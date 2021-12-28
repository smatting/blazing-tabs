(function() {

    // const fakeTabs = [
    //     { id: 42, windowId: 1 , index: 1, title: "example title for tab 42", favIconUrl: "https://purescript-halogen.github.io/purescript-halogen/favicon.svg" , url: "http://www.nixos.org"}
    // ];
    const fakeTabs = [
    {
        "id": 108,
        "index": 0,
        "windowId": 1,
        "highlighted": true,
        "active": true,
        "attention": false,
        "pinned": true,
        "status": "complete",
        "hidden": false,
        "discarded": false,
        "incognito": false,
        "width": 1918,
        "height": 969,
        "lastAccessed": 1640352848704,
        "audible": false,
        "mutedInfo": {
        "muted": false
        },
        "isInReaderMode": false,
        "sharingState": {
        "camera": false,
        "microphone": false
        },
        "successorTabId": -1,
        "cookieStoreId": "firefox-default",
        "url": "moz-extension://45ba499b-65f9-4806-907c-62795d6ef1f6/index.html",
        "title": "Stabber"
    },
    {
        "id": 88,
        "index": 1,
        "windowId": 1,
        "highlighted": false,
        "active": false,
        "attention": false,
        "pinned": false,
        "status": "complete",
        "hidden": false,
        "discarded": false,
        "incognito": false,
        "width": 1918,
        "height": 245,
        "lastAccessed": 1640352848587,
        "audible": false,
        "mutedInfo": {
        "muted": false
        },
        "isArticle": false,
        "isInReaderMode": false,
        "sharingState": {
        "camera": false,
        "microphone": false
        },
        "successorTabId": -1,
        "cookieStoreId": "firefox-default",
        "url": "file:///home/stefan/repos/stabber/ui-integration/index.html",
        "title": "Problem loading page",
        "favIconUrl": "chrome://global/skin/icons/info.svg"
    },
    {
        "id": 96,
        "index": 2,
        "windowId": 1,
        "highlighted": false,
        "active": false,
        "attention": false,
        "pinned": false,
        "status": "complete",
        "hidden": false,
        "discarded": false,
        "incognito": false,
        "width": 1918,
        "height": 245,
        "lastAccessed": 1640352611363,
        "audible": false,
        "mutedInfo": {
        "muted": false
        },
        "isArticle": true,
        "isInReaderMode": false,
        "sharingState": {
        "camera": false,
        "microphone": false
        },
        "successorTabId": -1,
        "cookieStoreId": "firefox-default",
        "url": "https://purescript-halogen.github.io/purescript-halogen/guide/04-Lifecycles-Subscriptions.html",
        "title": "Lifecycles & Subscriptions - Halogen Guide",
        "favIconUrl": "data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxOTkuNyAxODQuMiI+CiAgPHN0eWxlPgogICAgQG1lZGlhIChwcmVmZXJzLWNvbG9yLXNjaGVtZTogZGFyaykgewogICAgICBzdmcgeyBmaWxsOiB3aGl0ZTsgfQogICAgfQogIDwvc3R5bGU+CjxwYXRoIGQ9Ik0xODkuNSwzNi44YzAuMiwyLjgsMCw1LjEtMC42LDYuOEwxNTMsMTYyYy0wLjYsMi4xLTIsMy43LTQuMiw1Yy0yLjIsMS4yLTQuNCwxLjktNi43LDEuOUgzMS40Yy05LjYsMC0xNS4zLTIuOC0xNy4zLTguNAogIGMtMC44LTIuMi0wLjgtMy45LDAuMS01LjJjMC45LTEuMiwyLjQtMS44LDQuNi0xLjhIMTIzYzcuNCwwLDEyLjYtMS40LDE1LjQtNC4xczUuNy04LjksOC42LTE4LjRsMzIuOS0xMDguNgogIGMxLjgtNS45LDEtMTEuMS0yLjItMTUuNlMxNjkuOSwwLDE2NCwwSDcyLjdjLTEsMC0zLjEsMC40LTYuMSwxLjFsMC4xLTAuNEM2NC41LDAuMiw2Mi42LDAsNjEsMC4xcy0zLDAuNS00LjMsMS40CiAgYy0xLjMsMC45LTIuNCwxLjgtMy4yLDIuOFM1Miw2LjUsNTEuMiw4LjFjLTAuOCwxLjYtMS40LDMtMS45LDQuM3MtMS4xLDIuNy0xLjgsNC4yYy0wLjcsMS41LTEuMywyLjctMiwzLjdjLTAuNSwwLjYtMS4yLDEuNS0yLDIuNQogIHMtMS42LDItMi4yLDIuOHMtMC45LDEuNS0xLjEsMi4yYy0wLjIsMC43LTAuMSwxLjgsMC4yLDMuMmMwLjMsMS40LDAuNCwyLjQsMC40LDMuMWMtMC4zLDMtMS40LDYuOS0zLjMsMTEuNgogIGMtMS45LDQuNy0zLjYsOC4xLTUuMSwxMC4xYy0wLjMsMC40LTEuMiwxLjMtMi42LDIuN2MtMS40LDEuNC0yLjMsMi42LTIuNiwzLjdjLTAuMywwLjQtMC4zLDEuNS0wLjEsMy40YzAuMywxLjgsMC40LDMuMSwwLjMsMy44CiAgYy0wLjMsMi43LTEuMyw2LjMtMywxMC44Yy0xLjcsNC41LTMuNCw4LjItNSwxMWMtMC4yLDAuNS0wLjksMS40LTIsMi44Yy0xLjEsMS40LTEuOCwyLjUtMiwzLjRjLTAuMiwwLjYtMC4xLDEuOCwwLjEsMy40CiAgYzAuMiwxLjYsMC4yLDIuOC0wLjEsMy42Yy0wLjYsMy0xLjgsNi43LTMuNiwxMWMtMS44LDQuMy0zLjYsNy45LTUuNCwxMWMtMC41LDAuOC0xLjEsMS43LTIsMi44Yy0wLjgsMS4xLTEuNSwyLTIsMi44CiAgcy0wLjgsMS42LTEsMi41Yy0wLjEsMC41LDAsMS4zLDAuNCwyLjNjMC4zLDEuMSwwLjQsMS45LDAuNCwyLjZjLTAuMSwxLjEtMC4yLDIuNi0wLjUsNC40Yy0wLjIsMS44LTAuNCwyLjktMC40LDMuMgogIGMtMS44LDQuOC0xLjcsOS45LDAuMiwxNS4yYzIuMiw2LjIsNi4yLDExLjUsMTEuOSwxNS44YzUuNyw0LjMsMTEuNyw2LjQsMTcuOCw2LjRoMTEwLjdjNS4yLDAsMTAuMS0xLjcsMTQuNy01LjJzNy43LTcuOCw5LjItMTIuOQogIGwzMy0xMDguNmMxLjgtNS44LDEtMTAuOS0yLjItMTUuNUMxOTQuOSwzOS43LDE5Mi42LDM4LDE4OS41LDM2Ljh6IE01OS42LDEyMi44TDczLjgsODBjMCwwLDcsMCwxMC44LDBzMjguOC0xLjcsMjUuNCwxNy41CiAgYy0zLjQsMTkuMi0xOC44LDI1LjItMzYuOCwyNS40UzU5LjYsMTIyLjgsNTkuNiwxMjIuOHogTTc4LjYsMTE2LjhjNC43LTAuMSwxOC45LTIuOSwyMi4xLTE3LjFTODkuMiw4Ni4zLDg5LjIsODYuM2wtOC45LDAKICBsLTEwLjIsMzAuNUM3MC4yLDExNi45LDc0LDExNi45LDc4LjYsMTE2Ljh6IE03NS4zLDY4LjdMODksMjYuMmg5LjhsMC44LDM0bDIzLjYtMzRoOS45bC0xMy42LDQyLjVoLTcuMWwxMi41LTM1LjRsLTI0LjUsMzUuNGgtNi44CiAgbC0wLjgtMzVMODIsNjguN0g3NS4zeiIvPgo8L3N2Zz4KPCEtLSBPcmlnaW5hbCBpbWFnZSBDb3B5cmlnaHQgRGF2ZSBHYW5keSDigJTCoENDIEJZIDQuMCBMaWNlbnNlIC0tPgo="
    },
    {
        "id": 74,
        "index": 3,
        "windowId": 1,
        "highlighted": false,
        "active": false,
        "attention": false,
        "pinned": false,
        "status": "complete",
        "hidden": false,
        "discarded": false,
        "incognito": false,
        "width": 1918,
        "height": 928,
        "lastAccessed": 1640352656634,
        "audible": false,
        "mutedInfo": {
        "muted": false
        },
        "isArticle": false,
        "isInReaderMode": false,
        "sharingState": {
        "camera": false,
        "microphone": false
        },
        "successorTabId": -1,
        "cookieStoreId": "firefox-default",
        "url": "file:///home/stefan/repos/stabber/generated-docs/html/Foreign.html#search:show",
        "title": "PureScript: Foreign"
    },
    {
        "id": 61,
        "index": 4,
        "windowId": 1,
        "highlighted": false,
        "active": false,
        "attention": false,
        "pinned": false,
        "status": "complete",
        "hidden": false,
        "discarded": false,
        "incognito": false,
        "width": 1918,
        "height": 928,
        "lastAccessed": 1640352610564,
        "audible": false,
        "mutedInfo": {
        "muted": false
        },
        "isArticle": true,
        "isInReaderMode": false,
        "sharingState": {
        "camera": false,
        "microphone": false
        },
        "successorTabId": -1,
        "cookieStoreId": "firefox-default",
        "url": "https://book.purescript.org/chapter3.html",
        "title": "Functions and Records - PureScript by Example",
        "favIconUrl": "data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxOTkuNyAxODQuMiI+CiAgPHN0eWxlPgogICAgQG1lZGlhIChwcmVmZXJzLWNvbG9yLXNjaGVtZTogZGFyaykgewogICAgICBzdmcgeyBmaWxsOiB3aGl0ZTsgfQogICAgfQogIDwvc3R5bGU+CjxwYXRoIGQ9Ik0xODkuNSwzNi44YzAuMiwyLjgsMCw1LjEtMC42LDYuOEwxNTMsMTYyYy0wLjYsMi4xLTIsMy43LTQuMiw1Yy0yLjIsMS4yLTQuNCwxLjktNi43LDEuOUgzMS40Yy05LjYsMC0xNS4zLTIuOC0xNy4zLTguNAogIGMtMC44LTIuMi0wLjgtMy45LDAuMS01LjJjMC45LTEuMiwyLjQtMS44LDQuNi0xLjhIMTIzYzcuNCwwLDEyLjYtMS40LDE1LjQtNC4xczUuNy04LjksOC42LTE4LjRsMzIuOS0xMDguNgogIGMxLjgtNS45LDEtMTEuMS0yLjItMTUuNlMxNjkuOSwwLDE2NCwwSDcyLjdjLTEsMC0zLjEsMC40LTYuMSwxLjFsMC4xLTAuNEM2NC41LDAuMiw2Mi42LDAsNjEsMC4xcy0zLDAuNS00LjMsMS40CiAgYy0xLjMsMC45LTIuNCwxLjgtMy4yLDIuOFM1Miw2LjUsNTEuMiw4LjFjLTAuOCwxLjYtMS40LDMtMS45LDQuM3MtMS4xLDIuNy0xLjgsNC4yYy0wLjcsMS41LTEuMywyLjctMiwzLjdjLTAuNSwwLjYtMS4yLDEuNS0yLDIuNQogIHMtMS42LDItMi4yLDIuOHMtMC45LDEuNS0xLjEsMi4yYy0wLjIsMC43LTAuMSwxLjgsMC4yLDMuMmMwLjMsMS40LDAuNCwyLjQsMC40LDMuMWMtMC4zLDMtMS40LDYuOS0zLjMsMTEuNgogIGMtMS45LDQuNy0zLjYsOC4xLTUuMSwxMC4xYy0wLjMsMC40LTEuMiwxLjMtMi42LDIuN2MtMS40LDEuNC0yLjMsMi42LTIuNiwzLjdjLTAuMywwLjQtMC4zLDEuNS0wLjEsMy40YzAuMywxLjgsMC40LDMuMSwwLjMsMy44CiAgYy0wLjMsMi43LTEuMyw2LjMtMywxMC44Yy0xLjcsNC41LTMuNCw4LjItNSwxMWMtMC4yLDAuNS0wLjksMS40LTIsMi44Yy0xLjEsMS40LTEuOCwyLjUtMiwzLjRjLTAuMiwwLjYtMC4xLDEuOCwwLjEsMy40CiAgYzAuMiwxLjYsMC4yLDIuOC0wLjEsMy42Yy0wLjYsMy0xLjgsNi43LTMuNiwxMWMtMS44LDQuMy0zLjYsNy45LTUuNCwxMWMtMC41LDAuOC0xLjEsMS43LTIsMi44Yy0wLjgsMS4xLTEuNSwyLTIsMi44CiAgcy0wLjgsMS42LTEsMi41Yy0wLjEsMC41LDAsMS4zLDAuNCwyLjNjMC4zLDEuMSwwLjQsMS45LDAuNCwyLjZjLTAuMSwxLjEtMC4yLDIuNi0wLjUsNC40Yy0wLjIsMS44LTAuNCwyLjktMC40LDMuMgogIGMtMS44LDQuOC0xLjcsOS45LDAuMiwxNS4yYzIuMiw2LjIsNi4yLDExLjUsMTEuOSwxNS44YzUuNyw0LjMsMTEuNyw2LjQsMTcuOCw2LjRoMTEwLjdjNS4yLDAsMTAuMS0xLjcsMTQuNy01LjJzNy43LTcuOCw5LjItMTIuOQogIGwzMy0xMDguNmMxLjgtNS44LDEtMTAuOS0yLjItMTUuNUMxOTQuOSwzOS43LDE5Mi42LDM4LDE4OS41LDM2Ljh6IE01OS42LDEyMi44TDczLjgsODBjMCwwLDcsMCwxMC44LDBzMjguOC0xLjcsMjUuNCwxNy41CiAgYy0zLjQsMTkuMi0xOC44LDI1LjItMzYuOCwyNS40UzU5LjYsMTIyLjgsNTkuNiwxMjIuOHogTTc4LjYsMTE2LjhjNC43LTAuMSwxOC45LTIuOSwyMi4xLTE3LjFTODkuMiw4Ni4zLDg5LjIsODYuM2wtOC45LDAKICBsLTEwLjIsMzAuNUM3MC4yLDExNi45LDc0LDExNi45LDc4LjYsMTE2Ljh6IE03NS4zLDY4LjdMODksMjYuMmg5LjhsMC44LDM0bDIzLjYtMzRoOS45bC0xMy42LDQyLjVoLTcuMWwxMi41LTM1LjRsLTI0LjUsMzUuNGgtNi44CiAgbC0wLjgtMzVMODIsNjguN0g3NS4zeiIvPgo8L3N2Zz4KPCEtLSBPcmlnaW5hbCBpbWFnZSBDb3B5cmlnaHQgRGF2ZSBHYW5keSDigJTCoENDIEJZIDQuMCBMaWNlbnNlIC0tPgo="
    },
    {
        "id": 100,
        "index": 5,
        "windowId": 1,
        "highlighted": false,
        "active": false,
        "attention": false,
        "pinned": false,
        "status": "complete",
        "hidden": false,
        "discarded": false,
        "incognito": false,
        "width": 1918,
        "height": 969,
        "lastAccessed": 1640352380007,
        "audible": false,
        "mutedInfo": {
        "muted": false
        },
        "isArticle": true,
        "isInReaderMode": false,
        "sharingState": {
        "camera": false,
        "microphone": false
        },
        "successorTabId": -1,
        "cookieStoreId": "firefox-default",
        "url": "https://www.tutorialspoint.com/html5/html5_character_encodings.htm",
        "title": "HTML5 - Character Encodings",
        "favIconUrl": "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAABEFpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADw/eHBhY2tldCBiZWdpbj0i77u/IiBpZD0iVzVNME1wQ2VoaUh6cmVTek5UY3prYzlkIj8+IDx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IkFkb2JlIFhNUCBDb3JlIDUuNS1jMDIxIDc5LjE1NDkxMSwgMjAxMy8xMC8yOS0xMTo0NzoxNiAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wUmlnaHRzPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvcmlnaHRzLyIgeG1sbnM6eG1wTU09Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9tbS8iIHhtbG5zOnN0UmVmPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvc1R5cGUvUmVzb3VyY2VSZWYjIiB4bWxuczp4bXA9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC8iIHhtbG5zOmRjPSJodHRwOi8vcHVybC5vcmcvZGMvZWxlbWVudHMvMS4xLyIgeG1wUmlnaHRzOk1hcmtlZD0iRmFsc2UiIHhtcE1NOkRvY3VtZW50SUQ9InhtcC5kaWQ6NjlFRjRDRkEyMkFCMTFFNDhGQTc4RkYyNTY3NTVDM0QiIHhtcE1NOkluc3RhbmNlSUQ9InhtcC5paWQ6NjlFRjRDRjkyMkFCMTFFNDhGQTc4RkYyNTY3NTVDM0QiIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIENTMyBXaW5kb3dzIj4gPHhtcE1NOkRlcml2ZWRGcm9tIHN0UmVmOmluc3RhbmNlSUQ9InhtcC5paWQ6OUNGRkMyMDNGNjE1MTFFMzg5OEE5Mjg0MjY2Q0I2RDEiIHN0UmVmOmRvY3VtZW50SUQ9InhtcC5k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"
    },
    {
        "id": 104,
        "index": 6,
        "windowId": 1,
        "highlighted": false,
        "active": false,
        "attention": false,
        "pinned": false,
        "status": "complete",
        "hidden": false,
        "discarded": false,
        "incognito": false,
        "width": 1918,
        "height": 969,
        "lastAccessed": 1640352380906,
        "audible": false,
        "mutedInfo": {
        "muted": false
        },
        "isArticle": true,
        "isInReaderMode": false,
        "sharingState": {
        "camera": false,
        "microphone": false
        },
        "successorTabId": -1,
        "cookieStoreId": "firefox-default",
        "url": "https://flaviocopes.com/commonjs/",
        "title": "CommonJS JavaScript Module Format, an introduction",
        "favIconUrl": "data:image/png;base64,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"
    }
    ];

    callbacks.register('switchToTab', function(arg) {
        console.log('[mock] switching to tab ', arg);
    });

    callbacks.register('closeTab', function(arg) {
        console.log('[mock] closing tab ', arg);
    });

    document.addEventListener('DOMContentLoaded', function() {
        console.log('doc ready');
        setTimeout(function() {
            // console.log('sending message');
            callbacks.call('notifyTabs', fakeTabs);
        }, 100);
    }, false);


})();
