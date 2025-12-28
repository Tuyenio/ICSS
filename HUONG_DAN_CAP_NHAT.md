# 📚 CẬP NHẬT THƯ VIỆN TÀI LIỆU - PHIÊN BẢN NHÓM TÀI LIỆU

## 🎯 Tổng quan thay đổi
Chức năng **Thư viện tài liệu** đã được cập nhật để quản lý tài liệu theo **Nhóm tài liệu**:
- ✅ Thêm mới là **thêm nhóm tài liệu**
- ✅ Click vào nhóm nào → Hiển thị và thêm tài liệu cho nhóm đó
- ✅ Form thêm tài liệu giữ nguyên như cũ

---

## 📋 CÁC BƯỚC CẬP NHẬT

### **Bước 1: Chạy SQL để tạo bảng nhóm tài liệu**

Chạy file SQL:
```bash
web/DB/nhom_tai_lieu_table.sql
```

Hoặc chạy trực tiếp trong MySQL:

```sql
-- Tạo bảng nhóm tài liệu
CREATE TABLE IF NOT EXISTS nhom_tai_lieu (
    id INT AUTO_INCREMENT PRIMARY KEY,
    ten_nhom VARCHAR(255) NOT NULL,
    mo_ta TEXT,
    icon VARCHAR(50) DEFAULT 'fa-folder',
    mau_sac VARCHAR(20) DEFAULT '#3b82f6',
    nguoi_tao_id INT,
    ngay_tao DATETIME DEFAULT CURRENT_TIMESTAMP,
    ngay_cap_nhat DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    trang_thai ENUM('Hoạt động', 'Đã xóa') DEFAULT 'Hoạt động',
    thu_tu INT DEFAULT 0,
    FOREIGN KEY (nguoi_tao_id) REFERENCES nhanvien(id) ON DELETE SET NULL,
    INDEX idx_trang_thai (trang_thai),
    INDEX idx_thu_tu (thu_tu)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Thêm cột nhom_tai_lieu_id vào bảng tai_lieu
ALTER TABLE tai_lieu 
ADD COLUMN nhom_tai_lieu_id INT DEFAULT NULL AFTER id,
ADD FOREIGN KEY (nhom_tai_lieu_id) REFERENCES nhom_tai_lieu(id) ON DELETE SET NULL;

-- Thêm một số nhóm tài liệu mẫu
INSERT INTO nhom_tai_lieu (ten_nhom, mo_ta, icon, mau_sac, thu_tu) VALUES
('Báo cáo', 'Các báo cáo định kỳ và chuyên đề', 'fa-chart-line', '#3b82f6', 1),
('Mẫu đơn', 'Các mẫu đơn, biểu mẫu nội bộ', 'fa-file-lines', '#10b981', 2),
('Quy định & Chính sách', 'Quy định, chính sách công ty', 'fa-scale-balanced', '#f59e0b', 3),
('Hợp đồng & MOU', 'Hợp đồng, biên bản ghi nhớ', 'fa-file-contract', '#8b5cf6', 4),
('Hướng dẫn', 'Tài liệu hướng dẫn, quy trình', 'fa-book', '#06b6d4', 5),
('Thanh toán', 'Đề nghị, đề xuất thanh toán', 'fa-money-check-dollar', '#ec4899', 6),
('Khác', 'Các tài liệu khác', 'fa-folder-open', '#6b7280', 99);
```

### **Bước 2: Kiểm tra các file đã cập nhật**

✅ **Backend (Java):**
- `src/java/controller/NhomTaiLieu.java` - ✅ Entity class mới cho nhóm tài liệu
- `src/java/controller/TaiLieu.java` - ✅ Đã thêm field `nhomTaiLieuId`
- `src/java/controller/GroupDocumentServlet.java` - ✅ Servlet mới xử lý nhóm tài liệu
- `src/java/controller/DocumentServlet.java` - ✅ Đã cập nhật xử lý theo nhóm
- `src/java/controller/KNCSDL.java` - ✅ Đã thêm methods CRUD cho nhóm

✅ **Frontend (JSP):**
- `web/documents.jsp` - ✅ Giao diện mới với nhóm tài liệu

✅ **Database:**
- `web/DB/nhom_tai_lieu_table.sql` - ✅ SQL tạo bảng và insert dữ liệu mẫu

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

## 🚀 HƯỚNG DẪN SỬ DỤNG MỚI

### **1. Truy cập Thư viện tài liệu**
- Đăng nhập vào hệ thống
- Click vào menu **"Thư viện tài liệu"** trên sidebar
- Màn hình chính sẽ hiển thị **danh sách các nhóm tài liệu**

### **2. Quản lý nhóm tài liệu**

