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

-- ============================================
-- PHẦN 2: NHẬP DỮ LIỆU MẪU
-- ============================================

-- Dữ liệu mẫu cho phòng ban (bổ sung thêm phòng ban)
INSERT INTO phong_ban (ten_phong, ngay_tao) VALUES
('Phòng Nhân sự', NOW()),
('Phòng Kỹ thuật', NOW()),
('Phòng Kế toán', NOW()),
('Phòng Kinh doanh', NOW()),
('Phòng Hành chính', NOW()),
('Phòng Marketing', NOW());

-- Dữ liệu mẫu cho nhân viên (bổ sung trạng thái, vai trò, phòng ban khác nhau)
INSERT INTO nhanvien (ho_ten, email, mat_khau, so_dien_thoai, gioi_tinh, ngay_sinh, phong_ban_id, chuc_vu, luong_co_ban, trang_thai_lam_viec, vai_tro, ngay_vao_lam, avatar_url)
VALUES
('Lê Văn Minh', 'minh@company.com', 'password123', '0901234567', 'Nam', '1985-01-15', 6, 'Giám đốc', 15000000, 'Đang làm', 'Admin', '2020-01-01', NULL),
('Trần Thị Lan', 'lan@company.com', 'password123', '0902345678', 'Nữ', '1988-03-20', 2, 'Trưởng phòng Nhân sự', 12000000, 'Đang làm', 'Quản lý', '2020-02-01', NULL),
('Nguyễn Văn Cường', 'cuong@company.com', 'password123', '0903456789', 'Nam', '1990-07-10', 1, 'Senior Developer', 10000000, 'Đang làm', 'Nhân viên', '2021-03-15', NULL),
('Phạm Thị Hoa', 'hoa@company.com', 'password123', '0904567890', 'Nữ', '1992-11-05', 4, 'Kế toán', 8000000, 'Đang làm', 'Nhân viên', '2021-06-01', NULL),
('Hoàng Minh Tuấn', 'tuan@company.com', 'password123', '0905678901', 'Nam', '1987-09-25', 5, 'Nhân viên Kinh doanh', 7000000, 'Đang làm', 'Nhân viên', '2022-01-10', NULL),
('Võ Thị Mai', 'mai@company.com', 'password123', '0906789012', 'Nữ', '1995-12-12', 1, 'UI/UX Designer', 9000000, 'Đang làm', 'Nhân viên', '2022-01-15', NULL),
('Đặng Văn Nam', 'nam@company.com', 'password123', '0907890123', 'Nam', '1996-04-08', 1, 'Junior Developer', 6500000, 'Đang làm', 'Nhân viên', '2023-03-01', NULL),
('Lý Thị Hương', 'huong@company.com', 'password123', '0908901234', 'Nữ', '1994-06-18', 3, 'Marketing Executive', 8500000, 'Đang làm', 'Nhân viên', '2022-05-10', NULL),
('Bùi Văn Đức', 'duc@company.com', 'password123', '0909012345', 'Nam', '1986-08-30', 4, 'Senior Accountant', 11000000, 'Đang làm', 'Quản lý', '2020-07-20', NULL),
('Ngô Thị Linh', 'linh@company.com', 'password123', '0910123456', 'Nữ', '1997-02-14', 2, 'HR Assistant', 7500000, 'Đang làm', 'Nhân viên', '2023-01-05', NULL);

-- Cập nhật trưởng phòng cho phòng ban (dựa trên 10 nhân viên có ID từ 1-10)
UPDATE phong_ban SET truong_phong_id = 2 WHERE id = 2; -- Trần Thị Lan - Trưởng phòng Nhân sự  
UPDATE phong_ban SET truong_phong_id = 9 WHERE id = 4; -- Bùi Văn Đức - Senior Accountant

-- Dữ liệu mẫu cho công việc (phân theo phòng ban)
INSERT INTO cong_viec (ten_cong_viec, mo_ta, han_hoan_thanh, muc_do_uu_tien, nguoi_giao_id, nguoi_nhan_id, phong_ban_id, trang_thai)
VALUES
-- Công việc Phòng Kỹ thuật (phong_ban_id = 2)
('Thiết kế giao diện trang chủ', 'Thiết kế giao diện cho trang chủ trang web công ty', '2024-08-15', 'Cao', 3, 6, 2, 'Đã hoàn thành'),
('Phát triển backend API', 'Xây dựng các giao diện lập trình cho trang web', '2024-08-25', 'Cao', 3, 1, 2, 'Đang thực hiện'),
('Tích hợp thanh toán online', 'Tích hợp cổng thanh toán Momo, VNPay', '2024-09-05', 'Trung bình', 3, 7, 2, 'Chưa bắt đầu'),
('Testing và debug', 'Kiểm thử tổng thể hệ thống', '2024-09-15', 'Cao', 3, 6, 2, 'Chưa bắt đầu'),
('Phân tích yêu cầu hệ thống', 'Thu thập và phân tích yêu cầu QLNS', '2024-07-20', 'Cao', 3, 2, 2, 'Đã hoàn thành'),
('Thiết kế database', 'Thiết kế cơ sở dữ liệu cho hệ thống', '2024-07-30', 'Cao', 3, 1, 2, 'Đã hoàn thành'),
('Phát triển module nhân viên', 'Xây dựng chức năng quản lý nhân viên', '2024-08-10', 'Trung bình', 3, 6, 2, 'Đang thực hiện'),
('Phát triển module chấm công', 'Xây dựng hệ thống chấm công', '2024-08-20', 'Trung bình', 3, 7, 2, 'Trễ hạn'),

