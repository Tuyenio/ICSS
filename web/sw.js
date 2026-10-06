// sw.js — push notification + trang báo mất mạng.
// Chỉ can thiệp request điều hướng trang (GET navigate); CSS/JS/ảnh/API đi thẳng mạng như cũ.

const OFFLINE_HTML = `<!DOCTYPE html>
<html lang="vi"><head><meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">
<meta name="theme-color" content="#667eea">
<title>Mất kết nối - ICSS</title>
<style>
  html,body{margin:0;height:100%;font-family:-apple-system,'Segoe UI',Roboto,sans-serif;
    background:linear-gradient(135deg,#667eea 0%,#764ba2 100%);color:#fff}
  .box{min-height:100%;display:flex;flex-direction:column;align-items:center;justify-content:center;
    text-align:center;padding:24px;box-sizing:border-box}
  .icon{font-size:56px;margin-bottom:12px}
  h1{font-size:1.4rem;margin:0 0 8px}
  p{opacity:.9;margin:0 0 24px;line-height:1.5}
  button{border:0;border-radius:12px;padding:12px 28px;font-size:16px;font-weight:600;
    color:#4f46e5;background:#fff;cursor:pointer}
</style></head>
<body><div class="box">
  <div class="icon">&#128246;</div>
  <h1>Không có kết nối mạng</h1>
  <p>Vui lòng kiểm tra Wi-Fi hoặc dữ liệu di động rồi thử lại.</p>
  <button onclick="location.reload()">Thử lại</button>
</div>
<script>window.addEventListener('online',function(){location.reload()});</script>
</body></html>`;

self.addEventListener('install', () => {
  self.skipWaiting();
});

self.addEventListener('activate', event => {
  event.waitUntil(self.clients.claim());
});

self.addEventListener('fetch', event => {
  const req = event.request;
  if (req.mode !== 'navigate' || req.method !== 'GET') return;
  event.respondWith(
    fetch(req).catch(() => new Response(OFFLINE_HTML, {
      headers: { 'Content-Type': 'text/html; charset=UTF-8' }
    }))
  );
});

self.addEventListener('push', event => {
  let data = {};
  try { data = event.data.json(); } catch (e) {}

  const title = data.title || "Thông báo";
  const options = {
    body: data.body || "",
    icon: "Img/logoics.png",
    badge: "icons/logo192.png",
    data: data.url || null
  };

  event.waitUntil(self.registration.showNotification(title, options));
});

self.addEventListener("notificationclick", event => {
  event.notification.close();
  const url = new URL(event.notification.data || "./", self.registration.scope).href;
  event.waitUntil(
    self.clients.matchAll({ type: "window", includeUncontrolled: true }).then(list => {
      for (const client of list) {
        if (client.url.startsWith(self.registration.scope) && "focus" in client) {
          client.navigate(url);
          return client.focus();
        }
      }
      return self.clients.openWindow(url);
    })
  );
});
