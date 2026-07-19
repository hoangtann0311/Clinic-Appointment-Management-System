<%@ page pageEncoding="UTF-8" %>
</main>

<footer class="cams-app-footer">
    <div class="container text-center">
        <p class="cams-app-footer-copyright">&copy; 2026 Hệ thống Quản lý Lịch hẹn CAMS. Bảo lưu mọi quyền.</p>
        <p class="cams-app-footer-tagline">Hành trình chăm sóc và đồng hành cùng mẹ &amp; bé</p>
    </div>
</footer>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"
        integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz"
        crossorigin="anonymous"></script>

<script>
function openSidebar() {
    var s = document.getElementById('adminSidebar');
    var b = document.getElementById('sidebarBackdrop');
    if (!s) return;
    s.classList.add('show');
    if (b) b.classList.add('show');
    document.body.style.overflow = 'hidden';
}
function closeSidebar() {
    var s = document.getElementById('adminSidebar');
    var b = document.getElementById('sidebarBackdrop');
    if (!s) return;
    s.classList.remove('show');
    if (b) b.classList.remove('show');
    document.body.style.overflow = '';
}
function toggleSidebar() {
    var s = document.getElementById('adminSidebar');
    if (!s) return;
    s.classList.contains('show') ? closeSidebar() : openSidebar();
}

(function() {
    var links = document.querySelectorAll('.admin-sidebar-menu li a');
    var path = window.location.pathname;
    for (var i = 0; i < links.length; i++) {
        var link = links[i];
        if (!link.href || link.href === window.location.origin + '/') continue;
        try {
            var linkPath = new URL(link.href).pathname;
            if (path === linkPath || (path.startsWith(linkPath) && linkPath !== '${pageContext.request.contextPath}/')) {
                link.classList.add('active');
            }
        } catch (e) {
            // Ignore an invalid navigation URL.
        }
    }
})();
</script>
</body>
</html>
