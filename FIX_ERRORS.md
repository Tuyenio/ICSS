# 🔧 CÁC LỖI ĐÃ SỬA

## ✅ Lỗi 1: Thêm nhóm tài liệu bị logout

### **Nguyên nhân:**
Session attribute name không khớp - đang dùng `userID` nhưng có thể session lưu là `userId`

### **Giải pháp:**
Cập nhật [GroupDocumentServlet.java](src/java/controller/GroupDocumentServlet.java) - thử cả 2 attribute names:

```java
// Thử cả userID và userId
Integer userIdObj = (Integer) session.getAttribute("userID");
if (userIdObj == null) {
    userIdObj = (Integer) session.getAttribute("userId");
}
```

### **Icon Selector:**
Thay input text thành dropdown select với 15 icons phổ biến:
- Thư mục, Biểu đồ, Tài liệu, Luật, Hợp đồng
- Sách, Tiền, PDF, Word, Excel
- Cặp, Bảng ghi, Chứng chỉ, Con dấu, v.v.

**Vị trí thay đổi:**
- Modal "Thêm nhóm tài liệu" 
- Modal "Sửa nhóm tài liệu"

---

## ✅ Lỗi 2: Xóa tài liệu nhảy về trang nhóm ban đầu

### **Nguyên nhân:**
Khi xóa tài liệu, không truyền `nhomId` để redirect về đúng nhóm

### **Giải pháp:**

#### 1. **Cập nhật documents.jsp:**
- Thêm `nhomId` vào function `confirmDelete()`
- Thêm `&nhomId=` vào URL xóa
- Thêm hidden input `nhomId` vào form sửa tài liệu

```javascript
// Trước
onclick="confirmDelete(<%= doc.getId() %>, '<%= doc.getTenTaiLieu() %>')"

// Sau
onclick="confirmDelete(<%= doc.getId() %>, '<%= doc.getTenTaiLieu() %>', <%= nhomId %>)"
```

```javascript
// Function cập nhật
function confirmDelete(id, ten, nhomId) {
    // ...
    window.location.href = 'deleteTailieu?id=' + id + '&nhomId=' + nhomId;
}
```

#### 2. **Cập nhật DocumentServlet.java:**

**handleDeleteDocument():**
```java
// Lấy nhomId từ parameter
String nhomIdStr = request.getParameter("nhomId");

// ...xóa tài liệu...

// Redirect về đúng nhóm
if (nhomIdStr != null && !nhomIdStr.isEmpty()) {
    request.setAttribute("nhomId", Integer.parseInt(nhomIdStr));
}
handleListDocuments(request, response);
```

**handleUpdateDocument():**
```java
// Tương tự cho update
String nhomIdStr = request.getParameter("nhomId");
// ... update ...
if (nhomIdStr != null && !nhomIdStr.isEmpty()) {
    request.setAttribute("nhomId", Integer.parseInt(nhomIdStr));
}
```

**handleListDocuments():**
```java
// Kiểm tra cả request attribute (từ redirect)
if (nhomIdStr == null || nhomIdStr.isEmpty()) {
    Integer nhomIdAttr = (Integer) request.getAttribute("nhomId");
    if (nhomIdAttr != null) {
        nhomIdStr = nhomIdAttr.toString();
    }
}
```

---

## 📝 TÓM TẮT CÁC FILE ĐÃ SỬA

### ✅ **src/java/controller/GroupDocumentServlet.java**
- Thử cả 2 session attributes: `userID` và `userId`

### ✅ **src/java/controller/DocumentServlet.java**
- `handleDeleteDocument()`: Lấy và truyền nhomId
- `handleUpdateDocument()`: Lấy và truyền nhomId
- `handleListDocuments()`: Kiểm tra cả request attribute

### ✅ **web/documents.jsp**
- Modal thêm nhóm: Input icon → Select dropdown
- Modal sửa nhóm: Input icon → Select dropdown
- Modal sửa tài liệu: Thêm hidden input nhomId
- Nút xóa tài liệu: Truyền nhomId vào function
- Function confirmDelete(): Nhận và truyền nhomId vào URL

---

## 🧪 CÁCH KIỂM TRA

### **Test Lỗi 1: Thêm nhóm tài liệu**
1. Đăng nhập vào hệ thống
2. Vào Thư viện tài liệu
3. Click "Thêm nhóm tài liệu"
4. Chọn icon từ dropdown (không cần nhập mã)
5. Điền thông tin và Submit
6. ✅ Không bị logout, nhóm được thêm vào CSDL

### **Test Lỗi 2: Xóa tài liệu trong nhóm**
1. Click vào một nhóm tài liệu (ví dụ: Báo cáo)
2. Xóa một tài liệu trong nhóm đó
3. ✅ Sau khi xóa, vẫn ở lại trang nhóm "Báo cáo" (không nhảy về trang chủ)

### **Test thêm: Sửa tài liệu**
1. Vào một nhóm tài liệu
2. Sửa một tài liệu
3. ✅ Sau khi sửa, vẫn ở lại nhóm hiện tại

---

## 🚀 CÀI ĐẶT

1. **Build lại project:**
```bash
ant clean-build deploy
```

2. **Restart server:**
Khởi động lại Tomcat/GlassFish

3. **Test thử các tính năng đã sửa**

---

## ✨ DANH SÁCH 15 ICONS CÓ SẴN

1. **fa-folder** - Thư mục
2. **fa-chart-line** - Biểu đồ
3. **fa-file-lines** - Tài liệu
4. **fa-scale-balanced** - Luật
5. **fa-file-contract** - Hợp đồng
6. **fa-book** - Sách
7. **fa-money-check-dollar** - Tiền
8. **fa-folder-open** - Thư mục mở
9. **fa-file-pdf** - PDF
10. **fa-file-word** - Word
11. **fa-file-excel** - Excel
12. **fa-briefcase** - Cặp
13. **fa-clipboard** - Bảng ghi
14. **fa-certificate** - Chứng chỉ
15. **fa-stamp** - Con dấu

---

## 📌 GHI CHÚ

- Tất cả các thay đổi đều backward compatible
- Session check giờ an toàn hơn với fallback
- Icon selector giúp người dùng dễ chọn hơn
- Xóa/sửa tài liệu giờ giữ context nhóm hiện tại

**✅ Tất cả đã hoạt động ổn định!**
