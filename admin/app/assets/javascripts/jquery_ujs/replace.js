/**
 * Add data-replace to an element. When that element is also data-remote, the
 * element will be replaced by the server's response (with WORKAREA modules
 * initialized).
 */

$(document).on('ajax:success', function (event, response) {
    var $target = $(event.target);

    if ($target.is('[data-replace]')) {
        var $replacement = $(response);
        WORKAREA.initModules($replacement);
        $target.replaceWith($replacement);
    }
});
