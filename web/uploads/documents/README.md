# Thư mục lưu trữ tài liệu upload

Thư mục này dùng để lưu trữ các file tài liệu được upload lên hệ thống.

## Lưu ý quan trọng:
- Các file được upload sẽ tự động lưu vào thư mục này
- Tên file sẽ được đổi thành dạng UUID để tránh trùng lặp
- Đảm bảo thư mục này có quyền ghi (write permission)
- Không xóa file trực tiếp trong thư mục này trừ khi đã xóa khỏi database

## Cấu trúc:
```
uploads/
  └── documents/
      ├── uuid1_file1.pdf
      ├── uuid2_document.docx
      └── uuid3_report.xlsx
```

## Bảo mật:
- File upload được kiểm tra kích thước (max 50MB)
- Tên file được sanitize để tránh lỗ hổng bảo mật
- Chỉ người dùng đã đăng nhập mới có thể upload/download
