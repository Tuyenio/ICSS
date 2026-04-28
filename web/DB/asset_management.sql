CREATE TABLE IF NOT EXISTS tai_san (
    id INT AUTO_INCREMENT PRIMARY KEY,
    ten_tai_san VARCHAR(255) NOT NULL,
    so_luong INT NOT NULL DEFAULT 0,
    tinh_trang VARCHAR(100) DEFAULT 'Dang su dung',
    gia_ca DECIMAL(15,2) NOT NULL DEFAULT 0,
    bao_hanh VARCHAR(100) DEFAULT NULL,
    mo_ta TEXT,
    ngay_tao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ngay_cap_nhat TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX idx_tai_san_tinh_trang ON tai_san(tinh_trang);
CREATE INDEX idx_tai_san_ten ON tai_san(ten_tai_san);
