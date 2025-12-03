(function () {
    // Support both header dropdown (#notificationList) and admin page list (#adminNotificationList)
    var list = document.getElementById('notificationList') || document.getElementById('adminNotificationList');
    if (!list) {
        console.warn('notification.js: neither #notificationList nor #adminNotificationList found');
        return;
    }

    // --- CHANGED: return Promise so callers can await result ---
    function markReadRequest(id, li) {
        return new Promise(function (resolve, reject) {
            if (!id) {
                console.warn('markReadRequest called without id', li);
                return resolve(false);
            }
            var ctx = (window.APP_CONTEXT || '').trim();
            var url = (ctx ? ctx : '') + '/ApiThongbaoMarkRead'; // fallback to absolute app-root
            console.debug('markReadRequest ->', {id: id, url: url});

            var xhr = new XMLHttpRequest();
            xhr.open('POST', url, true);
            xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded; charset=UTF-8');

            xhr.onreadystatechange = function () {
                if (xhr.readyState !== 4) return;
                console.debug('MarkRead response', xhr.status, xhr.responseText && xhr.responseText.slice(0,200));
                var body = (xhr.responseText || '').trim();
                if (xhr.status >= 200 && xhr.status < 300 && body === 'OK') {
                    if (li) {
                        li.classList.remove('is-unread');
                        li.classList.add('is-read');
                        var badge = li.querySelector('.badge-status');
                        if (badge) {
                            badge.classList.remove('bg-danger');
                            badge.classList.add('bg-success');
                            badge.textContent = 'Đã đọc';
                        }
                        var dot = li.querySelector('.notif-dot');
                        if (dot) dot.style.display = 'none';
                    }
                    if (window.updateNotifyBadgeCount) window.updateNotifyBadgeCount();
                    return resolve(true);
                }
                console.error('MarkRead failed', {status: xhr.status, body: body});
                return resolve(false);
            };

            xhr.onerror = function (e) {
                console.error('XHR network error', e);
                return resolve(false);
            };

            xhr.send('id=' + encodeURIComponent(id));
        });
    }

    // --- NEW: mark all unread in the admin list ---
    async function markAllUnread() {
        var adminList = document.getElementById('adminNotificationList');
        if (!adminList) {
            console.warn('markAllUnread: admin list not found');
            return;
        }
        var unreadItems = Array.from(adminList.querySelectorAll('li.list-group-item.is-unread'));
        if (unreadItems.length === 0) {
            console.debug('markAllUnread: no unread items');
            return;
        }

        var btn = document.getElementById('markAllBtn');
        if (btn) {
            btn.disabled = true;
            var orig = btn.innerHTML;
            btn.innerHTML = '<span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span> Đang xử lý';
        }

        // send requests in parallel
        var promises = unreadItems.map(function (li) {
            var id = li.getAttribute('data-id');
            return markReadRequest(id, li);
        });

        var results = await Promise.allSettled(promises);
        console.debug('markAllUnread results', results);

        if (btn) {
            btn.disabled = false;
            btn.innerHTML = orig;
        }

        // final badge update
        if (window.updateNotifyBadgeCount) window.updateNotifyBadgeCount();
    }

    // Attach handler to button if present
    document.addEventListener('DOMContentLoaded', function () {
        var markAllBtn = document.getElementById('markAllBtn');
        if (markAllBtn) {
            markAllBtn.addEventListener('click', function (e) {
                e.preventDefault();
                markAllUnread();
            });
        }
    });

    list.addEventListener('click', function (e) {
        var target = e.target;
        var li = target.closest('li.list-group-item');
        if (!li) return;

        // clicking badge explicitly
        if (target.classList && target.classList.contains('badge-status')) {
            if (li.classList.contains('is-unread')) {
                var idB = li.getAttribute('data-id');
                markReadRequest(idB, li);
            } else {
                console.debug('badge clicked but already read');
            }
            return;
        }

        // clicking the list item
        if (li.classList.contains('is-unread')) {
            var id = li.getAttribute('data-id');
            markReadRequest(id, li);
        }
    });

    // --- new: register SW and subscribe to push ---
    async function initPush() {
        if (!('serviceWorker' in navigator) || !('PushManager' in window)) {
            console.warn('Push not supported');
            return;
        }
        try {
            const reg = await navigator.serviceWorker.register(window.APP_CONTEXT + '/sw.js');
            console.debug('SW registered', reg);

            const perm = await Notification.requestPermission();
            if (perm !== 'granted') return console.debug('Notification permission not granted');

            // VAPID public key from server (Base64URL) - fetch from your server endpoint
            const resp = await fetch(window.APP_CONTEXT + '/ApiPushGetVapid'); // should return {publicKey: '...'}
            const json = await resp.json();
            const vapidPublicKey = json.publicKey;

            function urlBase64ToUint8Array(base64String) {
                const padding = '='.repeat((4 - base64String.length % 4) % 4);
                const base64 = (base64String + padding).replace(/\-/g, '+').replace(/_/g, '/');
                const rawData = atob(base64);
                const outputArray = new Uint8Array(rawData.length);
                for (let i = 0; i < rawData.length; ++i) outputArray[i] = rawData.charCodeAt(i);
                return outputArray;
            }

            const sub = await reg.pushManager.subscribe({
                userVisibleOnly: true,
                applicationServerKey: urlBase64ToUint8Array(vapidPublicKey)
            });

            // send subscription to server to save (associate with logged-in user)
            await fetch(window.APP_CONTEXT + '/ApiPushSaveSubscription', {
                method: 'POST',
                headers: {'Content-Type': 'application/json'},
                body: JSON.stringify(sub)
            });
            console.debug('Push subscribed and sent to server');
        } catch (err) {
            console.error('Push init error', err);
        }
    }

    // call once on page load (or on user opt-in button)
    initPush();
})();