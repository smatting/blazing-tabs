(function() {
    document.addEventListener('DOMContentLoaded', function() {
        console.log('doc ready');
        setTimeout(function() {
            console.log('sending message');
            callbacks.call('notifyTabs', 'this is the message');
        }, 100);
    }, false);
})();
