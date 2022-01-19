"use strict";

exports.registerCallback = function(fn) {
    return function() {
        callbacks.register("notifyTabs", function(arg) {
            /* why additional()? https://book.purescript.org/chapter10.html#effectful-functions */
            fn(arg)();
        });
    };
};

exports.switchToTab = function(tabId) {
    return function() {
        callbacks.call('switchToTab', tabId);
    }
};

exports.closeTab = function(tabId) {
    return function() {
        callbacks.call('closeTab', tabId);
    }
};

exports.requestShortcut = function() {
    return function() {
        console.log('requestShortcut is called!');
        callbacks.call('requestShortcut', null);
    }
}

exports.onShortcutResponse = function(fn) {
    return function() {
        callbacks.register("onShortcutResponse", function(arg) {
            fn(arg)();
        });
    };
};
