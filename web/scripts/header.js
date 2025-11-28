// PREMIUM HEADER ANIMATIONS
document.addEventListener('DOMContentLoaded', function() {
// Pulse animation for notification badge
const style = document.createElement('style');
        style.textContent = `
            @keyframes pulse {
                0% { transform: scale(1); box-shadow: 0 0 0 0 rgba(255, 107, 107, 0.7); }
                70% { transform: scale(1.05); box-shadow: 0 0 0 10px rgba(255, 107, 107, 0); }
                100% { transform: scale(1); box-shadow: 0 0 0 0 rgba(255, 107, 107, 0); }
            }
            
            /* Responsive header */
            @media (max-width: 1200px) {
                .header { margin-left: 240px !important; }
            }
            
            @media (max-width: 992px) {
                .header { 
                    margin-left: 76px !important; 
                    transition: margin-left 0.3s ease;
                }
                .header:hover { margin-left: 260px !important; }
            }
            
            @media (max-width: 576px) {
                .header { 
                    margin-left: 60px !important; 
                    padding: 0 16px !important;
                }
                .header:hover { margin-left: 240px !important; }
                
                .header #pageTitle {
                    font-size: 1.2rem !important;
                }
                
                .header .dropdown a span {
                    display: none;
                }
                
                .header .dropdown a img {
                    width: 36px !important;
                    height: 36px !important;
                }
            }
        `;
        document.head.appendChild(style);
        });
        // Đặt tiêu đề động cho từng trang
        if (typeof PAGE_TITLE !== 'undefined') {
var pageTitleEl = document.getElementById('pageTitle');
        if (pageTitleEl)
        pageTitleEl.innerHTML = PAGE_TITLE;
        }

// Nhảy sang trang thông báo khi bấm chuông
(function () {
var bell = document.getElementById('adminNotificationBell');
        if (bell) {
bell.onclick = function () {
window.location.href = './apiThongbao';
        };
        }
})();

        (function () {
        const POLL_INTERVAL = 7000; // ms, adjust
                const LIMIT = 8;
                let seenIds = new Set();
                let pollTimer = null;
                let lastPayloadHash = '';
                // Request permission once (call from page load or explicit button)
                        function ensurePermission() {
                        if (!("Notification" in window)) return Promise.resolve('unsupported');
                                if (Notification.permission === 'default') {
                        return Notification.requestPermission();
                        }
                        return Promise.resolve(Notification.permission);
                        }

                // Show desktop notification
                function showDesktopNotification(n) {
                try {
                if (!("Notification" in window)) return;
                        if (Notification.permission !== 'granted') return;
                        const title = n.title || 'Thông báo';
                        const body = (n.body || '').replace(/<\/?[^>]+(>|$)/g, '');
                        const opt = {
                        body: body,
                                tag: 'icss-noti-' + n.id,
                                renotify: false,
                                data: { id: n.id },
                                icon: window.contextPath + '/Img/logoics.png'
                        };
                        const notif = new Notification(title, opt);
                        notif.onclick = function (ev) {
                        window.focus && window.focus();
                                // mở trang thông báo
                                window.location.href = window.contextPath + '/apiThongbao';
                                try { notif.close(); } catch (e) {}
                        };
                } catch (e) {
                console.warn('Notif error', e);
                }
                }

                // Update badge DOM (re-use existing function if present)
                function updateBadge(count) {
                var badge = document.getElementById('notiCount');
                        if (!badge) return;
                        badge.textContent = count;
                        badge.style.display = (count > 0) ? 'inline-block' : 'none';
                }

                // Optionally update notification list dropdown: implement if your dropdown has #notificationList
                function updateDropdown(list) {
                try {
                const ul = document.getElementById('notificationList');
                        if (!ul) return;
                        ul.innerHTML = '';
                        list.forEach(item => {
                        const li = document.createElement('li');
                                li.className = 'list-group-item ' + (item.is_read ? 'is-read' : 'is-unread');
                                li.setAttribute('data-id', item.id);
                                li.innerHTML = '<div class="d-flex justify-content-between"><div><b>' + escapeHtml(item.title) + '</b><div class="small text-muted">' + escapeHtml(item.body) + '</div></div><small class="text-muted">' + (item.created_at || '') + '</small></div>';
                                ul.appendChild(li);
                        });
                } catch (e) { console.warn(e); }
                }

                function escapeHtml(s) {
                if (!s) return '';
                        return String(s).replace(/[&<>"']/g, function (m) {
                return ({'&':'&amp;', '<':'&lt;', '>':'&gt;', '"':'&quot;', "'":"&#39;"})[m];
                });
                }

                async function pollOnce() {
                try {
                const url = window.contextPath + '/ApiThongbaoLatest?limit=' + LIMIT + '&_=' + Date.now();
                        const res = await fetch(url, {cache: 'no-store'});
                        if (!res.ok) return;
                        const list = await res.json();
                        // compute simple hash to avoid duplicate UI updates
                        const payloadHash = JSON.stringify(list.map(x => x.id));
                        if (payloadHash === lastPayloadHash) return;
                        lastPayloadHash = payloadHash;
                        // badge count = number of unread (is_read === false)
                        const unread = list.filter(it => !it.is_read);
                        updateBadge(unread.length);
                        // detect new ids (not seen before)
                        const newItems = [];
                        list.forEach(it => {
                        if (!seenIds.has(String(it.id))) {
                        newItems.push(it);
                        }
                        });
                        // remember currently seen (keep only last LIMIT ids)
                        seenIds.clear();
                        list.slice(0, LIMIT).forEach(it => seenIds.add(String(it.id)));
                        // update dropdown list if exist
                        updateDropdown(list);
                        // show desktop notifications for new unread items (server may return read/unread)
                        if (newItems.length > 0) {
                await ensurePermission();
                        newItems.forEach(it => {
                        if (!it.is_read) showDesktopNotification(it);
                        });
                }
                } catch (e) {
                // ignore
                console.warn('poll error', e);
                }
                }

                function startPolling() {
                if (pollTimer) return;
                        pollOnce();
                        pollTimer = setInterval(() => {
                        // pause when page hidden
                        if (document.hidden) return;
                                pollOnce();
                        }, POLL_INTERVAL);
                }

                function stopPolling() {
                if (pollTimer) { clearInterval(pollTimer); pollTimer = null; }
                }

                // Pause polling when tab hidden to save resources
                document.addEventListener('visibilitychange', function () {
                if (document.hidden) stopPolling(); else startPolling();
                });
                        // expose for manual control
                        window.icssNotifications = {
                        start: startPolling,
                                stop: stopPolling,
                                requestPermission: ensurePermission
                        };
                        // auto start on load
                        if (document.readyState === 'loading') {
                document.addEventListener('DOMContentLoaded', startPolling);
                } else {
                startPolling();
                }

                })();