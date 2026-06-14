# CLAUDE.md — Clinic Appointment Management System (CAMS)



**5 Role**: Admin, Doctor, Manager, Staff, Patient, Sonographer

## Công Nghệ

| Thành phần | Công nghệ |
|------------|-----------|
| Ngôn ngữ | Java 17 |
| Web Server | Apache Tomcat 10.1 |
| Servlet API | Jakarta Servlet 6.x |
| Database | SQL Server |
| Build | Apache Ant (NetBeans) |
| View | JSP + JSTL 3.0 |
| DB Access | JDBC (PreparedStatement) |
| Password | BCrypt (jbcrypt 0.4) |
| Frontend | Bootstrap 5 CDN |

## Kiến Trúc Hệ Thống

### MVC Pattern (strict)

```
Request → Controller (Servlet) → Service (Business Logic) → DAO (Data Access) → Database
                                         ↓
                                   Model (Entity)
                                         ↓
                                   View (JSP) → Response
```

### Package Structure

```
config/     — DatabaseConfig, AppConfig
model/      — Entity classes + enums/
DAO/        — Data Access Objects (extends BaseDAO)
service/    — Business Logic
controller/ — Servlets (extends BaseController)
filter/     — AuthenticationFilter, AuthorizationFilter, EncodingFilter
utils/      — BCryptUtil, ValidationUtil, DateUtil, PaginationUtil, EmailUtil, AuditUtil
```

### Web Structure

```
web/views/common/      — header.jsp, footer.jsp, sidebar.jsp, pagination.jsp
web/views/auth/        — login.jsp, register.jsp, forgot-password.jsp
web/views/admin/       — dashboard.jsp + users/, roles/, doctors/, services/, medicines/, news/, reviews/, audit-logs/, settings/, clinic/
web/views/errors/      — 403.jsp, 404.jsp, 500.jsp
web/assets/            — css/, js/, images/, uploads/
```

## Coding Conventions



### Quy Tắc Bắt Buộc

1. **KHÔNG business logic trong JSP** — chỉ dùng JSTL `<c:if>`, `<c:forEach>`, `${expr}`
2. **KHÔNG SQL trong Servlet** — mọi query phải qua DAO
3. **LUÔN dùng PreparedStatement** — không nối chuỗi SQL
4. **LUÔN hash password** — BCryptUtil.hashPassword() trước khi lưu
5. **Validate input ở Service layer** — dùng ValidationUtil
6. **Xử lý exception tập trung** — try-catch trong Service, throw lại cho Controller
7. **Đóng connection** — luôn dùng try-finally hoặc closeResources() trong DAO
8. **Session management** — user object lưu trong session attribute "user"
9. **Phân quyền** — AuthorizationFilter kiểm tra role trước khi vào /admin/*

### Database Conventions

- Tất cả bảng có `created_at DATETIME2 DEFAULT GETDATE()`
- Tất cả bảng có `updated_at DATETIME2 DEFAULT GETDATE()`
- Foreign key: `REFERENCES table(id)`
- NVARCHAR cho tiếng Việt
- BIT cho boolean (is_active, is_hidden, is_read)
- DECIMAL(18,2) cho tiền tệ

## Quy Trình Phát Triển

### Trước Khi Code
1. Đọc CLAUDE.md để hiểu context
2. Kiểm tra module đã hoàn thành
3. Xác định file cần tạo/sửa

### Khi Code
1. SQL script → Model → DAO → Service → Controller → Filter → JSP → CSS/JS
2. Mỗi file phải compile được ngay
3. Viết code sạch, comment tiếng Việt ở business logic quan trọng

### Sau Khi Code
1. Build: `ant clean build`
2. Deploy: Copy WAR vào Tomcat webapps
3. Test thủ công theo checklist

## Danh Sách Module

### Đã Hoàn Thành
- [x] Project skeleton (NetBeans)
- [x] BA Document (DocsProject.docx)
- [x] CLAUDE.md

### Đang Triển Khai
- [ ] Phase 1: Foundation & Authentication

### Tiếp Theo
- [ ] Phase 2: RBAC & Admin Layout & Dashboard
- [ ] Phase 3: User Management
- [ ] Phase 4: Role Management + Clinic
- [ ] Phase 5: Doctor Management
- [ ] Phase 6: Service & Medicine Management
- [ ] Phase 7: News & Reviews
- [ ] Phase 8: Audit Logs & System Settings
- [ ] Phase 9: Doctor Schedule & Appointment
- [ ] Phase 10: Medical Records, Prescriptions, Payments, Notifications
