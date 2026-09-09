/*
 * Popup thông báo neo tại chuông trên header (dùng chung cho header.jsp và user_header.jsp).
 * Bấm chuông = mở popup tại chỗ; chỉ nút "Xem tất cả" mới điều hướng sang ./apiThongbao.
 */
(function () {
    'use strict';

    const LIMIT = 8;
    const ALL_URL = './apiThongbao';

    let popupEl = null;
    let listEl = null;
    let bellEl = null;
    let wrapEl = null;
    let isOpen = false;
    let lastList = null;

    function injectStyle() {
        if (document.getElementById('icssNotiPopupStyle')) {
            return;
        }
        const style = document.createElement('style');
        style.id = 'icssNotiPopupStyle';
        style.textContent = `
            .noti-popup {
                position: absolute;
                top: calc(100% + 14px);
                right: 0;
                width: 380px;
                max-width: calc(100vw - 32px);
                background: #fff;
                border: 1px solid rgba(15, 23, 42, 0.08);
                border-radius: 16px;
                box-shadow: 0 20px 45px rgba(15, 23, 42, 0.18);
                z-index: 1100;
                overflow: hidden;
                cursor: default;
                opacity: 0;
                transform: translateY(-8px);
                transition: opacity 0.18s ease, transform 0.18s ease;
                pointer-events: none;
            }
            .noti-popup.is-open {
                opacity: 1;
                transform: translateY(0);
                pointer-events: auto;
            }
            .noti-popup::before {
                content: '';
                position: absolute;
                top: -7px;
                right: 18px;
                width: 14px;
                height: 14px;
                background: #fff;
                border-left: 1px solid rgba(15, 23, 42, 0.08);
                border-top: 1px solid rgba(15, 23, 42, 0.08);
                transform: rotate(45deg);
            }
            .noti-popup-header {
                display: flex;
                align-items: center;
                justify-content: space-between;
                gap: 10px;
                padding: 14px 18px;
                border-bottom: 1px solid #eef2f7;
                background: linear-gradient(135deg, rgba(102, 126, 234, 0.10), rgba(118, 75, 162, 0.10));
            }
            .noti-popup-title {
                font-weight: 700;
                color: #1e293b;
                font-size: 0.98rem;
            }
            .noti-popup-count {
                font-size: 0.72rem;
                font-weight: 600;
                color: #fff;
                background: linear-gradient(45deg, #ff6b6b, #ee5a24);
                border-radius: 999px;
                padding: 3px 9px;
            }
            .noti-popup-body {
                max-height: 380px;
                overflow-y: auto;
            }
            .noti-popup-item {
                display: flex;
                gap: 12px;
                align-items: flex-start;
                padding: 12px 18px;
                border-bottom: 1px solid #f1f5f9;
                cursor: pointer;
                transition: background 0.18s ease;
            }
            .noti-popup-item:last-child {
                border-bottom: none;
            }
            .noti-popup-item:hover {
                background: #f8fafc;
            }
            .noti-popup-item.is-unread {
                background: rgba(102, 126, 234, 0.06);
            }
            .noti-popup-item.is-unread:hover {
                background: rgba(102, 126, 234, 0.12);
            }
            .noti-popup-dot {
                width: 9px;
                height: 9px;
                border-radius: 50%;
                margin-top: 6px;
                flex-shrink: 0;
                background: #cbd5e1;
            }
            .noti-popup-item.is-unread .noti-popup-dot {
                background: linear-gradient(45deg, #ff6b6b, #ee5a24);
            }
            .noti-popup-item-title {
                font-weight: 600;
                color: #1e293b;
                font-size: 0.9rem;
                margin-bottom: 2px;
            }
            .noti-popup-item-body {
                color: #64748b;
                font-size: 0.82rem;
                display: -webkit-box;
                -webkit-line-clamp: 2;
                -webkit-box-orient: vertical;
                overflow: hidden;
            }
            .noti-popup-item-time {
                color: #94a3b8;
                font-size: 0.74rem;
                margin-top: 4px;
            }
            .noti-popup-empty {
                padding: 34px 18px;
                text-align: center;
                color: #94a3b8;
                font-size: 0.88rem;
            }
            .noti-popup-empty i {
                display: block;
                font-size: 1.8rem;
                margin-bottom: 8px;
                color: #cbd5e1;
            }
            .noti-popup-footer {
                padding: 10px 14px;
                border-top: 1px solid #eef2f7;
                background: #f8fafc;
            }
            .noti-popup-all {
                display: block;
                width: 100%;
                text-align: center;
                padding: 9px 12px;
                border: none;
                border-radius: 10px;
                font-weight: 600;
                font-size: 0.88rem;
                color: #fff;
                background: linear-gradient(135deg, #667eea, #764ba2);
                cursor: pointer;
                transition: filter 0.2s ease, transform 0.2s ease;
            }
            .noti-popup-all:hover {
                filter: brightness(1.08);
                transform: translateY(-1px);
            }
            @media (max-width: 576px) {
                .noti-popup { width: 300px; }
            }
        `;
        document.head.appendChild(style);
    }

    function escapeHtml(s) {
        if (s === null || s === undefined) {
            return '';
        }
        return String(s).replace(/[&<>"']/g, function (m) {
            return ({'&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;'})[m];
        });
    }

    // Body có thể chứa thẻ HTML từ nơi tạo thông báo -> bỏ thẻ rồi mới escape
    function stripTags(s) {
        return String(s || '').replace(/<\/?[^>]+(>|$)/g, ' ').replace(/\s+/g, ' ').trim();
    }

    function buildPopup() {
        popupEl = document.createElement('div');
        popupEl.className = 'noti-popup';
        popupEl.id = 'notiPopup';
        popupEl.innerHTML = ''
                + '<div class="noti-popup-header">'
                + '  <span class="noti-popup-title"><i class="fa-solid fa-bell me-2" style="color:#667eea"></i>Thông báo</span>'
                + '  <span class="noti-popup-count" id="notiPopupCount" style="display:none">0</span>'
                + '</div>'
                + '<div class="noti-popup-body" id="notiPopupList"></div>'
                + '<div class="noti-popup-footer">'
                + '  <button type="button" class="noti-popup-all" id="notiPopupAll">Xem tất cả</button>'
                + '</div>';

        // Click bên trong popup không được làm đóng popup (handler ở bell/document)
        popupEl.addEventListener('click', function (e) {
            e.stopPropagation();
        });

        wrapEl.appendChild(popupEl);
        listEl = popupEl.querySelector('#notiPopupList');

        popupEl.querySelector('#notiPopupAll').addEventListener('click', function () {
            window.location.href = ALL_URL;
        });

        renderLoading();
    }

    function renderLoading() {
        listEl.innerHTML = '<div class="noti-popup-empty">'
                + '<i class="fa-solid fa-spinner fa-spin"></i>Đang tải thông báo...</div>';
    }

    function renderEmpty() {
        listEl.innerHTML = '<div class="noti-popup-empty">'
                + '<i class="fa-regular fa-bell-slash"></i>Chưa có thông báo nào</div>';
    }

    function render(list) {
        if (!listEl) {
            return;
        }
        lastList = list;

        if (!Array.isArray(list) || list.length === 0) {
            renderEmpty();
            updatePopupCount(0);
            return;
        }

        let unread = 0;
        const html = list.slice(0, LIMIT).map(function (item) {
            const isUnread = !item.is_read;
            if (isUnread) {
                unread++;
            }
            const body = stripTags(item.body);
            return '<div class="noti-popup-item ' + (isUnread ? 'is-unread' : '') + '" data-id="' + escapeHtml(item.id) + '">'
                    + '<span class="noti-popup-dot"></span>'
                    + '<div class="flex-grow-1">'
                    + '<div class="noti-popup-item-title">' + escapeHtml(item.title || 'Thông báo') + '</div>'
                    + (body ? '<div class="noti-popup-item-body">' + escapeHtml(body) + '</div>' : '')
                    + (item.created_at ? '<div class="noti-popup-item-time"><i class="fa-regular fa-clock me-1"></i>' + escapeHtml(item.created_at) + '</div>' : '')
                    + '</div>'
                    + '</div>';
        }).join('');

        listEl.innerHTML = html;
        updatePopupCount(unread);

        listEl.querySelectorAll('.noti-popup-item').forEach(function (el) {
            el.addEventListener('click', function () {
                markRead(el);
            });
        });
    }

    function updatePopupCount(unread) {
        const el = popupEl && popupEl.querySelector('#notiPopupCount');
        if (!el) {
            return;
        }
        el.textContent = unread + ' mới';
        el.style.display = unread > 0 ? 'inline-block' : 'none';
    }

    // Bấm 1 thông báo = đánh dấu đã đọc tại chỗ, không rời trang
    function markRead(itemEl) {
        if (!itemEl.classList.contains('is-unread')) {
            return;
        }
        const id = itemEl.getAttribute('data-id');
        itemEl.classList.remove('is-unread');

        fetch('./ApiThongbaoMarkRead', {
            method: 'POST',
            headers: {'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'},
            body: 'id=' + encodeURIComponent(id)
        }).then(function () {
            if (lastList) {
                lastList.forEach(function (n) {
                    if (String(n.id) === String(id)) {
                        n.is_read = true;
                    }
                });
                updatePopupCount(lastList.filter(function (n) {
                    return !n.is_read;
                }).length);
            }
            refreshBadge();
        }).catch(function () {
            itemEl.classList.add('is-unread'); // thất bại thì trả lại trạng thái cũ
        });
    }

    function refreshBadge() {
        fetch('./ApiThongbaoUnreadCount?_=' + Date.now(), {cache: 'no-store'})
                .then(function (res) {
                    return res.ok ? res.text() : null;
                })
                .then(function (txt) {
                    if (txt === null) {
                        return;
                    }
                    const n = parseInt(String(txt).trim(), 10);
                    const badge = document.getElementById('notiCount');
                    if (badge && !Number.isNaN(n)) {
                        badge.textContent = n;
                        badge.style.display = n > 0 ? 'inline-block' : 'none';
                    }
                })
                .catch(function () {});
    }

    function load() {
        renderLoading();
        fetch('./ApiThongbaoLatest?limit=' + LIMIT + '&_=' + Date.now(), {cache: 'no-store'})
                .then(function (res) {
                    if (!res.ok) {
                        throw new Error('HTTP ' + res.status);
                    }
                    return res.json();
                })
                .then(render)
                .catch(function () {
                    listEl.innerHTML = '<div class="noti-popup-empty">'
                            + '<i class="fa-solid fa-triangle-exclamation"></i>Không tải được thông báo</div>';
                });
    }

    function open() {
        if (isOpen) {
            return;
        }
        isOpen = true;
        popupEl.classList.add('is-open');
        load();
    }

    function close() {
        if (!isOpen) {
            return;
        }
        isOpen = false;
        popupEl.classList.remove('is-open');
    }

    function toggle() {
        if (isOpen) {
            close();
        } else {
            open();
        }
    }

    function init(bellId) {
        bellEl = document.getElementById(bellId);
        if (!bellEl || popupEl) {
            return;
        }
        injectStyle();

        // Nút chuông có hiệu ứng hover transform: scale() - nếu popup là con của nút thì
        // nó cũng bị scale theo. Bọc nút trong 1 wrapper tĩnh và neo popup vào wrapper.
        wrapEl = document.createElement('div');
        wrapEl.className = 'noti-bell-wrap';
        wrapEl.style.position = 'relative';
        wrapEl.style.display = 'inline-flex';
        bellEl.parentNode.insertBefore(wrapEl, bellEl);
        wrapEl.appendChild(bellEl);

        buildPopup();

        bellEl.addEventListener('click', function (e) {
            e.preventDefault();
            e.stopPropagation();
            toggle();
        });

        document.addEventListener('click', function () {
            close();
        });

        document.addEventListener('keydown', function (e) {
            if (e.key === 'Escape') {
                close();
            }
        });
    }

    window.icssNotiPopup = {
        init: init,
        open: open,
        close: close,
        toggle: toggle,
        // header.js gọi khi poll thấy dữ liệu mới, để popup đang mở không bị cũ
        render: function (list) {
            if (isOpen) {
                render(list);
            }
        },
        isOpen: function () {
            return isOpen;
        }
    };

    // Tự khởi tạo với id chuông của trang admin hoặc trang nhân viên
    document.addEventListener('DOMContentLoaded', function () {
        if (document.getElementById('adminNotificationBell')) {
            init('adminNotificationBell');
        } else if (document.getElementById('notificationBell')) {
            init('notificationBell');
        }
    });
})();
