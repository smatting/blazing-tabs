"use strict";

exports.registerCallback = function(fn) {
    return function() {
        console.log('registerCallback', fn);
        callbacks.register("notifyTabs", function(arg) {
            /* why additional()? https://book.purescript.org/chapter10.html#effectful-functions */
            fn(arg)();
        });
    };
};
