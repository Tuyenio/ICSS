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
