-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Máy chủ: 127.0.0.1
-- Thời gian đã tạo: Th9 17, 2025 lúc 11:06 AM
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
(433, 2, '2025-09-10', '08:48:19', NULL),
(434, 1, '2025-09-15', '11:17:39', '11:17:43');

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
  `nguoi_nhan_id` int(11) DEFAULT NULL,
  `phong_ban_id` int(11) DEFAULT NULL,
  `trang_thai` enum('Chưa bắt đầu','Đang thực hiện','Đã hoàn thành','Trễ hạn') DEFAULT 'Chưa bắt đầu',
  `tai_lieu_cv` varchar(255) DEFAULT NULL,
  `file_tai_lieu` varchar(255) DEFAULT NULL,
  `ngay_tao` timestamp NOT NULL DEFAULT current_timestamp(),
  `ngay_bat_dau` date DEFAULT NULL,
  `ngay_hoan_thanh` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `cong_viec`
--

INSERT INTO `cong_viec` (`id`, `du_an_id`, `ten_cong_viec`, `mo_ta`, `han_hoan_thanh`, `muc_do_uu_tien`, `nguoi_giao_id`, `nguoi_nhan_id`, `phong_ban_id`, `trang_thai`, `tai_lieu_cv`, `file_tai_lieu`, `ngay_tao`, `ngay_bat_dau`, `ngay_hoan_thanh`) VALUES
(52, NULL, 'Gửi lại bảng lương T8.2025', '', '2025-09-09', 'Trung bình', 12, 7, 1, 'Đã hoàn thành', '', NULL, '2025-09-08 07:07:01', '2025-09-09', '2025-09-09'),
(53, NULL, 'Kế hoạch đăng bài', 'Lên kế hoạch đăng bài và đăng bài cho tuần này. Liên quan đến vấn tiết kiệm chi phí khi sử dụng Dashboard, bài toán CFO.', '2025-09-09', 'Trung bình', 11, 15, 7, 'Đã hoàn thành', '', NULL, '2025-09-08 08:14:00', NULL, NULL),
(57, NULL, 'Kế hoạch đăng bài', 'Lên kế hoạch đăng bài và đăng bài về ANM. Đưa ra các ', '2025-09-09', 'Trung bình', 11, 13, 7, 'Đã hoàn thành', '', NULL, '2025-09-08 08:29:50', NULL, NULL),
(58, NULL, 'Kế hoạch đăng bài', 'Lê kế hoạch đăng bài và đăng bài về OCI. Chú ý tới vấn đề tiết kiệm chi phí, khách hàng hướng đến là CTO', '2025-09-09', 'Trung bình', 11, 9, 7, 'Đã hoàn thành', '', NULL, '2025-09-08 08:31:12', NULL, NULL),
(61, NULL, 'Thiết kế Template ', '- Thư ngỏ\r\n- Giấy giới thiệu \r\n- Thư trả lời \r\n- Powerpoint template \r\n... các template cần cho công ty ', '2025-09-12', 'Trung bình', 4, 13, 7, 'Trễ hạn', '', NULL, '2025-09-10 06:52:18', NULL, NULL),
(62, NULL, 'chính sách giá sản phẩm', '', '2025-12-09', 'Trung bình', 10, 11, 7, 'Chưa bắt đầu', '', NULL, '2025-09-10 07:02:34', NULL, NULL),
(63, NULL, 'chính sách lương thưởng cho nhân viên ', '', '2025-12-09', 'Trung bình', 10, 11, 7, 'Chưa bắt đầu', '', NULL, '2025-09-10 07:03:33', NULL, NULL),
(64, NULL, 'hoàn thiện danh sách 500 doanh nghiệp', 'Đưa ra kịch bản gọi điện cho các bạn tts liên hệ', '2025-12-09', 'Cao', 10, 11, 7, 'Chưa bắt đầu', '', NULL, '2025-09-10 07:04:55', NULL, NULL),
(65, NULL, 'lên kế hoạch triển khai KPI cho từng đơn vị', '', '2025-12-09', 'Cao', 10, 11, 7, 'Đã hoàn thành', '', NULL, '2025-09-10 07:07:38', NULL, NULL),
(66, NULL, 'đăng bài truyền thông', '7 bài, video ~3p /1 tuần trong đó 20/80 20-sp, 80- xu thế/Dẫn bài trang Web', '2025-12-09', 'Trung bình', 10, 11, 7, 'Chưa bắt đầu', '', NULL, '2025-09-10 07:08:27', NULL, NULL),
(67, NULL, 'lên kế hoạch sự kiện ( trong và ngoài nước )', 'Lên kế hoạch sự kiện trong và ngoài nước ( từ giờ cho đến cuối năm, năm sau,…)', '2025-12-09', 'Trung bình', 10, 11, 7, 'Chưa bắt đầu', '', NULL, '2025-09-10 07:11:04', NULL, NULL),
(68, NULL, 'làm việc trực tiếp với các đối tác đã kí', 'Làm việc tiếp vs các đối tác đã/ chuẩn bị kí MoU, cụ thể các công việc ( Dương hỗ trợ)', '2025-12-09', 'Trung bình', 10, 11, 7, 'Chưa bắt đầu', '', NULL, '2025-09-10 07:11:53', NULL, NULL),
(69, NULL, 'đánh giá các đối thủ cạnh tranh an ninh mạng', '- Trao đổi vs Oracle, tổ chức các buổi  onl webinar (Dương, Linh hỗ trợ)\r\n', '2025-12-09', 'Trung bình', 10, 11, 7, 'Chưa bắt đầu', '', NULL, '2025-09-10 07:13:02', NULL, NULL),
(70, NULL, 'triển khai chương trình đào tạo về an toàn thông tin', 'Triển khai trực tiếp , AI triển khai onl để thuận lợi cho ng học \r\n( Linh tham gia cùng đội KT, A Âu mời các đối tác triển khai khác), p.tich Mobile App theo thông tư 50 ', '2025-12-09', 'Trung bình', 18, 6, 6, 'Chưa bắt đầu', 'Đã lập phương án cho 1 số đối tác. ', NULL, '2025-09-10 07:14:34', NULL, NULL),
(71, NULL, 'chỉnh sửa lại web công ty', '', '2025-12-09', 'Cao', 10, 8, 6, 'Chưa bắt đầu', '', NULL, '2025-09-10 07:15:36', NULL, NULL),
(72, NULL, 'đề xuất bộ phận tiếp nhận thông tin khách hàng cho việc bán hàng OCI', '(đội KT cần ngồi lại về OCI live, công cụ ANBM,…). Đồng thời, giao lại cho anh Trung để bán hàng', '2025-12-09', 'Trung bình', 6, 8, 6, 'Chưa bắt đầu', '', NULL, '2025-09-10 07:17:05', NULL, NULL),
(73, NULL, 'lắp đặt server', 'AI SOC-Allen cho đội sang lắp đặt, anh Hanh bố trí bạn bên đội KT để học hỏi', '2025-12-09', 'Trung bình', 6, 5, 6, 'Đã hoàn thành', '', NULL, '2025-09-10 07:18:55', NULL, NULL),
(75, NULL, 'lên phương án kinh doanh CLOUD cùng G Group', '', '2025-09-19', 'Trung bình', 10, 11, 7, 'Đang thực hiện', '', NULL, '2025-09-11 02:32:10', '2025-09-12', NULL),
(76, NULL, 'hoàn chỉnh hướng dẫn sử dụng ICS CIM ( trình bày bằng video hoặc pp ) ', '', '2025-09-15', 'Cao', 10, 1, 6, 'Trễ hạn', '', NULL, '2025-09-11 02:36:12', '2025-09-11', NULL),
(85, NULL, '1', '1', '2025-09-21', 'Thấp', 1, NULL, 6, 'Chưa bắt đầu', '1', '', '2025-09-17 07:33:04', NULL, NULL);

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

