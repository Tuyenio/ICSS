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

-- ============================================
-- PHẦN 2: DỮ LIỆU MẪU NĂM 2025 (PHÙ HỢP YÊU CẦU)
-- ============================================

-- 5 phòng ban
INSERT INTO phong_ban (ten_phong, ngay_tao) VALUES
('Phòng Nhân sự', NOW()),
('Phòng Kỹ thuật', NOW()),
('Phòng Kế toán', NOW()),
('Phòng Kinh doanh', NOW()),
('Phòng Marketing', NOW());

-- 9 nhân viên (1 Admin, 2 Quản lý, 6 Nhân viên)
INSERT INTO nhanvien (ho_ten, email, mat_khau, so_dien_thoai, gioi_tinh, ngay_sinh, phong_ban_id, chuc_vu, luong_co_ban, trang_thai_lam_viec, vai_tro, ngay_vao_lam, avatar_url) VALUES
('Lê Quốc Huy', 'huy.admin@icss.com.vn', 'password123', '0901123456', 'Nam', '1984-02-10', 2, 'Giám đốc CNTT', 20000000, 'Đang làm', 'Admin', '2019-05-01', NULL),
('Trần Thị Bích Ngọc', 'ngoc.hr@icss.com.vn', 'password123', '0902234567', 'Nữ', '1989-07-19', 1, 'Trưởng phòng Nhân sự', 14000000, 'Đang làm', 'Quản lý', '2020-03-10', NULL),
('Bùi Quang Dũng', 'dung.sales@icss.com.vn', 'password123', '0903345678', 'Nam', '1987-11-08', 4, 'Trưởng phòng Kinh doanh', 15000000, 'Đang làm', 'Quản lý', '2020-04-01', NULL),
('Nguyễn Minh Khôi', 'khoi.dev@icss.com.vn', 'password123', '0904456789', 'Nam', '1992-05-12', 2, 'Senior Developer', 12000000, 'Đang làm', 'Nhân viên', '2022-01-15', NULL),
('Phạm Thu Hà', 'ha.finance@icss.com.vn', 'password123', '0905567890', 'Nữ', '1993-09-21', 3, 'Kế toán viên', 9000000, 'Đang làm', 'Nhân viên', '2021-10-01', NULL),
('Vũ Anh Tuấn', 'tuan.backend@icss.com.vn', 'password123', '0906678901', 'Nam', '1995-12-03', 2, 'Backend Developer', 11000000, 'Đang làm', 'Nhân viên', '2023-02-20', NULL),
('Lý Ngọc Hân', 'han.marketing@icss.com.vn', 'password123', '0907789012', 'Nữ', '1996-03-18', 5, 'Marketing Executive', 9500000, 'Đang làm', 'Nhân viên', '2022-06-01', NULL),
('Đặng Hoàng Long', 'long.frontend@icss.com.vn', 'password123', '0908890123', 'Nam', '1994-08-27', 2, 'Frontend Developer', 10500000, 'Đang làm', 'Nhân viên', '2023-08-10', NULL),
('Ngô Thảo Linh', 'linh.hr@icss.com.vn', 'password123', '0909901234', 'Nữ', '1997-01-29', 1, 'HR Assistant', 8500000, 'Đang làm', 'Nhân viên', '2024-01-05', NULL);

-- Gán trưởng phòng
UPDATE phong_ban SET truong_phong_id = 2 WHERE id = 1; -- HR
UPDATE phong_ban SET truong_phong_id = 3 WHERE id = 4; -- Sales

-- Công việc (>=3 mỗi người trừ Admin), 2025
INSERT INTO cong_viec (ten_cong_viec, mo_ta, han_hoan_thanh, muc_do_uu_tien, nguoi_giao_id, nguoi_nhan_id, phong_ban_id, trang_thai) VALUES
-- id=4 Khôi
('Thiết kế API dịch vụ người dùng', 'Thiết kế và tài liệu hóa API User v2', '2025-07-25', 'Cao', 1, 4, 2, 'Đã hoàn thành'),
('Tối ưu truy vấn MySQL', 'Tối ưu index cho bảng cong_viec và cham_cong', '2025-08-05', 'Cao', 1, 4, 2, 'Đang thực hiện'),
('Viết unit test cho module auth', 'Bổ sung test bao phủ 80%', '2025-08-20', 'Trung bình', 2, 4, 2, 'Chưa bắt đầu'),
-- id=6 Tuấn
('Xây dựng dịch vụ chấm công', 'API checkin/checkout, tính giờ làm', '2025-07-30', 'Cao', 1, 6, 2, 'Đã hoàn thành'),
('Tích hợp JWT đa phiên', 'Cho phép refresh token an toàn', '2025-08-10', 'Cao', 4, 6, 2, 'Đang thực hiện'),
('Refactor module lương', 'Tách service và repository', '2025-08-18', 'Trung bình', 2, 6, 2, 'Chưa bắt đầu'),
-- id=8 Long
('Nâng cấp UI bảng Kanban', 'Kéo-thả, badge trạng thái, ưu tiên', '2025-07-28', 'Cao', 4, 8, 2, 'Đã hoàn thành'),
('Tối ưu bundle FE', 'Giảm kích thước JS, lazy load', '2025-08-08', 'Trung bình', 1, 8, 2, 'Đang thực hiện'),
('Sửa lỗi hiển thị thông báo', 'Fix badge chưa đọc, dropdown', '2025-08-15', 'Thấp', 2, 8, 2, 'Chưa bắt đầu'),
-- id=5 Hà
('Tổng hợp bảng lương tháng 7/2025', 'Đối soát và chốt lương', '2025-08-03', 'Cao', 1, 5, 3, 'Đã hoàn thành'),
('Lập báo cáo thuế TNCN', 'Tháng 8/2025', '2025-08-20', 'Trung bình', 1, 5, 3, 'Đang thực hiện'),
('Rà soát chứng từ chi phí', 'Kiểm tra hóa đơn quý III', '2025-09-05', 'Trung bình', 3, 5, 3, 'Chưa bắt đầu'),
-- id=7 Hân
('Kế hoạch chiến dịch Back-to-School', 'Xác định KPI và ngân sách', '2025-08-01', 'Cao', 3, 7, 5, 'Đã hoàn thành'),
('Thiết kế banner social', 'Facebook, LinkedIn, Zalo', '2025-08-12', 'Trung bình', 3, 7, 5, 'Đang thực hiện'),
('Viết blog series HR Tech', '3 bài viết dài', '2025-08-25', 'Thấp', 2, 7, 5, 'Chưa bắt đầu'),
-- id=9 Linh
('Tuyển dụng Backend Dev', '2 vị trí mid-level', '2025-07-31', 'Cao', 2, 9, 1, 'Đã hoàn thành'),
('Tổ chức onboarding 08/2025', 'Chuẩn bị tài liệu và lịch trình', '2025-08-09', 'Trung bình', 2, 9, 1, 'Đang thực hiện'),
('Cập nhật quy trình đánh giá', 'Template đánh giá quý III', '2025-08-22', 'Thấp', 2, 9, 1, 'Chưa bắt đầu'),
-- id=2 Ngọc (QL HR)
('Xây dựng khung năng lực', 'Cho các vị trí kỹ thuật', '2025-08-18', 'Cao', 1, 2, 1, 'Đang thực hiện'),
('Rà soát chính sách phúc lợi', 'Cập nhật phụ cấp, bảo hiểm', '2025-08-30', 'Trung bình', 1, 2, 1, 'Chưa bắt đầu'),
('Đánh giá hiệu suất tháng 7', 'Phản hồi cho nhân sự', '2025-08-05', 'Thấp', 1, 2, 1, 'Đã hoàn thành'),
-- id=3 Dũng (QL Sales)
('Ký HĐ với khách hàng ABC', 'Gói triển khai 12 tháng', '2025-08-07', 'Cao', 1, 3, 4, 'Đã hoàn thành'),
('Xây pipeline quý III', 'Dự báo doanh số', '2025-08-20', 'Cao', 1, 3, 4, 'Đang thực hiện'),
('Huấn luyện đội sales', 'Kịch bản demo sản phẩm', '2025-08-25', 'Trung bình', 1, 3, 4, 'Chưa bắt đầu');

