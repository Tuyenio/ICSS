-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Máy chủ: 127.0.0.1
-- Thời gian đã tạo: Th9 11, 2025 lúc 11:09 AM
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

--
-- Đang đổ dữ liệu cho bảng `cham_cong`
--

INSERT INTO `cham_cong` (`id`, `nhan_vien_id`, `ngay`, `check_in`, `check_out`) VALUES
(419, 9, '2025-09-04', '04:42:51', '04:46:37'),
(420, 8, '2025-09-04', '06:31:43', NULL),
(421, 14, '2025-09-04', '07:35:17', NULL),
(422, 2, '2025-09-04', '08:24:12', '08:24:40'),
(423, 14, '2025-09-08', '10:05:48', '10:05:52'),
(424, 9, '2025-09-09', '01:34:12', '12:02:34'),
(425, 7, '2025-09-09', '01:45:57', NULL),
(426, 1, '2025-09-09', '02:04:15', '02:56:22'),
(427, 2, '2025-09-09', '10:17:43', '10:18:02'),
(428, 5, '2025-09-09', '15:52:20', '15:52:26'),
(429, 15, '2025-09-09', '17:30:25', '17:30:30'),
(430, 9, '2025-09-10', '08:22:35', '12:24:03'),
(431, 15, '2025-09-10', '08:34:53', NULL),
(432, 1, '2025-09-10', '08:46:44', NULL),
(433, 2, '2025-09-10', '08:48:19', NULL);

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `cong_viec`
--

