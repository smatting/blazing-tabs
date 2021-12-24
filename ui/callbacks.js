"use strict";

var callbacks = (function() {

    function register(name, fn) {
        console.log('this is register', name);
        console.log('this is fn', fn);
        window.cbks = window.cbks || {};
        window.cbks[name] = window.cbks[name] || [];
        window.cbks[name].push(fn);
    }

    function call(name, arg) {
        window.cbks = window.cbks || {};
        window.cbks[name] = window.cbks[name] || [];
        window.cbks[name].forEach(function(callback) {
            console.log(window.cbks);
            console.log('callback is', callback);
            console.log('arg is', arg);
            return callback(arg);
        });
    }

    return ({
        register: register,
        call: call
    });

})();

(function() {
    document.addEventListener('DOMContentLoaded', function() {
        console.log('doc ready');
        setTimeout(function() {
            console.log('sending message');
            callbacks.call('notifyTabs', 'this is the message');
        }, 1000);
    }, false);

})();