-- Công việc Phòng Marketing (phong_ban_id = 6)
('Lập kế hoạch content', 'Lên kế hoạch nội dung marketing Q4', '2024-08-01', 'Cao', 8, 6, 6, 'Đã hoàn thành'),
('Thiết kế banner quảng cáo', 'Thiết kế các banner cho chiến dịch', '2024-08-05', 'Trung bình', 8, 6, 6, 'Đang thực hiện'),
('Chạy ads Facebook', 'Triển khai quảng cáo trên Facebook', '2024-08-15', 'Cao', 8, 8, 6, 'Chưa bắt đầu'),
('Báo cáo hiệu quả chiến dịch', 'Lập báo cáo kết quả marketing', '2024-09-30', 'Trung bình', 8, 6, 6, 'Chưa bắt đầu'),

-- Công việc Phòng Nhân sự (phong_ban_id = 1)
('Lập job description', 'Viết mô tả công việc các vị trí tuyển dụng', '2024-07-25', 'Cao', 2, 10, 1, 'Đã hoàn thành'),
('Đăng tin tuyển dụng', 'Đăng tin trên các trang tuyển dụng', '2024-08-01', 'Trung bình', 2, 10, 1, 'Đã hoàn thành'),
('Sàn lọc hồ sơ ứng viên', 'Rà soát và lọc hồ sơ ứng tuyển', '2024-08-10', 'Cao', 2, 2, 1, 'Đang thực hiện'),
('Phỏng vấn ứng viên', 'Tổ chức phỏng vấn các ứng viên', '2024-08-20', 'Cao', 2, 1, 1, 'Chưa bắt đầu'),

-- Công việc Phòng Kế toán (phong_ban_id = 3)
('Thu thập dữ liệu tài chính', 'Tổng hợp số liệu tài chính cả năm', '2024-12-20', 'Cao', 4, 9, 3, 'Trễ hạn'),
('Lập báo cáo chi tiết', 'Viết báo cáo tài chính chi tiết', '2024-12-25', 'Cao', 4, 4, 3, 'Chưa bắt đầu'),
('Kiểm toán nội bộ', 'Thực hiện kiểm toán số liệu', '2024-12-30', 'Cao', 4, 9, 3, 'Chưa bắt đầu'),

-- Công việc Phòng Kinh doanh (phong_ban_id = 4)
('Lên kế hoạch sự kiện', 'Lập kế hoạch tổ chức sự kiện', '2024-08-10', 'Cao', 5, 8, 4, 'Đang thực hiện'),
('Liên hệ khách mời', 'Gửi thư mời các khách hàng VIP', '2024-08-15', 'Trung bình', 5, 8, 4, 'Chưa bắt đầu'),
('Chuẩn bị demo sản phẩm', 'Chuẩn bị bản demo cho sự kiện', '2024-08-20', 'Cao', 5, 6, 4, 'Chưa bắt đầu');

-- Dữ liệu mẫu cho tiến độ công việc
INSERT INTO cong_viec_tien_do (cong_viec_id, nguoi_cap_nhat_id, phan_tram, ghi_chu)
VALUES
(1, 6, 100, 'Đã hoàn thành thiết kế giao diện theo yêu cầu'),
(2, 1, 70, 'Đã hoàn thành 70% giao diện lập trình, còn lại giao diện thanh toán'),
(5, 2, 100, 'Hoàn thành phân tích và tài liệu hóa yêu cầu'),
(6, 1, 100, 'Database đã được thiết kế và triển khai'),
(7, 6, 60, 'Đang phát triển các chức năng CRUD nhân viên'),
(8, 7, 30, 'Gặp khó khăn trong tích hợp thiết bị chấm công'),
(9, 6, 100, 'Kế hoạch content đã được duyệt'),
(10, 6, 80, 'Đã thiết kế 80% banner cần thiết'),
(13, 10, 100, 'Job description đã hoàn thành cho tất cả vị trí'),
(14, 10, 100, 'Đã đăng tin trên 5 trang tuyển dụng chính'),
(15, 2, 50, 'Đã sàn lọc 50% hồ sơ nhận được'),
(17, 9, 20, 'Mới bắt đầu thu thập dữ liệu từ các phòng ban'),
(20, 8, 75, 'Kế hoạch sự kiện đã cơ bản hoàn thành');

-- Dữ liệu mẫu cho chấm công (1 tháng gần nhất)
INSERT INTO cham_cong (nhan_vien_id, ngay, check_in, check_out)
VALUES
-- Tuần 1 tháng 7
(2, '2024-07-01', '08:00:00', '17:30:00'), (3, '2024-07-01', '08:15:00', '17:45:00'),
(4, '2024-07-01', '08:30:00', '17:00:00'), (5, '2024-07-01', '08:00:00', '18:00:00'),
(6, '2024-07-01', '08:45:00', '17:30:00'), (7, '2024-07-01', '08:00:00', '17:15:00'),
(8, '2024-07-01', '08:30:00', '17:30:00'), (9, '2024-07-01', '08:15:00', '17:00:00'),
(10, '2024-07-01', '08:00:00', '17:30:00'), (1, '2024-07-01', '08:30:00', '18:15:00'),