-- Tiến độ công việc (đồng bộ trạng thái)
INSERT INTO cong_viec_tien_do (cong_viec_id, nguoi_cap_nhat_id, phan_tram, ghi_chu) VALUES
(1, 4, 100, 'Hoàn tất API và tài liệu'),
(2, 4, 60, 'Tối ưu chỉ mục, còn 2 query chậm'),
(4, 6, 100, 'Hoàn thành dịch vụ chấm công'),
(5, 6, 40, 'Luồng refresh token đang test'),
(7, 8, 100, 'Đã nâng cấp drag-drop và badge'),
(8, 8, 50, 'Đang cấu hình code splitting'),
(10, 5, 100, 'Đã chốt lương tháng 7/2025'),
(13, 7, 100, 'Chiến dịch đã duyệt'),
(16, 9, 100, 'Đã tuyển đủ 2 ứng viên'),
(19, 2, 100, 'Đã gửi phản hồi hiệu suất'),
(20, 3, 100, 'Hợp đồng đã ký 07/08/2025'),
(21, 3, 40, 'Đang tổng hợp dữ liệu');

-- Lịch sử công việc
INSERT INTO cong_viec_lich_su (cong_viec_id, nguoi_thay_doi_id, mo_ta_thay_doi) VALUES
(1, 1, 'Tạo công việc'),
(1, 4, 'Cập nhật tiến độ 50%'),
(1, 4, 'Hoàn thành công việc'),
(5, 6, 'Bắt đầu thực hiện'),
(7, 8, 'Triển khai nâng cấp UI'),
(10, 5, 'Đã chốt bảng lương'),
(13, 7, 'Hoàn thành kế hoạch'),
(20, 3, 'Ký hợp đồng với khách hàng ABC');

-- Đánh giá công việc
INSERT INTO cong_viec_danh_gia (cong_viec_id, nguoi_danh_gia_id, nhan_xet) VALUES
(1, 2, 'API rõ ràng, hiệu năng tốt'),
(4, 2, 'Dịch vụ ổn định, dễ bảo trì'),
(7, 3, 'UX mượt, tương tác tốt'),
(13, 3, 'Kế hoạch sáng tạo, bám KPI');

-- Chấm công 2025: tất cả trừ Admin (id 1)
INSERT INTO cham_cong (nhan_vien_id, ngay, check_in, check_out) VALUES
-- Tuần 1 (07/07 - 07/11)
(2,'2025-07-07','08:05:00','17:35:00'),(3,'2025-07-07','08:10:00','17:40:00'),(4,'2025-07-07','08:15:00','18:00:00'),(5,'2025-07-07','08:30:00','17:30:00'),(6,'2025-07-07','08:20:00','17:45:00'),(7,'2025-07-07','08:25:00','17:20:00'),(8,'2025-07-07','08:10:00','17:50:00'),(9,'2025-07-07','08:00:00','17:30:00'),
(2,'2025-07-08','08:00:00','17:30:00'),(3,'2025-07-08','08:10:00','17:40:00'),(4,'2025-07-08','08:05:00','18:05:00'),(5,'2025-07-08','08:35:00','17:25:00'),(6,'2025-07-08','08:25:00','17:40:00'),(7,'2025-07-08','08:30:00','17:25:00'),(8,'2025-07-08','08:15:00','17:45:00'),(9,'2025-07-08','08:00:00','17:30:00'),
(2,'2025-07-09','08:10:00','17:30:00'),(3,'2025-07-09','08:05:00','17:35:00'),(4,'2025-07-09','08:20:00','18:10:00'),(5,'2025-07-09','08:25:00','17:20:00'),(6,'2025-07-09','08:30:00','17:50:00'),(7,'2025-07-09','08:15:00','17:30:00'),(8,'2025-07-09','08:05:00','17:40:00'),(9,'2025-07-09','08:05:00','17:35:00'),
(2,'2025-07-10','08:00:00','17:30:00'),(3,'2025-07-10','08:25:00','17:50:00'),(4,'2025-07-10','08:40:00','18:20:00'),(5,'2025-07-10','08:35:00','17:25:00'),(6,'2025-07-10','08:10:00','17:30:00'),(7,'2025-07-10','08:00:00','17:10:00'),(8,'2025-07-10','08:20:00','17:45:00'),(9,'2025-07-10','08:15:00','17:45:00'),
(2,'2025-07-11','08:05:00','17:35:00'),(3,'2025-07-11','08:15:00','17:35:00'),(4,'2025-07-11','08:25:00','18:00:00'),(5,'2025-07-11','08:30:00','17:30:00'),(6,'2025-07-11','08:45:00','17:50:00'),(7,'2025-07-11','08:25:00','17:30:00'),(8,'2025-07-11','08:10:00','17:40:00'),(9,'2025-07-11','08:00:00','17:30:00'),
-- Tuần 2 (07/14 - 07/18)
(2,'2025-07-14','08:00:00','17:30:00'),(3,'2025-07-14','08:10:00','17:40:00'),(4,'2025-07-14','08:10:00','18:00:00'),(5,'2025-07-14','08:35:00','17:25:00'),(6,'2025-07-14','08:25:00','17:40:00'),(7,'2025-07-14','08:30:00','17:25:00'),(8,'2025-07-14','08:15:00','17:45:00'),(9,'2025-07-14','08:00:00','17:30:00'),
(2,'2025-07-15','08:05:00','17:35:00'),(3,'2025-07-15','08:15:00','17:45:00'),(4,'2025-07-15','08:30:00','18:15:00'),(5,'2025-07-15','08:25:00','17:20:00'),(6,'2025-07-15','08:30:00','17:50:00'),(7,'2025-07-15','08:15:00','17:30:00'),(8,'2025-07-15','08:05:00','17:40:00'),(9,'2025-07-15','08:05:00','17:35:00'),
(2,'2025-07-16','08:00:00','17:30:00'),(3,'2025-07-16','08:25:00','17:50:00'),(4,'2025-07-16','08:35:00','18:10:00'),(5,'2025-07-16','08:35:00','17:25:00'),(6,'2025-07-16','08:10:00','17:30:00'),(7,'2025-07-16','08:00:00','17:10:00'),(8,'2025-07-16','08:20:00','17:45:00'),(9,'2025-07-16','08:15:00','17:45:00'),
(2,'2025-07-17','08:05:00','17:35:00'),(3,'2025-07-17','08:15:00','17:35:00'),(4,'2025-07-17','08:25:00','18:00:00'),(5,'2025-07-17','08:30:00','17:30:00'),(6,'2025-07-17','08:45:00','17:50:00'),(7,'2025-07-17','08:25:00','17:30:00'),(8,'2025-07-17','08:10:00','17:40:00'),(9,'2025-07-17','08:00:00','17:30:00'),
(2,'2025-07-18','08:00:00','17:30:00'),(3,'2025-07-18','08:10:00','17:40:00'),(4,'2025-07-18','08:10:00','18:00:00'),(5,'2025-07-18','08:35:00','17:25:00'),(6,'2025-07-18','08:25:00','17:40:00'),(7,'2025-07-18','08:30:00','17:25:00'),(8,'2025-07-18','08:15:00','17:45:00'),(9,'2025-07-18','08:00:00','17:30:00');

