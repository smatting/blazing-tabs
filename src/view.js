document.addEventListener('DOMContentLoaded', function() { 
    var app = new Vue({
        el: '#tab-view',
        data: {
            message: 'Hello Vue!',
            showHelp: false,
            searchInput: '',
            tabs: [],
            keyboardSelectionIndex: 0
        },
        methods: {
            moveKeyboardSelection: function(delta) {
                const i = this.keyboardSelectionIndex;
                const n = _.size(this.tabs);
                const iNext = Math.min((Math.max(i + delta, 0)), n-1);
                this.keyboardSelectionIndex = iNext;
            },
            closeTab: function(tabId, event) {
                const that = this;
                chrome.tabs.remove(tabId, function() {
                    // console.log('tabs inside closeTab', that.tabs);
                    that.tabs = _.filter(that.tabs, function(tab) {return tab.id !== tabId});
                });
            },
            closeTabsOlderThan: function(secs) {
                const that = this;
                chrome.storage.local.get({tabsLastActive: {}}, function(data) {
                    const now = (+ new Date());
                    const tabAge = timeSinceLastActive(now, data.tabsLastActive);
                    var tabsToClose = _.filter(that.tabs, function(tab) {
                        return (tabAge(tab) / 1000 > secs) && tab.url != window.location.href && !tab.pinned;
                    });
                    _.forEach(tabsToClose, function(tab) {
                        that.closeTab(tab.id);
                    });
                });
            },
            switchToTab: function(tabid) {
                console.log('switchToTab', tabid);
                chrome.tabs.get(tabid, function(tab) {
                    if (tab) {
                    //   console.log("found tab", tab);
                        chrome.tabs.highlight({tabs: [tab.index]});
                    } else {
                    console.log("did not find tab", tabid);
                    }
                });
            },
            switchToSelectedTab: function() {
                const i = this.keyboardSelectionIndex;
                const n = _.size(this.tabs);
                if ((0 <= i) && (i < n)) {
                    this.switchToTab(this.tabs[i].id);
                }
            },
            onSearchInput: function(value) {
                // console.log('onSearchInput', value);
                this.keyboardSelectionIndex = 0;
                if (value.startsWith('!')) {
                    return;
                }
                if (value == "?") {
                    this.showHelp = true;
                } else {
                    this.showHelp = false;
                    this.resortTabs(null, value);
                }
            },
            resortTabs: function(tabs, query) {

                if (_.isNil(tabs)) {
                    tabs = this.tabs;
                }

                let performSearch;
                if (_.isNil(query)) {
                    performSearch = false;
                } else {
                    query = query.replace(/\s/g, '');
                    performSearch = (!_.isEmpty(query));
                }
                if (performSearch) {
                    _.forEach(tabs, function(tab) {
                        if (_.isNil(tab.title) || _.isEmpty(tab.title)) {
                            tab.searchScore = 0;
                            return
                        }
                        // const url = new URL(tab.url);
                        // const urlScore_ = doScore(query, url.hostname + url.pathname);
                        const urlScore_ = doScore(query, tab.url);
                        const urlScore = _.isNil(urlScore_[0]) ? 0 : urlScore_[0];

                        const res = doScore(query, tab.title);
                        if (res == NO_MATCH) {
                            tab.searchScore = urlScore;
                            tab.searchPositions = null;
                        } else {
                            tab.searchScore = res[0] + 0.5 * urlScore;

                            tab.searchPositions = res[1];
                            const highlights = _.map(searchHighlights(res[1], tab.title.length), function(r) {
                                r.text = tab.title.slice(r.range[0], r.range[1]+1);
                                return r
                            });
                            if (highlights.length > 0) {
                                tab.highlights = highlights;
                            } else {
                                tab.highlights = null;
                            }
                            // if (tab.highlights.length > 0) {
                            //     console.log(tab.highlights);
                            // }
                        }
                    });
                    tabs = _.orderBy(tabs, 'searchScore', ["desc"]);
                    app.tabs = tabs;
                } else {
                    _.forEach(tabs, function(tab) {
                        tab.searchPositions = null;
                        tab.highlights = null;
                    });
                    chrome.storage.local.get({tabsLastActive: {}}, function(data) {
                        var tabsFiltered = _.filter(tabs, function(tab) {return tab.url != window.location.href;});
                        // console.log('tabsFiltered', tabsFiltered);
                        const tabsSorted = sortTabs(tabsFiltered, data.tabsLastActive);
                        app.tabs = tabsSorted;
                    });
                }
            }
        }
    });

    function timeSinceLastActive(now, tabsLastActive) {
        return function(tab) {
            const t = tabsLastActive[tab.id];
            if (t !== undefined) {
                return now - t;
            } else {
                return 1000000000000;
            }
        };
    };

    function sortTabs(tabs, tabsLastActive) {
        const now = (+ new Date());
        const tabsSorted = _.sortBy(tabs, timeSinceLastActive(now, tabsLastActive))
        return tabsSorted;
    };

    function updateTabView() {
        console.log('updateTabView()');

        // document.getElementById('tab-search').value = '';
        app.searchInput = '';

        app.keyboardSelectionIndex = 0;

        // console.log('updateTabView');
        chrome.tabs.query({currentWindow: true}, function(tabs) {
            app.resortTabs(tabs);
            // chrome.storage.local.get({tabsLastActive: {}}, function(data) {
            //     var tabsFiltered = _.filter(tabs, function(tab) {return tab.url != window.location.href;});
            //     // console.log('tabsFiltered', tabsFiltered);
            //     const tabsSorted = sortTabs(tabsFiltered, data.tabsLastActive);
            //     app.tabs = tabsSorted;
            // });
        });
        // chrome.storage.local.get({tabs: {}}, function(data) {
        //     console.log('tabs read', data.tabs);
        //     app.message = _.size(data.tabs);
        //     app.tabs = _.values(data.tabs);
        // });
    };

    const NO_MATCH = 0;
    const NO_SCORE = 0;

    // function computeCharScore(query: string, queryLower: string, queryIndex: number, target: string, targetLower: string, targetIndex: number, matchesSequenceLength: number): number {
    function computeCharScore(query, queryLower, queryIndex, target, targetLower, targetIndex, matchesSequenceLength) {
        let score = 0;

        if (queryLower[queryIndex] !== targetLower[targetIndex]) {
            return score; // no match of characters
        }

        // Character match bonus
        score += 1;

        // if (DEBUG) {
        // 	console.groupCollapsed(`%cCharacter match bonus: +1 (char: ${queryLower[queryIndex]} at index ${targetIndex}, total score: ${score})`, 'font-weight: normal');
        // }

        // Consecutive match bonus
        if (matchesSequenceLength > 0) {
            score += (matchesSequenceLength * 5);

            // if (DEBUG) {
            // 	console.log('Consecutive match bonus: ' + (matchesSequenceLength * 5));
            // }
        }

        // Same case bonus
        if (query[queryIndex] === target[targetIndex]) {
            score += 1;

            // if (DEBUG) {
            // 	console.log('Same case bonus: +1');
            // }
        }

        // Start of word bonus
        if (targetIndex === 0) {
            score += 8;

            // if (DEBUG) {
            // 	console.log('Start of word bonus: +8');
            // }
        }

        else {

            // After separator bonus
            const separatorBonus = scoreSeparatorAtPos(target.charCodeAt(targetIndex - 1));
            // const separatorBonus = 0;
            if (separatorBonus) {
                score += separatorBonus;

                // if (DEBUG) {
                // 	console.log('After separtor bonus: +4');
                // }
            }

            // Inside word upper case bonus (camel case)
            // else if (isUpper(target.charCodeAt(targetIndex))) {
            //     score += 1;

            //     // if (DEBUG) {
            //     // 	console.log('Inside word upper case bonus: +1');
            //     // }
            // }
        }

        // if (DEBUG) {
        // 	console.groupEnd();
        // }

        return score;
    }


    // function scoreSeparatorAtPos(charCode: number): number {
    function scoreSeparatorAtPos(charCode) {
        switch (charCode) {
            case 47: // CharCode.Slash:
            case 92: // CharCode.Backslash:
                return 5; // prefer path separators...
            case 95: // CharCode.Underline:
            case 45: // CharCode.Dash:
            case 46: // CharCode.Period:
            case 32: // CharCode.Space:
            case 39: // CharCode.SingleQuote:
            case 34: // CharCode.DoubleQuote:
            case 58: // CharCode.Colon:
                return 4; // ...over other separators
            default:
                return 0;
        }
    }

    function doScore(query, target) {

        const targetLength = target.length;
        const queryLength = query.length;
        const targetLower = target.toLowerCase();
        const queryLower = query.toLowerCase();

        if (!target || !query) {
            return NO_SCORE; // return early if target or query are undefined
        }

        if (targetLength < queryLength) {
            return NO_SCORE; // impossible for query to be contained in target
        }
        

        const scores = [];
        const matches = [];

        //
        // Build Scorer Matrix:
        //
        // The matrix is composed of query q and target t. For each index we score
        // q[i] with t[i] and compare that with the previous score. If the score is
        // equal or larger, we keep the match. In addition to the score, we also keep
        // the length of the consecutive matches to use as boost for the score.
        //
        //      t   a   r   g   e   t
        //  q
        //  u
        //  e
        //  r
        //  y
        //
        for (let queryIndex = 0; queryIndex < queryLength; queryIndex++) {
            for (let targetIndex = 0; targetIndex < targetLength; targetIndex++) {
                const currentIndex = queryIndex * targetLength + targetIndex;
                const leftIndex = currentIndex - 1;
                const diagIndex = (queryIndex - 1) * targetLength + targetIndex - 1;

                const leftScore = targetIndex > 0 ? scores[leftIndex] : 0;
                const diagScore = queryIndex > 0 && targetIndex > 0 ? scores[diagIndex] : 0;

                const matchesSequenceLength = queryIndex > 0 && targetIndex > 0 ? matches[diagIndex] : 0;

                // If we are not matching on the first query character any more, we only produce a
                // score if we had a score previously for the last query index (by looking at the diagScore).
                // This makes sure that the query always matches in sequence on the target. For example
                // given a target of "ede" and a query of "de", we would otherwise produce a wrong high score
                // for query[1] ("e") matching on target[0] ("e") because of the "beginning of word" boost.
                let score;
                if (!diagScore && queryIndex > 0) {
                    score = 0;
                } else {
                    score = computeCharScore(query, queryLower, queryIndex, target, targetLower, targetIndex, matchesSequenceLength);
                    // score = 1;
                }

                // We have a score and its equal or larger than the left score
                // Match: sequence continues growing from previous diag value
                // Score: increases by diag score value
                if (score && diagScore + score >= leftScore) {
                    matches[currentIndex] = matchesSequenceLength + 1;
                    scores[currentIndex] = diagScore + score;
                }

                // We either have no score or the score is lower than the left score
                // Match: reset to 0
                // Score: pick up from left hand side
                else {
                    matches[currentIndex] = NO_MATCH;
                    scores[currentIndex] = leftScore;
                }
            }
        }

        // Restore Positions (starting from bottom right of matrix)
        const positions = [];
        let queryIndex = queryLength - 1;
        let targetIndex = targetLength - 1;
        while (queryIndex >= 0 && targetIndex >= 0) {
            const currentIndex = queryIndex * targetLength + targetIndex;
            const match = matches[currentIndex];
            if (match === NO_MATCH) {
                targetIndex--; // go left
            } else {
                positions.push(targetIndex);

                // go up and left
                queryIndex--;
                targetIndex--;
            }
        }

        // Print matrix
        // if (DEBUG_MATRIX) {
        // printMatrix(query, target, matches, scores);
        // }

        return [scores[queryLength * targetLength - 1], positions.reverse()];
    }

    chrome.runtime.onMessage.addListener(function(message, sender) {
        // console.log('Got message', message);
        document.getElementById('tab-search').focus();
        if (message.type == 'ACTIVATE_TAB_VIEW') {
            console.log('ACTIVATE_TAB_VIEW');
            // app.keyboardSelectionIndex = 0;
            updateTabView();
        }
        if (message.type == 'REFRESH_TAB_VIEW') {
            app.moveKeyboardSelection(1);
            console.log('REFRESH_TAB_VIEW');
            // updateTabView();
        }
    });

    window.addEventListener("keydown", function(e) {
        // console.log('keydown', e.keyCode);
        if (e.keyCode == 38) {
            e.preventDefault();
            e.stopPropagation();
            app.moveKeyboardSelection(-1);
        }
        if (e.keyCode == 40) {
            e.preventDefault();
            e.stopPropagation();
            app.moveKeyboardSelection(1);
        }
        // ENTER
        if (e.keyCode == 13) {
            if (app.searchInput.startsWith('!')) {
                const regex = /!\s*close (\d+)(h|m|d)/g;
                const match = regex.exec(app.searchInput);
                if (match) {
                    document.getElementById('tab-search').select();
                    const secsUnit = {h: 60*60, m: 60, d: 24*60*60}[match[2]];
                    const secs = parseInt(match[1]) * secsUnit;
                    app.closeTabsOlderThan(secs);
                }
            } else {
                app.switchToSelectedTab();
            }
        }
    });


    document.getElementById('tab-search').focus();
    // document.getElementById('tab-search').addEventListener('blur', function() {
    //     document.getElementById('tab-search').focus();
    // });

    updateTabView();

    function searchHighlights(searchPositions, stringLength) {
        const l = searchPositions;
        const n = stringLength;

        if (l.length == 0) {
            return [];
        }
        const mids =_.filter(_.zip(l, _.tail(l)), function(pair) {
            return !_.isNil(pair[0]) && !_.isNil(pair[1]) && pair[0] + 1 != pair[1];
        });
        const selectedRanges_ = _.chunk(_.concat(l[0], _.flatten(mids), l[l.length-1]), 2);
        const selectedRanges = _.map(selectedRanges_, function(pair) { return {type: 'Selection', range: pair} }); 

        const interRanges_ = _.map(mids, function(pair) { return [pair[0] + 1, pair[1] - 1]; });
        const interRanges__ = _.concat(
            [[0, selectedRanges_[0][0]-1]],
            interRanges_,
            [[selectedRanges_[selectedRanges_.length-1][1]+1, n-1]])
        const interRanges = _.map(interRanges__, function(pair) { return {type: 'NonSelection', range: pair} }); 

        const validIndex = function(i) { return 0 <= i && i < n };
        const validRange = function(pair) { return validIndex(pair[0]) && validIndex(pair[1]) && pair[0] <= pair[1] }

        const allRanges_ = _.flatten(_.zip(interRanges, selectedRanges));
        const allRanges = _.filter(allRanges_, function(r) {
            if (_.isNil(r)) {
                return false;
            }
            return validRange(r.range);
        });

        return allRanges;
    };
    
    chrome.commands.getAll(function(commands) {
        if (commands.length > 0) {
            const shortcut = commands[0].shortcut;
            if (shortcut != '') {
                app.shortcut = shortcut;
                return
            }
        }
        app.shortcut = undefined;
    });

}, false);
