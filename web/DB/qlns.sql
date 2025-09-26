-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Máy chủ: 127.0.0.1
-- Thời gian đã tạo: Th9 26, 2025 lúc 12:19 PM
-- Phiên bản máy phục vụ: 10.4.32-MariaDB
-- Phiên bản PHP: 8.0.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Cơ sở dữ liệu: `qlns`
--

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `cau_hinh_he_thong`
--

CREATE TABLE `cau_hinh_he_thong` (
  `id` int(11) NOT NULL,
  `ten_cau_hinh` varchar(100) DEFAULT NULL,
  `gia_tri` text DEFAULT NULL,
  `mo_ta` text DEFAULT NULL,
  `ngay_tao` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `cau_hinh_he_thong`
--

INSERT INTO `cau_hinh_he_thong` (`id`, `ten_cau_hinh`, `gia_tri`, `mo_ta`, `ngay_tao`) VALUES
(1, 'company_name', 'CÔNG TY TNHH ICSS', 'Tên công ty', '2025-09-03 03:26:58'),
(2, 'working_hours_start', '08:45', 'Giờ bắt đầu làm việc', '2025-09-03 03:26:58'),
(3, 'working_hours_end', '17:30', 'Giờ kết thúc làm việc', '2025-09-03 03:26:58'),
(4, 'annual_leave_days', '12', 'Số ngày phép năm', '2025-09-03 03:26:58');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `cham_cong`
--

CREATE TABLE `cham_cong` (
  `id` int(11) NOT NULL,
  `nhan_vien_id` int(11) DEFAULT NULL,
  `ngay` date DEFAULT NULL,
  `check_in` time DEFAULT NULL,
  `check_out` time DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `cong_viec`
--

CREATE TABLE `cong_viec` (
  `id` int(11) NOT NULL,
  `du_an_id` int(11) DEFAULT NULL,
  `ten_cong_viec` varchar(255) NOT NULL,
  `mo_ta` text DEFAULT NULL,
  `han_hoan_thanh` date DEFAULT NULL,
  `muc_do_uu_tien` enum('Thấp','Trung bình','Cao') DEFAULT 'Trung bình',
  `nguoi_giao_id` int(11) DEFAULT NULL,
  `phong_ban_id` int(11) DEFAULT NULL,
  `trang_thai` enum('Chưa bắt đầu','Đang thực hiện','Đã hoàn thành','Trễ hạn') DEFAULT 'Chưa bắt đầu',
  `tai_lieu_cv` varchar(255) DEFAULT NULL,
  `file_tai_lieu` varchar(255) DEFAULT NULL,
  `ngay_tao` timestamp NOT NULL DEFAULT current_timestamp(),
  `ngay_bat_dau` date DEFAULT NULL,
  `ngay_hoan_thanh` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `cong_viec_danh_gia`
--

CREATE TABLE `cong_viec_danh_gia` (
  `id` int(11) NOT NULL,
  `cong_viec_id` int(11) DEFAULT NULL,
  `nguoi_danh_gia_id` int(11) DEFAULT NULL,
  `nhan_xet` text DEFAULT NULL,
  `thoi_gian` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `cong_viec_lich_su`
--

CREATE TABLE `cong_viec_lich_su` (
  `id` int(11) NOT NULL,
  `cong_viec_id` int(11) DEFAULT NULL,
  `nguoi_thay_doi_id` int(11) DEFAULT NULL,
  `mo_ta_thay_doi` text DEFAULT NULL,
  `thoi_gian` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `cong_viec_nguoi_nhan`
--

CREATE TABLE `cong_viec_nguoi_nhan` (
  `id` int(11) NOT NULL,
  `cong_viec_id` int(11) NOT NULL,
  `nhan_vien_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `cong_viec_quy_trinh`
--

CREATE TABLE `cong_viec_quy_trinh` (
  `id` int(11) NOT NULL,
  `cong_viec_id` int(11) DEFAULT NULL,
  `ten_buoc` varchar(255) DEFAULT NULL,
  `mo_ta` text DEFAULT NULL,
  `trang_thai` enum('Chưa bắt đầu','Đang thực hiện','Đã hoàn thành') DEFAULT 'Chưa bắt đầu',
  `ngay_bat_dau` date DEFAULT NULL,
  `ngay_ket_thuc` date DEFAULT NULL,
  `ngay_tao` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `cong_viec_tien_do`
--

CREATE TABLE `cong_viec_tien_do` (
  `id` int(11) NOT NULL,
  `cong_viec_id` int(11) DEFAULT NULL,
  `phan_tram` int(11) DEFAULT NULL,
  `thoi_gian_cap_nhat` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `du_an`
--

CREATE TABLE `du_an` (
  `id` int(11) NOT NULL,
  `ten_du_an` varchar(255) NOT NULL,
  `mo_ta` text DEFAULT NULL,
  `ngay_bat_dau` date DEFAULT NULL,
  `ngay_ket_thuc` date DEFAULT NULL,
  `ngay_tao` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `du_an`
--

INSERT INTO `du_an` (`id`, `ten_du_an`, `mo_ta`, `ngay_bat_dau`, `ngay_ket_thuc`, `ngay_tao`) VALUES
(1, 'Công việc chung', 'Công việc riêng', '2025-09-17', '2035-10-31', '2025-09-17 09:03:49');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `file_dinh_kem`
--

CREATE TABLE `file_dinh_kem` (
  `id` int(11) NOT NULL,
  `cong_viec_id` int(11) DEFAULT NULL,
  `tien_do_id` int(11) DEFAULT NULL,
  `duong_dan_file` varchar(255) DEFAULT NULL,
  `mo_ta` text DEFAULT NULL,
  `thoi_gian_upload` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `lich_trinh`
--

CREATE TABLE `lich_trinh` (
  `id` int(11) NOT NULL,
  `tieu_de` varchar(255) NOT NULL,
  `ngay_bat_dau` date NOT NULL,
  `ngay_ket_thuc` date DEFAULT NULL,
  `mo_ta` text DEFAULT NULL,
  `ngay_tao` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `lich_trinh`
--

INSERT INTO `lich_trinh` (`id`, `tieu_de`, `ngay_bat_dau`, `ngay_ket_thuc`, `mo_ta`, `ngay_tao`) VALUES
(6, '1321', '2025-09-23', '2025-09-24', '12321', '2025-09-23 04:57:55');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `luong`
--

CREATE TABLE `luong` (
  `id` int(11) NOT NULL,
  `nhan_vien_id` int(11) DEFAULT NULL,
  `thang` int(11) DEFAULT NULL,
  `nam` int(11) DEFAULT NULL,
  `luong_co_ban` decimal(12,2) DEFAULT NULL,
  `phu_cap` decimal(12,2) DEFAULT 0.00,
  `thuong` decimal(12,2) DEFAULT 0.00,
  `phat` decimal(12,2) DEFAULT 0.00,
  `bao_hiem` decimal(12,2) DEFAULT 0.00,
  `thue` decimal(12,2) DEFAULT 0.00,
  `luong_thuc_te` decimal(12,2) DEFAULT NULL,
  `ghi_chu` text DEFAULT NULL,
  `trang_thai` enum('Chưa trả','Đã trả') DEFAULT 'Chưa trả',
  `ngay_tra_luong` date DEFAULT NULL,
  `ngay_tao` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `luong_cau_hinh`
--

CREATE TABLE `luong_cau_hinh` (
  `id` int(11) NOT NULL,
  `ten_cau_hinh` varchar(100) DEFAULT NULL,
  `gia_tri` varchar(100) DEFAULT NULL,
  `mo_ta` text DEFAULT NULL,
  `ngay_tao` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `luu_kpi`
--

CREATE TABLE `luu_kpi` (
  `id` int(11) NOT NULL,
  `nhan_vien_id` int(11) DEFAULT NULL,
  `thang` int(11) DEFAULT NULL,
  `nam` int(11) DEFAULT NULL,
  `chi_tieu` text DEFAULT NULL,
  `ket_qua` text DEFAULT NULL,
  `diem_kpi` float DEFAULT NULL,
  `ghi_chu` text DEFAULT NULL,
  `ngay_tao` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `nhanvien`
--

CREATE TABLE `nhanvien` (
  `id` int(11) NOT NULL,
  `ho_ten` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `mat_khau` varchar(255) NOT NULL,
  `so_dien_thoai` varchar(20) DEFAULT NULL,
  `gioi_tinh` enum('Nam','Nữ','Khác') DEFAULT NULL,
  `ngay_sinh` date DEFAULT NULL,
  `phong_ban_id` int(11) DEFAULT NULL,
  `chuc_vu` varchar(100) DEFAULT NULL,
  `luong_co_ban` decimal(12,2) DEFAULT 0.00,
  `trang_thai_lam_viec` enum('Đang làm','Tạm nghỉ','Nghỉ việc') DEFAULT 'Đang làm',
  `vai_tro` enum('Admin','Quản lý','Nhân viên') DEFAULT 'Nhân viên',
  `ngay_vao_lam` date DEFAULT NULL,
  `avatar_url` varchar(255) DEFAULT NULL,
  `ngay_tao` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `nhanvien`
--

INSERT INTO `nhanvien` (`id`, `ho_ten`, `email`, `mat_khau`, `so_dien_thoai`, `gioi_tinh`, `ngay_sinh`, `phong_ban_id`, `chuc_vu`, `luong_co_ban`, `trang_thai_lam_viec`, `vai_tro`, `ngay_vao_lam`, `avatar_url`, `ngay_tao`) VALUES
(1, 'Phạm Minh Thắng', 'minhthang@gmail.com', '12345678', '0834035090', 'Nam', '2003-11-23', 6, 'Nhân viên', 20000000.00, 'Đang làm', 'Nhân viên', '2025-09-03', 'https://i.postimg.cc/C5Z5RWgt/z5863399686673-df5230e1f84835bf20b88f032388d49d.jpg', '2025-09-03 03:26:57'),
(2, 'Nguyễn Ngọc Tuyền', 'tt98tuyen@gmail.com', 'tuyendz321', '0399045920', 'Nam', '2003-03-11', 6, 'Nhân viên', 0.00, 'Đang làm', 'Nhân viên', '2025-07-20', 'https://i.postimg.cc/q7nxs24X/z6976269052999-e22e9cb5e367830aede3a369c5f977b6.jpg', '2025-09-04 03:59:59'),
(3, 'Nguyễn Tấn Dũng', 'jindonguyen2015@gmail.com', '12345678', '0943924816', 'Nam', '2002-08-24', 6, 'Nhân viên', 0.00, 'Đang làm', 'Nhân viên', '2025-05-05', 'https://i.postimg.cc/CLrmzggp/z6913446856097-ac16f34c6ba3cb76c40d753bb051e0a6-Nguyen-Dung.jpg', '2025-09-04 04:03:30'),
(4, 'Võ Trung Âu', 'dr.votrungau@gmail.com', '12345678', '0931487231', 'Nam', '1989-03-03', 1, 'Giám đốc', 0.00, 'Đang làm', 'Admin', '2024-08-01', 'https://i.postimg.cc/QCX0WNCh/IMG-9548-Vo-Au.jpg', '2025-09-04 04:03:44'),
(5, 'Trịnh Văn Chiến', 'trinhchienalone@gmail.com', 'Chien123@', '0819881399', 'Nam', '2004-09-15', 6, 'Thực tập sinh', 0.00, 'Đang làm', 'Nhân viên', '2025-07-01', 'https://i.postimg.cc/660HxZb3/z3773863902306-3dcbc5c61ac55cf92ead58604f04d7c2-V-n-Chi-n-Tr-nh-Tr-Chi-n.jpg', '2025-09-04 04:04:34'),
(6, 'Vũ Tam Hanh', 'vutamhanh@gmail.com', '12345678', '0912338386', 'Nam', '1974-09-21', 6, 'Trưởng phòng', 0.00, 'Đang làm', 'Quản lý', '2025-09-03', 'https://i.postimg.cc/x1mhwnFR/IMG-8032.jpg', '2025-09-04 04:05:00'),
(7, 'Nguyễn Thị Diễm Quỳnh', 'quynhdiem@icss.com.vn', '12345678', '0972363821', 'Nữ', '2001-11-15', 1, 'Nhân viên', 0.00, 'Đang làm', 'Nhân viên', '2025-06-16', 'https://i.postimg.cc/x1mhwnFR/IMG-8032.jpg', '2025-09-04 04:07:07'),
(8, 'Trần Đình Nam', 'trandinhnamuet@gmail.com', '12345678', '0962989431', 'Nam', '2001-09-01', 6, 'Nhân viên', 0.00, 'Đang làm', 'Nhân viên', '2025-09-03', 'https://i.postimg.cc/76rBwnyC/Anhdaidien-Tr-n-nh-Nam.png', '2025-09-04 04:08:41'),
(9, 'Phạm Thị Lê Vinh', 'phamvinh2004hb@gmail.com', 'Levinh123@', '0356249734', 'Nữ', '2004-07-28', 7, 'Thực tập sinh', 0.00, 'Đang làm', 'Nhân viên', '2025-07-01', 'https://i.postimg.cc/vZjqSdqt/nh-c-y-Vinh-Ph-m.jpg', '2025-09-04 04:10:16'),
(10, 'Nguyễn Đức Dương', 'linhduonghb1992@gmail.com', '12345678', '0977230903', 'Nam', '2003-09-23', 8, 'Trưởng phòng', 0.00, 'Đang làm', 'Admin', '2025-08-02', 'https://i.postimg.cc/VNC7xH2Q/509756574-8617132495078515-4794128757965032491-n-Linh-Duong-Nguyen.jpg', '2025-09-04 04:10:23'),
(11, 'Đặng Lê Trung', 'trungdang@icss.com.vn', '12345678', '0985553321', 'Nam', '1991-11-24', 7, 'Giám đốc', 0.00, 'Đang làm', 'Admin', '2025-07-21', 'https://i.postimg.cc/x1mhwnFR/IMG-8032.jpg', '2025-09-04 04:28:13'),
(12, 'Vũ Thị Hải Yến', 'yenics@gmail.com', '12345678', '0900000001', 'Nữ', '2025-09-04', 1, 'Giám đốc', 0.00, 'Đang làm', 'Admin', '2025-09-04', 'https://i.postimg.cc/x1mhwnFR/IMG-8032.jpg', '2025-09-04 04:30:16'),
(13, 'Đặng Như Quỳnh', 'dangnhuquynh108@gmail.com', '12345678', '0352881187', 'Nữ', '2004-05-28', 7, 'Thực tập sinh', 0.00, 'Đang làm', 'Nhân viên', '2025-07-01', 'https://i.postimg.cc/XqQxKMBF/z6611166684599-bef42c73e3c6652f77e87eb8a82c5bc6-ng-Nh-Qu-nh.jpg', '2025-09-04 04:42:04'),
(14, 'Nguyễn Ngọc Phúc', 'mancity.phuc2004@gmail.com', '12345678', '0961522506', 'Nam', '2025-08-20', 6, 'Thực tập sinh', 0.00, 'Đang làm', 'Nhân viên', '2025-06-28', 'https://i.postimg.cc/x1mhwnFR/IMG-8032.jpg', '2025-09-04 06:29:30'),
(15, 'Đặng Thu Hồng', 'dangthuhong1101@gmail.com', '12345678', '0363631856', 'Nữ', '2004-12-02', 7, 'Thực tập sinh', 0.00, 'Đang làm', 'Nhân viên', '2025-07-01', 'https://i.postimg.cc/x1mhwnFR/IMG-8032.jpg', '2025-09-04 06:32:20'),
(16, 'Phan Tuấn Linh', 'linhphan227366@gmail.com', '12345678', '0911162004', 'Nam', '2004-06-11', 6, 'Nhân viên', 0.00, 'Đang làm', 'Nhân viên', '2025-03-21', 'https://i.postimg.cc/xTSQT8mh/IMG-1142-linh-phan.avif', '2025-09-04 06:50:11'),
(17, 'Nguyễn Huy Hoàng', 'huyhoangnguyen20704@gmail.com', '12345678   ', '0395491415', 'Nam', '2004-07-20', 6, 'Thực tập sinh', 0.00, 'Đang làm', 'Nhân viên', '2025-07-02', 'https://i.postimg.cc/x1mhwnFR/IMG-8032.jpg', '2025-09-04 07:02:17'),
(18, 'Admin', 'admin@gmail.com', '12345678', 'Admin', 'Nam', '2025-09-04', 6, 'Giám đốc', 0.00, 'Đang làm', 'Admin', '2025-09-13', 'https://i.postimg.cc/x1mhwnFR/IMG-8032.jpg', '2025-09-04 07:43:56');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `nhan_su_lich_su`
--

CREATE TABLE `nhan_su_lich_su` (
  `id` int(11) NOT NULL,
  `nhan_vien_id` int(11) DEFAULT NULL,
  `loai_thay_doi` varchar(100) DEFAULT NULL,
  `gia_tri_cu` text DEFAULT NULL,
  `gia_tri_moi` text DEFAULT NULL,
  `nguoi_thay_doi_id` int(11) DEFAULT NULL,
  `ghi_chu` text DEFAULT NULL,
  `thoi_gian` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `phan_quyen_chuc_nang`
--

CREATE TABLE `phan_quyen_chuc_nang` (
  `id` int(11) NOT NULL,
  `vai_tro` enum('Admin','Quản lý','Nhân viên','Trưởng nhóm','Nhân viên cấp cao') DEFAULT NULL,
  `chuc_nang` varchar(100) DEFAULT NULL,
  `co_quyen` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `phong_ban`
--

CREATE TABLE `phong_ban` (
  `id` int(11) NOT NULL,
  `ten_phong` varchar(100) NOT NULL,
  `truong_phong_id` int(11) DEFAULT NULL,
  `ngay_tao` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `phong_ban`
--

INSERT INTO `phong_ban` (`id`, `ten_phong`, `truong_phong_id`, `ngay_tao`) VALUES
(1, 'Phòng Nhân sự', NULL, '2025-09-03 03:26:57'),
(6, 'Phòng Kỹ thuật', 6, '2025-09-04 04:19:49'),
(7, 'Phòng Marketing & Sales', NULL, '2025-09-04 04:20:02'),
(8, 'Phòng Tài chính & Pháp chế', 10, '2025-09-04 04:20:52');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `thong_bao`
--

CREATE TABLE `thong_bao` (
  `id` int(11) NOT NULL,
  `tieu_de` varchar(255) DEFAULT NULL,
  `noi_dung` text DEFAULT NULL,
  `nguoi_nhan_id` int(11) DEFAULT NULL,
  `loai_thong_bao` text DEFAULT NULL,
  `da_doc` tinyint(1) DEFAULT 0,
  `ngay_doc` timestamp NULL DEFAULT NULL,
  `ngay_tao` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `thong_bao`
--

INSERT INTO `thong_bao` (`id`, `tieu_de`, `noi_dung`, `nguoi_nhan_id`, `loai_thong_bao`, `da_doc`, `ngay_doc`, `ngay_tao`) VALUES
(245, 'Công việc mới', 'Bạn được giao công việc: 1. Hạn: 2025-09-25.', 1, 'Công việc mới', 0, '2025-09-23 07:05:42', '2025-09-23 07:05:42'),
(246, 'Công việc mới', 'Bạn được giao công việc: 1. Hạn: 2025-09-26.', 2, 'Công việc mới', 0, '2025-09-23 09:00:58', '2025-09-23 09:00:58'),
(247, 'Công việc mới', 'Bạn được giao công việc: 1. Hạn: 2025-09-26.', 5, 'Công việc mới', 0, '2025-09-23 09:00:58', '2025-09-23 09:00:58'),
(248, 'Công việc mới', 'Bạn được giao công việc: 1. Hạn: 2025-09-26.', 8, 'Công việc mới', 0, '2025-09-23 09:00:58', '2025-09-23 09:00:58'),
(249, 'Công việc mới', 'Bạn được giao công việc: 1. Hạn: 2025-09-27.', 11, 'Công việc mới', 0, '2025-09-23 09:18:38', '2025-09-23 09:18:38'),
(250, 'Công việc mới', 'Bạn được giao công việc: 1. Hạn: 2025-09-27.', 14, 'Công việc mới', 0, '2025-09-23 09:18:38', '2025-09-23 09:18:38'),
(251, 'Công việc mới', 'Bạn được giao công việc: 1. Hạn: 2025-09-27.', 17, 'Công việc mới', 0, '2025-09-23 09:18:38', '2025-09-23 09:18:38'),
(252, 'Công việc mới', 'Bạn được giao công việc: 1231. Hạn: 2025-09-20.', 2, 'Công việc mới', 0, '2025-09-23 09:38:19', '2025-09-23 09:38:19'),
(253, 'Công việc mới', 'Bạn được giao công việc: 1231. Hạn: 2025-09-20.', 5, 'Công việc mới', 0, '2025-09-23 09:38:19', '2025-09-23 09:38:19'),
(254, 'Công việc mới', 'Bạn được giao công việc: 1231. Hạn: 2025-09-20.', 8, 'Công việc mới', 0, '2025-09-23 09:38:19', '2025-09-23 09:38:19'),
(255, 'Công việc mới', 'Bạn được giao công việc: 1231. Hạn: 2025-09-20.', 11, 'Công việc mới', 0, '2025-09-23 09:38:19', '2025-09-23 09:38:19'),
(256, 'Công việc mới', 'Bạn được giao công việc: 1231. Hạn: 2025-09-20.', 14, 'Công việc mới', 0, '2025-09-23 09:38:19', '2025-09-23 09:38:19'),
(257, 'Công việc mới', 'Bạn được giao công việc: 22211. Hạn: 2025-09-21.', 3, 'Công việc mới', 0, '2025-09-23 09:38:35', '2025-09-23 09:38:35'),
(258, 'Công việc mới', 'Bạn được giao công việc: 22211. Hạn: 2025-09-21.', 6, 'Công việc mới', 0, '2025-09-23 09:38:35', '2025-09-23 09:38:35'),
(259, 'Công việc mới', 'Bạn được giao công việc: 22211. Hạn: 2025-09-21.', 9, 'Công việc mới', 0, '2025-09-23 09:38:35', '2025-09-23 09:38:35'),
(260, 'Công việc mới', 'Bạn được giao công việc: 22211. Hạn: 2025-09-21.', 12, 'Công việc mới', 0, '2025-09-23 09:38:35', '2025-09-23 09:38:35'),
(261, 'Công việc mới', 'Bạn được giao công việc: 22211. Hạn: 2025-09-21.', 15, 'Công việc mới', 0, '2025-09-23 09:38:35', '2025-09-23 09:38:35'),
(262, 'Cập nhật công việc', 'Công việc: 1231 vừa được cập nhật mới', 11, 'Cập nhật', 0, '2025-09-23 09:38:42', '2025-09-23 09:38:42'),
(263, 'Cập nhật công việc', 'Công việc: 1231 vừa được cập nhật mới', 14, 'Cập nhật', 0, '2025-09-23 09:38:42', '2025-09-23 09:38:42'),
(264, 'Cập nhật công việc', 'Công việc: 1231 vừa được cập nhật mới', 2, 'Cập nhật', 0, '2025-09-23 09:38:42', '2025-09-23 09:38:42'),
(265, 'Cập nhật công việc', 'Công việc: 1231 vừa được cập nhật mới', 8, 'Cập nhật', 0, '2025-09-23 09:38:42', '2025-09-23 09:38:42'),
(266, 'Cập nhật công việc', 'Công việc: 1231 vừa được cập nhật mới', 5, 'Cập nhật', 0, '2025-09-23 09:38:42', '2025-09-23 09:38:42'),
(267, 'Cập nhật công việc', 'Công việc: 22211 vừa được cập nhật mới', 15, 'Cập nhật', 0, '2025-09-23 09:38:51', '2025-09-23 09:38:51'),
(268, 'Cập nhật công việc', 'Công việc: 22211 vừa được cập nhật mới', 3, 'Cập nhật', 0, '2025-09-23 09:38:51', '2025-09-23 09:38:51'),
(269, 'Cập nhật công việc', 'Công việc: 22211 vừa được cập nhật mới', 9, 'Cập nhật', 0, '2025-09-23 09:38:51', '2025-09-23 09:38:51'),
(270, 'Cập nhật công việc', 'Công việc: 22211 vừa được cập nhật mới', 6, 'Cập nhật', 0, '2025-09-23 09:38:51', '2025-09-23 09:38:51'),
(271, 'Cập nhật công việc', 'Công việc: 22211 vừa được cập nhật mới', 12, 'Cập nhật', 0, '2025-09-23 09:38:51', '2025-09-23 09:38:51'),
(272, 'Công việc mới', 'Bạn được giao công việc: 22211. Hạn: 2025-09-21.', 2, 'Công việc mới', 0, '2025-09-23 09:55:39', '2025-09-23 09:55:39'),
(273, 'Công việc mới', 'Bạn được giao công việc: 22211. Hạn: 2025-09-21.', 5, 'Công việc mới', 0, '2025-09-23 09:55:39', '2025-09-23 09:55:39'),
(274, 'Công việc mới', 'Bạn được giao công việc: 22211. Hạn: 2025-09-21.', 8, 'Công việc mới', 0, '2025-09-23 09:55:39', '2025-09-23 09:55:39'),
(275, 'Cập nhật công việc', 'Công việc: 22211 vừa được cập nhật mới', 2, 'Cập nhật', 0, '2025-09-23 09:56:09', '2025-09-23 09:56:09'),
(276, 'Cập nhật công việc', 'Công việc: 22211 vừa được cập nhật mới', 5, 'Cập nhật', 0, '2025-09-23 09:56:09', '2025-09-23 09:56:09'),
(277, 'Cập nhật công việc', 'Công việc: 22211 vừa được cập nhật mới', 8, 'Cập nhật', 0, '2025-09-23 09:56:09', '2025-09-23 09:56:09'),
(278, 'Cập nhật công việc', 'Công việc: 22211 vừa được cập nhật mới', 11, 'Cập nhật', 0, '2025-09-23 09:56:09', '2025-09-23 09:56:09'),
(279, 'Cập nhật công việc', 'Công việc: 22211 vừa được cập nhật mới', 14, 'Cập nhật', 0, '2025-09-23 09:56:09', '2025-09-23 09:56:09'),
(280, 'Công việc mới', 'Bạn được giao công việc: 111. Hạn: 2025-09-28.', 8, 'Công việc mới', 0, '2025-09-23 09:57:05', '2025-09-23 09:57:05'),
(281, 'Công việc mới', 'Bạn được giao công việc: 111. Hạn: 2025-09-28.', 11, 'Công việc mới', 0, '2025-09-23 09:57:05', '2025-09-23 09:57:05'),
(282, 'Công việc mới', 'Bạn được giao công việc: 111. Hạn: 2025-09-28.', 14, 'Công việc mới', 0, '2025-09-23 09:57:05', '2025-09-23 09:57:05'),
(283, 'Công việc mới', 'Bạn được giao công việc: 111. Hạn: 2025-09-28.', 9, 'Công việc mới', 0, '2025-09-23 09:57:30', '2025-09-23 09:57:30'),
(284, 'Công việc mới', 'Bạn được giao công việc: 111. Hạn: 2025-09-28.', 12, 'Công việc mới', 0, '2025-09-23 09:57:30', '2025-09-23 09:57:30'),
(285, 'Công việc mới', 'Bạn được giao công việc: 111. Hạn: 2025-09-28.', 15, 'Công việc mới', 0, '2025-09-23 09:57:30', '2025-09-23 09:57:30'),
(286, 'Cập nhật công việc', 'Công việc: 111 vừa được cập nhật mới', 8, 'Cập nhật', 0, '2025-09-23 09:57:43', '2025-09-23 09:57:43'),
(287, 'Cập nhật công việc', 'Công việc: 111 vừa được cập nhật mới', 11, 'Cập nhật', 0, '2025-09-23 09:57:43', '2025-09-23 09:57:43'),
(288, 'Cập nhật công việc', 'Công việc: 111 vừa được cập nhật mới', 14, 'Cập nhật', 0, '2025-09-23 09:57:43', '2025-09-23 09:57:43'),
(289, 'Cập nhật công việc', 'Công việc: 111 vừa được cập nhật mới', 17, 'Cập nhật', 0, '2025-09-23 09:57:43', '2025-09-23 09:57:43'),
(290, 'Công việc mới', 'Bạn được giao công việc: 132131. Hạn: 2025-10-05.', 15, 'Công việc mới', 0, '2025-09-23 09:58:14', '2025-09-23 09:58:14'),
(291, 'Cập nhật công việc', 'Công việc: 111 vừa được cập nhật mới', 15, 'Cập nhật', 0, '2025-09-23 09:59:03', '2025-09-23 09:59:03'),
(292, 'Cập nhật công việc', 'Công việc: 22211 vừa được cập nhật mới', 2, 'Cập nhật', 0, '2025-09-23 10:01:00', '2025-09-23 10:01:00'),
(293, 'Cập nhật công việc', 'Công việc: 22211 vừa được cập nhật mới', 5, 'Cập nhật', 0, '2025-09-23 10:01:00', '2025-09-23 10:01:00'),
(294, 'Cập nhật công việc', 'Công việc: 22211 vừa được cập nhật mới', 8, 'Cập nhật', 0, '2025-09-23 10:01:00', '2025-09-23 10:01:00'),
(295, 'Cập nhật công việc', 'Công việc: 22211 vừa được cập nhật mới', 11, 'Cập nhật', 0, '2025-09-23 10:01:00', '2025-09-23 10:01:00'),
(296, 'Cập nhật công việc', 'Công việc: 22211 vừa được cập nhật mới', 14, 'Cập nhật', 0, '2025-09-23 10:01:00', '2025-09-23 10:01:00'),
(297, 'Cập nhật công việc', 'Công việc: 22211 vừa được cập nhật mới', 17, 'Cập nhật', 0, '2025-09-23 10:01:00', '2025-09-23 10:01:00'),
(298, 'Cập nhật công việc', 'Công việc: 22211 vừa được cập nhật mới', 11, 'Cập nhật', 0, '2025-09-23 10:01:09', '2025-09-23 10:01:09'),
(299, 'Cập nhật công việc', 'Công việc: 22211 vừa được cập nhật mới', 5, 'Cập nhật', 0, '2025-09-23 10:01:09', '2025-09-23 10:01:09'),
(300, 'Công việc mới', 'Bạn được giao công việc: 132131. Hạn: 2025-10-05.', 2, 'Công việc mới', 0, '2025-09-23 10:24:28', '2025-09-23 10:24:28'),
(301, 'Công việc mới', 'Bạn được giao công việc: 132131. Hạn: 2025-10-05.', 5, 'Công việc mới', 0, '2025-09-23 10:24:28', '2025-09-23 10:24:28'),
(302, 'Công việc mới', 'Bạn được giao công việc: 132131. Hạn: 2025-10-05.', 8, 'Công việc mới', 0, '2025-09-23 10:24:28', '2025-09-23 10:24:28'),
(303, 'Công việc mới', 'Bạn được giao công việc: 132131. Hạn: 2025-10-05.', 11, 'Công việc mới', 0, '2025-09-23 10:24:28', '2025-09-23 10:24:28'),
(304, 'Cập nhật công việc', 'Công việc: 132131 vừa được cập nhật mới', 11, 'Cập nhật', 0, '2025-09-23 10:24:47', '2025-09-23 10:24:47'),
(305, 'Cập nhật công việc', 'Công việc: 132131 vừa được cập nhật mới', 2, 'Cập nhật', 0, '2025-09-23 10:24:47', '2025-09-23 10:24:47'),
(306, 'Cập nhật công việc', 'Công việc: 132131 vừa được cập nhật mới', 8, 'Cập nhật', 0, '2025-09-23 10:24:47', '2025-09-23 10:24:47'),
(307, 'Công việc mới', 'Bạn được giao công việc: 6666. Hạn: 2025-09-30.', 1, 'Công việc mới', 0, '2025-09-23 10:25:08', '2025-09-23 10:25:08'),
(308, 'Công việc mới', 'Bạn được giao công việc: 6666. Hạn: 2025-09-30.', 4, 'Công việc mới', 0, '2025-09-23 10:25:08', '2025-09-23 10:25:08'),
(309, 'Công việc mới', 'Bạn được giao công việc: 6666. Hạn: 2025-09-30.', 7, 'Công việc mới', 0, '2025-09-23 10:25:08', '2025-09-23 10:25:08'),
(310, 'Công việc mới', 'Bạn được giao công việc: 1. Hạn: 2025-09-28.', 14, 'Công việc mới', 0, '2025-09-26 08:09:38', '2025-09-26 08:09:38'),
(311, 'Công việc mới', 'Bạn được giao công việc: 1. Hạn: 2025-09-28.', 17, 'Công việc mới', 0, '2025-09-26 08:09:38', '2025-09-26 08:09:38');

--
-- Chỉ mục cho các bảng đã đổ
--

--
-- Chỉ mục cho bảng `cau_hinh_he_thong`
--
ALTER TABLE `cau_hinh_he_thong`
  ADD PRIMARY KEY (`id`);

--
-- Chỉ mục cho bảng `cham_cong`
--
ALTER TABLE `cham_cong`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `nhan_vien_id` (`nhan_vien_id`,`ngay`);

--
-- Chỉ mục cho bảng `cong_viec`
--
ALTER TABLE `cong_viec`
  ADD PRIMARY KEY (`id`),
  ADD KEY `nguoi_giao_id` (`nguoi_giao_id`),
  ADD KEY `phong_ban_id` (`phong_ban_id`),
  ADD KEY `fk_cong_viec_du_an` (`du_an_id`);

--
-- Chỉ mục cho bảng `cong_viec_danh_gia`
--
ALTER TABLE `cong_viec_danh_gia`
  ADD PRIMARY KEY (`id`),
  ADD KEY `cong_viec_id` (`cong_viec_id`),
  ADD KEY `nguoi_danh_gia_id` (`nguoi_danh_gia_id`);

--
-- Chỉ mục cho bảng `cong_viec_lich_su`
--
ALTER TABLE `cong_viec_lich_su`
  ADD PRIMARY KEY (`id`),
  ADD KEY `cong_viec_id` (`cong_viec_id`),
  ADD KEY `nguoi_thay_doi_id` (`nguoi_thay_doi_id`);

--
-- Chỉ mục cho bảng `cong_viec_nguoi_nhan`
--
ALTER TABLE `cong_viec_nguoi_nhan`
  ADD PRIMARY KEY (`id`),
  ADD KEY `cong_viec_id` (`cong_viec_id`),
  ADD KEY `nhan_vien_id` (`nhan_vien_id`);

--
-- Chỉ mục cho bảng `cong_viec_quy_trinh`
--
ALTER TABLE `cong_viec_quy_trinh`
  ADD PRIMARY KEY (`id`),
  ADD KEY `cong_viec_id` (`cong_viec_id`);

--
-- Chỉ mục cho bảng `cong_viec_tien_do`
--
ALTER TABLE `cong_viec_tien_do`
  ADD PRIMARY KEY (`id`),
  ADD KEY `cong_viec_id` (`cong_viec_id`);

--
-- Chỉ mục cho bảng `du_an`
--
ALTER TABLE `du_an`
  ADD PRIMARY KEY (`id`);

--
-- Chỉ mục cho bảng `file_dinh_kem`
--
ALTER TABLE `file_dinh_kem`
  ADD PRIMARY KEY (`id`),
  ADD KEY `cong_viec_id` (`cong_viec_id`),
  ADD KEY `tien_do_id` (`tien_do_id`);

--
-- Chỉ mục cho bảng `lich_trinh`
--
ALTER TABLE `lich_trinh`
  ADD PRIMARY KEY (`id`);

--
-- Chỉ mục cho bảng `luong`
--
ALTER TABLE `luong`
  ADD PRIMARY KEY (`id`),
  ADD KEY `nhan_vien_id` (`nhan_vien_id`);

--
-- Chỉ mục cho bảng `luong_cau_hinh`
--
ALTER TABLE `luong_cau_hinh`
  ADD PRIMARY KEY (`id`);

--
-- Chỉ mục cho bảng `luu_kpi`
--
ALTER TABLE `luu_kpi`
  ADD PRIMARY KEY (`id`),
  ADD KEY `nhan_vien_id` (`nhan_vien_id`);

--
-- Chỉ mục cho bảng `nhanvien`
--
ALTER TABLE `nhanvien`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`),
  ADD KEY `phong_ban_id` (`phong_ban_id`);

--
-- Chỉ mục cho bảng `nhan_su_lich_su`
--
ALTER TABLE `nhan_su_lich_su`
  ADD PRIMARY KEY (`id`),
  ADD KEY `nhan_vien_id` (`nhan_vien_id`),
  ADD KEY `nguoi_thay_doi_id` (`nguoi_thay_doi_id`);

--
-- Chỉ mục cho bảng `phan_quyen_chuc_nang`
--
ALTER TABLE `phan_quyen_chuc_nang`
  ADD PRIMARY KEY (`id`);

--
-- Chỉ mục cho bảng `phong_ban`
--
ALTER TABLE `phong_ban`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_truong_phong` (`truong_phong_id`);

--
-- Chỉ mục cho bảng `thong_bao`
--
ALTER TABLE `thong_bao`
  ADD PRIMARY KEY (`id`),
  ADD KEY `nguoi_nhan_id` (`nguoi_nhan_id`);

--
-- AUTO_INCREMENT cho các bảng đã đổ
--

--
-- AUTO_INCREMENT cho bảng `cau_hinh_he_thong`
--
ALTER TABLE `cau_hinh_he_thong`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT cho bảng `cham_cong`
--
ALTER TABLE `cham_cong`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=436;

--
-- AUTO_INCREMENT cho bảng `cong_viec`
--
ALTER TABLE `cong_viec`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=131;

--
-- AUTO_INCREMENT cho bảng `cong_viec_danh_gia`
--
ALTER TABLE `cong_viec_danh_gia`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT cho bảng `cong_viec_lich_su`
--
ALTER TABLE `cong_viec_lich_su`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT cho bảng `cong_viec_nguoi_nhan`
--
ALTER TABLE `cong_viec_nguoi_nhan`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=200;

--
-- AUTO_INCREMENT cho bảng `cong_viec_quy_trinh`
--
ALTER TABLE `cong_viec_quy_trinh`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=161;

--
-- AUTO_INCREMENT cho bảng `cong_viec_tien_do`
--
ALTER TABLE `cong_viec_tien_do`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=73;

--
-- AUTO_INCREMENT cho bảng `du_an`
--
ALTER TABLE `du_an`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=32;

--
-- AUTO_INCREMENT cho bảng `file_dinh_kem`
--
ALTER TABLE `file_dinh_kem`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT cho bảng `lich_trinh`
--
ALTER TABLE `lich_trinh`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT cho bảng `luong`
--
ALTER TABLE `luong`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=25;

--
-- AUTO_INCREMENT cho bảng `luong_cau_hinh`
--
ALTER TABLE `luong_cau_hinh`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT cho bảng `luu_kpi`
--
ALTER TABLE `luu_kpi`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=25;

--
-- AUTO_INCREMENT cho bảng `nhanvien`
--
ALTER TABLE `nhanvien`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;

--
-- AUTO_INCREMENT cho bảng `nhan_su_lich_su`
--
ALTER TABLE `nhan_su_lich_su`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT cho bảng `phan_quyen_chuc_nang`
--
ALTER TABLE `phan_quyen_chuc_nang`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT cho bảng `phong_ban`
--
ALTER TABLE `phong_ban`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT cho bảng `thong_bao`
--
ALTER TABLE `thong_bao`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=312;

--
-- Các ràng buộc cho các bảng đã đổ
--

--
-- Các ràng buộc cho bảng `cham_cong`
--
ALTER TABLE `cham_cong`
  ADD CONSTRAINT `cham_cong_ibfk_1` FOREIGN KEY (`nhan_vien_id`) REFERENCES `nhanvien` (`id`) ON DELETE CASCADE;

--
-- Các ràng buộc cho bảng `cong_viec`
--
ALTER TABLE `cong_viec`
  ADD CONSTRAINT `cong_viec_ibfk_1` FOREIGN KEY (`nguoi_giao_id`) REFERENCES `nhanvien` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `cong_viec_ibfk_3` FOREIGN KEY (`phong_ban_id`) REFERENCES `phong_ban` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_cong_viec_du_an` FOREIGN KEY (`du_an_id`) REFERENCES `du_an` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Các ràng buộc cho bảng `cong_viec_danh_gia`
--
ALTER TABLE `cong_viec_danh_gia`
  ADD CONSTRAINT `cong_viec_danh_gia_ibfk_1` FOREIGN KEY (`cong_viec_id`) REFERENCES `cong_viec` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `cong_viec_danh_gia_ibfk_2` FOREIGN KEY (`nguoi_danh_gia_id`) REFERENCES `nhanvien` (`id`) ON DELETE CASCADE;

--
-- Các ràng buộc cho bảng `cong_viec_lich_su`
--
ALTER TABLE `cong_viec_lich_su`
  ADD CONSTRAINT `cong_viec_lich_su_ibfk_1` FOREIGN KEY (`cong_viec_id`) REFERENCES `cong_viec` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `cong_viec_lich_su_ibfk_2` FOREIGN KEY (`nguoi_thay_doi_id`) REFERENCES `nhanvien` (`id`) ON DELETE CASCADE;

--
-- Các ràng buộc cho bảng `cong_viec_nguoi_nhan`
--
ALTER TABLE `cong_viec_nguoi_nhan`
  ADD CONSTRAINT `cong_viec_nguoi_nhan_ibfk_1` FOREIGN KEY (`cong_viec_id`) REFERENCES `cong_viec` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `cong_viec_nguoi_nhan_ibfk_2` FOREIGN KEY (`nhan_vien_id`) REFERENCES `nhanvien` (`id`) ON DELETE CASCADE;

--
-- Các ràng buộc cho bảng `cong_viec_quy_trinh`
--
ALTER TABLE `cong_viec_quy_trinh`
  ADD CONSTRAINT `cong_viec_quy_trinh_ibfk_1` FOREIGN KEY (`cong_viec_id`) REFERENCES `cong_viec` (`id`) ON DELETE CASCADE;

--
-- Các ràng buộc cho bảng `cong_viec_tien_do`
--
ALTER TABLE `cong_viec_tien_do`
  ADD CONSTRAINT `cong_viec_tien_do_ibfk_1` FOREIGN KEY (`cong_viec_id`) REFERENCES `cong_viec` (`id`) ON DELETE CASCADE;

--
-- Các ràng buộc cho bảng `file_dinh_kem`
--
ALTER TABLE `file_dinh_kem`
  ADD CONSTRAINT `file_dinh_kem_ibfk_1` FOREIGN KEY (`cong_viec_id`) REFERENCES `cong_viec` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `file_dinh_kem_ibfk_2` FOREIGN KEY (`tien_do_id`) REFERENCES `cong_viec_tien_do` (`id`) ON DELETE CASCADE;

--
-- Các ràng buộc cho bảng `luong`
--
ALTER TABLE `luong`
  ADD CONSTRAINT `luong_ibfk_1` FOREIGN KEY (`nhan_vien_id`) REFERENCES `nhanvien` (`id`) ON DELETE CASCADE;

--
-- Các ràng buộc cho bảng `luu_kpi`
--
ALTER TABLE `luu_kpi`
  ADD CONSTRAINT `luu_kpi_ibfk_1` FOREIGN KEY (`nhan_vien_id`) REFERENCES `nhanvien` (`id`) ON DELETE CASCADE;

--
-- Các ràng buộc cho bảng `nhanvien`
--
ALTER TABLE `nhanvien`
  ADD CONSTRAINT `nhanvien_ibfk_1` FOREIGN KEY (`phong_ban_id`) REFERENCES `phong_ban` (`id`) ON DELETE SET NULL;

--
-- Các ràng buộc cho bảng `nhan_su_lich_su`
--
ALTER TABLE `nhan_su_lich_su`
  ADD CONSTRAINT `nhan_su_lich_su_ibfk_1` FOREIGN KEY (`nhan_vien_id`) REFERENCES `nhanvien` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `nhan_su_lich_su_ibfk_2` FOREIGN KEY (`nguoi_thay_doi_id`) REFERENCES `nhanvien` (`id`) ON DELETE SET NULL;

--
-- Các ràng buộc cho bảng `phong_ban`
--
ALTER TABLE `phong_ban`
  ADD CONSTRAINT `fk_truong_phong` FOREIGN KEY (`truong_phong_id`) REFERENCES `nhanvien` (`id`) ON DELETE SET NULL;

--
-- Các ràng buộc cho bảng `thong_bao`
--
ALTER TABLE `thong_bao`
  ADD CONSTRAINT `thong_bao_ibfk_1` FOREIGN KEY (`nguoi_nhan_id`) REFERENCES `nhanvien` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