-- Tuần 2 tháng 7 (một số người nghỉ)
(2, '2024-07-08', '08:00:00', '17:30:00'), (3, '2024-07-08', '08:15:00', '17:45:00'),
(4, '2024-07-08', '08:30:00', '17:00:00'), (6, '2024-07-08', '08:45:00', '17:30:00'),
(7, '2024-07-08', '08:00:00', '17:15:00'), (8, '2024-07-08', '08:30:00', '17:30:00'),
(9, '2024-07-08', '08:15:00', '17:00:00'), (10, '2024-07-08', '08:00:00', '17:30:00'),
(1, '2024-07-08', '08:30:00', '18:15:00'),

-- Tuần 3 tháng 7 (một số người đi muộn)
(2, '2024-07-15', '08:30:00', '17:30:00'), (3, '2024-07-15', '09:00:00', '18:00:00'),
(4, '2024-07-15', '08:15:00', '17:00:00'), (5, '2024-07-15', '08:45:00', '18:30:00'),
(6, '2024-07-15', '08:00:00', '17:30:00'), (7, '2024-07-15', '09:15:00', '17:45:00'),
(8, '2024-07-15', '08:30:00', '17:30:00'), (9, '2024-07-15', '08:00:00', '17:00:00'),
(10, '2024-07-15', '08:45:00', '17:45:00'), (1, '2024-07-15', '08:30:00', '18:15:00'),

-- Tuần 4 tháng 7
(2, '2024-07-22', '08:00:00', '17:30:00'), (3, '2024-07-22', '08:15:00', '17:45:00'),
(4, '2024-07-22', '08:30:00', '17:00:00'), (5, '2024-07-22', '08:00:00', '18:00:00'),
(6, '2024-07-22', '08:45:00', '17:30:00'), (7, '2024-07-22', '08:00:00', '17:15:00'),
(8, '2024-07-22', '08:30:00', '17:30:00'), (9, '2024-07-22', '08:15:00', '17:00:00'),
(10, '2024-07-22', '08:00:00', '17:30:00'), (1, '2024-07-22', '08:30:00', '18:15:00');

-- Dữ liệu mẫu cho thông báo
INSERT INTO thong_bao (tieu_de, noi_dung, nguoi_nhan_id, loai_thong_bao, da_doc)
VALUES
('Công việc mới được giao', 'Bạn có công việc "Thiết kế giao diện trang chủ" được giao bởi Lê Văn Minh', 6, 'Công việc mới', TRUE),
('Hạn chót sắp tới', 'Công việc "Phát triển giao diện lập trình backend" sẽ đến hạn vào ngày 25/08/2024', 1, 'Hạn chót', FALSE),
('Công việc trễ hạn', 'Công việc "Phát triển module chấm công" đã trễ hạn', 7, 'Trễ hạn', FALSE),
('Lương tháng 7 đã được chuyển', 'Lương tháng 7/2024 đã được chuyển vào tài khoản của bạn', 2, 'Lương', TRUE),
('Họp phòng ban', 'Cuộc họp phòng ban Kỹ thuật vào 9h sáng mai', 6, 'Công việc mới', FALSE),
('Cập nhật tiến độ công việc', 'Vui lòng cập nhật tiến độ công việc "Sàn lọc hồ sơ ứng viên"', 2, 'Hạn chót', FALSE),
('Chúc mừng hoàn thành công việc', 'Chúc mừng bạn đã hoàn thành "Thiết kế database"', 1, 'Công việc mới', TRUE),
('Thông báo nghỉ phép', 'Đơn nghỉ phép của bạn đã được duyệt', 7, 'Công việc mới', TRUE),
('Đánh giá hiệu suất', 'Đến hạn đánh giá hiệu suất làm việc quý 2', 10, 'Hạn chót', FALSE),
('Sự kiện công ty', 'Thông báo tham gia sự kiện ra mắt sản phẩm mới', 8, 'Công việc mới', FALSE);

-- Dữ liệu mẫu cho lịch sử công việc
INSERT INTO cong_viec_lich_su (cong_viec_id, nguoi_thay_doi_id, mo_ta_thay_doi)
VALUES
(1, 3, 'Tạo công việc mới: Thiết kế giao diện trang chủ'),
(1, 6, 'Cập nhật tiến độ: 50%'),
(1, 6, 'Cập nhật tiến độ: 100% - Đã hoàn thành'),
(2, 3, 'Tạo công việc mới: Phát triển giao diện lập trình backend'),
(2, 1, 'Cập nhật tiến độ: 30%'),
(2, 1, 'Cập nhật tiến độ: 70%'),
(7, 3, 'Tạo công việc mới: Phát triển module nhân viên'),
(7, 6, 'Cập nhật tiến độ: 25%'),
(7, 6, 'Cập nhật tiến độ: 60%'),
(8, 3, 'Tạo công việc mới: Phát triển module chấm công'),
(8, 7, 'Cập nhật tiến độ: 10%'),
(8, 7, 'Báo cáo vấn đề: Khó khăn trong tích hợp thiết bị'),
(9, 8, 'Tạo công việc mới: Lập kế hoạch content'),
(9, 6, 'Cập nhật tiến độ: 100% - Đã hoàn thành'),
(15, 2, 'Tạo công việc mới: Sàn lọc hồ sơ ứng viên'),
(15, 2, 'Cập nhật tiến độ: 25%'),
(15, 2, 'Cập nhật tiến độ: 50%');

