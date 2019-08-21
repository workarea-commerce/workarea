document.addEventListener('turbolinks:load', function(event) {
    if (typeof window.ga === 'function') {
        window.ga('set', 'location', event.data.url);
        window.ga('send', 'pageview');
    }
});