-- Bổ sung thêm cho 2 nhân sự (id 4,6) để tổng thời gian > 1 tháng
INSERT INTO cham_cong (nhan_vien_id, ngay, check_in, check_out) VALUES
-- Tuần 3 (07/21 - 07/25)
(4,'2025-07-21','08:20:00','18:00:00'),(6,'2025-07-21','08:25:00','17:40:00'),
(4,'2025-07-22','08:25:00','18:05:00'),(6,'2025-07-22','08:30:00','17:45:00'),
(4,'2025-07-23','08:15:00','18:10:00'),(6,'2025-07-23','08:20:00','17:50:00'),
(4,'2025-07-24','08:35:00','18:15:00'),(6,'2025-07-24','08:10:00','17:35:00'),
(4,'2025-07-25','08:10:00','18:00:00'),(6,'2025-07-25','08:05:00','17:30:00'),
-- Tuần 4 (07/28 - 08/01)
(4,'2025-07-28','08:25:00','18:05:00'),(6,'2025-07-28','08:20:00','17:45:00'),
(4,'2025-07-29','08:30:00','18:00:00'),(6,'2025-07-29','08:25:00','17:40:00'),
(4,'2025-07-30','08:20:00','18:10:00'),(6,'2025-07-30','08:30:00','17:50:00'),
(4,'2025-07-31','08:35:00','18:20:00'),(6,'2025-07-31','08:15:00','17:45:00'),
(4,'2025-08-01','08:15:00','18:05:00'),(6,'2025-08-01','08:10:00','17:40:00'),
-- Tuần 1 tháng 8 (08/04 - 08/08)
(4,'2025-08-04','08:20:00','18:00:00'),(6,'2025-08-04','08:25:00','17:40:00'),
(4,'2025-08-05','08:25:00','18:05:00'),(6,'2025-08-05','08:30:00','17:45:00'),
(4,'2025-08-06','08:15:00','18:10:00'),(6,'2025-08-06','08:20:00','17:50:00'),
(4,'2025-08-07','08:35:00','18:15:00'),(6,'2025-08-07','08:10:00','17:35:00'),
(4,'2025-08-08','08:10:00','18:00:00'),(6,'2025-08-08','08:05:00','17:30:00');

-- Lương tháng 7 và 8/2025 cho tất cả trừ Admin (id=1)
INSERT INTO luong (nhan_vien_id, thang, nam, luong_co_ban, phu_cap, thuong, phat, bao_hiem, thue, luong_thuc_te, ghi_chu, trang_thai, ngay_tra_luong) VALUES
(2,7,2025,14000000,1500000,600000,0,1400000,650000,14100000,'Lương 07/2025','Đã trả','2025-08-05'),
(3,7,2025,15000000,1800000,800000,0,1500000,720000,15480000,'Lương 07/2025','Đã trả','2025-08-05'),
(4,7,2025,12000000,1200000,500000,0,1200000,540000,12260000,'Lương 07/2025','Đã trả','2025-08-05'),
(5,7,2025, 9000000, 900000,300000,0, 900000,360000, 9510000,'Lương 07/2025','Đã trả','2025-08-05'),
(6,7,2025,11000000,1100000,400000,0,1100000,500000,11400000,'Lương 07/2025','Đã trả','2025-08-05'),
(7,7,2025, 9500000, 900000,300000,0, 900000,350000, 9800000,'Lương 07/2025','Đã trả','2025-08-05'),
(8,7,2025,10500000,1000000,350000,0,1050000,470000,10880000,'Lương 07/2025','Đã trả','2025-08-05'),
(9,7,2025, 8500000, 800000,200000,0, 850000,320000, 8820000,'Lương 07/2025','Đã trả','2025-08-05'),
-- Tháng 8/2025 (chưa trả)
(2,8,2025,14000000,1500000,700000,0,1400000,680000,14220000,'Lương 08/2025','Chưa trả',NULL),
(3,8,2025,15000000,1800000,900000,0,1500000,730000,15770000,'Lương 08/2025','Chưa trả',NULL),
(4,8,2025,12000000,1200000,600000,0,1200000,560000,12340000,'Lương 08/2025','Chưa trả',NULL),
(5,8,2025, 9000000, 900000,350000,0, 900000,370000, 9570000,'Lương 08/2025','Chưa trả',NULL),
(6,8,2025,11000000,1100000,450000,0,1100000,510000,11490000,'Lương 08/2025','Chưa trả',NULL),
(7,8,2025, 9500000, 900000,350000,0, 900000,360000, 9840000,'Lương 08/2025','Chưa trả',NULL),
(8,8,2025,10500000,1000000,400000,0,1050000,480000,10920000,'Lương 08/2025','Chưa trả',NULL),
(9,8,2025, 8500000, 800000,250000,0, 850000,330000, 8850000,'Lương 08/2025','Chưa trả',NULL);

-- Thông báo
INSERT INTO thong_bao (tieu_de, noi_dung, nguoi_nhan_id, loai_thong_bao, da_doc) VALUES
('Công việc mới', 'Bạn được giao nhiệm vụ Tối ưu truy vấn MySQL', 4, 'Công việc mới', FALSE),
('Hạn chót gần kề', 'Hoàn thiện Tích hợp JWT đa phiên trước 10/08', 6, 'Hạn chót', FALSE),
('Lương đã chi trả', 'Lương tháng 07/2025 đã được chuyển', 5, 'Lương', TRUE);

-- Báo cáo công việc
INSERT INTO bao_cao_cong_viec (loai_bao_cao, duong_dan, nguoi_tao_id) VALUES
('TaskProgress', '/reports/task_progress_2025_07.pdf', 1),
('EmployeeKPI', '/reports/employee_kpi_2025_07.pdf', 2),
('DepartmentPerformance', '/reports/dept_performance_2025_q3.pdf', 3);

-- File đính kèm
INSERT INTO file_dinh_kem (cong_viec_id, duong_dan_file, mo_ta) VALUES
(1, '/uploads/api_user_v2.yaml', 'Tài liệu Swagger'),
(7, '/uploads/kanban_ui_mockup.png', 'Mockup UI Kanban'),
(10,'/uploads/bang_luong_2025_07.xlsx','Bảng lương tháng 7/2025');

-- Cấu hình lương
INSERT INTO luong_cau_hinh (ten_cau_hinh, gia_tri, mo_ta) VALUES
('luong_co_ban_toi_thieu', '5000000', 'Lương cơ bản tối thiểu (VND)'),
('he_so_bao_hiem', '10.5', 'Tỷ lệ % đóng BHXH'),
('he_so_thue', '5', 'Tỷ lệ % thuế TNCN cơ bản'),
('phu_cap_an_trua', '30000', 'Phụ cấp ăn trưa mỗi ngày (VND)');

-- KPI tháng 7 và 8/2025 cho tất cả trừ Admin (id=1)
INSERT INTO luu_kpi (nhan_vien_id, thang, nam, chi_tieu, ket_qua, diem_kpi, ghi_chu) VALUES
(2,7,2025,'Hoàn tất đánh giá hiệu suất tháng','Đã hoàn thành đúng hạn',9.2,'Quản lý tốt tiến độ'),
(3,7,2025,'Ký 1 hợp đồng mới','Đã ký HĐ ABC',9.0,'Doanh số đạt mục tiêu'),
(4,7,2025,'Bổ sung 50 unit test','Thêm 60 test',9.5,'Vượt chỉ tiêu'),
(5,7,2025,'Đối soát bảng lương 07/2025','Hoàn tất chính xác',9.0,'Không sai sót'),
(6,7,2025,'Hoàn thành dịch vụ chấm công','Đã bàn giao',9.3,'Chất lượng tốt'),
(7,7,2025,'Hoàn thiện kế hoạch Back-to-School','Đã duyệt',8.8,'Sáng tạo'),
(8,7,2025,'Nâng cấp UI Kanban','Đã release',9.1,'Trải nghiệm tốt'),
(9,7,2025,'Tuyển 2 backend dev','Đủ số lượng',9.0,'Đúng thời hạn'),
(2,8,2025,'Cập nhật chính sách phúc lợi','Đang thực hiện',7.5,'Đúng tiến độ'),
(3,8,2025,'Xây dựng pipeline Q3','Đang tổng hợp',7.8,'Cần thêm dữ liệu'),
(4,8,2025,'Tối ưu truy vấn','Đang làm',8.2,'Cải thiện 30%'),
(5,8,2025,'Báo cáo thuế TNCN','Đang làm',7.9,'Đúng quy định'),
(6,8,2025,'Tích hợp JWT đa phiên','Đang test',8.0,'Ổn định'),
(7,8,2025,'Thiết kế banner social','Đang triển khai',7.8,'Đúng guideline'),
(8,8,2025,'Tối ưu bundle FE','Đang làm',7.7,'Giảm 25% kích thước'),
(9,8,2025,'Onboarding 08/2025','Đang chuẩn bị',8.1,'Đủ tài liệu');