-- Dữ liệu mẫu cho đánh giá công việc
INSERT INTO cong_viec_danh_gia (cong_viec_id, nguoi_danh_gia_id, nhan_xet)
VALUES
(1, 3, 'Thiết kế đẹp, chuyên nghiệp, đúng yêu cầu và hạn chót'),
(5, 3, 'Phân tích kỹ lưỡng, tài liệu đầy đủ và chi tiết'),
(6, 3, 'Cơ sở dữ liệu được thiết kế tối ưu, tuân thủ chuẩn'),
(9, 8, 'Kế hoạch content sáng tạo và phù hợp với đối tượng mục tiêu'),
(13, 2, 'Job description đầy đủ thông tin, hấp dẫn ứng viên'),
(14, 2, 'Đăng tin hiệu quả trên nhiều kênh tuyển dụng'),
(7, 3, 'Tiến độ chậm hơn dự kiến nhưng chất lượng tốt'),
(10, 8, 'Banner thiết kế đẹp mắt, thu hút người xem'),
(20, 5, 'Kế hoạch chi tiết nhưng cần điều chỉnh một số điểm');

-- Dữ liệu mẫu cho báo cáo công việc
INSERT INTO bao_cao_cong_viec (loai_bao_cao, duong_dan, nguoi_tao_id)
VALUES
('TaskProgress', '/reports/task_progress_2024.pdf', 1),
('DepartmentPerformance', '/reports/dept_performance_q2.pdf', 1),
('EmployeeKPI', '/reports/employee_kpi_2024.pdf', 1),
('ProjectSummary', '/reports/project_summary_q2.pdf', 3),
('MonthlyReport', '/reports/monthly_july_2024.pdf', 1);

-- Dữ liệu mẫu cho lương chi tiết
INSERT INTO luong (nhan_vien_id, thang, nam, luong_co_ban, phu_cap, thuong, phat, bao_hiem, thue, luong_thuc_te, ghi_chu, trang_thai, ngay_tra_luong) VALUES
-- Tháng 6/2024
(1, 6, 2024, 15000000, 2000000, 500000, 0, 1500000, 720000, 15280000, 'Lương tháng 6', 'Đã trả', '2024-07-05'),
(2, 6, 2024, 12000000, 1500000, 400000, 0, 1200000, 560000, 12140000, 'Lương tháng 6', 'Đã trả', '2024-07-05'),
(3, 6, 2024, 10000000, 1200000, 300000, 0, 1000000, 410000, 10090000, 'Lương tháng 6', 'Đã trả', '2024-07-05'),
(4, 6, 2024, 8000000, 800000, 200000, 0, 800000, 320000, 7880000, 'Lương tháng 6', 'Đã trả', '2024-07-05'),
(5, 6, 2024, 7000000, 700000, 150000, 0, 700000, 270000, 6880000, 'Lương tháng 6', 'Đã trả', '2024-07-05'),
(6, 6, 2024, 9000000, 1000000, 350000, 0, 900000, 365000, 9085000, 'Lương tháng 6', 'Đã trả', '2024-07-05'),
(7, 6, 2024, 6500000, 650000, 100000, 50000, 650000, 245000, 6355000, 'Lương tháng 6, phạt đi muộn', 'Đã trả', '2024-07-05'),
(8, 6, 2024, 8500000, 900000, 300000, 0, 850000, 340000, 8510000, 'Lương tháng 6', 'Đã trả', '2024-07-05'),
(9, 6, 2024, 11000000, 1300000, 600000, 0, 1100000, 510000, 11290000, 'Lương tháng 6', 'Đã trả', '2024-07-05'),
(10, 6, 2024, 7500000, 750000, 200000, 0, 750000, 285000, 7415000, 'Lương tháng 6', 'Đã trả', '2024-07-05'),

-- Tháng 7/2024
(1, 7, 2024, 15000000, 2000000, 800000, 0, 1500000, 780000, 15520000, 'Lương tháng 7', 'Đã trả', '2024-08-05'),
(2, 7, 2024, 12000000, 1500000, 600000, 0, 1200000, 580000, 12320000, 'Lương tháng 7', 'Đã trả', '2024-08-05'),
(3, 7, 2024, 10000000, 1200000, 400000, 100000, 1000000, 420000, 10080000, 'Lương tháng 7, phạt đi muộn', 'Đã trả', '2024-08-05'),
(4, 7, 2024, 8000000, 800000, 300000, 0, 800000, 340000, 7960000, 'Lương tháng 7', 'Đã trả', '2024-08-05'),
(5, 7, 2024, 7000000, 700000, 250000, 50000, 700000, 290000, 6910000, 'Lương tháng 7, phạt vi phạm', 'Đã trả', '2024-08-05'),
(6, 7, 2024, 9000000, 1000000, 500000, 0, 900000, 380000, 9220000, 'Lương tháng 7', 'Đã trả', '2024-08-05'),
(7, 7, 2024, 6500000, 650000, 200000, 0, 650000, 260000, 6440000, 'Lương tháng 7', 'Đã trả', '2024-08-05'),
(8, 7, 2024, 8500000, 900000, 400000, 0, 850000, 350000, 8500000, 'Lương tháng 7', 'Đã trả', '2024-08-05'),
(9, 7, 2024, 11000000, 1300000, 700000, 0, 1100000, 520000, 11380000, 'Lương tháng 7', 'Đã trả', '2024-08-05'),
(10, 7, 2024, 7500000, 750000, 300000, 0, 750000, 300000, 7500000, 'Lương tháng 7', 'Đã trả', '2024-08-05'),