#### **a) Thêm nhóm tài liệu mới:**
1. Click nút **"Thêm nhóm tài liệu"** ở góc trên bên phải
2. Điền thông tin:
   - **Tên nhóm** (bắt buộc): Tên nhóm tài liệu
   - **Mô tả**: Mô tả ngắn về nhóm
   - **Icon**: FontAwesome icon class (vd: fa-folder, fa-file-contract)
   - **Màu sắc**: Chọn màu đại diện cho nhóm
   - **Thứ tự**: Thứ tự hiển thị (0 = đầu tiên)
3. Click **"Thêm nhóm"**

#### **b) Sửa nhóm tài liệu:**
- Click nút **⋮** (3 chấm dọc) trên card nhóm
- Chọn **"Sửa"**
- Cập nhật thông tin → Click **"Lưu thay đổi"**

#### **c) Xóa nhóm tài liệu:**
- Click nút **⋮** trên card nhóm
- Chọn **"Xóa"**
- Xác nhận xóa

> ⚠️ **Lưu ý:** Xóa nhóm không xóa các tài liệu bên trong (soft delete)

### **3. Quản lý tài liệu trong nhóm**

#### **a) Xem tài liệu trong nhóm:**
- Click vào **card nhóm tài liệu**
- Hệ thống sẽ hiển thị danh sách tài liệu trong nhóm đó

#### **b) Tải lên tài liệu mới:**
1. Vào trong một nhóm tài liệu
2. Click nút **"Tải lên tài liệu"** ở góc trên bên phải
3. Điền thông tin (giống cũ):
   - **Tên tài liệu** (bắt buộc)
   - **Loại tài liệu**: Báo cáo, Mẫu đơn, Quy định, Chính sách, v.v.
   - **Mô tả**: Mô tả ngắn về tài liệu
   - **Chọn file** (bắt buộc): Max 50MB
4. Click **"Tải lên"**

> 📝 **Tài liệu sẽ được lưu vào nhóm hiện tại**

#### **c) Tìm kiếm tài liệu trong nhóm:**
- Vào trong một nhóm
- Sử dụng ô tìm kiếm ở trên
- Nhập từ khóa → Click **"Tìm"**

#### **d) Quản lý tài liệu (Tải xuống, Sửa, Xóa):**
- Các nút thao tác giữ nguyên như cũ:
  - ✅ **Tải xuống** (màu xanh lá)
  - ✏️ **Chỉnh sửa** (màu vàng)
  - 🗑️ **Xóa** (màu đỏ)

### **4. Breadcrumb navigation**
- Khi vào trong nhóm, sẽ có thanh điều hướng:
  - **Trang chủ** → Về danh sách nhóm
  - **/ Tên nhóm** → Nhóm hiện tại

---

## 🎨 TÍNH NĂNG MỚI

### ✨ **Quản lý theo nhóm**
- Tổ chức tài liệu theo nhóm chuyên biệt
- Mỗi nhóm có icon và màu sắc riêng
- Hiển thị số lượng tài liệu trong mỗi nhóm

### 📊 **Thống kê**
- Đếm số lượng tài liệu trong mỗi nhóm
- Hiển thị trực quan trên card nhóm

### 🔍 **Tìm kiếm thông minh**
- Tìm kiếm trong toàn bộ nhóm
- Tìm kiếm theo tên, mô tả, loại tài liệu

### 🎨 **Giao diện đẹp hơn**
- Cards nhóm tài liệu với hover effect
- Màu sắc tùy chỉnh cho mỗi nhóm
- Icons fontawesome linh hoạt
- Breadcrumb navigation rõ ràng

---

## 📁 CẤU TRÚC FILE MỚI

```
ICSS/
├── src/java/controller/
│   ├── NhomTaiLieu.java          # [MỚI] Entity nhóm tài liệu
│   ├── TaiLieu.java               # [CẬP NHẬT] Thêm nhomTaiLieuId
│   ├── GroupDocumentServlet.java  # [MỚI] Servlet nhóm tài liệu
│   ├── DocumentServlet.java       # [CẬP NHẬT] Xử lý theo nhóm
│   └── KNCSDL.java                # [CẬP NHẬT] Thêm methods nhóm
├── web/
│   ├── documents.jsp              # [CẬP NHẬT HOÀN TOÀN] Giao diện mới
│   └── DB/
│       └── nhom_tai_lieu_table.sql # [MỚI] SQL tạo bảng
└── HUONG_DAN_CAP_NHAT.md         # File này
```

---

## 🔄 THAY ĐỔI KỸ THUẬT

### **1. Database Schema**
```sql
-- Bảng mới
nhom_tai_lieu (
    id, ten_nhom, mo_ta, icon, mau_sac,
    nguoi_tao_id, ngay_tao, ngay_cap_nhat,
    trang_thai, thu_tu
)

-- Bảng cập nhật
tai_lieu (
    ...,
    nhom_tai_lieu_id INT [MỚI], -- Foreign key to nhom_tai_lieu
    ...
)
```

