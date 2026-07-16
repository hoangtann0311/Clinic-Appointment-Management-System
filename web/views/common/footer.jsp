<%@ page pageEncoding="UTF-8" %>
<c:choose>
    <c:when test="${not empty sessionScope.user && (sessionScope.user.roleId == 2 || sessionScope.user.roleId == 6)}">
        </main> <!-- Close admin-main -->
        
        <!-- Bootstrap 5 JS Bundle CDN -->
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"
                integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz"
                crossorigin="anonymous">
        </script>
        
        <!-- Sidebar Toggle Script -->
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
        
        // Active link highlight
        (function() {
            var links = document.querySelectorAll('.admin-sidebar-menu li a');
            var path = window.location.pathname;
            for (var i = 0; i < links.length; i++) {
                var link = links[i];
                if (link.href && link.href !== window.location.origin + '/') {
                    try {
                        var linkPath = new URL(link.href).pathname;
                        if (path === linkPath || (path.startsWith(linkPath) && linkPath !== '${pageContext.request.contextPath}/')) {
                            link.classList.add('active');
                        }
                    } catch(e) {}
                }
            }
        })();
        </script>
        </body>
        </html>
    </c:when>
    <c:when test="${not empty sessionScope.user && sessionScope.user.roleId == 5}">
        </main> <!-- Close patient-main-container -->

        <!-- Client Portal Footer -->
        <footer class="patient-footer py-4 mt-auto">
            <div class="container text-center">
                <p class="mb-1 text-muted small">&copy; 2026 Hệ thống Quản lý Lịch hẹn CAMS. Bảo lưu mọi quyền.</p>
                <small class="text-pink-light">Hành trình chăm sóc và đồng hành cùng mẹ & bé</small>
            </div>
        </footer>

        <!-- Bootstrap 5 JS Bundle -->
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"
                integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz"
                crossorigin="anonymous"></script>
        </body>
        </html>
    </c:when>
    <c:otherwise>
        </main>
        <!-- End Main Content -->

        <!-- Footer -->
        <footer class="bg-white border-top mt-auto py-3">
            <div class="container text-center text-muted">
                <small>&copy; 2026 Clinic Appointment Management System. All rights reserved.</small>
            </div>
        </footer>

        <!-- Bootstrap 5 JS Bundle CDN -->
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"
                integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz"
                crossorigin="anonymous">
        </script>
        </body>
        </html>
    </c:otherwise>
</c:choose>
