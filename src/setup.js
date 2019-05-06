(function() {
  window.addEventListener('load', (event) => {
      console.log('this is setup.js');

      var app = Elm.Main.init({
        node: document.getElementById('elm'),
        flags: "bla"
      });


      app.ports.highlight.subscribe(function(highlightInfo) {
        chrome.tabs.highlight(highlightInfo);
      });

      app.ports.queryTabs.subscribe(function() {
          console.log('sendMessage: queryTabs');
          chrome.runtime.sendMessage(null, {stabberMsgType: "queryTabs"});
      });

      app.ports.doCloseTab.subscribe(function(msg) {
          chrome.tabs.remove(msg.tabId, function() {
              chrome.runtime.sendMessage(null, {stabberMsgType: "queryTabs"});
          });
      })

      // app.ports.doFocus.subscribe(function(msg) {
      //   document.getElementById("elm").focus(); 
      // }

      chrome.runtime.onMessage.addListener(function(message, sender) {
          document.getElementById("tab-search").focus(); 

          console.log('Got message', message);
          if (message.stabberMsgType == "tabs") {
              console.log('message.tabs', message.tabs);

              console.log('size', _.size(message.tabs));


              const tabs = _.map(message.tabs, function(tab) {
                  var favIconUrl = null;
                  if (tab.favIconUrl) {
                      favIconUrl = tab.favIconUrl.toString();
                  }
                  return { id: tab.id
                         , windowId: tab.windowId
                         , index: tab.index
                         , title: tab.title
                         , favIconUrl: favIconUrl
                         , lastAccessed: tab.lastAccessed
                         };
              });
              // const tabs = _.forEach([1,2,3], function(tab, i) {
              //     console.log('tab', tab);
              //     console.log('i', i);
              // });

              console.log('Got tabs', tabs);

              // message
              // app.ports.tabs.send({hello: "world"});
              app.ports.tabs.send(tabs);
          }

          // document.getElementById('tab-search').focus();
          // if (message.type == 'ACTIVATE_TAB_VIEW') {
          //     console.log('ACTIVATE_TAB_VIEW');
          //     // app.keyboardSelectionIndex = 0;
          //     updateTabView();
          // }
          // if (message.type == 'REFRESH_TAB_VIEW') {
          //     app.moveKeyboardSelection(1);
          //     console.log('REFRESH_TAB_VIEW');
          //     // updateTabView();
          // }
      });
  });
})();