-- Tháng 8/2024 (dự kiến)
(1, 8, 2024, 15000000, 2000000, 1200000, 0, 1500000, 820000, 15880000, 'Lương tháng 8 + thưởng dự án', 'Chưa trả', NULL),
(2, 8, 2024, 12000000, 1500000, 800000, 200000, 1200000, 600000, 12300000, 'Lương tháng 8, phạt chất lượng', 'Chưa trả', NULL),
(3, 8, 2024, 10000000, 1200000, 500000, 0, 1000000, 450000, 10250000, 'Lương tháng 8', 'Chưa trả', NULL),
(4, 8, 2024, 8000000, 800000, 400000, 0, 800000, 360000, 8040000, 'Lương tháng 8', 'Chưa trả', NULL),
(5, 8, 2024, 7000000, 700000, 300000, 0, 700000, 310000, 6990000, 'Lương tháng 8', 'Chưa trả', NULL),
(6, 8, 2024, 9000000, 1000000, 600000, 0, 900000, 400000, 9300000, 'Lương tháng 8', 'Chưa trả', NULL),
(7, 8, 2024, 6500000, 650000, 250000, 0, 650000, 275000, 6475000, 'Lương tháng 8', 'Chưa trả', NULL),
(8, 8, 2024, 8500000, 900000, 500000, 0, 850000, 375000, 8675000, 'Lương tháng 8', 'Chưa trả', NULL),
(9, 8, 2024, 11000000, 1300000, 800000, 0, 1100000, 550000, 11450000, 'Lương tháng 8', 'Chưa trả', NULL),
(10, 8, 2024, 7500000, 750000, 350000, 0, 750000, 315000, 7535000, 'Lương tháng 8', 'Chưa trả', NULL);

-- Dữ liệu mẫu cho cấu hình lương
INSERT INTO luong_cau_hinh (ten_cau_hinh, gia_tri, mo_ta)
VALUES
('luong_co_ban_toi_thieu', '4420000', 'Lương cơ bản tối thiểu theo quy định'),
('he_so_bao_hiem', '10.5', 'Tỷ lệ % đóng bảo hiểm xã hội'),
('he_so_thue', '5', 'Tỷ lệ % thuế thu nhập cá nhân cơ bản'),
('phu_cap_an_trua', '30000', 'Phụ cấp ăn trua mỗi ngày (VND)'),
('phu_cap_xang_xe', '500000', 'Phụ cấp xăng xe hàng tháng (VND)'),
('thuong_hoan_thanh_du_an', '2000000', 'Thưởng hoàn thành dự án đúng hạn'),
('phat_di_muon', '50000', 'Phạt đi muộn mỗi lần (VND)'),
('phat_nghi_khong_phep', '200000', 'Phạt nghỉ không phép mỗi ngày (VND)');

-- Dữ liệu mẫu cho KPI nhân viên
INSERT INTO luu_kpi (nhan_vien_id, thang, nam, chi_tieu, ket_qua, diem_kpi, ghi_chu)
VALUES
-- KPI tháng 6/2024
(1, 6, 2024, 'Quản lý 3 dự án đúng tiến độ', 'Hoàn thành 100%', 9.5, 'Xuất sắc trong quản lý dự án'),
(2, 6, 2024, 'Tuyển dụng 5 nhân viên mới', 'Tuyển được 4 người', 8.0, 'Tốt, thiếu 1 người do yêu cầu cao'),
(3, 6, 2024, 'Phát triển 2 module mới', 'Hoàn thành 2 module', 9.0, 'Chất lượng mã nguồn tốt, đúng hạn chót'),
(6, 6, 2024, 'Cải thiện UI/UX 5 trang', 'Cải thiện 6 trang', 9.2, 'Vượt chỉ tiêu, thiết kế đẹp'),
(7, 6, 2024, 'Fix 50 bugs trong tháng', 'Fix được 45 bugs', 8.5, 'Gần đạt chỉ tiêu, chất lượng tốt'),

-- KPI tháng 7/2024
(1, 7, 2024, 'Quản lý 3 dự án đúng tiến độ', 'Hoàn thành 100%', 9.8, 'Xuất sắc, hoàn thành sớm hơn dự kiến'),
(2, 7, 2024, 'Tuyển dụng 3 nhân viên mới', 'Tuyển được 3 người', 9.0, 'Đạt 100% chỉ tiêu'),
(3, 7, 2024, 'Tối ưu hóa cơ sở dữ liệu', 'Cải thiện 30% hiệu suất', 8.8, 'Tốt, hiệu suất cải thiện đáng kể'),
(6, 7, 2024, 'Thiết kế 3 giao diện mới', 'Hoàn thành 3 giao diện', 9.1, 'Thiết kế sáng tạo, thân thiện với người dùng'),
(8, 7, 2024, 'Tổ chức 2 sự kiện marketing', 'Tổ chức thành công 2 sự kiện', 8.7, 'Sự kiện thu hút nhiều khách hàng');

-- Dữ liệu mẫu cho báo cáo công việc bổ sung
INSERT INTO bao_cao_cong_viec (loai_bao_cao, duong_dan, nguoi_tao_id)
VALUES
('PDF', '/reports/project_website_progress_202407.pdf', 3),
('Excel', '/reports/hr_recruitment_202407.xlsx', 2),
('PDF', '/reports/marketing_campaign_q2_2024.pdf', 8),
('Excel', '/reports/financial_summary_q2_2024.xlsx', 4),
('PDF', '/reports/employee_performance_202407.pdf', 2),
('Excel', '/reports/attendance_report_202407.xlsx', 9);

