function sendTabs(windowId) {
    chrome.tabs.query({windowId: windowId}, function(tabs) {
        chrome.runtime.sendMessage(null, {stabberMsgType: "tabs", tabs: tabs, windowId: windowId});
    });
}

function makeTab() {
  chrome.tabs.create({url: "index.html", pinned: true});
}

function openSearch() {
  chrome.tabs.query({title: 'Stabber', windowId : browser.windows.WINDOW_ID_CURRENT}, function(tabs) {
      tabs = tabs || [];
      if (tabs.length > 0) {
          const stabberTab = tabs[0];
          console.log('stabberTab', stabberTab);
          // sendTabs(stabberTab.windowId);

          if (!stabberTab.highlighted) {
            chrome.tabs.highlight({windowId: stabberTab.windowId, tabs: [stabberTab.index]});
          } 

      } else {
          makeTab();
      }
  });
}

chrome.browserAction.onClicked.addListener(openSearch);

chrome.runtime.onMessage.addListener(function(message, sender) {
  if (message.stabberMsgType == "queryTabs") {
      console.log('message.tabs', message.tabs);
      sendTabs(message.windowId);
  }
});
