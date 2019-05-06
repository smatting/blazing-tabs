
// function makeTab() {
//   chrome.tabs.create({url: "index.html", pinned: true});
// }

// function openSearch() {

//   chrome.tabs.query({highlighted: true, currentWindow: true}, function(activeTabs) {
//     chrome.tabs.query({url:"chrome-extension://*/tabs.html", currentWindow: true}, function(tabs) {
//     if (tabs.length > 0) {
//       const hummingTab = tabs[0];
//       if ((activeTabs.length > 0) && (activeTabs[0].id == hummingTab.id)) {
//         chrome.runtime.sendMessage(null, {"type": "REFRESH_TAB_VIEW"});
//       } else {
//         chrome.tabs.highlight({tabs: [hummingTab.index], windowId: hummingTab.windowId}, function() {
//           chrome.runtime.sendMessage(null, {"type": "ACTIVATE_TAB_VIEW"});
//         });
//       }
//     } else {
//       makeTab();
//     }
//     })   
//   });
// }

// function updateTabView() {

// };

// chrome.browserAction.onClicked.addListener(openSearch);

// function onTabActivated(activeInfo) {
//   chrome.storage.local.get({tabsLastActive: {}}, function(data) {
//     // console.log('tabsLastActive', data.tabsLastActive);
//     data.tabsLastActive[activeInfo.tabId] = (+ new Date());
//     chrome.storage.local.set({tabsLastActive: data.tabsLastActive});
//   });
// }

// chrome.tabs.onActivated.addListener(onTabActivated);

function sendTabs(windowId) {
    chrome.tabs.query({}, function(tabs) {
        chrome.runtime.sendMessage(null, {stabberMsgType: "tabs", tabs: tabs});
    });
}

function makeTab() {
  // chrome.tabs.create({url: "index.html", pinned: true});
  chrome.tabs.create({url: "index.html", pinned: false});
}

function openSearch() {

  chrome.tabs.query({title: 'Stabber'}, function(tabs) {
      tabs = tabs || [];
      if (tabs.length > 0) {
          const stabberTab = tabs[0];
          console.log('stabberTab', stabberTab);

  //               chrome.runtime.sendMessage(null, {"type": "ACTIVATE_TAB_VIEW"});

          sendTabs(stabberTab.windowId);

          if (stabberTab.highlighted) {
          } else {
            chrome.tabs.highlight({windowId: stabberTab.windowId, tabs: [stabberTab.index]});
          }
      } else {
          makeTab();
      }
      // console.log('tabs', tabs);
  });

  // chrome.tabs.query({highlighted: true, currentWindow: true}, function(activeTabs) {
  //     chrome.tabs.query({url:"chrome-extension://*/index.html", currentWindow: true}, function(tabs) {
  //         console.log('tabs', tabs);
    
  //         tabs = tabs || [];
  //         if (tabs.length > 0) {
  //           const hummingTab = tabs[0];
  //           if ((activeTabs.length > 0) && (activeTabs[0].id == hummingTab.id)) {
  //             chrome.runtime.sendMessage(null, {"type": "REFRESH_TAB_VIEW"});
  //           } else {
  //             chrome.tabs.highlight({tabs: [hummingTab.index], windowId: hummingTab.windowId}, function() {
  //               chrome.runtime.sendMessage(null, {"type": "ACTIVATE_TAB_VIEW"});
  //             });
  //           }
  //         } else {
  //           makeTab();
  //         }
    
  //     })   
  // });

}

chrome.browserAction.onClicked.addListener(openSearch);

chrome.runtime.onMessage.addListener(function(message, sender) {
console.log('Backend got message', message);

  if (message.stabberMsgType == "queryTabs") {
      console.log('message.tabs', message.tabs);
      sendTabs();
  }

});
