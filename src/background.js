function sendTabs(windowId) {
    chrome.tabs.query({windowId: windowId}, function(tabs) {
        chrome.runtime.sendMessage(null, {btabsMsgType: "tabs", tabs: tabs, windowId: windowId});
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
      sendTabs(message.windowId);
  }
});
