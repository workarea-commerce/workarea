/**
 * Add data-insert to an element. When that element is also data-remote, the
 * server's response will be appended into the element matching the value of
 * the data-insert attribute. (with WORKAREA modules initialized). If that
 * element is also insert-before or insert-after, the response will instead
 * be inserted before or after, respectively, the matching element.
 */

$(document).on('ajax:success', function (event, response) {
    var $element = $(event.target),
        targetSelector = $element.data('insert'),
        $target,
        $content;

    if (! $element.is('[data-insert]')) { return; }
    if (_.isEmpty(targetSelector)) { return; }

    $target = $(targetSelector);
    $content = $(response);

    if ($element.is('[data-insert-after]')) {
        $content.insertAfter($target);
    } else if ($element.is('[data-insert-before]')) {
        $content.insertBefore($target);
    } else {
        $target.append($content);
    }

    WORKAREA.initModules($content);
});