-- Dữ liệu mẫu cho file đính kèm
INSERT INTO file_dinh_kem (cong_viec_id, duong_dan_file, mo_ta)
VALUES
(1, '/uploads/homepage_mockup_v1.png', 'Mockup giao diện trang chủ phiên bản 1'),
(1, '/uploads/homepage_mockup_final.png', 'Mockup giao diện trang chủ phiên bản cuối'),
(2, '/uploads/api_documentation.pdf', 'Tài liệu đặc tả giao diện lập trình'),
(5, '/uploads/requirement_analysis.docx', 'Tài liệu phân tích yêu cầu chi tiết'),
(6, '/uploads/database_schema.sql', 'File script tạo cơ sở dữ liệu'),
(9, '/uploads/content_plan_q4.xlsx', 'Kế hoạch content marketing Q4'),
(10, '/uploads/banner_designs.zip', 'Bộ sưu tập banner thiết kế'),
(13, '/uploads/job_descriptions.pdf', 'Mô tả công việc các vị trí tuyển dụng');

-- Dữ liệu mẫu cho cấu hình lương bổ sung
INSERT INTO luong_cau_hinh (ten_cau_hinh, gia_tri, mo_ta)
VALUES
('muc_luong_co_ban_toi_thieu', '8000000', 'Mức lương cơ bản tối thiểu công ty'),
('luong_gio_lam_them', '50000', 'Lương làm thêm giờ (VND/giờ)'),
('he_so_kpi_cao', '1.2', 'Hệ số KPI cho nhân viên xuất sắc');

-- Dữ liệu mẫu cho KPI bổ sung
INSERT INTO luu_kpi (nhan_vien_id, thang, nam, chi_tieu, ket_qua, diem_kpi, ghi_chu)
VALUES
(6, 7, 2024, 'Thiết kế giao diện trang web chất lượng cao', 'Hoàn thành xuất sắc thiết kế trang chủ', 9.5, 'Thiết kế đẹp, đúng hạn chót'),
(1, 7, 2024, 'Phát triển giao diện lập trình hiệu quả', 'Hoàn thành 70% giao diện lập trình cần thiết', 8.0, 'Tiến độ tốt, chất lượng mã nguồn cao'),
(1, 7, 2024, 'Thiết kế cơ sở dữ liệu tối ưu', 'Cơ sở dữ liệu được thiết kế hoàn hảo', 9.8, 'Cấu trúc cơ sở dữ liệu xuất sắc'),
(8, 7, 2024, 'Lập kế hoạch content marketing', 'Kế hoạch chi tiết và sáng tạo', 8.5, 'Content phù hợp với đối tượng mục tiêu'),
(6, 7, 2024, 'Thiết kế banner quảng cáo', 'Banner đẹp mắt và thu hút', 8.2, 'Thiết kế sáng tạo, hiệu quả'),
(2, 7, 2024, 'Sàn lọc hồ sơ ứng viên chất lượng', 'Lọc được 50% hồ sơ phù hợp', 7.5, 'Tiêu chí lọc chính xác'),
(10, 7, 2024, 'Viết job description hấp dẫn', 'JD đầy đủ và thu hút ứng viên', 8.8, 'Mô tả công việc rõ ràng, hấp dẫn'),
(10, 7, 2024, 'Đăng tin tuyển dụng hiệu quả', 'Đăng tin trên 5 kênh chính', 8.0, 'Tiếp cận được nhiều ứng viên'),
(6, 7, 2024, 'Phát triển module quản lý nhân viên', 'Hoàn thành 60% chức năng', 7.2, 'Tiến độ ổn định, chức năng tốt'),
(7, 7, 2024, 'Phát triển module chấm công', 'Gặp khó khăn trong tích hợp', 6.0, 'Cần hỗ trợ thêm về kỹ thuật');

-- Dữ liệu mẫu cho lịch sử thay đổi nhân sự
INSERT INTO nhan_su_lich_su (nhan_vien_id, loai_thay_doi, gia_tri_cu, gia_tri_moi, nguoi_thay_doi_id, ghi_chu)
VALUES
(6, 'Chức vụ', 'Nhân viên', 'Lập trình viên', 1, 'Thăng chức do hiệu suất tốt'),
(7, 'Chức vụ', 'Intern', 'Lập trình viên', 1, 'Chuyển từ thực tập sang chính thức'),
(10, 'Phòng ban', 'Hành chính', 'Nhân sự', 2, 'Chuyển phòng ban phù hợp'),
(9, 'Trạng thái', 'Đang làm', 'Tạm nghỉ', 2, 'Nghỉ phép thai sản'),
(3, 'Lương cơ bản', '9000000', '10000000', 1, 'Tăng lương định kỳ'),
(6, 'Chức vụ', 'Lập trình viên', 'Senior Developer', 1, 'Thăng chức lên cấp cao'),
(8, 'Phòng ban', 'Marketing', 'Kinh doanh', 1, 'Chuyển phòng ban theo yêu cầu');

