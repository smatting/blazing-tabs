window.addEventListener('load', (event) => {
  chrome.windows.getCurrent((function(windowInfo) {
      const ownWindowId = windowInfo.id;

      callbacks.register('switchToTab', function(tabId) {
         chrome.tabs.get(tabId, function(tab) {
           chrome.tabs.highlight({"windowId": tab.windowId, "tabs": [tab.index]});
         });
      });

      const queryTabs = function() {
        chrome.runtime.sendMessage(null, {btabsMsgType: "queryTabs"});
      }

      window.onfocus = function () {
          queryTabs();
      };

      callbacks.register('closeTab', function(tabId) {
          chrome.tabs.remove(tabId, function() {});
      });

      chrome.runtime.onMessage.addListener(function(message, sender) {
          document.getElementById("tab-search").focus();
          if (message.btabsMsgType == "tabs") {
              callbacks.call('notifyTabs', {tabSources: message.tabs, ownWindowId: ownWindowId});
          }
          if (message.btabsMsgType == "shortcut-response") {
              console.log('received shortcut-response', message);
              callbacks.call('onShortcutResponse', message.shortcut);
          }
      });

      queryTabs();

      const requestShortcut = function() {
        chrome.runtime.sendMessage(null, {btabsMsgType: "shortcut-request"});
      }

      callbacks.register('requestShortcut', function() {
        console.log('requestShortcut');
        requestShortcut();
      });

      // requestShortcut();

  }));
});