-- Lịch sử nhân sự
INSERT INTO nhan_su_lich_su (nhan_vien_id, loai_thay_doi, gia_tri_cu, gia_tri_moi, nguoi_thay_doi_id, ghi_chu) VALUES
(4,'Chức vụ','Developer','Senior Developer',1,'Thăng chức 07/2025'),
(7,'Phòng ban','Kinh doanh','Marketing',1,'Điều chuyển theo năng lực'),
(9,'Số điện thoại','0909800000','0909901234',2,'Cập nhật liên hệ');

-- Phân quyền
INSERT INTO phan_quyen_chuc_nang (vai_tro, chuc_nang, co_quyen) VALUES
('Admin','TaoCongViec',TRUE),('Admin','SuaCongViec',TRUE),('Admin','XoaCongViec',TRUE),('Admin','QuanLyLuong',TRUE),('Admin','QuanLyChamCong',TRUE),
('Quản lý','TaoCongViec',TRUE),('Quản lý','SuaCongViec',TRUE),('Quản lý','XemBaoCao',TRUE),('Quản lý','DanhGiaCongViec',TRUE),
('Nhân viên','XemCongViec',TRUE),('Nhân viên','CapNhatTienDo',TRUE),('Nhân viên','ChamCong',TRUE);

-- Cấu hình hệ thống
INSERT INTO cau_hinh_he_thong (ten_cau_hinh, gia_tri, mo_ta) VALUES
('company_name','CÔNG TY TNHH ICSS','Tên công ty'),
('working_hours_start','08:00','Giờ bắt đầu làm việc'),
('working_hours_end','17:30','Giờ kết thúc làm việc'),
('annual_leave_days','12','Số ngày phép năm');

-- Quy trình công việc
INSERT INTO cong_viec_quy_trinh (cong_viec_id, ten_buoc, mo_ta, trang_thai, ngay_bat_dau, ngay_ket_thuc) VALUES
(1,'Thiết kế API','Soạn thảo spec','Đã hoàn thành','2025-07-15','2025-07-18'),
(1,'Review','Phản biện giải pháp','Đã hoàn thành','2025-07-19','2025-07-20'),
(4,'Triển khai','Coding & test','Đã hoàn thành','2025-07-20','2025-07-28');

COMMIT;

-- ============================================
-- PHẦN 3: BỔ SUNG DỮ LIỆU 07-08/2025, HOÀN THIỆN QUY TRÌNH & CHẤM CÔNG
-- ============================================

-- 3.1 Bổ sung nhân sự quản lý để đủ Trưởng phòng cho tất cả phòng ban
-- Thêm Quản lý phòng Kế toán (dept 3) và Quản lý phòng Marketing (dept 5)
INSERT INTO nhanvien (ho_ten, email, mat_khau, so_dien_thoai, gioi_tinh, ngay_sinh, phong_ban_id, chuc_vu, luong_co_ban, trang_thai_lam_viec, vai_tro, ngay_vao_lam, avatar_url) VALUES
('Trần Hải Nam', 'nam.financelead@icss.com.vn', 'password123', '0912000111', 'Nam', '1986-04-18', 3, 'Kế toán trưởng', 13000000, 'Đang làm', 'Quản lý', '2021-02-01', NULL),
('Phạm Minh Anh', 'anh.mktlead@icss.com.vn', 'password123', '0913777666', 'Nữ', '1988-10-05', 5, 'Trưởng phòng Marketing', 13500000, 'Đang làm', 'Quản lý', '2020-09-15', NULL);

-- Sau khi thêm, các id mới sẽ là 10 (Nam) và 11 (Anh)
-- Cập nhật Trưởng phòng cho tất cả phòng ban: 1-HR, 2-Kỹ thuật, 3-Kế toán, 4-Kinh doanh, 5-Marketing
UPDATE phong_ban SET truong_phong_id = 2 WHERE id = 1;  -- HR: Trần Thị Bích Ngọc (Quản lý)
UPDATE phong_ban SET truong_phong_id = 1 WHERE id = 2;  -- Kỹ thuật: Lê Quốc Huy (Admin)
UPDATE phong_ban SET truong_phong_id = 10 WHERE id = 3; -- Kế toán: Trần Hải Nam (Quản lý)
UPDATE phong_ban SET truong_phong_id = 3 WHERE id = 4;  -- Kinh doanh: Bùi Quang Dũng (Quản lý)
UPDATE phong_ban SET truong_phong_id = 11 WHERE id = 5; -- Marketing: Phạm Minh Anh (Quản lý)

-- 3.2 Bổ sung công việc để tất cả phòng ban đều có đủ công việc (thêm mỗi phòng 1-2 việc)
INSERT INTO cong_viec (ten_cong_viec, mo_ta, han_hoan_thanh, muc_do_uu_tien, nguoi_giao_id, nguoi_nhan_id, phong_ban_id, trang_thai) VALUES
-- Phòng Nhân sự (1): giao bởi Ngọc (id=2), nhận: Linh (id=9)
('Cập nhật hồ sơ nhân sự số hóa', 'Chuẩn hóa hồ sơ HR lên hệ thống', '2025-08-18', 'Trung bình', 2, 9, 1, 'Đang thực hiện'),
('Kế hoạch đào tạo nội bộ Q3', 'Xây dựng lịch đào tạo tháng 9', '2025-08-28', 'Thấp', 2, 9, 1, 'Chưa bắt đầu'),
-- Phòng Kỹ thuật (2): giao bởi Huy (id=1), nhận: Khôi (4), Tuấn (6), Long (8)
('Chuẩn hóa logging toàn hệ thống', 'Áp dụng cấu trúc log và traceId', '2025-08-22', 'Cao', 1, 6, 2, 'Đang thực hiện'),
('Tối ưu cache layer', 'Thiết lập cache cho API tần suất cao', '2025-08-30', 'Trung bình', 1, 4, 2, 'Chưa bắt đầu'),
-- Phòng Kế toán (3): giao bởi Nam (id=10), nhận: Hà (5)
('Đối soát công nợ Q2', 'Đối chiếu công nợ khách hàng đến 06/2025', '2025-08-21', 'Cao', 10, 5, 3, 'Đang thực hiện'),
-- Phòng Kinh doanh (4): giao bởi Dũng (3), nhận: Dũng (3) hoặc nhân viên sales (tạm thời Dũng tự xử lý)
('Chuẩn bị proposal khách hàng XYZ', 'Đề xuất gói dịch vụ 6 tháng', '2025-08-19', 'Cao', 3, 3, 4, 'Đang thực hiện'),
-- Phòng Marketing (5): giao bởi Minh Anh (11), nhận: Hân (7)
('Lên lịch nội dung Social August', 'Lịch đăng bài cho toàn bộ kênh', '2025-08-16', 'Trung bình', 11, 7, 5, 'Đang thực hiện'),
('Tối ưu chiến dịch Ads', 'Điều chỉnh bidding & target', '2025-08-26', 'Cao', 11, 7, 5, 'Chưa bắt đầu');