--
-- Đang đổ dữ liệu cho bảng `cong_viec_nguoi_nhan`
--

INSERT INTO `cong_viec_nguoi_nhan` (`id`, `cong_viec_id`, `nhan_vien_id`) VALUES
(2, 73, 5),
(4, 70, 6),
(5, 52, 7),
(6, 71, 8),
(7, 72, 8),
(8, 58, 9),
(9, 62, 11),
(10, 63, 11),
(11, 64, 11),
(12, 65, 11),
(13, 66, 11),
(14, 67, 11),
(15, 68, 11),
(16, 69, 11),
(17, 75, 11),
(18, 57, 13),
(19, 61, 13),
(20, 53, 15),
(32, 76, 1),
(33, 76, 2),
(66, 85, 1);

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
(132, 62, 'bước 1', 'tham khảo giá một số công ty', 'Chưa bắt đầu', '2025-09-11', '2025-09-15', '2025-09-11 07:50:28'),
(133, 62, 'bước 2', 'lập bảng chính sách giá cụ thể', 'Chưa bắt đầu', '2025-09-11', '2025-09-15', '2025-09-11 07:51:24'),
(134, 63, 'bước 1', 'làm bảng lương chi tiết', 'Chưa bắt đầu', '2025-09-11', '2025-09-15', '2025-09-11 07:52:49'),
(135, 63, 'bước 2', 'báo cáo lại Mrs. Yến', 'Chưa bắt đầu', '2025-09-11', '2025-09-15', '2025-09-11 07:53:15'),
(136, 64, 'bước 1', 'đưa ra kịch bản triển khai', 'Chưa bắt đầu', '2025-09-11', '2025-09-15', '2025-09-11 07:54:09'),
(137, 64, 'bước 2', 'giao cho các bạn TTS liên hệ', 'Chưa bắt đầu', '2025-09-11', '2025-09-15', '2025-09-11 07:54:45'),
(138, 65, 'bước 1', 'Xác định mục tiêu tổng thể của doanh nghiệp', 'Chưa bắt đầu', '2025-09-11', '2025-09-15', '2025-09-11 07:57:12'),
(139, 65, 'bước 2', 'Xây dựng KPI cụ thể cho từng đơn vị', 'Chưa bắt đầu', '2025-09-11', '2025-09-15', '2025-09-11 07:57:34'),
(140, 66, 'bước 1', 'Xác định mục tiêu, đối tượng truyền thông', 'Chưa bắt đầu', '2025-09-11', '2025-09-15', '2025-09-11 07:59:35'),
(141, 66, 'bước 2', 'Phân công và sản xuất nội dung', 'Chưa bắt đầu', '2025-09-11', '2025-09-15', '2025-09-11 08:00:06'),
(142, 67, 'bước 1', 'Xây dựng kịch bản & chương trình chi tiết', 'Chưa bắt đầu', '2025-09-11', '2025-09-15', '2025-09-11 08:01:15'),
(143, 67, 'bước 2', 'Truyền thông & quảng bá', 'Chưa bắt đầu', '2025-09-11', '2025-09-15', '2025-09-11 08:01:38'),
(144, 68, 'bước 1', 'Rà soát & nắm rõ thỏa thuận đã ký', 'Chưa bắt đầu', '2025-09-11', '2025-09-15', '2025-09-11 08:02:55'),
(145, 68, 'bước 2', 'Đánh giá & báo cáo định kỳ', 'Chưa bắt đầu', '2025-09-11', '2025-09-15', '2025-09-11 08:03:37'),
(146, 69, 'bước 1', 'Xác định, lựa chọn mục tiêu đánh giá', 'Chưa bắt đầu', '2025-09-11', '2025-09-15', '2025-09-11 08:05:06'),
(147, 69, 'bước 2', 'Phân tích SWOT từng đối thủ', 'Chưa bắt đầu', '2025-09-11', '2025-09-15', '2025-09-11 08:05:25'),
(148, 70, 'bước 1', 'Xây dựng nội dung chi tiết & phương pháp đào tạo', 'Chưa bắt đầu', '2025-09-11', '2025-09-15', '2025-09-11 08:06:46'),
(149, 70, 'bước 2', 'Chuẩn bị nhân sự & nguồn lực', 'Chưa bắt đầu', '2025-09-11', '2025-09-15', '2025-09-11 08:07:06'),
(150, 71, 'bước 1', 'xem và chỉnh sửa', 'Chưa bắt đầu', '2025-09-11', '2025-09-15', '2025-09-11 08:09:34'),
(151, 71, 'bước 2', 'báo cáo lại Mrs. Yến', 'Chưa bắt đầu', '2025-09-11', '2025-09-15', '2025-09-11 08:10:01'),
(152, 72, 'bước 1', 'đội kĩ thuật ngồi bàn về  OCI live, công cụ ANBM...', 'Chưa bắt đầu', '2025-09-11', '2025-09-15', '2025-09-11 08:11:17'),
(153, 72, 'bước 2', 'bàn giao lại cho Mr. trung', 'Chưa bắt đầu', '2025-09-11', '2025-09-15', '2025-09-11 08:11:48'),
(154, 73, 'bước 1', 'Mr Hanh sắp xếp nhân sự tiếp đón, học hỏi', 'Chưa bắt đầu', '2025-09-11', '2025-09-15', '2025-09-11 08:13:10'),
(155, 73, 'bước 2', 'Mr. Dũng tiếp nhận server', 'Chưa bắt đầu', '2025-09-11', '2025-09-15', '2025-09-11 08:13:53'),
(156, 75, 'Hẹn lịch sang thăm và làm việc với GG', '', 'Đang thực hiện', '2025-09-12', '2025-09-15', '2025-09-12 01:57:16'),
(157, 75, 'Sang thăm và làm việc', 'Xác định được hướng hợp tác', 'Chưa bắt đầu', '2025-09-15', '2025-09-26', '2025-09-12 01:58:05'),
(158, 75, 'Triển khai ký NDA và MOU', '', 'Chưa bắt đầu', '2025-09-22', '2025-09-19', '2025-09-12 01:58:38');

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
(30, 52, 0, '2025-09-17 08:48:14'),
(33, 53, 0, '2025-09-11 10:34:13'),
(34, 57, 0, '2025-09-12 02:32:38'),
(35, 58, 0, '2025-09-11 07:18:44'),
(38, 61, 0, '2025-09-12 02:37:53'),
(39, 62, 0, '2025-09-17 08:38:37'),
(40, 69, 0, '2025-09-11 08:26:54'),
(41, 73, 0, '2025-09-12 03:00:09'),
(42, 70, 0, '2025-09-12 06:43:44'),
(43, 71, 0, '2025-09-17 08:54:40'),
(45, 63, 0, '2025-09-17 08:48:11'),
(46, 75, 0, '2025-09-17 08:18:18'),
(47, 76, 0, '2025-09-15 04:16:55'),
(48, 64, 0, '2025-09-11 08:27:18'),
(49, 65, 0, '2025-09-11 08:27:12'),
(50, 72, 0, '2025-09-17 08:41:57'),
(52, 66, 0, '2025-09-12 06:43:37'),
(53, 67, 0, '2025-09-11 08:27:03'),
(54, 68, 0, '2025-09-12 06:43:40');

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
(1, 'Công việc riêng', 'Công việc riêng', '2025-09-17', '2035-10-31', '2025-09-17 09:03:49');

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
-- Cấu trúc bảng cho bảng `tep_dinh_kem`
--

