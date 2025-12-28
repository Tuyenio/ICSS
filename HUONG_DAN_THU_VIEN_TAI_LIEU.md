# 📚 HƯỚNG DẪN CÀI ĐẶT VÀ SỬ DỤNG - THƯ VIỆN TÀI LIỆU

## 🎯 Tổng quan
Chức năng **Thư viện tài liệu** cho phép quản lý toàn bộ tài liệu, file báo cáo, mẫu đơn nội bộ của công ty một cách chuyên nghiệp và hiệu quả.

---

## 📋 CÁC BƯỚC CÀI ĐẶT

### **Bước 1: Tạo bảng database**

Chạy file SQL để tạo bảng `tai_lieu` trong database:

```bash
web/DB/tai_lieu_table.sql
```

Hoặc chạy trực tiếp trong MySQL:

```sql
CREATE TABLE IF NOT EXISTS tai_lieu (
    id INT AUTO_INCREMENT PRIMARY KEY,
    ten_tai_lieu VARCHAR(255) NOT NULL,
    loai_tai_lieu VARCHAR(100) DEFAULT 'Khác',
    mo_ta TEXT,
    file_name VARCHAR(255) NOT NULL,
    file_path VARCHAR(500) NOT NULL,
    file_size BIGINT DEFAULT 0,
    file_type VARCHAR(50),
    nguoi_tao_id INT,
    ngay_tao DATETIME DEFAULT CURRENT_TIMESTAMP,
    ngay_cap_nhat DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    trang_thai ENUM('Hoạt động', 'Đã xóa') DEFAULT 'Hoạt động',
    luot_xem INT DEFAULT 0,
    luot_tai INT DEFAULT 0,
    FOREIGN KEY (nguoi_tao_id) REFERENCES nhanvien(id) ON DELETE SET NULL,
    INDEX idx_loai (loai_tai_lieu),
    INDEX idx_ngay_tao (ngay_tao),
    INDEX idx_trang_thai (trang_thai)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

### **Bước 2: Kiểm tra các file đã tạo**

✅ **Backend (Java):**
- `src/java/controller/TaiLieu.java` - Entity class
- `src/java/controller/DocumentServlet.java` - Servlet xử lý logic
- `src/java/controller/KNCSDL.java` - Đã thêm các methods CRUD

✅ **Frontend (JSP):**
- `web/documents.jsp` - Giao diện chính
- `web/sidebar.jsp` - Đã thêm menu "Thư viện tài liệu"

✅ **Thư mục upload:**
- `web/uploads/documents/` - Thư mục lưu file

### **Bước 3: Build và Deploy**

Trong NetBeans hoặc command line:

```bash
ant clean-build deploy
```

Hoặc sử dụng task có sẵn:
- Build and Deploy ICSS

### **Bước 4: Khởi động lại server**

Khởi động lại Tomcat/GlassFish server để áp dụng thay đổi.

---

## 🚀 HƯỚNG DẪN SỬ DỤNG

### **1. Truy cập Thư viện tài liệu**
- Đăng nhập vào hệ thống
- Click vào menu **"Thư viện tài liệu"** trên sidebar
- Icon: 📁 (Folder open)

### **2. Tải lên tài liệu mới**
1. Click nút **"Tải lên tài liệu"** ở góc trên bên phải
2. Điền thông tin:
   - **Tên tài liệu** (bắt buộc)
   - **Loại tài liệu**: Báo cáo, Mẫu đơn, Quy định, Chính sách, Hướng dẫn, Khác
   - **Mô tả**: Mô tả ngắn về tài liệu
   - **Chọn file**: PDF, DOC, DOCX, XLS, XLSX, hình ảnh... (max 50MB)
3. Click **"Tải lên"**

### **3. Tìm kiếm và lọc tài liệu**
- **Tìm kiếm**: Nhập từ khóa trong ô "Tìm kiếm tài liệu"
- **Lọc theo loại**: Chọn loại tài liệu từ dropdown
- Click **"Tìm"**

### **4. Quản lý tài liệu**
Mỗi tài liệu có 3 nút thao tác:

✅ **Tải xuống** (màu xanh lá)
- Download file về máy
- Tự động tăng lượt tải

✏️ **Chỉnh sửa** (màu vàng)
- Cập nhật tên, loại, mô tả
- Không thể thay đổi file đã upload

🗑️ **Xóa** (màu đỏ)
- Xóa mềm (soft delete)
- Tài liệu vẫn còn trong database với trạng thái "Đã xóa"

### **5. Thông tin hiển thị**
Mỗi tài liệu hiển thị:
- 📄 Icon file theo loại (PDF màu đỏ, Word màu xanh, Excel màu xanh lá...)
- 📝 Tên tài liệu
- 🏷️ Loại tài liệu (badge)
- 👤 Người tạo
- 📅 Ngày tạo
- 💾 Kích thước file
- 👁️ Lượt xem
- ⬇️ Lượt tải

---

## 🎨 TÍNH NĂNG NỔI BẬT

### ✨ **Giao diện cao cấp**
- Modern glassmorphism design
- Responsive trên mọi thiết bị
- Smooth animations và transitions
- Icon màu sắc theo loại file

### 🔒 **Bảo mật**
- Kiểm tra đăng nhập trước khi truy cập
- Validate kích thước file (max 50MB)
- Sanitize tên file để tránh lỗ hổng bảo mật
- Tên file được mã hóa UUID

### 📊 **Thống kê**
- Đếm lượt xem (view count)
- Đếm lượt tải (download count)
- Thông tin người tạo và ngày tạo

### 🔍 **Tìm kiếm thông minh**
- Tìm theo tên tài liệu
- Tìm theo mô tả
- Lọc theo loại tài liệu

---

## 📁 CẤU TRÚC FILE

```
ICSS/
├── src/java/controller/
│   ├── TaiLieu.java               # Entity class
│   ├── DocumentServlet.java       # Servlet xử lý
│   └── KNCSDL.java               # Database connection (đã update)
├── web/
│   ├── documents.jsp              # Giao diện chính
│   ├── sidebar.jsp                # Sidebar (đã update)
│   ├── header.jsp                 # Header
│   ├── DB/
│   │   └── tai_lieu_table.sql    # SQL tạo bảng
│   └── uploads/
│       └── documents/             # Thư mục lưu file
│           └── README.md
└── build.xml
```

---

## 🛠️ CẤU HÌNH NÂNG CAO

### **Thay đổi kích thước file tối đa**

Trong `DocumentServlet.java`:
```java
private static final long MAX_FILE_SIZE = 50 * 1024 * 1024; // 50MB

