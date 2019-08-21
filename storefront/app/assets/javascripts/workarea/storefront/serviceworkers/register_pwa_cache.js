/*global navigator*/

if ('serviceWorker' in navigator) {
    navigator.serviceWorker.register('/pwa_cache.js', { scope: './' });
}