### **2. Entity Classes**
- **NhomTaiLieu.java**: Class mới với đầy đủ getters/setters
- **TaiLieu.java**: Thêm `nhomTaiLieuId`, `tenNhomTaiLieu`

### **3. Servlet Mapping**
```java
// Servlet mới
@WebServlet("/dsNhomTailieu", "/themNhomTailieu", "/suaNhomTailieu", "/xoaNhomTailieu")
GroupDocumentServlet

// Servlet cập nhật
@WebServlet("/dsTailieu", "/uploadTailieu", "/downloadTailieu", "/deleteTailieu", "/updateTailieu")
DocumentServlet // Đã cập nhật để xử lý theo nhóm
```

### **4. KNCSDL Methods**
**Methods mới:**
- `getAllNhomTaiLieu()` - Lấy tất cả nhóm
- `getNhomTaiLieuById(int id)` - Lấy nhóm theo ID
- `insertNhomTaiLieu(NhomTaiLieu)` - Thêm nhóm mới
- `updateNhomTaiLieu(NhomTaiLieu)` - Cập nhật nhóm
- `deleteNhomTaiLieu(int id)` - Xóa nhóm
- `getTaiLieuByNhomId(int nhomId)` - Lấy tài liệu theo nhóm
- `searchTaiLieuInNhom(int nhomId, String keyword)` - Tìm kiếm trong nhóm

**Methods cập nhật:**
- `insertTaiLieu()` - Thêm parameter `nhomTaiLieuId`

---

## 🛠️ TROUBLESHOOTING

### **Lỗi: "Table 'nhom_tai_lieu' doesn't exist"**
➡️ Chạy lại file SQL `nhom_tai_lieu_table.sql`

### **Lỗi: "Column 'nhom_tai_lieu_id' not found"**
➡️ Chạy câu lệnh ALTER TABLE để thêm cột vào bảng tai_lieu

### **Không hiển thị nhóm tài liệu**
➡️ Kiểm tra đã insert dữ liệu mẫu chưa
➡️ Kiểm tra session đăng nhập còn hợp lệ không

### **Lỗi khi upload tài liệu**
➡️ Phải chọn một nhóm tài liệu trước khi upload
➡️ Kiểm tra thư mục `uploads/documents/` có quyền ghi không

---

## 📊 SO SÁNH TRƯỚC VÀ SAU

| Tính năng | Trước | Sau |
|-----------|-------|-----|
| **Thêm mới** | Thêm trực tiếp tài liệu | Thêm nhóm tài liệu trước |
| **Tổ chức** | Lọc theo loại tài liệu | Quản lý theo nhóm chuyên biệt |
| **Tìm kiếm** | Tìm trong tất cả tài liệu | Tìm trong từng nhóm |
| **Hiển thị** | Danh sách phẳng | Phân cấp: Nhóm → Tài liệu |
| **Giao diện** | Cards tài liệu | Cards nhóm + Cards tài liệu |
| **Icon/Màu** | Theo loại file | Theo nhóm tài liệu |

---

## ✅ CHECKLIST SAU KHI CẬP NHẬT

- [ ] Đã chạy SQL tạo bảng `nhom_tai_lieu`
- [ ] Đã thêm cột `nhom_tai_lieu_id` vào bảng `tai_lieu`
- [ ] Đã insert dữ liệu mẫu cho nhóm tài liệu
- [ ] Đã build và deploy project
- [ ] Đã restart server
- [ ] Có thể truy cập trang Thư viện tài liệu
- [ ] Hiển thị được danh sách nhóm tài liệu
- [ ] Có thể thêm/sửa/xóa nhóm tài liệu
- [ ] Có thể click vào nhóm để xem tài liệu
- [ ] Có thể upload tài liệu vào nhóm
- [ ] Có thể tải xuống/sửa/xóa tài liệu
- [ ] Tìm kiếm hoạt động bình thường

---

## 🎉 HOÀN THÀNH!

Chức năng **Thư viện tài liệu** với **Nhóm tài liệu** đã sẵn sàng sử dụng!

### Luồng sử dụng mới:
1. **Trang chủ** → Hiển thị danh sách nhóm tài liệu
2. **Click nhóm** → Hiển thị tài liệu trong nhóm
3. **Upload tài liệu** → Tài liệu được lưu vào nhóm hiện tại
4. **Quay lại** → Click "Trang chủ" trên breadcrumb

**Form thêm tài liệu giữ nguyên như cũ, chỉ cần chọn nhóm trước!**

---

📞 **Hỗ trợ**: Nếu gặp vấn đề, kiểm tra console log hoặc kiểm tra lại các bước trên.

🚀 **Chúc bạn sử dụng hiệu quả!**