CREATE TABLE `cong_viec` (
  `id` int(11) NOT NULL,
  `ten_cong_viec` varchar(255) NOT NULL,
  `mo_ta` text DEFAULT NULL,
  `han_hoan_thanh` date DEFAULT NULL,
  `muc_do_uu_tien` enum('Thấp','Trung bình','Cao') DEFAULT 'Trung bình',
  `nguoi_giao_id` int(11) DEFAULT NULL,
  `nguoi_nhan_id` int(11) DEFAULT NULL,
  `phong_ban_id` int(11) DEFAULT NULL,
  `trang_thai` enum('Chưa bắt đầu','Đang thực hiện','Đã hoàn thành','Trễ hạn') DEFAULT 'Chưa bắt đầu',
  `tai_lieu_cv` varchar(255) DEFAULT NULL,
  `ngay_tao` timestamp NOT NULL DEFAULT current_timestamp(),
  `ngay_bat_dau` date DEFAULT NULL,
  `ngay_hoan_thanh` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `cong_viec`
--

INSERT INTO `cong_viec` (`id`, `ten_cong_viec`, `mo_ta`, `han_hoan_thanh`, `muc_do_uu_tien`, `nguoi_giao_id`, `nguoi_nhan_id`, `phong_ban_id`, `trang_thai`, `tai_lieu_cv`, `ngay_tao`, `ngay_bat_dau`, `ngay_hoan_thanh`) VALUES
(51, 'Lên đề xuất dự án TKV', 'Dũng hỗ trợ', '2025-09-11', 'Cao', 11, 6, 7, 'Chưa bắt đầu', '', '2025-09-08 04:35:56', NULL, NULL),
(52, 'Gửi lại bảng lương T8.2025', '', '2025-09-09', 'Trung bình', 12, 7, 1, 'Đã hoàn thành', '', '2025-09-08 07:07:01', '2025-09-09', '2025-09-09'),
(53, 'Kế hoạch đăng bài', 'Lên kế hoạch đăng bài và đăng bài cho tuần này. Liên quan đến vấn tiết kiệm chi phí khi sử dụng Dashboard, bài toán CFO.', '2025-09-09', 'Trung bình', 11, 15, 7, 'Trễ hạn', '', '2025-09-08 08:14:00', NULL, NULL),
(57, 'Kế hoạch đăng bài', 'Lên kế hoạch đăng bài và đăng bài về ANM. Đưa ra các \"nổi đau\" khách hàng khi bị tấn công mang và ICS giải quyết các vấn đề này ntn? Xây dựng các infographic về ANM', '2025-09-09', 'Trung bình', 11, 13, 7, 'Trễ hạn', '', '2025-09-08 08:29:50', NULL, NULL),
(58, 'Kế hoạch đăng bài', 'Lê kế hoạch đăng bài và đăng bài về OCI. Chú ý tới vấn đề tiết kiệm chi phí, khách hàng hướng đến là CTO', '2025-09-09', 'Trung bình', 11, 9, 7, 'Trễ hạn', '', '2025-09-08 08:31:12', NULL, NULL),
(61, 'Thiết kế Template ', '- Thư ngỏ\r\n- Giấy giới thiệu \r\n- Thư trả lời \r\n- Powerpoint template \r\n... các template cần cho công ty ', '2025-09-12', 'Trung bình', 4, 13, 7, 'Chưa bắt đầu', '', '2025-09-10 06:52:18', NULL, NULL),
(62, 'chính sách giá sản phẩm', '', '2025-12-09', 'Trung bình', 10, 11, 7, 'Chưa bắt đầu', '', '2025-09-10 07:02:34', NULL, NULL),
(63, 'chính sách lương thưởng cho nhân viên ', '', '2025-12-09', 'Trung bình', 10, 11, 7, 'Chưa bắt đầu', '', '2025-09-10 07:03:33', NULL, NULL),
(64, 'hoàn thiện danh sách 500 doanh nghiệp', 'Đưa ra kịch bản gọi điện cho các bạn tts liên hệ', '2025-12-09', 'Cao', 10, 11, 7, 'Chưa bắt đầu', '', '2025-09-10 07:04:55', NULL, NULL),
(65, 'lên kế hoạch triển khai KPI cho từng đơn vị', '', '2025-12-09', 'Cao', 10, 11, 7, 'Chưa bắt đầu', '', '2025-09-10 07:07:38', NULL, NULL),
(66, 'đăng bài truyền thông', '7 bài, video ~3p /1 tuần trong đó 20/80 20-sp, 80- xu thế/Dẫn bài trang Web', '2025-12-09', 'Trung bình', 10, 11, 7, 'Chưa bắt đầu', '', '2025-09-10 07:08:27', NULL, NULL),
(67, 'lên kế hoạch sự kiện ( trong và ngoài nước )', 'Lên kế hoạch sự kiện trong và ngoài nước ( từ giờ cho đến cuối năm, năm sau,…)', '2025-12-09', 'Trung bình', 10, 11, 7, 'Chưa bắt đầu', '', '2025-09-10 07:11:04', NULL, NULL),
(68, 'làm việc trực tiếp với các đối tác đã kí', 'Làm việc tiếp vs các đối tác đã/ chuẩn bị kí MoU, cụ thể các công việc ( Dương hỗ trợ)', '2025-12-09', 'Trung bình', 10, 11, 7, 'Chưa bắt đầu', '', '2025-09-10 07:11:53', NULL, NULL),
(69, 'đánh giá các đối thủ cạnh tranh an ninh mạng', '- Trao đổi vs Oracle, tổ chức các buổi  onl webinar (Dương, Linh hỗ trợ)\r\n', '2025-12-09', 'Trung bình', 10, 11, 7, 'Chưa bắt đầu', '', '2025-09-10 07:13:02', NULL, NULL),
(70, 'triển khai chương trình đào tạo về an toàn thông tin', 'Triển khai trực tiếp , AI triển khai onl để thuận lợi cho ng học \r\n( Linh tham gia cùng đội KT, A Âu mời các đối tác triển khai khác), p.tich Mobile App theo thông tư 50 ', '2025-12-09', 'Trung bình', 10, 6, 6, 'Chưa bắt đầu', '', '2025-09-10 07:14:34', NULL, NULL),
(71, 'chỉnh sửa lại web công ty', '', '2025-12-09', 'Cao', 10, 8, 6, 'Chưa bắt đầu', '', '2025-09-10 07:15:36', NULL, NULL),
(72, 'đề xuất bộ phận tiếp nhận thông tin khách hàng cho việc bán hàng OCI', '(đội KT cần ngồi lại về OCI live, công cụ ANBM,…). Đồng thời, giao lại cho anh Trung để bán hàng', '2025-12-09', 'Trung bình', 10, 6, 6, 'Chưa bắt đầu', '', '2025-09-10 07:17:05', NULL, NULL),
(73, 'lắp đặt server', 'AI SOC-Allen cho đội sang lắp đặt, anh Hanh bố trí bạn bên đội KT để học hỏi', '2025-12-09', 'Trung bình', 10, 6, 6, 'Chưa bắt đầu', '', '2025-09-10 07:18:55', NULL, NULL),
(75, 'lên phương án kinh doanh CLOUD cùng G Group', '', '2025-09-19', 'Trung bình', 10, 11, 7, 'Chưa bắt đầu', '', '2025-09-11 02:32:10', NULL, NULL),
(76, 'hoàn chỉnh hướng dẫn sử dụng ICS CIM ( trình bày bằng video hoặc pp ) ', '', '2025-09-15', 'Cao', 10, 1, 6, 'Đang thực hiện', '', '2025-09-11 02:36:12', '2025-09-11', NULL),
(78, '11', '1', '2025-09-27', 'Thấp', 7, NULL, 6, 'Đang thực hiện', '111', '2025-09-11 07:58:35', '2025-09-11', NULL);

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
(7, 78, 1, '1', '2025-09-11 08:32:16'),
(8, 78, 2, '131213', '2025-09-11 08:32:30'),
(9, 78, 1, '11mm', '2025-09-11 08:33:55'),
(10, 78, 1, '31231', '2025-09-11 08:35:25');

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

--
-- Đang đổ dữ liệu cho bảng `cong_viec_nguoi_nhan`
--

INSERT INTO `cong_viec_nguoi_nhan` (`id`, `cong_viec_id`, `nhan_vien_id`) VALUES
(1, 76, 1),
(3, 78, 1),
(4, 78, 2);

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
(122, 52, 'Bước 1', 'Tạo file excel', 'Đã hoàn thành', '2025-09-08', '2025-09-09', '2025-09-08 09:07:16'),
(123, 52, 'Bước 2', 'Gửi từng nhân viên check lại bảng lương của họ', 'Đã hoàn thành', '2025-09-09', '2025-09-09', '2025-09-08 09:07:55'),
(124, 52, 'Bước 3', 'Gửi lại file cuối cùng cho Ms.Yến', 'Đã hoàn thành', '2025-09-09', '2025-09-09', '2025-09-08 09:08:31'),
(128, 76, 'bước 1', 'Thắng và Tuyền hoàn thiện sớm', 'Đang thực hiện', '2025-09-11', '2025-09-15', '2025-09-11 02:37:36'),
(129, 76, 'bước 2', 'báo cáo lại kết quả cho Mrs. Yến', 'Chưa bắt đầu', '2025-09-11', '2025-09-15', '2025-09-11 02:38:57'),
(134, 78, 'abc', '1', 'Đã hoàn thành', '2025-08-21', '2025-09-19', '2025-09-11 08:10:17'),
(136, 78, 'Thuthu11', '1', 'Chưa bắt đầu', '2025-08-21', '2025-09-19', '2025-09-11 08:24:50');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `cong_viec_tien_do`
--

CREATE TABLE `cong_viec_tien_do` (
  `id` int(11) NOT NULL,
  `cong_viec_id` int(11) DEFAULT NULL,
  `phan_tram` int(11) DEFAULT NULL,
  `thoi_gian_cap_nhat` timestamp NOT NULL DEFAULT current_timestamp()
) ;

--
-- Đang đổ dữ liệu cho bảng `cong_viec_tien_do`
--

INSERT INTO `cong_viec_tien_do` (`id`, `cong_viec_id`, `phan_tram`, `thoi_gian_cap_nhat`) VALUES
(29, 51, 0, '2025-09-11 07:21:08'),
(30, 52, 100, '2025-09-11 02:40:02'),
(33, 53, 0, '2025-09-11 02:47:19'),
(34, 57, 0, '2025-09-10 06:50:53'),
(35, 58, 0, '2025-09-11 07:18:44'),
(38, 61, 0, '2025-09-11 07:22:03'),
(39, 62, 0, '2025-09-11 02:47:27'),
(40, 69, 0, '2025-09-11 02:50:27'),
(41, 73, 0, '2025-09-11 07:22:42'),
(42, 70, 0, '2025-09-10 07:44:23'),
(43, 71, 0, '2025-09-10 07:44:35'),
(45, 63, 0, '2025-09-11 02:47:50'),
(46, 75, 0, '2025-09-11 07:25:01'),
(47, 76, 0, '2025-09-11 07:57:42'),
(48, 64, 0, '2025-09-11 02:48:31'),
(49, 65, 0, '2025-09-11 02:48:45'),
(50, 72, 0, '2025-09-11 07:18:37'),
(52, 78, 50, '2025-09-11 08:53:56');

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
(1, 'Phạm Minh Thắng', 'minhthang@gmail.com', '11112222', '0834035090', 'Nam', '2003-11-23', 6, 'Nhân viên', 20000000.00, 'Đang làm', 'Nhân viên', '2025-09-03', 'https://i.postimg.cc/C5Z5RWgt/z5863399686673-df5230e1f84835bf20b88f032388d49d.jpg', '2025-09-03 03:26:57'),
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
(27, 'Công việc mới', 'Bạn được giao công việc: Test việc cho Dũng. Hạn: 2025-09-10.', 3, 'Công việc mới', 0, '2025-09-04 04:34:38', '2025-09-04 04:34:38'),
(28, 'Công việc mới', 'Bạn được giao công việc: Test việc cho Quỳnh. Hạn: 2025-09-10.', 7, 'Công việc mới', 1, '2025-09-08 04:31:26', '2025-09-04 04:35:22'),
(29, 'Công việc mới', 'Bạn được giao công việc: Test việc cho Chiến. Hạn: 2025-09-10.', 5, 'Công việc mới', 1, '2025-09-04 04:48:44', '2025-09-04 04:35:47'),
(30, 'Công việc mới', 'Bạn được giao công việc: Test việc cho Dương. Hạn: 2025-09-09.', 10, 'Công việc mới', 1, '2025-09-04 04:37:57', '2025-09-04 04:36:28'),
(31, 'Cập nhật công việc', 'Công việc: Test việc cho Dũng vừa được cập nhật mới', 3, 'Cập nhật', 0, '2025-09-04 04:36:37', '2025-09-04 04:36:37'),
(32, 'Cập nhật công việc', 'Công việc: Test việc cho Quỳnh vừa được cập nhật mới', 7, 'Cập nhật', 1, '2025-09-08 04:31:30', '2025-09-04 04:36:45'),
(33, 'Cập nhật công việc', 'Công việc: Test việc cho Chiến vừa được cập nhật mới', 5, 'Cập nhật', 1, '2025-09-04 04:48:43', '2025-09-04 04:36:54'),
(34, 'Công việc mới', 'Bạn được giao công việc: Test việc cho Nam. Hạn: 2025-09-09.', 8, 'Công việc mới', 1, '2025-09-04 04:47:43', '2025-09-04 04:37:28'),
(35, 'Công việc mới', 'Bạn được giao công việc: Test việc cho Vinh. Hạn: 2025-09-09.', 9, 'Công việc mới', 1, '2025-09-04 04:42:03', '2025-09-04 04:37:57'),
(36, 'Nhân viên mới', 'Phòng Marketing & Sale: vừa thêm một nhân viên mới.', 11, 'Nhân viên mới', 1, '2025-09-08 04:25:55', '2025-09-04 04:42:04'),
(37, 'Thêm mới quy trình', 'Công việc: Test việc cho Dũng vừa được thêm quy trình mới', 3, 'Thêm mới', 0, '2025-09-04 04:43:36', '2025-09-04 04:43:36'),
(38, 'Cập nhật quy trình', 'Công việc: Test việc cho Dũng vừa được cập nhật quy trình mới', 3, 'Cập nhật', 0, '2025-09-04 04:44:08', '2025-09-04 04:44:08'),
(39, 'Cập nhật quy trình', 'Công việc: Test việc cho Dũng vừa được cập nhật quy trình mới', 3, 'Cập nhật', 0, '2025-09-04 04:44:13', '2025-09-04 04:44:13'),
(40, 'Thêm mới quy trình', 'Công việc: Test việc cho Quỳnh vừa được thêm quy trình mới', 7, 'Thêm mới', 1, '2025-09-08 04:33:29', '2025-09-04 04:44:52'),
(41, 'Cập nhật quy trình', 'Công việc: Test việc cho Quỳnh vừa được cập nhật quy trình mới', 7, 'Cập nhật', 1, '2025-09-08 04:33:24', '2025-09-04 04:45:05'),
(42, 'Cập nhật công việc', 'Công việc: Test việc cho Dũng vừa được cập nhật mới', 3, 'Cập nhật', 0, '2025-09-04 04:45:19', '2025-09-04 04:45:19'),
(43, 'Công việc mới', 'Bạn được giao công việc: Test việc cho Nam. Hạn: 2025-09-09.', 8, 'Công việc mới', 1, '2025-09-04 06:32:33', '2025-09-04 04:48:54'),
(44, 'Thêm mới quy trình', 'Công việc: Test việc cho Nam vừa được thêm quy trình mới', 8, 'Thêm mới', 1, '2025-09-04 06:32:33', '2025-09-04 04:49:17'),
(45, 'Cập nhật quy trình', 'Công việc: Test việc cho Nam vừa được cập nhật quy trình mới', 8, 'Cập nhật', 1, '2025-09-04 06:32:33', '2025-09-04 04:50:01'),
(46, 'Thêm mới quy trình', 'Công việc: Test việc cho Chiến vừa được thêm quy trình mới', 5, 'Thêm mới', 0, '2025-09-04 04:50:11', '2025-09-04 04:50:11'),
(47, 'Cập nhật quy trình', 'Công việc: Test việc cho Nam vừa được cập nhật quy trình mới', 8, 'Cập nhật', 1, '2025-09-04 06:32:32', '2025-09-04 04:50:12'),
(48, 'Cập nhật quy trình', 'Công việc: Test việc cho Chiến vừa được cập nhật quy trình mới', 5, 'Cập nhật', 0, '2025-09-04 04:50:17', '2025-09-04 04:50:17'),
(49, 'Cập nhật quy trình', 'Công việc: Test việc cho Nam vừa được cập nhật quy trình mới', 8, 'Cập nhật', 1, '2025-09-04 06:32:31', '2025-09-04 04:51:33'),
(50, 'Cập nhật quy trình', 'Công việc: Test việc cho Nam vừa được cập nhật quy trình mới', 8, 'Cập nhật', 1, '2025-09-04 06:32:30', '2025-09-04 05:15:46'),
(51, 'Cập nhật công việc', 'Công việc: Test việc cho Dũng vừa được cập nhật mới', 3, 'Cập nhật', 0, '2025-09-04 06:36:37', '2025-09-04 06:36:37'),
(52, 'Cập nhật quy trình', 'Công việc: Test việc cho Chiến vừa được cập nhật quy trình mới', 5, 'Cập nhật', 0, '2025-09-04 06:47:35', '2025-09-04 06:47:35'),
(53, 'Cập nhật quy trình', 'Công việc: Test việc cho Dũng vừa được cập nhật quy trình mới', 3, 'Cập nhật', 0, '2025-09-04 06:57:20', '2025-09-04 06:57:20'),
(54, 'Công việc mới', 'Bạn được giao công việc: Tích hợp thanh toán online. Hạn: 2025-09-19.', 1, 'Công việc mới', 0, '2025-09-08 04:31:00', '2025-09-08 04:31:00'),
(55, 'Thêm mới quy trình', 'Công việc: Tích hợp thanh toán online vừa được thêm quy trình mới', 1, 'Thêm mới', 0, '2025-09-08 04:31:22', '2025-09-08 04:31:22'),
(56, 'Công việc mới', 'Bạn được giao công việc: ewqee. Hạn: 2025-09-20.', 9, 'Công việc mới', 1, '2025-09-08 09:06:40', '2025-09-08 04:35:18'),
(57, 'Công việc mới', 'Bạn được giao công việc: ewqee. Hạn: 2025-09-20.', 9, 'Công việc mới', 0, '2025-09-08 04:35:19', '2025-09-08 04:35:19'),
(58, 'Công việc mới', 'Bạn được giao công việc: Lên đề xuất dự án TKV. Hạn: 2025-09-11.', 9, 'Công việc mới', 1, '2025-09-09 03:01:31', '2025-09-08 04:35:57'),
(59, 'Cập nhật công việc', 'Công việc: Lên đề xuất dự án TKV vừa được cập nhật mới', 9, 'Cập nhật', 1, '2025-09-09 03:01:51', '2025-09-08 07:03:40'),
(60, 'Công việc mới', 'Bạn được giao công việc: Gửi lại bảng lương T8.2025. Hạn: 2025-09-09.', 7, 'Công việc mới', 1, '2025-09-09 01:57:59', '2025-09-08 07:07:01'),
(61, 'Cập nhật công việc', 'Công việc: Lên đề xuất dự án TKV vừa được cập nhật mới', 9, 'Cập nhật', 1, '2025-09-09 03:01:52', '2025-09-08 07:43:47'),
(62, 'Cập nhật công việc', 'Công việc: Lên đề xuất dự án TKV vừa được cập nhật mới', 6, 'Cập nhật', 1, '2025-09-09 03:01:46', '2025-09-08 07:44:16'),
(63, 'Cập nhật công việc', 'Công việc: Lên đề xuất dự án TKV vừa được cập nhật mới', 6, 'Cập nhật', 1, '2025-09-09 03:01:53', '2025-09-08 07:44:32'),
(64, 'Công việc mới', 'Bạn được giao công việc: Kế hoạch đăng bài. Hạn: 2025-09-09.', 15, 'Công việc mới', 1, '2025-09-09 03:01:54', '2025-09-08 08:14:00'),
(65, 'Cập nhật công việc', 'Công việc: Kế hoạch đăng bài vừa được cập nhật mới', 15, 'Cập nhật', 1, '2025-09-09 03:01:57', '2025-09-08 08:15:05'),
(66, 'Công việc mới', 'Bạn được giao công việc: Kế hoạch đăng bài. Hạn: 2025-09-09.', 13, 'Công việc mới', 1, '2025-09-09 03:01:57', '2025-09-08 08:22:13'),
(67, 'Công việc mới', 'Bạn được giao công việc: Kế hoạch đăng bài. Hạn: 2025-09-09.', 13, 'Công việc mới', 1, '2025-09-09 03:01:58', '2025-09-08 08:23:06'),
(68, 'Công việc mới', 'Bạn được giao công việc: Kế hoạch đăng bài. Hạn: 2025-09-09.', 9, 'Công việc mới', 1, '2025-09-09 03:01:58', '2025-09-08 08:24:17'),
(69, 'Cập nhật công việc', 'Công việc: Kế hoạch đăng bài vừa được cập nhật mới', 13, 'Cập nhật', 1, '2025-09-09 03:01:59', '2025-09-08 08:24:47'),
(70, 'Cập nhật công việc', 'Công việc: Kế hoạch đăng bài vừa được cập nhật mới', 13, 'Cập nhật', 1, '2025-09-09 03:02:00', '2025-09-08 08:25:51'),
(71, 'Cập nhật công việc', 'Công việc: Kế hoạch đăng bài vừa được cập nhật mới', 13, 'Cập nhật', 1, '2025-09-09 03:02:00', '2025-09-08 08:26:07'),
(72, 'Cập nhật công việc', 'Công việc: Kế hoạch đăng bài vừa được cập nhật mới', 13, 'Cập nhật', 1, '2025-09-09 03:02:01', '2025-09-08 08:26:56'),
(73, 'Công việc mới', 'Bạn được giao công việc: Kế hoạch đăng bài. Hạn: 2025-09-09.', 13, 'Công việc mới', 1, '2025-09-09 03:02:01', '2025-09-08 08:29:50'),
(74, 'Công việc mới', 'Bạn được giao công việc: Kế hoạch đăng bài. Hạn: 2025-09-09.', 9, 'Công việc mới', 1, '2025-09-09 03:02:02', '2025-09-08 08:31:12'),
(75, 'Thêm mới quy trình', 'Công việc: Gửi lại bảng lương T8.2025 vừa được thêm quy trình mới', 7, 'Thêm mới', 1, '2025-09-09 01:58:00', '2025-09-08 09:07:16'),
(76, 'Thêm mới quy trình', 'Công việc: Gửi lại bảng lương T8.2025 vừa được thêm quy trình mới', 7, 'Thêm mới', 1, '2025-09-09 01:58:01', '2025-09-08 09:07:55'),
(77, 'Thêm mới quy trình', 'Công việc: Gửi lại bảng lương T8.2025 vừa được thêm quy trình mới', 7, 'Thêm mới', 1, '2025-09-09 01:58:01', '2025-09-08 09:08:31'),
(78, 'Công việc mới', 'Bạn được giao công việc: Test việc cho Linh. Hạn: 2025-09-11.', 16, 'Công việc mới', 1, '2025-09-09 03:19:35', '2025-09-09 03:19:26'),
(79, 'Cập nhật quy trình', 'Công việc: Gửi lại bảng lương T8.2025 vừa được cập nhật quy trình mới', 7, 'Cập nhật', 0, '2025-09-09 03:59:18', '2025-09-09 03:59:18'),
(80, 'Cập nhật quy trình', 'Công việc: Gửi lại bảng lương T8.2025 vừa được cập nhật quy trình mới', 7, 'Cập nhật', 1, '2025-09-09 06:40:49', '2025-09-09 03:59:29'),
(81, 'Cập nhật quy trình', 'Công việc: Gửi lại bảng lương T8.2025 vừa được cập nhật quy trình mới', 7, 'Cập nhật', 1, '2025-09-09 06:40:49', '2025-09-09 03:59:38'),
(82, 'Cập nhật quy trình', 'Công việc: Gửi lại bảng lương T8.2025 vừa được cập nhật quy trình mới', 7, 'Cập nhật', 1, '2025-09-09 06:40:48', '2025-09-09 03:59:48'),
(83, 'Cập nhật quy trình', 'Công việc: Gửi lại bảng lương T8.2025 vừa được cập nhật quy trình mới', 7, 'Cập nhật', 1, '2025-09-09 06:40:48', '2025-09-09 03:59:53'),
(84, 'Cập nhật quy trình', 'Công việc: Gửi lại bảng lương T8.2025 vừa được cập nhật quy trình mới', 7, 'Cập nhật', 1, '2025-09-09 06:40:47', '2025-09-09 04:02:01'),
(85, 'Cập nhật quy trình', 'Công việc: Gửi lại bảng lương T8.2025 vừa được cập nhật quy trình mới', 7, 'Cập nhật', 1, '2025-09-09 06:40:47', '2025-09-09 04:02:29'),
(86, 'Cập nhật quy trình', 'Công việc: Gửi lại bảng lương T8.2025 vừa được cập nhật quy trình mới', 7, 'Cập nhật', 1, '2025-09-09 06:40:46', '2025-09-09 04:02:50'),
(87, 'Cập nhật quy trình', 'Công việc: Gửi lại bảng lương T8.2025 vừa được cập nhật quy trình mới', 7, 'Cập nhật', 1, '2025-09-09 06:40:45', '2025-09-09 04:03:11'),
(88, 'Cập nhật quy trình', 'Công việc: Gửi lại bảng lương T8.2025 vừa được cập nhật quy trình mới', 7, 'Cập nhật', 1, '2025-09-09 06:40:45', '2025-09-09 04:05:30'),
(89, 'Cập nhật quy trình', 'Công việc: Gửi lại bảng lương T8.2025 vừa được cập nhật quy trình mới', 7, 'Cập nhật', 1, '2025-09-09 06:40:45', '2025-09-09 04:05:36'),
(90, 'Cập nhật quy trình', 'Công việc: Gửi lại bảng lương T8.2025 vừa được cập nhật quy trình mới', 7, 'Cập nhật', 1, '2025-09-09 06:40:44', '2025-09-09 04:05:44'),
(91, 'Cập nhật quy trình', 'Công việc: Gửi lại bảng lương T8.2025 vừa được cập nhật quy trình mới', 7, 'Cập nhật', 1, '2025-09-09 06:40:43', '2025-09-09 04:06:07'),
(92, 'Công việc mới', 'Bạn được giao công việc: agsfhsad. Hạn: 2025-09-10.', 7, 'Công việc mới', 1, '2025-09-09 04:06:32', '2025-09-09 04:06:22'),
(93, 'Thêm mới quy trình', 'Công việc: agsfhsad vừa được thêm quy trình mới', 7, 'Thêm mới', 1, '2025-09-09 06:40:42', '2025-09-09 04:07:04'),
(94, 'Thêm mới quy trình', 'Công việc: agsfhsad vừa được thêm quy trình mới', 7, 'Thêm mới', 1, '2025-09-09 06:40:42', '2025-09-09 04:07:17'),
(95, 'Cập nhật quy trình', 'Công việc: agsfhsad vừa được cập nhật quy trình mới', 7, 'Cập nhật', 1, '2025-09-09 06:40:53', '2025-09-09 04:07:27'),
(96, 'Thêm mới quy trình', 'Công việc: agsfhsad vừa được thêm quy trình mới', 7, 'Thêm mới', 1, '2025-09-09 06:40:53', '2025-09-09 04:07:28'),
(97, 'Cập nhật quy trình', 'Công việc: agsfhsad vừa được cập nhật quy trình mới', 7, 'Cập nhật', 1, '2025-09-09 06:40:52', '2025-09-09 04:07:55'),
(98, 'Cập nhật quy trình', 'Công việc: agsfhsad vừa được cập nhật quy trình mới', 7, 'Cập nhật', 1, '2025-09-09 06:40:52', '2025-09-09 04:08:00'),
(99, 'Cập nhật quy trình', 'Công việc: agsfhsad vừa được cập nhật quy trình mới', 7, 'Cập nhật', 1, '2025-09-09 06:40:51', '2025-09-09 04:08:10'),
(100, 'Công việc mới', 'Bạn được giao công việc: Thiết kế Template . Hạn: 2025-09-12.', 11, 'Công việc mới', 0, '2025-09-10 06:52:18', '2025-09-10 06:52:18'),
(101, 'Cập nhật công việc', 'Công việc: Thiết kế Template  vừa được cập nhật mới', 12, 'Cập nhật', 0, '2025-09-10 06:52:46', '2025-09-10 06:52:46'),
(102, 'Cập nhật công việc', 'Công việc: Thiết kế Template  vừa được cập nhật mới', 13, 'Cập nhật', 0, '2025-09-10 06:53:08', '2025-09-10 06:53:08'),
(103, 'Công việc mới', 'Bạn được giao công việc: chính sách giá sản phẩm. Hạn: 2025-12-09.', 11, 'Công việc mới', 0, '2025-09-10 07:02:34', '2025-09-10 07:02:34'),
(104, 'Công việc mới', 'Bạn được giao công việc: chính sách lương thưởng cho nhân viên . Hạn: 2025-12-09.', 11, 'Công việc mới', 0, '2025-09-10 07:03:34', '2025-09-10 07:03:34'),
(105, 'Công việc mới', 'Bạn được giao công việc: hoàn thiện danh sách 500 doanh nghiệp. Hạn: 2025-12-09.', 11, 'Công việc mới', 0, '2025-09-10 07:04:55', '2025-09-10 07:04:55'),
(106, 'Công việc mới', 'Bạn được giao công việc: lên kế hoạch triển khai KPI cho từng đơn vị. Hạn: 2025-12-09.', 11, 'Công việc mới', 0, '2025-09-10 07:07:38', '2025-09-10 07:07:38'),
(107, 'Công việc mới', 'Bạn được giao công việc: đăng bài truyền thông. Hạn: 2025-12-09.', 11, 'Công việc mới', 0, '2025-09-10 07:08:27', '2025-09-10 07:08:27'),
(108, 'Công việc mới', 'Bạn được giao công việc: lên kế hoạch sự kiện ( trong và ngoài nước ). Hạn: 2025-12-09.', 11, 'Công việc mới', 0, '2025-09-10 07:11:04', '2025-09-10 07:11:04'),
(109, 'Công việc mới', 'Bạn được giao công việc: làm việc trực tiếp với các đối tác đã kí. Hạn: 2025-12-09.', 11, 'Công việc mới', 0, '2025-09-10 07:11:54', '2025-09-10 07:11:54'),
(110, 'Công việc mới', 'Bạn được giao công việc: đánh giá các đốmạngủ cạnh tranh an ninh mạng. Hạn: 2025-12-09.', 11, 'Công việc mới', 0, '2025-09-10 07:13:02', '2025-09-10 07:13:02'),
(111, 'Công việc mới', 'Bạn được giao công việc: triển khai chương trình đào tạo về an toàn thông tin. Hạn: 2025-12-09.', 6, 'Công việc mới', 0, '2025-09-10 07:14:34', '2025-09-10 07:14:34'),
(112, 'Công việc mới', 'Bạn được giao công việc: chỉnh sửa lại web công ty. Hạn: 2025-12-09.', 8, 'Công việc mới', 0, '2025-09-10 07:15:36', '2025-09-10 07:15:36'),
(113, 'Công việc mới', 'Bạn được giao công việc: đề xuất bộ phận tiếp nhận thông tin khách hàng cho việc bán hàng OCI. Hạn: 2025-12-09.', 6, 'Công việc mới', 0, '2025-09-10 07:17:05', '2025-09-10 07:17:05'),
(114, 'Công việc mới', 'Bạn được giao công việc: lắp đặt server. Hạn: 2025-12-09.', 6, 'Công việc mới', 1, '2025-09-10 09:25:44', '2025-09-10 07:18:56'),
(115, 'Công việc mới', 'Bạn được giao công việc: lên phương án kinh doanh CLOUD cùng Group. Hạn: 2025-09-19.', 11, 'Công việc mới', 0, '2025-09-11 02:25:00', '2025-09-11 02:25:00'),
(116, 'Công việc mới', 'Bạn được giao công việc: lên phương án kinh doanh CLOUD cùng G Group. Hạn: 2025-09-19.', 11, 'Công việc mới', 0, '2025-09-11 02:32:10', '2025-09-11 02:32:10'),
(117, 'Công việc mới', 'Bạn được giao công việc: hoàn. Hạn: 2025-09-15.', 1, 'Công việc mới', 0, '2025-09-11 02:36:12', '2025-09-11 02:36:12'),
(118, 'Thêm mới quy trình', 'Công việc: hoàn vừa được thêm quy trình mới', 1, 'Thêm mới', 0, '2025-09-11 02:37:36', '2025-09-11 02:37:36'),
(119, 'Thêm mới quy trình', 'Công việc: hoàn vừa được thêm quy trình mới', 1, 'Thêm mới', 0, '2025-09-11 02:38:58', '2025-09-11 02:38:58'),
(120, 'Cập nhật công việc', 'Công việc: hoàn chỉnh hướng dẫn sử dụng ICS ( trình bày bằng video hoặc pp )  vừa được cập nhật mới', 1, 'Cập nhật', 0, '2025-09-11 02:39:26', '2025-09-11 02:39:26'),
(121, 'Cập nhật quy trình', 'Công việc: hoàn chỉnh hướng dẫn sử dụng ICS ( trình bày bằng video hoặc pp )  vừa được cập nhật quy trình mới', 1, 'Cập nhật', 0, '2025-09-11 02:40:22', '2025-09-11 02:40:22'),
(122, 'Cập nhật công việc', 'Công việc: hoàn chỉnh hướng dẫn sử dụng ICS CIM ( trình bày bằng video hoặc pp )  vừa được cập nhật mới', 1, 'Cập nhật', 0, '2025-09-11 02:43:48', '2025-09-11 02:43:48'),
(123, 'Cập nhật công việc', 'Công việc: hoàn thiện danh sách 500 doanh nghiệp vừa được cập nhật mới', 11, 'Cập nhật', 0, '2025-09-11 02:48:24', '2025-09-11 02:48:24'),
(124, 'Cập nhật công việc', 'Công việc: đăng bài truyền thông vừa được cập nhật mới', 11, 'Cập nhật', 0, '2025-09-11 02:49:07', '2025-09-11 02:49:07'),
(125, 'Cập nhật công việc', 'Công việc: lên kế hoạch sự kiện ( trong và ngoài nước ) vừa được cập nhật mới', 11, 'Cập nhật', 0, '2025-09-11 02:49:31', '2025-09-11 02:49:31'),
(126, 'Cập nhật công việc', 'Công việc: làm việc trực tiếp với các đối tác đã kí vừa được cập nhật mới', 11, 'Cập nhật', 0, '2025-09-11 02:49:54', '2025-09-11 02:49:54'),
(127, 'Cập nhật công việc', 'Công việc: đánh giá các đối thủ cạnh tranh an ninh mạng vừa được cập nhật mới', 11, 'Cập nhật', 0, '2025-09-11 02:50:19', '2025-09-11 02:50:19'),
(128, 'Cập nhật công việc', 'Công việc: triển khai chương trình đào tạo về an toàn thông tin vừa được cập nhật mới', 6, 'Cập nhật', 0, '2025-09-11 02:51:07', '2025-09-11 02:51:07'),
(129, 'Cập nhật công việc', 'Công việc: đề xuất bộ phận tiếp nhận thông tin khách hàng cho việc bán hàng OCI vừa được cập nhật mới', 6, 'Cập nhật', 0, '2025-09-11 02:51:52', '2025-09-11 02:51:52'),
(130, 'Cập nhật công việc', 'Công việc: lắp đặt server vừa được cập nhật mới', 6, 'Cập nhật', 0, '2025-09-11 02:52:10', '2025-09-11 02:52:10'),
(131, 'Cập nhật quy trình', 'Công việc: hoàn chỉnh hướng dẫn sử dụng ICS CIM ( trình bày bằng video hoặc pp )  vừa được cập nhật quy trình mới', 1, 'Cập nhật', 0, '2025-09-11 04:44:11', '2025-09-11 04:44:11'),
(132, 'Công việc mới', 'Bạn được giao công việc: 1. Hạn: 2025-09-11.', 18, 'Công việc mới', 0, '2025-09-11 07:24:11', '2025-09-11 07:24:11'),
(133, 'Thêm mới quy trình', 'Công việc: 1 vừa được thêm quy trình mới', 18, 'Thêm mới', 0, '2025-09-11 07:24:24', '2025-09-11 07:24:24'),
(134, 'Thêm mới quy trình', 'Công việc: lên phương án kinh doanh CLOUD cùng G Group vừa được thêm quy trình mới', 11, 'Thêm mới', 0, '2025-09-11 07:24:51', '2025-09-11 07:24:51'),
(135, 'Xóa bỏ quy trình', 'Công việc: lên phương án kinh doanh CLOUD cùng G Group vừa xóa bỏ một quy trình', 11, 'Xóa bỏ', 0, '2025-09-11 07:25:01', '2025-09-11 07:25:01'),
(136, 'Cập nhật công việc', 'Công việc: hoàn chỉnh hướng dẫn sử dụng ICS CIM ( trình bày bằng video hoặc pp )  vừa được cập nhật mới', 1, 'Cập nhật', 0, '2025-09-11 07:57:40', '2025-09-11 07:57:40'),
(137, 'Cập nhật công việc', 'Công việc: 11 vừa được cập nhật mới', 1, 'Cập nhật', 0, '2025-09-11 08:15:07', '2025-09-11 08:15:07'),
(138, 'Xóa bỏ quy trình', 'Công việc: 11 vừa xóa bỏ một quy trình', 1, 'Cập nhật', 0, '2025-09-11 08:24:44', '2025-09-11 08:24:44'),
(139, 'Thêm mới quy trình', 'Công việc: 11 vừa được thêm quy trình mới', 1, 'Cập nhật', 0, '2025-09-11 08:24:50', '2025-09-11 08:24:50'),
(140, 'Cập nhật quy trình', 'Công việc: 11 vừa được cập nhật quy trình mới', 1, 'Cập nhật', 0, '2025-09-11 08:31:02', '2025-09-11 08:31:02'),
(141, 'Cập nhật quy trình', 'Công việc: 11 vừa được cập nhật quy trình mới', 1, 'Cập nhật', 0, '2025-09-11 08:32:05', '2025-09-11 08:32:05'),
(142, 'Đánh giá công việc mới', 'Bạn vừa có thêm đánh giá cho công việc.', 1, 'Đánh giá', 0, '2025-09-11 08:33:55', '2025-09-11 08:33:55'),
(143, 'Cập nhật công việc', 'Công việc: 11 vừa được cập nhật mới', 1, 'Cập nhật', 0, '2025-09-11 08:35:17', '2025-09-11 08:35:17'),
(144, 'Cập nhật công việc', 'Công việc: 11 vừa được cập nhật mới', 2, 'Cập nhật', 0, '2025-09-11 08:35:17', '2025-09-11 08:35:17'),
(145, 'Đánh giá công việc mới', 'Bạn vừa có thêm đánh giá cho công việc.', 1, 'Đánh giá', 0, '2025-09-11 08:35:25', '2025-09-11 08:35:25'),
(146, 'Đánh giá công việc mới', 'Bạn vừa có thêm đánh giá cho công việc.', 2, 'Đánh giá', 0, '2025-09-11 08:35:25', '2025-09-11 08:35:25'),
(147, 'Cập nhật quy trình', 'Công việc: 11 vừa được cập nhật quy trình mới', 1, 'Cập nhật', 0, '2025-09-11 08:53:33', '2025-09-11 08:53:33'),
(148, 'Cập nhật quy trình', 'Công việc: 11 vừa được cập nhật quy trình mới', 2, 'Cập nhật', 0, '2025-09-11 08:53:33', '2025-09-11 08:53:33'),
(149, 'Cập nhật quy trình', 'Công việc: 11 vừa được cập nhật quy trình mới', 1, 'Cập nhật', 0, '2025-09-11 08:53:43', '2025-09-11 08:53:43'),
(150, 'Cập nhật quy trình', 'Công việc: 11 vừa được cập nhật quy trình mới', 2, 'Cập nhật', 0, '2025-09-11 08:53:43', '2025-09-11 08:53:43');

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
  ADD KEY `nguoi_nhan_id` (`nguoi_nhan_id`),
  ADD KEY `phong_ban_id` (`phong_ban_id`);

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
  ADD KEY `nguoi_nhan_id` (`nhan_vien_id`);

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
-- Chỉ mục cho bảng `file_dinh_kem`
--
ALTER TABLE `file_dinh_kem`
  ADD PRIMARY KEY (`id`),
  ADD KEY `cong_viec_id` (`cong_viec_id`),
  ADD KEY `tien_do_id` (`tien_do_id`);

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
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=434;

--
-- AUTO_INCREMENT cho bảng `cong_viec`
--
ALTER TABLE `cong_viec`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=79;

--
-- AUTO_INCREMENT cho bảng `cong_viec_danh_gia`
--
ALTER TABLE `cong_viec_danh_gia`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT cho bảng `cong_viec_lich_su`
--
ALTER TABLE `cong_viec_lich_su`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT cho bảng `cong_viec_nguoi_nhan`
--
ALTER TABLE `cong_viec_nguoi_nhan`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT cho bảng `cong_viec_quy_trinh`
--
ALTER TABLE `cong_viec_quy_trinh`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=137;

--
-- AUTO_INCREMENT cho bảng `cong_viec_tien_do`
--
ALTER TABLE `cong_viec_tien_do`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `file_dinh_kem`
--
ALTER TABLE `file_dinh_kem`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

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
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT cho bảng `thong_bao`
--
ALTER TABLE `thong_bao`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=151;

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
  ADD CONSTRAINT `cong_viec_ibfk_2` FOREIGN KEY (`nguoi_nhan_id`) REFERENCES `nhanvien` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `cong_viec_ibfk_3` FOREIGN KEY (`phong_ban_id`) REFERENCES `phong_ban` (`id`) ON DELETE SET NULL;

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