-- 3.3 Thêm 2-3 bước quy trình cho MỌI công việc (id 1.. hiện tại; thêm bước chung để đủ số lượng)
-- Lưu ý: thêm bước bổ sung cả cho các task đã có bước trước đó
INSERT INTO cong_viec_quy_trinh (cong_viec_id, ten_buoc, mo_ta, trang_thai, ngay_bat_dau, ngay_ket_thuc) VALUES
-- Cho các công việc id 1..21 đã có
(1,'Kiểm thử tích hợp','Kiểm thử end-to-end','Đã hoàn thành','2025-07-21','2025-07-22'),
(2,'Phân tích','Đánh giá truy vấn chậm','Đang thực hiện','2025-08-01','2025-08-03'),
(2,'Thực hiện','Thêm index, tối ưu JOIN','Đang thực hiện','2025-08-03','2025-08-06'),
(2,'Kiểm thử','Benchmark lại','Chưa bắt đầu','2025-08-06','2025-08-08'),
(3,'Phân tích','Rà soát coverage','Chưa bắt đầu','2025-08-10','2025-08-12'),
(3,'Thực hiện','Viết test còn thiếu','Chưa bắt đầu','2025-08-12','2025-08-18'),
(4,'Nghiệm thu','Nghiệm thu với QA','Đã hoàn thành','2025-07-28','2025-07-29'),
(5,'Thiết kế','Thiết kế flow refresh','Đang thực hiện','2025-08-01','2025-08-04'),
(5,'Triển khai','Code & test','Đang thực hiện','2025-08-04','2025-08-09'),
(6,'Phân rã module','Tách service','Chưa bắt đầu','2025-08-12','2025-08-16'),
(7,'Nghiệm thu UI','UAT với PM','Đã hoàn thành','2025-07-27','2025-07-28'),
(8,'Đo đạc','Đo kích thước bundle','Đang thực hiện','2025-08-02','2025-08-05'),
(8,'Thực hiện','Cấu hình split','Đang thực hiện','2025-08-05','2025-08-08'),
(9,'Lập kế hoạch','Lên backlog fix','Chưa bắt đầu','2025-08-12','2025-08-14'),
(10,'Rà soát số liệu','Đối chiếu chênh lệch','Đã hoàn thành','2025-08-02','2025-08-03'),
(11,'Chuẩn bị tài liệu','Thu thập văn bản','Đang thực hiện','2025-08-10','2025-08-14'),
(12,'Rà soát chứng từ','Kiểm tra tính hợp lệ','Chưa bắt đầu','2025-08-20','2025-08-22'),
(13,'Họp kickoff','Thống nhất KPI','Đã hoàn thành','2025-07-28','2025-07-29'),
(14,'Thiết kế','Thiết kế banner','Đang thực hiện','2025-08-08','2025-08-12'),
(15,'Outline nội dung','Lên dàn ý 3 bài','Chưa bắt đầu','2025-08-15','2025-08-18'),
(16,'Phỏng vấn','Phỏng vấn ứng viên','Đã hoàn thành','2025-07-28','2025-07-31'),
(17,'Chuẩn bị tài liệu','Checklist onboarding','Đang thực hiện','2025-08-06','2025-08-08'),
(18,'Cập nhật template','Điều chỉnh form','Chưa bắt đầu','2025-08-15','2025-08-18'),
(19,'Thu thập dữ liệu','Tổng hợp minh chứng','Đã hoàn thành','2025-08-02','2025-08-03'),
(20,'Đàm phán','Thống nhất điều khoản','Đã hoàn thành','2025-08-05','2025-08-07'),
(21,'Chuẩn bị training','Agenda đào tạo','Đang thực hiện','2025-08-10','2025-08-15');

-- Bổ sung bước cho các công việc mới thêm ở mục 3.2
-- Giả sử các id mới tự tăng tiếp theo là 22..27 theo thứ tự chèn ở trên
INSERT INTO cong_viec_quy_trinh (cong_viec_id, ten_buoc, mo_ta, trang_thai, ngay_bat_dau, ngay_ket_thuc) VALUES
(22,'Phân tích','Kiểm tra trạng thái hồ sơ','Đang thực hiện','2025-08-10','2025-08-12'),
(22,'Thực hiện','Chuẩn hóa & upload','Đang thực hiện','2025-08-12','2025-08-16'),
(23,'Lên kế hoạch','Thu thập nhu cầu','Chưa bắt đầu','2025-08-20','2025-08-22'),
(24,'Thiết kế','Đặc tả log chuẩn','Đang thực hiện','2025-08-08','2025-08-12'),
(24,'Triển khai','Bổ sung traceId','Đang thực hiện','2025-08-12','2025-08-18'),
(25,'Đánh giá','Lựa chọn module cần cache','Chưa bắt đầu','2025-08-20','2025-08-22'),
(26,'Thu thập số liệu','Lấy SOA & đối chiếu','Đang thực hiện','2025-08-12','2025-08-18'),
(27,'Nghiên cứu','Thu thập yêu cầu','Đang thực hiện','2025-08-12','2025-08-16'),
(27,'Soạn thảo','Soạn proposal','Đang thực hiện','2025-08-16','2025-08-18'),
(28,'Lên lịch','Sắp lịch đăng bài','Đang thực hiện','2025-08-12','2025-08-14'),
(29,'Phân tích','Rà soát chiến dịch','Chưa bắt đầu','2025-08-20','2025-08-22');

-- 3.4 Mở rộng chấm công: toàn bộ tháng 7/2025 đến 12/08/2025 cho tất cả NV/QL (loại trừ Admin)
-- Dùng INSERT IGNORE để tránh trùng với dữ liệu đã có
-- Danh sách nhân viên cần chấm công: 2,3,4,5,6,7,8,9,10,11

-- Tháng 07/2025 (01..31), chỉ chấm ngày làm việc (t2..t6) với giờ check in/out hợp lý
-- Ở đây minh họa thêm một tập lớn; nếu đã có sẽ được IGNORE
INSERT IGNORE INTO cham_cong (nhan_vien_id, ngay, check_in, check_out) VALUES
-- 01/07 đến 04/07 cho tất cả
(2,'2025-07-01','08:10:00','17:40:00'),(3,'2025-07-01','08:20:00','17:45:00'),(4,'2025-07-01','08:05:00','18:00:00'),(5,'2025-07-01','08:25:00','17:30:00'),(6,'2025-07-01','08:15:00','17:50:00'),(7,'2025-07-01','08:20:00','17:20:00'),(8,'2025-07-01','08:10:00','17:40:00'),(9,'2025-07-01','08:15:00','17:35:00'),(10,'2025-07-01','08:05:00','17:35:00'),(11,'2025-07-01','08:10:00','17:40:00'),
(2,'2025-07-02','08:05:00','17:35:00'),(3,'2025-07-02','08:10:00','17:40:00'),(4,'2025-07-02','08:20:00','18:05:00'),(5,'2025-07-02','08:30:00','17:25:00'),(6,'2025-07-02','08:25:00','17:40:00'),(7,'2025-07-02','08:30:00','17:25:00'),(8,'2025-07-02','08:05:00','17:45:00'),(9,'2025-07-02','08:00:00','17:30:00'),(10,'2025-07-02','08:10:00','17:40:00'),(11,'2025-07-02','08:15:00','17:45:00'),
(2,'2025-07-03','08:00:00','17:30:00'),(3,'2025-07-03','08:10:00','17:40:00'),(4,'2025-07-03','08:15:00','18:10:00'),(5,'2025-07-03','08:35:00','17:25:00'),(6,'2025-07-03','08:10:00','17:30:00'),(7,'2025-07-03','08:00:00','17:10:00'),(8,'2025-07-03','08:20:00','17:45:00'),(9,'2025-07-03','08:05:00','17:35:00'),(10,'2025-07-03','08:10:00','17:40:00'),(11,'2025-07-03','08:20:00','17:50:00'),
(2,'2025-07-04','08:05:00','17:35:00'),(3,'2025-07-04','08:15:00','17:35:00'),(4,'2025-07-04','08:25:00','18:00:00'),(5,'2025-07-04','08:30:00','17:30:00'),(6,'2025-07-04','08:45:00','17:50:00'),(7,'2025-07-04','08:25:00','17:30:00'),(8,'2025-07-04','08:10:00','17:40:00'),(9,'2025-07-04','08:00:00','17:30:00'),(10,'2025-07-04','08:25:00','17:45:00'),(11,'2025-07-04','08:05:00','17:35:00');

