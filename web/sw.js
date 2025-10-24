// sw.js – dùng online, không cache
self.addEventListener('install', event => {
  console.log('Service Worker: installed');
  self.skipWaiting();
});

self.addEventListener('activate', event => {
  console.log('Service Worker: activated');
});

self.addEventListener('fetch', event => {
  // chỉ log thôi, không chặn fetch (bắt buộc có event listener này)
  console.log('Service Worker: fetch', event.request.url);
});
