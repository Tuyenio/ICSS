// sw.js — phiên bản an toàn không gây lỗi CSS

// Chỉ dùng cho PUSH, không intercept fetch request
self.addEventListener('install', event => {
  self.skipWaiting();
});

self.addEventListener('activate', event => {
  clients.claim();
});

// *** KHÔNG ĐƯỢC CÓ fetch handler ***
// (Chrome sẽ coi SW là router → gây lỗi CSS)

// Nhận Push
self.addEventListener('push', event => {
  let data = {};
  try { data = event.data.json(); } catch(e) {}

  const title = data.title || "Thông báo";
  const options = {
    body: data.body || "",
    icon: "/Img/logoics.png",
    badge: "/Img/logoics.png",
    data: data.url || null
  };

  event.waitUntil(
    self.registration.showNotification(title, options)
  );
});

// Click vào thông báo
self.addEventListener("notificationclick", (event) => {
  event.notification.close();
  const url = event.notification.data || "/";
  event.waitUntil(clients.openWindow(url));
});