-- Bổ sung tuần 3-4 tháng 07 cho tất cả (21..31), ngoại lệ: 4,6 đã có phần lớn -> vẫn dùng IGNORE
INSERT IGNORE INTO cham_cong (nhan_vien_id, ngay, check_in, check_out) VALUES
(2,'2025-07-21','08:05:00','17:35:00'),(3,'2025-07-21','08:15:00','17:45:00'),(5,'2025-07-21','08:30:00','17:20:00'),(7,'2025-07-21','08:25:00','17:25:00'),(8,'2025-07-21','08:10:00','17:40:00'),(9,'2025-07-21','08:10:00','17:30:00'),(10,'2025-07-21','08:20:00','17:40:00'),(11,'2025-07-21','08:15:00','17:45:00'),
(2,'2025-07-22','08:10:00','17:40:00'),(3,'2025-07-22','08:20:00','17:40:00'),(5,'2025-07-22','08:25:00','17:25:00'),(7,'2025-07-22','08:10:00','17:20:00'),(8,'2025-07-22','08:05:00','17:45:00'),(9,'2025-07-22','08:00:00','17:30:00'),(10,'2025-07-22','08:25:00','17:40:00'),(11,'2025-07-22','08:30:00','17:25:00'),
(2,'2025-07-23','08:00:00','17:30:00'),(3,'2025-07-23','08:25:00','17:50:00'),(5,'2025-07-23','08:35:00','17:25:00'),(7,'2025-07-23','08:00:00','17:10:00'),(8,'2025-07-23','08:20:00','17:45:00'),(9,'2025-07-23','08:05:00','17:35:00'),(10,'2025-07-23','08:30:00','17:50:00'),(11,'2025-07-23','08:10:00','17:40:00'),
(2,'2025-07-24','08:05:00','17:35:00'),(3,'2025-07-24','08:15:00','17:35:00'),(5,'2025-07-24','08:30:00','17:30:00'),(7,'2025-07-24','08:45:00','17:50:00'),(8,'2025-07-24','08:10:00','17:40:00'),(9,'2025-07-24','08:00:00','17:30:00'),(10,'2025-07-24','08:25:00','17:45:00'),(11,'2025-07-24','08:35:00','17:25:00'),
(2,'2025-07-25','08:00:00','17:30:00'),(3,'2025-07-25','08:10:00','17:40:00'),(5,'2025-07-25','08:25:00','17:20:00'),(7,'2025-07-25','08:25:00','17:25:00'),(8,'2025-07-25','08:05:00','17:45:00'),(9,'2025-07-25','08:15:00','17:35:00'),(10,'2025-07-25','08:10:00','17:40:00'),(11,'2025-07-25','08:20:00','17:50:00'),
(2,'2025-07-28','08:10:00','17:40:00'),(3,'2025-07-28','08:20:00','17:45:00'),(5,'2025-07-28','08:25:00','17:25:00'),(7,'2025-07-28','08:20:00','17:20:00'),(8,'2025-07-28','08:10:00','17:40:00'),(9,'2025-07-28','08:15:00','17:35:00'),(10,'2025-07-28','08:05:00','17:35:00'),(11,'2025-07-28','08:10:00','17:40:00'),
(2,'2025-07-29','08:05:00','17:35:00'),(3,'2025-07-29','08:10:00','17:40:00'),(5,'2025-07-29','08:30:00','17:30:00'),(7,'2025-07-29','08:30:00','17:25:00'),(8,'2025-07-29','08:05:00','17:45:00'),(9,'2025-07-29','08:00:00','17:30:00'),(10,'2025-07-29','08:10:00','17:40:00'),(11,'2025-07-29','08:15:00','17:45:00'),
(2,'2025-07-30','08:00:00','17:30:00'),(3,'2025-07-30','08:25:00','17:50:00'),(5,'2025-07-30','08:35:00','17:25:00'),(7,'2025-07-30','08:00:00','17:10:00'),(8,'2025-07-30','08:20:00','17:45:00'),(9,'2025-07-30','08:05:00','17:35:00'),(10,'2025-07-30','08:25:00','17:45:00'),(11,'2025-07-30','08:10:00','17:40:00'),
(2,'2025-07-31','08:05:00','17:35:00'),(3,'2025-07-31','08:15:00','17:35:00'),(5,'2025-07-31','08:30:00','17:30:00'),(7,'2025-07-31','08:45:00','17:50:00'),(8,'2025-07-31','08:10:00','17:40:00'),(9,'2025-07-31','08:00:00','17:30:00'),(10,'2025-07-31','08:25:00','17:45:00'),(11,'2025-07-31','08:35:00','17:25:00');

-- Tháng 08/2025 (01..12) cho tất cả NV/QL (một số đã có -> IGNORE)
INSERT IGNORE INTO cham_cong (nhan_vien_id, ngay, check_in, check_out) VALUES
(2,'2025-08-01','08:10:00','17:40:00'),(3,'2025-08-01','08:20:00','17:45:00'),(5,'2025-08-01','08:30:00','17:30:00'),(7,'2025-08-01','08:20:00','17:20:00'),(8,'2025-08-01','08:10:00','17:40:00'),(9,'2025-08-01','08:15:00','17:35:00'),(10,'2025-08-01','08:05:00','17:35:00'),(11,'2025-08-01','08:10:00','17:40:00'),
(2,'2025-08-04','08:05:00','17:35:00'),(3,'2025-08-04','08:10:00','17:40:00'),(5,'2025-08-04','08:25:00','17:25:00'),(7,'2025-08-04','08:30:00','17:25:00'),(8,'2025-08-04','08:05:00','17:45:00'),(9,'2025-08-04','08:00:00','17:30:00'),(10,'2025-08-04','08:15:00','17:45:00'),(11,'2025-08-04','08:20:00','17:40:00'),
(2,'2025-08-05','08:00:00','17:30:00'),(3,'2025-08-05','08:25:00','17:50:00'),(5,'2025-08-05','08:35:00','17:25:00'),(7,'2025-08-05','08:00:00','17:10:00'),(8,'2025-08-05','08:20:00','17:45:00'),(9,'2025-08-05','08:05:00','17:35:00'),(10,'2025-08-05','08:25:00','17:45:00'),(11,'2025-08-05','08:10:00','17:40:00'),
(2,'2025-08-06','08:05:00','17:35:00'),(3,'2025-08-06','08:15:00','17:35:00'),(5,'2025-08-06','08:30:00','17:30:00'),(7,'2025-08-06','08:45:00','17:50:00'),(8,'2025-08-06','08:10:00','17:40:00'),(9,'2025-08-06','08:00:00','17:30:00'),(10,'2025-08-06','08:20:00','17:50:00'),(11,'2025-08-06','08:15:00','17:45:00'),
(2,'2025-08-07','08:10:00','17:40:00'),(3,'2025-08-07','08:20:00','17:45:00'),(5,'2025-08-07','08:25:00','17:25:00'),(7,'2025-08-07','08:10:00','17:20:00'),(8,'2025-08-07','08:05:00','17:45:00'),(9,'2025-08-07','08:10:00','17:30:00'),(10,'2025-08-07','08:25:00','17:40:00'),(11,'2025-08-07','08:30:00','17:25:00'),
(2,'2025-08-08','08:00:00','17:30:00'),(3,'2025-08-08','08:25:00','17:50:00'),(5,'2025-08-08','08:35:00','17:25:00'),(7,'2025-08-08','08:00:00','17:10:00'),(8,'2025-08-08','08:20:00','17:45:00'),(9,'2025-08-08','08:05:00','17:35:00'),(10,'2025-08-08','08:20:00','17:50:00'),(11,'2025-08-08','08:10:00','17:40:00'),
(2,'2025-08-11','08:05:00','17:35:00'),(3,'2025-08-11','08:15:00','17:45:00'),(4,'2025-08-11','08:15:00','18:00:00'),(5,'2025-08-11','08:25:00','17:20:00'),(6,'2025-08-11','08:10:00','17:50:00'),(7,'2025-08-11','08:25:00','17:25:00'),(8,'2025-08-11','08:05:00','17:45:00'),(9,'2025-08-11','08:10:00','17:30:00'),(10,'2025-08-11','08:25:00','17:45:00'),(11,'2025-08-11','08:35:00','17:25:00'),
(2,'2025-08-12','08:10:00','17:40:00'),(3,'2025-08-12','08:20:00','17:45:00'),(4,'2025-08-12','08:05:00','18:05:00'),(5,'2025-08-12','08:30:00','17:30:00'),(6,'2025-08-12','08:25:00','17:40:00'),(7,'2025-08-12','08:30:00','17:25:00'),(8,'2025-08-12','08:05:00','17:45:00'),(9,'2025-08-12','08:00:00','17:30:00'),(10,'2025-08-12','08:10:00','17:40:00'),(11,'2025-08-12','08:15:00','17:45:00');

