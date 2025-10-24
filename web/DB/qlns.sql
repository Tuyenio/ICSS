-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Máy chủ: 127.0.0.1
-- Thời gian đã tạo: Th10 24, 2025 lúc 08:25 AM
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
  `nhac_viec` int(11) DEFAULT NULL,
  `tinh_trang` varchar(50) DEFAULT NULL,
  `ngay_tao` timestamp NOT NULL DEFAULT current_timestamp(),
  `ngay_bat_dau` date DEFAULT NULL,
  `ngay_hoan_thanh` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `cong_viec`
--

INSERT INTO `cong_viec` (`id`, `du_an_id`, `ten_cong_viec`, `mo_ta`, `han_hoan_thanh`, `muc_do_uu_tien`, `nguoi_giao_id`, `phong_ban_id`, `trang_thai`, `tai_lieu_cv`, `file_tai_lieu`, `nhac_viec`, `tinh_trang`, `ngay_tao`, `ngay_bat_dau`, `ngay_hoan_thanh`) VALUES
(134, 32, '1233', '1', '2025-09-29', 'Thấp', 1, 6, 'Trễ hạn', '11', '', 0, NULL, '2025-10-02 08:00:53', NULL, NULL),
(136, 1, '1', '13132', '2025-10-31', 'Cao', 11, 6, 'Đã hoàn thành', '11', '', 0, NULL, '2025-10-15 04:17:44', '2025-10-22', '2025-10-22'),
(137, 1, 'á chà ơi ú òa', '21312353453', '2025-10-25', 'Cao', 4, 1, 'Chưa bắt đầu', 'null', '', NULL, 'Đã xóa', '2025-10-22 08:17:33', '2025-10-22', NULL),
(138, 1, '21412', '1', '2025-10-24', 'Thấp', 11, 1, 'Chưa bắt đầu', 'có nhé', 'D:/uploads/Bảng điểm.docx', NULL, NULL, '2025-10-23 02:16:40', NULL, NULL),
(140, 32, '21412', '11', '2025-10-24', 'Thấp', 11, 1, 'Chưa bắt đầu', NULL, '', NULL, NULL, '2025-10-23 04:40:03', NULL, NULL);

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

--
-- Đang đổ dữ liệu cho bảng `cong_viec_danh_gia`
--

INSERT INTO `cong_viec_danh_gia` (`id`, `cong_viec_id`, `nguoi_danh_gia_id`, `nhan_xet`, `thoi_gian`) VALUES
(7, 137, 11, 'ổn rồi em', '2025-10-23 02:14:06');

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

--
-- Đang đổ dữ liệu cho bảng `cong_viec_lich_su`
--

INSERT INTO `cong_viec_lich_su` (`id`, `cong_viec_id`, `nguoi_thay_doi_id`, `mo_ta_thay_doi`, `thoi_gian`) VALUES
(77, 138, 18, 'Lưu trữ công việc', '2025-10-23 09:49:50'),
(78, 138, 18, 'Khôi phục công việc', '2025-10-23 09:57:06'),
(79, 137, 18, 'Lưu trữ công việc', '2025-10-24 03:04:36'),
(80, 137, 18, 'Khôi phục công việc', '2025-10-24 04:24:48'),
(81, 137, 18, 'Xóa công việc', '2025-10-24 04:24:58');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `cong_viec_nguoi_nhan`
--

