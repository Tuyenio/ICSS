(function () {
    var MOBILE_MAX = 768;

    function isMobile() {
        return window.innerWidth <= MOBILE_MAX;
    }

    function setupNavDrawer() {
        var sidebar = document.querySelector('.sidebar');
        if (!sidebar) return;

        var backdrop = document.createElement('div');
        backdrop.className = 'mobile-nav-backdrop';
        document.body.appendChild(backdrop);

        var toggle = document.createElement('button');
        toggle.type = 'button';
        toggle.className = 'mobile-nav-toggle';
        toggle.setAttribute('aria-label', 'Mở menu');
        toggle.setAttribute('aria-expanded', 'false');
        toggle.innerHTML = '<i class="fa-solid fa-bars"></i>';

        var headerLeft = document.querySelector('.header > :first-child');
        if (headerLeft) {
            headerLeft.insertBefore(toggle, headerLeft.firstChild);
        } else {
            toggle.classList.add('floating');
            document.body.appendChild(toggle);
        }

        function open() {
            sidebar.classList.add('mobile-open');
            backdrop.classList.add('show');
            document.body.classList.add('mobile-nav-locked');
            toggle.setAttribute('aria-expanded', 'true');
        }

        function close() {
            sidebar.classList.remove('mobile-open');
            backdrop.classList.remove('show');
            document.body.classList.remove('mobile-nav-locked');
            toggle.setAttribute('aria-expanded', 'false');
        }

        toggle.addEventListener('click', function (e) {
            e.stopPropagation();
            sidebar.classList.contains('mobile-open') ? close() : open();
        });
        backdrop.addEventListener('click', close);

        sidebar.addEventListener('click', function (e) {
            var link = e.target.closest('a');
            if (link && !link.classList.contains('submenu-toggle') && isMobile()) close();
        });

        document.addEventListener('keydown', function (e) {
            if (e.key === 'Escape') close();
        });

        window.addEventListener('resize', function () {
            if (!isMobile()) close();
        });

        // Vuốt sang trái trên ngăn kéo để đóng
        var startX = null;
        sidebar.addEventListener('touchstart', function (e) {
            startX = e.touches[0].clientX;
        }, { passive: true });
        sidebar.addEventListener('touchend', function (e) {
            if (startX !== null && startX - e.changedTouches[0].clientX > 60) close();
            startX = null;
        }, { passive: true });
    }

    function wrapTable(table) {
        if (!table.parentNode || table.closest('.table-responsive, .mobile-table-wrap')) return;
        var wrap = document.createElement('div');
        wrap.className = 'mobile-table-wrap';
        table.parentNode.insertBefore(wrap, table);
        wrap.appendChild(table);
    }

    // Bảng có data-mobile-cards: trên mobile mỗi dòng thành 1 thẻ, mỗi ô hiển thị "Nhãn: giá trị".
    // data-mobile-title="2": cột làm tiêu đề thẻ; data-mobile-hide="1,2": cột ẩn trên mobile (đánh số từ 1).
    function labelCardTable(table) {
        var labels = Array.prototype.map.call(table.querySelectorAll('thead th'), function (th) {
            return th.textContent.replace(/\s+/g, ' ').trim();
        });
        var titleCol = parseInt(table.getAttribute('data-mobile-title'), 10) || 0;
        var hide = (table.getAttribute('data-mobile-hide') || '').split(',').map(function (s) {
            return parseInt(s, 10);
        });
        table.querySelectorAll('tbody > tr').forEach(function (tr) {
            var col = 0;
            Array.prototype.forEach.call(tr.children, function (td) {
                col += 1;
                if (td.hasAttribute('colspan') && parseInt(td.getAttribute('colspan'), 10) > 1) {
                    td.classList.add('mc-full');
                    return;
                }
                td.setAttribute('data-label', labels[col - 1] || '');
                td.classList.toggle('mc-title', col === titleCol);
                td.classList.toggle('mc-hide', hide.indexOf(col) !== -1);
            });
        });
    }

    function setupTables() {
        var root = document.querySelector('.main-content') || document.body;
        root.querySelectorAll('table').forEach(wrapTable);
        root.querySelectorAll('table[data-mobile-cards]').forEach(labelCardTable);

        if (!('MutationObserver' in window)) return;
        new MutationObserver(function (mutations) {
            var cardTables = [];
            mutations.forEach(function (m) {
                var t = m.target.closest && m.target.closest('table[data-mobile-cards]');
                if (t && cardTables.indexOf(t) === -1) cardTables.push(t);
                m.addedNodes.forEach(function (node) {
                    if (node.nodeType !== 1) return;
                    if (node.tagName === 'TABLE') wrapTable(node);
                    else if (node.querySelectorAll) node.querySelectorAll('table').forEach(wrapTable);
                });
            });
            cardTables.forEach(labelCardTable);
        }).observe(root, { childList: true, subtree: true });
    }

    function registerServiceWorker() {
        if (!('serviceWorker' in navigator)) return;
        window.addEventListener('load', function () {
            navigator.serviceWorker.register('sw.js').catch(function (err) {
                console.warn('Service Worker registration failed:', err);
            });
        });
    }

    function init() {
        setupNavDrawer();
        setupTables();
    }

    registerServiceWorker();
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', init);
    } else {
        init();
    }
})();