-- 3.5 Bổ sung bảng lương cho 2 quản lý mới (tháng 7 và 8/2025)
INSERT INTO luong (nhan_vien_id, thang, nam, luong_co_ban, phu_cap, thuong, phat, bao_hiem, thue, luong_thuc_te, ghi_chu, trang_thai, ngay_tra_luong) VALUES
(10,7,2025,13000000,1200000,500000,0,1300000,600000,13300000,'Lương 07/2025','Đã trả','2025-08-05'),
(11,7,2025,13500000,1300000,600000,0,1350000,650000,13750000,'Lương 07/2025','Đã trả','2025-08-05'),
(10,8,2025,13000000,1200000,550000,0,1300000,610000,13390000,'Lương 08/2025','Chưa trả',NULL),
(11,8,2025,13500000,1300000,650000,0,1350000,660000,13840000,'Lương 08/2025','Chưa trả',NULL);

-- 3.6 Bổ sung thông báo hợp lý theo công việc & lương
INSERT INTO thong_bao (tieu_de, noi_dung, nguoi_nhan_id, loai_thong_bao, da_doc, ngay_doc) VALUES
('Nhắc việc', 'Hoàn thành "Chuẩn hóa logging toàn hệ thống" trước 22/08', 6, 'Hạn chót', FALSE, NULL),
('Nhắc việc', 'Kiểm thử "Tối ưu bundle FE" trước 08/08', 8, 'Hạn chót', TRUE, '2025-08-06 09:00:00'),
('Thông báo lương', 'Đã trả lương tháng 07/2025', 10, 'Lương', TRUE, '2025-08-05 15:00:00'),
('Thông báo lương', 'Đã trả lương tháng 07/2025', 11, 'Lương', TRUE, '2025-08-05 15:00:00'),
('Công việc mới', 'Bạn được giao "Lên lịch nội dung Social August"', 7, 'Công việc mới', FALSE, NULL);

-- 3.7 Đồng bộ tiến độ cho các công việc mới thêm (một vài bản ghi)
INSERT INTO cong_viec_tien_do (cong_viec_id, nguoi_cap_nhat_id, phan_tram, ghi_chu) VALUES
(22, 9, 40, 'Đang số hóa 30% hồ sơ'),
(24, 6, 30, 'Đã thống nhất format log'),
(26,10, 50, 'Đối chiếu công nợ tháng 4/2025 xong'),
(28,11, 60, 'Đã chốt lịch nội dung tuần 2');

COMMIT;

-- 3.3b Bổ sung đảm bảo mọi công việc có tối thiểu 2-3 bước quy trình
-- Thêm Bước 1 cho các công việc chưa có bước nào
INSERT INTO cong_viec_quy_trinh (cong_viec_id, ten_buoc, mo_ta, trang_thai, ngay_bat_dau, ngay_ket_thuc)
SELECT cv.id, 'Bước 1: Phân tích', 'Xác định yêu cầu & phạm vi', 'Chưa bắt đầu', '2025-07-10', '2025-07-12'
FROM cong_viec cv
LEFT JOIN (
    SELECT cong_viec_id, COUNT(*) AS cnt FROM cong_viec_quy_trinh GROUP BY cong_viec_id
) q ON q.cong_viec_id = cv.id
WHERE IFNULL(q.cnt, 0) = 0;

-- Thêm Bước 2 cho các công việc có < 2 bước
INSERT INTO cong_viec_quy_trinh (cong_viec_id, ten_buoc, mo_ta, trang_thai, ngay_bat_dau, ngay_ket_thuc)
SELECT cv.id, 'Bước 2: Thực hiện', 'Phát triển/triển khai theo kế hoạch', 'Chưa bắt đầu', '2025-07-13', '2025-07-18'
FROM cong_viec cv
LEFT JOIN (
    SELECT cong_viec_id, COUNT(*) AS cnt FROM cong_viec_quy_trinh GROUP BY cong_viec_id
) q ON q.cong_viec_id = cv.id
WHERE IFNULL(q.cnt, 0) < 2;

-- Thêm Bước 3 cho các công việc có < 3 bước (đảm bảo tối thiểu 3 nếu cần)
INSERT INTO cong_viec_quy_trinh (cong_viec_id, ten_buoc, mo_ta, trang_thai, ngay_bat_dau, ngay_ket_thuc)
SELECT cv.id, 'Bước 3: Kiểm thử/Nghiệm thu', 'Kiểm thử, UAT, nghiệm thu', 'Chưa bắt đầu', '2025-07-19', '2025-07-22'
FROM cong_viec cv
LEFT JOIN (
    SELECT cong_viec_id, COUNT(*) AS cnt FROM cong_viec_quy_trinh GROUP BY cong_viec_id
) q ON q.cong_viec_id = cv.id
WHERE IFNULL(q.cnt, 0) < 3;

COMMIT;