@MultipartConfig(
    maxFileSize = 1024 * 1024 * 50,       // 50MB
    maxRequestSize = 1024 * 1024 * 100    // 100MB
)
```

### **Thêm loại tài liệu mới**

Trong `documents.jsp`, tìm phần `<select name="loaiTaiLieu">`:
```html
<option value="Tên loại mới">Tên loại mới</option>
```

### **Thay đổi thư mục upload**

Trong `DocumentServlet.java`:
```java
private static final String UPLOAD_DIR = "uploads" + File.separator + "documents";
```

---

## ❗ TROUBLESHOOTING

### **Lỗi: "File quá lớn"**
➡️ Kiểm tra `MAX_FILE_SIZE` và `@MultipartConfig` trong servlet

### **Lỗi: "Không thể tải file lên"**
➡️ Kiểm tra quyền ghi (write permission) của thư mục `uploads/documents/`

### **Lỗi: "Không tìm thấy file khi download"**
➡️ Kiểm tra đường dẫn file trong database và thư mục thực tế

### **Giao diện bị lỗi****
➡️ Clear cache trình duyệt (Ctrl+F5)
➡️ Kiểm tra console log trình duyệt (F12)

---

## 📞 HỖ TRỢ

Nếu gặp vấn đề, kiểm tra:
1. ✅ Database đã tạo bảng `tai_lieu` chưa?
2. ✅ Thư mục `uploads/documents/` đã tồn tại chưa?
3. ✅ Server đã restart sau khi build chưa?
4. ✅ Session đăng nhập còn hợp lệ không?

---

## 🎉 HOÀN THÀNH!

Chức năng **Thư viện tài liệu** đã sẵn sàng sử dụng với:
- ✅ CRUD đầy đủ (Thêm, Xem, Sửa, Xóa)
- ✅ Upload & Download file
- ✅ Tìm kiếm & Lọc
- ✅ Giao diện chuyên nghiệp
- ✅ Responsive design
- ✅ Bảo mật tốt

**Chúc bạn sử dụng hiệu quả!** 🚀
