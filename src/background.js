(function() {
  const tabActivated = {};

  function sendTabs() {
    chrome.tabs.query({}, function(tabs) {
      const tabSources = [];
      tabs.forEach(function(tab) {
        if (tab.favIconUrl) {
          favIconUrl = tab.favIconUrl.toString();
        } else {
          favIconUrl = null;
        }
        tabSources.push({
          id: tab.id,
          windowId: tab.windowId,
          title: tab.title,
          url: tab.url,
          lastActivated: tabActivated[tab.id] || 0,
          favIconUrl: favIconUrl,
          active: tab.active
        })
      });
      chrome.runtime.sendMessage(null, {btabsMsgType: "tabs", tabs: tabSources});
    });
  }

  function makeTab() {
    chrome.tabs.create({url: "index.html", pinned: true});
  }

  function openSearch() {
    chrome.tabs.query({title: 'Blazing Tabs', windowId : chrome.windows.WINDOW_ID_CURRENT}, function(tabs) {
        tabs = tabs || [];
        if (tabs.length > 0) {
            const blazingTab = tabs[0];
            if (!blazingTab.highlighted) {
              chrome.tabs.highlight({windowId: blazingTab.windowId, tabs: [blazingTab.index]});
            }
        } else {
            makeTab();
        }
    });
  }

  chrome.browserAction.onClicked.addListener(openSearch);

  chrome.runtime.onMessage.addListener(function(message, sender) {
    if (message.btabsMsgType == "queryTabs") {
        sendTabs();
    }
  });

  chrome.browserAction.onClicked.addListener(openSearch);

  chrome.tabs.onActivated.addListener(function(activeinfo) {
    tabActivated[activeinfo.tabId] = Date.now();
    sendTabs();
  });

})();
