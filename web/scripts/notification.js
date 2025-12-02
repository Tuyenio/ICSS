(function () {
    var list = document.getElementById('notificationList');
    if (!list) {
        console.warn('notification.js: #notificationList not found');
        return;
    }

    function markReadRequest(id, li) {
        if (!id) {
            console.warn('markReadRequest called without id', li);
            return;
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
            // Detect server redirect to login (HTML) — treat as error
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
                }
                if (window.updateNotifyBadgeCount) window.updateNotifyBadgeCount();
                return;
            }
            // Fallback: sometimes server returns JSON or HTML (redirect). Log and show console error.
            console.error('MarkRead failed', {status: xhr.status, body: body});
        };

        xhr.onerror = function (e) {
            console.error('XHR network error', e);
        };

        xhr.send('id=' + encodeURIComponent(id));
    }

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
})();