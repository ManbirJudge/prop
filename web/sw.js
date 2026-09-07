const CACHE_NAME = 'prop-v1';

const ASSETS_TO_CACHE = [
    './',
    './index.html',
    './main.js',
    './icon.png'
];

self.addEventListener('install', evt => {
    evt.waitUntil(
        caches.open(CACHE_NAME).then(cache => {
            return cache.addAll(ASSETS_TO_CACHE);
        })
    );
    self.skipWaitiing();
});

self.addEventListener('activate', evt => {
    evt.waitUntil(
        caches.keys().then(keys => {
            return Promise.all(
                keys.map(k => {
                    if (k !== CACHE_NAME)
                        return caches.delete(key);
                })
            );
        })
    );
    self.clients.claim();
});

self.addEventListener('fetch', evt => {
    evt.respondWith(
        caches.match(evt.request).then(cachedResp => {
            if (cachedResp) return cachedResp;
            return fetch(evt.request);
        })
    );
});