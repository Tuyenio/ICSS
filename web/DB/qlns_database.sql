-- Tạo Database (xóa database cũ nếu tồn tại để tránh xung đột)
DROP DATABASE IF EXISTS qlns;
CREATE DATABASE qlns CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE qlns;

-- ============================================
-- PHẦN 1: TẠO CẤU TRÚC BẢNG
-- ============================================

-- 1. Bảng phòng ban
CREATE TABLE phong_ban (
    id INT PRIMARY KEY AUTO_INCREMENT,
    ten_phong VARCHAR(100) NOT NULL,
    truong_phong_id INT DEFAULT NULL,
    ngay_tao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. Bảng nhân viên
CREATE TABLE nhanvien (
    id INT PRIMARY KEY AUTO_INCREMENT,
    ho_ten VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    mat_khau VARCHAR(255) NOT NULL,
    so_dien_thoai VARCHAR(20),
    gioi_tinh ENUM('Nam', 'Nữ', 'Khác'),
    ngay_sinh DATE,
    phong_ban_id INT,
    chuc_vu VARCHAR(100),
    luong_co_ban DECIMAL(12,2) DEFAULT 0,
    trang_thai_lam_viec ENUM('Đang làm', 'Tạm nghỉ', 'Nghỉ việc') DEFAULT 'Đang làm',
    vai_tro ENUM('Admin', 'Quản lý', 'Nhân viên') DEFAULT 'Nhân viên',
    ngay_vao_lam DATE,
    avatar_url VARCHAR(255),
    ngay_tao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (phong_ban_id) REFERENCES phong_ban(id) ON DELETE SET NULL
);

-- Cập nhật khóa ngoại cho trưởng phòng (sau khi bảng nhân viên được tạo)
ALTER TABLE phong_ban ADD CONSTRAINT fk_truong_phong FOREIGN KEY (truong_phong_id) REFERENCES nhanvien(id) ON DELETE SET NULL;

-- 3. Công việc
CREATE TABLE cong_viec (
    id INT PRIMARY KEY AUTO_INCREMENT,
    ten_cong_viec VARCHAR(255) NOT NULL,
    mo_ta TEXT,
    han_hoan_thanh DATE,
    muc_do_uu_tien ENUM('Thấp', 'Trung bình', 'Cao') DEFAULT 'Trung bình',
    nguoi_giao_id INT,
    nguoi_nhan_id INT,
    phong_ban_id INT,
    trang_thai ENUM('Chưa bắt đầu', 'Đang thực hiện', 'Đã hoàn thành', 'Trễ hạn') DEFAULT 'Chưa bắt đầu',
    ngay_tao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (nguoi_giao_id) REFERENCES nhanvien(id) ON DELETE CASCADE,
    FOREIGN KEY (nguoi_nhan_id) REFERENCES nhanvien(id) ON DELETE CASCADE,
    FOREIGN KEY (phong_ban_id) REFERENCES phong_ban(id) ON DELETE SET NULL
);

-- 4. Theo dõi tiến độ công việc
CREATE TABLE cong_viec_tien_do (
    id INT PRIMARY KEY AUTO_INCREMENT,
    cong_viec_id INT,
    nguoi_cap_nhat_id INT,
    phan_tram INT CHECK (phan_tram BETWEEN 0 AND 100),
    ghi_chu TEXT,
    file_dinh_kem VARCHAR(255),
    thoi_gian_cap_nhat TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (cong_viec_id) REFERENCES cong_viec(id) ON DELETE CASCADE,
    FOREIGN KEY (nguoi_cap_nhat_id) REFERENCES nhanvien(id) ON DELETE CASCADE
);

-- 5. Lịch sử công việc
CREATE TABLE cong_viec_lich_su (
    id INT PRIMARY KEY AUTO_INCREMENT,
    cong_viec_id INT,
    nguoi_thay_doi_id INT,
    mo_ta_thay_doi TEXT,
    thoi_gian TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (cong_viec_id) REFERENCES cong_viec(id) ON DELETE CASCADE,
    FOREIGN KEY (nguoi_thay_doi_id) REFERENCES nhanvien(id) ON DELETE CASCADE
);

-- 6. Đánh giá công việc
CREATE TABLE cong_viec_danh_gia (
    id INT PRIMARY KEY AUTO_INCREMENT,
    cong_viec_id INT,
    nguoi_danh_gia_id INT,
    nhan_xet TEXT,
    thoi_gian TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (cong_viec_id) REFERENCES cong_viec(id) ON DELETE CASCADE,
    FOREIGN KEY (nguoi_danh_gia_id) REFERENCES nhanvien(id) ON DELETE CASCADE
);

-- 7. Chấm công
CREATE TABLE cham_cong (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nhan_vien_id INT,
    ngay DATE,
    check_in TIME,
    check_out TIME,
    FOREIGN KEY (nhan_vien_id) REFERENCES nhanvien(id) ON DELETE CASCADE,
    UNIQUE(nhan_vien_id, ngay)
);

-- 8. Bảng lương
CREATE TABLE luong (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nhan_vien_id INT,
    thang INT,
    nam INT,
    luong_co_ban DECIMAL(12,2),
    phu_cap DECIMAL(12,2) DEFAULT 0,
    thuong DECIMAL(12,2) DEFAULT 0,
    phat DECIMAL(12,2) DEFAULT 0,
    bao_hiem DECIMAL(12,2) DEFAULT 0,
    thue DECIMAL(12,2) DEFAULT 0,
    luong_thuc_te DECIMAL(12,2),
    ghi_chu TEXT,
    trang_thai ENUM('Chưa trả', 'Đã trả') DEFAULT 'Chưa trả',
    ngay_tra_luong DATE,
    ngay_tao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (nhan_vien_id) REFERENCES nhanvien(id) ON DELETE CASCADE
);

-- 9. Thông báo
CREATE TABLE thong_bao (
    id INT PRIMARY KEY AUTO_INCREMENT,
    tieu_de VARCHAR(255),
    noi_dung TEXT,
    nguoi_nhan_id INT,
    loai_thong_bao ENUM('Công việc mới', 'Hạn chót', 'Trễ hạn', 'Lương', 'Khác') DEFAULT 'Khác',
    da_doc BOOLEAN DEFAULT FALSE,
    ngay_doc TIMESTAMP NULL DEFAULT NULL,
    ngay_tao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (nguoi_nhan_id) REFERENCES nhanvien(id) ON DELETE CASCADE
);

-- 10. Báo cáo công việc
CREATE TABLE bao_cao_cong_viec (
    id INT PRIMARY KEY AUTO_INCREMENT,
    loai_bao_cao VARCHAR(100),
    duong_dan VARCHAR(255),
    nguoi_tao_id INT,
    ngay_tao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (nguoi_tao_id) REFERENCES nhanvien(id) ON DELETE CASCADE
);


-- 11. File đính kèm (của công việc hoặc tiến độ)
CREATE TABLE file_dinh_kem (
    id INT PRIMARY KEY AUTO_INCREMENT,
    cong_viec_id INT,
    tien_do_id INT,
    duong_dan_file VARCHAR(255),
    mo_ta TEXT,
    thoi_gian_upload TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (cong_viec_id) REFERENCES cong_viec(id) ON DELETE CASCADE,
    FOREIGN KEY (tien_do_id) REFERENCES cong_viec_tien_do(id) ON DELETE CASCADE
);

-- 12. Cấu hình công thức lương
CREATE TABLE luong_cau_hinh (
    id INT PRIMARY KEY AUTO_INCREMENT,
    ten_cau_hinh VARCHAR(100),
    gia_tri VARCHAR(100),
    mo_ta TEXT,
    ngay_tao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 13. Ghi nhận KPI theo công việc
CREATE TABLE luu_kpi (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nhan_vien_id INT,
    thang INT,
    nam INT,
    chi_tieu TEXT,
    ket_qua TEXT,
    diem_kpi FLOAT,
    ghi_chu TEXT,
    ngay_tao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (nhan_vien_id) REFERENCES nhanvien(id) ON DELETE CASCADE
);

-- 14. Lịch sử thay đổi nhân sự
CREATE TABLE nhan_su_lich_su (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nhan_vien_id INT,
    loai_thay_doi VARCHAR(100),
    gia_tri_cu TEXT,
    gia_tri_moi TEXT,
    nguoi_thay_doi_id INT,
    ghi_chu TEXT,
    thoi_gian TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (nhan_vien_id) REFERENCES nhanvien(id) ON DELETE CASCADE,
    FOREIGN KEY (nguoi_thay_doi_id) REFERENCES nhanvien(id) ON DELETE SET NULL
);

-- 15. Phân quyền chức năng
CREATE TABLE phan_quyen_chuc_nang (
    id INT PRIMARY KEY AUTO_INCREMENT,
    vai_tro ENUM('Admin', 'Quản lý', 'Nhân viên', 'Trưởng nhóm', 'Nhân viên cấp cao'),
    chuc_nang VARCHAR(100),
    co_quyen BOOLEAN DEFAULT FALSE
);

-- 16. Cấu hình hệ thống
CREATE TABLE cau_hinh_he_thong (
    id INT PRIMARY KEY AUTO_INCREMENT,
    ten_cau_hinh VARCHAR(100),
    gia_tri TEXT,
    mo_ta TEXT,
    ngay_tao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 17. Quy trình công việc
CREATE TABLE cong_viec_quy_trinh (
    id INT PRIMARY KEY AUTO_INCREMENT,
    cong_viec_id INT,
    ten_buoc VARCHAR(255),
    mo_ta TEXT,
    trang_thai ENUM('Chưa bắt đầu', 'Đang thực hiện', 'Đã hoàn thành') DEFAULT 'Chưa bắt đầu',
    ngay_bat_dau DATE,
    ngay_ket_thuc DATE,
    ngay_tao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (cong_viec_id) REFERENCES cong_viec(id) ON DELETE CASCADE
);