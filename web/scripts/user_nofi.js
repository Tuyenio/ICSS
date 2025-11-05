(function () {
    var list = document.getElementById('notificationList');
    if (!list)
        return;

    list.addEventListener('click', function (e) {
        var li = e.target.closest('li.list-group-item');
        if (!li)
            return;

        if (li.classList.contains('is-unread')) {
            var id = li.getAttribute('data-id');
            if (!id)
                return;

            var xhr = new XMLHttpRequest();
            xhr.open('POST', '<%= request.getContextPath() %>/ApiThongbaoMarkRead', true);
            xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded; charset=UTF-8');

            xhr.onreadystatechange = function () {
                if (xhr.readyState === 4) {
                    console.log('MarkRead status=', xhr.status, 'resp=', (xhr.responseText || '').slice(0, 120));
                    if (xhr.status >= 200 && xhr.status < 300) {
                        var body = (xhr.responseText || '').trim();
                        if (body === 'OK') {
                            li.classList.remove('is-unread');
                            li.classList.add('is-read');
                            var badge = li.querySelector('.badge-status');
                            if (badge) {
                                badge.classList.remove('bg-danger');
                                badge.classList.add('bg-success');
                                badge.textContent = 'Đã đọc';
                            }
                            if (window.updateNotifyBadgeCount)
                                window.updateNotifyBadgeCount();
                        } else {
                            // Nếu body KHÔNG phải 'OK', khả năng bị redirect sang trang đăng nhập (HTML)
                            console.warn('MarkRead returned non-OK body.');
                        }
                    } else {
                        console.error('MarkRead HTTP error:', xhr.status);
                    }
                }
            };

            xhr.send('id=' + encodeURIComponent(id));
        }
    });
})();