-- Dữ liệu mẫu cho phân quyền chức năng
INSERT INTO phan_quyen_chuc_nang (vai_tro, chuc_nang, co_quyen)
VALUES
-- Admin permissions
('Admin', 'TaoCongViec', TRUE), ('Admin', 'XoaCongViec', TRUE), ('Admin', 'SuaCongViec', TRUE),
('Admin', 'XemCongViec', TRUE), ('Admin', 'TaoNhanVien', TRUE), ('Admin', 'XoaNhanVien', TRUE),
('Admin', 'SuaNhanVien', TRUE), ('Admin', 'XemNhanVien', TRUE), ('Admin', 'TaoPhongBan', TRUE),
('Admin', 'XoaPhongBan', TRUE), ('Admin', 'SuaPhongBan', TRUE), ('Admin', 'XemPhongBan', TRUE),
('Admin', 'XemBaoCao', TRUE), ('Admin', 'XuatBaoCao', TRUE), ('Admin', 'QuanLyLuong', TRUE),
('Admin', 'QuanLyChamCong', TRUE), ('Admin', 'PhanQuyen', TRUE),

-- Manager permissions  
('Quản lý', 'TaoCongViec', TRUE), ('Quản lý', 'SuaCongViec', TRUE), ('Quản lý', 'XemCongViec', TRUE),
('Quản lý', 'XemNhanVien', TRUE), ('Quản lý', 'XemPhongBan', TRUE), ('Quản lý', 'XemBaoCao', TRUE),
('Quản lý', 'DanhGiaCongViec', TRUE), ('Quản lý', 'PhanCongCongViec', TRUE), ('Quản lý', 'XemLuong', TRUE),
('Quản lý', 'QuanLyChamCong', FALSE),

-- Employee permissions
('Nhân viên', 'XemCongViec', TRUE), ('Nhân viên', 'CapNhatTienDo', TRUE), ('Nhân viên', 'XemLuong', TRUE),
('Nhân viên', 'ChamCong', TRUE), ('Nhân viên', 'XemThongBao', TRUE), ('Nhân viên', 'CapNhatThongTin', TRUE),
('Nhân viên', 'TaoCongViec', FALSE), ('Nhân viên', 'XoaCongViec', FALSE), ('Nhân viên', 'XemBaoCao', FALSE);

-- Dữ liệu mẫu cho cấu hình hệ thống
INSERT INTO cau_hinh_he_thong (ten_cau_hinh, gia_tri, mo_ta)
VALUES
('company_name', 'CÔNG TY TNHH ICSS', 'Tên công ty'),
('company_address', '123 Đường ABC, Quận 1, TP.HCM', 'Địa chỉ công ty'),
('company_phone', '028-1234-5678', 'Số điện thoại công ty'),
('company_email', 'info@icss.com.vn', 'Email liên hệ công ty'),
('working_hours_start', '08:00', 'Giờ bắt đầu làm việc'),
('working_hours_end', '17:30', 'Giờ kết thúc làm việc'),
('late_penalty', '50000', 'Phạt đi muộn (VND/lần)'),
('overtime_rate', '1.5', 'Hệ số làm thêm giờ'),
('annual_leave_days', '12', 'Số ngày phép năm'),
('probation_period', '60', 'Thời gian thử việc (ngày)');

-- Dữ liệu mẫu cho quy trình công việc
INSERT INTO cong_viec_quy_trinh (cong_viec_id, ten_buoc, mo_ta, trang_thai, ngay_bat_dau, ngay_ket_thuc)
VALUES
-- Quy trình cho "Thiết kế giao diện trang chủ"
(1, 'Nghiên cứu yêu cầu', 'Tìm hiểu yêu cầu và mục tiêu thiết kế', 'Đã hoàn thành', '2024-07-01', '2024-07-03'),
(1, 'Tạo wireframe', 'Vẽ wireframe cho giao diện', 'Đã hoàn thành', '2024-07-04', '2024-07-06'),
(1, 'Thiết kế mockup', 'Thiết kế giao diện chi tiết', 'Đã hoàn thành', '2024-07-07', '2024-07-12'),
(1, 'Review và chỉnh sửa', 'Nhận feedback và chỉnh sửa', 'Đã hoàn thành', '2024-07-13', '2024-07-15'),

-- Quy trình cho "Phát triển giao diện lập trình backend"
(2, 'Thiết kế cấu trúc giao diện lập trình', 'Thiết kế cấu trúc giao diện lập trình', 'Đã hoàn thành', '2024-07-16', '2024-07-18'),
(2, 'Phát triển giao diện lập trình cơ bản', 'Lập trình các giao diện lập trình cơ bản', 'Đã hoàn thành', '2024-07-19', '2024-07-25'),
(2, 'Phát triển giao diện lập trình nâng cao', 'Lập trình các giao diện lập trình phức tạp', 'Đang thực hiện', '2024-07-26', NULL),
(2, 'Kiểm thử giao diện lập trình', 'Kiểm thử tất cả giao diện lập trình', 'Chưa bắt đầu', NULL, NULL),

-- Quy trình cho "Lập kế hoạch content"
(9, 'Phân tích đối tượng mục tiêu', 'Nghiên cứu đối tượng mục tiêu', 'Đã hoàn thành', '2024-07-01', '2024-07-02'),
(9, 'Lập content calendar', 'Tạo lịch đăng content', 'Đã hoàn thành', '2024-07-03', '2024-07-05'),
(9, 'Viết content outline', 'Tạo outline cho từng bài viết', 'Đã hoàn thành', '2024-07-06', '2024-07-08');

