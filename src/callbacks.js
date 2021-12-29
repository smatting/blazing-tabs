"use strict";

/* Usage:
 *
 * callbacks.register('foo', function(arg) { .. });
 *
 * then
 *
 * callbacks.call('foo', arg)
 *
 * to call all registered callbacks (we only need 1) with arg.
 *
 * Dear reviewer:
 *
 * I use this hack to bridge the Purescript app with the browser extension.
 * Namely for this use case:
 *
 * 1. The purescript registers a callback 'notifyTabs' that receives tabs
 *    queried by chrome API. This callback contains the closure of the
 *    purescript app, which isn't easily accessible to JS land otherwise. See
 *    src/ExtInterface.js and src/ExtInterface.purs
 *
 * 2. The extension sends tabs. See sendTabs() in backgrounds.js and the and the
 *    onMessage listener in setup.js, which calls the callback defined in the
 *    Purescript app.
 *
 * This callbacks mechanism also lets you mock out the extension interface
 * completely, see `debug-ui/setup.js`
 *
 * */

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