-- 3.4b Bổ sung chấm công còn thiếu tháng 07/2025 (tuần 2 và 3) cho tất cả NV/QL
-- Các ngày làm việc: 07/07..07/11 và 07/14..07/18
INSERT IGNORE INTO cham_cong (nhan_vien_id, ngay, check_in, check_out) VALUES
-- Tuần 2 (07/07 - 07/11)
(2,'2025-07-07','08:12:00','17:42:00'),(3,'2025-07-07','08:18:00','17:45:00'),(4,'2025-07-07','08:05:00','18:00:00'),(5,'2025-07-07','08:28:00','17:25:00'),(6,'2025-07-07','08:10:00','17:50:00'),(7,'2025-07-07','08:22:00','17:20:00'),(8,'2025-07-07','08:08:00','17:38:00'),(9,'2025-07-07','08:14:00','17:34:00'),(10,'2025-07-07','08:06:00','17:36:00'),(11,'2025-07-07','08:10:00','17:40:00'),
(2,'2025-07-08','08:10:00','17:40:00'),(3,'2025-07-08','08:20:00','17:40:00'),(4,'2025-07-08','08:18:00','18:05:00'),(5,'2025-07-08','08:30:00','17:25:00'),(6,'2025-07-08','08:20:00','17:40:00'),(7,'2025-07-08','08:30:00','17:25:00'),(8,'2025-07-08','08:06:00','17:46:00'),(9,'2025-07-08','08:01:00','17:31:00'),(10,'2025-07-08','08:11:00','17:41:00'),(11,'2025-07-08','08:16:00','17:46:00'),
(2,'2025-07-09','08:02:00','17:32:00'),(3,'2025-07-09','08:12:00','17:42:00'),(4,'2025-07-09','08:17:00','18:10:00'),(5,'2025-07-09','08:34:00','17:24:00'),(6,'2025-07-09','08:08:00','17:28:00'),(7,'2025-07-09','08:02:00','17:12:00'),(8,'2025-07-09','08:18:00','17:43:00'),(9,'2025-07-09','08:06:00','17:36:00'),(10,'2025-07-09','08:12:00','17:42:00'),(11,'2025-07-09','08:22:00','17:52:00'),
(2,'2025-07-10','08:06:00','17:36:00'),(3,'2025-07-10','08:16:00','17:36:00'),(4,'2025-07-10','08:26:00','18:00:00'),(5,'2025-07-10','08:31:00','17:31:00'),(6,'2025-07-10','08:46:00','17:51:00'),(7,'2025-07-10','08:27:00','17:31:00'),(8,'2025-07-10','08:11:00','17:41:00'),(9,'2025-07-10','08:02:00','17:32:00'),(10,'2025-07-10','08:26:00','17:46:00'),(11,'2025-07-10','08:06:00','17:36:00'),
(2,'2025-07-11','08:01:00','17:31:00'),(3,'2025-07-11','08:11:00','17:41:00'),(4,'2025-07-11','08:27:00','18:02:00'),(5,'2025-07-11','08:26:00','17:21:00'),(6,'2025-07-11','08:26:00','17:46:00'),(7,'2025-07-11','08:26:00','17:26:00'),(8,'2025-07-11','08:06:00','17:46:00'),(9,'2025-07-11','08:16:00','17:36:00'),(10,'2025-07-11','08:11:00','17:41:00'),(11,'2025-07-11','08:21:00','17:51:00');

INSERT IGNORE INTO cham_cong (nhan_vien_id, ngay, check_in, check_out) VALUES
-- Tuần 3 (07/14 - 07/18)
(2,'2025-07-14','08:09:00','17:39:00'),(3,'2025-07-14','08:19:00','17:44:00'),(4,'2025-07-14','08:04:00','18:01:00'),(5,'2025-07-14','08:29:00','17:24:00'),(6,'2025-07-14','08:09:00','17:49:00'),(7,'2025-07-14','08:21:00','17:19:00'),(8,'2025-07-14','08:09:00','17:39:00'),(9,'2025-07-14','08:13:00','17:33:00'),(10,'2025-07-14','08:07:00','17:37:00'),(11,'2025-07-14','08:11:00','17:41:00'),
(2,'2025-07-15','08:08:00','17:38:00'),(3,'2025-07-15','08:18:00','17:43:00'),(4,'2025-07-15','08:16:00','18:06:00'),(5,'2025-07-15','08:28:00','17:23:00'),(6,'2025-07-15','08:18:00','17:38:00'),(7,'2025-07-15','08:28:00','17:23:00'),(8,'2025-07-15','08:07:00','17:47:00'),(9,'2025-07-15','08:02:00','17:32:00'),(10,'2025-07-15','08:12:00','17:42:00'),(11,'2025-07-15','08:17:00','17:47:00'),
(2,'2025-07-16','08:03:00','17:33:00'),(3,'2025-07-16','08:13:00','17:43:00'),(4,'2025-07-16','08:18:00','18:11:00'),(5,'2025-07-16','08:33:00','17:23:00'),(6,'2025-07-16','08:09:00','17:29:00'),(7,'2025-07-16','08:03:00','17:13:00'),(8,'2025-07-16','08:19:00','17:44:00'),(9,'2025-07-16','08:07:00','17:37:00'),(10,'2025-07-16','08:13:00','17:43:00'),(11,'2025-07-16','08:23:00','17:53:00'),
(2,'2025-07-17','08:07:00','17:37:00'),(3,'2025-07-17','08:17:00','17:37:00'),(4,'2025-07-17','08:27:00','18:01:00'),(5,'2025-07-17','08:32:00','17:32:00'),(6,'2025-07-17','08:47:00','17:52:00'),(7,'2025-07-17','08:27:00','17:32:00'),(8,'2025-07-17','08:12:00','17:42:00'),(9,'2025-07-17','08:03:00','17:33:00'),(10,'2025-07-17','08:27:00','17:47:00'),(11,'2025-07-17','08:07:00','17:37:00'),
(2,'2025-07-18','08:02:00','17:32:00'),(3,'2025-07-18','08:12:00','17:42:00'),(4,'2025-07-18','08:28:00','18:03:00'),(5,'2025-07-18','08:27:00','17:22:00'),(6,'2025-07-18','08:27:00','17:47:00'),(7,'2025-07-18','08:27:00','17:27:00'),(8,'2025-07-18','08:07:00','17:47:00'),(9,'2025-07-18','08:17:00','17:37:00'),(10,'2025-07-18','08:12:00','17:42:00'),(11,'2025-07-18','08:22:00','17:52:00');

COMMIT;

-- 3.5b Đảm bảo bảng lương đầy đủ cho tất cả NV/QL (tháng 7 và 8/2025) nếu chưa có
-- Ghi chú: tính phúc lợi và khấu trừ cơ bản dựa trên lương cơ bản; không tạo bản ghi trùng
INSERT INTO luong (nhan_vien_id, thang, nam, luong_co_ban, phu_cap, thuong, phat, bao_hiem, thue, luong_thuc_te, ghi_chu, trang_thai, ngay_tra_luong)
SELECT n.id, 7, 2025,
             n.luong_co_ban,
             1000000 AS phu_cap,
             500000 AS thuong,
             0 AS phat,
             ROUND(n.luong_co_ban * 0.105) AS bao_hiem,
             ROUND(n.luong_co_ban * 0.05) AS thue,
             (n.luong_co_ban + 1000000 + 500000 - 0 - ROUND(n.luong_co_ban * 0.105) - ROUND(n.luong_co_ban * 0.05)) AS luong_thuc_te,
             'Lương 07/2025' AS ghi_chu,
             'Đã trả' AS trang_thai,
             '2025-08-05' AS ngay_tra_luong
FROM nhanvien n
WHERE n.vai_tro IN ('Nhân viên','Quản lý')
    AND NOT EXISTS (
        SELECT 1 FROM luong l WHERE l.nhan_vien_id = n.id AND l.thang = 7 AND l.nam = 2025
    );

INSERT INTO luong (nhan_vien_id, thang, nam, luong_co_ban, phu_cap, thuong, phat, bao_hiem, thue, luong_thuc_te, ghi_chu, trang_thai, ngay_tra_luong)
SELECT n.id, 8, 2025,
             n.luong_co_ban,
             1000000 AS phu_cap,
             600000 AS thuong,
             0 AS phat,
             ROUND(n.luong_co_ban * 0.105) AS bao_hiem,
             ROUND(n.luong_co_ban * 0.05) AS thue,
             (n.luong_co_ban + 1000000 + 600000 - 0 - ROUND(n.luong_co_ban * 0.105) - ROUND(n.luong_co_ban * 0.05)) AS luong_thuc_te,
             'Lương 08/2025' AS ghi_chu,
             'Chưa trả' AS trang_thai,
             NULL AS ngay_tra_luong
FROM nhanvien n
WHERE n.vai_tro IN ('Nhân viên','Quản lý')
    AND NOT EXISTS (
        SELECT 1 FROM luong l WHERE l.nhan_vien_id = n.id AND l.thang = 8 AND l.nam = 2025
    );

COMMIT;