CREATE TABLE `tep_dinh_kem` (
  `id` int(11) NOT NULL,
  `ten_file` varchar(255) DEFAULT NULL,
  `duong_dan` varchar(500) DEFAULT NULL,
  `ngay_tai_len` datetime DEFAULT current_timestamp(),
  `nguoi_tai_len` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `tep_dinh_kem`
--

INSERT INTO `tep_dinh_kem` (`id`, `ten_file`, `duong_dan`, `ngay_tai_len`, `nguoi_tai_len`) VALUES
(20, 'Phạm Minh Thắng_Báo cáo HNM.docx', 'Phạm Minh Thắng_Báo cáo HNM.docx', '2025-09-17 11:23:23', 'anonymous'),
(21, 'z6099009923178_034b5ec3171d659dccc5ce20a01842a1.jpg', 'z6099009923178_034b5ec3171d659dccc5ce20a01842a1.jpg', '2025-09-17 11:23:23', 'anonymous');

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
(102, 'Cập nhật công việc', 'Công việc: Thiết kế Template  vừa được cập nhật mới', 13, 'Cập nhật', 1, '2025-09-12 02:32:09', '2025-09-10 06:53:08'),
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
(136, 'Thêm mới quy trình', 'Công việc: chính sách giá sản phẩm vừa được thêm quy trình mới', 11, 'Thêm mới', 0, '2025-09-11 07:50:29', '2025-09-11 07:50:29'),
(137, 'Thêm mới quy trình', 'Công việc: chính sách giá sản phẩm vừa được thêm quy trình mới', 11, 'Thêm mới', 0, '2025-09-11 07:51:24', '2025-09-11 07:51:24'),
(138, 'Thêm mới quy trình', 'Công việc: chính sách lương thưởng cho nhân viên  vừa được thêm quy trình mới', 11, 'Thêm mới', 0, '2025-09-11 07:52:49', '2025-09-11 07:52:49'),
(139, 'Thêm mới quy trình', 'Công việc: chính sách lương thưởng cho nhân viên  vừa được thêm quy trình mới', 11, 'Thêm mới', 0, '2025-09-11 07:53:15', '2025-09-11 07:53:15'),
(140, 'Thêm mới quy trình', 'Công việc: hoàn thiện danh sách 500 doanh nghiệp vừa được thêm quy trình mới', 11, 'Thêm mới', 0, '2025-09-11 07:54:09', '2025-09-11 07:54:09'),
(141, 'Thêm mới quy trình', 'Công việc: hoàn thiện danh sách 500 doanh nghiệp vừa được thêm quy trình mới', 11, 'Thêm mới', 0, '2025-09-11 07:54:45', '2025-09-11 07:54:45'),
(142, 'Thêm mới quy trình', 'Công việc: lên kế hoạch triển khai KPI cho từng đơn vị vừa được thêm quy trình mới', 11, 'Thêm mới', 0, '2025-09-11 07:57:12', '2025-09-11 07:57:12'),
(143, 'Thêm mới quy trình', 'Công việc: lên kế hoạch triển khai KPI cho từng đơn vị vừa được thêm quy trình mới', 11, 'Thêm mới', 0, '2025-09-11 07:57:34', '2025-09-11 07:57:34'),
(144, 'Thêm mới quy trình', 'Công việc: đăng bài truyền thông vừa được thêm quy trình mới', 11, 'Thêm mới', 0, '2025-09-11 07:59:35', '2025-09-11 07:59:35'),
(145, 'Thêm mới quy trình', 'Công việc: đăng bài truyền thông vừa được thêm quy trình mới', 11, 'Thêm mới', 0, '2025-09-11 08:00:06', '2025-09-11 08:00:06'),
(146, 'Thêm mới quy trình', 'Công việc: lên kế hoạch sự kiện ( trong và ngoài nước ) vừa được thêm quy trình mới', 11, 'Thêm mới', 0, '2025-09-11 08:01:15', '2025-09-11 08:01:15'),
(147, 'Thêm mới quy trình', 'Công việc: lên kế hoạch sự kiện ( trong và ngoài nước ) vừa được thêm quy trình mới', 11, 'Thêm mới', 0, '2025-09-11 08:01:38', '2025-09-11 08:01:38'),
(148, 'Thêm mới quy trình', 'Công việc: làm việc trực tiếp với các đối tác đã kí vừa được thêm quy trình mới', 11, 'Thêm mới', 0, '2025-09-11 08:02:55', '2025-09-11 08:02:55'),
(149, 'Thêm mới quy trình', 'Công việc: làm việc trực tiếp với các đối tác đã kí vừa được thêm quy trình mới', 11, 'Thêm mới', 0, '2025-09-11 08:03:37', '2025-09-11 08:03:37'),
(150, 'Thêm mới quy trình', 'Công việc: đánh giá các đối thủ cạnh tranh an ninh mạng vừa được thêm quy trình mới', 11, 'Thêm mới', 0, '2025-09-11 08:05:06', '2025-09-11 08:05:06'),
(151, 'Thêm mới quy trình', 'Công việc: đánh giá các đối thủ cạnh tranh an ninh mạng vừa được thêm quy trình mới', 11, 'Thêm mới', 0, '2025-09-11 08:05:25', '2025-09-11 08:05:25'),
(152, 'Thêm mới quy trình', 'Công việc: triển khai chương trình đào tạo về an toàn thông tin vừa được thêm quy trình mới', 6, 'Thêm mới', 0, '2025-09-11 08:06:46', '2025-09-11 08:06:46'),
(153, 'Thêm mới quy trình', 'Công việc: triển khai chương trình đào tạo về an toàn thông tin vừa được thêm quy trình mới', 6, 'Thêm mới', 0, '2025-09-11 08:07:06', '2025-09-11 08:07:06'),
(154, 'Thêm mới quy trình', 'Công việc: chỉnh sửa lại web công ty vừa được thêm quy trình mới', 8, 'Thêm mới', 0, '2025-09-11 08:09:34', '2025-09-11 08:09:34'),
(155, 'Thêm mới quy trình', 'Công việc: chỉnh sửa lại web công ty vừa được thêm quy trình mới', 8, 'Thêm mới', 0, '2025-09-11 08:10:01', '2025-09-11 08:10:01'),
(156, 'Thêm mới quy trình', 'Công việc: đề xuất bộ phận tiếp nhận thông tin khách hàng cho việc bán hàng OCI vừa được thêm quy trình mới', 6, 'Thêm mới', 0, '2025-09-11 08:11:17', '2025-09-11 08:11:17'),
(157, 'Thêm mới quy trình', 'Công việc: đề xuất bộ phận tiếp nhận thông tin khách hàng cho việc bán hàng OCI vừa được thêm quy trình mới', 6, 'Thêm mới', 0, '2025-09-11 08:11:49', '2025-09-11 08:11:49'),
(158, 'Thêm mới quy trình', 'Công việc: lắp đặt server vừa được thêm quy trình mới', 6, 'Thêm mới', 0, '2025-09-11 08:13:10', '2025-09-11 08:13:10'),
(159, 'Thêm mới quy trình', 'Công việc: lắp đặt server vừa được thêm quy trình mới', 6, 'Thêm mới', 0, '2025-09-11 08:13:53', '2025-09-11 08:13:53'),
(160, 'Cập nhật công việc', 'Công việc: Kế hoạch đăng bài vừa được cập nhật mới', 15, 'Cập nhật', 0, '2025-09-11 10:34:21', '2025-09-11 10:34:21'),
(161, 'Cập nhật công việc', 'Công việc: Kế hoạch đăng bài vừa được cập nhật mới', 13, 'Cập nhật', 1, '2025-09-12 02:32:12', '2025-09-11 10:34:28'),
(162, 'Cập nhật công việc', 'Công việc: Kế hoạch đăng bài vừa được cập nhật mới', 9, 'Cập nhật', 0, '2025-09-11 10:34:34', '2025-09-11 10:34:34'),
(163, 'Cập nhật công việc', 'Công việc: Lên đề xuất dự án TKV vừa được cập nhật mới', 6, 'Cập nhật', 0, '2025-09-11 10:34:49', '2025-09-11 10:34:49'),
(164, 'Cập nhật công việc', 'Công việc: chính sách lương thưởng cho nhân viên  vừa được cập nhật mới', 11, 'Cập nhật', 0, '2025-09-12 01:54:22', '2025-09-12 01:54:22'),
(165, 'Cập nhật công việc', 'Công việc: hoàn thiện danh sách 500 doanh nghiệp vừa được cập nhật mới', 11, 'Cập nhật', 0, '2025-09-12 01:54:33', '2025-09-12 01:54:33'),
(166, 'Cập nhật công việc', 'Công việc: lên kế hoạch triển khai KPI cho từng đơn vị vừa được cập nhật mới', 11, 'Cập nhật', 0, '2025-09-12 01:54:43', '2025-09-12 01:54:43'),
(167, 'Cập nhật công việc', 'Công việc: hoàn thiện danh sách 500 doanh nghiệp vừa được cập nhật mới', 11, 'Cập nhật', 0, '2025-09-12 01:55:04', '2025-09-12 01:55:04'),
(168, 'Cập nhật công việc', 'Công việc: đăng bài truyền thông vừa được cập nhật mới', 11, 'Cập nhật', 0, '2025-09-12 01:55:18', '2025-09-12 01:55:18'),
(169, 'Thêm mới quy trình', 'Công việc: lên phương án kinh doanh CLOUD cùng G Group vừa được thêm quy trình mới', 11, 'Thêm mới', 0, '2025-09-12 01:57:17', '2025-09-12 01:57:17'),
(170, 'Thêm mới quy trình', 'Công việc: lên phương án kinh doanh CLOUD cùng G Group vừa được thêm quy trình mới', 11, 'Thêm mới', 0, '2025-09-12 01:58:05', '2025-09-12 01:58:05'),
(171, 'Thêm mới quy trình', 'Công việc: lên phương án kinh doanh CLOUD cùng G Group vừa được thêm quy trình mới', 11, 'Thêm mới', 0, '2025-09-12 01:58:38', '2025-09-12 01:58:38'),
(172, 'Cập nhật công việc', 'Công việc: triển khai chương trình đào tạo về an toàn thông tin vừa được cập nhật mới', 6, 'Cập nhật', 0, '2025-09-12 02:15:51', '2025-09-12 02:15:51'),
(173, 'Cập nhật công việc', 'Công việc: đề xuất bộ phận tiếp nhận thông tin khách hàng cho việc bán hàng OCI vừa được cập nhật mới', 6, 'Cập nhật', 0, '2025-09-12 02:16:44', '2025-09-12 02:16:44'),
(174, 'Cập nhật công việc', 'Công việc: triển khai chương trình đào tạo về an toàn thông tin vừa được cập nhật mới', 6, 'Cập nhật', 0, '2025-09-12 02:16:59', '2025-09-12 02:16:59'),
(175, 'Cập nhật công việc', 'Công việc: triển khai chương trình đào tạo về an toàn thông tin vừa được cập nhật mới', 6, 'Cập nhật', 0, '2025-09-12 02:17:14', '2025-09-12 02:17:14'),
(176, 'Cập nhật công việc', 'Công việc: lắp đặt server vừa được cập nhật mới', 5, 'Cập nhật', 0, '2025-09-12 02:17:38', '2025-09-12 02:17:38'),
(177, 'Cập nhật công việc', 'Công việc: đề xuất bộ phận tiếp nhận thông tin khách hàng cho việc bán hàng OCI vừa được cập nhật mới', 8, 'Cập nhật', 0, '2025-09-12 02:17:56', '2025-09-12 02:17:56'),
(178, 'Cập nhật công việc', 'Công việc: Lên đề xuất dự án TKV vừa được cập nhật mới', 6, 'Cập nhật', 0, '2025-09-12 02:19:58', '2025-09-12 02:19:58'),
(179, 'Cập nhật công việc', 'Công việc: triển khai chương trình đào tạo về an toàn thông tin vừa được cập nhật mới', 6, 'Cập nhật', 0, '2025-09-12 02:20:26', '2025-09-12 02:20:26'),
(180, 'Cập nhật công việc', 'Công việc: triển khai chương trình đào tạo về an toàn thông tin vừa được cập nhật mới', 6, 'Cập nhật', 0, '2025-09-12 02:20:39', '2025-09-12 02:20:39'),
(181, 'Cập nhật công việc', 'Công việc: Lên đề xuất dự án TKV vừa được cập nhật mới', 6, 'Cập nhật', 0, '2025-09-12 02:22:27', '2025-09-12 02:22:27'),
(182, 'Thêm mới quy trình', 'Công việc: Lên đề xuất dự án TKV vừa được thêm quy trình mới', 6, 'Thêm mới', 0, '2025-09-12 02:26:29', '2025-09-12 02:26:29'),
(183, 'Thêm mới quy trình', 'Công việc: Lên đề xuất dự án TKV vừa được thêm quy trình mới', 6, 'Thêm mới', 0, '2025-09-12 02:28:19', '2025-09-12 02:28:19'),
(184, 'Cập nhật quy trình', 'Công việc: lên phương án kinh doanh CLOUD cùng G Group vừa được cập nhật quy trình mới', 11, 'Cập nhật', 0, '2025-09-12 02:52:42', '2025-09-12 02:52:42'),
(185, 'Cập nhật quy trình', 'Công việc: lên phương án kinh doanh CLOUD cùng G Group vừa được cập nhật quy trình mới', 11, 'Cập nhật', 0, '2025-09-12 02:52:48', '2025-09-12 02:52:48'),
(186, 'Cập nhật công việc', 'Công việc: hoàn chỉnh hướng dẫn sử dụng ICS CIM ( trình bày bằng video hoặc pp )  vừa được cập nhật mới', 1, 'Cập nhật', 0, '2025-09-12 06:55:40', '2025-09-12 06:55:40'),
(187, 'Cập nhật công việc', 'Công việc: hoàn chỉnh hướng dẫn sử dụng ICS CIM ( trình bày bằng video hoặc pp )  vừa được cập nhật mới', 2, 'Cập nhật', 0, '2025-09-12 06:55:40', '2025-09-12 06:55:40'),
(188, 'Công việc mới', 'Bạn được giao công việc: 11. Hạn: 2025-09-16.', 14, 'Công việc mới', 0, '2025-09-16 07:31:58', '2025-09-16 07:31:58'),
(189, 'Công việc mới', 'Bạn được giao công việc: 11. Hạn: 2025-09-16.', 12, 'Công việc mới', 0, '2025-09-16 07:31:58', '2025-09-16 07:31:58'),
(190, 'Công việc mới', 'Bạn được giao công việc: 11. Hạn: 2025-09-16.', 5, 'Công việc mới', 0, '2025-09-16 07:31:58', '2025-09-16 07:31:58'),
(191, 'Công việc mới', 'Bạn được giao công việc: 11. Hạn: 2025-09-16.', 16, 'Công việc mới', 0, '2025-09-16 07:31:58', '2025-09-16 07:31:58'),
(192, 'Cập nhật công việc', 'Công việc: 11 vừa được cập nhật mới', 14, 'Cập nhật', 0, '2025-09-16 07:32:14', '2025-09-16 07:32:14'),
(193, 'Cập nhật công việc', 'Công việc: 11 vừa được cập nhật mới', 16, 'Cập nhật', 0, '2025-09-16 07:32:14', '2025-09-16 07:32:14'),
(194, 'Cập nhật công việc', 'Công việc: 11 vừa được cập nhật mới', 5, 'Cập nhật', 0, '2025-09-16 07:32:14', '2025-09-16 07:32:14'),
(195, 'Cập nhật công việc', 'Công việc: 11 vừa được cập nhật mới', 12, 'Cập nhật', 0, '2025-09-16 07:32:14', '2025-09-16 07:32:14'),
(196, 'Cập nhật công việc', 'Công việc: 11 vừa được cập nhật mới', 2, 'Cập nhật', 0, '2025-09-16 07:32:14', '2025-09-16 07:32:14'),
(197, 'Cập nhật công việc', 'Công việc: 11 vừa được cập nhật mới', 14, 'Cập nhật', 0, '2025-09-16 07:32:21', '2025-09-16 07:32:21'),
(198, 'Cập nhật công việc', 'Công việc: 11 vừa được cập nhật mới', 2, 'Cập nhật', 0, '2025-09-16 07:32:21', '2025-09-16 07:32:21'),
(199, 'Cập nhật công việc', 'Công việc: 11 vừa được cập nhật mới', 16, 'Cập nhật', 0, '2025-09-16 07:32:21', '2025-09-16 07:32:21'),
(200, 'Cập nhật công việc', 'Công việc: 11 vừa được cập nhật mới', 5, 'Cập nhật', 0, '2025-09-16 07:32:21', '2025-09-16 07:32:21'),
(201, 'Cập nhật công việc', 'Công việc: 11 vừa được cập nhật mới', 12, 'Cập nhật', 0, '2025-09-16 07:32:21', '2025-09-16 07:32:21'),
(202, 'Cập nhật công việc', 'Công việc: 11 vừa được cập nhật mới', 14, 'Cập nhật', 0, '2025-09-16 07:32:47', '2025-09-16 07:32:47'),
(203, 'Cập nhật công việc', 'Công việc: 11 vừa được cập nhật mới', 2, 'Cập nhật', 0, '2025-09-16 07:32:47', '2025-09-16 07:32:47'),
(204, 'Cập nhật công việc', 'Công việc: 11 vừa được cập nhật mới', 16, 'Cập nhật', 0, '2025-09-16 07:32:47', '2025-09-16 07:32:47'),
(205, 'Công việc mới', 'Bạn được giao công việc: 11. Hạn: 2025-09-20.', 1, 'Công việc mới', 0, '2025-09-16 08:20:51', '2025-09-16 08:20:51'),
(206, 'Công việc mới', 'Bạn được giao công việc: 11. Hạn: 2025-09-20.', 15, 'Công việc mới', 0, '2025-09-16 08:20:51', '2025-09-16 08:20:51'),
(207, 'Công việc mới', 'Bạn được giao công việc: 11. Hạn: 2025-09-20.', 10, 'Công việc mới', 0, '2025-09-16 08:20:51', '2025-09-16 08:20:51'),
(208, 'Công việc mới', 'Bạn được giao công việc: 11. Hạn: 2025-09-20.', 16, 'Công việc mới', 0, '2025-09-16 08:20:51', '2025-09-16 08:20:51'),
(209, 'Công việc mới', 'Bạn được giao công việc: 22. Hạn: 2025-09-21.', 15, 'Công việc mới', 0, '2025-09-16 08:21:15', '2025-09-16 08:21:15'),
(210, 'Công việc mới', 'Bạn được giao công việc: 1. Hạn: 2025-09-19.', 2, 'Công việc mới', 0, '2025-09-17 03:10:53', '2025-09-17 03:10:53'),
(211, 'Công việc mới', 'Bạn được giao công việc: 1. Hạn: 2025-09-21.', 2, 'Công việc mới', 0, '2025-09-17 03:17:47', '2025-09-17 03:17:47'),
(212, 'Công việc mới', 'Bạn được giao công việc: 1. Hạn: 2025-09-21.', 1, 'Công việc mới', 0, '2025-09-17 03:49:22', '2025-09-17 03:49:22'),
(213, 'Cập nhật công việc', 'Công việc: 1 vừa được cập nhật mới', 1, 'Cập nhật', 0, '2025-09-17 05:02:59', '2025-09-17 05:02:59'),
(214, 'Cập nhật công việc', 'Công việc: 1 vừa được cập nhật mới', 3, 'Cập nhật', 0, '2025-09-17 05:03:47', '2025-09-17 05:03:47'),
(215, 'Công việc mới', 'Bạn được giao công việc: 1. Hạn: 2025-09-21.', 1, 'Công việc mới', 0, '2025-09-17 07:33:04', '2025-09-17 07:33:04'),
(216, 'Cập nhật công việc', 'Công việc: 1 vừa được cập nhật mới', 1, 'Cập nhật', 0, '2025-09-17 07:34:29', '2025-09-17 07:34:29'),
(217, 'Cập nhật công việc', 'Công việc: 1 vừa được cập nhật mới', 1, 'Cập nhật', 0, '2025-09-17 07:34:38', '2025-09-17 07:34:38'),
(218, 'Cập nhật công việc', 'Công việc: 1 vừa được cập nhật mới', 1, 'Cập nhật', 0, '2025-09-17 08:03:09', '2025-09-17 08:03:09'),
(219, 'Cập nhật công việc', 'Công việc: 1 vừa được cập nhật mới', 1, 'Cập nhật', 0, '2025-09-17 08:11:14', '2025-09-17 08:11:14'),
(220, 'Cập nhật công việc', 'Công việc: 1 vừa được cập nhật mới', 1, 'Cập nhật', 0, '2025-09-17 08:18:24', '2025-09-17 08:18:24');

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
-- Chỉ mục cho bảng `tep_dinh_kem`
--
ALTER TABLE `tep_dinh_kem`
  ADD PRIMARY KEY (`id`);

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
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=435;

--
-- AUTO_INCREMENT cho bảng `cong_viec`
--
ALTER TABLE `cong_viec`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=86;

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
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=67;

--
-- AUTO_INCREMENT cho bảng `cong_viec_quy_trinh`
--
ALTER TABLE `cong_viec_quy_trinh`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=161;

--
-- AUTO_INCREMENT cho bảng `cong_viec_tien_do`
--
ALTER TABLE `cong_viec_tien_do`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `du_an`
--
ALTER TABLE `du_an`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

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
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT cho bảng `tep_dinh_kem`
--
ALTER TABLE `tep_dinh_kem`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=22;

--
-- AUTO_INCREMENT cho bảng `thong_bao`
--
ALTER TABLE `thong_bao`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=221;

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
  ADD CONSTRAINT `cong_viec_ibfk_3` FOREIGN KEY (`phong_ban_id`) REFERENCES `phong_ban` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_cong_viec_du_an` FOREIGN KEY (`du_an_id`) REFERENCES `du_an` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

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
  ADD CONSTRAINT `cong_viec_tien_do_ibfk_1` FOREIGN KEY (`cong_viec_id`) REFERENCES `cong_viec` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `cong_viec_tien_do_ibfk_2` FOREIGN KEY (`a`) REFERENCES `nhanvien` (`id`) ON DELETE CASCADE;

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
