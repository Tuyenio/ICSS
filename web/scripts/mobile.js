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

    function setupTables() {
        var root = document.querySelector('.main-content') || document.body;
        root.querySelectorAll('table').forEach(wrapTable);

        if (!('MutationObserver' in window)) return;
        new MutationObserver(function (mutations) {
            mutations.forEach(function (m) {
                m.addedNodes.forEach(function (node) {
                    if (node.nodeType !== 1) return;
                    if (node.tagName === 'TABLE') wrapTable(node);
                    else if (node.querySelectorAll) node.querySelectorAll('table').forEach(wrapTable);
                });
            });
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
