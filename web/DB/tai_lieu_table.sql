-- ===================================
-- Bảng quản lý THƯ VIỆN TÀI LIỆU
-- ===================================

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

-- ===================================
-- Dữ liệu mẫu
-- ===================================

INSERT INTO tai_lieu (ten_tai_lieu, loai_tai_lieu, mo_ta, file_name, file_path, file_size, file_type, nguoi_tao_id) VALUES
('Quy định nội bộ công ty', 'Quy định', 'Tài liệu quy định nội bộ về quy trình làm việc và văn hóa doanh nghiệp', 'quy_dinh_noi_bo.pdf', 'uploads/documents/quy_dinh_noi_bo.pdf', 524288, 'application/pdf', 1),
('Mẫu đơn xin nghỉ phép', 'Mẫu đơn', 'Form đơn xin nghỉ phép chuẩn của công ty', 'mau_don_nghi_phep.docx', 'uploads/documents/mau_don_nghi_phep.docx', 32768, 'application/vnd.openxmlformats-officedocument.wordprocessingml.document', 1),
('Báo cáo tài chính Q4/2024', 'Báo cáo', 'Báo cáo tài chính quý 4 năm 2024', 'bao_cao_tai_chinh_q4_2024.xlsx', 'uploads/documents/bao_cao_tai_chinh_q4_2024.xlsx', 102400, 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', 1),
('Hướng dẫn sử dụng hệ thống', 'Hướng dẫn', 'Tài liệu hướng dẫn chi tiết sử dụng hệ thống quản lý nhân sự', 'huong_dan_he_thong.pdf', 'uploads/documents/huong_dan_he_thong.pdf', 1048576, 'application/pdf', 1),
('Chính sách đào tạo nhân viên', 'Chính sách', 'Quy định về chính sách đào tạo và phát triển nhân viên', 'chinh_sach_dao_tao.pdf', 'uploads/documents/chinh_sach_dao_tao.pdf', 409600, 'application/pdf', 1);