-- ===== DỮ LIỆU BỔ SUNG CHO CÁC THÁNG KHÁC =====

-- Thêm dữ liệu chấm công cho tháng 6
INSERT INTO cham_cong (nhan_vien_id, ngay, check_in, check_out)
SELECT nhan_vien_id, DATE_SUB(ngay, INTERVAL 1 MONTH), check_in, check_out 
FROM cham_cong 
WHERE ngay BETWEEN '2024-07-01' AND '2024-07-22';

-- Dữ liệu mẫu cho lịch sử nhân sự
INSERT INTO nhan_su_lich_su (nhan_vien_id, loai_thay_doi, gia_tri_cu, gia_tri_moi, nguoi_thay_doi_id, ghi_chu)
VALUES
-- Thay đổi lương
(3, 'Lương', '9500000', '10000000', 1, 'Tăng lương do thăng chức lên Senior Developer'),
(6, 'Lương', '8500000', '9000000', 1, 'Tăng lương định kỳ 6 tháng'),
(7, 'Lương', '6000000', '6500000', 1, 'Tăng lương sau thử việc'),
(10, 'Lương', '7000000', '7500000', 1, 'Điều chỉnh lương theo thị trường'),

-- Thay đổi chức vụ
(3, 'Chức vụ', 'Developer', 'Senior Developer', 1, 'Thăng chức do hiệu suất xuất sắc'),
(6, 'Chức vụ', 'Junior Designer', 'UI/UX Designer', 1, 'Thăng chức sau 1 năm làm việc'),
(8, 'Chức vụ', 'Marketing Assistant', 'Marketing Executive', 1, 'Thăng chức trong phòng Marketing'),

-- Thay đổi phòng ban
(7, 'Phòng ban', 'Phòng Kỹ thuật', 'Phòng Kỹ thuật', 1, 'Chuyển từ Junior sang chính thức'),
(10, 'Phòng ban', 'Phòng Kế toán', 'Phòng Kế toán', 1, 'Xác nhận sau thời gian thử việc'),

-- Thay đổi trạng thái
(5, 'Trạng thái', 'Thực việc', 'Chính thức', 1, 'Kết thúc thời gian thử việc thành công'),
(7, 'Trạng thái', 'Thực việc', 'Chính thức', 1, 'Chuyển sang nhân viên chính thức'),

-- Cập nhật thông tin cá nhân
(2, 'Số điện thoại', '0987654321', '0987654999', 2, 'Cập nhật số điện thoại mới'),
(4, 'Địa chỉ', '456 Đường DEF, Quận 3', '789 Đường GHI, Quận 7', 4, 'Chuyển nhà, cập nhật địa chỉ'),
(6, 'Email', 'designer@company.com', 'uiux.designer@company.com', 6, 'Cập nhật email theo chức vụ mới');

-- Dữ liệu mẫu cho permissions bổ sung
INSERT INTO phan_quyen_chuc_nang (vai_tro, chuc_nang, co_quyen) VALUES
-- Manager permissions bổ sung
('Quản lý', 'QuanLyNhanVien', TRUE), ('Quản lý', 'PhePhep', TRUE), ('Quản lý', 'XemBangLuong', TRUE),
('Quản lý', 'QuanLyKPI', TRUE), ('Quản lý', 'DanhGiaNhanVien', TRUE), ('Quản lý', 'TaoNhomCongViec', TRUE),
('Quản lý', 'PhanQuyenNhom', TRUE), ('Quản lý', 'XemThongKe', TRUE), ('Quản lý', 'XuatBaoCao', TRUE),

-- Team Lead permissions  
('Trưởng nhóm', 'QuanLyNhomCongViec', TRUE), ('Trưởng nhóm', 'PhanCongCongViec', TRUE), 
('Trưởng nhóm', 'DanhGiaCongViec', TRUE), ('Trưởng nhóm', 'XemTienDoNhom', TRUE),
('Trưởng nhóm', 'TaoSubTask', TRUE), ('Trưởng nhóm', 'QuanLyHanChot', TRUE),

-- Senior Employee permissions
('Nhân viên cấp cao', 'MentorJunior', TRUE), ('Nhân viên cấp cao', 'XemXetMaNguon', TRUE), ('Nhân viên cấp cao', 'DanhGiaKyThuat', TRUE),
('Nhân viên cấp cao', 'ThamGiaPhongVan', TRUE), ('Nhân viên cấp cao', 'TaoTaiLieu', TRUE);

-- Thêm sample data cho cấu hình hệ thống nâng cao
INSERT INTO cau_hinh_he_thong (ten_cau_hinh, gia_tri, mo_ta) VALUES
('backup_frequency', '24', 'Tần suất backup dữ liệu (giờ)'),
('session_timeout', '30', 'Thời gian timeout session (phút)'),
('max_file_upload', '10', 'Kích thước file upload tối đa (MB)'),
('email_smtp_server', 'smtp.gmail.com', 'Server SMTP gửi email'),
('email_smtp_port', '587', 'Port SMTP'),
('notification_enabled', 'true', 'Bật/tắt thông báo email'),
('maintenance_mode', 'false', 'Chế độ bảo trì hệ thống'),
('log_level', 'INFO', 'Mức độ ghi log'),
('password_min_length', '8', 'Độ dài mật khẩu tối thiểu'),
('max_login_attempts', '5', 'Số lần đăng nhập sai tối đa');

COMMIT;