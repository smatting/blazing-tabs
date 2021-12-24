(function() {

    const fakeTabs = [
        { id: 42, windowId: 1 , index: 1, title: "example title for tab 42", favIconUrl: "https://purescript-halogen.github.io/purescript-halogen/favicon.svg" , url: "http://www.nixos.org"}
    ];

    document.addEventListener('DOMContentLoaded', function() {
        console.log('doc ready');
        setTimeout(function() {
            console.log('sending message');
            callbacks.call('notifyTabs', fakeTabs);
        }, 100);
    }, false);

})();
