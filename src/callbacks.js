"use strict";

var callbacks = (function() {
    function register(name, fn) {
        window.cbks = window.cbks || {};
        window.cbks[name] = window.cbks[name] || [];
        window.cbks[name].push(fn);
    }

    function call(name, arg) {
        window.cbks = window.cbks || {};
        window.cbks[name] = window.cbks[name] || [];
        window.cbks[name].forEach(function(callback) {
            return callback(arg);
        });
    }

    return ({
        register: register,
        call: call
    });
})();
