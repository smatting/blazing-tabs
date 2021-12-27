(function() {
  window.addEventListener('load', (event) => {
    chrome.windows.getCurrent((function(windowInfo) {
        const myWindowId = windowInfo.id;

        callbacks.register('switchToTab', function(tabId) {
           chrome.tabs.get(tabId, function(tab) {
             chrome.tabs.highlight({"windowId": myWindowId, "tabs": [tab.index]});
           });
        });

        const queryTabs = function() {
          chrome.runtime.sendMessage(null, {stabberMsgType: "queryTabs", windowId: myWindowId});
        }

        window.onfocus = function () {
            queryTabs();
        };

        // TODO
        // app.ports.queryTabs.subscribe(function() {
        //     queryTabs();
        // });

        callbacks.register('closeTab', function(tabId) {
            chrome.tabs.remove(tabId, function() {});
        });

        chrome.runtime.onMessage.addListener(function(message, sender) {
            document.getElementById("tab-search").focus(); 

            // console.log('Got message', message);
            // console.log('WINDOW_ID_CURRENT', chrome.windows.WINDOW_ID_CURRENT);
            // console.log('message.windowId', message.windowId);
            if (message.windowId !== myWindowId) {
                return;
            }
            
            if (message.stabberMsgType == "tabs") {
                console.log('message.tabs', message.tabs);

                console.log('size', message.tabs.length);

                const tabs = message.tabs.map((function(tab) {
                    var favIconUrl = null;
                    if (tab.favIconUrl) {
                        favIconUrl = tab.favIconUrl.toString();
                    }
                    return { id: tab.id
                           , windowId: tab.windowId
                           , index: tab.index
                           , title: tab.title
                           , favIconUrl: favIconUrl
                           , lastAccessed: 0 /* TODO: remove. not available in chrome */
                           , url: tab.url
                           };
                }));

                callbacks.call('notifyTabs', tabs);
                // app.ports.tabs.send(tabs);
            }
        });

        queryTabs();
    }));
  });
})();
