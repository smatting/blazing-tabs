"use strict";

exports.favIconUrl = just => nothing => tabSource => {
    if (tabSource.favIconUrl === undefined) {
        return nothing;
    } else {
        return just(tabSource.favIconUrl);
    }
}