CREATE TABLE `cong_viec_nguoi_nhan` (
  `id` int(11) NOT NULL,
  `cong_viec_id` int(11) NOT NULL,
  `nhan_vien_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `cong_viec_nguoi_nhan`
--

INSERT INTO `cong_viec_nguoi_nhan` (`id`, `cong_viec_id`, `nhan_vien_id`) VALUES
(239, 136, 11),
(240, 136, 18),
(241, 136, 2),
(242, 136, 1),
(243, 136, 13),
(269, 138, 9),
(272, 137, 10),
(273, 137, 3),
(275, 134, 17),
(276, 134, 14),
(277, 134, 8),
(278, 140, 17);

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

--
-- Đang đổ dữ liệu cho bảng `cong_viec_quy_trinh`
--

INSERT INTO `cong_viec_quy_trinh` (`id`, `cong_viec_id`, `ten_buoc`, `mo_ta`, `trang_thai`, `ngay_bat_dau`, `ngay_ket_thuc`, `ngay_tao`) VALUES
(162, 137, 'ok đấy ba chấm', 'á à', 'Chưa bắt đầu', '2025-10-23', '2025-10-24', '2025-10-22 09:50:41');

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

--
-- Đang đổ dữ liệu cho bảng `cong_viec_tien_do`
--

INSERT INTO `cong_viec_tien_do` (`id`, `cong_viec_id`, `phan_tram`, `thoi_gian_cap_nhat`) VALUES
(74, 136, 0, '2025-10-23 08:57:13'),
(75, 137, 0, '2025-10-23 08:56:19'),
(76, 138, 0, '2025-10-23 02:48:04'),
(77, 134, 0, '2025-10-23 04:45:52'),
(78, 140, 0, '2025-10-23 04:45:52');

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
(1, 'Công việc chung', 'Công việc riêng', '2025-09-17', '2035-10-31', '2025-09-17 09:03:49'),
(32, '222', '123', '2025-10-02', '2025-10-11', '2025-10-02 07:41:05');

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
(1, 'Phạm Minh Thắng', 'minhthang@gmail.com', '12345678', '0834035090', 'Nam', '2003-11-23', 6, 'Nhân viên', 20000000.00, 'Đang làm', 'Nhân viên', '2025-09-03', 'https://i.postimg.cc/x1mhwnFR/IMG-8032.jpg', '2025-09-03 03:26:57'),
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
(18, 'xAdmin', 'admin@gmail.com', '12345678', 'Admin', 'Nam', '2025-09-04', 6, 'Giám đốc', 0.00, 'Đang làm', 'Admin', '2025-09-13', 'https://i.postimg.cc/x1mhwnFR/IMG-8032.jpg', '2025-09-04 07:43:56');

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
(314, 'Công việc mới', 'Bạn được giao công việc: 1. Hạn: 2025-09-29.', 1, 'Công việc mới', 0, '2025-09-30 02:15:38', '2025-09-30 02:15:38'),
(315, 'Cập nhật công việc', 'Công việc: 1 vừa được cập nhật mới', 1, 'Cập nhật', 0, '2025-09-30 02:18:33', '2025-09-30 02:18:33'),
(316, 'Cập nhật công việc', 'Công việc: 1 vừa được cập nhật mới', 1, 'Cập nhật', 0, '2025-09-30 02:18:38', '2025-09-30 02:18:38'),
(317, 'Cập nhật công việc', 'Công việc: 1 vừa được cập nhật mới', 1, 'Cập nhật', 0, '2025-09-30 02:42:24', '2025-09-30 02:42:24'),
(318, 'Cập nhật công việc', 'Công việc: 1 vừa được cập nhật mới', 1, 'Cập nhật', 0, '2025-09-30 02:42:59', '2025-09-30 02:42:59'),
(319, 'Cập nhật công việc', 'Công việc: 1 vừa được cập nhật mới', 1, 'Cập nhật', 0, '2025-09-30 02:43:11', '2025-09-30 02:43:11'),
(320, 'Công việc mới', 'Bạn được giao công việc: 1. Hạn: 2025-09-29.', 8, 'Công việc mới', 0, '2025-10-02 08:00:53', '2025-10-02 08:00:53'),
(321, 'Công việc mới', 'Bạn được giao công việc: 1. Hạn: 2025-09-29.', 14, 'Công việc mới', 0, '2025-10-02 08:00:53', '2025-10-02 08:00:53'),
(322, 'Công việc mới', 'Bạn được giao công việc: 1. Hạn: 2025-09-29.', 17, 'Công việc mới', 0, '2025-10-02 08:00:53', '2025-10-02 08:00:53'),
(323, 'Công việc mới', 'Bạn được giao công việc: 1. Hạn: 2025-10-05.', 2, 'Công việc mới', 0, '2025-10-02 08:01:12', '2025-10-02 08:01:12'),
(324, 'Công việc mới', 'Bạn được giao công việc: 1. Hạn: 2025-10-05.', 14, 'Công việc mới', 0, '2025-10-02 08:01:12', '2025-10-02 08:01:12'),
(325, 'Công việc mới', 'Bạn được giao công việc: 1. Hạn: 2025-10-05.', 17, 'Công việc mới', 0, '2025-10-02 08:01:12', '2025-10-02 08:01:12'),
(326, 'Công việc mới', 'Bạn được giao công việc: 1. Hạn: 2025-10-31.', 3, 'Công việc mới', 0, '2025-10-15 04:17:44', '2025-10-15 04:17:44'),
(327, 'Công việc mới', 'Bạn được giao công việc: 1. Hạn: 2025-10-31.', 16, 'Công việc mới', 0, '2025-10-15 04:17:44', '2025-10-15 04:17:44'),
(328, 'Cập nhật công việc', 'Công việc: 1 vừa được cập nhật mới', 3, 'Cập nhật', 0, '2025-10-15 08:37:29', '2025-10-15 08:37:29'),
(329, 'Cập nhật công việc', 'Công việc: 1 vừa được cập nhật mới', 1, 'Cập nhật', 0, '2025-10-15 08:37:29', '2025-10-15 08:37:29'),
(330, 'Cập nhật công việc', 'Công việc: 1 vừa được cập nhật mới', 16, 'Cập nhật', 0, '2025-10-15 08:37:29', '2025-10-15 08:37:29'),
(331, 'Cập nhật công việc', 'Công việc: 1 vừa được cập nhật mới', 11, 'Cập nhật', 0, '2025-10-15 08:44:42', '2025-10-15 08:44:42'),
(332, 'Cập nhật công việc', 'Công việc: 1 vừa được cập nhật mới', 11, 'Cập nhật', 0, '2025-10-15 08:44:49', '2025-10-15 08:44:49'),
(333, 'Cập nhật công việc', 'Công việc: 1 vừa được cập nhật mới', 11, 'Cập nhật', 0, '2025-10-15 08:45:32', '2025-10-15 08:45:32'),
(334, 'Cập nhật công việc', 'Công việc: 1 vừa được cập nhật mới', 18, 'Cập nhật', 0, '2025-10-15 08:45:32', '2025-10-15 08:45:32'),
(335, 'Cập nhật công việc', 'Công việc: 1 vừa được cập nhật mới', 11, 'Cập nhật', 0, '2025-10-15 09:29:24', '2025-10-15 09:29:24'),
(336, 'Cập nhật công việc', 'Công việc: 1 vừa được cập nhật mới', 18, 'Cập nhật', 0, '2025-10-15 09:29:24', '2025-10-15 09:29:24'),
(337, 'Thêm mới quy trình', 'Công việc: 1 vừa được thêm quy trình mới', 11, 'Cập nhật', 0, '2025-10-22 08:05:47', '2025-10-22 08:05:47'),
(338, 'Thêm mới quy trình', 'Công việc: 1 vừa được thêm quy trình mới', 18, 'Cập nhật', 0, '2025-10-22 08:05:47', '2025-10-22 08:05:47'),
(339, 'Cập nhật quy trình', 'Công việc: 1 vừa được cập nhật quy trình mới', 11, 'Cập nhật', 0, '2025-10-22 08:05:56', '2025-10-22 08:05:56'),
(340, 'Cập nhật quy trình', 'Công việc: 1 vừa được cập nhật quy trình mới', 18, 'Cập nhật', 0, '2025-10-22 08:05:56', '2025-10-22 08:05:56'),
(341, 'Cập nhật quy trình', 'Công việc: 1 vừa được cập nhật quy trình mới', 11, 'Cập nhật', 0, '2025-10-22 08:06:06', '2025-10-22 08:06:06'),
(342, 'Cập nhật quy trình', 'Công việc: 1 vừa được cập nhật quy trình mới', 18, 'Cập nhật', 0, '2025-10-22 08:06:06', '2025-10-22 08:06:06'),
(343, 'Cập nhật quy trình', 'Công việc: 1 vừa được cập nhật quy trình mới', 11, 'Cập nhật', 0, '2025-10-22 08:06:18', '2025-10-22 08:06:18'),
(344, 'Cập nhật quy trình', 'Công việc: 1 vừa được cập nhật quy trình mới', 18, 'Cập nhật', 0, '2025-10-22 08:06:18', '2025-10-22 08:06:18'),
(345, 'Cập nhật công việc', 'Công việc: 1 vừa được cập nhật mới', 11, 'Cập nhật', 0, '2025-10-22 08:06:27', '2025-10-22 08:06:27'),
(346, 'Cập nhật công việc', 'Công việc: 1 vừa được cập nhật mới', 18, 'Cập nhật', 0, '2025-10-22 08:06:27', '2025-10-22 08:06:27'),
(347, 'Xóa bỏ quy trình', 'Công việc: 1 vừa xóa bỏ một quy trình', 11, 'Cập nhật', 0, '2025-10-22 08:06:58', '2025-10-22 08:06:58'),
(348, 'Xóa bỏ quy trình', 'Công việc: 1 vừa xóa bỏ một quy trình', 18, 'Cập nhật', 0, '2025-10-22 08:06:58', '2025-10-22 08:06:58'),
(349, 'Cập nhật công việc', 'Công việc: 1 vừa được cập nhật mới', 11, 'Cập nhật', 0, '2025-10-22 08:09:53', '2025-10-22 08:09:53'),
(350, 'Cập nhật công việc', 'Công việc: 1 vừa được cập nhật mới', 18, 'Cập nhật', 0, '2025-10-22 08:09:53', '2025-10-22 08:09:53'),
(351, 'Cập nhật công việc', 'Công việc: 1 vừa được cập nhật mới', 11, 'Cập nhật', 0, '2025-10-22 08:10:03', '2025-10-22 08:10:03'),
(352, 'Cập nhật công việc', 'Công việc: 1 vừa được cập nhật mới', 18, 'Cập nhật', 0, '2025-10-22 08:10:03', '2025-10-22 08:10:03'),
(353, 'Công việc mới', 'Bạn được giao công việc: 21412. Hạn: 2025-10-22.', 10, 'Công việc mới', 0, '2025-10-22 08:17:33', '2025-10-22 08:17:33'),
(354, 'Công việc mới', 'Bạn được giao công việc: 21412. Hạn: 2025-10-22.', 3, 'Công việc mới', 0, '2025-10-22 08:17:33', '2025-10-22 08:17:33'),
(355, 'Cập nhật công việc', 'Công việc: 3333 vừa được cập nhật mới', 10, 'Cập nhật', 0, '2025-10-22 08:37:58', '2025-10-22 08:37:58'),
(356, 'Cập nhật công việc', 'Công việc: 3333 vừa được cập nhật mới', 3, 'Cập nhật', 0, '2025-10-22 08:37:58', '2025-10-22 08:37:58'),
(357, 'Cập nhật công việc', 'Công việc: 1 vừa được cập nhật mới', 11, 'Cập nhật', 0, '2025-10-22 08:48:39', '2025-10-22 08:48:39'),
(358, 'Cập nhật công việc', 'Công việc: 1 vừa được cập nhật mới', 18, 'Cập nhật', 0, '2025-10-22 08:48:39', '2025-10-22 08:48:39'),
(359, 'Cập nhật công việc', 'Công việc: 1 vừa được cập nhật mới', 2, 'Cập nhật', 0, '2025-10-22 08:48:39', '2025-10-22 08:48:39'),
(360, 'Cập nhật công việc', 'Công việc: 1 vừa được cập nhật mới', 1, 'Cập nhật', 0, '2025-10-22 08:48:39', '2025-10-22 08:48:39'),
(361, 'Cập nhật công việc', 'Công việc: 1 vừa được cập nhật mới', 13, 'Cập nhật', 0, '2025-10-22 08:48:39', '2025-10-22 08:48:39'),
(362, 'Cập nhật công việc', 'Công việc: 3333 vừa được cập nhật mới', 10, 'Cập nhật', 0, '2025-10-22 08:52:08', '2025-10-22 08:52:08'),
(363, 'Cập nhật công việc', 'Công việc: 3333 vừa được cập nhật mới', 3, 'Cập nhật', 0, '2025-10-22 08:52:08', '2025-10-22 08:52:08'),
(364, 'Cập nhật công việc', 'Công việc: 333377 vừa được cập nhật mới', 10, 'Cập nhật', 0, '2025-10-22 09:28:28', '2025-10-22 09:28:28'),
(365, 'Cập nhật công việc', 'Công việc: 333377 vừa được cập nhật mới', 3, 'Cập nhật', 0, '2025-10-22 09:28:28', '2025-10-22 09:28:28'),
(366, 'Cập nhật công việc', 'Công việc: 33337711 vừa được cập nhật mới', 10, 'Cập nhật', 0, '2025-10-22 09:47:09', '2025-10-22 09:47:09'),
(367, 'Cập nhật công việc', 'Công việc: 33337711 vừa được cập nhật mới', 3, 'Cập nhật', 0, '2025-10-22 09:47:09', '2025-10-22 09:47:09'),
(368, 'Cập nhật công việc', 'Công việc: 33337 vừa được cập nhật mới', 10, 'Cập nhật', 0, '2025-10-22 09:47:37', '2025-10-22 09:47:37'),
(369, 'Cập nhật công việc', 'Công việc: 33337 vừa được cập nhật mới', 3, 'Cập nhật', 0, '2025-10-22 09:47:37', '2025-10-22 09:47:37'),
(370, 'Thêm mới quy trình', 'Công việc: 33337 vừa được thêm quy trình mới', 10, 'Cập nhật', 0, '2025-10-22 09:50:41', '2025-10-22 09:50:41'),
(371, 'Thêm mới quy trình', 'Công việc: 33337 vừa được thêm quy trình mới', 3, 'Cập nhật', 0, '2025-10-22 09:50:41', '2025-10-22 09:50:41'),
(372, 'Cập nhật công việc', 'Công việc: 333377 vừa được cập nhật mới', 10, 'Cập nhật', 0, '2025-10-22 09:55:01', '2025-10-22 09:55:01'),
(373, 'Cập nhật công việc', 'Công việc: 333377 vừa được cập nhật mới', 3, 'Cập nhật', 0, '2025-10-22 09:55:01', '2025-10-22 09:55:01'),
(374, 'Cập nhật công việc', 'Công việc: 33337711 vừa được cập nhật mới', 10, 'Cập nhật', 0, '2025-10-22 09:55:15', '2025-10-22 09:55:15'),
(375, 'Cập nhật công việc', 'Công việc: 33337711 vừa được cập nhật mới', 3, 'Cập nhật', 0, '2025-10-22 09:55:15', '2025-10-22 09:55:15'),
(376, 'Cập nhật công việc', 'Công việc: 33337711 vừa được cập nhật mới', 10, 'Cập nhật', 0, '2025-10-22 09:55:44', '2025-10-22 09:55:44'),
(377, 'Cập nhật công việc', 'Công việc: 33337711 vừa được cập nhật mới', 3, 'Cập nhật', 0, '2025-10-22 09:55:44', '2025-10-22 09:55:44'),
(378, 'Cập nhật quy trình', 'Công việc: 33337711 vừa được cập nhật quy trình mới', 10, 'Cập nhật', 0, '2025-10-22 09:56:22', '2025-10-22 09:56:22'),
(379, 'Cập nhật quy trình', 'Công việc: 33337711 vừa được cập nhật quy trình mới', 3, 'Cập nhật', 0, '2025-10-22 09:56:22', '2025-10-22 09:56:22'),
(380, 'Cập nhật công việc', 'Công việc: 33337711 vừa được cập nhật mới', 10, 'Cập nhật', 0, '2025-10-22 09:56:42', '2025-10-22 09:56:42'),
(381, 'Cập nhật công việc', 'Công việc: 33337711 vừa được cập nhật mới', 3, 'Cập nhật', 0, '2025-10-22 09:56:42', '2025-10-22 09:56:42'),
(382, 'Cập nhật công việc', 'Công việc: 33337711 vừa được cập nhật mới', 16, 'Cập nhật', 0, '2025-10-22 09:56:42', '2025-10-22 09:56:42'),
(383, 'Cập nhật công việc', 'Công việc: úi zời vừa được cập nhật mới', 10, 'Cập nhật', 0, '2025-10-23 02:10:15', '2025-10-23 02:10:15'),
(384, 'Cập nhật công việc', 'Công việc: úi zời vừa được cập nhật mới', 3, 'Cập nhật', 0, '2025-10-23 02:10:15', '2025-10-23 02:10:15'),
(385, 'Cập nhật công việc', 'Công việc: úi zời vừa được cập nhật mới', 16, 'Cập nhật', 0, '2025-10-23 02:10:15', '2025-10-23 02:10:15'),
(386, 'Cập nhật công việc', 'Công việc: úi zời vừa được cập nhật mới', 10, 'Cập nhật', 0, '2025-10-23 02:10:37', '2025-10-23 02:10:37'),
(387, 'Cập nhật công việc', 'Công việc: úi zời vừa được cập nhật mới', 3, 'Cập nhật', 0, '2025-10-23 02:10:37', '2025-10-23 02:10:37'),
(388, 'Cập nhật công việc', 'Công việc: úi zời vừa được cập nhật mới', 10, 'Cập nhật', 0, '2025-10-23 02:10:54', '2025-10-23 02:10:54'),
(389, 'Cập nhật công việc', 'Công việc: úi zời vừa được cập nhật mới', 3, 'Cập nhật', 0, '2025-10-23 02:10:54', '2025-10-23 02:10:54'),
(390, 'Cập nhật quy trình', 'Công việc: úi zời vừa được cập nhật quy trình mới', 10, 'Cập nhật', 0, '2025-10-23 02:11:31', '2025-10-23 02:11:31'),
(391, 'Cập nhật quy trình', 'Công việc: úi zời vừa được cập nhật quy trình mới', 3, 'Cập nhật', 0, '2025-10-23 02:11:31', '2025-10-23 02:11:31'),
(392, 'Cập nhật quy trình', 'Công việc: úi zời vừa được cập nhật quy trình mới', 10, 'Cập nhật', 0, '2025-10-23 02:12:16', '2025-10-23 02:12:16'),
(393, 'Cập nhật quy trình', 'Công việc: úi zời vừa được cập nhật quy trình mới', 3, 'Cập nhật', 0, '2025-10-23 02:12:16', '2025-10-23 02:12:16'),
(394, 'Đánh giá công việc mới', 'Bạn vừa có thêm đánh giá cho công việc.', 10, 'Đánh giá', 0, '2025-10-23 02:14:06', '2025-10-23 02:14:06'),
(395, 'Đánh giá công việc mới', 'Bạn vừa có thêm đánh giá cho công việc.', 3, 'Đánh giá', 0, '2025-10-23 02:14:06', '2025-10-23 02:14:06'),
(396, 'Công việc mới', 'Bạn được giao công việc: 21412. Hạn: 2025-10-24.', 9, 'Công việc mới', 0, '2025-10-23 02:16:40', '2025-10-23 02:16:40'),
(397, 'Cập nhật công việc', 'Công việc: 21412 vừa được cập nhật mới', 9, 'Cập nhật', 0, '2025-10-23 02:17:44', '2025-10-23 02:17:44'),
(398, 'Cập nhật công việc', 'Công việc: á chà ơi vừa được cập nhật mới', 10, 'Cập nhật', 0, '2025-10-23 02:23:08', '2025-10-23 02:23:08'),
(399, 'Cập nhật công việc', 'Công việc: á chà ơi vừa được cập nhật mới', 3, 'Cập nhật', 0, '2025-10-23 02:23:08', '2025-10-23 02:23:08'),
(400, 'Cập nhật quy trình', 'Công việc: á chà ơi vừa được cập nhật quy trình mới', 10, 'Cập nhật', 0, '2025-10-23 02:46:34', '2025-10-23 02:46:34'),
(401, 'Cập nhật quy trình', 'Công việc: á chà ơi vừa được cập nhật quy trình mới', 3, 'Cập nhật', 0, '2025-10-23 02:46:34', '2025-10-23 02:46:34'),
(402, 'Cập nhật quy trình', 'Công việc: á chà ơi vừa được cập nhật quy trình mới', 10, 'Cập nhật', 0, '2025-10-23 02:46:50', '2025-10-23 02:46:50'),
(403, 'Cập nhật quy trình', 'Công việc: á chà ơi vừa được cập nhật quy trình mới', 3, 'Cập nhật', 0, '2025-10-23 02:46:50', '2025-10-23 02:46:50'),
(404, 'Cập nhật quy trình', 'Công việc: á chà ơi vừa được cập nhật quy trình mới', 10, 'Cập nhật', 0, '2025-10-23 02:47:15', '2025-10-23 02:47:15'),
(405, 'Cập nhật quy trình', 'Công việc: á chà ơi vừa được cập nhật quy trình mới', 3, 'Cập nhật', 0, '2025-10-23 02:47:15', '2025-10-23 02:47:15'),
(406, 'Cập nhật quy trình', 'Công việc: á chà ơi vừa được cập nhật quy trình mới', 10, 'Cập nhật', 0, '2025-10-23 02:47:30', '2025-10-23 02:47:30'),
(407, 'Cập nhật quy trình', 'Công việc: á chà ơi vừa được cập nhật quy trình mới', 3, 'Cập nhật', 0, '2025-10-23 02:47:30', '2025-10-23 02:47:30'),
(408, 'Cập nhật công việc', 'Công việc: á chà ơi ú òa vừa được cập nhật mới', 10, 'Cập nhật', 0, '2025-10-23 02:51:15', '2025-10-23 02:51:15'),
(409, 'Cập nhật công việc', 'Công việc: á chà ơi ú òa vừa được cập nhật mới', 3, 'Cập nhật', 0, '2025-10-23 02:51:15', '2025-10-23 02:51:15'),
(410, 'Công việc mới', 'Bạn được giao công việc: 21412. Hạn: 2025-10-24.', 16, 'Công việc mới', 0, '2025-10-23 04:23:35', '2025-10-23 04:23:35'),
(411, 'Cập nhật công việc', 'Công việc: 1233 vừa được cập nhật mới', 17, 'Cập nhật', 0, '2025-10-23 04:24:32', '2025-10-23 04:24:32'),
(412, 'Cập nhật công việc', 'Công việc: 1233 vừa được cập nhật mới', 14, 'Cập nhật', 0, '2025-10-23 04:24:32', '2025-10-23 04:24:32'),
(413, 'Cập nhật công việc', 'Công việc: 1233 vừa được cập nhật mới', 8, 'Cập nhật', 0, '2025-10-23 04:24:32', '2025-10-23 04:24:32'),
(414, 'Công việc mới', 'Bạn được giao công việc: 21412. Hạn: 2025-10-24.', 17, 'Công việc mới', 0, '2025-10-23 04:40:03', '2025-10-23 04:40:03');

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
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=141;

--
-- AUTO_INCREMENT cho bảng `cong_viec_danh_gia`
--
ALTER TABLE `cong_viec_danh_gia`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT cho bảng `cong_viec_lich_su`
--
ALTER TABLE `cong_viec_lich_su`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=82;

--
-- AUTO_INCREMENT cho bảng `cong_viec_nguoi_nhan`
--
ALTER TABLE `cong_viec_nguoi_nhan`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=279;

--
-- AUTO_INCREMENT cho bảng `cong_viec_quy_trinh`
--
ALTER TABLE `cong_viec_quy_trinh`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=163;

--
-- AUTO_INCREMENT cho bảng `cong_viec_tien_do`
--
ALTER TABLE `cong_viec_tien_do`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=79;

--
-- AUTO_INCREMENT cho bảng `du_an`
--
ALTER TABLE `du_an`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=33;

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
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=415;

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
