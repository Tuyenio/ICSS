-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Máy chủ: 127.0.0.1
-- Thời gian đã tạo: Th12 02, 2025 lúc 09:29 AM
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

DELIMITER $$
--
-- Thủ tục
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `CapQuyenMacDinhChoVaiTro` (IN `p_vai_tro` ENUM('Admin','Quản lý','Nhân viên'), IN `p_nguoi_cap_id` INT)   BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_nhan_vien_id INT;
    DECLARE v_ma_quyen VARCHAR(50);
    
    -- Cursor để duyệt tất cả nhân viên có vai trò này
    DECLARE cur_nhanvien CURSOR FOR 
        SELECT id FROM nhanvien WHERE vai_tro = p_vai_tro;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    OPEN cur_nhanvien;
    
    nhanvien_loop: LOOP
        FETCH cur_nhanvien INTO v_nhan_vien_id;
        IF done THEN
            LEAVE nhanvien_loop;
        END IF;
        
        -- Xóa quyền cũ của nhân viên này
        DELETE FROM nhanvien_quyen WHERE nhan_vien_id = v_nhan_vien_id;
        
        -- Cấp quyền theo vai trò
        CASE p_vai_tro
            WHEN 'Admin' THEN
                -- Admin có tất cả quyền
                INSERT INTO nhanvien_quyen (nhan_vien_id, ma_quyen, nguoi_cap_quyen_id)
                SELECT v_nhan_vien_id, ma_quyen, p_nguoi_cap_id 
                FROM he_thong_quyen WHERE trang_thai = 'Hoạt động';
                
            WHEN 'Quản lý' THEN
                -- Quản lý có quyền trung gian
                INSERT INTO nhanvien_quyen (nhan_vien_id, ma_quyen, nguoi_cap_quyen_id)
                SELECT v_nhan_vien_id, ma_quyen, p_nguoi_cap_id 
                FROM he_thong_quyen 
                WHERE trang_thai = 'Hoạt động' 
                AND ma_quyen NOT IN ('nhan_su.xoa', 'nhan_su.phan_quyen', 'phong_ban.xoa', 
                                   'du_an.xoa', 'cong_viec.xoa', 'luong.quan_ly', 
                                   'he_thong.cau_hinh', 'he_thong.sao_luu', 'he_thong.nhat_ky');
                
            WHEN 'Nhân viên' THEN
                -- Nhân viên chỉ có quyền cơ bản
                INSERT INTO nhanvien_quyen (nhan_vien_id, ma_quyen, nguoi_cap_quyen_id)
                SELECT v_nhan_vien_id, ma_quyen, p_nguoi_cap_id 
                FROM he_thong_quyen 
                WHERE trang_thai = 'Hoạt động' 
                AND ma_quyen IN ('nhan_su.xem', 'phong_ban.xem', 'du_an.xem', 
                               'cong_viec.xem', 'cong_viec.cap_nhat_tien_do', 
                               'cham_cong.xem', 'luong.xem', 'bao_cao.xem');
        END CASE;
        
    END LOOP;
    
    CLOSE cur_nhanvien;
    
END$$

DELIMITER ;

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
  `bao_cao` varchar(255) DEFAULT NULL,
  `check_in` time DEFAULT NULL,
  `check_out` time DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `cham_cong`
--

INSERT INTO `cham_cong` (`id`, `nhan_vien_id`, `ngay`, `bao_cao`, `check_in`, `check_out`) VALUES
(438, 8, '2025-10-10', NULL, '11:27:55', NULL),
(439, 21, '2025-10-24', NULL, '16:43:01', '16:43:09'),
(442, 8, '2025-11-04', NULL, '07:03:15', '17:19:32'),
(443, 24, '2025-11-04', NULL, '07:16:33', '17:04:44'),
(444, 3, '2025-11-04', NULL, '07:25:01', '17:00:07'),
(445, 25, '2025-11-04', NULL, '07:28:08', '17:01:02'),
(446, 5, '2025-11-04', NULL, '07:43:32', '17:03:28'),
(447, 17, '2025-11-04', NULL, '07:47:42', '17:03:10'),
(448, 21, '2025-11-04', NULL, '07:52:14', '17:06:48'),
(449, 15, '2025-11-04', NULL, '07:57:22', '17:01:01'),
(450, 7, '2025-11-04', NULL, '07:59:59', '17:00:35'),
(451, 23, '2025-11-04', NULL, '08:04:00', '17:01:00'),
(452, 10, '2025-11-04', NULL, '08:03:00', '17:03:00'),
(453, 25, '2025-11-05', NULL, '07:44:47', '17:07:11'),
(454, 23, '2025-11-05', NULL, '07:52:27', '17:07:32'),
(455, 10, '2025-11-05', NULL, '07:52:53', '17:07:59'),
(456, 7, '2025-11-05', NULL, '07:55:45', '17:09:21'),
(457, 15, '2025-11-05', NULL, '07:58:40', '17:07:42'),
(458, 24, '2025-11-05', NULL, '07:59:43', '17:31:24'),
(459, 3, '2025-11-05', NULL, '08:01:18', '17:37:31'),
(460, 21, '2025-11-05', NULL, '08:02:00', '17:09:00'),
(461, 8, '2025-11-05', NULL, '08:04:43', '17:14:11'),
(462, 14, '2025-11-05', NULL, '13:01:00', '17:07:20'),
(465, 9, '2025-11-06', NULL, '07:55:14', '17:11:33'),
(466, 14, '2025-11-06', NULL, '07:55:57', '17:01:53'),
(467, 25, '2025-11-06', NULL, '07:57:25', '17:01:06'),
(468, 23, '2025-11-06', NULL, '07:59:28', '17:00:53'),
(469, 3, '2025-11-06', NULL, '07:59:43', '17:00:37'),
(470, 7, '2025-11-06', NULL, '08:00:07', '17:00:58'),
(471, 21, '2025-11-06', NULL, '08:00:16', '17:01:17'),
(472, 8, '2025-11-06', NULL, '08:00:49', '17:28:46'),
(473, 10, '2025-11-06', NULL, '09:14:40', '17:00:50'),
(474, 24, '2025-11-06', NULL, '13:00:00', '18:21:00'),
(476, 3, '2025-11-07', NULL, '07:26:00', '17:18:54'),
(477, 8, '2025-11-07', NULL, '07:55:39', '17:26:56'),
(478, 23, '2025-11-07', NULL, '07:59:00', '17:01:26'),
(479, 10, '2025-11-07', NULL, '07:59:42', '17:04:17'),
(480, 21, '2025-11-07', NULL, '08:00:14', '17:13:40'),
(481, 25, '2025-11-07', NULL, '08:01:04', '17:05:06'),
(482, 7, '2025-11-07', NULL, '08:01:30', '17:13:36'),
(483, 24, '2025-11-07', NULL, '08:05:10', '17:05:07'),
(484, 9, '2025-11-07', NULL, '08:05:45', '17:16:21'),
(485, 14, '2025-11-07', NULL, '08:05:49', '17:15:35'),
(486, 5, '2025-11-07', NULL, '09:47:20', '17:14:56'),
(487, 15, '2025-11-07', NULL, '12:47:33', '17:07:07'),
(488, 3, '2025-11-10', NULL, '08:01:45', '17:08:10'),
(489, 8, '2025-11-10', NULL, '08:03:06', '17:18:39'),
(490, 25, '2025-11-10', NULL, '08:03:49', '17:20:37'),
(491, 21, '2025-11-10', NULL, '08:05:00', '17:02:00'),
(492, 7, '2025-11-10', 'Do đường tắc nên đã báo cáo c Yến và xin đến muộn', '08:09:32', '17:17:26'),
(493, 15, '2025-11-10', NULL, '08:12:00', '17:05:00'),
(494, 24, '2025-11-10', NULL, '08:04:00', '17:05:00'),
(495, 23, '2025-11-10', NULL, '08:18:58', '17:10:04'),
(496, 10, '2025-11-10', NULL, '08:04:00', '17:03:00'),
(497, 9, '2025-11-10', NULL, '08:28:20', '12:14:19'),
(498, 8, '2025-11-11', NULL, '07:52:12', '17:19:19'),
(499, 3, '2025-11-11', NULL, '07:55:59', '17:08:29'),
(500, 23, '2025-11-11', NULL, '07:57:08', '17:02:22'),
(501, 7, '2025-11-11', NULL, '07:59:28', '17:24:00'),
(502, 21, '2025-11-11', NULL, '07:59:31', '17:19:38'),
(503, 9, '2025-11-11', NULL, '07:59:32', '17:09:49'),
(504, 15, '2025-11-11', NULL, '07:59:00', '17:03:00'),
(505, 25, '2025-11-11', NULL, '08:00:12', '17:00:06'),
(506, 5, '2025-11-11', NULL, '08:01:29', '17:04:27'),
(507, 14, '2025-11-11', NULL, '08:03:08', '17:54:29'),
(508, 10, '2025-11-11', NULL, '08:03:12', '17:01:50'),
(509, 24, '2025-11-11', NULL, '08:03:31', '17:01:07'),
(510, 7, '2025-11-12', NULL, '07:57:05', '17:14:45'),
(511, 8, '2025-11-12', NULL, '07:58:41', '17:10:09'),
(512, 23, '2025-11-12', NULL, '07:59:32', '17:13:54'),
(513, 15, '2025-11-12', NULL, '07:59:36', '17:04:05'),
(514, 25, '2025-11-12', NULL, '08:00:17', '17:12:27'),
(515, 5, '2025-11-12', NULL, '08:00:27', '13:34:52'),
(516, 24, '2025-11-12', NULL, '08:01:22', '18:43:31'),
(517, 10, '2025-11-12', NULL, '08:01:49', '17:00:49'),
(518, 21, '2025-11-12', NULL, '08:02:50', '19:35:51'),
(519, 5, '2025-11-13', NULL, '07:51:27', NULL),
(520, 9, '2025-11-13', NULL, '07:54:24', '13:08:38'),
(521, 7, '2025-11-13', NULL, '07:57:31', '18:06:44'),
(522, 23, '2025-11-13', NULL, '07:57:51', '17:00:51'),
(523, 21, '2025-11-13', NULL, '08:00:11', '17:09:00'),
(524, 8, '2025-11-13', NULL, '08:00:53', '17:29:34'),
(525, 25, '2025-11-13', NULL, '08:02:35', '17:05:25'),
(526, 3, '2025-11-13', NULL, '08:04:30', '17:14:12'),
(527, 24, '2025-11-13', NULL, '08:01:00', '17:04:00'),
(528, 10, '2025-11-13', NULL, '08:03:00', '17:02:00'),
(529, 5, '2025-11-14', NULL, '07:54:40', '23:06:44'),
(530, 9, '2025-11-14', NULL, '07:57:46', NULL),
(531, 23, '2025-11-14', NULL, '07:58:39', '17:01:09'),
(532, 3, '2025-11-14', NULL, '07:59:22', NULL),
(533, 25, '2025-11-14', NULL, '08:00:00', '17:46:20'),
(534, 21, '2025-11-14', NULL, '08:00:33', NULL),
(535, 7, '2025-11-14', NULL, '08:01:39', '18:14:55'),
(536, 24, '2025-11-14', NULL, '08:04:08', '17:42:02'),
(537, 10, '2025-11-14', NULL, '08:05:47', '17:00:57'),
(538, 8, '2025-11-14', NULL, '07:59:00', '17:08:00'),
(539, 15, '2025-11-14', NULL, '13:02:20', '17:00:07'),
(540, 17, '2025-11-14', NULL, '13:08:10', '17:00:35'),
(541, 23, '2025-11-17', NULL, '07:54:51', '17:10:17'),
(542, 10, '2025-11-17', NULL, '07:56:14', '17:36:15'),
(543, 3, '2025-11-17', NULL, '07:56:47', '17:09:46'),
(544, 25, '2025-11-17', NULL, '07:59:36', '17:05:01'),
(545, 15, '2025-11-17', NULL, '07:59:45', '17:28:11'),
(546, 9, '2025-11-17', NULL, '08:01:49', '12:46:37'),
(547, 7, '2025-11-17', NULL, '08:03:22', '17:27:28'),
(548, 21, '2025-11-17', NULL, '08:04:05', '17:15:00'),
(549, 8, '2025-11-17', NULL, '08:04:09', '17:14:48'),
(550, 24, '2025-11-17', NULL, '08:04:00', '17:15:00'),
(551, 17, '2025-11-17', NULL, '08:20:37', NULL),
(552, 5, '2025-11-17', 'em quên check in từ sáng, chị sửa lại giúp em ạ', '17:06:35', '17:06:38'),
(553, 23, '2025-11-18', NULL, '07:59:19', '17:02:00'),
(554, 3, '2025-11-18', NULL, '08:00:43', '17:10:40'),
(555, 5, '2025-11-18', NULL, '08:00:44', '17:02:23'),
(557, 24, '2025-11-18', NULL, '08:02:00', '17:01:00'),
(558, 7, '2025-11-18', NULL, '08:03:01', '17:35:10'),
(559, 8, '2025-11-18', NULL, '08:16:06', '17:24:55'),
(560, 25, '2025-11-18', NULL, '08:04:42', '17:00:35'),
(561, 14, '2025-11-18', NULL, '08:00:00', '17:04:00'),
(562, 21, '2025-11-18', NULL, '08:03:00', '17:05:00'),
(563, 14, '2025-11-19', NULL, '08:02:00', '17:00:00'),
(564, 24, '2025-11-19', NULL, '08:01:00', '17:00:00'),
(565, 3, '2025-11-19', NULL, '08:01:00', '17:00:00'),
(566, 7, '2025-11-19', NULL, '08:01:00', '17:00:00'),
(567, 25, '2025-11-19', NULL, '08:01:00', '17:00:00'),
(568, 21, '2025-11-19', NULL, '08:01:00', '17:00:00'),
(569, 8, '2025-11-19', NULL, '08:01:00', '17:00:00'),
(570, 23, '2025-11-19', NULL, '08:01:00', '17:00:00'),
(571, 15, '2025-11-19', NULL, '08:01:00', '17:00:00'),
(572, 17, '2025-11-19', NULL, '08:01:00', '17:00:00'),
(573, 14, '2025-11-20', NULL, '08:00:00', '17:05:00'),
(574, 23, '2025-11-20', NULL, '07:53:30', '17:01:18'),
(575, 9, '2025-11-20', NULL, '07:53:35', '12:13:41'),
(576, 7, '2025-11-20', NULL, '07:54:16', '17:02:04'),
(577, 21, '2025-11-20', NULL, '07:59:11', '17:01:19'),
(578, 3, '2025-11-20', NULL, '07:59:21', '17:05:08'),
(579, 8, '2025-11-20', NULL, '08:01:13', '17:10:02'),
(580, 25, '2025-11-20', NULL, '08:04:42', '17:02:52'),
(581, 27, '2025-11-20', NULL, '08:28:13', '17:02:58'),
(582, 27, '2025-11-21', NULL, '07:54:28', '17:00:59'),
(583, 5, '2025-11-21', NULL, '08:00:07', '17:01:05'),
(584, 7, '2025-11-21', NULL, '08:01:13', '17:37:10'),
(585, 23, '2025-11-21', NULL, '08:02:08', '17:00:26'),
(586, 21, '2025-11-21', NULL, '08:03:01', '17:00:35'),
(587, 3, '2025-11-21', NULL, '08:03:41', '17:11:35'),
(588, 9, '2025-11-21', NULL, '08:04:27', '17:11:16'),
(589, 8, '2025-11-21', NULL, '08:05:04', '17:17:35'),
(590, 24, '2025-11-21', NULL, '08:10:38', '17:01:06'),
(591, 14, '2025-11-21', NULL, '08:04:00', '17:01:00'),
(592, 17, '2025-11-21', NULL, '13:00:00', '17:38:00'),
(593, 3, '2025-11-24', NULL, '07:58:24', NULL),
(594, 27, '2025-11-24', NULL, '07:59:17', NULL),
(595, 9, '2025-11-24', NULL, '07:59:48', '12:08:55'),
(596, 21, '2025-11-24', NULL, '07:59:51', NULL),
(597, 25, '2025-11-24', NULL, '08:00:27', NULL),
(598, 7, '2025-11-24', NULL, '08:01:22', NULL),
(599, 24, '2025-11-24', NULL, '08:06:53', NULL),
(600, 8, '2025-11-24', NULL, '08:12:11', NULL),
(601, 17, '2025-11-24', NULL, '08:29:48', NULL),
(602, 10, '2025-11-24', NULL, '08:38:11', NULL),
(603, 14, '2025-11-24', NULL, '08:49:47', NULL),
(604, 15, '2025-11-24', NULL, '13:10:29', NULL),
(605, 18, '2025-11-26', NULL, '15:45:35', NULL);

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
  `ngay_gia_han` date DEFAULT NULL,
  `muc_do_uu_tien` enum('Thấp','Trung bình','Cao') DEFAULT 'Trung bình',
  `nguoi_giao_id` int(11) DEFAULT NULL,
  `phong_ban_id` int(11) DEFAULT NULL,
  `trang_thai` enum('Chưa bắt đầu','Đang thực hiện','Đã hoàn thành','Trễ hạn') DEFAULT 'Chưa bắt đầu',
  `trang_thai_duyet` varchar(50) DEFAULT 'Chưa duyệt',
  `ly_do_duyet` text DEFAULT NULL,
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

INSERT INTO `cong_viec` (`id`, `du_an_id`, `ten_cong_viec`, `mo_ta`, `han_hoan_thanh`, `ngay_gia_han`, `muc_do_uu_tien`, `nguoi_giao_id`, `phong_ban_id`, `trang_thai`, `trang_thai_duyet`, `ly_do_duyet`, `tai_lieu_cv`, `file_tai_lieu`, `nhac_viec`, `tinh_trang`, `ngay_tao`, `ngay_bat_dau`, `ngay_hoan_thanh`) VALUES
(174, 1, 'Bổ sung gói đào tạo 2 ngày, lên báo giá và các công việc triển khai', 'Bên phường yêu cầu lên gói đào tạo 2 ngày, và gửi sau ngày 30', '2025-12-03', '2025-12-03', 'Cao', 11, 7, 'Đã hoàn thành', 'Chưa duyệt', NULL, 'null', '', 0, NULL, '2025-09-30 10:27:50', '2025-11-11', '2025-11-15'),
(175, 1, 'Đốc thúc đội marketing tư vấn các gói đào tạo', 'Đốc thúc Dương về gói đào tạo tại Phú Thọ', '2025-11-16', NULL, 'Cao', 11, 7, 'Đã hoàn thành', 'Chưa duyệt', NULL, 'null', '', NULL, NULL, '2025-09-30 10:27:50', '2025-11-11', '2025-11-15'),
(176, 1, 'Làm việc với a Bình BIDV', 'Đang tiến hành báo giá', '2025-11-16', NULL, 'Cao', 11, 7, 'Đã hoàn thành', 'Chưa duyệt', NULL, 'null', '/opt/Tomcat/uploads/CTĐT BIDV - PROMPT2.docx', 0, NULL, '2025-09-30 10:27:50', '2025-11-11', '2025-11-15'),
(177, 1, 'Lên phương án hợp tác với TPX', 'gọi ko bắt máy, nhắn tin không trả lời', '2025-11-16', NULL, 'Cao', 11, 7, 'Đã hoàn thành', 'Chưa duyệt', NULL, 'null', '', NULL, NULL, '2025-09-30 10:27:50', '2025-11-11', '2025-11-15'),
(178, 1, 'Bán được 5 gói đào tạo về AI', 'null', '2025-12-09', '2025-12-06', 'Trung bình', 4, 7, 'Đang thực hiện', 'Đã duyệt', 'Chưa chốt được hợp đồng', 'null', '', NULL, NULL, '2025-09-30 10:27:50', '2025-09-24', NULL),
(179, 1, 'Trong tháng 9 đến giữa tháng 10 phải bán được 1 Dashboard', 'null', '2025-11-30', NULL, 'Cao', 4, 7, 'Trễ hạn', 'Chưa duyệt', NULL, 'null', '', NULL, NULL, '2025-09-30 10:27:51', '2025-09-22', NULL),
(180, 1, 'Oracle cloud: Ký hợp đồng với 3C', 'Đã liên hệ với a Cường 3C, họ đang dùng Viettel để triển khai game trong nước. Còn gói Global thì cần 2 tháng nữa mới đánh gía', '2025-11-30', NULL, 'Cao', 11, 7, 'Đã hoàn thành', 'Chưa duyệt', NULL, 'null', '', 0, NULL, '2025-09-30 10:27:51', '2025-09-22', '2025-11-28'),
(181, 1, 'Tham gia sự kiện tại Hòa Lạc', 'Tư vấn và tìm kiếm khách hàng', '2025-11-16', NULL, 'Cao', 11, 7, 'Đã hoàn thành', 'Chưa duyệt', NULL, 'null', '', NULL, NULL, '2025-09-30 10:27:51', '2025-11-11', '2025-11-15'),
(182, 1, 'Làm việc với Luxtech xây dựng kế hoạch đi tỉnh', 'Đốc thúc C Phương lên kế hoạch kinh doanh', '2025-11-16', NULL, 'Cao', 11, 7, 'Trễ hạn', 'Từ chối', 'Chưa thấy file báo cáo công việc với Luxtech chỗ Mai Phương', 'null', '', NULL, NULL, '2025-09-30 10:27:51', '2025-11-11', '2025-11-15'),
(183, 1, 'Tư vấn giải pháp Dashboard cho a Đỉnh', 'đang làm việc', '2025-11-16', NULL, 'Cao', 11, 7, 'Đã hoàn thành', 'Chưa duyệt', NULL, 'null', '', NULL, NULL, '2025-09-30 10:27:51', '2025-11-11', '2025-11-15'),
(184, 1, 'Làm việc với a Tùng Gtel', 'null', '2025-11-16', NULL, 'Cao', 11, 7, 'Đã hoàn thành', 'Chưa duyệt', NULL, 'null', '', NULL, NULL, '2025-09-30 10:27:51', '2025-11-11', '2025-11-15'),
(185, 1, 'Đốc thúc Pacisoft lên báo giá cho dự án Database', 'đã báo giá cho mobifone', '2025-11-16', NULL, 'Cao', 11, 7, 'Đã hoàn thành', 'Chưa duyệt', NULL, 'null', '', NULL, NULL, '2025-09-30 10:27:51', '2025-11-11', '2025-11-15'),
(186, 1, 'Làm việc lại với Mobifone', 'Giữ mối quan hệ để triển khai các việc tiếp theo', '2025-11-16', NULL, 'Cao', 11, 7, 'Đã hoàn thành', 'Chưa duyệt', NULL, 'null', '', NULL, NULL, '2025-09-30 10:27:52', '2025-11-11', '2025-11-15'),
(187, 1, 'Lên kế hoạch Qúy IV', 'null', '2025-11-16', NULL, 'Cao', 11, 7, 'Đã hoàn thành', 'Chưa duyệt', NULL, 'null', '', NULL, NULL, '2025-09-30 10:27:52', '2025-11-11', '2025-11-15'),
(188, 1, 'Tìm SĐT của danh sách khách hàng', 'Phúc hỗ trợ tìm SĐT', '2025-11-16', NULL, 'Cao', 11, 7, 'Đã hoàn thành', 'Chưa duyệt', NULL, 'null', '', NULL, NULL, '2025-09-30 10:27:52', '2025-11-11', '2025-11-15'),
(190, 1, 'suppor Gpay làm việc với Hanpass và Gamapay', 'Gửi phiếu thông tin của GPay cho các đơn vị', '2025-11-16', NULL, 'Cao', 4, 8, 'Đã hoàn thành', 'Chưa duyệt', NULL, 'null', '', NULL, NULL, '2025-09-30 10:27:52', '2025-11-11', '2025-11-15'),
(192, 1, 'Soạn hợp đồng với phường Đồ Sơn', 'null', '2025-11-16', NULL, 'Cao', 4, 8, 'Đã hoàn thành', 'Chưa duyệt', NULL, 'null', '', NULL, NULL, '2025-09-30 10:27:52', '2025-11-11', '2025-11-15'),
(193, 1, 'Làm lại số hotline cho facebook, zalo và các trang mạng xã hội của cty', 'null', '2025-11-24', NULL, 'Cao', 4, 1, 'Trễ hạn', 'Chưa duyệt', NULL, 'null', '', 0, NULL, '2025-09-30 10:27:53', '2025-09-26', '2025-11-21'),
(194, 1, 'Tuyển dụng thực tập sinh và nhân sự đề nghị', 'null', '2025-11-16', NULL, 'Cao', 4, 1, 'Đã hoàn thành', 'Chưa duyệt', NULL, 'null', '', NULL, NULL, '2025-09-30 10:27:53', '2025-11-11', '2025-11-15'),
(195, 1, 'Báo cáo của 10 tập đoàn lớn tại Việt Nam', 'null', '2025-11-16', '2025-11-14', 'Cao', 4, 12, 'Đã hoàn thành', 'Chưa duyệt', NULL, 'null', '', 0, NULL, '2025-09-30 10:27:53', '2025-11-11', '2025-11-15'),
(196, 1, 'Tối ưu hóa AI Agent', 'Nghiên cứu tối ưu các node trong workflow cùng anh Quang Anh', '2025-11-16', NULL, 'Cao', 4, 12, 'Đã hoàn thành', 'Chưa duyệt', NULL, 'null', '', NULL, NULL, '2025-09-30 10:27:53', '2025-11-11', '2025-11-15'),
(197, 1, 'Nghiên cứu phần AI/ML trong Dashboard', 'Tìm hiểu các thuật toán, dữ liệu, mô hình triển khai huấn luyện AI', '2025-11-16', NULL, 'Cao', 4, 6, 'Đã hoàn thành', 'Đã duyệt', 'ok', 'null', '', NULL, NULL, '2025-09-30 10:27:53', '2025-11-11', '2025-11-15'),
(198, 1, 'Nghiên cứu báo cáo về hoạt động của AI SOC', 'null', '2025-11-16', NULL, 'Cao', 4, 12, 'Đã hoàn thành', 'Chưa duyệt', NULL, 'null', '', 0, NULL, '2025-09-30 10:27:53', '2025-11-11', '2025-11-15'),
(199, 1, 'Lên quy trình pentest Website và App', 'null', '2025-11-16', NULL, 'Cao', 4, 12, 'Đã hoàn thành', 'Chưa duyệt', NULL, 'null', '', NULL, NULL, '2025-09-30 10:27:53', '2025-11-11', '2025-11-15'),
(201, 1, 'Hoàn thiện các gói tư vấn ATTT cấp độ, đánh giá hệ thống, xây dựng các gói đào tạo nhận thức, đào tạo chuyên sâu.', 'Hoàn thiện các gói tư vấn ATTT cấp độ, sổ tay ATTT', '2025-11-16', NULL, 'Cao', 6, 6, 'Đã hoàn thành', 'Đã duyệt', 'ok', 'https://docs.google.com/document/d/1n1luF4iAIxi1K5WnTGnqRdHzqfln09yv/edit?usp=sharing&ouid=112270737146532441010&rtpof=true&sd=true', '', NULL, NULL, '2025-09-30 10:27:54', '2025-11-11', '2025-11-15'),
(202, 1, 'Chốt thời gian chuyển giao các sản phẩm của Hyper-G', 'Dashboard, AISOC', '2025-11-16', NULL, 'Cao', 6, 6, 'Đã hoàn thành', 'Chưa duyệt', NULL, 'null', '', NULL, NULL, '2025-09-30 10:27:54', '2025-11-11', '2025-11-15'),
(205, 1, 'Xây dựng phương án giới thiệu các sản phẩm cho NIC', 'Xây dựng phương án giới thiệu các sản phẩm cho NIC: DashBoard, AISOC', '2025-11-16', NULL, 'Trung bình', 18, 6, 'Đã hoàn thành', 'Chưa duyệt', NULL, 'null', '', NULL, NULL, '2025-10-07 01:39:15', '2025-11-11', '2025-11-15'),
(206, 1, 'các bạn kỹ thuật nghiên cứu làm các dashboard cơ bản', 'link nghiên cứu đã có trong zalo', '2025-11-16', NULL, 'Cao', 6, 6, 'Đã hoàn thành', 'Chưa duyệt', NULL, 'null', '', NULL, NULL, '2025-10-17 04:12:05', '2025-11-11', '2025-11-15'),
(207, 1, 'Đào tạo sale cho nhân viên công ty', 'Mr Trung lên kế hoạch triển khai', '2025-11-16', NULL, 'Cao', 11, 7, 'Đã hoàn thành', 'Chưa duyệt', NULL, 'null', '', NULL, NULL, '2025-10-17 04:14:38', '2025-11-11', '2025-11-15'),
(209, 1, 'HyperG bàn giao AI SOC', 'Công việc chưa thực hiện được do Hyper-G chưa bàn giao', '2025-11-29', NULL, 'Cao', 6, 6, 'Trễ hạn', 'Chưa duyệt', NULL, 'null', '', 0, NULL, '2025-10-17 04:23:03', '2025-11-14', NULL),
(210, 1, 'Làm việc với Hyper G để xin tài liệu đào tạo kĩ thuật', 'null', '2025-11-16', NULL, 'Cao', 6, 6, 'Đã hoàn thành', 'Chưa duyệt', NULL, 'null', '', NULL, NULL, '2025-10-17 04:25:42', '2025-11-11', '2025-11-15'),
(211, 1, 'Hoàn thiện các chức năng quản lý dự án theo các qui trình ', 'Đưa các bước của qui trình thực hiện dự án của các bộ phận liên quan', '2025-11-16', NULL, 'Cao', 6, 6, 'Đã hoàn thành', 'Chưa duyệt', NULL, 'null', '/opt/Tomcat/uploads/qui trinh ky thuat.png;/opt/Tomcat/uploads/QUY TRÌNH ICS.docx', 0, NULL, '2025-10-20 07:18:15', '2025-11-11', '2025-11-15'),
(214, 1, 'Xuất hóa đơn HyperG - Cathay', 'Nộp thuế ghi nhận thuế đầu vào có vấn đề gì không khi thanh toán chậm vì HĐ kí 1 năm/ trình bày các rủi ro? Xuất hóa đơn ra (ICS xuất cho Cathay). Thanh toán (chỉ thanh toán phần tiên chưa bao gồm thuế). Giữ thuế lại (nộp hộ cho HyperG)', '2025-11-21', '2025-11-21', 'Cao', 4, 1, 'Trễ hạn', 'Chưa duyệt', NULL, 'null', '', 0, NULL, '2025-11-14 06:13:09', '2025-11-14', NULL),
(215, 1, 'Lên chương trình đào tạo cho BIDV', 'Xây dựng chương trình đào tạo 1 ngày cho BIDV và báo giá. Đã gửi chương trình đào tạo cho BIDV', '2025-11-21', NULL, 'Thấp', 11, 7, 'Trễ hạn', 'Chưa duyệt', NULL, 'null', '', NULL, NULL, '2025-11-17 00:59:30', '2025-11-17', NULL),
(217, 1, 'lên file quản lý dự án Agribank', 'Dũng quản lý', '2025-11-17', NULL, 'Thấp', 11, 7, 'Trễ hạn', 'Chưa duyệt', NULL, 'null', '', 0, NULL, '2025-11-17 01:08:49', '2025-11-17', NULL),
(226, 56, 'Tìm kiếm đối tác và liên hệ lắp thêm đường internet mới chạy AI SOC', 'Vẫn đang tìm thêm các bên viễn thông để kéo thêm đường Internet. Đã liên hệ cả 3 nhà mạng CMC, Viettel, FPT đều không lắp được do cơ sở hạ tầng', '2025-11-16', NULL, 'Trung bình', 4, 6, 'Đã hoàn thành', 'Chưa duyệt', NULL, 'null', '', NULL, NULL, '2025-11-17 01:41:08', '2025-11-11', '2025-11-15'),
(227, 56, 'Thêm xem theo tuần, tháng tổng hợp công việc trang HRM', 'null', '2025-11-16', NULL, 'Trung bình', 4, 6, 'Đã hoàn thành', 'Chưa duyệt', NULL, 'Đã thêm vào phần chức năng báo cáo', '', NULL, NULL, '2025-11-17 01:41:09', '2025-11-11', '2025-11-15'),
(228, 56, 'Thêm phần gửi danh sách hoặc lí do checkin hoặc checkout muộn', 'null', '2025-11-16', NULL, 'Trung bình', 4, 6, 'Đã hoàn thành', 'Chưa duyệt', NULL, 'null', '', NULL, NULL, '2025-11-17 01:41:09', '2025-11-11', '2025-11-15'),
(229, 56, 'Thêm dự án cá nhân có thể thêm list công việc dự án cho từng cá nhân', 'null', '2025-11-16', NULL, 'Trung bình', 4, 6, 'Đã hoàn thành', 'Chưa duyệt', NULL, 'null', '', NULL, NULL, '2025-11-17 01:41:09', '2025-11-11', '2025-11-15'),
(230, 56, 'Sửa lại phần dự án có thể giao việc cho các nhân viên của tất cả các phòng', 'null', '2025-11-16', NULL, 'Trung bình', 4, 6, 'Đã hoàn thành', 'Chưa duyệt', NULL, 'null', '', NULL, NULL, '2025-11-17 01:41:09', '2025-11-11', '2025-11-15'),
(231, 56, 'Sửa lại phần thống kê báo cáo đang bị sai logic về % hoàn thành công việc', 'null', '2025-11-16', NULL, 'Trung bình', 4, 6, 'Đã hoàn thành', 'Chưa duyệt', NULL, 'null', '', NULL, NULL, '2025-11-17 01:41:09', '2025-11-11', '2025-11-15'),
(232, 57, 'Web HyperG ( Kết nối API web tổng và web con )', 'null', '2040-11-18', NULL, 'Trung bình', 4, 6, 'Đang thực hiện', 'Chưa duyệt', NULL, 'null', '', NULL, NULL, '2025-11-17 01:41:09', '2025-11-26', NULL),
(233, 57, 'Web HyperG kiểm tra toàn bộ frontend và gửi HyperG check', 'null', '2025-11-16', NULL, 'Trung bình', 4, 6, 'Đã hoàn thành', 'Chưa duyệt', NULL, 'null', '', NULL, NULL, '2025-11-17 01:41:09', '2025-11-11', '2025-11-15'),
(234, 57, 'Web HyperG đẩy web lên Server hệ thống để chạy', NULL, '2042-11-18', NULL, 'Trung bình', 4, 6, 'Chưa bắt đầu', 'Chưa duyệt', NULL, NULL, NULL, NULL, NULL, '2025-11-17 01:41:10', '2025-11-28', NULL),
(235, 1, 'AI SOC đánh giá hồ sơ đăng ký dịch vụ an ninh mạng ( sản phẩm )', NULL, '2025-11-16', NULL, 'Trung bình', 4, 6, 'Đã hoàn thành', 'Chưa duyệt', NULL, NULL, NULL, NULL, NULL, '2025-11-17 01:41:10', '2025-11-11', '2025-11-15'),
(236, 1, 'Báo cáo kết quả CSA chạy trên windows, Linux Server ( hiệu suất. tỉ lệ nhanh chậm)', 'null', '2025-11-16', NULL, 'Trung bình', 4, 6, 'Đã hoàn thành', 'Chưa duyệt', NULL, 'null', '/opt/Tomcat/uploads/tài liệu cho nhân viên kinh doanh sp CSA-ICS.docx;/opt/Tomcat/uploads/Tài liệu kỹ thuật CSA đủ.docx', NULL, NULL, '2025-11-17 01:41:10', '2025-11-11', '2025-11-15'),
(237, 1, 'VietGuard đổi logo và chỉnh mã nguồn đúng tên VietGuard', NULL, '2025-11-16', NULL, 'Trung bình', 4, 6, 'Đã hoàn thành', 'Chưa duyệt', NULL, NULL, NULL, NULL, NULL, '2025-11-17 01:41:10', '2025-11-11', '2025-11-15'),
(238, 1, 'Kết quả báo cáo của 6 ngân hàng', NULL, '2025-11-16', NULL, 'Trung bình', 4, 6, 'Đã hoàn thành', 'Chưa duyệt', NULL, NULL, NULL, NULL, NULL, '2025-11-17 01:41:10', '2025-11-11', '2025-11-15'),
(239, 1, 'Triển khai CSA, lấy list danh sách web nhân viên sử dụng', 'null', '2047-11-18', NULL, 'Trung bình', 4, 6, 'Đang thực hiện', 'Chưa duyệt', NULL, 'null', '', NULL, NULL, '2025-11-17 01:41:11', '2025-12-03', '2025-11-18'),
(240, 1, 'Hoàn thiện backend Dashboard đi thi A05', 'null', '2025-11-16', NULL, 'Trung bình', 4, 6, 'Đã hoàn thành', 'Chưa duyệt', NULL, 'null', '', NULL, NULL, '2025-11-17 01:41:11', '2025-11-11', '2025-11-15'),
(241, 1, 'Hoàn thiện Dashboard Sales', 'null', '2025-12-26', NULL, 'Trung bình', 4, 6, 'Đang thực hiện', 'Chưa duyệt', NULL, 'null', '', 0, NULL, '2025-11-17 01:41:11', '2025-12-05', NULL),
(242, 56, 'Bổ sung click vào các phòng ban sẽ hiện các công việc của phòng Ban đang thực hiện ', 'null', '2025-11-18', NULL, 'Trung bình', 4, 6, 'Đã hoàn thành', 'Chưa duyệt', NULL, 'null', '', NULL, NULL, '2025-11-17 05:54:43', '2025-11-17', '2025-11-18'),
(243, 56, 'Thêm phân loại theo ngày và tuần của list công việc', 'Trong mục báo cáo nhanh, thêm phân loại theo ngày, theo tuần ', '2025-11-16', NULL, 'Cao', 4, 1, 'Đã hoàn thành', 'Chưa duyệt', NULL, 'null', '', NULL, NULL, '2025-11-17 05:56:03', '2025-11-11', '2025-11-15'),
(244, 47, 'Trao đổi với Phòng Văn Hóa về Netzero Tours', '- Trao đổi với Cán bộ Văn hóa du lịch của Phường để tư vấn về chtr Netzero tours\r\n- Tạo nhóm có a Tim để cùng tư vấn cụ thể ', '2025-11-20', NULL, 'Trung bình', 4, 7, 'Trễ hạn', 'Chưa duyệt', NULL, 'null', '', NULL, NULL, '2025-11-17 06:04:04', '2025-11-17', NULL),
(245, 37, 'gửi báo giá dự toán', 'null', '2025-11-16', NULL, 'Thấp', 11, 6, 'Đã hoàn thành', 'Chưa duyệt', NULL, 'null', '', NULL, NULL, '2025-11-17 06:19:43', '2025-11-11', '2025-11-15'),
(246, 37, 'Ký hợp đồng triển khai', 'Mục tiêu ký được hợp đồng triển khai trong năm nay. Chuẩn bị năm 2026', '2025-12-31', NULL, 'Thấp', 11, 7, 'Đang thực hiện', 'Chưa duyệt', NULL, 'null', '', NULL, NULL, '2025-11-17 06:21:40', '2025-11-17', NULL),
(247, 38, 'GỬi báo giá', 'null', '2025-11-16', NULL, 'Thấp', 11, 7, 'Đã hoàn thành', 'Chưa duyệt', NULL, 'null', '', NULL, NULL, '2025-11-17 06:29:32', '2025-11-11', '2025-11-15'),
(248, 58, 'Đưa mini app lên hệ thống Zalo Demo', 'Chưa có sản phẩm nên chưa thể làm demo, đợi anh Trung + Dương', '2025-11-30', NULL, 'Cao', 4, 6, 'Trễ hạn', 'Chưa duyệt', NULL, 'null', '', 0, NULL, '2025-11-17 06:33:25', '2025-11-10', NULL),
(249, 58, 'Chính sách giá với ECHOSS', '- Trao đổi chinh sách giá  - Trung ', '2025-11-22', NULL, 'Cao', 4, 7, 'Trễ hạn', 'Chưa duyệt', NULL, 'null', '', 0, NULL, '2025-11-17 06:37:40', '2025-11-17', NULL),
(250, 58, 'Ký hợp tác với ECHOSS', 'Triển khai ký MOU và hợp đồng với ECHOSS', '2025-11-22', NULL, 'Cao', 4, 8, 'Trễ hạn', 'Chưa duyệt', NULL, 'null', '', 0, NULL, '2025-11-17 06:38:28', '2025-11-17', NULL),
(251, 38, 'Đợi xét duyệt ngân sách', 'null', '2025-12-31', NULL, 'Thấp', 11, 7, 'Đang thực hiện', 'Chưa duyệt', NULL, 'null', '/opt/Tomcat/uploads/mobifone - Oracle Database.pdf', NULL, NULL, '2025-11-17 06:40:16', '2025-11-17', '2025-11-17'),
(252, 39, 'Họp online xác định nhu cầu thực tế', 'null', '2025-11-30', NULL, 'Trung bình', 11, 6, 'Trễ hạn', 'Chưa duyệt', NULL, 'null', '', NULL, NULL, '2025-11-17 06:45:22', '2025-11-24', NULL),
(253, 48, 'Gặp mặt lần đầu nắm yêu cầu', 'null', '2025-11-16', NULL, 'Thấp', 11, 6, 'Đã hoàn thành', 'Chưa duyệt', NULL, 'null', '', NULL, NULL, '2025-11-17 06:49:48', '2025-11-11', '2025-11-15'),
(254, 48, 'Khảo sát hạ tầng cơ bản', 'Khảo sát cơ bản', '2025-11-16', NULL, 'Thấp', 11, 6, 'Đã hoàn thành', 'Chưa duyệt', NULL, 'null', '', NULL, NULL, '2025-11-17 06:53:45', '2025-11-11', '2025-11-15'),
(255, 48, 'Khảo sát IT', 'null', '2025-11-30', NULL, 'Cao', 11, 6, 'Đã hoàn thành', 'Chưa duyệt', NULL, 'null', '/opt/Tomcat/uploads/Biên bản cuộc họp ICS-Agribank_ 20-11.pdf', NULL, NULL, '2025-11-17 06:54:35', '2025-11-17', '2025-11-24'),
(256, 40, 'Hẹn cuối tháng 11 khảo sát', 'null', '2025-11-30', NULL, 'Thấp', 11, 6, 'Trễ hạn', 'Chưa duyệt', NULL, 'null', '', NULL, NULL, '2025-11-17 06:56:27', '2025-11-17', NULL),
(257, 41, 'Dùng thử', 'Phản hồi tốt', '2025-11-16', NULL, 'Thấp', 11, 6, 'Đã hoàn thành', 'Chưa duyệt', NULL, 'null', '', NULL, NULL, '2025-11-17 07:10:31', '2025-11-11', '2025-11-15'),
(258, 41, 'Lên chính sách báo giá', 'Đợi a Âu xét duyệt chính sách giá cho 3C', '2025-11-21', NULL, 'Thấp', 11, 7, 'Trễ hạn', 'Chưa duyệt', NULL, 'null', '', NULL, NULL, '2025-11-17 07:12:42', '2025-11-17', NULL),
(260, 50, 'Hỗ trợ kỹ thuật', 'Làm việc với IRtech để nắm sản phẩm IRmind', '2025-11-30', NULL, 'Thấp', 11, 6, 'Trễ hạn', 'Chưa duyệt', NULL, 'null', '', 0, NULL, '2025-11-17 08:36:10', '2025-11-17', NULL),
(261, 50, 'Trao đổi chính sách IRTECH', 'null', '2025-11-30', NULL, 'Thấp', 11, 7, 'Trễ hạn', 'Chưa duyệt', NULL, 'null', '', NULL, NULL, '2025-11-17 08:36:47', '2025-11-17', NULL),
(262, 44, 'Làm việc với CyStack để nắm khi nào khảo sát', 'null', '2025-11-30', NULL, 'Thấp', 11, 6, 'Trễ hạn', 'Chưa duyệt', NULL, 'null', 'D:/uploads/Phạm Minh Thắng_Báo cáo TTDN VNPT TH_Final.docx', NULL, NULL, '2025-11-17 08:38:38', '2025-11-17', NULL),
(263, 52, 'Chốt được lịch sang thăm văn phòng', 'null', '2025-11-30', NULL, 'Thấp', 11, 7, 'Trễ hạn', 'Chưa duyệt', NULL, 'null', '', NULL, NULL, '2025-11-17 08:41:19', '2025-11-17', NULL),
(266, 71, 'Trao đổi với a Đạt Vinachem tư vấn ESG và các module nhà máy ', 'null', '2025-11-30', NULL, 'Thấp', 4, 6, 'Trễ hạn', 'Chưa duyệt', NULL, 'null', '', NULL, NULL, '2025-11-20 04:14:04', '2025-11-21', NULL),
(267, 44, 'Ký NDA giữa CyStack và Medlac', 'null', '2025-11-17', NULL, 'Thấp', 11, 7, 'Trễ hạn', 'Chưa duyệt', NULL, 'null', '', NULL, NULL, '2025-11-20 04:23:45', '2025-11-17', NULL),
(268, 44, 'Khảo Sát Công ty Dược', 'Trung CyStack sẽ sắp xếp lịch và báo ICS sau. Tuyền bám sát nhắc a Trung để theo dõi tiến độ', '2025-11-30', NULL, 'Thấp', 11, 6, 'Chưa bắt đầu', 'Chưa duyệt', NULL, NULL, '', NULL, 'Đã xóa', '2025-11-20 04:32:43', '2025-11-18', NULL),
(269, 44, 'Khảo Sát Công ty Dược', 'Trung CyStack sẽ sắp xếp lịch khảo sát. Tuyền bám sát để nắm lịch đi cùng', '2025-11-30', NULL, 'Thấp', 11, 6, 'Chưa bắt đầu', 'Chưa duyệt', NULL, NULL, '', NULL, 'Đã xóa', '2025-11-20 04:34:26', '2025-11-19', NULL),
(270, 44, 'Khảo Sát Công ty Dược', 'Tuyền nắm lịch để đi khảo sát cùng', '2025-11-30', NULL, 'Thấp', 11, 7, 'Trễ hạn', 'Chưa duyệt', NULL, 'null', '', NULL, NULL, '2025-11-20 04:35:25', '2025-11-20', NULL),
(271, 40, 'Đã xin lịch khảo sát, a ĐỈnh sẽ liên hệ trước 1 tuần', 'null', '2025-12-15', NULL, 'Thấp', 11, 7, 'Đang thực hiện', 'Chưa duyệt', NULL, 'null', '', NULL, NULL, '2025-11-20 04:46:51', '2025-11-20', NULL),
(272, 41, 'Đã gửi báo giá cho a Cường 3C', 'Đợi phản hồi từ 3C, tầm từ giữa tháng 12 triển khai. Nam hỗ trợ kỹ thuật', '2025-12-20', NULL, 'Thấp', 11, 7, 'Chưa bắt đầu', 'Chưa duyệt', NULL, 'null', '', NULL, NULL, '2025-11-20 04:51:12', '2025-11-20', NULL),
(275, 56, 'Chỉnh sửa 2', '- Phân nhóm và chọn lọc quyền hạn của các thành viên từ Ban điều hành, đến trưởng phòng, nhân viên: mở các tick để phân quyền, khi đó admin hoặc lãnh đạo sẽ phân quyền cho cấp dưới và được vào các mục nào. \r\n', '2025-11-26', NULL, 'Trung bình', 4, 6, 'Trễ hạn', 'Chưa duyệt', NULL, 'null', '', NULL, NULL, '2025-11-20 06:36:00', '2025-11-20', NULL),
(276, 69, 'Họp trao đổi lại về Vyin AI', 'trao đổi lại xem AI khi kết nối với Facebook , zalo...', '2025-11-25', NULL, 'Trung bình', 24, 6, 'Trễ hạn', 'Chưa duyệt', NULL, 'null', '', NULL, NULL, '2025-11-21 01:27:03', '2025-11-24', NULL),
(277, 70, 'Frontend Learning KT', 'Hoàn thiện giao diện ', '2025-11-28', NULL, 'Cao', 24, 6, 'Trễ hạn', 'Chưa duyệt', NULL, 'null', '', NULL, NULL, '2025-11-21 01:29:09', '2025-11-21', '2025-11-24'),
(278, 70, 'Backend Learning KT', 'hoàn thiện backend cho auth và phát chiển cho các chức năng còn lại', '2025-11-28', NULL, 'Cao', 24, 6, 'Trễ hạn', 'Chưa duyệt', NULL, 'null', '', NULL, NULL, '2025-11-21 01:30:12', '2025-11-21', '2025-11-24'),
(279, 45, 'Làm việc với a Tim về Netzero', NULL, '2025-11-30', NULL, 'Trung bình', 11, 7, 'Trễ hạn', 'Chưa duyệt', NULL, NULL, '', NULL, NULL, '2025-11-21 06:47:50', '2025-11-21', NULL),
(280, 46, 'Dự án Netzero', 'Làm việc với a Tim về Netzero. A Tim đang tổng hợp gửi ICS', '2025-11-30', NULL, 'Trung bình', 11, 7, 'Trễ hạn', 'Chưa duyệt', NULL, 'null', '', NULL, NULL, '2025-11-21 06:49:58', '2025-11-21', NULL),
(281, 47, 'Làm việc với a Tim về Netzero', 'null', '2025-11-30', NULL, 'Trung bình', 11, 7, 'Trễ hạn', 'Chưa duyệt', NULL, 'null', '', NULL, NULL, '2025-11-21 06:51:17', '2025-11-21', NULL),
(282, 51, 'Giới thiệu smartdashboard', 'null', '2025-12-01', NULL, 'Thấp', 11, 7, 'Trễ hạn', 'Chưa duyệt', NULL, 'null', '', NULL, NULL, '2025-11-21 06:54:51', '2025-11-14', NULL),
(283, 42, 'đã gửi đề xuất phương án cho Đà Nẵng', 'null', '2025-11-30', NULL, 'Thấp', 11, 7, 'Trễ hạn', 'Chưa duyệt', NULL, 'null', '', NULL, NULL, '2025-11-21 06:57:37', '2025-11-03', NULL),
(284, 70, 'Hỗ trợ hoàn thiện backend cho quang anh', 'kiểm tra và hoàn thiện các backend cho chức năng', '2025-11-28', NULL, 'Trung bình', 24, 6, 'Trễ hạn', 'Chưa duyệt', NULL, 'null', '', NULL, NULL, '2025-11-24 01:47:35', '2025-11-24', NULL),
(285, 60, 'Làm website Oracle Cloud VN', NULL, '2025-11-30', NULL, 'Cao', 4, 6, 'Đã hoàn thành', 'Chưa duyệt', NULL, NULL, '', NULL, NULL, '2025-11-24 01:49:25', '2025-09-01', '2025-11-24'),
(290, 38, 'thử nhé1', '1', '2025-11-29', NULL, 'Thấp', 22, 6, 'Chưa bắt đầu', 'Chưa duyệt', NULL, NULL, '', NULL, 'Đã xóa', '2025-11-25 06:50:14', '2025-11-20', NULL),
(291, 1, '5555555', '1', '2025-11-29', NULL, 'Thấp', 18, 6, 'Chưa bắt đầu', 'Chưa duyệt', NULL, NULL, '', NULL, 'Đã xóa', '2025-11-25 06:50:49', '2025-11-20', NULL),
(292, 61, '5555555', '1', '2025-11-29', NULL, 'Thấp', 22, 7, 'Đã hoàn thành', 'Chưa duyệt', NULL, 'null', '', NULL, NULL, '2025-11-25 08:02:40', '2025-11-20', '2025-11-25'),
(293, 61, '11111', 'null', '2025-11-29', NULL, 'Thấp', 22, 7, 'Chưa bắt đầu', 'Chưa duyệt', NULL, 'null', '', NULL, 'Đã xóa', '2025-11-25 08:02:52', '2025-11-20', NULL),
(294, 1, '11111', '1', '2025-11-29', NULL, 'Thấp', 18, 6, 'Chưa bắt đầu', 'Chưa duyệt', NULL, 'null', '', NULL, 'Đã xóa', '2025-11-26 02:03:20', '2025-11-20', NULL),
(295, 51, '1', '1', '2025-11-28', NULL, 'Thấp', 22, 6, 'Chưa bắt đầu', 'Chưa duyệt', NULL, NULL, '', NULL, 'Đã xóa', '2025-11-27 02:27:50', '2025-11-27', NULL),
(296, 51, '2', '2', '2025-11-28', NULL, 'Thấp', 22, 6, 'Chưa bắt đầu', 'Chưa duyệt', NULL, NULL, '', NULL, 'Đã xóa', '2025-11-27 02:28:28', '2025-11-27', NULL),
(297, 51, '2', '1', '2025-11-28', NULL, 'Thấp', 22, 6, 'Chưa bắt đầu', 'Chưa duyệt', NULL, NULL, '', NULL, 'Đã xóa', '2025-11-27 02:44:34', '2025-11-27', NULL),
(298, 60, '1', '1', '2025-11-28', NULL, 'Thấp', 22, 6, 'Chưa bắt đầu', 'Chưa duyệt', NULL, NULL, '', NULL, 'Đã xóa', '2025-11-27 03:07:14', '2025-11-27', NULL),
(301, 50, '1', '1', '2025-11-29', NULL, 'Thấp', 22, 6, 'Chưa bắt đầu', 'Chưa duyệt', NULL, 'null', '', NULL, 'Đã xóa', '2025-11-28 08:15:36', '2025-11-28', NULL),
(302, 1, 'ba sáu', '123', '2025-11-29', NULL, 'Thấp', 22, 6, 'Chưa bắt đầu', 'Chưa duyệt', NULL, '', '', NULL, 'Đã xóa', '2025-11-28 09:14:34', '2025-11-28', NULL),
(303, 64, 'ba sáu', '1', '2025-11-29', NULL, 'Thấp', 22, 6, 'Trễ hạn', 'Chưa duyệt', NULL, '', '', NULL, NULL, '2025-11-29 02:46:41', '2025-11-28', NULL),
(304, 1, 'ba bảy', '1', '2025-11-29', NULL, 'Thấp', 22, 1, 'Trễ hạn', 'Chưa duyệt', NULL, '', '', NULL, NULL, '2025-11-29 02:47:18', '2025-11-28', NULL),
(305, 64, 'ba sáu', '1', '2025-11-29', NULL, 'Thấp', 22, 6, 'Trễ hạn', 'Chưa duyệt', NULL, '', '', NULL, NULL, '2025-11-29 02:47:49', '2025-11-28', NULL),
(306, 64, 'ba sáu', '1', '2025-11-29', NULL, 'Thấp', 22, 6, 'Trễ hạn', 'Chưa duyệt', NULL, '', '', NULL, NULL, '2025-11-29 02:55:03', '2025-11-28', NULL),
(307, 1, 'ba sáu', '1', '2025-11-29', NULL, 'Thấp', 22, 6, 'Trễ hạn', 'Chưa duyệt', NULL, '', 'D:/uploads\\1764571055044_4ad3cae5-5c65-4ebd-85e4-0e7d0dfdcd9b_Phạm Minh Thắng_Báo cáo TTDN VNPT TH.docx', NULL, 'Đã xóa', '2025-12-01 06:37:35', '2025-11-28', NULL),
(308, 1, 'ba sáu', '1', '2025-11-29', NULL, 'Thấp', 22, 6, 'Trễ hạn', 'Chưa duyệt', NULL, '', '', NULL, NULL, '2025-12-01 06:38:24', '2025-11-28', NULL),
(310, 1, 'Lên1 bản checklist quy trình giữa ICS và Luxtech', '3123', '2025-12-26', NULL, 'Cao', 24, 6, 'Chưa bắt đầu', 'Chưa duyệt', NULL, '', '', NULL, NULL, '2025-12-02 08:02:04', '2025-12-02', NULL);

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `cong_viec_danh_gia`
--

CREATE TABLE `cong_viec_danh_gia` (
  `id` int(11) NOT NULL,
  `cong_viec_id` int(11) DEFAULT NULL,
  `nguoi_danh_gia_id` int(11) DEFAULT NULL,
  `is_from_worker` tinyint(1) DEFAULT 0,
  `nhan_xet` text DEFAULT NULL,
  `thoi_gian` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `cong_viec_danh_gia`
--

INSERT INTO `cong_viec_danh_gia` (`id`, `cong_viec_id`, `nguoi_danh_gia_id`, `is_from_worker`, `nhan_xet`, `thoi_gian`) VALUES
(7, 190, 4, 0, 'Các bước tiếp theo cho thông tin feedback của các đơn vị và triển như thế nào.', '2025-10-07 01:33:50'),
(8, 192, 4, 0, 'Chưa thấy link/ file hợp đồng đính kèm', '2025-10-07 01:37:14'),
(9, 202, 6, 0, 'sdsdsds', '2025-11-17 02:12:51'),
(10, 201, 6, 0, 'Đã làm xong công việc, tuy nhiên cần hoàn thiện chi tiết hơn.', '2025-11-18 05:56:49'),
(11, 179, 22, 0, '123', '2025-11-26 09:20:32'),
(12, 294, 22, 0, '123', '2025-11-26 09:42:42'),
(13, 294, 18, 0, '123', '2025-11-26 09:43:21'),
(14, 294, 18, 0, '444444444444', '2025-11-26 09:43:30'),
(15, 294, 25, 0, 'em làm rồi anh ạ', '2025-11-26 09:57:35'),
(16, 294, 25, 0, 'bố mày làm rồi aaaaaaaaaaaaaaaaaaaaaaaaaaaa', '2025-11-26 09:58:41'),
(17, 294, 25, 0, 'làm ở đâu, anh k thấy', '2025-11-26 09:59:55'),
(18, 294, 18, 0, 'aaaa', '2025-11-26 17:23:15'),
(19, 294, 25, 1, 'bbbb', '2025-11-26 17:23:59'),
(20, 294, 18, 0, 'cccc', '2025-11-26 17:24:22'),
(21, 294, 18, 0, 'ddd', '2025-11-26 17:38:37'),
(22, 294, 22, 0, 'đây r', '2025-11-26 17:39:00'),
(23, 294, 25, 1, 'aaa', '2025-11-26 17:39:12'),
(24, 294, 25, 1, 'hú hú cà cà', '2025-11-26 17:41:53'),
(25, 294, 18, 0, 'chắc sai', '2025-11-26 17:42:46'),
(26, 294, 25, 1, 'vẫn đúng mà sếp', '2025-11-26 17:43:06'),
(27, 294, 8, 1, 'tyuiop', '2025-11-26 17:43:57'),
(28, 282, 18, 0, '123', '2025-11-27 01:57:40'),
(29, 282, 8, 1, 'hú hú', '2025-11-27 02:12:21');

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
(12, 174, 18, 'Bật nhắc việc', '2025-10-24 09:07:59'),
(13, 174, 18, 'Bật nhắc việc', '2025-10-24 09:07:59'),
(14, 174, 18, 'Tắt nhắc việc', '2025-10-24 09:08:03'),
(15, 174, 18, 'Lưu trữ công việc', '2025-10-24 09:08:23'),
(16, 174, 18, 'Khôi phục công việc', '2025-10-24 09:08:52'),
(17, 211, 18, '📅 Đổi deadline: \'2025-10-20\' → \'2025-10-25\' | 👥 Đổi người nhận: \'Nguyễn Ngọc Tuyền, Phạm Minh Thắng, Tạ Quang Anh\' → \'Nguyễn Ngọc Tuyền,Phạm Minh Thắng,Tạ Quang Anh\'', '2025-10-24 09:38:54'),
(18, 211, 18, '🔄 Đổi trạng thái: \'Chưa bắt đầu\' → \'Đã hoàn thành\' | 👥 Đổi người nhận: \'Nguyễn Ngọc Tuyền, Phạm Minh Thắng, Tạ Quang Anh\' → \'Nguyễn Ngọc Tuyền,Phạm Minh Thắng,Tạ Quang Anh\'', '2025-10-24 09:39:43'),
(19, 206, 18, '🔄 Đổi trạng thái: \'Trễ hạn\' → \'Đã hoàn thành\' | 👥 Đổi người nhận: \'Nguyễn Ngọc Tuyền, Phạm Minh Thắng, Trần Đình Nam, Vũ Tam Hanh\' → \'Nguyễn Ngọc Tuyền,Phạm Minh Thắng,Trần Đình Nam,Vũ Tam Hanh\'', '2025-10-24 09:40:54'),
(20, 176, 18, 'Bật nhắc việc', '2025-10-24 09:47:33'),
(21, 176, 18, 'Bật nhắc việc', '2025-10-24 09:47:33'),
(22, 176, 18, 'Tắt nhắc việc', '2025-10-24 09:47:39'),
(23, 211, 18, 'Bật nhắc việc', '2025-10-24 09:49:43'),
(24, 211, 18, 'Bật nhắc việc', '2025-10-24 09:49:43'),
(25, 211, 21, 'Tắt nhắc việc', '2025-10-24 09:49:53'),
(26, 174, 11, '👤 Đổi người giao: \'Võ Trung Âu\' → \'11\' | 🔄 Đổi trạng thái: \'Trễ hạn\' → \'Đã hoàn thành\'', '2025-11-04 01:06:11'),
(27, 176, 11, '🔄 Đổi trạng thái: \'Trễ hạn\' → \'Đã hoàn thành\'', '2025-11-04 01:06:32'),
(28, 183, 11, '🔄 Đổi trạng thái: \'Trễ hạn\' → \'Đã hoàn thành\'', '2025-11-04 01:06:50'),
(34, 195, 4, 'Bật nhắc việc', '2025-11-11 03:16:07'),
(35, 198, 4, 'Bật nhắc việc', '2025-11-11 03:17:05'),
(36, 209, 4, 'Bật nhắc việc', '2025-11-11 03:17:33'),
(37, 198, 14, 'Tắt nhắc việc', '2025-11-11 09:20:15'),
(38, 195, 18, 'Tắt nhắc việc', '2025-11-12 01:26:33'),
(39, 195, 18, '📅 Đổi deadline: \'2025-10-06\' → \'2025-11-12\'', '2025-11-12 01:26:51'),
(40, 197, 18, '📅 Đổi deadline: \'2025-10-10\' → \'2025-11-12\' | 🏢 Đổi phòng ban: \'?\' → \'6\' | 📎 Cập nhật link tài liệu', '2025-11-12 01:27:08'),
(41, 198, 18, '📅 Đổi deadline: \'2025-10-10\' → \'2025-11-12\'', '2025-11-12 01:27:30'),
(42, 198, 18, '🔧 [Tiến độ: bước 1] 🔄 Đổi trạng thái tiến độ: \'Chưa bắt đầu\' → \'Đã hoàn thành\'', '2025-11-12 01:27:42'),
(43, 197, 18, '🔧 [Tiến độ: bước 1] 🔄 Đổi trạng thái tiến độ: \'Chưa bắt đầu\' → \'Đã hoàn thành\'', '2025-11-12 01:27:57'),
(44, 193, 4, 'Bật nhắc việc', '2025-11-12 02:33:49'),
(45, 193, 4, 'Bật nhắc việc', '2025-11-12 02:33:49'),
(46, 193, 4, 'Tắt nhắc việc', '2025-11-12 02:33:52'),
(47, 193, 4, '📄 Cập nhật mô tả công việc | 📅 Đổi deadline: \'2025-09-30\' → \'2025-11-24\' | 📎 Cập nhật link tài liệu', '2025-11-12 02:34:15'),
(48, 193, 4, '🔄 Đổi trạng thái: \'Chưa bắt đầu\' → \'Đang thực hiện\'', '2025-11-12 02:34:27'),
(49, 179, 4, '📄 Cập nhật mô tả công việc | 📅 Đổi deadline: \'2025-10-15\' → \'2025-11-30\' | 🔄 Đổi trạng thái: \'Trễ hạn\' → \'Đang thực hiện\' | 📎 Cập nhật link tài liệu', '2025-11-12 02:37:05'),
(50, 209, 4, 'Tắt nhắc việc', '2025-11-12 02:37:08'),
(51, 209, 4, '📅 Đổi deadline: \'2025-10-18\' → \'2025-11-29\' | 👥 Đổi người nhận: \'Vũ Tam Hanh\' → \'Vũ Tam Hanh,Nguyễn Ngọc Tuyền\'', '2025-11-12 02:37:45'),
(52, 209, 4, '🔄 Đổi trạng thái: \'Chưa bắt đầu\' → \'Đang thực hiện\' | 👥 Đổi người nhận: \'Vũ Tam Hanh, Nguyễn Ngọc Tuyền\' → \'Nguyễn Ngọc Tuyền,Vũ Tam Hanh\'', '2025-11-12 02:37:53'),
(53, 195, 18, 'Gia hạn công việc đến 2025-11-14', '2025-11-14 02:22:27'),
(54, 195, 18, '🔧 [Tiến độ: bước 1] 🔄 Đổi trạng thái tiến độ: \'Đang thực hiện\' → \'Đã hoàn thành\'', '2025-11-14 02:22:43'),
(55, 195, 18, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-09-26\' | 🔄 Đổi trạng thái: \'Đã hoàn thành\' → \'Đang thực hiện\'', '2025-11-14 02:22:44'),
(56, 174, 18, '➕ Thêm tiến độ mới: \'Hoàn thành\' | Trạng thái: Chưa bắt đầu | Ngày bắt đầu: 2025-11-14 | Deadline: 2025-11-14 | Mô tả: \"Hoàn thành\"', '2025-11-14 02:28:11'),
(57, 174, 18, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-09-29\'', '2025-11-14 02:28:16'),
(58, 174, 18, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-09-29\' | 📅 Đổi deadline: \'2025-10-01\' → \'2025-11-14\'', '2025-11-14 02:29:03'),
(59, 174, 18, '🔧 [Tiến độ: Hoàn thành] 🔄 Đổi trạng thái tiến độ: \'Chưa bắt đầu\' → \'Đã hoàn thành\'', '2025-11-14 02:29:10'),
(60, 174, 18, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-09-29\'', '2025-11-14 02:29:12'),
(61, 175, 18, '➕ Thêm tiến độ mới: \'Hoàn thành\' | Trạng thái: Đã hoàn thành | Ngày bắt đầu: 2025-11-14 | Deadline: 2025-11-14 | Mô tả: \"Hoàn thành\"', '2025-11-14 02:30:53'),
(62, 175, 18, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-09-29\'', '2025-11-14 02:30:55'),
(63, 176, 18, '➕ Thêm tiến độ mới: \'Hoàn thành\' | Trạng thái: Chưa bắt đầu | Ngày bắt đầu: 2025-11-14 | Deadline: 2025-11-14 | Mô tả: \"Hoàn thành\"', '2025-11-14 02:31:15'),
(64, 176, 18, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-09-30\'', '2025-11-14 02:31:20'),
(65, 177, 18, '➕ Thêm tiến độ mới: \'Hoàn thành\' | Trạng thái: Chưa bắt đầu | Ngày bắt đầu: 2025-11-14 | Deadline: 2025-11-14 | Mô tả: \"Hoàn thành\"', '2025-11-14 02:31:32'),
(66, 177, 18, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-10-01\'', '2025-11-14 02:31:40'),
(67, 211, 18, '➕ Thêm tiến độ mới: \'Hoàn thành\' | Trạng thái: Đã hoàn thành | Ngày bắt đầu: 2025-11-14 | Deadline: 2025-11-14 | Mô tả: \"Hoàn thành\"', '2025-11-14 02:32:01'),
(68, 210, 18, '🔧 [Tiến độ: bước 1] 🔄 Đổi trạng thái tiến độ: \'Chưa bắt đầu\' → \'Đã hoàn thành\'', '2025-11-14 02:32:37'),
(69, 210, 18, '🔧 [Tiến độ: bước 2] 🔄 Đổi trạng thái tiến độ: \'Chưa bắt đầu\' → \'Đã hoàn thành\'', '2025-11-14 02:32:41'),
(70, 210, 18, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-01\'', '2025-11-14 02:32:42'),
(71, 207, 18, '🔧 [Tiến độ: bước 1] 🔄 Đổi trạng thái tiến độ: \'Chưa bắt đầu\' → \'Đã hoàn thành\'', '2025-11-14 02:32:51'),
(72, 207, 18, '🔧 [Tiến độ: bước 2] 🔄 Đổi trạng thái tiến độ: \'Chưa bắt đầu\' → \'Đã hoàn thành\'', '2025-11-14 02:32:54'),
(73, 206, 18, '🔧 [Tiến độ: bước 1] 🔄 Đổi trạng thái tiến độ: \'Chưa bắt đầu\' → \'Đã hoàn thành\'', '2025-11-14 02:33:14'),
(74, 206, 18, '🔧 [Tiến độ: bước 2] 🔄 Đổi trạng thái tiến độ: \'Chưa bắt đầu\' → \'Đã hoàn thành\'', '2025-11-14 02:33:17'),
(75, 202, 18, '🔧 [Tiến độ: Tổ chức họp trực tuyến với Hyper-G] � Cập nhật mô tả tiến độ | 🔄 Đổi trạng thái tiến độ: \'Đang thực hiện\' → \'Đã hoàn thành\'', '2025-11-14 02:33:31'),
(76, 202, 18, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-10-01\' | 👥 Đổi người nhận: \'Nguyễn Huy Hoàng, Nguyễn Ngọc Phúc, Nguyễn Tấn Dũng, Tạ Quang Anh, Trần Đình Nam, Trịnh Văn Chiến, Vũ Tam Hanh\' → \'Nguyễn Huy Hoàng,Nguyễn Ngọc Phúc,Nguyễn Tấn Dũng,Tạ Quang Anh,Trần Đình Nam,Trịnh Văn Chiến,Vũ Tam Hanh\'', '2025-11-14 02:33:34'),
(77, 201, 18, '🔧 [Tiến độ: Giao việc cho phúc nghiên cứu viết sổ tay ATTT] 🔄 Đổi trạng thái tiến độ: \'Đang thực hiện\' → \'Đã hoàn thành\'', '2025-11-14 02:33:42'),
(78, 201, 18, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-09-29\' | 👥 Đổi người nhận: \'Nguyễn Ngọc Phúc, Vũ Tam Hanh\' → \'Nguyễn Ngọc Phúc,Vũ Tam Hanh\'', '2025-11-14 02:33:46'),
(80, 181, 18, '➕ Thêm tiến độ mới: \'Hoàn thành\' | Trạng thái: Chưa bắt đầu | Ngày bắt đầu: 2025-11-14 | Deadline: 2025-11-14 | Mô tả: \"Hoàn thành\"', '2025-11-14 02:34:26'),
(81, 181, 18, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-10-01\'', '2025-11-14 02:34:27'),
(82, 181, 18, '🔧 [Tiến độ: Hoàn thành] 🔄 Đổi trạng thái tiến độ: \'Chưa bắt đầu\' → \'Đã hoàn thành\'', '2025-11-14 02:34:38'),
(83, 182, 18, '➕ Thêm tiến độ mới: \'Hoàn thành\' | Trạng thái: Chưa bắt đầu | Ngày bắt đầu: 2025-11-14 | Deadline: 2025-11-14 | Mô tả: \"Hoàn thành\"', '2025-11-14 02:34:57'),
(84, 182, 18, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-10-02\'', '2025-11-14 02:35:02'),
(85, 183, 18, '➕ Thêm tiến độ mới: \'Hoàn thành\' | Trạng thái: Chưa bắt đầu | Ngày bắt đầu: 2025-11-14 | Deadline: 2025-11-14 | Mô tả: \"Hoàn thành\"', '2025-11-14 02:35:28'),
(86, 183, 18, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-10-03\'', '2025-11-14 02:35:33'),
(87, 184, 18, '➕ Thêm tiến độ mới: \'Hoàn thành\' | Trạng thái: Chưa bắt đầu | Ngày bắt đầu: 2025-11-14 | Deadline: 2025-11-14 | Mô tả: \"Hoàn thành\"', '2025-11-14 02:35:43'),
(88, 184, 18, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-09-30\'', '2025-11-14 02:35:48'),
(89, 185, 18, '➕ Thêm tiến độ mới: \'Hoàn thành\' | Trạng thái: Chưa bắt đầu | Ngày bắt đầu: 2025-11-14 | Deadline: 2025-11-14 | Mô tả: \"Hoàn thành\"', '2025-11-14 02:35:58'),
(90, 185, 18, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-09-29\'', '2025-11-14 02:36:02'),
(91, 186, 18, '➕ Thêm tiến độ mới: \'Hoàn thành\' | Trạng thái: Chưa bắt đầu | Ngày bắt đầu: 2025-11-14 | Deadline: 2025-11-14 | Mô tả: \"Hoàn thành\"', '2025-11-14 02:36:15'),
(92, 186, 18, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-09-29\'', '2025-11-14 02:36:19'),
(93, 187, 18, '➕ Thêm tiến độ mới: \'Hoàn thành\' | Trạng thái: Chưa bắt đầu | Ngày bắt đầu: 2025-11-14 | Deadline: 2025-11-14 | Mô tả: \"Hoàn thành\"', '2025-11-14 02:36:40'),
(94, 187, 18, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-09-29\'', '2025-11-14 02:36:45'),
(95, 188, 18, '➕ Thêm tiến độ mới: \'Hoàn thành\' | Trạng thái: Chưa bắt đầu | Ngày bắt đầu: 2025-11-14 | Deadline: 2025-11-14 | Mô tả: \"Hoàn thành\"', '2025-11-14 02:36:58'),
(96, 188, 18, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-09-29\'', '2025-11-14 02:36:59'),
(97, 188, 18, '🔧 [Tiến độ: Hoàn thành] 🔄 Đổi trạng thái tiến độ: \'Chưa bắt đầu\' → \'Đã hoàn thành\'', '2025-11-14 02:37:05'),
(98, 188, 18, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-09-29\'', '2025-11-14 02:37:06'),
(99, 190, 18, '➕ Thêm tiến độ mới: \'Hoàn thành\' | Trạng thái: Đã hoàn thành | Ngày bắt đầu: 2025-11-14 | Deadline: 2025-11-14 | Mô tả: \"Hoàn thành\"', '2025-11-14 02:37:18'),
(100, 190, 18, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-09-26\' | 📎 Cập nhật link tài liệu', '2025-11-14 02:37:20'),
(101, 192, 18, '➕ Thêm tiến độ mới: \'Hoàn thành\' | Trạng thái: Chưa bắt đầu | Ngày bắt đầu: 2025-11-14 | Deadline: 2025-11-14 | Mô tả: \"Hoàn thành\"', '2025-11-14 02:37:34'),
(102, 192, 18, '📄 Cập nhật mô tả công việc | 📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-09-30\' | 📎 Cập nhật link tài liệu', '2025-11-14 02:37:38'),
(103, 194, 18, '➕ Thêm tiến độ mới: \'Hoàn thành\' | Trạng thái: Chưa bắt đầu | Ngày bắt đầu: 2025-11-14 | Deadline: 2025-11-14 | Mô tả: \"Hoàn thành\"', '2025-11-14 02:37:52'),
(104, 194, 18, '📄 Cập nhật mô tả công việc | 📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-09-25\' | 📎 Cập nhật link tài liệu', '2025-11-14 02:37:56'),
(105, 176, 18, '🔧 [Tiến độ: Hoàn thành] 🔄 Đổi trạng thái tiến độ: \'Chưa bắt đầu\' → \'Đã hoàn thành\'', '2025-11-14 02:45:10'),
(106, 176, 18, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-09-30\'', '2025-11-14 02:45:12'),
(107, 209, 24, '🔧 [Tiến độ: bước 1] 🔄 Đổi trạng thái tiến độ: \'Chưa bắt đầu\' → \'Đang thực hiện\'', '2025-11-14 02:49:28'),
(108, 211, 18, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-01\'', '2025-11-14 02:56:26'),
(109, 174, 18, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-01\'', '2025-11-14 02:56:53'),
(110, 214, 4, '🆕 Tạo mới công việc: \'Xuất hóa đơn HyperG - Cathay\' | Deadline: 2025-11-19 | Độ ưu tiên: Cao | Người nhận: Nguyễn Đức Dương,Nguyễn Thị Diễm Quỳnh', '2025-11-14 06:13:09'),
(111, 214, 4, '➕ Thêm tiến độ mới: \'bước 1\' | Trạng thái: Chưa bắt đầu | Ngày bắt đầu: 2025-11-14 | Deadline: 2025-11-18', '2025-11-14 06:13:42'),
(112, 214, 4, '➕ Thêm tiến độ mới: \'bước 2\' | Trạng thái: Chưa bắt đầu | Ngày bắt đầu: 2025-11-14 | Deadline: 2025-11-18', '2025-11-14 06:13:55'),
(113, 214, 4, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-14\' | 👥 Đổi người nhận: \'Nguyễn Đức Dương, Nguyễn Thị Diễm Quỳnh\' → \'Nguyễn Đức Dương,Nguyễn Thị Diễm Quỳnh\' | 📎 Cập nhật link tài liệu', '2025-11-14 06:13:58'),
(114, 178, 4, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-09-22\'', '2025-11-14 07:03:27'),
(115, 178, 4, 'Gia hạn công việc đến 2025-11-25', '2025-11-14 07:03:41'),
(116, 178, 4, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-09-22\'', '2025-11-14 07:03:45'),
(117, 178, 4, 'Gia hạn công việc đến 2025-11-25', '2025-11-14 07:04:02'),
(118, 178, 4, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-09-22\' | 👤 Đổi người giao: \'Đặng Lê Trung\' → \'4\' | 🔄 Đổi trạng thái: \'Chưa bắt đầu\' → \'Trễ hạn\' | 👥 Đổi người nhận: \'Đặng Lê Trung\' → \'Đặng Lê Trung,Nguyễn Đức Dương\'', '2025-11-14 07:04:23'),
(119, 178, 4, 'Xét duyệt: Đã duyệt - Lý do: Chưa chốt được hợp đồng', '2025-11-14 07:04:44'),
(120, 215, 11, '🆕 Tạo mới công việc: \'Lên chương trình đào tạo cho BIDV\' | Deadline: 2025-11-21 | Độ ưu tiên: Thấp', '2025-11-17 00:59:30'),
(121, 215, 11, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-17\' | 🔄 Đổi trạng thái: \'Chưa bắt đầu\' → \'Đang thực hiện\' | 👥 Đổi người nhận: \'(chưa có)\' → \'null\' | 📎 Cập nhật link tài liệu', '2025-11-17 00:59:53'),
(123, 215, 11, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-17\' | 🔄 Đổi trạng thái: \'Chưa bắt đầu\' → \'Đang thực hiện\' | 👥 Đổi người nhận: \'(chưa có)\' → \'null\'', '2025-11-17 01:02:07'),
(124, 217, 11, '🆕 Tạo mới công việc: \'lên file quản lý dự án Agribank\' | Deadline: 2025-11-17 | Độ ưu tiên: Thấp | Người nhận: Đặng Lê Trung', '2025-11-17 01:08:49'),
(125, 215, 11, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-17\' | 🔄 Đổi trạng thái: \'Chưa bắt đầu\' → \'Đang thực hiện\' | 👥 Đổi người nhận: \'(chưa có)\' → \'null\'', '2025-11-17 01:09:10'),
(126, 217, 11, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-17\' | 🔄 Đổi trạng thái: \'Chưa bắt đầu\' → \'Đang thực hiện\' | 📎 Cập nhật link tài liệu', '2025-11-17 01:09:16'),
(127, 215, 11, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-17\' | 🔄 Đổi trạng thái: \'Chưa bắt đầu\' → \'Đang thực hiện\' | 👥 Đổi người nhận: \'(chưa có)\' → \'null\'', '2025-11-17 01:09:27'),
(128, 215, 11, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-17\' | 🔄 Đổi trạng thái: \'Chưa bắt đầu\' → \'Đang thực hiện\' | 👥 Đổi người nhận: \'(chưa có)\' → \'Đặng Lê Trung\'', '2025-11-17 01:12:35'),
(129, 217, 11, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-17\'', '2025-11-17 01:13:07'),
(130, 215, 11, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-17\' | 🔄 Đổi trạng thái: \'Chưa bắt đầu\' → \'Đang thực hiện\'', '2025-11-17 01:13:17'),
(131, 215, 11, '➕ Thêm tiến độ mới: \'đang thực hiện\' | Trạng thái: Chưa bắt đầu | Ngày bắt đầu: 2025-11-17 | Deadline: 2025-11-17', '2025-11-17 01:13:52'),
(132, 215, 11, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-17\' | 🔄 Đổi trạng thái: \'Chưa bắt đầu\' → \'Đang thực hiện\'', '2025-11-17 01:13:55'),
(133, 215, 11, '🔧 [Tiến độ: đang thực hiện] 🔄 Đổi trạng thái tiến độ: \'Chưa bắt đầu\' → \'Đang thực hiện\'', '2025-11-17 01:14:13'),
(134, 215, 11, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-17\' | 🔄 Đổi trạng thái: \'Chưa bắt đầu\' → \'Đang thực hiện\'', '2025-11-17 01:14:15'),
(135, 217, 11, '➕ Thêm tiến độ mới: \'test\' | Trạng thái: Chưa bắt đầu | Ngày bắt đầu: 2025-11-17 | Deadline: 2025-11-17', '2025-11-17 01:14:47'),
(136, 217, 11, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-17\'', '2025-11-17 01:14:50'),
(137, 217, 11, '🔧 [Tiến độ: test] 🔄 Đổi trạng thái tiến độ: \'Chưa bắt đầu\' → \'Đang thực hiện\'', '2025-11-17 01:15:15'),
(138, 217, 11, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-17\'', '2025-11-17 01:15:20'),
(140, 197, 6, 'Xét duyệt: Đã duyệt - Lý do: ok', '2025-11-17 01:45:36'),
(148, 226, 18, '➕ Thêm tiến độ mới: \'Hoàn thành\' | Trạng thái: Chưa bắt đầu | Ngày bắt đầu: 2025-11-17 | Deadline: 2025-11-17 | Mô tả: \"Hoàn thành\"', '2025-11-17 01:48:52'),
(149, 227, 18, '➕ Thêm tiến độ mới: \'Hoàn thành\' | Trạng thái: Chưa bắt đầu | Ngày bắt đầu: 2025-11-17 | Deadline: 2025-11-17 | Mô tả: \"Hoàn thành\"', '2025-11-17 01:49:02'),
(150, 228, 18, '➕ Thêm tiến độ mới: \'Hoàn thành\' | Trạng thái: Chưa bắt đầu | Ngày bắt đầu: 2025-11-17 | Deadline: 2025-11-17 | Mô tả: \"Hoàn thành\"', '2025-11-17 01:49:46'),
(151, 202, 6, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-10-01\' | 👥 Đổi người nhận: \'Nguyễn Huy Hoàng, Nguyễn Ngọc Phúc, Nguyễn Tấn Dũng, Tạ Quang Anh, Trần Đình Nam, Trịnh Văn Chiến, Vũ Tam Hanh\' → \'Nguyễn Huy Hoàng,Nguyễn Ngọc Phúc,Nguyễn Tấn Dũng,Tạ Quang Anh,Trần Đình Nam,Trịnh Văn Chiến,Vũ Tam Hanh\'', '2025-11-17 01:49:48'),
(152, 231, 18, '➕ Thêm tiến độ mới: \'Hoàn thành\' | Trạng thái: Chưa bắt đầu | Ngày bắt đầu: 2025-11-17 | Deadline: 2025-11-17 | Mô tả: \"Hoàn thành\"', '2025-11-17 01:50:04'),
(153, 230, 18, '➕ Thêm tiến độ mới: \'Hoàn thành\' | Trạng thái: Chưa bắt đầu | Ngày bắt đầu: 2025-11-17 | Deadline: 2025-11-17 | Mô tả: \"Hoàn thành\"', '2025-11-17 01:50:15'),
(154, 229, 18, '➕ Thêm tiến độ mới: \'Hoàn thành\' | Trạng thái: Chưa bắt đầu | Ngày bắt đầu: 2025-11-17 | Deadline: 2025-11-17 | Mô tả: \"Hoàn thành\"', '2025-11-17 01:50:26'),
(155, 232, 18, '➕ Thêm tiến độ mới: \'Hoàn thành\' | Trạng thái: Chưa bắt đầu | Ngày bắt đầu: 2025-11-17 | Deadline: 2025-11-17 | Mô tả: \"Hoàn thành\"', '2025-11-17 01:50:52'),
(156, 233, 18, '➕ Thêm tiến độ mới: \'Hoàn thành\' | Trạng thái: Chưa bắt đầu | Ngày bắt đầu: 2025-11-17 | Deadline: 2025-11-17 | Mô tả: \"Hoàn thành\"', '2025-11-17 01:51:02'),
(157, 234, 18, '➕ Thêm tiến độ mới: \'Hoàn thành\' | Trạng thái: Chưa bắt đầu | Ngày bắt đầu: 2025-11-17 | Deadline: 2025-11-17 | Mô tả: \"Hoàn thành\"', '2025-11-17 01:51:13'),
(158, 241, 18, '➕ Thêm tiến độ mới: \'Hoàn thành\' | Trạng thái: Chưa bắt đầu | Ngày bắt đầu: 2025-11-17 | Deadline: 2025-11-17 | Mô tả: \"Hoàn thành\"', '2025-11-17 01:51:41'),
(159, 240, 18, '➕ Thêm tiến độ mới: \'Hoàn thành\' | Trạng thái: Chưa bắt đầu | Ngày bắt đầu: 2025-11-17 | Deadline: 2025-11-17 | Mô tả: \"Hoàn thành\"', '2025-11-17 01:51:51'),
(160, 239, 18, '➕ Thêm tiến độ mới: \'Hoàn thành\' | Trạng thái: Chưa bắt đầu | Ngày bắt đầu: 2025-11-17 | Deadline: 2025-11-17 | Mô tả: \"Hoàn thành\"', '2025-11-17 01:52:03'),
(161, 238, 18, '➕ Thêm tiến độ mới: \'Hoàn thành\' | Trạng thái: Chưa bắt đầu | Ngày bắt đầu: 2025-11-17 | Deadline: 2025-11-17 | Mô tả: \"Hoàn thành\"', '2025-11-17 01:52:18'),
(162, 237, 18, '➕ Thêm tiến độ mới: \'Hoàn thành\' | Trạng thái: Chưa bắt đầu | Ngày bắt đầu: 2025-11-17 | Deadline: 2025-11-17 | Mô tả: \"Hoàn thành\"', '2025-11-17 01:52:35'),
(163, 236, 18, '➕ Thêm tiến độ mới: \'Hoàn thành\' | Trạng thái: Chưa bắt đầu | Ngày bắt đầu: 2025-11-17 | Deadline: 2025-11-17 | Mô tả: \"Hoàn thành\"', '2025-11-17 01:52:46'),
(164, 235, 18, '➕ Thêm tiến độ mới: \'Hoàn thành\' | Trạng thái: Chưa bắt đầu | Ngày bắt đầu: 2025-11-17 | Deadline: 2025-11-17 | Mô tả: \"Hoàn thành\"', '2025-11-17 01:52:57'),
(166, 193, 18, '➕ Thêm tiến độ mới: \'Hoàn thành\' | Trạng thái: Chưa bắt đầu | Ngày bắt đầu: 2025-11-17 | Deadline: 2025-11-17 | Mô tả: \"Hoàn thành\"', '2025-11-17 01:53:31'),
(167, 180, 18, '➕ Thêm tiến độ mới: \'Hoàn thành\' | Trạng thái: Chưa bắt đầu | Ngày bắt đầu: 2025-11-17 | Deadline: 2025-11-17 | Mô tả: \"Hoàn thành\"', '2025-11-17 01:53:46'),
(168, 179, 18, '➕ Thêm tiến độ mới: \'Hoàn thành\' | Trạng thái: Chưa bắt đầu | Ngày bắt đầu: 2025-11-17 | Deadline: 2025-11-17 | Mô tả: \"Hoàn thành\"', '2025-11-17 01:54:01'),
(169, 178, 18, '➕ Thêm tiến độ mới: \'Hoàn thành\' | Trạng thái: Chưa bắt đầu | Ngày bắt đầu: 2025-11-17 | Deadline: 2025-11-17 | Mô tả: \"Hoàn thành\"', '2025-11-17 01:54:14'),
(170, 226, 25, '🔧 [Tiến độ: Hoàn thành] 🔄 Đổi trạng thái tiến độ: \'Chưa bắt đầu\' → \'Đã hoàn thành\'', '2025-11-17 01:54:55'),
(171, 226, 25, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-19\' | 🔄 Đổi trạng thái: \'Đã hoàn thành\' → \'Chưa bắt đầu\' | 📎 Cập nhật link tài liệu', '2025-11-17 01:54:56'),
(172, 227, 25, '🔧 [Tiến độ: Hoàn thành] 🔄 Đổi trạng thái tiến độ: \'Chưa bắt đầu\' → \'Đã hoàn thành\'', '2025-11-17 01:55:10'),
(173, 227, 25, '📄 Cập nhật mô tả công việc | 📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-20\' | 🔄 Đổi trạng thái: \'Đã hoàn thành\' → \'Chưa bắt đầu\' | 📎 Cập nhật link tài liệu', '2025-11-17 01:55:11'),
(174, 228, 25, '🔧 [Tiến độ: Hoàn thành] 🔄 Đổi trạng thái tiến độ: \'Chưa bắt đầu\' → \'Đã hoàn thành\'', '2025-11-17 01:55:19'),
(175, 228, 25, '📄 Cập nhật mô tả công việc | 📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-21\' | 🔄 Đổi trạng thái: \'Đã hoàn thành\' → \'Chưa bắt đầu\' | 📎 Cập nhật link tài liệu', '2025-11-17 01:55:20'),
(176, 229, 25, '🔧 [Tiến độ: Hoàn thành] 🔄 Đổi trạng thái tiến độ: \'Chưa bắt đầu\' → \'Đã hoàn thành\'', '2025-11-17 01:55:28'),
(177, 229, 25, '📄 Cập nhật mô tả công việc | 📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-22\' | 🔄 Đổi trạng thái: \'Đã hoàn thành\' → \'Chưa bắt đầu\' | 📎 Cập nhật link tài liệu', '2025-11-17 01:55:29'),
(178, 230, 25, '🔧 [Tiến độ: Hoàn thành] 🔄 Đổi trạng thái tiến độ: \'Chưa bắt đầu\' → \'Đã hoàn thành\'', '2025-11-17 01:55:42'),
(179, 230, 25, '📄 Cập nhật mô tả công việc | 📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-23\' | 🔄 Đổi trạng thái: \'Đã hoàn thành\' → \'Chưa bắt đầu\' | 📎 Cập nhật link tài liệu', '2025-11-17 01:55:43'),
(180, 231, 25, '🔧 [Tiến độ: Hoàn thành] 🔄 Đổi trạng thái tiến độ: \'Chưa bắt đầu\' → \'Đã hoàn thành\'', '2025-11-17 01:55:52'),
(181, 231, 25, '📄 Cập nhật mô tả công việc | 📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-24\' | 🔄 Đổi trạng thái: \'Đã hoàn thành\' → \'Chưa bắt đầu\' | 📎 Cập nhật link tài liệu', '2025-11-17 01:55:53'),
(182, 235, 24, '🔧 [Tiến độ: Hoàn thành] 🔄 Đổi trạng thái tiến độ: \'Chưa bắt đầu\' → \'Đã hoàn thành\'', '2025-11-17 02:04:29'),
(183, 236, 24, '🔧 [Tiến độ: Hoàn thành] 🔄 Đổi trạng thái tiến độ: \'Chưa bắt đầu\' → \'Đã hoàn thành\'', '2025-11-17 02:04:41'),
(184, 237, 24, '🔧 [Tiến độ: Hoàn thành] 🔄 Đổi trạng thái tiến độ: \'Chưa bắt đầu\' → \'Đã hoàn thành\'', '2025-11-17 02:04:50'),
(185, 238, 24, '🔧 [Tiến độ: Hoàn thành] 🔄 Đổi trạng thái tiến độ: \'Chưa bắt đầu\' → \'Đã hoàn thành\'', '2025-11-17 02:05:14'),
(186, 241, 24, '🔧 [Tiến độ: Hoàn thành] 🔄 Đổi trạng thái tiến độ: \'Chưa bắt đầu\' → \'Đang thực hiện\'', '2025-11-17 02:05:35'),
(187, 240, 24, '🔧 [Tiến độ: Hoàn thành] 🔄 Đổi trạng thái tiến độ: \'Chưa bắt đầu\' → \'Đang thực hiện\'', '2025-11-17 02:06:02'),
(188, 239, 24, '🔧 [Tiến độ: Hoàn thành] 🔄 Đổi trạng thái tiến độ: \'Chưa bắt đầu\' → \'Đang thực hiện\'', '2025-11-17 02:06:17'),
(189, 239, 24, '📄 Cập nhật mô tả công việc | 📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-12-03\' | 📎 Cập nhật link tài liệu', '2025-11-17 02:06:19'),
(190, 240, 24, '📄 Cập nhật mô tả công việc | 📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-12-04\' | 🔄 Đổi trạng thái: \'Đang thực hiện\' → \'Chưa bắt đầu\' | 📎 Cập nhật link tài liệu', '2025-11-17 02:06:26'),
(191, 241, 24, '📄 Cập nhật mô tả công việc | 📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-12-05\' | 🔄 Đổi trạng thái: \'Đang thực hiện\' → \'Chưa bắt đầu\' | 📎 Cập nhật link tài liệu', '2025-11-17 02:06:38'),
(192, 241, 24, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-12-05\' | 🔄 Đổi trạng thái: \'Đang thực hiện\' → \'Chưa bắt đầu\'', '2025-11-17 02:06:59'),
(193, 240, 24, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-12-04\' | 🔄 Đổi trạng thái: \'Đang thực hiện\' → \'Chưa bắt đầu\'', '2025-11-17 02:07:16'),
(194, 232, 24, '🔧 [Tiến độ: Hoàn thành] 🔄 Đổi trạng thái tiến độ: \'Chưa bắt đầu\' → \'Đang thực hiện\'', '2025-11-17 02:07:56'),
(195, 232, 24, '📄 Cập nhật mô tả công việc | 📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-26\' | 📎 Cập nhật link tài liệu', '2025-11-17 02:07:57'),
(196, 233, 24, '🔧 [Tiến độ: Hoàn thành] 🔄 Đổi trạng thái tiến độ: \'Chưa bắt đầu\' → \'Đã hoàn thành\'', '2025-11-17 02:08:25'),
(197, 233, 24, '📄 Cập nhật mô tả công việc | 📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-27\' | 🔄 Đổi trạng thái: \'Đã hoàn thành\' → \'Chưa bắt đầu\' | 📎 Cập nhật link tài liệu', '2025-11-17 02:08:26'),
(198, 233, 24, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-27\'', '2025-11-17 02:08:26'),
(199, 241, 24, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-12-05\' | 🔄 Đổi trạng thái: \'Đang thực hiện\' → \'Chưa bắt đầu\'', '2025-11-17 02:08:55'),
(200, 241, 24, '🔧 [Tiến độ: Hoàn thành] 🔄 Đổi trạng thái tiến độ: \'Đang thực hiện\' → \'Chưa bắt đầu\'', '2025-11-17 02:09:02'),
(201, 241, 24, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-12-05\' | 🔄 Đổi trạng thái: \'Đang thực hiện\' → \'Chưa bắt đầu\'', '2025-11-17 02:09:03'),
(202, 241, 24, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-12-05\'', '2025-11-17 02:09:10'),
(203, 241, 24, '🔧 [Tiến độ: Hoàn thành] 🔄 Đổi trạng thái tiến độ: \'Chưa bắt đầu\' → \'Đang thực hiện\'', '2025-11-17 02:09:17'),
(204, 241, 24, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-12-05\'', '2025-11-17 02:09:18'),
(217, 202, 6, '⭐ Thêm đánh giá: \"sdsdsds\"', '2025-11-17 02:12:51'),
(219, 236, 6, '📄 Cập nhật mô tả công việc | 📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-30\' | 📎 Cập nhật link tài liệu', '2025-11-17 03:43:35'),
(220, 236, 6, '📁 Tải lên file: tài liệu cho nhân viên kinh doanh sp CSA-ICS.docx, Tài liệu kỹ thuật CSA đủ.docx', '2025-11-17 03:43:35'),
(221, 214, 18, '📄 Cập nhật mô tả công việc | 📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-14\' | 👥 Đổi người nhận: \'Nguyễn Đức Dương, Nguyễn Thị Diễm Quỳnh\' → \'Nguyễn Đức Dương,Nguyễn Thị Diễm Quỳnh\'', '2025-11-17 03:54:36'),
(222, 178, 4, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-09-22\' | 🔄 Đổi trạng thái: \'Chưa bắt đầu\' → \'Đang thực hiện\' | 👥 Đổi người nhận: \'Đặng Lê Trung, Nguyễn Đức Dương\' → \'Đặng Lê Trung,Nguyễn Đức Dương\'', '2025-11-17 05:52:05'),
(223, 180, 4, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-09-22\' | 🔄 Đổi trạng thái: \'Chưa bắt đầu\' → \'Đang thực hiện\'', '2025-11-17 05:52:14'),
(225, 214, 4, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-14\' | 🔄 Đổi trạng thái: \'Chưa bắt đầu\' → \'Đang thực hiện\' | 👥 Đổi người nhận: \'Nguyễn Đức Dương, Nguyễn Thị Diễm Quỳnh\' → \'Nguyễn Đức Dương,Nguyễn Thị Diễm Quỳnh\'', '2025-11-17 05:52:29'),
(226, 193, 4, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-09-26\' | 🔄 Đổi trạng thái: \'Chưa bắt đầu\' → \'Đang thực hiện\'', '2025-11-17 05:52:35'),
(227, 179, 4, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-09-22\' | 🔄 Đổi trạng thái: \'Chưa bắt đầu\' → \'Đang thực hiện\'', '2025-11-17 05:52:40'),
(228, 242, 4, '🆕 Tạo mới công việc: \'Bổ sung click vào các phòng ban sẽ hiện các công việc của phòng Ban đang thực hiện \' | Deadline: 2025-11-18 | Độ ưu tiên: Trung bình | Người nhận: Phạm Minh Thắng', '2025-11-17 05:54:43'),
(229, 243, 4, '🆕 Tạo mới công việc: \'Thêm phân loại theo ngày và tuần của list công việc\' | Deadline: 2025-11-18 | Độ ưu tiên: Cao | Người nhận: Phạm Minh Thắng', '2025-11-17 05:56:03'),
(230, 243, 4, '📄 Cập nhật mô tả công việc | 📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-17\' | 📎 Cập nhật link tài liệu', '2025-11-17 05:56:54'),
(231, 244, 4, '🆕 Tạo mới công việc: \'Trao đổi với Phòng Văn Hóa về Netzero Tours\' | Deadline: 2025-11-20 | Độ ưu tiên: Trung bình | Người nhận: Đặng Lê Trung', '2025-11-17 06:04:04'),
(232, 245, 11, '🆕 Tạo mới công việc: \'gửi báo giá dự toán\' | Deadline: 2025-11-17 | Độ ưu tiên: Thấp | Người nhận: Nguyễn Tấn Dũng', '2025-11-17 06:19:43'),
(233, 246, 11, '🆕 Tạo mới công việc: \'Ký hợp đồng triển khai\' | Deadline: 2025-12-31 | Độ ưu tiên: Thấp | Người nhận: Vũ Tam Hanh', '2025-11-17 06:21:40'),
(234, 245, 11, '📄 Cập nhật mô tả công việc | 📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-10-10\' | 🔄 Đổi trạng thái: \'Chưa bắt đầu\' → \'Đã hoàn thành\' | 📎 Cập nhật link tài liệu', '2025-11-17 06:21:50'),
(235, 246, 11, '➕ Thêm tiến độ mới: \'Hẹn với TKV để xác nhận kế hoạch triển khai\' | Trạng thái: Đang thực hiện | Ngày bắt đầu: 2025-11-17 | Deadline: 2025-11-30', '2025-11-17 06:22:43'),
(236, 246, 11, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-17\' | 🔄 Đổi trạng thái: \'Đang thực hiện\' → \'Chưa bắt đầu\' | 📎 Cập nhật link tài liệu', '2025-11-17 06:22:45'),
(237, 246, 11, '➕ Thêm tiến độ mới: \'Ký hợp đồng\' | Trạng thái: Đang thực hiện | Ngày bắt đầu: 2025-12-01 | Deadline: 2025-12-31', '2025-11-17 06:24:04'),
(238, 246, 11, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-17\' | 🔄 Đổi trạng thái: \'Đang thực hiện\' → \'Chưa bắt đầu\'', '2025-11-17 06:24:07'),
(239, 245, 11, '➕ Thêm tiến độ mới: \'đã xong\' | Trạng thái: Đã hoàn thành | Ngày bắt đầu: 2025-11-17 | Deadline: 2025-11-18', '2025-11-17 06:25:27'),
(240, 245, 11, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-10-10\'', '2025-11-17 06:25:29'),
(241, 247, 11, '🆕 Tạo mới công việc: \'GỬi báo giá\' | Deadline: 2025-11-17 | Độ ưu tiên: Thấp', '2025-11-17 06:29:32'),
(242, 243, 18, '➕ Thêm tiến độ mới: \'Hoàn thành\' | Trạng thái: Chưa bắt đầu | Ngày bắt đầu: 2025-11-17 | Deadline: 2025-11-18 | Mô tả: \"Hoàn thành\"', '2025-11-17 06:30:25'),
(243, 243, 18, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-17\'', '2025-11-17 06:30:34'),
(244, 243, 18, '🔧 [Tiến độ: Hoàn thành] 🔄 Đổi trạng thái tiến độ: \'Chưa bắt đầu\' → \'Đã hoàn thành\'', '2025-11-17 06:30:45'),
(245, 243, 18, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-17\' | 🔄 Đổi trạng thái: \'Đã hoàn thành\' → \'Chưa bắt đầu\'', '2025-11-17 06:30:46'),
(246, 247, 11, '➕ Thêm tiến độ mới: \'báo giá cho Mobifone\' | Trạng thái: Đã hoàn thành | Ngày bắt đầu: 2025-11-17 | Deadline: 2025-11-17', '2025-11-17 06:31:01'),
(247, 247, 11, '📄 Cập nhật mô tả công việc | 📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-01\' | 🔄 Đổi trạng thái: \'Đã hoàn thành\' → \'Chưa bắt đầu\' | 👥 Đổi người nhận: \'(chưa có)\' → \'null\' | 📎 Cập nhật link tài liệu', '2025-11-17 06:31:06'),
(248, 227, 18, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-20\' | 📎 Cập nhật link tài liệu', '2025-11-17 06:33:04'),
(249, 248, 4, '🆕 Tạo mới công việc: \'Đưa mini app lên hệ thống Zalo Demo\' | Deadline: 2025-11-22 | Độ ưu tiên: Trung bình | Người nhận: Vũ Tam Hanh,Phạm Minh Thắng', '2025-11-17 06:33:26'),
(250, 249, 4, '🆕 Tạo mới công việc: \'Chính sách giá với ECHOSS\' | Deadline: 2025-11-22 | Độ ưu tiên: Cao | Người nhận: Đặng Lê Trung', '2025-11-17 06:37:41'),
(251, 250, 4, '🆕 Tạo mới công việc: \'Ký hợp tác với ECHOSS\' | Deadline: 2025-11-22 | Độ ưu tiên: Cao | Người nhận: Nguyễn Đức Dương', '2025-11-17 06:38:28'),
(252, 248, 4, '📄 Cập nhật mô tả công việc | 📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-10\' | ⚡ Đổi độ ưu tiên: \'Trung bình\' → \'Cao\' | 👥 Đổi người nhận: \'Vũ Tam Hanh, Phạm Minh Thắng\' → \'Phạm Minh Thắng,Vũ Tam Hanh\' | 📎 Cập nhật link tài liệu', '2025-11-17 06:38:44'),
(253, 251, 11, '🆕 Tạo mới công việc: \'Đợi xét duyệt ngân sách\' | Deadline: 2025-12-31 | Độ ưu tiên: Thấp | Người nhận: Đặng Lê Trung', '2025-11-17 06:40:16'),
(254, 251, 11, '➕ Thêm tiến độ mới: \'Đã trình hồ sơ xin ngân sách\' | Trạng thái: Đã hoàn thành | Ngày bắt đầu: 2025-11-17 | Deadline: 2025-11-17', '2025-11-17 06:42:05'),
(255, 251, 11, '📄 Cập nhật mô tả công việc | 📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-17\' | 🔄 Đổi trạng thái: \'Đã hoàn thành\' → \'Chưa bắt đầu\' | 📎 Cập nhật link tài liệu', '2025-11-17 06:42:09'),
(256, 251, 11, '➕ Thêm tiến độ mới: \'Ký kết hợp đồng\' | Trạng thái: Chưa bắt đầu | Ngày bắt đầu: 2025-11-17 | Deadline: 2025-12-31', '2025-11-17 06:42:42'),
(257, 251, 11, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-17\'', '2025-11-17 06:42:45'),
(258, 251, 11, '🔧 [Tiến độ: Đã trình hồ sơ xin ngân sách] 🔄 Đổi trạng thái tiến độ: \'Đã hoàn thành\' → \'Đang thực hiện\'', '2025-11-17 06:43:00'),
(259, 251, 11, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-17\'', '2025-11-17 06:43:03'),
(260, 251, 11, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-17\' | 🔄 Đổi trạng thái: \'Đã hoàn thành\' → \'Đang thực hiện\'', '2025-11-17 06:43:17'),
(261, 252, 11, '🆕 Tạo mới công việc: \'Họp online xác định nhu cầu thực tế\' | Deadline: 2025-11-30 | Độ ưu tiên: Trung bình | Người nhận: Đặng Lê Trung,Vũ Tam Hanh', '2025-11-17 06:45:22'),
(262, 253, 11, '🆕 Tạo mới công việc: \'Gặp mặt lần đầu nắm yêu cầu\' | Deadline: 2025-11-17 | Độ ưu tiên: Thấp | Người nhận: Võ Trung Âu,Vũ Tam Hanh,Nguyễn Tấn Dũng', '2025-11-17 06:49:48'),
(263, 253, 11, '➕ Thêm tiến độ mới: \'Gặp trao đổi\' | Trạng thái: Đã hoàn thành | Ngày bắt đầu: 2025-11-03 | Deadline: 2025-11-03', '2025-11-17 06:50:27'),
(264, 253, 11, '📄 Cập nhật mô tả công việc | 📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-03\' | 🔄 Đổi trạng thái: \'Đã hoàn thành\' → \'Chưa bắt đầu\' | 👥 Đổi người nhận: \'Võ Trung Âu, Vũ Tam Hanh, Nguyễn Tấn Dũng\' → \'Nguyễn Tấn Dũng,Võ Trung Âu,Vũ Tam Hanh\' | 📎 Cập nhật link tài liệu', '2025-11-17 06:51:02'),
(265, 253, 11, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-03\' | 👥 Đổi người nhận: \'Nguyễn Tấn Dũng, Võ Trung Âu, Vũ Tam Hanh\' → \'Nguyễn Tấn Dũng,Võ Trung Âu,Vũ Tam Hanh\'', '2025-11-17 06:52:41'),
(266, 254, 11, '🆕 Tạo mới công việc: \'Khảo sát hạ tầng cơ bản\' | Deadline: 2025-11-14 | Độ ưu tiên: Thấp | Người nhận: Vũ Tam Hanh,Nguyễn Tấn Dũng', '2025-11-17 06:53:45'),
(267, 255, 11, '🆕 Tạo mới công việc: \'Khảo sát IT\' | Deadline: 2025-11-30 | Độ ưu tiên: Thấp | Người nhận: Vũ Tam Hanh,Nguyễn Tấn Dũng', '2025-11-17 06:54:36'),
(268, 254, 11, '➕ Thêm tiến độ mới: \'đã khảo sát xong, cần báo cáo\' | Trạng thái: Đã hoàn thành | Ngày bắt đầu: 2025-11-14 | Deadline: 2025-11-14', '2025-11-17 06:55:21'),
(269, 254, 11, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-14\' | 👥 Đổi người nhận: \'Vũ Tam Hanh, Nguyễn Tấn Dũng\' → \'Nguyễn Tấn Dũng,Vũ Tam Hanh\' | 📎 Cập nhật link tài liệu', '2025-11-17 06:55:24'),
(270, 254, 11, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-14\' | 🔄 Đổi trạng thái: \'Trễ hạn\' → \'Đã hoàn thành\' | 👥 Đổi người nhận: \'Nguyễn Tấn Dũng, Vũ Tam Hanh\' → \'Nguyễn Tấn Dũng,Vũ Tam Hanh\'', '2025-11-17 06:55:38'),
(271, 256, 11, '🆕 Tạo mới công việc: \'Hẹn cuối tháng 11 khảo sát\' | Deadline: 2025-11-30 | Độ ưu tiên: Thấp | Người nhận: Vũ Tam Hanh,Nguyễn Tấn Dũng', '2025-11-17 06:56:28'),
(272, 256, 11, '➕ Thêm tiến độ mới: \'Dũng nắm công việc và hỗ trợ a Long khảo sát\' | Trạng thái: Đang thực hiện | Ngày bắt đầu: 2025-11-17 | Deadline: 2025-11-30', '2025-11-17 07:00:04'),
(273, 256, 11, '📄 Cập nhật mô tả công việc | 📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-17\' | 🔄 Đổi trạng thái: \'Đang thực hiện\' → \'Chưa bắt đầu\' | 👥 Đổi người nhận: \'Vũ Tam Hanh, Nguyễn Tấn Dũng\' → \'Nguyễn Tấn Dũng,Vũ Tam Hanh\' | 📎 Cập nhật link tài liệu', '2025-11-17 07:00:07'),
(274, 193, 7, '🔧 [Tiến độ: Hoàn thành] 🔄 Đổi trạng thái tiến độ: \'Chưa bắt đầu\' → \'Đang thực hiện\'', '2025-11-17 07:08:59'),
(275, 214, 7, '🔧 [Tiến độ: bước 1] 🔄 Đổi trạng thái tiến độ: \'Chưa bắt đầu\' → \'Đang thực hiện\'', '2025-11-17 07:10:08'),
(276, 257, 11, '🆕 Tạo mới công việc: \'Dùng thử\' | Deadline: 2025-11-17 | Độ ưu tiên: Thấp | Người nhận: Phan Tuấn Linh', '2025-11-17 07:10:31'),
(277, 257, 11, '➕ Thêm tiến độ mới: \'Đã dùng thử phản hồi ok\' | Trạng thái: Đã hoàn thành | Ngày bắt đầu: 2025-11-17 | Deadline: 2025-11-17', '2025-11-17 07:11:36'),
(278, 257, 11, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-01\' | 🔄 Đổi trạng thái: \'Đã hoàn thành\' → \'Chưa bắt đầu\' | 📎 Cập nhật link tài liệu', '2025-11-17 07:11:39'),
(279, 258, 11, '🆕 Tạo mới công việc: \'Lên chính sách báo giá\' | Deadline: 2025-11-21 | Độ ưu tiên: Thấp | Người nhận: Võ Trung Âu', '2025-11-17 07:12:43'),
(289, 226, 18, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-17\' | 📅 Đổi deadline: \'2033-11-18\' → \'2025-11-17\'', '2025-11-17 07:46:36'),
(290, 227, 18, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-17\' | 📅 Đổi deadline: \'2034-11-18\' → \'2025-11-17\'', '2025-11-17 07:46:45'),
(291, 228, 18, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-17\' | 📅 Đổi deadline: \'2035-11-18\' → \'2025-11-17\'', '2025-11-17 07:46:52'),
(292, 243, 18, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-17\' | 📅 Đổi deadline: \'2025-11-18\' → \'2025-11-17\'', '2025-11-17 07:46:53'),
(293, 229, 18, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-17\' | 📅 Đổi deadline: \'2036-11-18\' → \'2025-11-17\'', '2025-11-17 07:46:59'),
(294, 231, 18, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-17\' | 📅 Đổi deadline: \'2038-11-18\' → \'2025-11-17\'', '2025-11-17 07:47:00'),
(295, 230, 18, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-17\' | 📅 Đổi deadline: \'2037-11-18\' → \'2025-11-17\'', '2025-11-17 07:47:08'),
(296, 260, 11, '🆕 Tạo mới công việc: \'Hỗ trợ kỹ thuật\' | Deadline: 2025-11-30 | Độ ưu tiên: Thấp | Người nhận: Vũ Tam Hanh,Nguyễn Ngọc Tuyền', '2025-11-17 08:36:11'),
(297, 261, 11, '🆕 Tạo mới công việc: \'Trao đổi chính sách IRTECH\' | Deadline: 2025-11-30 | Độ ưu tiên: Thấp | Người nhận: Đặng Lê Trung', '2025-11-17 08:36:47'),
(298, 260, 18, 'Bật nhắc việc', '2025-11-17 08:37:47'),
(299, 260, 18, 'Bật nhắc việc', '2025-11-17 08:37:47'),
(300, 262, 11, '🆕 Tạo mới công việc: \'Làm việc với CyStack để nắm khi nào khảo sát\' | Deadline: 2025-11-30 | Độ ưu tiên: Thấp | Người nhận: Vũ Tam Hanh,Nguyễn Ngọc Tuyền', '2025-11-17 08:38:39'),
(302, 247, 18, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-01\' | 👥 Đổi người nhận: \'(chưa có)\' → \'Đặng Lê Trung\'', '2025-11-17 08:39:57'),
(303, 260, 18, 'Tắt nhắc việc', '2025-11-17 08:41:09'),
(304, 263, 11, '🆕 Tạo mới công việc: \'Chốt được lịch sang thăm văn phòng\' | Deadline: 2025-11-30 | Độ ưu tiên: Thấp | Người nhận: Vũ Tam Hanh', '2025-11-17 08:41:20'),
(305, 260, 18, '➕ Thêm tiến độ mới: \'Hỗ trợ kỹ thuật\' | Trạng thái: Chưa bắt đầu | Ngày bắt đầu: 2025-11-17 | Deadline: 2025-11-24', '2025-11-17 08:41:56'),
(306, 240, 24, '🔧 [Tiến độ: Hoàn thành] 🔄 Đổi trạng thái tiến độ: \'Đang thực hiện\' → \'Đã hoàn thành\'', '2025-11-17 09:16:08'),
(307, 240, 24, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-12-04\' | 🔄 Đổi trạng thái: \'Đã hoàn thành\' → \'Đang thực hiện\'', '2025-11-17 09:16:09'),
(308, 240, 24, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-12-04\' | 🔄 Đổi trạng thái: \'Đã hoàn thành\' → \'Đang thực hiện\'', '2025-11-17 09:16:22'),
(309, 240, 24, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-12-04\' | 👥 Đổi người nhận: \'(chưa có)\' → \'Nguyễn Ngọc Tuyền\'', '2025-11-17 09:16:23'),
(310, 239, 24, '🔧 [Tiến độ: Hoàn thành] 🔄 Đổi trạng thái tiến độ: \'Đang thực hiện\' → \'Đã hoàn thành\'', '2025-11-18 02:56:31'),
(311, 201, 6, '⭐ Thêm đánh giá: \"Đã làm xong công việc, tuy nhiên cần hoàn thiện ch...\"', '2025-11-18 05:56:50'),
(312, 201, 6, 'Xét duyệt: Đã duyệt - Lý do: ok', '2025-11-18 05:57:02'),
(313, 242, 18, '➕ Thêm tiến độ mới: \'Hoàn thành\' | Trạng thái: Chưa bắt đầu | Ngày bắt đầu: 2025-11-18 | Deadline: 2025-11-18 | Mô tả: \"Hoàn thành\"', '2025-11-18 07:53:26'),
(314, 242, 18, '📄 Cập nhật mô tả công việc | 📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-17\' | 📎 Cập nhật link tài liệu', '2025-11-18 07:53:30'),
(315, 242, 25, '🔧 [Tiến độ: Hoàn thành] 🔄 Đổi trạng thái tiến độ: \'Chưa bắt đầu\' → \'Đã hoàn thành\'', '2025-11-18 07:53:48'),
(316, 242, 25, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-17\' | 🔄 Đổi trạng thái: \'Đã hoàn thành\' → \'Chưa bắt đầu\'', '2025-11-18 07:53:49'),
(317, 255, 4, '📄 Cập nhật mô tả công việc | 📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-17\' | ⚡ Đổi độ ưu tiên: \'Thấp\' → \'Cao\' | 👥 Đổi người nhận: \'Vũ Tam Hanh, Nguyễn Tấn Dũng\' → \'Nguyễn Tấn Dũng,Vũ Tam Hanh\' | 📎 Cập nhật link tài liệu', '2025-11-18 13:28:43'),
(318, 255, 4, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-17\' | 🔄 Đổi trạng thái: \'Chưa bắt đầu\' → \'Đang thực hiện\' | 👥 Đổi người nhận: \'Nguyễn Tấn Dũng, Vũ Tam Hanh\' → \'Nguyễn Tấn Dũng,Vũ Tam Hanh\'', '2025-11-18 13:28:55'),
(321, 180, 4, 'Bật nhắc việc', '2025-11-18 14:08:49'),
(322, 258, 4, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-17\' | 🔄 Đổi trạng thái: \'Chưa bắt đầu\' → \'Đã hoàn thành\' | 📎 Cập nhật link tài liệu', '2025-11-19 13:59:04'),
(323, 182, 4, 'Xét duyệt: Từ chối - Lý do: Chưa thấy file báo cáo công việc với Luxtech chỗ Mai Phương', '2025-11-19 14:08:42'),
(326, 217, 4, 'Bật nhắc việc', '2025-11-20 04:11:32'),
(327, 266, 18, '🆕 Tạo mới công việc: \'Trao đổi với a Đạt Vinachem tư vấn ESG và các module nhà máy \' | Deadline: null | Độ ưu tiên: Thấp | Người nhận: Nguyễn Tấn Dũng', '2025-11-20 04:14:04'),
(328, 241, 4, 'Bật nhắc việc', '2025-11-20 04:14:50'),
(329, 214, 4, 'Bật nhắc việc', '2025-11-20 04:15:03'),
(331, 267, 11, '🆕 Tạo mới công việc: \'Ký NDA giữa CyStack và Medlac\' | Deadline: 2025-11-17 | Độ ưu tiên: Thấp | Người nhận: Đặng Lê Trung', '2025-11-20 04:23:45'),
(332, 267, 11, '📄 Cập nhật mô tả công việc | 📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-17\' | 🔄 Đổi trạng thái: \'Trễ hạn\' → \'Đã hoàn thành\' | 📎 Cập nhật link tài liệu', '2025-11-20 04:24:27'),
(333, 268, 11, '🆕 Tạo mới công việc: \'Khảo Sát Công ty Dược\' | Deadline: 2025-11-30 | Độ ưu tiên: Thấp | Người nhận: Nguyễn Ngọc Tuyền', '2025-11-20 04:32:43'),
(334, 266, 18, '➕ Thêm tiến độ mới: \'Liên hệ anh Đạt\' | Trạng thái: Chưa bắt đầu | Ngày bắt đầu: 2025-11-20 | Deadline: 2025-11-29', '2025-11-20 04:33:13'),
(335, 269, 11, '🆕 Tạo mới công việc: \'Khảo Sát Công ty Dược\' | Deadline: 2025-11-30 | Độ ưu tiên: Thấp | Người nhận: Vũ Tam Hanh,Nguyễn Ngọc Tuyền', '2025-11-20 04:34:26'),
(336, 270, 11, '🆕 Tạo mới công việc: \'Khảo Sát Công ty Dược\' | Deadline: 2025-11-30 | Độ ưu tiên: Thấp | Người nhận: Nguyễn Ngọc Tuyền', '2025-11-20 04:35:26'),
(337, 270, 11, '➕ Thêm tiến độ mới: \'Đợi lịch khảo sát từ CyStack\' | Trạng thái: Đang thực hiện | Ngày bắt đầu: 2025-11-20 | Deadline: 2025-11-30', '2025-11-20 04:36:05'),
(338, 270, 11, '➕ Thêm tiến độ mới: \'Khảo sát, báo cáo kết quả\' | Trạng thái: Chưa bắt đầu | Ngày bắt đầu: 2025-11-30 | Deadline: 2025-12-31', '2025-11-20 04:36:43'),
(339, 270, 11, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-20\' | 🔄 Đổi trạng thái: \'Đang thực hiện\' → \'Chưa bắt đầu\' | 📎 Cập nhật link tài liệu', '2025-11-20 04:36:51'),
(340, 270, 11, '🔧 [Tiến độ: Khảo sát, báo cáo kết quả] 🔄 Đổi trạng thái tiến độ: \'Chưa bắt đầu\' → \'Đang thực hiện\'', '2025-11-20 04:37:11'),
(341, 270, 11, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-20\' | 🔄 Đổi trạng thái: \'Đang thực hiện\' → \'Chưa bắt đầu\'', '2025-11-20 04:37:13'),
(342, 270, 11, '🔧 [Tiến độ: Khảo sát, báo cáo kết quả] 🔄 Đổi trạng thái tiến độ: \'Đang thực hiện\' → \'Chưa bắt đầu\'', '2025-11-20 04:37:29'),
(343, 270, 11, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-20\'', '2025-11-20 04:37:30'),
(344, 271, 11, '🆕 Tạo mới công việc: \'Đã xin lịch khảo sát, a ĐỈnh sẽ liên hệ trước 1 tuần\' | Deadline: 2025-12-15 | Độ ưu tiên: Thấp | Người nhận: Nguyễn Tấn Dũng', '2025-11-20 04:46:51'),
(345, 272, 11, '🆕 Tạo mới công việc: \'Đã gửi báo giá cho a Cường 3C\' | Deadline: 2025-12-20 | Độ ưu tiên: Thấp | Người nhận: Trần Đình Nam', '2025-11-20 04:51:13'),
(346, 272, 11, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-20\' | 🔄 Đổi trạng thái: \'Chưa bắt đầu\' → \'Đang thực hiện\' | 📎 Cập nhật link tài liệu', '2025-11-20 04:57:22'),
(354, 275, 4, '🆕 Tạo mới công việc: \'Chỉnh sửa 2\' | Deadline: 2025-11-22 | Độ ưu tiên: Trung bình', '2025-11-20 06:36:00'),
(357, 252, 4, '📄 Cập nhật mô tả công việc | 📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-01\' | 👥 Đổi người nhận: \'Đặng Lê Trung, Vũ Tam Hanh\' → \'Đặng Lê Trung,Vũ Tam Hanh,Nguyễn Công Bảo\' | 📎 Cập nhật link tài liệu', '2025-11-20 06:41:53'),
(358, 252, 4, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-01\' | 🔄 Đổi trạng thái: \'Chưa bắt đầu\' → \'Đang thực hiện\' | 👥 Đổi người nhận: \'Đặng Lê Trung, Vũ Tam Hanh, Nguyễn Công Bảo\' → \'Đặng Lê Trung,Nguyễn Công Bảo,Vũ Tam Hanh\'', '2025-11-20 06:43:02'),
(359, 248, 4, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-10\' | 🔄 Đổi trạng thái: \'Chưa bắt đầu\' → \'Đang thực hiện\' | 👥 Đổi người nhận: \'Phạm Minh Thắng, Vũ Tam Hanh\' → \'Phạm Minh Thắng,Vũ Tam Hanh\'', '2025-11-20 06:43:37'),
(360, 249, 4, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-17\' | 🔄 Đổi trạng thái: \'Chưa bắt đầu\' → \'Đang thực hiện\' | 📎 Cập nhật link tài liệu', '2025-11-20 06:43:47'),
(361, 249, 4, 'Bật nhắc việc', '2025-11-20 06:43:49'),
(362, 249, 4, 'Bật nhắc việc', '2025-11-20 06:43:53'),
(363, 248, 4, 'Bật nhắc việc', '2025-11-20 06:43:58'),
(364, 250, 4, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-17\' | 🔄 Đổi trạng thái: \'Chưa bắt đầu\' → \'Đang thực hiện\' | 📎 Cập nhật link tài liệu', '2025-11-20 06:44:11'),
(365, 250, 4, 'Bật nhắc việc', '2025-11-20 06:44:14'),
(369, 275, 18, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-20\' | 👥 Đổi người nhận: \'(chưa có)\' → \'Phạm Minh Thắng\' | 📎 Cập nhật link tài liệu', '2025-11-20 17:54:34'),
(372, 241, 24, 'Tắt nhắc việc', '2025-11-21 01:23:30'),
(373, 276, 24, '🆕 Tạo mới công việc: \'Họp trao đổi lại về Vyin AI\' | Deadline: 2025-11-25 | Độ ưu tiên: Trung bình | Người nhận: Nguyễn Ngọc Tuyền,Phạm Minh Thắng', '2025-11-21 01:27:04'),
(374, 277, 24, '🆕 Tạo mới công việc: \'Frontend Learning KT\' | Deadline: 2025-11-28 | Độ ưu tiên: Cao | Người nhận: Tạ Quang Anh', '2025-11-21 01:29:10'),
(375, 278, 24, '🆕 Tạo mới công việc: \'Backend Learning KT\' | Deadline: 2025-11-28 | Độ ưu tiên: Cao | Người nhận: Tạ Quang Anh', '2025-11-21 01:30:12'),
(376, 266, 4, '📄 Cập nhật mô tả công việc | 📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-21\' | 📅 Đổi deadline: \'(chưa có)\' → \'2025-11-30\' | 👤 Đổi người giao: \'Đào Huy Hoàng\' → \'4\' | 📎 Cập nhật link tài liệu', '2025-11-21 06:46:19'),
(377, 279, 11, '🆕 Tạo mới công việc: \'Làm việc với a Tim về Netzero\' | Deadline: 2025-11-30 | Độ ưu tiên: Trung bình | Người nhận: Vũ Thị Hải Yến,Nguyễn Tấn Dũng', '2025-11-21 06:47:50'),
(378, 280, 11, '🆕 Tạo mới công việc: \'Dự án Netzero\' | Deadline: 2025-11-30 | Độ ưu tiên: Trung bình | Người nhận: Vũ Thị Hải Yến,Nguyễn Tấn Dũng', '2025-11-21 06:49:59'),
(379, 281, 11, '🆕 Tạo mới công việc: \'Làm việc với a Tim về Netzero\' | Deadline: 2025-11-30 | Độ ưu tiên: Trung bình | Người nhận: Vũ Thị Hải Yến,Nguyễn Tấn Dũng', '2025-11-21 06:51:17'),
(380, 281, 11, '📄 Cập nhật mô tả công việc | 📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-21\' | 🔄 Đổi trạng thái: \'Chưa bắt đầu\' → \'Đang thực hiện\' | 👥 Đổi người nhận: \'Vũ Thị Hải Yến, Nguyễn Tấn Dũng\' → \'Nguyễn Tấn Dũng,Vũ Thị Hải Yến\' | 📎 Cập nhật link tài liệu', '2025-11-21 06:51:25'),
(381, 279, 11, '➕ Thêm tiến độ mới: \'xác định hướng triển khai với a Tim\' | Trạng thái: Đang thực hiện | Ngày bắt đầu: 2025-11-21 | Deadline: 2025-11-21', '2025-11-21 06:53:04'),
(382, 271, 11, '📄 Cập nhật mô tả công việc | 📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-20\' | 🔄 Đổi trạng thái: \'Chưa bắt đầu\' → \'Đang thực hiện\' | 📎 Cập nhật link tài liệu', '2025-11-21 06:53:41'),
(383, 282, 11, '🆕 Tạo mới công việc: \'Giới thiệu smartdashboard\' | Deadline: 2025-11-14 | Độ ưu tiên: Thấp | Người nhận: Đặng Lê Trung', '2025-11-21 06:54:51'),
(384, 282, 11, '➕ Thêm tiến độ mới: \'giới thiệu sản phẩm cho Vpbak\' | Trạng thái: Đã hoàn thành | Ngày bắt đầu: 2025-11-14 | Deadline: 2025-11-14', '2025-11-21 06:55:20'),
(385, 282, 11, '➕ Thêm tiến độ mới: \'Giới thiệu sản phẩm cho chủ tịch Vpbank\' | Trạng thái: Đang thực hiện | Ngày bắt đầu: 2025-11-14 | Deadline: 2025-11-30 | Mô tả: \"đang xin lịch hẹn\"', '2025-11-21 06:55:54'),
(386, 282, 11, '📄 Cập nhật mô tả công việc | 📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-14\' | 🔄 Đổi trạng thái: \'Trễ hạn\' → \'Chưa bắt đầu\' | 📎 Cập nhật link tài liệu', '2025-11-21 06:55:57'),
(387, 282, 11, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-14\' | 🔄 Đổi trạng thái: \'Trễ hạn\' → \'Đã hoàn thành\'', '2025-11-21 06:56:16'),
(388, 282, 11, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-14\' | 📅 Đổi deadline: \'2025-11-14\' → \'2025-11-30\'', '2025-11-21 06:56:26'),
(389, 282, 11, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-14\' | 🔄 Đổi trạng thái: \'Đã hoàn thành\' → \'Đang thực hiện\'', '2025-11-21 06:56:36'),
(390, 283, 11, '🆕 Tạo mới công việc: \'đã gửi đề xuất phương án cho Đà Nẵng\' | Deadline: 2025-11-03 | Độ ưu tiên: Thấp | Người nhận: Đặng Lê Trung', '2025-11-21 06:57:37'),
(391, 283, 11, '➕ Thêm tiến độ mới: \'gửi phương án đề xuất\' | Trạng thái: Đã hoàn thành | Ngày bắt đầu: 2025-11-03 | Deadline: 2025-11-03', '2025-11-21 06:58:21'),
(392, 283, 11, '➕ Thêm tiến độ mới: \'đợi phản hồi\' | Trạng thái: Đang thực hiện | Ngày bắt đầu: 2025-11-03 | Deadline: 2025-11-30', '2025-11-21 06:58:50'),
(393, 283, 11, '📄 Cập nhật mô tả công việc | 📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-03\' | 🔄 Đổi trạng thái: \'Trễ hạn\' → \'Chưa bắt đầu\' | 📎 Cập nhật link tài liệu', '2025-11-21 06:58:53'),
(394, 283, 11, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-03\' | 📅 Đổi deadline: \'2025-11-03\' → \'2025-11-30\' | 🔄 Đổi trạng thái: \'Trễ hạn\' → \'Đang thực hiện\'', '2025-11-21 06:59:07'),
(395, 214, 7, 'Tắt nhắc việc', '2025-11-21 09:48:22'),
(396, 193, 7, '🔧 [Tiến độ: Hoàn thành] 🔄 Đổi trạng thái tiến độ: \'Đang thực hiện\' → \'Đã hoàn thành\'', '2025-11-21 09:48:34'),
(397, 193, 7, '🔧 [Tiến độ: Hoàn thành] 🔄 Đổi trạng thái tiến độ: \'Đã hoàn thành\' → \'Đang thực hiện\'', '2025-11-21 09:48:58'),
(398, 193, 7, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-09-26\'', '2025-11-21 09:49:00'),
(399, 214, 7, '🔧 [Tiến độ: bước 1] 🔄 Đổi trạng thái tiến độ: \'Đang thực hiện\' → \'Đã hoàn thành\'', '2025-11-21 09:49:18'),
(400, 214, 7, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-14\' | 👥 Đổi người nhận: \'Nguyễn Đức Dương, Nguyễn Thị Diễm Quỳnh\' → \'Nguyễn Đức Dương,Nguyễn Thị Diễm Quỳnh\'', '2025-11-21 09:49:19'),
(401, 214, 7, 'Gia hạn công việc đến 2025-11-21', '2025-11-21 09:50:22'),
(402, 214, 7, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-14\' | 👥 Đổi người nhận: \'Nguyễn Đức Dương, Nguyễn Thị Diễm Quỳnh\' → \'Nguyễn Đức Dương,Nguyễn Thị Diễm Quỳnh\'', '2025-11-21 09:50:28'),
(403, 214, 18, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-14\' | 🔄 Đổi trạng thái: \'Đang thực hiện\' → \'Đã hoàn thành\' | 👥 Đổi người nhận: \'Nguyễn Đức Dương, Nguyễn Thị Diễm Quỳnh\' → \'Nguyễn Đức Dương,Nguyễn Thị Diễm Quỳnh\'', '2025-11-21 09:51:55'),
(404, 276, 25, '➕ Thêm tiến độ mới: \'Bước 2: Thực hiện\' | Trạng thái: Chưa bắt đầu | Ngày bắt đầu: 2025-11-22 | Deadline: 2025-11-24 | Mô tả: \"đang làm\"', '2025-11-22 13:04:27'),
(405, 276, 25, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-24\' | 👥 Đổi người nhận: \'Nguyễn Ngọc Tuyền, Phạm Minh Thắng\' → \'Nguyễn Ngọc Tuyền,Phạm Minh Thắng\' | 📎 Cập nhật link tài liệu', '2025-11-22 13:04:42'),
(406, 276, 25, '🔧 [Tiến độ: Bước 2: Thực hiện] 🔄 Đổi trạng thái tiến độ: \'Chưa bắt đầu\' → \'Đang thực hiện\'', '2025-11-22 13:04:58'),
(407, 276, 25, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-24\' | 🔄 Đổi trạng thái: \'Đang thực hiện\' → \'Chưa bắt đầu\' | 👥 Đổi người nhận: \'Nguyễn Ngọc Tuyền, Phạm Minh Thắng\' → \'Nguyễn Ngọc Tuyền,Phạm Minh Thắng\'', '2025-11-22 13:05:00'),
(409, 275, 25, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-20\' | 📅 Đổi deadline: \'2025-11-22\' → \'2025-11-26\'', '2025-11-22 13:05:53');
INSERT INTO `cong_viec_lich_su` (`id`, `cong_viec_id`, `nguoi_thay_doi_id`, `mo_ta_thay_doi`, `thoi_gian`) VALUES
(410, 275, 25, '➕ Thêm tiến độ mới: \'Hoàn thành\' | Trạng thái: Chưa bắt đầu | Ngày bắt đầu: 2025-11-21 | Deadline: 2025-11-26 | Mô tả: \"Hoàn thành\"', '2025-11-22 13:06:12'),
(411, 275, 25, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-20\'', '2025-11-22 13:06:14'),
(412, 275, 25, '🔧 [Tiến độ: Hoàn thành] 🔄 Đổi trạng thái tiến độ: \'Chưa bắt đầu\' → \'Đang thực hiện\'', '2025-11-22 13:06:20'),
(413, 275, 25, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-20\'', '2025-11-22 13:06:20'),
(414, 248, 25, 'Tắt nhắc việc', '2025-11-22 13:06:39'),
(415, 248, 25, '➕ Thêm tiến độ mới: \'Hoàn thành\' | Trạng thái: Chưa bắt đầu | Ngày bắt đầu: 2025-11-22 | Deadline: 2025-11-30 | Mô tả: \"Hoàn thành\"', '2025-11-22 13:07:46'),
(416, 248, 25, '📄 Cập nhật mô tả công việc | 📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-10\' | 📅 Đổi deadline: \'2025-11-22\' → \'2025-11-30\' | 👥 Đổi người nhận: \'Phạm Minh Thắng, Vũ Tam Hanh\' → \'Phạm Minh Thắng,Vũ Tam Hanh\'', '2025-11-22 13:07:52'),
(417, 249, 11, 'Tắt nhắc việc', '2025-11-24 01:01:56'),
(418, 180, 11, 'Tắt nhắc việc', '2025-11-24 01:02:41'),
(419, 217, 11, 'Tắt nhắc việc', '2025-11-24 01:03:14'),
(420, 215, 11, '📄 Cập nhật mô tả công việc | 📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-17\' | 🔄 Đổi trạng thái: \'Trễ hạn\' → \'Đã hoàn thành\'', '2025-11-24 01:03:52'),
(421, 217, 11, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-17\' | 🔄 Đổi trạng thái: \'Trễ hạn\' → \'Đã hoàn thành\'', '2025-11-24 01:04:09'),
(422, 244, 11, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-17\' | 🔄 Đổi trạng thái: \'Trễ hạn\' → \'Đang thực hiện\' | 📎 Cập nhật link tài liệu', '2025-11-24 01:04:32'),
(423, 249, 11, '➕ Thêm tiến độ mới: \'Xin chính sách\' | Trạng thái: Đang thực hiện | Ngày bắt đầu: 2025-11-20 | Deadline: 2025-11-30 | Mô tả: \"đốc thốc lien tục mà họ hẹn lần tới\"', '2025-11-24 01:05:43'),
(424, 249, 11, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-17\'', '2025-11-24 01:05:47'),
(425, 255, 3, '➕ Thêm tiến độ mới: \'Trao đổi sơ bộ về bộ dữ liệu của hạ tầng IT\' | Trạng thái: Đã hoàn thành | Ngày bắt đầu: 2025-11-20 | Deadline: 2025-11-20', '2025-11-24 01:17:14'),
(426, 255, 3, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-17\' | 🔄 Đổi trạng thái: \'Đã hoàn thành\' → \'Chưa bắt đầu\' | 👥 Đổi người nhận: \'Nguyễn Tấn Dũng, Vũ Tam Hanh\' → \'Nguyễn Tấn Dũng,Vũ Tam Hanh\'', '2025-11-24 01:17:19'),
(427, 255, 3, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-17\' | 👥 Đổi người nhận: \'Nguyễn Tấn Dũng, Vũ Tam Hanh\' → \'Nguyễn Tấn Dũng,Vũ Tam Hanh\'', '2025-11-24 01:17:28'),
(428, 244, 11, '➕ Thêm tiến độ mới: \'Đang làm việc với a Tim xin chính sách Netzero\' | Trạng thái: Đang thực hiện | Ngày bắt đầu: 2025-11-20 | Deadline: 2025-11-30', '2025-11-24 01:36:37'),
(429, 244, 11, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-17\'', '2025-11-24 01:36:41'),
(430, 180, 11, '➕ Thêm tiến độ mới: \'Xin lịch họp với 3C\' | Trạng thái: Chưa bắt đầu | Ngày bắt đầu: 2025-11-24 | Deadline: 2025-11-30', '2025-11-24 01:44:26'),
(431, 180, 11, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-09-22\' | 🔄 Đổi trạng thái: \'Chưa bắt đầu\' → \'Đang thực hiện\'', '2025-11-24 01:44:28'),
(432, 255, 3, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-17\' | 👥 Đổi người nhận: \'Nguyễn Tấn Dũng, Vũ Tam Hanh\' → \'Nguyễn Tấn Dũng,Vũ Tam Hanh\'', '2025-11-24 01:45:00'),
(433, 255, 3, '📁 Tải lên file: Biên bản cuộc họp ICS-Agribank_ 20-11.pdf', '2025-11-24 01:45:00'),
(434, 252, 11, '➕ Thêm tiến độ mới: \'Cathay đang xin lịch họp với sếp\' | Trạng thái: Đang thực hiện | Ngày bắt đầu: 2025-11-24 | Deadline: 2025-11-30', '2025-11-24 01:46:19'),
(435, 252, 11, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-24\' | 👥 Đổi người nhận: \'Đặng Lê Trung, Nguyễn Công Bảo, Vũ Tam Hanh\' → \'Đặng Lê Trung\'', '2025-11-24 01:46:22'),
(436, 180, 11, '🔧 [Tiến độ: Hoàn thành] 🔄 Đổi trạng thái tiến độ: \'Chưa bắt đầu\' → \'Đã hoàn thành\'', '2025-11-24 01:46:58'),
(437, 180, 11, '🔧 [Tiến độ: Xin lịch họp với 3C] 🔄 Đổi trạng thái tiến độ: \'Chưa bắt đầu\' → \'Đang thực hiện\'', '2025-11-24 01:47:06'),
(438, 180, 11, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-09-22\' | 🔄 Đổi trạng thái: \'Đang thực hiện\' → \'Chưa bắt đầu\'', '2025-11-24 01:47:07'),
(439, 180, 11, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-09-22\' | 🔄 Đổi trạng thái: \'Đang thực hiện\' → \'Chưa bắt đầu\'', '2025-11-24 01:47:19'),
(440, 284, 24, '🆕 Tạo mới công việc: \'Hỗ trợ hoàn thiện backend cho quang anh\' | Deadline: 2025-11-28 | Độ ưu tiên: Trung bình | Người nhận: Nguyễn Ngọc Tuyền', '2025-11-24 01:47:36'),
(441, 285, 8, '🆕 Tạo mới công việc: \'Làm website Oracle Cloud VN\' | Deadline: 2025-11-30 | Độ ưu tiên: Cao | Người nhận: Trần Đình Nam', '2025-11-24 01:49:25'),
(442, 285, 8, '➕ Thêm tiến độ mới: \'Hoàn thành\' | Trạng thái: Đã hoàn thành | Ngày bắt đầu: 2025-11-24 | Deadline: 2025-11-24', '2025-11-24 01:53:32'),
(443, 178, 11, '➕ Thêm tiến độ mới: \'Gửi chương trình đào tạo sang BIDV. Xin lịch đào tạo\' | Trạng thái: Đang thực hiện | Ngày bắt đầu: 2025-11-24 | Deadline: 2025-11-30', '2025-11-24 01:56:31'),
(444, 178, 11, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-09-22\' | 👥 Đổi người nhận: \'Đặng Lê Trung, Nguyễn Đức Dương\' → \'Đặng Lê Trung,Nguyễn Đức Dương\'', '2025-11-24 01:56:33'),
(445, 261, 11, '➕ Thêm tiến độ mới: \'Xin chính sách IRmind\' | Trạng thái: Chưa bắt đầu | Ngày bắt đầu: 2025-11-24 | Deadline: 2025-11-30', '2025-11-24 02:56:31'),
(446, 261, 11, '📄 Cập nhật mô tả công việc | 📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-17\' | 📎 Cập nhật link tài liệu', '2025-11-24 02:56:33'),
(447, 261, 11, '🔧 [Tiến độ: Xin chính sách IRmind] 🔄 Đổi trạng thái tiến độ: \'Chưa bắt đầu\' → \'Đang thực hiện\'', '2025-11-24 02:57:50'),
(448, 261, 11, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-17\'', '2025-11-24 02:57:53'),
(451, 271, 11, '➕ Thêm tiến độ mới: \'XIn lịch khảo sát nhà máy\' | Trạng thái: Đang thực hiện | Ngày bắt đầu: 2025-11-24 | Deadline: 2025-11-30', '2025-11-24 03:13:58'),
(452, 271, 11, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-20\' | 🔄 Đổi trạng thái: \'Đang thực hiện\' → \'Chưa bắt đầu\'', '2025-11-24 03:14:02'),
(453, 272, 11, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-20\' | 🔄 Đổi trạng thái: \'Chưa bắt đầu\' → \'Đã hoàn thành\'', '2025-11-24 03:14:24'),
(454, 280, 11, '➕ Thêm tiến độ mới: \'Trao đổi với a TIm về các bước thực hiện\' | Trạng thái: Đang thực hiện | Ngày bắt đầu: 2025-11-24 | Deadline: 2025-11-30', '2025-11-24 03:15:15'),
(455, 280, 11, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-21\' | 🔄 Đổi trạng thái: \'Đang thực hiện\' → \'Chưa bắt đầu\' | 👥 Đổi người nhận: \'Vũ Thị Hải Yến, Nguyễn Tấn Dũng\' → \'Nguyễn Tấn Dũng,Vũ Thị Hải Yến\' | 📎 Cập nhật link tài liệu', '2025-11-24 03:15:16'),
(456, 281, 11, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-21\' | 🔄 Đổi trạng thái: \'Chưa bắt đầu\' → \'Đang thực hiện\' | 👥 Đổi người nhận: \'Nguyễn Tấn Dũng, Vũ Thị Hải Yến\' → \'Nguyễn Tấn Dũng,Vũ Thị Hải Yến\'', '2025-11-24 03:15:30'),
(457, 263, 11, '➕ Thêm tiến độ mới: \'Điện a MInh sắp xếp lịch\' | Trạng thái: Chưa bắt đầu | Ngày bắt đầu: 2025-11-24 | Deadline: 2025-11-30', '2025-11-24 03:16:02'),
(458, 260, 18, '🔧 [Tiến độ: Hỗ trợ kỹ thuật] 🔄 Đổi trạng thái tiến độ: \'Chưa bắt đầu\' → \'Đang thực hiện\'', '2025-11-24 03:16:03'),
(459, 260, 18, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-17\' | 👥 Đổi người nhận: \'Vũ Tam Hanh, Nguyễn Ngọc Tuyền\' → \'Nguyễn Ngọc Tuyền,Vũ Tam Hanh\' | 📎 Cập nhật link tài liệu', '2025-11-24 03:16:06'),
(460, 263, 11, '📄 Cập nhật mô tả công việc | 📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-17\' | 📎 Cập nhật link tài liệu', '2025-11-24 03:16:09'),
(461, 263, 11, '🔧 [Tiến độ: Điện a MInh sắp xếp lịch] 🔄 Đổi trạng thái tiến độ: \'Chưa bắt đầu\' → \'Đang thực hiện\'', '2025-11-24 03:16:40'),
(462, 263, 11, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-17\' | 🔄 Đổi trạng thái: \'Đang thực hiện\' → \'Chưa bắt đầu\'', '2025-11-24 03:16:42'),
(463, 269, 18, 'Xóa công việc', '2025-11-24 03:17:27'),
(464, 281, 11, '➕ Thêm tiến độ mới: \'Trao đổi với a TIm về các bước thực hiện\' | Trạng thái: Đang thực hiện | Ngày bắt đầu: 2025-11-24 | Deadline: 2025-11-30', '2025-11-24 03:21:14'),
(465, 281, 11, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-21\' | 🔄 Đổi trạng thái: \'Đang thực hiện\' → \'Chưa bắt đầu\' | 👥 Đổi người nhận: \'Nguyễn Tấn Dũng, Vũ Thị Hải Yến\' → \'Nguyễn Tấn Dũng,Vũ Thị Hải Yến\'', '2025-11-24 03:21:23'),
(466, 241, 18, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-12-05\' | 📅 Đổi deadline: \'2049-11-18\' → \'2025-12-26\'', '2025-11-24 03:25:44'),
(467, 266, 3, '🔧 [Tiến độ: Liên hệ anh Đạt] � Cập nhật mô tả tiến độ | 🔄 Đổi trạng thái tiến độ: \'Chưa bắt đầu\' → \'Đang thực hiện\'', '2025-11-24 03:39:32'),
(468, 266, 3, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-21\'', '2025-11-24 03:39:52'),
(469, 250, 10, 'Tắt nhắc việc', '2025-11-24 03:49:24'),
(470, 268, 18, 'Xóa công việc', '2025-11-24 04:11:14'),
(471, 277, 18, '➕ Thêm tiến độ mới: \'Đợi quang anh hoàn thiện Frontend rồi bắt đầu làm backend\' | Trạng thái: Chưa bắt đầu | Ngày bắt đầu: 2025-11-24 | Deadline: 2025-12-26', '2025-11-24 07:10:37'),
(472, 277, 18, '🔧 [Tiến độ: Giao diện landing page] 📝 Đổi tên tiến độ: \'Đợi quang anh hoàn thiện Frontend rồi bắt đầu làm backend\' → \'Giao diện landing page\'', '2025-11-24 07:11:41'),
(473, 284, 18, '➕ Thêm tiến độ mới: \'Đợi quang anh hoàn thiện Fe rồi hỗ trợ backend\' | Trạng thái: Chưa bắt đầu | Ngày bắt đầu: 2025-11-24 | Deadline: 2025-12-26', '2025-11-24 07:13:39'),
(474, 284, 18, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-24\' | 📎 Cập nhật link tài liệu', '2025-11-24 07:13:48'),
(475, 284, 18, '🔧 [Tiến độ: Đợi quang anh hoàn thiện Fe rồi hỗ trợ backend] 🔄 Đổi trạng thái tiến độ: \'Chưa bắt đầu\' → \'Đang thực hiện\'', '2025-11-24 07:14:01'),
(476, 284, 18, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-24\' | 🔄 Đổi trạng thái: \'Đang thực hiện\' → \'Chưa bắt đầu\'', '2025-11-24 07:14:17'),
(477, 278, 18, '➕ Thêm tiến độ mới: \'B\' | Trạng thái: Chưa bắt đầu | Ngày bắt đầu: 2025-11-24 | Deadline: 2025-11-28', '2025-11-24 07:14:37'),
(478, 278, 18, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-21\' | 📎 Cập nhật link tài liệu', '2025-11-24 07:14:42'),
(479, 278, 18, '🔧 [Tiến độ: B] 🔄 Đổi trạng thái tiến độ: \'Chưa bắt đầu\' → \'Đang thực hiện\'', '2025-11-24 07:14:54'),
(480, 278, 18, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-21\'', '2025-11-24 07:14:55'),
(481, 277, 18, '🔧 [Tiến độ: Giao diện landing page] 🔄 Đổi trạng thái tiến độ: \'Chưa bắt đầu\' → \'Đang thực hiện\'', '2025-11-24 07:15:11'),
(482, 277, 18, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-21\' | 📎 Cập nhật link tài liệu', '2025-11-24 07:15:13'),
(483, 277, 18, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-21\' | 🔄 Đổi trạng thái: \'Đang thực hiện\' → \'Chưa bắt đầu\'', '2025-11-24 07:15:17'),
(484, 277, 21, '🔧 [Tiến độ: Giao diện landing page] 🔄 Đổi trạng thái tiến độ: \'Đang thực hiện\' → \'Đã hoàn thành\'', '2025-11-24 07:48:08'),
(485, 277, 21, '➕ Thêm tiến độ mới: \'Giao diện người dùng\' | Trạng thái: Đã hoàn thành | Ngày bắt đầu: 2025-11-21 | Deadline: 2025-11-23', '2025-11-24 07:48:36'),
(486, 277, 21, '➕ Thêm tiến độ mới: \'Giao diện khóa học, chi tiết khóa học, search.\' | Trạng thái: Đã hoàn thành | Ngày bắt đầu: 2025-11-22 | Deadline: 2025-11-23', '2025-11-24 07:49:34'),
(487, 277, 21, '➕ Thêm tiến độ mới: \'Giao diện admin, giảng viên và các giao diện chức năng.\' | Trạng thái: Đang thực hiện | Ngày bắt đầu: 2025-11-23 | Deadline: 2025-11-27', '2025-11-24 07:50:03'),
(488, 277, 21, '➕ Thêm tiến độ mới: \'Giao diện cài đặt và các chức năng user\' | Trạng thái: Đang thực hiện | Ngày bắt đầu: 2025-11-23 | Deadline: 2025-11-27', '2025-11-24 07:50:48'),
(489, 278, 21, '🔧 [Tiến độ: Login và Regis ] 📝 Đổi tên tiến độ: \'B\' → \'Login và Regis \' | 🔄 Đổi trạng thái tiến độ: \'Đang thực hiện\' → \'Đã hoàn thành\' | 📅 Đổi ngày bắt đầu: \'2025-11-24\' → \'2025-11-22\' | 📅 Đổi deadline tiến độ: \'2025-11-28\' → \'2025-11-25\'', '2025-11-24 07:51:28'),
(490, 277, 21, '📄 Cập nhật mô tả công việc | 📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-21\' | 🔄 Đổi trạng thái: \'Đã hoàn thành\' → \'Đang thực hiện\'', '2025-11-24 07:52:00'),
(491, 278, 21, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-21\' | 🔄 Đổi trạng thái: \'Đã hoàn thành\' → \'Đang thực hiện\'', '2025-11-24 07:52:11'),
(492, 278, 21, '➕ Thêm tiến độ mới: \'CRUD khóa học\' | Trạng thái: Chưa bắt đầu | Ngày bắt đầu: 2025-12-01 | Deadline: 2025-12-03', '2025-11-24 07:52:45'),
(493, 290, 18, '🆕 Tạo mới công việc: \'thử nhé1\' | Deadline: 2025-11-29 | Độ ưu tiên: Thấp | Người nhận: Nguyễn Huy Hoàng', '2025-11-25 06:50:14'),
(494, 291, 18, '🆕 Tạo mới công việc: \'5555555\' | Deadline: 2025-11-29 | Độ ưu tiên: Thấp | Người nhận: Tuấn Anh', '2025-11-25 06:50:49'),
(495, 292, 18, '🆕 Tạo mới công việc: \'5555555\' | Deadline: 2025-11-29 | Độ ưu tiên: Thấp | Người nhận: Nguyễn Huy Hoàng', '2025-11-25 08:02:40'),
(496, 293, 18, '🆕 Tạo mới công việc: \'11111\' | Deadline: 2025-11-29 | Độ ưu tiên: Thấp | Người nhận: Nguyễn Huy Hoàng', '2025-11-25 08:02:52'),
(497, 292, 18, '➕ Thêm tiến độ mới: \'123\' | Trạng thái: Chưa bắt đầu | Ngày bắt đầu: 2025-11-20 | Deadline: 2025-11-21 | Mô tả: \"1\"', '2025-11-25 08:03:04'),
(498, 292, 18, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-20\' | 📎 Cập nhật link tài liệu', '2025-11-25 08:03:06'),
(499, 292, 18, '🔧 [Tiến độ: 123] 🔄 Đổi trạng thái tiến độ: \'Chưa bắt đầu\' → \'Đã hoàn thành\'', '2025-11-25 08:03:11'),
(500, 292, 18, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-20\' | 🔄 Đổi trạng thái: \'Đã hoàn thành\' → \'Chưa bắt đầu\'', '2025-11-25 08:03:11'),
(501, 293, 18, '➕ Thêm tiến độ mới: \'123\' | Trạng thái: Chưa bắt đầu | Ngày bắt đầu: 2025-11-20 | Deadline: 2025-11-21 | Mô tả: \"1\"', '2025-11-25 08:03:30'),
(502, 293, 18, '📄 Cập nhật mô tả công việc | 📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-20\' | 📎 Cập nhật link tài liệu', '2025-11-25 08:03:31'),
(503, 294, 25, '🆕 Tạo mới công việc: \'11111\' | Deadline: 2025-11-29 | Độ ưu tiên: Thấp | Người nhận: Phạm Minh Thắng', '2025-11-26 02:03:20'),
(504, 294, 25, 'Xóa công việc', '2025-11-26 03:07:32'),
(505, 294, 25, 'Khôi phục công việc', '2025-11-26 03:14:42'),
(506, 294, 25, 'Lưu trữ công việc', '2025-11-26 04:25:00'),
(507, 294, 25, 'Khôi phục công việc', '2025-11-26 04:27:07'),
(508, 294, 25, '➕ Thêm tiến độ mới: \'123\' | Trạng thái: Chưa bắt đầu | Ngày bắt đầu: 2025-11-26 | Deadline: 2025-11-21 | Mô tả: \"123\"', '2025-11-26 04:35:45'),
(509, 179, 18, '⭐ Thêm đánh giá: \"123\"', '2025-11-26 09:20:32'),
(510, 294, 18, '⭐ Thêm đánh giá: \"123\"', '2025-11-26 09:42:42'),
(511, 294, 18, '⭐ Thêm đánh giá: \"123\"', '2025-11-26 09:43:21'),
(512, 294, 18, '⭐ Thêm đánh giá: \"444444444444\"', '2025-11-26 09:43:30'),
(513, 294, 25, '⭐ Thêm đánh giá: \"em làm rồi anh ạ\"', '2025-11-26 09:57:35'),
(514, 294, 25, '⭐ Thêm đánh giá: \"bố mày làm rồi aaaaaaaaaaaaaaaaaaaaaaaaaaaa\"', '2025-11-26 09:58:41'),
(515, 294, 25, '⭐ Thêm đánh giá: \"làm ở đâu, anh k thấy\"', '2025-11-26 09:59:55'),
(516, 294, 18, '⭐ Thêm đánh giá: \"aaaa\"', '2025-11-26 17:23:15'),
(517, 294, 25, '⭐ Thêm đánh giá: \"bbbb\"', '2025-11-26 17:23:59'),
(518, 294, 18, '⭐ Thêm đánh giá: \"cccc\"', '2025-11-26 17:24:22'),
(519, 294, 18, '⭐ Thêm đánh giá: \"ddd\"', '2025-11-26 17:38:37'),
(520, 294, 25, '⭐ Thêm đánh giá: \"đây r\"', '2025-11-26 17:39:00'),
(521, 294, 25, '⭐ Thêm đánh giá: \"aaa\"', '2025-11-26 17:39:12'),
(522, 294, 25, '⭐ Thêm đánh giá: \"hú hú cà cà\"', '2025-11-26 17:41:53'),
(523, 294, 18, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-20\' | 👥 Đổi người nhận: \'Phạm Minh Thắng\' → \'Phạm Minh Thắng,Trần Đình Nam\' | 📎 Cập nhật link tài liệu', '2025-11-26 17:42:37'),
(524, 294, 18, '⭐ Thêm đánh giá: \"chắc sai\"', '2025-11-26 17:42:46'),
(525, 294, 25, '⭐ Thêm đánh giá: \"vẫn đúng mà sếp\"', '2025-11-26 17:43:06'),
(526, 294, 8, '⭐ Thêm đánh giá: \"tyuiop\"', '2025-11-26 17:43:57'),
(527, 282, 18, '⭐ Thêm đánh giá: \"123\"', '2025-11-27 01:57:40'),
(528, 282, 18, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-14\' | 👥 Đổi người nhận: \'Đặng Lê Trung\' → \'Đặng Lê Trung,Trần Đình Nam\'', '2025-11-27 02:10:28'),
(529, 282, 8, '⭐ Thêm đánh giá: \"hú hú\"', '2025-11-27 02:12:21'),
(530, 282, 8, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-14\' | 👥 Đổi người nhận: \'Đặng Lê Trung, Trần Đình Nam\' → \'Trần Đình Nam,Tuấn Anh\'', '2025-11-27 02:15:37'),
(531, 295, 18, '🆕 Tạo mới công việc: \'1\' | Deadline: 2025-11-28 | Độ ưu tiên: Thấp | Người nhận: zAdmin', '2025-11-27 02:27:50'),
(532, 296, 8, '🆕 Tạo mới công việc: \'2\' | Deadline: 2025-11-28 | Độ ưu tiên: Thấp | Người nhận: zAdmin', '2025-11-27 02:28:28'),
(533, 297, 8, '🆕 Tạo mới công việc: \'2\' | Deadline: 2025-11-28 | Độ ưu tiên: Thấp | Người nhận: Trần Đình Nam', '2025-11-27 02:44:34'),
(534, 282, 8, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-14\' | 📅 Đổi deadline: \'2025-11-30\' → \'2025-12-01\' | 👥 Đổi người nhận: \'Trần Đình Nam, Tuấn Anh\' → \'Trần Đình Nam,Tuấn Anh\'', '2025-11-27 02:47:36'),
(535, 298, 18, '🆕 Tạo mới công việc: \'1\' | Deadline: 2025-11-28 | Độ ưu tiên: Thấp | Người nhận: Nguyễn Huy Hoàng', '2025-11-27 03:07:14'),
(542, 179, 18, '➕ Thêm tiến độ mới: \'123\' | Trạng thái: Chưa bắt đầu | Ngày bắt đầu: 2025-11-26 | Deadline: 2025-11-21 | Mô tả: \"1\"', '2025-11-27 09:27:51'),
(543, 179, 18, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-09-22\' | 👥 Đổi người nhận: \'Đặng Lê Trung\' → \'Đặng Lê Trung,Nguyễn Công Bảo\'', '2025-11-27 09:42:26'),
(544, 179, 18, '🗑️ Xóa tiến độ: \'123\'', '2025-11-27 09:52:12'),
(545, 179, 18, '🗑️ Xóa tiến độ: \'123\'', '2025-11-27 09:52:13'),
(546, 179, 18, '🗑️ Xóa tiến độ: \'123\'', '2025-11-27 09:52:18'),
(547, 179, 18, '➕ Thêm tiến độ mới: \'123\' | Trạng thái: Chưa bắt đầu | Ngày bắt đầu: 2025-11-26 | Deadline: 2025-11-21 | Mô tả: \"123\"', '2025-11-27 09:52:35'),
(548, 180, 18, '🔧 [Tiến độ: Xin lịch họp với 3C] 🔄 Đổi trạng thái tiến độ: \'Đang thực hiện\' → \'Đã hoàn thành\'', '2025-11-27 18:38:26'),
(549, 180, 18, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-09-22\'', '2025-11-27 18:38:29'),
(551, 301, 18, '🆕 Tạo mới công việc: \'1\' | Deadline: 2025-11-29 | Độ ưu tiên: Thấp | Người nhận: Nguyễn Huy Hoàng', '2025-11-28 08:15:36'),
(552, 301, 18, '➕ Thêm tiến độ mới: \'1\' | Trạng thái: Chưa bắt đầu | Ngày bắt đầu: 2025-11-27 | Deadline: 2025-11-29 | Mô tả: \"1\"', '2025-11-28 08:16:11'),
(553, 301, 18, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-28\' | 📎 Cập nhật link tài liệu', '2025-11-28 08:16:23'),
(554, 301, 18, '➕ Thêm tiến độ mới: \'1\' | Trạng thái: Chưa bắt đầu | Ngày bắt đầu: 2025-11-27 | Deadline: 2025-11-29 | Mô tả: \"1\"', '2025-11-28 08:16:44'),
(555, 179, 18, '🗑️ Xóa tiến độ: \'123\'', '2025-11-28 08:17:21'),
(556, 179, 18, '➕ Thêm tiến độ mới: \'1\' | Trạng thái: Chưa bắt đầu | Ngày bắt đầu: 2025-11-27 | Deadline: 2025-11-29 | Mô tả: \"1\"', '2025-11-28 08:17:50'),
(557, 301, 18, 'Xóa công việc', '2025-11-28 08:23:50'),
(558, 179, 18, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-09-22\' | 👥 Đổi người nhận: \'Đặng Lê Trung, Nguyễn Công Bảo\' → \'Đặng Lê Trung,Nguyễn Công Bảo\'', '2025-11-28 08:33:36'),
(559, 179, 18, '➕ Thêm tiến độ mới: \'test\' | Trạng thái: Chưa bắt đầu | Ngày bắt đầu: 2025-11-27 | Deadline: 2025-11-29', '2025-11-28 08:34:02'),
(560, 179, 18, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-09-22\' | 👥 Đổi người nhận: \'Đặng Lê Trung, Nguyễn Công Bảo\' → \'Đặng Lê Trung,Nguyễn Công Bảo\'', '2025-11-28 08:34:07'),
(561, 179, 18, '🗑️ Xóa tiến độ: \'1\'', '2025-11-28 08:44:48'),
(562, 179, 18, '➕ Thêm tiến độ mới: \'1\' | Trạng thái: Chưa bắt đầu | Ngày bắt đầu: 2025-11-27 | Deadline: 2025-11-29 | Mô tả: \"123123\"', '2025-11-28 08:50:37'),
(563, 179, 18, '🗑️ Xóa tiến độ: \'1\'', '2025-11-28 08:54:04'),
(565, 298, 18, 'Xóa công việc', '2025-11-28 09:03:16'),
(566, 297, 18, 'Xóa công việc', '2025-11-28 09:03:21'),
(567, 296, 18, 'Xóa công việc', '2025-11-28 09:03:27'),
(568, 295, 18, 'Xóa công việc', '2025-11-28 09:03:32'),
(569, 294, 18, 'Xóa công việc', '2025-11-28 09:03:40'),
(570, 293, 18, 'Xóa công việc', '2025-11-28 09:03:45'),
(571, 291, 18, 'Xóa công việc', '2025-11-28 09:03:51'),
(572, 290, 18, 'Xóa công việc', '2025-11-28 09:03:58'),
(573, 302, 18, '🆕 Tạo mới công việc: \'ba sáu\' | Deadline: 2025-11-29 | Độ ưu tiên: Thấp', '2025-11-28 09:14:34'),
(574, 302, 18, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-28\' | 👥 Đổi người nhận: \'(chưa có)\' → \'Đặng Thu Hồng,Trịnh Văn Chiến\'', '2025-11-28 09:14:49'),
(575, 302, 18, '➕ Thêm tiến độ mới: \'1\' | Trạng thái: Chưa bắt đầu | Ngày bắt đầu: 2025-11-27 | Deadline: 2025-11-29 | Mô tả: \"1\"', '2025-11-28 09:15:06'),
(576, 302, 18, 'Xóa công việc', '2025-11-28 09:15:42'),
(577, 303, 18, '🆕 Tạo mới công việc: \'ba sáu\' | Deadline: 2025-11-29 | Độ ưu tiên: Thấp | Người nhận: Tuấn Anh,Nguyễn Huy Hoàng', '2025-11-29 02:46:41'),
(578, 303, 18, 'Xóa công việc', '2025-11-29 02:47:01'),
(579, 304, 18, '🆕 Tạo mới công việc: \'ba bảy\' | Deadline: 2025-11-29 | Độ ưu tiên: Thấp | Người nhận: Tuấn Anh,Nguyễn Huy Hoàng', '2025-11-29 02:47:19'),
(580, 305, 18, '🆕 Tạo mới công việc: \'ba sáu\' | Deadline: 2025-11-29 | Độ ưu tiên: Thấp | Người nhận: Tuấn Anh,Nguyễn Huy Hoàng', '2025-11-29 02:47:49'),
(581, 305, 18, 'Xóa công việc', '2025-11-29 02:47:56'),
(582, 306, 18, '🆕 Tạo mới công việc: \'ba sáu\' | Deadline: 2025-11-29 | Độ ưu tiên: Thấp | Người nhận: Tuấn Anh,Nguyễn Huy Hoàng', '2025-11-29 02:55:03'),
(584, 262, 18, '📄 Cập nhật mô tả công việc | 📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-17\' | 🔄 Đổi trạng thái: \'Trễ hạn\' → \'Chưa bắt đầu\' | 👥 Đổi người nhận: \'Vũ Tam Hanh, Nguyễn Ngọc Tuyền\' → \'Nguyễn Ngọc Tuyền,Vũ Tam Hanh\' | 📎 Cập nhật link tài liệu', '2025-12-01 06:36:47'),
(585, 262, 18, '📁 Tải lên file: Phạm Minh Thắng_Báo cáo TTDN VNPT TH_Final.docx', '2025-12-01 06:36:47'),
(586, 307, 18, '🆕 Tạo mới công việc: \'ba sáu\' | Deadline: 2025-11-29 | Độ ưu tiên: Thấp | Người nhận: Nguyễn Huy Hoàng', '2025-12-01 06:37:35'),
(587, 307, 18, 'Xóa công việc', '2025-12-01 06:38:04'),
(588, 308, 18, '🆕 Tạo mới công việc: \'ba sáu\' | Deadline: 2025-11-29 | Độ ưu tiên: Thấp | Người nhận: Nguyễn Huy Hoàng', '2025-12-01 06:38:24'),
(590, 305, 18, 'Khôi phục công việc', '2025-12-01 06:46:43'),
(591, 303, 18, 'Khôi phục công việc', '2025-12-01 06:47:13'),
(596, 239, 18, '➕ Thêm tiến độ mới: \'1\' | Trạng thái: Chưa bắt đầu | Ngày bắt đầu: 2025-11-27 | Deadline: 2025-11-29 | Mô tả: \"1\"', '2025-12-01 07:02:44'),
(597, 239, 18, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-12-03\'', '2025-12-01 07:03:04'),
(598, 239, 18, '🔧 [Tiến độ: 1] 🔄 Đổi trạng thái tiến độ: \'Chưa bắt đầu\' → \'Đã hoàn thành\'', '2025-12-01 07:03:15'),
(599, 239, 18, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-12-03\'', '2025-12-01 07:03:16'),
(600, 239, 18, '🔧 [Tiến độ: 1] 🔄 Đổi trạng thái tiến độ: \'Đã hoàn thành\' → \'Đang thực hiện\'', '2025-12-01 07:03:24'),
(601, 239, 18, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-12-03\' | 🔄 Đổi trạng thái: \'Đang thực hiện\' → \'Đã hoàn thành\'', '2025-12-01 07:03:25'),
(602, 239, 18, '🔧 [Tiến độ: 1] 🔄 Đổi trạng thái tiến độ: \'Đang thực hiện\' → \'Đã hoàn thành\'', '2025-12-01 07:27:27'),
(603, 239, 18, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-12-03\'', '2025-12-01 07:27:28'),
(604, 174, 18, 'Gia hạn công việc đến 2025-12-03', '2025-12-01 07:27:48'),
(605, 174, 18, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-11-11\' | 🔄 Đổi trạng thái: \'Trễ hạn\' → \'Đã hoàn thành\'', '2025-12-01 07:27:55'),
(606, 239, 18, '🔧 [Tiến độ: 1] 🔄 Đổi trạng thái tiến độ: \'Đã hoàn thành\' → \'Đang thực hiện\'', '2025-12-01 07:42:46'),
(607, 239, 18, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-12-03\' | 🔄 Đổi trạng thái: \'Đang thực hiện\' → \'Đã hoàn thành\'', '2025-12-01 07:42:47'),
(608, 178, 18, 'Gia hạn công việc đến 2025-12-06', '2025-12-01 08:49:42'),
(609, 178, 18, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-09-22\' | 👥 Đổi người nhận: \'Đặng Lê Trung, Nguyễn Đức Dương\' → \'Đặng Lê Trung,Nguyễn Đức Dương\'', '2025-12-01 08:49:45'),
(610, 178, 18, '📅 Đổi ngày bắt đầu: \'(chưa có)\' → \'2025-09-22\' | 📅 Đổi deadline: \'2025-12-06\' → \'2025-12-07\' | 👥 Đổi người nhận: \'Đặng Lê Trung, Nguyễn Đức Dương\' → \'Đặng Lê Trung,Nguyễn Đức Dương\'', '2025-12-01 08:50:16'),
(611, 178, 18, '📅 Đổi deadline: \'2025-12-07\' → \'2025-12-08\' | 👥 Đổi người nhận: \'Đặng Lê Trung, Nguyễn Đức Dương\' → \'Đặng Lê Trung,Nguyễn Đức Dương\'', '2025-12-01 08:54:19'),
(612, 178, 18, '📅 Đổi ngày bắt đầu: \'2025-09-22\' → \'2025-09-23\' | 👥 Đổi người nhận: \'Đặng Lê Trung, Nguyễn Đức Dương\' → \'Đặng Lê Trung,Nguyễn Đức Dương\'', '2025-12-01 08:54:31'),
(613, 178, 18, '🔧 [Tiến độ: Gửi chương trình đào tạo sang BIDV. Xin lịch đào tạo] 🔄 Đổi trạng thái tiến độ: \'Đang thực hiện\' → \'Đã hoàn thành\'', '2025-12-01 08:55:07'),
(614, 178, 18, '👥 Đổi người nhận: \'Đặng Lê Trung, Nguyễn Đức Dương\' → \'Đặng Lê Trung,Nguyễn Đức Dương\'', '2025-12-01 08:55:08'),
(615, 178, 18, '🔧 [Tiến độ: Gửi chương trình đào tạo sang BIDV. Xin lịch đào tạo] 📅 Đổi ngày bắt đầu: \'2025-11-24\' → \'2025-11-25\' | 📅 Đổi deadline tiến độ: \'2025-11-30\' → \'2025-12-02\'', '2025-12-01 08:55:34'),
(616, 178, 18, '👥 Đổi người nhận: \'Đặng Lê Trung, Nguyễn Đức Dương\' → \'Đặng Lê Trung,Nguyễn Đức Dương\'', '2025-12-01 08:55:35'),
(617, 178, 18, '📅 Đổi deadline: \'2025-12-08\' → \'2025-12-09\'', '2025-12-01 09:03:45'),
(618, 178, 18, '📅 Đổi ngày bắt đầu: \'2025-09-23\' → \'2025-09-24\'', '2025-12-01 09:04:07'),
(619, 178, 18, '⚡ Đổi độ ưu tiên: \'Cao\' → \'Trung bình\'', '2025-12-01 09:04:54'),
(620, 310, 18, '🆕 Tạo mới công việc: \'Lên1 bản checklist quy trình giữa ICS và Luxtech\' | Deadline: 2025-12-26 | Độ ưu tiên: Cao | Người nhận: zAdmin', '2025-12-02 08:02:04');

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
(296, 199, 14),
(299, 196, 14),
(364, 205, 3),
(365, 205, 6),
(425, 207, 11),
(435, 206, 8),
(436, 206, 6),
(442, 197, 14),
(443, 198, 14),
(449, 209, 24),
(450, 209, 6),
(451, 195, 14),
(455, 175, 11),
(457, 177, 11),
(458, 210, 3),
(466, 201, 14),
(467, 201, 6),
(468, 181, 11),
(469, 182, 11),
(470, 183, 11),
(471, 184, 11),
(472, 185, 11),
(473, 186, 11),
(474, 187, 11),
(476, 188, 11),
(477, 190, 10),
(478, 192, 10),
(479, 194, 12),
(480, 176, 11),
(481, 211, 21),
(516, 234, 24),
(517, 235, 24),
(519, 237, 24),
(520, 238, 24),
(524, 202, 17),
(525, 202, 14),
(526, 202, 3),
(527, 202, 21),
(528, 202, 8),
(529, 202, 5),
(530, 202, 6),
(542, 232, 24),
(543, 233, 24),
(544, 233, 24),
(555, 236, 24),
(573, 246, 6),
(574, 245, 3),
(588, 251, 11),
(597, 253, 3),
(598, 253, 4),
(599, 253, 6),
(606, 254, 3),
(607, 254, 6),
(610, 256, 3),
(611, 256, 6),
(613, 257, 16),
(620, 226, 25),
(621, 227, 25),
(622, 228, 25),
(623, 243, 25),
(624, 229, 25),
(625, 231, 25),
(626, 230, 25),
(633, 247, 11),
(637, 240, 24),
(639, 242, 25),
(645, 258, 4),
(649, 267, 11),
(650, 268, 24),
(651, 269, 6),
(652, 269, 24),
(656, 270, 24),
(674, 250, 10),
(682, 279, 12),
(683, 279, 3),
(698, 283, 11),
(699, 193, 7),
(704, 214, 10),
(705, 214, 7),
(708, 276, 24),
(709, 276, 25),
(713, 275, 25),
(714, 248, 25),
(715, 248, 6),
(716, 215, 11),
(717, 217, 11),
(719, 249, 11),
(724, 244, 11),
(726, 255, 3),
(727, 255, 6),
(728, 252, 11),
(732, 285, 8),
(736, 261, 11),
(739, 271, 3),
(740, 272, 8),
(741, 280, 3),
(742, 280, 12),
(745, 260, 24),
(746, 260, 6),
(748, 263, 6),
(749, 281, 3),
(750, 281, 12),
(751, 241, 24),
(752, 266, 3),
(754, 284, 24),
(759, 277, 21),
(760, 278, 21),
(761, 290, 17),
(762, 291, 23),
(766, 292, 17),
(767, 293, 17),
(769, 294, 25),
(770, 294, 8),
(775, 295, 18),
(776, 296, 18),
(777, 297, 8),
(778, 282, 8),
(779, 282, 23),
(780, 298, 17),
(791, 180, 11),
(794, 301, 17),
(797, 179, 11),
(798, 179, 27),
(799, 302, 15),
(800, 302, 5),
(801, 303, 23),
(802, 303, 17),
(803, 304, 23),
(804, 304, 17),
(805, 305, 23),
(806, 305, 17),
(807, 306, 23),
(808, 306, 17),
(809, 262, 24),
(810, 262, 6),
(811, 307, 17),
(812, 308, 17),
(819, 174, 11),
(820, 239, 24),
(837, 178, 11),
(838, 178, 10),
(839, 310, 18);

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
(161, 199, 'Báo cáo', 'Báo cáo', 'Đã hoàn thành', '2025-10-02', '2025-10-04', '2025-10-02 08:42:15'),
(162, 198, 'bước 1', 'Báo cáo', 'Đã hoàn thành', '2025-10-02', '2025-10-04', '2025-10-02 08:42:47'),
(163, 197, 'bước 1', 'Báo cáo', 'Đã hoàn thành', '2025-10-02', '2025-10-04', '2025-10-02 08:43:08'),
(164, 195, 'bước 1', 'Báo cáo', 'Đã hoàn thành', '2025-10-02', '2025-10-04', '2025-10-02 08:43:20'),
(165, 196, 'bước 1', 'Báo cáo', 'Đã hoàn thành', '2025-10-02', '2025-10-04', '2025-10-02 08:45:36'),
(167, 202, 'Nghiên cứu các sản phẩm Hyper-G chuyển giao cho ICS ', 'Nghiên cứu các sản phẩm Hyper-G chuyển giao cho ICS ', 'Đã hoàn thành', '2025-10-01', '2025-10-06', '2025-10-07 01:46:03'),
(168, 202, 'Nghiên cứu các sản phẩm Hyper-G chuyển giao cho ICS ', 'Nghiên cứu các sản phẩm Hyper-G chuyển giao cho ICS ', 'Đã hoàn thành', '2025-10-01', '2025-10-06', '2025-10-07 01:46:04'),
(169, 202, 'Tổ chức họp trực tuyến với Hyper-G', '1. Thảo luận về tích hợp bán hàng Oracle Cloud2. Thảo luận về Smart Dashboard3. Thảo luận về việc triển khai và bán hàng AI SOC4. Thảo luận về việc triển khai, xây dựng thương hiệu và bán hàng sản phẩm DLP5. Thảo luận về dự án TKV+Cysteak Oracle Clould 6. Chia sẻ và thảo luận về hệ thống CRM quản lý cơ hội kinh doanh Salesforce.', 'Đã hoàn thành', '2025-10-07', '2025-10-07', '2025-10-07 01:47:32'),
(170, 201, 'Giao việc cho phúc nghiên cứu viết sổ tay ATTT', 'Giao việc cho phúc nghiên cứu viết sổ tay ATTT', 'Đã hoàn thành', '2025-10-06', '2025-10-06', '2025-10-07 01:49:14'),
(171, 205, 'Phân tích yêu cầu của UBND TP Đà Nẵng', 'Phân tích yêu cầu của UBND TP Đà Nẵng CV 381.BC.SKHCN', 'Đã hoàn thành', '2025-10-03', '2025-10-06', '2025-10-07 01:50:38'),
(172, 201, 'Sổ tay ATTT', 'Đã hoàn thiện sổ tay', 'Đã hoàn thành', '2025-10-05', '2025-10-07', '2025-10-08 01:35:20'),
(173, 206, 'bước 1', 'anh Hanh bàn giao lại cho các bạn kĩ thuật', 'Đã hoàn thành', '2025-10-17', '2025-10-20', '2025-10-17 04:12:32'),
(174, 206, 'bước 2', 'nghiên cứu và báo cáo Mr Âu', 'Đã hoàn thành', '2025-10-17', '2025-10-20', '2025-10-17 04:12:55'),
(175, 207, 'bước 1', 'lên file đào tạo cụ thể', 'Đã hoàn thành', '2025-10-17', '2025-10-20', '2025-10-17 04:15:06'),
(176, 207, 'bước 2', 'Đào tạo và kiểm tra, báo cáo lại kết quả vào thứ 2 20/10/2025', 'Đã hoàn thành', '2025-10-17', '2025-10-20', '2025-10-17 04:15:53'),
(179, 209, 'bước 1', 'làm việc với bên Hyper G', 'Đang thực hiện', '2025-10-17', '2025-10-18', '2025-10-17 04:23:26'),
(180, 209, 'bước 2', 'Mr Hanh bàn giao cho 2 bạn kĩ thuật nắm và triển khai', 'Chưa bắt đầu', '2025-10-17', '2025-10-18', '2025-10-17 04:23:51'),
(181, 210, 'bước 1', 'Trao đổi với hyper G', 'Đã hoàn thành', '2025-10-17', '2025-10-20', '2025-10-17 04:26:15'),
(182, 210, 'bước 2', 'tài liệu bên họ có, hướng dẫn để bên mình nghiên cứu cụ thể, đặc biệt TIM và Renobit', 'Đã hoàn thành', '2025-10-17', '2025-10-20', '2025-10-17 04:27:01'),
(183, 174, 'Hoàn thành', 'Hoàn thành', 'Đã hoàn thành', '2025-11-14', '2025-11-14', '2025-11-14 02:28:11'),
(184, 175, 'Hoàn thành', 'Hoàn thành', 'Đã hoàn thành', '2025-11-14', '2025-11-14', '2025-11-14 02:30:53'),
(185, 176, 'Hoàn thành', 'Hoàn thành', 'Đã hoàn thành', '2025-11-14', '2025-11-14', '2025-11-14 02:31:15'),
(186, 177, 'Hoàn thành', 'Hoàn thành', 'Chưa bắt đầu', '2025-11-14', '2025-11-14', '2025-11-14 02:31:32'),
(187, 211, 'Hoàn thành', 'Hoàn thành', 'Đã hoàn thành', '2025-11-14', '2025-11-14', '2025-11-14 02:32:01'),
(189, 181, 'Hoàn thành', 'Hoàn thành', 'Đã hoàn thành', '2025-11-14', '2025-11-14', '2025-11-14 02:34:26'),
(190, 182, 'Hoàn thành', 'Hoàn thành', 'Chưa bắt đầu', '2025-11-14', '2025-11-14', '2025-11-14 02:34:57'),
(191, 183, 'Hoàn thành', 'Hoàn thành', 'Chưa bắt đầu', '2025-11-14', '2025-11-14', '2025-11-14 02:35:28'),
(192, 184, 'Hoàn thành', 'Hoàn thành', 'Chưa bắt đầu', '2025-11-14', '2025-11-14', '2025-11-14 02:35:43'),
(193, 185, 'Hoàn thành', 'Hoàn thành', 'Chưa bắt đầu', '2025-11-14', '2025-11-14', '2025-11-14 02:35:58'),
(194, 186, 'Hoàn thành', 'Hoàn thành', 'Chưa bắt đầu', '2025-11-14', '2025-11-14', '2025-11-14 02:36:15'),
(195, 187, 'Hoàn thành', 'Hoàn thành', 'Chưa bắt đầu', '2025-11-14', '2025-11-14', '2025-11-14 02:36:40'),
(196, 188, 'Hoàn thành', 'Hoàn thành', 'Đã hoàn thành', '2025-11-14', '2025-11-14', '2025-11-14 02:36:58'),
(197, 190, 'Hoàn thành', 'Hoàn thành', 'Đã hoàn thành', '2025-11-14', '2025-11-14', '2025-11-14 02:37:18'),
(198, 192, 'Hoàn thành', 'Hoàn thành', 'Chưa bắt đầu', '2025-11-14', '2025-11-14', '2025-11-14 02:37:33'),
(199, 194, 'Hoàn thành', 'Hoàn thành', 'Chưa bắt đầu', '2025-11-14', '2025-11-14', '2025-11-14 02:37:52'),
(200, 214, 'bước 1', '', 'Đã hoàn thành', '2025-11-14', '2025-11-18', '2025-11-14 06:13:42'),
(201, 214, 'bước 2', '', 'Chưa bắt đầu', '2025-11-14', '2025-11-18', '2025-11-14 06:13:55'),
(202, 215, 'đang thực hiện', '', 'Đang thực hiện', '2025-11-17', '2025-11-17', '2025-11-17 01:13:52'),
(203, 217, 'test', '', 'Đang thực hiện', '2025-11-17', '2025-11-17', '2025-11-17 01:14:47'),
(212, 226, 'Hoàn thành', 'Hoàn thành', 'Đã hoàn thành', '2025-11-17', '2025-11-17', '2025-11-17 01:48:52'),
(213, 227, 'Hoàn thành', 'Hoàn thành', 'Đã hoàn thành', '2025-11-17', '2025-11-17', '2025-11-17 01:49:01'),
(214, 228, 'Hoàn thành', 'Hoàn thành', 'Đã hoàn thành', '2025-11-17', '2025-11-17', '2025-11-17 01:49:45'),
(215, 231, 'Hoàn thành', 'Hoàn thành', 'Đã hoàn thành', '2025-11-17', '2025-11-17', '2025-11-17 01:50:04'),
(216, 230, 'Hoàn thành', 'Hoàn thành', 'Đã hoàn thành', '2025-11-17', '2025-11-17', '2025-11-17 01:50:15'),
(217, 229, 'Hoàn thành', 'Hoàn thành', 'Đã hoàn thành', '2025-11-17', '2025-11-17', '2025-11-17 01:50:26'),
(218, 232, 'Hoàn thành', 'Hoàn thành', 'Đang thực hiện', '2025-11-17', '2025-11-17', '2025-11-17 01:50:52'),
(219, 233, 'Hoàn thành', 'Hoàn thành', 'Đã hoàn thành', '2025-11-17', '2025-11-17', '2025-11-17 01:51:02'),
(220, 234, 'Hoàn thành', 'Hoàn thành', 'Chưa bắt đầu', '2025-11-17', '2025-11-17', '2025-11-17 01:51:13'),
(221, 241, 'Hoàn thành', 'Hoàn thành', 'Đang thực hiện', '2025-11-17', '2025-11-17', '2025-11-17 01:51:41'),
(222, 240, 'Hoàn thành', 'Hoàn thành', 'Đã hoàn thành', '2025-11-17', '2025-11-17', '2025-11-17 01:51:51'),
(223, 239, 'Hoàn thành', 'Hoàn thành', 'Đã hoàn thành', '2025-11-17', '2025-11-17', '2025-11-17 01:52:03'),
(224, 238, 'Hoàn thành', 'Hoàn thành', 'Đã hoàn thành', '2025-11-17', '2025-11-17', '2025-11-17 01:52:18'),
(225, 237, 'Hoàn thành', 'Hoàn thành', 'Đã hoàn thành', '2025-11-17', '2025-11-17', '2025-11-17 01:52:34'),
(226, 236, 'Hoàn thành', 'Hoàn thành', 'Đã hoàn thành', '2025-11-17', '2025-11-17', '2025-11-17 01:52:45'),
(227, 235, 'Hoàn thành', 'Hoàn thành', 'Đã hoàn thành', '2025-11-17', '2025-11-17', '2025-11-17 01:52:57'),
(229, 193, 'Hoàn thành', 'Hoàn thành', 'Đang thực hiện', '2025-11-17', '2025-11-17', '2025-11-17 01:53:31'),
(230, 180, 'Hoàn thành', 'Hoàn thành', 'Đã hoàn thành', '2025-11-17', '2025-11-17', '2025-11-17 01:53:46'),
(231, 179, 'Hoàn thành', 'Hoàn thành', 'Chưa bắt đầu', '2025-11-17', '2025-11-17', '2025-11-17 01:54:01'),
(232, 178, 'Hoàn thành', 'Hoàn thành', 'Chưa bắt đầu', '2025-11-17', '2025-11-17', '2025-11-17 01:54:14'),
(233, 246, 'Hẹn với TKV để xác nhận kế hoạch triển khai', '', 'Đang thực hiện', '2025-11-17', '2025-11-30', '2025-11-17 06:22:42'),
(234, 246, 'Ký hợp đồng', '', 'Đang thực hiện', '2025-12-01', '2025-12-31', '2025-11-17 06:24:04'),
(235, 245, 'đã xong', '', 'Đã hoàn thành', '2025-11-17', '2025-11-18', '2025-11-17 06:25:27'),
(236, 243, 'Hoàn thành', 'Hoàn thành', 'Đã hoàn thành', '2025-11-17', '2025-11-18', '2025-11-17 06:30:25'),
(237, 247, 'báo giá cho Mobifone', '', 'Đã hoàn thành', '2025-11-17', '2025-11-17', '2025-11-17 06:31:01'),
(238, 251, 'Đã trình hồ sơ xin ngân sách', '', 'Đang thực hiện', '2025-11-17', '2025-11-17', '2025-11-17 06:42:05'),
(239, 251, 'Ký kết hợp đồng', '', 'Chưa bắt đầu', '2025-11-17', '2025-12-31', '2025-11-17 06:42:42'),
(240, 253, 'Gặp trao đổi', '', 'Đã hoàn thành', '2025-11-03', '2025-11-03', '2025-11-17 06:50:27'),
(241, 254, 'đã khảo sát xong, cần báo cáo', '', 'Đã hoàn thành', '2025-11-14', '2025-11-14', '2025-11-17 06:55:21'),
(242, 256, 'Dũng nắm công việc và hỗ trợ a Long khảo sát', '', 'Đang thực hiện', '2025-11-17', '2025-11-30', '2025-11-17 07:00:03'),
(243, 257, 'Đã dùng thử phản hồi ok', '', 'Đã hoàn thành', '2025-11-17', '2025-11-17', '2025-11-17 07:11:35'),
(245, 260, 'Hỗ trợ kỹ thuật', '', 'Đang thực hiện', '2025-11-17', '2025-11-24', '2025-11-17 08:41:56'),
(246, 242, 'Hoàn thành', 'Hoàn thành', 'Đã hoàn thành', '2025-11-18', '2025-11-18', '2025-11-18 07:53:25'),
(247, 266, 'Liên hệ anh Đạt', 'Đã liên hệ nhưng a Đạt bận chưa trao đổi', 'Đang thực hiện', '2025-11-20', '2025-11-29', '2025-11-20 04:33:13'),
(248, 270, 'Đợi lịch khảo sát từ CyStack', '', 'Đang thực hiện', '2025-11-20', '2025-11-30', '2025-11-20 04:36:05'),
(249, 270, 'Khảo sát, báo cáo kết quả', '', 'Chưa bắt đầu', '2025-11-30', '2025-12-31', '2025-11-20 04:36:42'),
(252, 279, 'xác định hướng triển khai với a Tim', '', 'Đang thực hiện', '2025-11-21', '2025-11-21', '2025-11-21 06:53:04'),
(253, 282, 'giới thiệu sản phẩm cho Vpbak', '', 'Đã hoàn thành', '2025-11-14', '2025-11-14', '2025-11-21 06:55:20'),
(254, 282, 'Giới thiệu sản phẩm cho chủ tịch Vpbank', 'đang xin lịch hẹn', 'Đang thực hiện', '2025-11-14', '2025-11-30', '2025-11-21 06:55:54'),
(255, 283, 'gửi phương án đề xuất', '', 'Đã hoàn thành', '2025-11-03', '2025-11-03', '2025-11-21 06:58:21'),
(256, 283, 'đợi phản hồi', '', 'Đang thực hiện', '2025-11-03', '2025-11-30', '2025-11-21 06:58:50'),
(257, 276, 'Bước 2: Thực hiện', 'đang làm', 'Đang thực hiện', '2025-11-22', '2025-11-24', '2025-11-22 13:04:26'),
(258, 275, 'Hoàn thành', 'Hoàn thành', 'Đang thực hiện', '2025-11-21', '2025-11-26', '2025-11-22 13:06:12'),
(259, 248, 'Hoàn thành', 'Hoàn thành', 'Chưa bắt đầu', '2025-11-22', '2025-11-30', '2025-11-22 13:07:46'),
(260, 249, 'Xin chính sách', 'đốc thốc lien tục mà họ hẹn lần tới', 'Đang thực hiện', '2025-11-20', '2025-11-30', '2025-11-24 01:05:43'),
(261, 255, 'Trao đổi sơ bộ về bộ dữ liệu của hạ tầng IT', '', 'Đã hoàn thành', '2025-11-20', '2025-11-20', '2025-11-24 01:17:14'),
(262, 244, 'Đang làm việc với a Tim xin chính sách Netzero', '', 'Đang thực hiện', '2025-11-20', '2025-11-30', '2025-11-24 01:36:37'),
(263, 180, 'Xin lịch họp với 3C', '', 'Đã hoàn thành', '2025-11-24', '2025-11-30', '2025-11-24 01:44:26'),
(264, 252, 'Cathay đang xin lịch họp với sếp', '', 'Đang thực hiện', '2025-11-24', '2025-11-30', '2025-11-24 01:46:19'),
(265, 285, 'Hoàn thành', '', 'Đã hoàn thành', '2025-11-24', '2025-11-24', '2025-11-24 01:53:32'),
(266, 178, 'Gửi chương trình đào tạo sang BIDV. Xin lịch đào tạo', '', 'Đã hoàn thành', '2025-11-25', '2025-12-02', '2025-11-24 01:56:31'),
(267, 261, 'Xin chính sách IRmind', '', 'Đang thực hiện', '2025-11-24', '2025-11-30', '2025-11-24 02:56:31'),
(268, 271, 'XIn lịch khảo sát nhà máy', '', 'Đang thực hiện', '2025-11-24', '2025-11-30', '2025-11-24 03:13:58'),
(269, 280, 'Trao đổi với a TIm về các bước thực hiện', '', 'Đang thực hiện', '2025-11-24', '2025-11-30', '2025-11-24 03:15:14'),
(270, 263, 'Điện a MInh sắp xếp lịch', '', 'Đang thực hiện', '2025-11-24', '2025-11-30', '2025-11-24 03:16:02'),
(271, 281, 'Trao đổi với a TIm về các bước thực hiện', '', 'Đang thực hiện', '2025-11-24', '2025-11-30', '2025-11-24 03:21:14'),
(272, 277, 'Giao diện landing page', '', 'Đã hoàn thành', '2025-11-24', '2025-12-26', '2025-11-24 07:10:36'),
(273, 284, 'Đợi quang anh hoàn thiện Fe rồi hỗ trợ backend', '', 'Đang thực hiện', '2025-11-24', '2025-12-26', '2025-11-24 07:13:39'),
(274, 278, 'Login và Regis ', '', 'Đã hoàn thành', '2025-11-22', '2025-11-25', '2025-11-24 07:14:36'),
(275, 277, 'Giao diện người dùng', '', 'Đã hoàn thành', '2025-11-21', '2025-11-23', '2025-11-24 07:48:36'),
(276, 277, 'Giao diện khóa học, chi tiết khóa học, search.', '', 'Đã hoàn thành', '2025-11-22', '2025-11-23', '2025-11-24 07:49:33'),
(277, 277, 'Giao diện admin, giảng viên và các giao diện chức năng.', '', 'Đang thực hiện', '2025-11-23', '2025-11-27', '2025-11-24 07:50:03'),
(278, 277, 'Giao diện cài đặt và các chức năng user', '', 'Đang thực hiện', '2025-11-23', '2025-11-27', '2025-11-24 07:50:47'),
(279, 278, 'CRUD khóa học', '', 'Chưa bắt đầu', '2025-12-01', '2025-12-03', '2025-11-24 07:52:45'),
(280, 292, '123', '1', 'Đã hoàn thành', '2025-11-20', '2025-11-21', '2025-11-25 08:03:03'),
(281, 293, '123', '1', 'Chưa bắt đầu', '2025-11-20', '2025-11-21', '2025-11-25 08:03:30'),
(282, 294, '123', '123', 'Chưa bắt đầu', '2025-11-26', '2025-11-21', '2025-11-26 04:35:45'),
(287, 301, '1', '1', 'Chưa bắt đầu', '2025-11-27', '2025-11-29', '2025-11-28 08:16:11'),
(288, 301, '1', '1', 'Chưa bắt đầu', '2025-11-27', '2025-11-29', '2025-11-28 08:16:44'),
(290, 179, 'test', '', 'Chưa bắt đầu', '2025-11-27', '2025-11-29', '2025-11-28 08:34:02'),
(292, 302, '1', '1', 'Chưa bắt đầu', '2025-11-27', '2025-11-29', '2025-11-28 09:15:06'),
(293, 239, '1', '1', 'Đang thực hiện', '2025-11-27', '2025-11-29', '2025-12-01 07:02:44');

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
(78, 174, 100, '2025-12-01 07:27:40'),
(79, 194, 100, '2025-11-14 02:37:55'),
(80, 179, 0, '2025-11-28 09:20:14'),
(81, 196, 100, '2025-10-21 07:41:41'),
(82, 195, 100, '2025-11-14 02:22:42'),
(83, 199, 100, '2025-10-02 08:43:20'),
(84, 201, 100, '2025-11-18 05:55:49'),
(85, 198, 100, '2025-11-12 01:27:42'),
(86, 197, 100, '2025-11-19 04:02:24'),
(87, 202, 100, '2025-11-24 04:20:47'),
(88, 190, 100, '2025-11-25 06:26:33'),
(90, 192, 100, '2025-11-14 02:37:36'),
(91, 205, 100, '2025-11-14 02:26:07'),
(93, 206, 100, '2025-11-20 04:32:41'),
(94, 207, 100, '2025-11-14 02:32:53'),
(96, 209, 0, '2025-11-21 01:24:17'),
(97, 210, 100, '2025-11-14 02:32:41'),
(98, 176, 100, '2025-11-14 02:45:14'),
(99, 211, 100, '2025-11-20 06:48:42'),
(100, 175, 100, '2025-11-14 02:30:53'),
(101, 193, 0, '2025-11-21 09:48:58'),
(102, 177, 100, '2025-11-14 02:31:38'),
(103, 178, 50, '2025-12-01 09:04:56'),
(104, 180, 100, '2025-11-27 18:38:35'),
(105, 184, 100, '2025-11-14 02:35:46'),
(108, 181, 100, '2025-11-14 02:42:03'),
(109, 182, 0, '2025-11-22 13:12:47'),
(110, 183, 100, '2025-11-14 02:35:31'),
(111, 185, 100, '2025-11-14 02:36:01'),
(112, 186, 100, '2025-11-14 02:36:18'),
(113, 187, 100, '2025-11-14 02:36:43'),
(114, 188, 100, '2025-11-14 02:37:05'),
(115, 214, 50, '2025-11-21 09:51:50'),
(116, 215, 0, '2025-11-24 01:03:20'),
(117, 217, 0, '2025-11-24 01:03:57'),
(119, 235, 100, '2025-11-24 03:30:53'),
(124, 236, 100, '2025-11-17 03:43:43'),
(128, 226, 100, '2025-11-28 08:26:55'),
(129, 227, 100, '2025-11-17 07:47:14'),
(130, 228, 100, '2025-11-17 07:46:47'),
(131, 231, 100, '2025-11-17 07:55:20'),
(132, 230, 100, '2025-11-17 07:47:17'),
(133, 229, 100, '2025-11-17 07:46:54'),
(134, 232, 0, '2025-11-17 02:07:56'),
(135, 233, 100, '2025-11-17 02:08:25'),
(136, 234, 0, '2025-11-24 03:13:04'),
(137, 241, 0, '2025-11-24 03:25:26'),
(138, 240, 100, '2025-11-17 09:16:39'),
(139, 239, 50, '2025-12-01 07:42:45'),
(140, 238, 100, '2025-11-17 02:05:14'),
(141, 237, 100, '2025-11-17 02:04:54'),
(143, 242, 100, '2025-11-18 07:53:48'),
(144, 243, 100, '2025-11-17 07:47:18'),
(145, 245, 100, '2025-11-17 06:47:12'),
(146, 246, 0, '2025-11-24 01:02:51'),
(147, 247, 100, '2025-11-17 08:39:51'),
(148, 248, 0, '2025-11-28 04:10:30'),
(149, 251, 0, '2025-11-24 01:03:06'),
(150, 252, 0, '2025-11-24 01:46:19'),
(151, 253, 100, '2025-11-17 07:15:18'),
(152, 254, 100, '2025-11-17 06:55:32'),
(153, 256, 0, '2025-11-20 04:14:17'),
(154, 257, 100, '2025-11-19 04:29:46'),
(155, 258, 0, '2025-11-24 03:23:45'),
(157, 260, 0, '2025-11-28 08:04:16'),
(158, 261, 0, '2025-11-24 02:57:50'),
(159, 255, 100, '2025-11-24 01:44:50'),
(161, 266, 0, '2025-11-24 03:39:32'),
(162, 267, 0, '2025-11-20 04:24:08'),
(163, 270, 0, '2025-11-24 03:09:51'),
(164, 272, 0, '2025-12-01 07:03:56'),
(166, 249, 0, '2025-11-24 01:05:43'),
(167, 250, 0, '2025-11-24 04:19:20'),
(168, 275, 0, '2025-11-24 03:35:12'),
(169, 277, 60, '2025-11-24 07:51:52'),
(170, 276, 0, '2025-11-22 13:05:07'),
(171, 281, 0, '2025-11-24 03:21:14'),
(172, 279, 0, '2025-11-21 06:53:04'),
(173, 271, 0, '2025-11-24 03:13:58'),
(174, 282, 50, '2025-11-27 02:47:38'),
(175, 283, 50, '2025-11-21 06:58:56'),
(176, 244, 0, '2025-11-24 01:36:37'),
(177, 278, 50, '2025-11-24 07:52:45'),
(178, 285, 100, '2025-11-24 01:53:32'),
(179, 269, 0, '2025-11-24 03:17:27'),
(180, 268, 0, '2025-11-24 03:36:58'),
(181, 280, 0, '2025-11-24 03:15:15'),
(182, 263, 0, '2025-11-24 03:17:05'),
(183, 284, 0, '2025-11-24 07:14:15'),
(184, 262, 0, '2025-12-01 06:36:57'),
(185, 292, 100, '2025-11-25 08:03:11'),
(186, 293, 0, '2025-11-25 08:03:30'),
(187, 294, 0, '2025-11-27 01:46:04'),
(189, 301, 0, '2025-11-28 08:16:53'),
(191, 302, 0, '2025-11-28 09:15:16'),
(192, 304, 0, '2025-12-01 06:48:33'),
(193, 307, 0, '2025-12-01 06:37:39'),
(194, 308, 0, '2025-12-01 06:48:26'),
(196, 305, 0, '2025-12-01 06:46:49'),
(197, 303, 0, '2025-12-01 06:48:14'),
(198, 306, 0, '2025-12-01 06:48:29');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `du_an`
--

CREATE TABLE `du_an` (
  `id` int(11) NOT NULL,
  `ten_du_an` varchar(255) NOT NULL,
  `mo_ta` text DEFAULT NULL,
  `lead_id` int(11) DEFAULT NULL,
  `muc_do_uu_tien` varchar(50) DEFAULT NULL,
  `ngay_bat_dau` date DEFAULT NULL,
  `ngay_ket_thuc` date DEFAULT NULL,
  `ngay_tao` timestamp NOT NULL DEFAULT current_timestamp(),
  `nhom_du_an` varchar(100) DEFAULT NULL,
  `phong_ban` varchar(255) DEFAULT NULL,
  `trang_thai_duan` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `du_an`
--

INSERT INTO `du_an` (`id`, `ten_du_an`, `mo_ta`, `lead_id`, `muc_do_uu_tien`, `ngay_bat_dau`, `ngay_ket_thuc`, `ngay_tao`, `nhom_du_an`, `phong_ban`, `trang_thai_duan`) VALUES
(1, 'Công việc chung', 'Công việc riêng', 4, 'Cao', '2025-09-17', '2035-10-31', '2025-09-17 09:03:49', 'Khác', 'Phòng Kỹ Thuật', 'Đang thực hiện'),
(37, 'Dự án TKV', 'Đã báo giá, năm 2026 triển khai', 11, 'Cao', '2025-11-18', '2026-01-31', '2025-11-10 06:55:45', 'Dashboard', 'Phòng Kỹ Thuật', 'Đang thực hiện'),
(38, 'Database Mobifone', 'Đã gửi báo giá', 11, 'Cao', '2025-11-18', '2025-11-30', '2025-11-10 06:56:34', 'Oracle Cloud', 'Phòng Kỹ Thuật', 'Đang thực hiện'),
(39, 'AI SOC cho đối tác Cathay', 'Liên hệ với a GĐKT a Lương', 24, 'Cao', '2025-11-18', '2025-11-30', '2025-11-10 06:57:15', 'An ninh bảo mật', 'Phòng Kinh Doanh', 'Đang thực hiện'),
(40, 'Demo anh Đỉnh ', 'Cuối tháng 11 vào khảo sát, tư vấn', 3, 'Cao', '2025-11-18', '2025-11-30', '2025-11-10 06:57:52', 'Dashboard', 'Phòng Kinh Doanh', 'Đã kết thúc'),
(41, 'Oracle cho 3C', 'Đang dùng thử, Nam hỗ trợ', 8, 'Cao', '2025-11-18', '2025-11-30', '2025-11-10 07:00:08', 'Oracle Cloud', 'Phòng Kỹ Thuật', 'Đang thực hiện'),
(42, 'Dự án Đà Nẵng', 'Tư vấn chuyển đổi số', 6, 'Cao', '2025-11-18', '2026-01-01', '2025-11-10 07:00:41', 'Dashboard', 'Phòng Kỹ Thuật', 'Đang thực hiện'),
(43, 'Dự án NIC', '', 3, 'Trung bình', '2025-11-18', '2026-01-01', '2025-11-10 07:26:27', 'Dashboard', 'Phòng Kỹ Thuật', 'Đang thực hiện'),
(44, 'Dự án Dược Medlac Pharma Italia', '', 11, 'Cao', '2025-11-18', '2025-12-15', '2025-11-10 07:26:44', 'An ninh bảo mật', 'Phòng Kỹ Thuật', 'Đang thực hiện'),
(45, 'CĐS Phường Hòa Bình', '', 11, 'Cao', '2025-11-18', '2025-12-15', '2025-11-10 07:27:14', 'Chuyển đổi số', 'Phòng Kỹ Thuật', 'Đang thực hiện'),
(46, 'CĐS Xã Lương Sơn', '', 11, 'Cao', '2025-11-18', '2025-12-15', '2025-11-10 07:27:33', 'Chuyển đổi số', 'Phòng Kỹ Thuật', 'Đang thực hiện'),
(47, 'CĐS Phường Đồ Sơn', '', 11, 'Cao', '2025-11-18', '2025-12-15', '2025-11-10 07:28:05', 'Chuyển đổi số', 'Phòng Kỹ Thuật', 'Đang thực hiện'),
(48, 'Dự án Agribank', '', 4, 'Trung bình', '2025-11-18', '2025-12-15', '2025-11-10 07:28:27', 'Dashboard', 'Phòng Kỹ Thuật', 'Đang thực hiện'),
(49, 'Dự án Viettin Bank', '', 11, 'Trung bình', '2025-11-18', '2025-11-30', '2025-11-10 07:28:48', 'Dashboard', 'Phòng Kỹ Thuật', 'Đang thực hiện'),
(50, 'Dự án OEM AI Agent', '-Kỹ thuật\r\n-Kinh doanh', 24, 'Cao', '2025-11-18', '2025-11-30', '2025-11-10 07:29:04', 'Khác', 'Phòng Kỹ Thuật', 'Đã kết thúc'),
(51, 'Dự án Xã hội hóa Giáo Dục VPBank', 'làm việc với chủ tịch VPBank. ', 3, 'Cao', '2025-11-18', '2025-12-15', '2025-11-10 07:29:26', 'Dashboard', 'Phòng Kỹ Thuật', 'Đang thực hiện'),
(52, 'Vietlott', 'Pháp chế các điều luật liên quan tới quản lý , dữ liệu, số tiền phạt. Đánh giá tổng hợp số lượng máy vietlott', 6, 'Cao', '2025-11-18', '2025-12-15', '2025-11-10 07:29:47', 'Chuyển đổi số', 'Phòng Kỹ Thuật', 'Đang thực hiện'),
(53, 'Bảo Việt', 'Tìm đơn vị tư vấn chuyển đổi số liên quan bảo hiểm và ngân hàng , \"Nước ngoài\"', 11, 'Cao', '2025-11-18', '2025-12-15', '2025-11-10 07:30:07', 'Khác', 'Phòng Kỹ Thuật', 'Đang thực hiện'),
(54, 'Dược bạn a Hanh', '', 6, 'Cao', '2025-11-18', '2025-11-30', '2025-11-10 07:30:31', 'Khác', 'Phòng Kỹ Thuật', 'Đã kết thúc'),
(56, 'HRM ICS KT', 'HRM ICS KT', 25, 'Cao', '2025-11-19', '2025-11-30', '2025-11-17 01:40:10', 'Khác', 'Phòng Kỹ Thuật', 'Đang thực hiện'),
(57, 'Web HyperG', 'Tuyền Lead, Đang API security check (12/11 done) rồi họ mới gửi API cho mình tích hợp. Allen báo sẽ gửi trong hôm nay 13/11 nhưng chưa thấy', 8, 'Cao', '2025-11-18', '2025-12-15', '2025-11-17 01:40:29', 'Khác', 'Phòng Kỹ Thuật', 'Đang thực hiện'),
(58, 'Zalo Mini APP - ECHOSS KT', 'Thực hiện triển khai các mini app thông qua zalo, chuyển giao công nghệ từ Echoss', 25, 'Cao', '2025-11-19', '2025-12-01', '2025-11-17 06:32:19', 'Khác', 'Phòng Kỹ Thuật', 'Đang thực hiện'),
(60, 'Oracle Cloud KT', 'Oracle Cloud KT', 8, 'Cao', '2025-11-19', '2025-11-30', '2025-11-19 04:38:14', 'Oracle Cloud', 'Phòng Kỹ Thuật', 'Đang thực hiện'),
(61, 'Dashboard KT', 'Dashboard KT', 3, 'Cao', '2025-11-19', '2025-11-30', '2025-11-19 04:39:47', 'Dashboard', 'Phòng Kinh Doanh', 'Đang thực hiện'),
(62, 'AI SOC KT', 'AI SOC KT', 24, 'Cao', '2025-11-19', '2025-11-30', '2025-11-19 04:41:44', 'An ninh bảo mật', 'Phòng Kinh Doanh', 'Đang thực hiện'),
(63, 'VietGuard KT', 'VietGuard KT', 24, 'Cao', '2025-11-19', '2025-11-30', '2025-11-19 04:42:24', 'An ninh bảo mật', 'Phòng Kinh Doanh', 'Đang thực hiện'),
(64, 'CSA KT', 'CSA KT', 24, 'Cao', '2025-11-19', '2025-11-30', '2025-11-19 04:43:17', 'An ninh bảo mật', 'Phòng Kỹ Thuật', 'Tạm ngưng'),
(65, 'Phutraco KT', 'Phutraco KT', 8, 'Cao', '2025-11-19', '2025-11-30', '2025-11-19 04:44:43', 'Khác', 'Phòng Kỹ Thuật', 'Đang thực hiện'),
(66, 'ICSS Web KT', 'ICSS Web KT', 8, 'Cao', '2025-11-19', '2025-11-30', '2025-11-19 04:45:19', 'Khác', 'Phòng Kỹ Thuật', 'Đang thực hiện'),
(67, 'Dashboard Sale KT', 'Dashboard Sale KT', 24, 'Cao', '2025-11-19', '2025-11-30', '2025-11-19 04:46:06', 'Dashboard', 'Phòng Kinh Doanh', 'Đang thực hiện'),
(68, 'Web HyperG KT', 'Web HyperG KT', 24, 'Cao', '2025-11-19', '2025-11-30', '2025-11-19 04:46:45', 'An ninh bảo mật', 'Phòng Kỹ Thuật', 'Đang thực hiện'),
(69, 'Vyin AI KT', 'Vyin AI KT', 24, 'Cao', '2025-11-19', '2025-11-30', '2025-11-19 04:48:58', 'Khác', 'Phòng Kỹ Thuật', 'Đang thực hiện'),
(70, 'Web Learning', 'Web Learning', 24, 'Cao', '2025-11-19', '2025-11-30', '2025-11-19 04:50:18', 'Đào tạo', 'Phòng Kỹ Thuật', 'Đang thực hiện'),
(71, 'Tư vấn các module nhà máy cho Vinachem', '1. Quản lý tài sản, bảo trì bảo dưỡng\r\n2. Sản xuất thông minh\r\n3. Quản lý năng lượng ', 3, 'Thấp', NULL, NULL, '2025-11-20 03:42:23', 'Khác', 'Phòng Kỹ Thuật', 'Đang thực hiện'),
(72, 'Quản lý Zalo tập trung ', '- Viết một hệ thống quản lý toàn bộ NICK zalo của ICS ', 14, 'Trung bình', '2025-11-20', '2025-11-28', '2025-11-20 07:01:11', 'Khác', 'Phòng Kỹ Thuật', 'Đang thực hiện'),
(73, 'Đánh giá an toàn thông tin ', '-', 27, 'Trung bình', '2025-11-24', '2025-12-15', '2025-11-24 02:02:07', 'An ninh bảo mật', 'Phòng Kỹ Thuật', 'Đang thực hiện'),
(74, 'Số hoá cho công ty Phutraco', 'q', 23, 'Cao', '2025-11-18', '2025-11-26', '2025-11-27 03:22:15', 'Oracle Cloud', 'Phòng Kỹ Thuật', 'Đang thực hiện');

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
-- Cấu trúc bảng cho bảng `he_thong_quyen`
--

CREATE TABLE `he_thong_quyen` (
  `id` int(11) NOT NULL,
  `ma_quyen` varchar(50) NOT NULL COMMENT 'Mã quyền unique, dùng trong code',
  `ten_quyen` varchar(100) NOT NULL COMMENT 'Tên quyền hiển thị',
  `nhom_quyen` varchar(50) NOT NULL COMMENT 'Nhóm quyền (nhan_su, phong_ban, du_an, etc.)',
  `mo_ta` text DEFAULT NULL COMMENT 'Mô tả chi tiết quyền',
  `trang_thai` enum('Hoạt động','Vô hiệu') DEFAULT 'Hoạt động',
  `ngay_tao` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `he_thong_quyen`
--

INSERT INTO `he_thong_quyen` (`id`, `ma_quyen`, `ten_quyen`, `nhom_quyen`, `mo_ta`, `trang_thai`, `ngay_tao`) VALUES
(1, 'nhan_su.xem', 'Xem danh sách nhân viên', 'nhan_su', 'Được phép xem danh sách và thông tin nhân viên', 'Hoạt động', '2025-11-25 08:54:36'),
(2, 'nhan_su.them', 'Thêm nhân viên mới', 'nhan_su', 'Được phép thêm mới nhân viên vào hệ thống', 'Hoạt động', '2025-11-25 08:54:36'),
(3, 'nhan_su.sua', 'Sửa thông tin nhân viên', 'nhan_su', 'Được phép chỉnh sửa thông tin nhân viên', 'Hoạt động', '2025-11-25 08:54:36'),
(4, 'nhan_su.xoa', 'Xóa nhân viên', 'nhan_su', 'Được phép xóa nhân viên khỏi hệ thống', 'Hoạt động', '2025-11-25 08:54:36'),
(5, 'nhan_su.phan_quyen', 'Phân quyền nhân viên', 'nhan_su', 'Được phép cấp và thu hồi quyền cho nhân viên', 'Hoạt động', '2025-11-25 08:54:36'),
(6, 'phong_ban.xem', 'Xem danh sách phòng ban', 'phong_ban', 'Được phép xem thông tin các phòng ban', 'Hoạt động', '2025-11-25 08:54:36'),
(7, 'phong_ban.them', 'Thêm phòng ban mới', 'phong_ban', 'Được phép tạo phòng ban mới', 'Hoạt động', '2025-11-25 08:54:36'),
(8, 'phong_ban.sua', 'Sửa thông tin phòng ban', 'phong_ban', 'Được phép chỉnh sửa thông tin phòng ban', 'Hoạt động', '2025-11-25 08:54:36'),
(9, 'phong_ban.xoa', 'Xóa phòng ban', 'phong_ban', 'Được phép xóa phòng ban', 'Hoạt động', '2025-11-25 08:54:36'),
(10, 'du_an.xem', 'Xem danh sách dự án', 'du_an', 'Được phép xem thông tin các dự án', 'Hoạt động', '2025-11-25 08:54:36'),
(11, 'du_an.them', 'Tạo dự án mới', 'du_an', 'Được phép tạo dự án mới', 'Hoạt động', '2025-11-25 08:54:36'),
(12, 'du_an.sua', 'Sửa thông tin dự án', 'du_an', 'Được phép chỉnh sửa thông tin dự án', 'Hoạt động', '2025-11-25 08:54:36'),
(13, 'du_an.xoa', 'Xóa dự án', 'du_an', 'Được phép xóa dự án', 'Hoạt động', '2025-11-25 08:54:36'),
(14, 'cong_viec.xem', 'Xem danh sách công việc', 'cong_viec', 'Được phép xem danh sách công việc', 'Hoạt động', '2025-11-25 08:54:36'),
(15, 'cong_viec.them', 'Giao công việc mới', 'cong_viec', 'Được phép giao công việc cho nhân viên', 'Hoạt động', '2025-11-25 08:54:36'),
(16, 'cong_viec.sua', 'Sửa thông tin công việc', 'cong_viec', 'Được phép chỉnh sửa thông tin công việc', 'Hoạt động', '2025-11-25 08:54:36'),
(17, 'cong_viec.xoa', 'Xóa công việc', 'cong_viec', 'Được phép xóa công việc', 'Hoạt động', '2025-11-25 08:54:36'),
(18, 'cong_viec.duyet', 'Duyệt/đánh giá công việc', 'cong_viec', 'Được phép duyệt và đánh giá công việc', 'Hoạt động', '2025-11-25 08:54:36'),
(19, 'cong_viec.cap_nhat_tien_do', 'Cập nhật tiến độ', 'cong_viec', 'Được phép cập nhật tiến độ công việc', 'Hoạt động', '2025-11-25 08:54:36'),
(20, 'cham_cong.xem', 'Xem dữ liệu chấm công', 'cham_cong', 'Được phép xem dữ liệu chấm công', 'Hoạt động', '2025-11-25 08:54:36'),
(21, 'cham_cong.quan_ly', 'Quản lý chấm công', 'cham_cong', 'Được phép quản lý và chỉnh sửa dữ liệu chấm công', 'Hoạt động', '2025-11-25 08:54:36'),
(22, 'luong.xem', 'Xem bảng lương', 'luong', 'Được phép xem thông tin lương', 'Hoạt động', '2025-11-25 08:54:36'),
(23, 'luong.quan_ly', 'Quản lý lương', 'luong', 'Được phép quản lý và tính toán lương', 'Hoạt động', '2025-11-25 08:54:36'),
(24, 'bao_cao.xem', 'Xem báo cáo tổng hợp', 'bao_cao', 'Được phép xem các báo cáo tổng hợp', 'Hoạt động', '2025-11-25 08:54:36'),
(25, 'bao_cao.xuat', 'Xuất báo cáo', 'bao_cao', 'Được phép xuất báo cáo ra file', 'Hoạt động', '2025-11-25 08:54:36'),
(26, 'thong_ke.xem', 'Xem phân tích dữ liệu', 'thong_ke', 'Được phép xem các biểu đồ phân tích dữ liệu', 'Hoạt động', '2025-11-25 08:54:36'),
(27, 'he_thong.cau_hinh', 'Cấu hình hệ thống', 'he_thong', 'Được phép thay đổi cấu hình hệ thống', 'Hoạt động', '2025-11-25 08:54:36'),
(28, 'he_thong.sao_luu', 'Sao lưu & Khôi phục', 'he_thong', 'Được phép thực hiện sao lưu và khôi phục dữ liệu', 'Hoạt động', '2025-11-25 08:54:36'),
(29, 'he_thong.nhat_ky', 'Xem nhật ký hệ thống', 'he_thong', 'Được phép xem nhật ký hoạt động hệ thống', 'Hoạt động', '2025-11-25 08:54:36');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `lich_su_phan_quyen`
--

CREATE TABLE `lich_su_phan_quyen` (
  `id` int(11) NOT NULL,
  `nhan_vien_id` int(11) NOT NULL COMMENT 'ID nhân viên bị thay đổi quyền',
  `ma_quyen` varchar(50) NOT NULL COMMENT 'Mã quyền',
  `hanh_dong` enum('Cấp quyền','Thu hồi quyền','Cập nhật') NOT NULL COMMENT 'Loại thay đổi',
  `gia_tri_cu` tinyint(1) DEFAULT NULL COMMENT 'Giá trị cũ (1: có, 0: không)',
  `gia_tri_moi` tinyint(1) DEFAULT NULL COMMENT 'Giá trị mới (1: có, 0: không)',
  `nguoi_thuc_hien_id` int(11) DEFAULT NULL COMMENT 'ID người thực hiện thay đổi',
  `thoi_gian` timestamp NOT NULL DEFAULT current_timestamp(),
  `ghi_chu` text DEFAULT NULL COMMENT 'Ghi chú lý do thay đổi'
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
(12, 'Gặp Agribank', '2025-10-28', NULL, '9:30 sáng', '2025-10-27 03:09:51'),
(13, 'tham dự sự kiện LBS starup showcase', '2025-10-28', '2025-10-28', '13:00-18:00 ngày 28/10', '2025-10-27 03:10:51'),
(14, 'tham dự gặp đại sứ quán Áo tại NIC', '2025-10-30', NULL, '9:00-10:30', '2025-10-27 03:18:09'),
(15, 'gặp bên Vyin AI ', '2025-10-30', '2025-10-30', '13:00-14:00', '2025-10-27 03:19:18');

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
(3, 'Nguyễn Tấn Dũng', 'jindonguyen2015@gmail.com', '12345678', '0943924816', 'Nam', '2002-08-24', 6, 'Nhân viên', 0.00, 'Đang làm', 'Nhân viên', '2025-05-05', 'https://i.postimg.cc/CLrmzggp/z6913446856097-ac16f34c6ba3cb76c40d753bb051e0a6-Nguyen-Dung.jpg', '2025-09-04 04:03:30'),
(4, 'Võ Trung Âu', 'dr.votrungau@gmail.com', '03031989', '0931487231', 'Nam', '1989-03-03', 1, 'Giám đốc', 0.00, 'Đang làm', 'Admin', '2024-08-01', 'https://i.postimg.cc/QCX0WNCh/IMG-9548-Vo-Au.jpg', '2025-09-04 04:03:44'),
(5, 'Trịnh Văn Chiến', 'trinhchienalone@gmail.com', 'Chien123@', '0819881399', 'Nam', '2004-09-15', 6, 'Thực tập sinh', 0.00, 'Đang làm', 'Nhân viên', '2025-07-01', 'https://i.postimg.cc/660HxZb3/z3773863902306-3dcbc5c61ac55cf92ead58604f04d7c2-V-n-Chi-n-Tr-nh-Tr-Chi-n.jpg', '2025-09-04 04:04:34'),
(6, 'Vũ Tam Hanh', 'vutamhanh@gmail.com', '12345678', '0912338386', 'Nam', '1974-09-21', 6, 'Trưởng phòng', 0.00, 'Đang làm', 'Quản lý', '2025-09-03', 'https://i.postimg.cc/mg5vj6sh/456425285-8090187414400961-510193232292325071-n.jpg', '2025-09-04 04:05:00'),
(7, 'Nguyễn Thị Diễm Quỳnh', 'quynhdiem@icss.com.vn', '12345678', '0972363821', 'Nữ', '2001-11-15', 1, 'Nhân viên', 0.00, 'Đang làm', 'Nhân viên', '2025-06-16', 'https://i.postimg.cc/x1mhwnFR/IMG-8032.jpg', '2025-09-04 04:07:07'),
(8, 'Trần Đình Nam', 'trandinhnamuet@gmail.com', '12345678', '0962989431', 'Nam', '2001-09-01', 6, 'Nhân viên', 0.00, 'Đang làm', 'Nhân viên', '2025-09-03', 'https://i.ibb.co/wZkFw1R6/Avartar-Star.png', '2025-09-04 04:08:41'),
(9, 'Phạm Thị Lê Vinh', 'phamvinh2004hb@gmail.com', 'Levinh123@', '0356249734', 'Nữ', '2004-07-28', 7, 'Thực tập sinh', 0.00, 'Đang làm', 'Nhân viên', '2025-07-01', 'https://i.postimg.cc/vZjqSdqt/nh-c-y-Vinh-Ph-m.jpg', '2025-09-04 04:10:16'),
(10, 'Nguyễn Đức Dương', 'linhduonghb1992@gmail.com', '12345678', '0977230903', 'Nam', '2003-09-23', 8, 'Nhân viên', 0.00, 'Đang làm', 'Nhân viên', '2025-08-02', 'https://i.postimg.cc/VNC7xH2Q/509756574-8617132495078515-4794128757965032491-n-Linh-Duong-Nguyen.jpg', '2025-09-04 04:10:23'),
(11, 'Đặng Lê Trung', 'trungdang@icss.com.vn', '12345678@', '0985553321', 'Nam', '1991-11-24', 7, 'Trưởng phòng', 0.00, 'Đang làm', 'Quản lý', '2025-07-21', 'https://i.postimg.cc/x1mhwnFR/IMG-8032.jpg', '2025-09-04 04:28:13'),
(12, 'Vũ Thị Hải Yến', 'yenics@gmail.com', '12345678', '0900000001', 'Nữ', '2025-09-04', 1, 'Trưởng phòng', 0.00, 'Đang làm', 'Quản lý', '2025-09-04', 'https://i.postimg.cc/x1mhwnFR/IMG-8032.jpg', '2025-09-04 04:30:16'),
(13, 'Đặng Như Quỳnh', 'dangnhuquynh108@gmail.com', '12345678', '0352881187', 'Nữ', '2004-05-28', 7, 'Thực tập sinh', 0.00, 'Tạm nghỉ', 'Nhân viên', '2025-07-01', 'https://i.postimg.cc/XqQxKMBF/z6611166684599-bef42c73e3c6652f77e87eb8a82c5bc6-ng-Nh-Qu-nh.jpg', '2025-09-04 04:42:04'),
(14, 'Nguyễn Ngọc Phúc', 'mancity.phuc2004@gmail.com', '12345678', '0961522506', 'Nam', '2025-08-20', 12, 'Nhân viên', 0.00, 'Đang làm', 'Nhân viên', '2025-06-28', 'https://i.postimg.cc/x1mhwnFR/IMG-8032.jpg', '2025-09-04 06:29:30'),
(15, 'Đặng Thu Hồng', 'dangthuhong1101@gmail.com', '12345678', '0363631856', 'Nữ', '2004-12-02', 7, 'Thực tập sinh', 0.00, 'Nghỉ việc', 'Nhân viên', '2025-07-01', 'https://i.postimg.cc/x1mhwnFR/IMG-8032.jpg', '2025-09-04 06:32:20'),
(16, 'Phan Tuấn Linh', 'linhphan227366@gmail.com', '12345678', '0911162004', 'Nam', '2004-06-11', 6, 'Nhân viên', 0.00, 'Đang làm', 'Nhân viên', '2025-03-21', 'https://i.postimg.cc/xTSQT8mh/IMG-1142-linh-phan.avif', '2025-09-04 06:50:11'),
(17, 'Nguyễn Huy Hoàng', 'huyhoangnguyen20704@gmail.com', '12345678   ', '0395491415', 'Nam', '2004-07-20', 6, 'Thực tập sinh', 0.00, 'Đang làm', 'Nhân viên', '2025-07-02', 'https://i.postimg.cc/x1mhwnFR/IMG-8032.jpg', '2025-09-04 07:02:17'),
(18, 'zAdmin', 'admin@gmail.com', '123123123', 'Admin', 'Nam', '2025-09-04', 6, 'Giám đốc', 0.00, 'Đang làm', 'Admin', '2025-09-13', 'https://i.postimg.cc/x1mhwnFR/IMG-8032.jpg', '2025-09-04 07:43:56'),
(21, 'Tạ Quang Anh', 'kwanganh03@gmail.com', '12345678', '039673565', 'Nam', '2003-11-15', 6, 'Nhân viên', 0.00, 'Đang làm', 'Nhân viên', '2025-09-22', 'https://i.postimg.cc/g2Lqr6Kn/5449e2c1-c5f9-4526-a9cb-401e2ca52333.jpg', '2025-10-02 08:57:39'),
(22, 'Đào Huy Hoàng', 'huyhoang3710@gmail.com', '12345678', '0987654321', 'Nam', '2025-10-01', 1, 'Giám đốc', 0.00, 'Đang làm', 'Admin', '2025-10-01', 'https://i.postimg.cc/x1mhwnFR/IMG-8032.jpg', '2025-10-09 06:33:47'),
(23, 'Tuấn Anh', 'tuan.tr0312@gmail.com', '12345678', '0904456789', 'Nam', '2025-11-03', 7, 'Nhân viên', 0.00, 'Đang làm', 'Nhân viên', '2025-11-01', 'https://i.postimg.cc/x1mhwnFR/IMG-8032.jpg', '2025-11-03 01:58:07'),
(24, 'Nguyễn Ngọc Tuyền', 'tt98tuyen@gmail.com', '12345678', '0399045920', 'Nam', '2003-03-11', 6, 'Nhân viên', 0.00, 'Đang làm', 'Nhân viên', '2025-07-22', 'https://i.postimg.cc/q7nxs24X/z6976269052999-e22e9cb5e367830aede3a369c5f977b6.jpg', '2025-11-03 09:27:58'),
(25, 'Phạm Minh Thắng', 'minhthang@gmail.com', '12345678', '0834035090', 'Nam', '2003-11-23', 6, 'Nhân viên', 0.00, 'Đang làm', 'Nhân viên', '2025-07-20', 'https://i.postimg.cc/x1mhwnFR/IMG-8032.jpg', '2025-11-03 23:50:31'),
(27, 'Nguyễn Công Bảo', 'ncongbao2003@gmail.com', '12345678', '0900000001', 'Nam', '2003-01-22', 6, 'Nhân viên', 0.00, 'Đang làm', 'Nhân viên', '2025-11-20', 'https://i.postimg.cc/x1mhwnFR/IMG-8032.jpg', '2025-11-19 10:08:38');

--
-- Bẫy `nhanvien`
--
DELIMITER $$
CREATE TRIGGER `trigger_cap_quyen_nhan_vien_moi` AFTER INSERT ON `nhanvien` FOR EACH ROW BEGIN
    -- Cấp quyền mặc định dựa trên vai trò
    CASE NEW.vai_tro
        WHEN 'Admin' THEN
            INSERT INTO nhanvien_quyen (nhan_vien_id, ma_quyen, nguoi_cap_quyen_id)
            SELECT NEW.id, ma_quyen, 4 -- 4 là ID Admin mặc định
            FROM he_thong_quyen WHERE trang_thai = 'Hoạt động';
            
        WHEN 'Quản lý' THEN
            INSERT INTO nhanvien_quyen (nhan_vien_id, ma_quyen, nguoi_cap_quyen_id)
            SELECT NEW.id, ma_quyen, 4 
            FROM he_thong_quyen 
            WHERE trang_thai = 'Hoạt động' 
            AND ma_quyen NOT IN ('nhan_su.xoa', 'nhan_su.phan_quyen', 'phong_ban.xoa', 
                               'du_an.xoa', 'cong_viec.xoa', 'luong.quan_ly', 
                               'he_thong.cau_hinh', 'he_thong.sao_luu', 'he_thong.nhat_ky');
            
        WHEN 'Nhân viên' THEN
            INSERT INTO nhanvien_quyen (nhan_vien_id, ma_quyen, nguoi_cap_quyen_id)
            SELECT NEW.id, ma_quyen, 4 
            FROM he_thong_quyen 
            WHERE trang_thai = 'Hoạt động' 
            AND ma_quyen IN ('nhan_su.xem', 'phong_ban.xem', 'du_an.xem', 
                           'cong_viec.xem', 'cong_viec.cap_nhat_tien_do', 
                           'cham_cong.xem', 'luong.xem', 'bao_cao.xem');
    END CASE;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `nhanvien_quyen`
--

CREATE TABLE `nhanvien_quyen` (
  `nhanvien_id` int(11) NOT NULL,
  `quyen_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `nhanvien_quyen`
--

INSERT INTO `nhanvien_quyen` (`nhanvien_id`, `quyen_id`) VALUES
(4, 1),
(4, 2),
(4, 3),
(4, 4),
(4, 5),
(4, 6),
(4, 7),
(4, 8),
(4, 9),
(4, 10),
(4, 11),
(4, 12),
(4, 13),
(4, 14),
(4, 15),
(4, 16),
(4, 17),
(4, 18),
(4, 19),
(4, 21),
(4, 22),
(4, 23),
(4, 24),
(4, 25),
(4, 26),
(4, 27),
(4, 28),
(4, 29),
(4, 59),
(4, 60),
(8, 1),
(8, 2),
(8, 3),
(8, 4),
(8, 5),
(8, 6),
(8, 7),
(8, 8),
(8, 9),
(8, 10),
(8, 11),
(8, 12),
(8, 13),
(8, 14),
(8, 15),
(8, 16),
(8, 17),
(8, 18),
(8, 19),
(8, 20),
(8, 21),
(8, 22),
(8, 23),
(8, 24),
(8, 25),
(8, 26),
(8, 27),
(8, 28),
(8, 29),
(8, 59),
(8, 60),
(18, 1),
(18, 2),
(18, 3),
(18, 4),
(18, 5),
(18, 6),
(18, 7),
(18, 8),
(18, 9),
(18, 10),
(18, 11),
(18, 12),
(18, 13),
(18, 14),
(18, 15),
(18, 16),
(18, 17),
(18, 18),
(18, 19),
(18, 20),
(18, 21),
(18, 22),
(18, 23),
(18, 24),
(18, 25),
(18, 26),
(18, 27),
(18, 28),
(18, 29),
(18, 59),
(18, 60),
(22, 1),
(22, 2),
(22, 3),
(22, 4),
(22, 5),
(22, 6),
(22, 7),
(22, 8),
(22, 9),
(22, 10),
(22, 11),
(22, 12),
(22, 13),
(22, 14),
(22, 15),
(22, 16),
(22, 17),
(22, 18),
(22, 19),
(22, 20),
(22, 21),
(22, 22),
(22, 23),
(22, 24),
(22, 25),
(22, 26),
(22, 27),
(22, 28),
(22, 29),
(22, 59),
(22, 60),
(25, 10),
(25, 11),
(25, 12),
(25, 13),
(25, 14),
(25, 15),
(25, 18),
(25, 19),
(25, 60),
(27, 10),
(27, 14),
(27, 19),
(27, 20),
(27, 22);

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
(1, 'Phòng Nhân sự', 12, '2025-09-03 03:26:57'),
(6, 'Phòng Kỹ thuật', 6, '2025-09-04 04:19:49'),
(7, 'Phòng Marketing & Sales', 11, '2025-09-04 04:20:02'),
(8, 'Phòng Pháp Chế', NULL, '2025-09-04 04:20:52'),
(12, 'TTS', NULL, '2025-10-02 08:40:30');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `quyen`
--

CREATE TABLE `quyen` (
  `id` int(11) NOT NULL,
  `ma_quyen` varchar(100) NOT NULL,
  `ten_quyen` varchar(255) NOT NULL,
  `nhom_quyen` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `quyen`
--

INSERT INTO `quyen` (`id`, `ma_quyen`, `ten_quyen`, `nhom_quyen`) VALUES
(1, 'xem_nhanvien', 'Xem danh sách nhân viên', 'nhanvien'),
(2, 'them_nhanvien', 'Thêm nhân viên', 'nhanvien'),
(3, 'sua_nhanvien', 'Sửa nhân viên', 'nhanvien'),
(4, 'xoa_nhanvien', 'Xóa nhân viên', 'nhanvien'),
(5, 'phanquyen_nhanvien', 'Phân quyền nhân viên', 'nhanvien'),
(6, 'xem_phongban', 'Xem danh sách phòng ban', 'phongban'),
(7, 'them_phongban', 'Thêm phòng ban', 'phongban'),
(8, 'sua_phongban', 'Sửa phòng ban', 'phongban'),
(9, 'xoa_phongban', 'Xóa phòng ban', 'phongban'),
(10, 'xem_duan', 'Xem danh sách dự án', 'duan'),
(11, 'them_duan', 'Thêm dự án mới', 'duan'),
(12, 'sua_duan', 'Sửa dự án', 'duan'),
(13, 'xoa_duan', 'Xóa dự án', 'duan'),
(14, 'xem_congviec', 'Xem danh sách công việc', 'congviec'),
(15, 'them_congviec', 'Thêm công việc mới', 'congviec'),
(16, 'sua_congviec', 'Sửa công việc', 'congviec'),
(17, 'xoa_congviec', 'Xóa công việc', 'congviec'),
(18, 'duyet_congviec', 'Duyệt công việc', 'congviec'),
(19, 'capnhat_tiendo', 'Cập nhật tiến độ công việc', 'congviec'),
(20, 'xem_chamcong', 'Xem chấm công', 'chamcong'),
(21, 'quanly_chamcong', 'Quản lý chấm công', 'chamcong'),
(22, 'xem_luong', 'Xem bảng lương', 'luong'),
(23, 'quanly_luong', 'Quản lý lương', 'luong'),
(24, 'xem_baocao', 'Xem báo cáo', 'baocao'),
(25, 'xuat_baocao', 'Xuất báo cáo', 'baocao'),
(26, 'xem_phan_tich', 'Xem phân tích dữ liệu', 'baocao'),
(27, 'cauhinh_hethong', 'Cấu hình hệ thống', 'hethong'),
(28, 'saoluu_khoiphuc', 'Sao lưu và khôi phục', 'hethong'),
(29, 'xem_nhatky', 'Xem nhật ký hệ thống', 'hethong'),
(59, 'nhacviec', 'Nhắc việc', 'congviec'),
(60, 'them_quytrinh', 'Thêm quy trình', 'congviec');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `quy_trinh_nguoi_nhan`
--

CREATE TABLE `quy_trinh_nguoi_nhan` (
  `id` int(11) NOT NULL,
  `step_id` int(11) DEFAULT NULL,
  `nhan_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `quy_trinh_nguoi_nhan`
--

INSERT INTO `quy_trinh_nguoi_nhan` (`id`, `step_id`, `nhan_id`) VALUES
(1, 231, 4),
(2, 231, 6),
(3, 259, 17),
(4, 287, 23),
(5, 287, 17),
(6, 288, 3),
(7, 288, 16),
(8, 288, 23),
(9, 288, 17),
(12, 290, 3),
(13, 290, 16),
(14, 290, 23),
(15, 290, 17),
(18, 292, 23),
(19, 292, 17);

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
(314, 'Nhân viên mới', 'Phòng Kỹ thuật: vừa thêm một nhân viên mới.', 6, 'Nhân viên mới', 1, '2025-09-30 10:19:03', '2025-09-30 10:14:01'),
(315, 'Nhân viên mới', 'Phòng Marketing & Sales: vừa thêm một nhân viên mới.', 11, 'Nhân viên mới', 0, '2025-09-30 10:21:07', '2025-09-30 10:21:07'),
(316, 'Cập nhật công việc', 'Công việc: Lên quy trình pentest Website và App vừa được cập nhật mới', 14, 'Cập nhật', 0, '2025-10-02 08:41:08', '2025-10-02 08:41:08'),
(317, 'Cập nhật công việc', 'Công việc: Báo cáo của 10 tập đoàn lớn tại Việt Nam vừa được cập nhật mới', 14, 'Cập nhật', 0, '2025-10-02 08:41:15', '2025-10-02 08:41:15'),
(318, 'Cập nhật công việc', 'Công việc: Nghiên cứu báo cáo về hoạt động của AI SOC vừa được cập nhật mới', 14, 'Cập nhật', 0, '2025-10-02 08:41:47', '2025-10-02 08:41:47'),
(319, 'Thêm mới quy trình', 'Công việc: Lên quy trình pentest Website và App vừa được thêm quy trình mới', 14, 'Cập nhật', 0, '2025-10-02 08:42:15', '2025-10-02 08:42:15'),
(320, 'Thêm mới quy trình', 'Công việc: Nghiên cứu báo cáo về hoạt động của AI SOC vừa được thêm quy trình mới', 14, 'Cập nhật', 0, '2025-10-02 08:42:47', '2025-10-02 08:42:47'),
(321, 'Thêm mới quy trình', 'Công việc: Nghiên cứu phần AI/ML trong Dashboard vừa được thêm quy trình mới', 14, 'Cập nhật', 0, '2025-10-02 08:43:08', '2025-10-02 08:43:08'),
(322, 'Thêm mới quy trình', 'Công việc: Báo cáo của 10 tập đoàn lớn tại Việt Nam vừa được thêm quy trình mới', 14, 'Cập nhật', 0, '2025-10-02 08:43:20', '2025-10-02 08:43:20'),
(323, 'Cập nhật quy trình', 'Công việc: Lên quy trình pentest Website và App vừa được cập nhật quy trình mới', 14, 'Cập nhật', 0, '2025-10-02 08:43:20', '2025-10-02 08:43:20'),
(324, 'Cập nhật công việc', 'Công việc: Tối ưu hóa AI Agent vừa được cập nhật mới', 14, 'Cập nhật', 0, '2025-10-02 08:44:00', '2025-10-02 08:44:00'),
(325, 'Cập nhật quy trình', 'Công việc: Báo cáo của 10 tập đoàn lớn tại Việt Nam vừa được cập nhật quy trình mới', 14, 'Cập nhật', 0, '2025-10-02 08:44:04', '2025-10-02 08:44:04'),
(326, 'Thêm mới quy trình', 'Công việc: Tối ưu hóa AI Agent vừa được thêm quy trình mới', 14, 'Cập nhật', 1, '2025-10-02 08:45:46', '2025-10-02 08:45:36'),
(327, 'Cập nhật quy trình', 'Công việc: Tối ưu hóa AI Agent vừa được cập nhật quy trình mới', 14, 'Cập nhật', 0, '2025-10-02 08:45:58', '2025-10-02 08:45:58'),
(328, 'Công việc mới', 'Bạn được giao công việc: 1. Hạn: 2025-10-05.', 14, 'Công việc mới', 0, '2025-10-02 08:50:43', '2025-10-02 08:50:43'),
(329, 'Công việc mới', 'Bạn được giao công việc: Test việc cho Phúc. Hạn: 2025-10-04.', 14, 'Công việc mới', 0, '2025-10-02 08:51:14', '2025-10-02 08:51:14'),
(330, 'Nhân viên mới', 'Phòng Nhân sự: vừa thêm một nhân viên mới.', 12, 'Nhân viên mới', 0, '2025-10-02 08:57:39', '2025-10-02 08:57:39'),
(331, 'Cập nhật công việc', 'Công việc: Hoàn thiện cá chức năng của trang web oracle vừa được cập nhật mới', 6, 'Cập nhật', 1, '2025-10-07 01:27:46', '2025-10-07 01:24:45'),
(332, 'Cập nhật công việc', 'Công việc: Hoàn thiện các gói tư vấn ATTT cấp độ, đánh giá hệ thống, xây dựng các gói đào tạo nhận thức, đào tạo chuyên sâu. vừa được cập nhật mới', 6, 'Cập nhật', 1, '2025-10-07 01:27:44', '2025-10-07 01:25:48'),
(333, 'Cập nhật công việc', 'Công việc: Hoàn thiện các gói tư vấn ATTT cấp độ, đánh giá hệ thống, xây dựng các gói đào tạo nhận thức, đào tạo chuyên sâu. vừa được cập nhật mới', 14, 'Cập nhật', 0, '2025-10-07 01:25:48', '2025-10-07 01:25:48'),
(334, 'Cập nhật công việc', 'Công việc: Hoàn thiện các gói tư vấn ATTT cấp độ, đánh giá hệ thống, xây dựng các gói đào tạo nhận thức, đào tạo chuyên sâu. vừa được cập nhật mới', 14, 'Cập nhật', 0, '2025-10-07 01:25:59', '2025-10-07 01:25:59'),
(335, 'Cập nhật công việc', 'Công việc: Hoàn thiện các gói tư vấn ATTT cấp độ, đánh giá hệ thống, xây dựng các gói đào tạo nhận thức, đào tạo chuyên sâu. vừa được cập nhật mới', 6, 'Cập nhật', 1, '2025-10-07 01:27:24', '2025-10-07 01:25:59'),
(336, 'Cập nhật công việc', 'Công việc: Chốt thời gian chuyển giao các sản phẩm của Hyper-G vừa được cập nhật mới', 6, 'Cập nhật', 1, '2025-10-07 01:27:48', '2025-10-07 01:27:01'),
(338, 'Cập nhật công việc', 'Công việc: Chốt thời gian chuyển giao các sản phẩm của Hyper-G vừa được cập nhật mới', 3, 'Cập nhật', 1, '2025-10-07 01:32:24', '2025-10-07 01:27:01'),
(340, 'Cập nhật công việc', 'Công việc: Chốt thời gian chuyển giao các sản phẩm của Hyper-G vừa được cập nhật mới', 8, 'Cập nhật', 0, '2025-10-07 01:27:02', '2025-10-07 01:27:02'),
(341, 'Cập nhật công việc', 'Công việc: Chốt thời gian chuyển giao các sản phẩm của Hyper-G vừa được cập nhật mới', 17, 'Cập nhật', 0, '2025-10-07 01:27:02', '2025-10-07 01:27:02'),
(342, 'Cập nhật công việc', 'Công việc: Chốt thời gian chuyển giao các sản phẩm của Hyper-G vừa được cập nhật mới', 14, 'Cập nhật', 0, '2025-10-07 01:27:02', '2025-10-07 01:27:02'),
(343, 'Cập nhật công việc', 'Công việc: Chốt thời gian chuyển giao các sản phẩm của Hyper-G vừa được cập nhật mới', 21, 'Cập nhật', 0, '2025-10-07 01:27:02', '2025-10-07 01:27:02'),
(344, 'Cập nhật công việc', 'Công việc: Chốt thời gian chuyển giao các sản phẩm của Hyper-G vừa được cập nhật mới', 5, 'Cập nhật', 1, '2025-11-03 09:19:04', '2025-10-07 01:27:02'),
(345, 'Cập nhật công việc', 'Công việc: Hoàn thiện các gói tư vấn ATTT cấp độ, đánh giá hệ thống, xây dựng các gói đào tạo nhận thức, đào tạo chuyên sâu. vừa được cập nhật mới', 14, 'Cập nhật', 0, '2025-10-07 01:28:10', '2025-10-07 01:28:10'),
(346, 'Cập nhật công việc', 'Công việc: Hoàn thiện các gói tư vấn ATTT cấp độ, đánh giá hệ thống, xây dựng các gói đào tạo nhận thức, đào tạo chuyên sâu. vừa được cập nhật mới', 6, 'Cập nhật', 1, '2025-10-07 01:28:19', '2025-10-07 01:28:10'),
(347, 'Đánh giá công việc mới', 'Bạn vừa có thêm đánh giá cho công việc.', 10, 'Đánh giá', 1, '2025-10-13 03:17:20', '2025-10-07 01:33:50'),
(348, 'Thêm mới quy trình', 'Công việc: Lên phương án triển khai đào tạo tại Hải Phòng vừa được thêm quy trình mới', 11, 'Cập nhật', 0, '2025-10-07 01:35:55', '2025-10-07 01:35:55'),
(349, 'Thêm mới quy trình', 'Công việc: Lên phương án triển khai đào tạo tại Hải Phòng vừa được thêm quy trình mới', 10, 'Cập nhật', 1, '2025-10-13 03:17:19', '2025-10-07 01:35:55'),
(350, 'Đánh giá công việc mới', 'Bạn vừa có thêm đánh giá cho công việc.', 10, 'Đánh giá', 1, '2025-10-13 03:17:17', '2025-10-07 01:37:14'),
(351, 'Công việc mới', 'Bạn được giao công việc: Xây dựng phương án giới thiệu các sản phẩm cho NIC. Hạn: 2025-10-08.', 6, 'Công việc mới', 1, '2025-10-07 01:55:21', '2025-10-07 01:39:15'),
(352, 'Công việc mới', 'Bạn được giao công việc: Xây dựng phương án giới thiệu các sản phẩm cho NIC. Hạn: 2025-10-08.', 3, 'Công việc mới', 0, '2025-10-07 01:39:15', '2025-10-07 01:39:15'),
(353, 'Cập nhật công việc', 'Công việc: Hoàn thiện các gói tư vấn ATTT cấp độ, đánh giá hệ thống, xây dựng các gói đào tạo nhận thức, đào tạo chuyên sâu. vừa được cập nhật mới', 14, 'Cập nhật', 0, '2025-10-07 01:43:05', '2025-10-07 01:43:05'),
(354, 'Cập nhật công việc', 'Công việc: Hoàn thiện các gói tư vấn ATTT cấp độ, đánh giá hệ thống, xây dựng các gói đào tạo nhận thức, đào tạo chuyên sâu. vừa được cập nhật mới', 6, 'Cập nhật', 1, '2025-10-08 01:40:37', '2025-10-07 01:43:05'),
(355, 'Cập nhật công việc', 'Công việc: Xây dựng phương án giới thiệu các sản phẩm cho NIC vừa được cập nhật mới', 3, 'Cập nhật', 0, '2025-10-07 01:43:15', '2025-10-07 01:43:15'),
(356, 'Cập nhật công việc', 'Công việc: Xây dựng phương án giới thiệu các sản phẩm cho NIC vừa được cập nhật mới', 6, 'Cập nhật', 1, '2025-10-08 01:40:37', '2025-10-07 01:43:15'),
(357, 'Cập nhật công việc', 'Công việc: Chốt thời gian chuyển giao các sản phẩm của Hyper-G vừa được cập nhật mới', 17, 'Cập nhật', 0, '2025-10-07 01:43:46', '2025-10-07 01:43:46'),
(358, 'Cập nhật công việc', 'Công việc: Chốt thời gian chuyển giao các sản phẩm của Hyper-G vừa được cập nhật mới', 14, 'Cập nhật', 0, '2025-10-07 01:43:46', '2025-10-07 01:43:46'),
(360, 'Cập nhật công việc', 'Công việc: Chốt thời gian chuyển giao các sản phẩm của Hyper-G vừa được cập nhật mới', 3, 'Cập nhật', 0, '2025-10-07 01:43:46', '2025-10-07 01:43:46'),
(362, 'Cập nhật công việc', 'Công việc: Chốt thời gian chuyển giao các sản phẩm của Hyper-G vừa được cập nhật mới', 21, 'Cập nhật', 0, '2025-10-07 01:43:46', '2025-10-07 01:43:46'),
(363, 'Cập nhật công việc', 'Công việc: Chốt thời gian chuyển giao các sản phẩm của Hyper-G vừa được cập nhật mới', 8, 'Cập nhật', 0, '2025-10-07 01:43:47', '2025-10-07 01:43:47'),
(364, 'Cập nhật công việc', 'Công việc: Chốt thời gian chuyển giao các sản phẩm của Hyper-G vừa được cập nhật mới', 5, 'Cập nhật', 1, '2025-11-03 09:19:03', '2025-10-07 01:43:47'),
(365, 'Cập nhật công việc', 'Công việc: Chốt thời gian chuyển giao các sản phẩm của Hyper-G vừa được cập nhật mới', 6, 'Cập nhật', 1, '2025-10-08 01:40:35', '2025-10-07 01:43:47'),
(366, 'Cập nhật công việc', 'Công việc: Chốt thời gian chuyển giao các sản phẩm của Hyper-G vừa được cập nhật mới', 17, 'Cập nhật', 0, '2025-10-07 01:43:54', '2025-10-07 01:43:54'),
(367, 'Cập nhật công việc', 'Công việc: Chốt thời gian chuyển giao các sản phẩm của Hyper-G vừa được cập nhật mới', 14, 'Cập nhật', 0, '2025-10-07 01:43:55', '2025-10-07 01:43:55'),
(369, 'Cập nhật công việc', 'Công việc: Chốt thời gian chuyển giao các sản phẩm của Hyper-G vừa được cập nhật mới', 3, 'Cập nhật', 0, '2025-10-07 01:43:55', '2025-10-07 01:43:55'),
(371, 'Cập nhật công việc', 'Công việc: Chốt thời gian chuyển giao các sản phẩm của Hyper-G vừa được cập nhật mới', 21, 'Cập nhật', 0, '2025-10-07 01:43:55', '2025-10-07 01:43:55'),
(372, 'Cập nhật công việc', 'Công việc: Chốt thời gian chuyển giao các sản phẩm của Hyper-G vừa được cập nhật mới', 8, 'Cập nhật', 0, '2025-10-07 01:43:55', '2025-10-07 01:43:55'),
(373, 'Cập nhật công việc', 'Công việc: Chốt thời gian chuyển giao các sản phẩm của Hyper-G vừa được cập nhật mới', 5, 'Cập nhật', 1, '2025-11-03 09:19:02', '2025-10-07 01:43:55'),
(374, 'Cập nhật công việc', 'Công việc: Chốt thời gian chuyển giao các sản phẩm của Hyper-G vừa được cập nhật mới', 6, 'Cập nhật', 1, '2025-10-08 01:40:34', '2025-10-07 01:43:55'),
(375, 'Cập nhật công việc', 'Công việc: Hoàn thiện các gói tư vấn ATTT cấp độ, đánh giá hệ thống, xây dựng các gói đào tạo nhận thức, đào tạo chuyên sâu. vừa được cập nhật mới', 14, 'Cập nhật', 0, '2025-10-07 01:44:08', '2025-10-07 01:44:08'),
(376, 'Cập nhật công việc', 'Công việc: Hoàn thiện các gói tư vấn ATTT cấp độ, đánh giá hệ thống, xây dựng các gói đào tạo nhận thức, đào tạo chuyên sâu. vừa được cập nhật mới', 6, 'Cập nhật', 1, '2025-10-08 01:40:35', '2025-10-07 01:44:08'),
(377, 'Cập nhật công việc', 'Công việc: Chốt thời gian chuyển giao các sản phẩm của Hyper-G vừa được cập nhật mới', 17, 'Cập nhật', 0, '2025-10-07 01:44:18', '2025-10-07 01:44:18'),
(378, 'Cập nhật công việc', 'Công việc: Chốt thời gian chuyển giao các sản phẩm của Hyper-G vừa được cập nhật mới', 14, 'Cập nhật', 0, '2025-10-07 01:44:18', '2025-10-07 01:44:18'),
(380, 'Cập nhật công việc', 'Công việc: Chốt thời gian chuyển giao các sản phẩm của Hyper-G vừa được cập nhật mới', 3, 'Cập nhật', 0, '2025-10-07 01:44:19', '2025-10-07 01:44:19'),
(382, 'Cập nhật công việc', 'Công việc: Chốt thời gian chuyển giao các sản phẩm của Hyper-G vừa được cập nhật mới', 21, 'Cập nhật', 0, '2025-10-07 01:44:19', '2025-10-07 01:44:19'),
(383, 'Cập nhật công việc', 'Công việc: Chốt thời gian chuyển giao các sản phẩm của Hyper-G vừa được cập nhật mới', 8, 'Cập nhật', 0, '2025-10-07 01:44:19', '2025-10-07 01:44:19'),
(384, 'Cập nhật công việc', 'Công việc: Chốt thời gian chuyển giao các sản phẩm của Hyper-G vừa được cập nhật mới', 5, 'Cập nhật', 1, '2025-11-03 09:19:02', '2025-10-07 01:44:19'),
(385, 'Cập nhật công việc', 'Công việc: Chốt thời gian chuyển giao các sản phẩm của Hyper-G vừa được cập nhật mới', 6, 'Cập nhật', 1, '2025-10-08 01:40:40', '2025-10-07 01:44:19'),
(386, 'Cập nhật công việc', 'Công việc: Hoàn thiện các gói tư vấn ATTT cấp độ, đánh giá hệ thống, xây dựng các gói đào tạo nhận thức, đào tạo chuyên sâu. vừa được cập nhật mới', 14, 'Cập nhật', 0, '2025-10-07 01:44:33', '2025-10-07 01:44:33'),
(387, 'Cập nhật công việc', 'Công việc: Hoàn thiện các gói tư vấn ATTT cấp độ, đánh giá hệ thống, xây dựng các gói đào tạo nhận thức, đào tạo chuyên sâu. vừa được cập nhật mới', 6, 'Cập nhật', 1, '2025-10-08 01:40:33', '2025-10-07 01:44:33'),
(388, 'Thêm mới quy trình', 'Công việc: Chốt thời gian chuyển giao các sản phẩm của Hyper-G vừa được thêm quy trình mới', 17, 'Cập nhật', 0, '2025-10-07 01:46:03', '2025-10-07 01:46:03'),
(389, 'Thêm mới quy trình', 'Công việc: Chốt thời gian chuyển giao các sản phẩm của Hyper-G vừa được thêm quy trình mới', 14, 'Cập nhật', 0, '2025-10-07 01:46:03', '2025-10-07 01:46:03'),
(391, 'Thêm mới quy trình', 'Công việc: Chốt thời gian chuyển giao các sản phẩm của Hyper-G vừa được thêm quy trình mới', 3, 'Cập nhật', 0, '2025-10-07 01:46:03', '2025-10-07 01:46:03'),
(393, 'Thêm mới quy trình', 'Công việc: Chốt thời gian chuyển giao các sản phẩm của Hyper-G vừa được thêm quy trình mới', 21, 'Cập nhật', 0, '2025-10-07 01:46:03', '2025-10-07 01:46:03'),
(394, 'Thêm mới quy trình', 'Công việc: Chốt thời gian chuyển giao các sản phẩm của Hyper-G vừa được thêm quy trình mới', 8, 'Cập nhật', 0, '2025-10-07 01:46:03', '2025-10-07 01:46:03'),
(395, 'Thêm mới quy trình', 'Công việc: Chốt thời gian chuyển giao các sản phẩm của Hyper-G vừa được thêm quy trình mới', 5, 'Cập nhật', 1, '2025-11-03 09:19:01', '2025-10-07 01:46:03'),
(396, 'Thêm mới quy trình', 'Công việc: Chốt thời gian chuyển giao các sản phẩm của Hyper-G vừa được thêm quy trình mới', 6, 'Cập nhật', 1, '2025-10-08 01:40:32', '2025-10-07 01:46:04'),
(397, 'Thêm mới quy trình', 'Công việc: Chốt thời gian chuyển giao các sản phẩm của Hyper-G vừa được thêm quy trình mới', 17, 'Cập nhật', 0, '2025-10-07 01:46:04', '2025-10-07 01:46:04'),
(398, 'Thêm mới quy trình', 'Công việc: Chốt thời gian chuyển giao các sản phẩm của Hyper-G vừa được thêm quy trình mới', 14, 'Cập nhật', 0, '2025-10-07 01:46:04', '2025-10-07 01:46:04'),
(400, 'Thêm mới quy trình', 'Công việc: Chốt thời gian chuyển giao các sản phẩm của Hyper-G vừa được thêm quy trình mới', 3, 'Cập nhật', 0, '2025-10-07 01:46:04', '2025-10-07 01:46:04'),
(402, 'Thêm mới quy trình', 'Công việc: Chốt thời gian chuyển giao các sản phẩm của Hyper-G vừa được thêm quy trình mới', 21, 'Cập nhật', 0, '2025-10-07 01:46:04', '2025-10-07 01:46:04'),
(403, 'Thêm mới quy trình', 'Công việc: Chốt thời gian chuyển giao các sản phẩm của Hyper-G vừa được thêm quy trình mới', 8, 'Cập nhật', 0, '2025-10-07 01:46:05', '2025-10-07 01:46:05'),
(404, 'Thêm mới quy trình', 'Công việc: Chốt thời gian chuyển giao các sản phẩm của Hyper-G vừa được thêm quy trình mới', 5, 'Cập nhật', 1, '2025-11-03 09:19:00', '2025-10-07 01:46:05'),
(405, 'Thêm mới quy trình', 'Công việc: Chốt thời gian chuyển giao các sản phẩm của Hyper-G vừa được thêm quy trình mới', 6, 'Cập nhật', 1, '2025-10-08 01:40:31', '2025-10-07 01:46:05'),
(406, 'Thêm mới quy trình', 'Công việc: Chốt thời gian chuyển giao các sản phẩm của Hyper-G vừa được thêm quy trình mới', 17, 'Cập nhật', 0, '2025-10-07 01:47:32', '2025-10-07 01:47:32'),
(407, 'Thêm mới quy trình', 'Công việc: Chốt thời gian chuyển giao các sản phẩm của Hyper-G vừa được thêm quy trình mới', 14, 'Cập nhật', 0, '2025-10-07 01:47:32', '2025-10-07 01:47:32'),
(409, 'Thêm mới quy trình', 'Công việc: Chốt thời gian chuyển giao các sản phẩm của Hyper-G vừa được thêm quy trình mới', 3, 'Cập nhật', 1, '2025-10-07 03:37:00', '2025-10-07 01:47:32'),
(411, 'Thêm mới quy trình', 'Công việc: Chốt thời gian chuyển giao các sản phẩm của Hyper-G vừa được thêm quy trình mới', 21, 'Cập nhật', 1, '2025-10-07 03:36:56', '2025-10-07 01:47:33'),
(412, 'Thêm mới quy trình', 'Công việc: Chốt thời gian chuyển giao các sản phẩm của Hyper-G vừa được thêm quy trình mới', 8, 'Cập nhật', 1, '2025-10-07 03:36:57', '2025-10-07 01:47:33'),
(413, 'Thêm mới quy trình', 'Công việc: Chốt thời gian chuyển giao các sản phẩm của Hyper-G vừa được thêm quy trình mới', 5, 'Cập nhật', 1, '2025-10-07 03:36:59', '2025-10-07 01:47:33'),
(414, 'Thêm mới quy trình', 'Công việc: Chốt thời gian chuyển giao các sản phẩm của Hyper-G vừa được thêm quy trình mới', 6, 'Cập nhật', 1, '2025-10-07 03:36:59', '2025-10-07 01:47:33'),
(415, 'Cập nhật công việc', 'Công việc: Chốt thời gian chuyển giao các sản phẩm của Hyper-G vừa được cập nhật mới', 17, 'Cập nhật', 1, '2025-10-07 02:38:21', '2025-10-07 01:48:14'),
(416, 'Cập nhật công việc', 'Công việc: Chốt thời gian chuyển giao các sản phẩm của Hyper-G vừa được cập nhật mới', 14, 'Cập nhật', 1, '2025-10-07 02:38:21', '2025-10-07 01:48:14'),
(418, 'Cập nhật công việc', 'Công việc: Chốt thời gian chuyển giao các sản phẩm của Hyper-G vừa được cập nhật mới', 3, 'Cập nhật', 1, '2025-10-07 03:36:50', '2025-10-07 01:48:14'),
(420, 'Cập nhật công việc', 'Công việc: Chốt thời gian chuyển giao các sản phẩm của Hyper-G vừa được cập nhật mới', 21, 'Cập nhật', 1, '2025-10-07 03:36:53', '2025-10-07 01:48:14'),
(421, 'Cập nhật công việc', 'Công việc: Chốt thời gian chuyển giao các sản phẩm của Hyper-G vừa được cập nhật mới', 8, 'Cập nhật', 1, '2025-10-07 03:36:52', '2025-10-07 01:48:14'),
(422, 'Cập nhật công việc', 'Công việc: Chốt thời gian chuyển giao các sản phẩm của Hyper-G vừa được cập nhật mới', 5, 'Cập nhật', 1, '2025-10-07 03:36:55', '2025-10-07 01:48:14'),
(423, 'Cập nhật công việc', 'Công việc: Chốt thời gian chuyển giao các sản phẩm của Hyper-G vừa được cập nhật mới', 6, 'Cập nhật', 1, '2025-10-07 03:36:54', '2025-10-07 01:48:14'),
(424, 'Thêm mới quy trình', 'Công việc: Hoàn thiện các gói tư vấn ATTT cấp độ, đánh giá hệ thống, xây dựng các gói đào tạo nhận thức, đào tạo chuyên sâu. vừa được thêm quy trình mới', 14, 'Cập nhật', 1, '2025-10-07 02:38:20', '2025-10-07 01:49:14'),
(425, 'Thêm mới quy trình', 'Công việc: Hoàn thiện các gói tư vấn ATTT cấp độ, đánh giá hệ thống, xây dựng các gói đào tạo nhận thức, đào tạo chuyên sâu. vừa được thêm quy trình mới', 6, 'Cập nhật', 1, '2025-10-07 02:38:19', '2025-10-07 01:49:14'),
(426, 'Thêm mới quy trình', 'Công việc: Xây dựng phương án giới thiệu các sản phẩm cho NIC vừa được thêm quy trình mới', 3, 'Cập nhật', 1, '2025-10-07 02:38:18', '2025-10-07 01:50:39'),
(427, 'Thêm mới quy trình', 'Công việc: Xây dựng phương án giới thiệu các sản phẩm cho NIC vừa được thêm quy trình mới', 6, 'Cập nhật', 1, '2025-10-07 02:38:15', '2025-10-07 01:50:39'),
(428, 'Cập nhật công việc', 'Công việc: Xây dựng phương án giới thiệu các sản phẩm cho NIC vừa được cập nhật mới', 3, 'Cập nhật', 1, '2025-10-07 02:38:14', '2025-10-07 01:50:56'),
(429, 'Cập nhật công việc', 'Công việc: Xây dựng phương án giới thiệu các sản phẩm cho NIC vừa được cập nhật mới', 6, 'Cập nhật', 1, '2025-10-07 02:38:12', '2025-10-07 01:50:56'),
(430, 'Thêm mới quy trình', 'Công việc: Hoàn thiện các gói tư vấn ATTT cấp độ, đánh giá hệ thống, xây dựng các gói đào tạo nhận thức, đào tạo chuyên sâu. vừa được thêm quy trình mới', 14, 'Cập nhật', 1, '2025-11-03 06:19:16', '2025-10-08 01:35:20'),
(431, 'Thêm mới quy trình', 'Công việc: Hoàn thiện các gói tư vấn ATTT cấp độ, đánh giá hệ thống, xây dựng các gói đào tạo nhận thức, đào tạo chuyên sâu. vừa được thêm quy trình mới', 6, 'Cập nhật', 1, '2025-10-08 01:40:29', '2025-10-08 01:35:20'),
(432, 'Cập nhật công việc', 'Công việc: Hoàn thiện các gói tư vấn ATTT cấp độ, đánh giá hệ thống, xây dựng các gói đào tạo nhận thức, đào tạo chuyên sâu. vừa được cập nhật mới', 14, 'Cập nhật', 1, '2025-11-03 06:19:16', '2025-10-08 01:38:40'),
(433, 'Cập nhật công việc', 'Công việc: Hoàn thiện các gói tư vấn ATTT cấp độ, đánh giá hệ thống, xây dựng các gói đào tạo nhận thức, đào tạo chuyên sâu. vừa được cập nhật mới', 6, 'Cập nhật', 1, '2025-10-08 01:40:28', '2025-10-08 01:38:40'),
(434, 'Cập nhật công việc', 'Công việc: Hoàn thiện các gói tư vấn ATTT cấp độ, đánh giá hệ thống, xây dựng các gói đào tạo nhận thức, đào tạo chuyên sâu. vừa được cập nhật mới', 14, 'Cập nhật', 1, '2025-11-03 06:19:16', '2025-10-08 01:38:50'),
(435, 'Cập nhật công việc', 'Công việc: Hoàn thiện các gói tư vấn ATTT cấp độ, đánh giá hệ thống, xây dựng các gói đào tạo nhận thức, đào tạo chuyên sâu. vừa được cập nhật mới', 6, 'Cập nhật', 1, '2025-10-08 01:40:26', '2025-10-08 01:38:50'),
(436, 'Cập nhật công việc', 'Công việc: Chốt thời gian chuyển giao các sản phẩm của Hyper-G vừa được cập nhật mới', 17, 'Cập nhật', 0, '2025-10-08 01:39:14', '2025-10-08 01:39:14'),
(437, 'Cập nhật công việc', 'Công việc: Chốt thời gian chuyển giao các sản phẩm của Hyper-G vừa được cập nhật mới', 14, 'Cập nhật', 1, '2025-11-03 06:19:14', '2025-10-08 01:39:14'),
(439, 'Cập nhật công việc', 'Công việc: Chốt thời gian chuyển giao các sản phẩm của Hyper-G vừa được cập nhật mới', 3, 'Cập nhật', 0, '2025-10-08 01:39:15', '2025-10-08 01:39:15'),
(441, 'Cập nhật công việc', 'Công việc: Chốt thời gian chuyển giao các sản phẩm của Hyper-G vừa được cập nhật mới', 21, 'Cập nhật', 0, '2025-10-08 01:39:15', '2025-10-08 01:39:15'),
(442, 'Cập nhật công việc', 'Công việc: Chốt thời gian chuyển giao các sản phẩm của Hyper-G vừa được cập nhật mới', 8, 'Cập nhật', 0, '2025-10-08 01:39:15', '2025-10-08 01:39:15'),
(443, 'Cập nhật công việc', 'Công việc: Chốt thời gian chuyển giao các sản phẩm của Hyper-G vừa được cập nhật mới', 5, 'Cập nhật', 1, '2025-10-13 03:56:46', '2025-10-08 01:39:15'),
(444, 'Cập nhật công việc', 'Công việc: Chốt thời gian chuyển giao các sản phẩm của Hyper-G vừa được cập nhật mới', 6, 'Cập nhật', 1, '2025-10-08 01:40:25', '2025-10-08 01:39:15'),
(445, 'Nhân viên mới', 'Phòng Nhân sự: vừa thêm một nhân viên mới.', 12, 'Nhân viên mới', 1, '2025-10-13 03:56:40', '2025-10-09 06:33:47'),
(446, 'Công việc mới', 'Bạn được giao công việc: các bạn kỹ thuật nghiên cứu làm các dashboard cơ bản. Hạn: 2025-10-20.', 6, 'Công việc mới', 0, '2025-10-17 04:12:05', '2025-10-17 04:12:05'),
(449, 'Công việc mới', 'Bạn được giao công việc: các bạn kỹ thuật nghiên cứu làm các dashboard cơ bản. Hạn: 2025-10-20.', 8, 'Công việc mới', 0, '2025-10-17 04:12:06', '2025-10-17 04:12:06'),
(450, 'Thêm mới quy trình', 'Công việc: các bạn kỹ thuật nghiên cứu làm các dashboard cơ bản vừa được thêm quy trình mới', 6, 'Cập nhật', 0, '2025-10-17 04:12:32', '2025-10-17 04:12:32'),
(453, 'Thêm mới quy trình', 'Công việc: các bạn kỹ thuật nghiên cứu làm các dashboard cơ bản vừa được thêm quy trình mới', 8, 'Cập nhật', 0, '2025-10-17 04:12:32', '2025-10-17 04:12:32'),
(454, 'Thêm mới quy trình', 'Công việc: các bạn kỹ thuật nghiên cứu làm các dashboard cơ bản vừa được thêm quy trình mới', 6, 'Cập nhật', 0, '2025-10-17 04:12:55', '2025-10-17 04:12:55'),
(457, 'Thêm mới quy trình', 'Công việc: các bạn kỹ thuật nghiên cứu làm các dashboard cơ bản vừa được thêm quy trình mới', 8, 'Cập nhật', 0, '2025-10-17 04:12:55', '2025-10-17 04:12:55'),
(458, 'Công việc mới', 'Bạn được giao công việc: Đào tạo sale cho nhân viên công ty. Hạn: 2025-10-20.', 11, 'Công việc mới', 0, '2025-10-17 04:14:38', '2025-10-17 04:14:38'),
(459, 'Thêm mới quy trình', 'Công việc: Đào tạo sale cho nhân viên công ty vừa được thêm quy trình mới', 11, 'Cập nhật', 0, '2025-10-17 04:15:06', '2025-10-17 04:15:06'),
(460, 'Thêm mới quy trình', 'Công việc: Đào tạo sale cho nhân viên công ty vừa được thêm quy trình mới', 11, 'Cập nhật', 0, '2025-10-17 04:15:54', '2025-10-17 04:15:54'),
(461, 'Công việc mới', 'Bạn được giao công việc: T. Hạn: 2025-10-19.', 10, 'Công việc mới', 1, '2025-10-20 06:09:10', '2025-10-17 04:20:20'),
(462, 'Công việc mới', 'Bạn được giao công việc: T. Hạn: 2025-10-19.', 3, 'Công việc mới', 0, '2025-10-17 04:20:21', '2025-10-17 04:20:21'),
(463, 'Công việc mới', 'Bạn được giao công việc: T. Hạn: 2025-10-19.', 7, 'Công việc mới', 1, '2025-11-03 02:25:16', '2025-10-17 04:20:21'),
(464, 'Thêm mới quy trình', 'Công việc: T vừa được thêm quy trình mới', 10, 'Cập nhật', 1, '2025-10-20 06:09:07', '2025-10-17 04:21:08'),
(465, 'Thêm mới quy trình', 'Công việc: T vừa được thêm quy trình mới', 3, 'Cập nhật', 0, '2025-10-17 04:21:08', '2025-10-17 04:21:08'),
(466, 'Thêm mới quy trình', 'Công việc: T vừa được thêm quy trình mới', 7, 'Cập nhật', 1, '2025-11-03 02:25:19', '2025-10-17 04:21:08'),
(467, 'Thêm mới quy trình', 'Công việc: T vừa được thêm quy trình mới', 10, 'Cập nhật', 1, '2025-10-20 06:09:05', '2025-10-17 04:21:47'),
(468, 'Thêm mới quy trình', 'Công việc: T vừa được thêm quy trình mới', 3, 'Cập nhật', 0, '2025-10-17 04:21:47', '2025-10-17 04:21:47'),
(469, 'Thêm mới quy trình', 'Công việc: T vừa được thêm quy trình mới', 7, 'Cập nhật', 1, '2025-11-03 02:25:22', '2025-10-17 04:21:47'),
(470, 'Công việc mới', 'Bạn được giao công việc: HyperG bàn giao AI SOC. Hạn: 2025-10-18.', 6, 'Công việc mới', 0, '2025-10-17 04:23:03', '2025-10-17 04:23:03'),
(471, 'Thêm mới quy trình', 'Công việc: HyperG bàn giao AI SOC vừa được thêm quy trình mới', 6, 'Cập nhật', 0, '2025-10-17 04:23:27', '2025-10-17 04:23:27'),
(472, 'Thêm mới quy trình', 'Công việc: HyperG bàn giao AI SOC vừa được thêm quy trình mới', 6, 'Cập nhật', 0, '2025-10-17 04:23:51', '2025-10-17 04:23:51'),
(473, 'Công việc mới', 'Bạn được giao công việc: Làm việc với Hyper G để xin tài liệu đào tạo kĩ thuật. Hạn: 2025-10-20.', 3, 'Công việc mới', 0, '2025-10-17 04:25:42', '2025-10-17 04:25:42'),
(474, 'Thêm mới quy trình', 'Công việc: Làm việc với Hyper G để xin tài liệu đào tạo kĩ thuật vừa được thêm quy trình mới', 3, 'Cập nhật', 0, '2025-10-17 04:26:15', '2025-10-17 04:26:15'),
(475, 'Thêm mới quy trình', 'Công việc: Làm việc với Hyper G để xin tài liệu đào tạo kĩ thuật vừa được thêm quy trình mới', 3, 'Cập nhật', 0, '2025-10-17 04:27:02', '2025-10-17 04:27:02'),
(476, 'Nhân viên mới', 'Phòng Nhân sự: vừa thêm một nhân viên mới.', 12, 'Nhân viên mới', 0, '2025-10-18 10:17:45', '2025-10-18 10:17:45'),
(477, 'Cập nhật quy trình', 'Công việc: Đào tạo sale cho nhân viên công ty vừa được cập nhật quy trình mới', 11, 'Cập nhật', 0, '2025-10-19 09:45:14', '2025-10-19 09:45:14'),
(478, 'Cập nhật công việc', 'Công việc: HyperG bàn giao AI SOC vừa được cập nhật mới', 6, 'Cập nhật', 0, '2025-10-20 07:10:38', '2025-10-20 07:10:38'),
(481, 'Cập nhật công việc', 'Công việc: các bạn kỹ thuật nghiên cứu làm các dashboard cơ bản vừa được cập nhật mới', 8, 'Cập nhật', 1, '2025-10-21 07:40:00', '2025-10-20 07:12:31'),
(482, 'Cập nhật công việc', 'Công việc: các bạn kỹ thuật nghiên cứu làm các dashboard cơ bản vừa được cập nhật mới', 6, 'Cập nhật', 0, '2025-10-20 07:12:31', '2025-10-20 07:12:31'),
(485, 'Cập nhật công việc', 'Công việc: các bạn kỹ thuật nghiên cứu làm các dashboard cơ bản vừa được cập nhật mới', 8, 'Cập nhật', 0, '2025-10-20 07:12:44', '2025-10-20 07:12:44'),
(486, 'Cập nhật công việc', 'Công việc: các bạn kỹ thuật nghiên cứu làm các dashboard cơ bản vừa được cập nhật mới', 6, 'Cập nhật', 0, '2025-10-20 07:12:44', '2025-10-20 07:12:44'),
(487, 'Cập nhật công việc', 'Công việc: Làm việc với Hyper G để xin tài liệu đào tạo kĩ thuật vừa được cập nhật mới', 3, 'Cập nhật', 0, '2025-10-20 07:14:10', '2025-10-20 07:14:10'),
(490, 'Công việc mới', 'Bạn được giao công việc: Hoàn thiện các chức năng quản lý dự án theo các qui trình . Hạn: 2025-10-20.', 21, 'Công việc mới', 0, '2025-10-20 07:18:15', '2025-10-20 07:18:15'),
(493, 'Cập nhật công việc', 'Công việc: Hoàn thiện các chức năng quản lý dự án theo các qui trình  vừa được cập nhật mới', 21, 'Cập nhật', 1, '2025-10-21 07:39:54', '2025-10-20 07:18:31'),
(494, 'Công việc mới', 'Bạn được giao công việc: Nghiên cứu thực trạng trang web phutraco. Hạn: 2025-10-22.', 8, 'Công việc mới', 1, '2025-10-21 07:39:50', '2025-10-20 07:23:50'),
(495, 'Cập nhật công việc', 'Công việc: Đốc thúc Pacisoft lên báo giá cho dự án Database vừa được cập nhật mới', 11, 'Cập nhật', 0, '2025-10-22 03:56:59', '2025-10-22 03:56:59'),
(496, 'Cập nhật công việc', 'Công việc: Bổ sung gói đào tạo 2 ngày, lên báo giá và các công việc triển khai vừa được cập nhật mới', 11, 'Cập nhật', 0, '2025-10-22 03:57:41', '2025-10-22 03:57:41'),
(497, 'Cập nhật công việc', 'Công việc: Lên phương án hợp tác với TPX vừa được cập nhật mới', 11, 'Cập nhật', 0, '2025-10-24 06:19:36', '2025-10-24 06:19:36'),
(498, 'Cập nhật công việc', 'Công việc: Đốc thúc đội marketing tư vấn các gói đào tạo vừa được cập nhật mới', 11, 'Cập nhật', 0, '2025-10-24 06:20:04', '2025-10-24 06:20:04'),
(499, 'Cập nhật công việc', 'Công việc: Đốc thúc đội marketing tư vấn các gói đào tạo vừa được cập nhật mới', 11, 'Cập nhật', 0, '2025-10-24 06:20:16', '2025-10-24 06:20:16'),
(500, 'Cập nhật công việc', 'Công việc: Làm việc với a Bình BIDV vừa được cập nhật mới', 11, 'Cập nhật', 0, '2025-10-24 06:24:58', '2025-10-24 06:24:58'),
(501, 'Cập nhật công việc', 'Công việc: Bán được 5 gói đào tạo về AI vừa được cập nhật mới', 11, 'Cập nhật', 0, '2025-10-24 06:25:40', '2025-10-24 06:25:40'),
(502, 'Cập nhật công việc', 'Công việc: Làm việc với a Bình BIDV vừa được cập nhật mới', 11, 'Cập nhật', 0, '2025-10-24 06:26:15', '2025-10-24 06:26:15'),
(503, 'Cập nhật công việc', 'Công việc: Bán được 5 gói đào tạo về AI vừa được cập nhật mới', 11, 'Cập nhật', 0, '2025-10-24 06:26:31', '2025-10-24 06:26:31'),
(504, 'Cập nhật công việc', 'Công việc: Bán được 5 gói đào tạo về AI vừa được cập nhật mới', 11, 'Cập nhật', 0, '2025-10-24 06:27:04', '2025-10-24 06:27:04'),
(505, 'Cập nhật công việc', 'Công việc: Làm việc với a Bình BIDV vừa được cập nhật mới', 11, 'Cập nhật', 0, '2025-10-24 06:27:16', '2025-10-24 06:27:16'),
(506, 'Cập nhật công việc', 'Công việc: Oracle cloud: Ký hợp đồng với 3C vừa được cập nhật mới', 11, 'Cập nhật', 0, '2025-10-24 06:31:48', '2025-10-24 06:31:48'),
(507, 'Cập nhật công việc', 'Công việc: Tham gia sự kiện tại Hòa Lạc vừa được cập nhật mới', 11, 'Cập nhật', 0, '2025-10-24 06:32:07', '2025-10-24 06:32:07'),
(508, 'Cập nhật công việc', 'Công việc: Làm việc với Luxtech xây dựng kế hoạch đi tỉnh vừa được cập nhật mới', 11, 'Cập nhật', 0, '2025-10-24 06:32:20', '2025-10-24 06:32:20'),
(509, 'Cập nhật công việc', 'Công việc: Tư vấn giải pháp Dashboard cho a Đỉnh vừa được cập nhật mới', 11, 'Cập nhật', 0, '2025-10-24 06:32:44', '2025-10-24 06:32:44'),
(510, 'Cập nhật công việc', 'Công việc: Làm việc với a Tùng Gtel vừa được cập nhật mới', 11, 'Cập nhật', 0, '2025-10-24 06:40:00', '2025-10-24 06:40:00'),
(511, 'Cập nhật công việc', 'Công việc: Đốc thúc Pacisoft lên báo giá cho dự án Database vừa được cập nhật mới', 11, 'Cập nhật', 0, '2025-10-24 06:40:43', '2025-10-24 06:40:43'),
(512, 'Cập nhật công việc', 'Công việc: Làm việc lại với Mobifone vừa được cập nhật mới', 11, 'Cập nhật', 0, '2025-10-24 06:40:59', '2025-10-24 06:40:59'),
(513, 'Cập nhật công việc', 'Công việc: Lên kế hoạch Qúy IV vừa được cập nhật mới', 11, 'Cập nhật', 0, '2025-10-24 06:41:17', '2025-10-24 06:41:17'),
(514, 'Cập nhật công việc', 'Công việc: Đào tạo sale cho nhân viên công ty vừa được cập nhật mới', 11, 'Cập nhật', 0, '2025-10-24 06:41:31', '2025-10-24 06:41:31'),
(515, 'Cập nhật công việc', 'Công việc: Tìm SĐT của danh sách khách hàng vừa được cập nhật mới', 11, 'Cập nhật', 0, '2025-10-24 06:41:42', '2025-10-24 06:41:42'),
(518, 'Cập nhật công việc', 'Công việc: Hoàn thiện các chức năng quản lý dự án theo các qui trình  vừa được cập nhật mới', 21, 'Cập nhật', 0, '2025-10-24 09:38:53', '2025-10-24 09:38:53'),
(521, 'Cập nhật công việc', 'Công việc: Hoàn thiện các chức năng quản lý dự án theo các qui trình  vừa được cập nhật mới', 21, 'Cập nhật', 0, '2025-10-24 09:39:43', '2025-10-24 09:39:43'),
(524, 'Cập nhật công việc', 'Công việc: các bạn kỹ thuật nghiên cứu làm các dashboard cơ bản vừa được cập nhật mới', 8, 'Cập nhật', 0, '2025-10-24 09:40:54', '2025-10-24 09:40:54'),
(525, 'Cập nhật công việc', 'Công việc: các bạn kỹ thuật nghiên cứu làm các dashboard cơ bản vừa được cập nhật mới', 6, 'Cập nhật', 0, '2025-10-24 09:40:54', '2025-10-24 09:40:54'),
(526, 'Nhân viên mới', 'Phòng Marketing & Sales: vừa thêm một nhân viên mới.', 11, 'Nhân viên mới', 0, '2025-11-03 01:58:07', '2025-11-03 01:58:07'),
(527, 'Nhân viên mới', 'Phòng Kỹ thuật: vừa thêm một nhân viên mới.', 6, 'Nhân viên mới', 0, '2025-11-03 09:25:39', '2025-11-03 09:25:39'),
(528, 'Nhân viên mới', 'Phòng Kỹ thuật: vừa thêm một nhân viên mới.', 6, 'Nhân viên mới', 0, '2025-11-03 09:27:58', '2025-11-03 09:27:58'),
(529, 'Nhân viên mới', 'Phòng Nhân sự: vừa thêm một nhân viên mới.', 12, 'Nhân viên mới', 0, '2025-11-03 23:50:32', '2025-11-03 23:50:32'),
(530, 'Cập nhật công việc', 'Công việc: Bổ sung gói đào tạo 2 ngày, lên báo giá và các công việc triển khai vừa được cập nhật mới', 11, 'Cập nhật', 0, '2025-11-04 01:06:11', '2025-11-04 01:06:11'),
(531, 'Cập nhật công việc', 'Công việc: Làm việc với a Bình BIDV vừa được cập nhật mới', 11, 'Cập nhật', 0, '2025-11-04 01:06:32', '2025-11-04 01:06:32'),
(532, 'Cập nhật công việc', 'Công việc: Tư vấn giải pháp Dashboard cho a Đỉnh vừa được cập nhật mới', 11, 'Cập nhật', 0, '2025-11-04 01:06:50', '2025-11-04 01:06:50'),
(533, 'Công việc mới', 'Bạn được giao công việc: Test việc cho Dũng. Hạn: 2025-11-12.', 3, 'Công việc mới', 0, '2025-11-10 03:19:42', '2025-11-10 03:19:42'),
(534, 'Cập nhật công việc', 'Công việc: Báo cáo của 10 tập đoàn lớn tại Việt Nam vừa được cập nhật mới', 14, 'Cập nhật', 0, '2025-11-12 01:26:51', '2025-11-12 01:26:51'),
(535, 'Cập nhật công việc', 'Công việc: Nghiên cứu phần AI/ML trong Dashboard vừa được cập nhật mới', 14, 'Cập nhật', 0, '2025-11-12 01:27:08', '2025-11-12 01:27:08'),
(536, 'Cập nhật công việc', 'Công việc: Nghiên cứu báo cáo về hoạt động của AI SOC vừa được cập nhật mới', 14, 'Cập nhật', 0, '2025-11-12 01:27:30', '2025-11-12 01:27:30'),
(537, 'Cập nhật quy trình', 'Công việc: Nghiên cứu báo cáo về hoạt động của AI SOC vừa được cập nhật quy trình mới', 14, 'Cập nhật', 0, '2025-11-12 01:27:42', '2025-11-12 01:27:42'),
(538, 'Cập nhật quy trình', 'Công việc: Nghiên cứu phần AI/ML trong Dashboard vừa được cập nhật quy trình mới', 14, 'Cập nhật', 0, '2025-11-12 01:27:56', '2025-11-12 01:27:56'),
(539, 'Cập nhật công việc', 'Công việc: Làm lại số hotline cho facebook, zalo và các trang mạng xã hội của cty vừa được cập nhật mới', 7, 'Cập nhật', 0, '2025-11-12 02:34:15', '2025-11-12 02:34:15'),
(540, 'Cập nhật công việc', 'Công việc: Làm lại số hotline cho facebook, zalo và các trang mạng xã hội của cty vừa được cập nhật mới', 7, 'Cập nhật', 0, '2025-11-12 02:34:27', '2025-11-12 02:34:27'),
(541, 'Cập nhật công việc', 'Công việc: Trong tháng 9 đến giữa tháng 10 phải bán được 1 Dashboard vừa được cập nhật mới', 11, 'Cập nhật', 0, '2025-11-12 02:37:05', '2025-11-12 02:37:05'),
(542, 'Cập nhật công việc', 'Công việc: HyperG bàn giao AI SOC vừa được cập nhật mới', 6, 'Cập nhật', 0, '2025-11-12 02:37:45', '2025-11-12 02:37:45'),
(543, 'Cập nhật công việc', 'Công việc: HyperG bàn giao AI SOC vừa được cập nhật mới', 24, 'Cập nhật', 0, '2025-11-12 02:37:45', '2025-11-12 02:37:45'),
(544, 'Cập nhật công việc', 'Công việc: HyperG bàn giao AI SOC vừa được cập nhật mới', 24, 'Cập nhật', 0, '2025-11-12 02:37:53', '2025-11-12 02:37:53'),
(545, 'Cập nhật công việc', 'Công việc: HyperG bàn giao AI SOC vừa được cập nhật mới', 6, 'Cập nhật', 0, '2025-11-12 02:37:53', '2025-11-12 02:37:53'),
(546, 'Cập nhật quy trình', 'Công việc: Báo cáo của 10 tập đoàn lớn tại Việt Nam vừa được cập nhật quy trình mới', 14, 'Cập nhật', 0, '2025-11-14 02:22:42', '2025-11-14 02:22:42'),
(547, 'Cập nhật công việc', 'Công việc: Báo cáo của 10 tập đoàn lớn tại Việt Nam vừa được cập nhật mới', 14, 'Cập nhật', 0, '2025-11-14 02:22:44', '2025-11-14 02:22:44'),
(548, 'Thêm mới quy trình', 'Công việc: Bổ sung gói đào tạo 2 ngày, lên báo giá và các công việc triển khai vừa được thêm quy trình mới', 11, 'Cập nhật', 0, '2025-11-14 02:28:11', '2025-11-14 02:28:11'),
(549, 'Cập nhật công việc', 'Công việc: Bổ sung gói đào tạo 2 ngày, lên báo giá và các công việc triển khai vừa được cập nhật mới', 11, 'Cập nhật', 0, '2025-11-14 02:28:16', '2025-11-14 02:28:16'),
(550, 'Cập nhật công việc', 'Công việc: Bổ sung gói đào tạo 2 ngày, lên báo giá và các công việc triển khai vừa được cập nhật mới', 11, 'Cập nhật', 0, '2025-11-14 02:29:03', '2025-11-14 02:29:03'),
(551, 'Cập nhật quy trình', 'Công việc: Bổ sung gói đào tạo 2 ngày, lên báo giá và các công việc triển khai vừa được cập nhật quy trình mới', 11, 'Cập nhật', 0, '2025-11-14 02:29:10', '2025-11-14 02:29:10'),
(552, 'Cập nhật công việc', 'Công việc: Bổ sung gói đào tạo 2 ngày, lên báo giá và các công việc triển khai vừa được cập nhật mới', 11, 'Cập nhật', 0, '2025-11-14 02:29:12', '2025-11-14 02:29:12'),
(553, 'Thêm mới quy trình', 'Công việc: Đốc thúc đội marketing tư vấn các gói đào tạo vừa được thêm quy trình mới', 11, 'Cập nhật', 0, '2025-11-14 02:30:53', '2025-11-14 02:30:53'),
(554, 'Cập nhật công việc', 'Công việc: Đốc thúc đội marketing tư vấn các gói đào tạo vừa được cập nhật mới', 11, 'Cập nhật', 0, '2025-11-14 02:30:55', '2025-11-14 02:30:55'),
(555, 'Thêm mới quy trình', 'Công việc: Làm việc với a Bình BIDV vừa được thêm quy trình mới', 11, 'Cập nhật', 0, '2025-11-14 02:31:15', '2025-11-14 02:31:15'),
(556, 'Cập nhật công việc', 'Công việc: Làm việc với a Bình BIDV vừa được cập nhật mới', 11, 'Cập nhật', 0, '2025-11-14 02:31:20', '2025-11-14 02:31:20'),
(557, 'Thêm mới quy trình', 'Công việc: Lên phương án hợp tác với TPX vừa được thêm quy trình mới', 11, 'Cập nhật', 0, '2025-11-14 02:31:32', '2025-11-14 02:31:32'),
(558, 'Cập nhật công việc', 'Công việc: Lên phương án hợp tác với TPX vừa được cập nhật mới', 11, 'Cập nhật', 0, '2025-11-14 02:31:40', '2025-11-14 02:31:40'),
(559, 'Thêm mới quy trình', 'Công việc: Hoàn thiện các chức năng quản lý dự án theo các qui trình  vừa được thêm quy trình mới', 21, 'Cập nhật', 0, '2025-11-14 02:32:01', '2025-11-14 02:32:01'),
(560, 'Cập nhật quy trình', 'Công việc: Làm việc với Hyper G để xin tài liệu đào tạo kĩ thuật vừa được cập nhật quy trình mới', 3, 'Cập nhật', 0, '2025-11-14 02:32:37', '2025-11-14 02:32:37'),
(561, 'Cập nhật quy trình', 'Công việc: Làm việc với Hyper G để xin tài liệu đào tạo kĩ thuật vừa được cập nhật quy trình mới', 3, 'Cập nhật', 0, '2025-11-14 02:32:41', '2025-11-14 02:32:41'),
(562, 'Cập nhật công việc', 'Công việc: Làm việc với Hyper G để xin tài liệu đào tạo kĩ thuật vừa được cập nhật mới', 3, 'Cập nhật', 0, '2025-11-14 02:32:42', '2025-11-14 02:32:42'),
(563, 'Cập nhật quy trình', 'Công việc: Đào tạo sale cho nhân viên công ty vừa được cập nhật quy trình mới', 11, 'Cập nhật', 0, '2025-11-14 02:32:51', '2025-11-14 02:32:51'),
(564, 'Cập nhật quy trình', 'Công việc: Đào tạo sale cho nhân viên công ty vừa được cập nhật quy trình mới', 11, 'Cập nhật', 0, '2025-11-14 02:32:54', '2025-11-14 02:32:54'),
(565, 'Cập nhật quy trình', 'Công việc: các bạn kỹ thuật nghiên cứu làm các dashboard cơ bản vừa được cập nhật quy trình mới', 8, 'Cập nhật', 0, '2025-11-14 02:33:10', '2025-11-14 02:33:10'),
(566, 'Cập nhật quy trình', 'Công việc: các bạn kỹ thuật nghiên cứu làm các dashboard cơ bản vừa được cập nhật quy trình mới', 6, 'Cập nhật', 0, '2025-11-14 02:33:10', '2025-11-14 02:33:10'),
(567, 'Cập nhật quy trình', 'Công việc: các bạn kỹ thuật nghiên cứu làm các dashboard cơ bản vừa được cập nhật quy trình mới', 8, 'Cập nhật', 0, '2025-11-14 02:33:13', '2025-11-14 02:33:13'),
(568, 'Cập nhật quy trình', 'Công việc: các bạn kỹ thuật nghiên cứu làm các dashboard cơ bản vừa được cập nhật quy trình mới', 6, 'Cập nhật', 0, '2025-11-14 02:33:13', '2025-11-14 02:33:13'),
(569, 'Cập nhật quy trình', 'Công việc: các bạn kỹ thuật nghiên cứu làm các dashboard cơ bản vừa được cập nhật quy trình mới', 8, 'Cập nhật', 0, '2025-11-14 02:33:17', '2025-11-14 02:33:17'),
(570, 'Cập nhật quy trình', 'Công việc: các bạn kỹ thuật nghiên cứu làm các dashboard cơ bản vừa được cập nhật quy trình mới', 6, 'Cập nhật', 0, '2025-11-14 02:33:17', '2025-11-14 02:33:17'),
(571, 'Cập nhật quy trình', 'Công việc: Chốt thời gian chuyển giao các sản phẩm của Hyper-G vừa được cập nhật quy trình mới', 17, 'Cập nhật', 0, '2025-11-14 02:33:31', '2025-11-14 02:33:31'),
(572, 'Cập nhật quy trình', 'Công việc: Chốt thời gian chuyển giao các sản phẩm của Hyper-G vừa được cập nhật quy trình mới', 14, 'Cập nhật', 0, '2025-11-14 02:33:31', '2025-11-14 02:33:31'),
(573, 'Cập nhật quy trình', 'Công việc: Chốt thời gian chuyển giao các sản phẩm của Hyper-G vừa được cập nhật quy trình mới', 3, 'Cập nhật', 0, '2025-11-14 02:33:31', '2025-11-14 02:33:31'),
(574, 'Cập nhật quy trình', 'Công việc: Chốt thời gian chuyển giao các sản phẩm của Hyper-G vừa được cập nhật quy trình mới', 21, 'Cập nhật', 0, '2025-11-14 02:33:31', '2025-11-14 02:33:31'),
(575, 'Cập nhật quy trình', 'Công việc: Chốt thời gian chuyển giao các sản phẩm của Hyper-G vừa được cập nhật quy trình mới', 8, 'Cập nhật', 0, '2025-11-14 02:33:31', '2025-11-14 02:33:31'),
(576, 'Cập nhật quy trình', 'Công việc: Chốt thời gian chuyển giao các sản phẩm của Hyper-G vừa được cập nhật quy trình mới', 5, 'Cập nhật', 0, '2025-11-14 02:33:31', '2025-11-14 02:33:31'),
(577, 'Cập nhật quy trình', 'Công việc: Chốt thời gian chuyển giao các sản phẩm của Hyper-G vừa được cập nhật quy trình mới', 6, 'Cập nhật', 0, '2025-11-14 02:33:31', '2025-11-14 02:33:31'),
(578, 'Cập nhật công việc', 'Công việc: Chốt thời gian chuyển giao các sản phẩm của Hyper-G vừa được cập nhật mới', 17, 'Cập nhật', 0, '2025-11-14 02:33:34', '2025-11-14 02:33:34'),
(579, 'Cập nhật công việc', 'Công việc: Chốt thời gian chuyển giao các sản phẩm của Hyper-G vừa được cập nhật mới', 14, 'Cập nhật', 0, '2025-11-14 02:33:34', '2025-11-14 02:33:34'),
(580, 'Cập nhật công việc', 'Công việc: Chốt thời gian chuyển giao các sản phẩm của Hyper-G vừa được cập nhật mới', 3, 'Cập nhật', 0, '2025-11-14 02:33:34', '2025-11-14 02:33:34'),
(581, 'Cập nhật công việc', 'Công việc: Chốt thời gian chuyển giao các sản phẩm của Hyper-G vừa được cập nhật mới', 21, 'Cập nhật', 0, '2025-11-14 02:33:34', '2025-11-14 02:33:34'),
(582, 'Cập nhật công việc', 'Công việc: Chốt thời gian chuyển giao các sản phẩm của Hyper-G vừa được cập nhật mới', 8, 'Cập nhật', 0, '2025-11-14 02:33:34', '2025-11-14 02:33:34'),
(583, 'Cập nhật công việc', 'Công việc: Chốt thời gian chuyển giao các sản phẩm của Hyper-G vừa được cập nhật mới', 5, 'Cập nhật', 0, '2025-11-14 02:33:34', '2025-11-14 02:33:34'),
(584, 'Cập nhật công việc', 'Công việc: Chốt thời gian chuyển giao các sản phẩm của Hyper-G vừa được cập nhật mới', 6, 'Cập nhật', 0, '2025-11-14 02:33:34', '2025-11-14 02:33:34'),
(585, 'Cập nhật quy trình', 'Công việc: Hoàn thiện các gói tư vấn ATTT cấp độ, đánh giá hệ thống, xây dựng các gói đào tạo nhận thức, đào tạo chuyên sâu. vừa được cập nhật quy trình mới', 14, 'Cập nhật', 0, '2025-11-14 02:33:42', '2025-11-14 02:33:42'),
(586, 'Cập nhật quy trình', 'Công việc: Hoàn thiện các gói tư vấn ATTT cấp độ, đánh giá hệ thống, xây dựng các gói đào tạo nhận thức, đào tạo chuyên sâu. vừa được cập nhật quy trình mới', 6, 'Cập nhật', 0, '2025-11-14 02:33:42', '2025-11-14 02:33:42'),
(587, 'Cập nhật công việc', 'Công việc: Hoàn thiện các gói tư vấn ATTT cấp độ, đánh giá hệ thống, xây dựng các gói đào tạo nhận thức, đào tạo chuyên sâu. vừa được cập nhật mới', 14, 'Cập nhật', 0, '2025-11-14 02:33:46', '2025-11-14 02:33:46'),
(588, 'Cập nhật công việc', 'Công việc: Hoàn thiện các gói tư vấn ATTT cấp độ, đánh giá hệ thống, xây dựng các gói đào tạo nhận thức, đào tạo chuyên sâu. vừa được cập nhật mới', 6, 'Cập nhật', 0, '2025-11-14 02:33:46', '2025-11-14 02:33:46'),
(589, 'Thêm mới quy trình', 'Công việc: Hoàn thiện cá chức năng của trang web oracle vừa được thêm quy trình mới', 6, 'Cập nhật', 0, '2025-11-14 02:34:07', '2025-11-14 02:34:07'),
(590, 'Thêm mới quy trình', 'Công việc: Tham gia sự kiện tại Hòa Lạc vừa được thêm quy trình mới', 11, 'Cập nhật', 0, '2025-11-14 02:34:26', '2025-11-14 02:34:26'),
(591, 'Cập nhật công việc', 'Công việc: Tham gia sự kiện tại Hòa Lạc vừa được cập nhật mới', 11, 'Cập nhật', 0, '2025-11-14 02:34:27', '2025-11-14 02:34:27'),
(592, 'Cập nhật quy trình', 'Công việc: Tham gia sự kiện tại Hòa Lạc vừa được cập nhật quy trình mới', 11, 'Cập nhật', 0, '2025-11-14 02:34:38', '2025-11-14 02:34:38'),
(593, 'Thêm mới quy trình', 'Công việc: Làm việc với Luxtech xây dựng kế hoạch đi tỉnh vừa được thêm quy trình mới', 11, 'Cập nhật', 0, '2025-11-14 02:34:57', '2025-11-14 02:34:57'),
(594, 'Cập nhật công việc', 'Công việc: Làm việc với Luxtech xây dựng kế hoạch đi tỉnh vừa được cập nhật mới', 11, 'Cập nhật', 0, '2025-11-14 02:35:02', '2025-11-14 02:35:02'),
(595, 'Thêm mới quy trình', 'Công việc: Tư vấn giải pháp Dashboard cho a Đỉnh vừa được thêm quy trình mới', 11, 'Cập nhật', 0, '2025-11-14 02:35:28', '2025-11-14 02:35:28'),
(596, 'Cập nhật công việc', 'Công việc: Tư vấn giải pháp Dashboard cho a Đỉnh vừa được cập nhật mới', 11, 'Cập nhật', 0, '2025-11-14 02:35:33', '2025-11-14 02:35:33'),
(597, 'Thêm mới quy trình', 'Công việc: Làm việc với a Tùng Gtel vừa được thêm quy trình mới', 11, 'Cập nhật', 0, '2025-11-14 02:35:43', '2025-11-14 02:35:43'),
(598, 'Cập nhật công việc', 'Công việc: Làm việc với a Tùng Gtel vừa được cập nhật mới', 11, 'Cập nhật', 0, '2025-11-14 02:35:47', '2025-11-14 02:35:47'),
(599, 'Thêm mới quy trình', 'Công việc: Đốc thúc Pacisoft lên báo giá cho dự án Database vừa được thêm quy trình mới', 11, 'Cập nhật', 0, '2025-11-14 02:35:58', '2025-11-14 02:35:58'),
(600, 'Cập nhật công việc', 'Công việc: Đốc thúc Pacisoft lên báo giá cho dự án Database vừa được cập nhật mới', 11, 'Cập nhật', 0, '2025-11-14 02:36:02', '2025-11-14 02:36:02'),
(601, 'Thêm mới quy trình', 'Công việc: Làm việc lại với Mobifone vừa được thêm quy trình mới', 11, 'Cập nhật', 0, '2025-11-14 02:36:15', '2025-11-14 02:36:15'),
(602, 'Cập nhật công việc', 'Công việc: Làm việc lại với Mobifone vừa được cập nhật mới', 11, 'Cập nhật', 0, '2025-11-14 02:36:19', '2025-11-14 02:36:19'),
(603, 'Thêm mới quy trình', 'Công việc: Lên kế hoạch Qúy IV vừa được thêm quy trình mới', 11, 'Cập nhật', 0, '2025-11-14 02:36:40', '2025-11-14 02:36:40'),
(604, 'Cập nhật công việc', 'Công việc: Lên kế hoạch Qúy IV vừa được cập nhật mới', 11, 'Cập nhật', 0, '2025-11-14 02:36:44', '2025-11-14 02:36:44'),
(605, 'Thêm mới quy trình', 'Công việc: Tìm SĐT của danh sách khách hàng vừa được thêm quy trình mới', 11, 'Cập nhật', 0, '2025-11-14 02:36:58', '2025-11-14 02:36:58'),
(606, 'Cập nhật công việc', 'Công việc: Tìm SĐT của danh sách khách hàng vừa được cập nhật mới', 11, 'Cập nhật', 0, '2025-11-14 02:36:59', '2025-11-14 02:36:59'),
(607, 'Cập nhật quy trình', 'Công việc: Tìm SĐT của danh sách khách hàng vừa được cập nhật quy trình mới', 11, 'Cập nhật', 0, '2025-11-14 02:37:05', '2025-11-14 02:37:05'),
(608, 'Cập nhật công việc', 'Công việc: Tìm SĐT của danh sách khách hàng vừa được cập nhật mới', 11, 'Cập nhật', 0, '2025-11-14 02:37:06', '2025-11-14 02:37:06'),
(609, 'Thêm mới quy trình', 'Công việc: suppor Gpay làm việc với Hanpass và Gamapay vừa được thêm quy trình mới', 10, 'Cập nhật', 0, '2025-11-14 02:37:18', '2025-11-14 02:37:18'),
(610, 'Cập nhật công việc', 'Công việc: suppor Gpay làm việc với Hanpass và Gamapay vừa được cập nhật mới', 10, 'Cập nhật', 0, '2025-11-14 02:37:20', '2025-11-14 02:37:20'),
(611, 'Thêm mới quy trình', 'Công việc: Soạn hợp đồng với phường Đồ Sơn vừa được thêm quy trình mới', 10, 'Cập nhật', 0, '2025-11-14 02:37:33', '2025-11-14 02:37:33'),
(612, 'Cập nhật công việc', 'Công việc: Soạn hợp đồng với phường Đồ Sơn vừa được cập nhật mới', 10, 'Cập nhật', 0, '2025-11-14 02:37:38', '2025-11-14 02:37:38'),
(613, 'Thêm mới quy trình', 'Công việc: Tuyển dụng thực tập sinh và nhân sự đề nghị vừa được thêm quy trình mới', 12, 'Cập nhật', 0, '2025-11-14 02:37:52', '2025-11-14 02:37:52'),
(614, 'Cập nhật công việc', 'Công việc: Tuyển dụng thực tập sinh và nhân sự đề nghị vừa được cập nhật mới', 12, 'Cập nhật', 0, '2025-11-14 02:37:56', '2025-11-14 02:37:56'),
(615, 'Cập nhật quy trình', 'Công việc: Làm việc với a Bình BIDV vừa được cập nhật quy trình mới', 11, 'Cập nhật', 0, '2025-11-14 02:45:09', '2025-11-14 02:45:09'),
(616, 'Cập nhật công việc', 'Công việc: Làm việc với a Bình BIDV vừa được cập nhật mới', 11, 'Cập nhật', 0, '2025-11-14 02:45:12', '2025-11-14 02:45:12'),
(617, 'Cập nhật quy trình', 'Công việc: HyperG bàn giao AI SOC vừa được cập nhật quy trình mới', 24, 'Cập nhật', 0, '2025-11-14 02:49:28', '2025-11-14 02:49:28'),
(618, 'Cập nhật quy trình', 'Công việc: HyperG bàn giao AI SOC vừa được cập nhật quy trình mới', 6, 'Cập nhật', 0, '2025-11-14 02:49:28', '2025-11-14 02:49:28'),
(619, 'Cập nhật quy trình', 'Công việc: HyperG bàn giao AI SOC vừa được cập nhật quy trình mới', 24, 'Cập nhật', 0, '2025-11-14 02:49:41', '2025-11-14 02:49:41'),
(620, 'Cập nhật quy trình', 'Công việc: HyperG bàn giao AI SOC vừa được cập nhật quy trình mới', 6, 'Cập nhật', 0, '2025-11-14 02:49:42', '2025-11-14 02:49:42'),
(621, 'Cập nhật công việc', 'Công việc: Hoàn thiện các chức năng quản lý dự án theo các qui trình  vừa được cập nhật mới', 21, 'Cập nhật', 0, '2025-11-14 02:56:26', '2025-11-14 02:56:26'),
(622, 'Cập nhật công việc', 'Công việc: Bổ sung gói đào tạo 2 ngày, lên báo giá và các công việc triển khai vừa được cập nhật mới', 11, 'Cập nhật', 0, '2025-11-14 02:56:52', '2025-11-14 02:56:52'),
(623, 'Công việc mới', 'Bạn được giao công việc: Xuất hóa đơn HyperG - Cathay. Hạn: 2025-11-19.', 10, 'Công việc mới', 0, '2025-11-14 06:13:09', '2025-11-14 06:13:09'),
(624, 'Công việc mới', 'Bạn được giao công việc: Xuất hóa đơn HyperG - Cathay. Hạn: 2025-11-19.', 7, 'Công việc mới', 0, '2025-11-14 06:13:09', '2025-11-14 06:13:09'),
(625, 'Thêm mới quy trình', 'Công việc: Xuất hóa đơn HyperG - Cathay vừa được thêm quy trình mới', 10, 'Cập nhật', 0, '2025-11-14 06:13:42', '2025-11-14 06:13:42'),
(626, 'Thêm mới quy trình', 'Công việc: Xuất hóa đơn HyperG - Cathay vừa được thêm quy trình mới', 7, 'Cập nhật', 0, '2025-11-14 06:13:42', '2025-11-14 06:13:42'),
(627, 'Thêm mới quy trình', 'Công việc: Xuất hóa đơn HyperG - Cathay vừa được thêm quy trình mới', 10, 'Cập nhật', 0, '2025-11-14 06:13:55', '2025-11-14 06:13:55'),
(628, 'Thêm mới quy trình', 'Công việc: Xuất hóa đơn HyperG - Cathay vừa được thêm quy trình mới', 7, 'Cập nhật', 0, '2025-11-14 06:13:55', '2025-11-14 06:13:55'),
(629, 'Cập nhật công việc', 'Công việc: Xuất hóa đơn HyperG - Cathay vừa được cập nhật mới', 10, 'Cập nhật', 0, '2025-11-14 06:13:58', '2025-11-14 06:13:58'),
(630, 'Cập nhật công việc', 'Công việc: Xuất hóa đơn HyperG - Cathay vừa được cập nhật mới', 7, 'Cập nhật', 0, '2025-11-14 06:13:58', '2025-11-14 06:13:58');
INSERT INTO `thong_bao` (`id`, `tieu_de`, `noi_dung`, `nguoi_nhan_id`, `loai_thong_bao`, `da_doc`, `ngay_doc`, `ngay_tao`) VALUES
(631, 'Cập nhật công việc', 'Công việc: Bán được 5 gói đào tạo về AI vừa được cập nhật mới', 11, 'Cập nhật', 0, '2025-11-14 07:03:27', '2025-11-14 07:03:27'),
(632, 'Cập nhật công việc', 'Công việc: Bán được 5 gói đào tạo về AI vừa được cập nhật mới', 11, 'Cập nhật', 0, '2025-11-14 07:03:45', '2025-11-14 07:03:45'),
(633, 'Cập nhật công việc', 'Công việc: Bán được 5 gói đào tạo về AI vừa được cập nhật mới', 11, 'Cập nhật', 0, '2025-11-14 07:04:23', '2025-11-14 07:04:23'),
(634, 'Cập nhật công việc', 'Công việc: Bán được 5 gói đào tạo về AI vừa được cập nhật mới', 10, 'Cập nhật', 0, '2025-11-14 07:04:23', '2025-11-14 07:04:23'),
(635, 'Công việc mới', 'Bạn được giao công việc: lên file quản lý dự án Agribank. Hạn: 2025-11-17.', 11, 'Công việc mới', 0, '2025-11-17 01:08:49', '2025-11-17 01:08:49'),
(636, 'Cập nhật công việc', 'Công việc: lên file quản lý dự án Agribank vừa được cập nhật mới', 11, 'Cập nhật', 0, '2025-11-17 01:09:16', '2025-11-17 01:09:16'),
(637, 'Cập nhật công việc', 'Công việc: Lên chương trình đào tạo cho BIDV vừa được cập nhật mới', 11, 'Cập nhật', 0, '2025-11-17 01:12:35', '2025-11-17 01:12:35'),
(638, 'Cập nhật công việc', 'Công việc: lên file quản lý dự án Agribank vừa được cập nhật mới', 11, 'Cập nhật', 0, '2025-11-17 01:13:07', '2025-11-17 01:13:07'),
(639, 'Cập nhật công việc', 'Công việc: Lên chương trình đào tạo cho BIDV vừa được cập nhật mới', 11, 'Cập nhật', 0, '2025-11-17 01:13:17', '2025-11-17 01:13:17'),
(640, 'Thêm mới quy trình', 'Công việc: Lên chương trình đào tạo cho BIDV vừa được thêm quy trình mới', 11, 'Cập nhật', 0, '2025-11-17 01:13:52', '2025-11-17 01:13:52'),
(641, 'Cập nhật công việc', 'Công việc: Lên chương trình đào tạo cho BIDV vừa được cập nhật mới', 11, 'Cập nhật', 0, '2025-11-17 01:13:55', '2025-11-17 01:13:55'),
(642, 'Cập nhật quy trình', 'Công việc: Lên chương trình đào tạo cho BIDV vừa được cập nhật quy trình mới', 11, 'Cập nhật', 0, '2025-11-17 01:14:13', '2025-11-17 01:14:13'),
(643, 'Cập nhật công việc', 'Công việc: Lên chương trình đào tạo cho BIDV vừa được cập nhật mới', 11, 'Cập nhật', 0, '2025-11-17 01:14:15', '2025-11-17 01:14:15'),
(644, 'Thêm mới quy trình', 'Công việc: lên file quản lý dự án Agribank vừa được thêm quy trình mới', 11, 'Cập nhật', 0, '2025-11-17 01:14:47', '2025-11-17 01:14:47'),
(645, 'Cập nhật công việc', 'Công việc: lên file quản lý dự án Agribank vừa được cập nhật mới', 11, 'Cập nhật', 0, '2025-11-17 01:14:50', '2025-11-17 01:14:50'),
(646, 'Cập nhật quy trình', 'Công việc: lên file quản lý dự án Agribank vừa được cập nhật quy trình mới', 11, 'Cập nhật', 0, '2025-11-17 01:15:15', '2025-11-17 01:15:15'),
(647, 'Cập nhật công việc', 'Công việc: lên file quản lý dự án Agribank vừa được cập nhật mới', 11, 'Cập nhật', 0, '2025-11-17 01:15:20', '2025-11-17 01:15:20'),
(648, 'Thêm mới quy trình', 'Công việc: Tiếp tục hoàn thiện web Oracle, ghép API bella vừa được thêm quy trình mới', 8, 'Cập nhật', 0, '2025-11-17 01:43:47', '2025-11-17 01:43:47'),
(649, 'Thêm mới quy trình', 'Công việc: Phutraco: Web - Nghiên cứu và lập bản phương án làm, phương án triển khai (trên cloud, cấu trúc) và ước lượng chi phí (hàng tháng). Làm thêm demo minh họa vừa được thêm quy trình mới', 8, 'Cập nhật', 0, '2025-11-17 01:46:31', '2025-11-17 01:46:31'),
(650, 'Thêm mới quy trình', 'Công việc: ICSS: Web giới thiệu - Làm lại trang UI trang chủ cho chuyên nghiệp (tham khảo CISCO) vừa được thêm quy trình mới', 8, 'Cập nhật', 0, '2025-11-17 01:46:51', '2025-11-17 01:46:51'),
(651, 'Thêm mới quy trình', 'Công việc: Oracle: Chức năng xác thực mail khi đăng ký vừa được thêm quy trình mới', 8, 'Cập nhật', 0, '2025-11-17 01:47:00', '2025-11-17 01:47:00'),
(652, 'Thêm mới quy trình', 'Công việc: Oracle: Thêm bộ đếm lượt truy cập vừa được thêm quy trình mới', 8, 'Cập nhật', 0, '2025-11-17 01:47:13', '2025-11-17 01:47:13'),
(653, 'Thêm mới quy trình', 'Công việc: Update Oracle Cloud theo trao đổi với HyperG vừa được thêm quy trình mới', 8, 'Cập nhật', 0, '2025-11-17 01:48:02', '2025-11-17 01:48:02'),
(654, 'Thêm mới quy trình', 'Công việc: Oracle: Chức năng đăng nhập bằng Google vừa được thêm quy trình mới', 8, 'Cập nhật', 0, '2025-11-17 01:48:16', '2025-11-17 01:48:16'),
(655, 'Thêm mới quy trình', 'Công việc: Oracle: Chức năng quên mật khẩu => Gửi mail reset mật khẩu vừa được thêm quy trình mới', 8, 'Cập nhật', 0, '2025-11-17 01:48:35', '2025-11-17 01:48:35'),
(656, 'Thêm mới quy trình', 'Công việc: Tìm kiếm đối tác và liên hệ lắp thêm đường internet mới chạy AI SOC vừa được thêm quy trình mới', 25, 'Cập nhật', 0, '2025-11-17 01:48:52', '2025-11-17 01:48:52'),
(657, 'Thêm mới quy trình', 'Công việc: Thêm xem theo tuần, tháng tổng hợp công việc trang HRM vừa được thêm quy trình mới', 25, 'Cập nhật', 0, '2025-11-17 01:49:01', '2025-11-17 01:49:01'),
(658, 'Thêm mới quy trình', 'Công việc: Thêm phần gửi danh sách hoặc lí do checkin hoặc checkout muộn vừa được thêm quy trình mới', 25, 'Cập nhật', 0, '2025-11-17 01:49:46', '2025-11-17 01:49:46'),
(659, 'Cập nhật công việc', 'Công việc: Chốt thời gian chuyển giao các sản phẩm của Hyper-G vừa được cập nhật mới', 17, 'Cập nhật', 0, '2025-11-17 01:49:47', '2025-11-17 01:49:47'),
(660, 'Cập nhật công việc', 'Công việc: Chốt thời gian chuyển giao các sản phẩm của Hyper-G vừa được cập nhật mới', 14, 'Cập nhật', 0, '2025-11-17 01:49:47', '2025-11-17 01:49:47'),
(661, 'Cập nhật công việc', 'Công việc: Chốt thời gian chuyển giao các sản phẩm của Hyper-G vừa được cập nhật mới', 3, 'Cập nhật', 0, '2025-11-17 01:49:47', '2025-11-17 01:49:47'),
(662, 'Cập nhật công việc', 'Công việc: Chốt thời gian chuyển giao các sản phẩm của Hyper-G vừa được cập nhật mới', 21, 'Cập nhật', 0, '2025-11-17 01:49:48', '2025-11-17 01:49:48'),
(663, 'Cập nhật công việc', 'Công việc: Chốt thời gian chuyển giao các sản phẩm của Hyper-G vừa được cập nhật mới', 8, 'Cập nhật', 0, '2025-11-17 01:49:48', '2025-11-17 01:49:48'),
(664, 'Cập nhật công việc', 'Công việc: Chốt thời gian chuyển giao các sản phẩm của Hyper-G vừa được cập nhật mới', 5, 'Cập nhật', 0, '2025-11-17 01:49:48', '2025-11-17 01:49:48'),
(665, 'Cập nhật công việc', 'Công việc: Chốt thời gian chuyển giao các sản phẩm của Hyper-G vừa được cập nhật mới', 6, 'Cập nhật', 0, '2025-11-17 01:49:48', '2025-11-17 01:49:48'),
(666, 'Thêm mới quy trình', 'Công việc: Sửa lại phần thống kê báo cáo đang bị sai logic về % hoàn thành công việc vừa được thêm quy trình mới', 25, 'Cập nhật', 0, '2025-11-17 01:50:04', '2025-11-17 01:50:04'),
(667, 'Thêm mới quy trình', 'Công việc: Sửa lại phần dự án có thể giao việc cho các nhân viên của tất cả các phòng vừa được thêm quy trình mới', 25, 'Cập nhật', 0, '2025-11-17 01:50:15', '2025-11-17 01:50:15'),
(668, 'Thêm mới quy trình', 'Công việc: Thêm dự án cá nhân có thể thêm list công việc dự án cho từng cá nhân vừa được thêm quy trình mới', 25, 'Cập nhật', 0, '2025-11-17 01:50:26', '2025-11-17 01:50:26'),
(669, 'Thêm mới quy trình', 'Công việc: Web HyperG ( Kết nối API web tổng và web con ) vừa được thêm quy trình mới', 24, 'Cập nhật', 0, '2025-11-17 01:50:52', '2025-11-17 01:50:52'),
(670, 'Thêm mới quy trình', 'Công việc: Web HyperG kiểm tra toàn bộ frontend và gửi HyperG check vừa được thêm quy trình mới', 24, 'Cập nhật', 0, '2025-11-17 01:51:02', '2025-11-17 01:51:02'),
(671, 'Thêm mới quy trình', 'Công việc: Web HyperG đẩy web lên Server hệ thống để chạy vừa được thêm quy trình mới', 24, 'Cập nhật', 0, '2025-11-17 01:51:13', '2025-11-17 01:51:13'),
(672, 'Thêm mới quy trình', 'Công việc: Hoàn thiện Dashboard Sales vừa được thêm quy trình mới', 24, 'Cập nhật', 0, '2025-11-17 01:51:41', '2025-11-17 01:51:41'),
(673, 'Thêm mới quy trình', 'Công việc: Hoàn thiện backend Dashboard đi thi A05 vừa được thêm quy trình mới', 24, 'Cập nhật', 0, '2025-11-17 01:51:51', '2025-11-17 01:51:51'),
(674, 'Thêm mới quy trình', 'Công việc: Triển khai CSA, lấy list danh sách web nhân viên sử dụng vừa được thêm quy trình mới', 24, 'Cập nhật', 0, '2025-11-17 01:52:03', '2025-11-17 01:52:03'),
(675, 'Thêm mới quy trình', 'Công việc: Kết quả báo cáo của 6 ngân hàng vừa được thêm quy trình mới', 24, 'Cập nhật', 0, '2025-11-17 01:52:18', '2025-11-17 01:52:18'),
(676, 'Thêm mới quy trình', 'Công việc: VietGuard đổi logo và chỉnh mã nguồn đúng tên VietGuard vừa được thêm quy trình mới', 24, 'Cập nhật', 0, '2025-11-17 01:52:34', '2025-11-17 01:52:34'),
(677, 'Thêm mới quy trình', 'Công việc: Báo cáo kết quả CSA chạy trên windows, Linux Server ( hiệu suất. tỉ lệ nhanh chậm) vừa được thêm quy trình mới', 24, 'Cập nhật', 0, '2025-11-17 01:52:46', '2025-11-17 01:52:46'),
(678, 'Thêm mới quy trình', 'Công việc: AI SOC đánh giá hồ sơ đăng ký dịch vụ an ninh mạng ( sản phẩm ) vừa được thêm quy trình mới', 24, 'Cập nhật', 0, '2025-11-17 01:52:57', '2025-11-17 01:52:57'),
(679, 'Thêm mới quy trình', 'Công việc: Làm lại số hotline cho facebook, zalo và các trang mạng xã hội của cty vừa được thêm quy trình mới', 7, 'Cập nhật', 0, '2025-11-17 01:53:31', '2025-11-17 01:53:31'),
(680, 'Thêm mới quy trình', 'Công việc: Oracle cloud: Ký hợp đồng với 3C vừa được thêm quy trình mới', 11, 'Cập nhật', 0, '2025-11-17 01:53:46', '2025-11-17 01:53:46'),
(681, 'Thêm mới quy trình', 'Công việc: Trong tháng 9 đến giữa tháng 10 phải bán được 1 Dashboard vừa được thêm quy trình mới', 11, 'Cập nhật', 0, '2025-11-17 01:54:01', '2025-11-17 01:54:01'),
(682, 'Thêm mới quy trình', 'Công việc: Bán được 5 gói đào tạo về AI vừa được thêm quy trình mới', 11, 'Cập nhật', 0, '2025-11-17 01:54:14', '2025-11-17 01:54:14'),
(683, 'Thêm mới quy trình', 'Công việc: Bán được 5 gói đào tạo về AI vừa được thêm quy trình mới', 10, 'Cập nhật', 0, '2025-11-17 01:54:14', '2025-11-17 01:54:14'),
(684, 'Cập nhật quy trình', 'Công việc: Tìm kiếm đối tác và liên hệ lắp thêm đường internet mới chạy AI SOC vừa được cập nhật quy trình mới', 25, 'Cập nhật', 0, '2025-11-17 01:54:55', '2025-11-17 01:54:55'),
(685, 'Cập nhật công việc', 'Công việc: Tìm kiếm đối tác và liên hệ lắp thêm đường internet mới chạy AI SOC vừa được cập nhật mới', 25, 'Cập nhật', 0, '2025-11-17 01:54:56', '2025-11-17 01:54:56'),
(686, 'Cập nhật quy trình', 'Công việc: Thêm xem theo tuần, tháng tổng hợp công việc trang HRM vừa được cập nhật quy trình mới', 25, 'Cập nhật', 0, '2025-11-17 01:55:09', '2025-11-17 01:55:09'),
(687, 'Cập nhật công việc', 'Công việc: Thêm xem theo tuần, tháng tổng hợp công việc trang HRM vừa được cập nhật mới', 25, 'Cập nhật', 0, '2025-11-17 01:55:10', '2025-11-17 01:55:10'),
(688, 'Cập nhật quy trình', 'Công việc: Thêm phần gửi danh sách hoặc lí do checkin hoặc checkout muộn vừa được cập nhật quy trình mới', 25, 'Cập nhật', 0, '2025-11-17 01:55:19', '2025-11-17 01:55:19'),
(689, 'Cập nhật công việc', 'Công việc: Thêm phần gửi danh sách hoặc lí do checkin hoặc checkout muộn vừa được cập nhật mới', 25, 'Cập nhật', 0, '2025-11-17 01:55:20', '2025-11-17 01:55:20'),
(690, 'Cập nhật quy trình', 'Công việc: Thêm dự án cá nhân có thể thêm list công việc dự án cho từng cá nhân vừa được cập nhật quy trình mới', 25, 'Cập nhật', 0, '2025-11-17 01:55:28', '2025-11-17 01:55:28'),
(691, 'Cập nhật công việc', 'Công việc: Thêm dự án cá nhân có thể thêm list công việc dự án cho từng cá nhân vừa được cập nhật mới', 25, 'Cập nhật', 0, '2025-11-17 01:55:29', '2025-11-17 01:55:29'),
(692, 'Cập nhật quy trình', 'Công việc: Sửa lại phần dự án có thể giao việc cho các nhân viên của tất cả các phòng vừa được cập nhật quy trình mới', 25, 'Cập nhật', 0, '2025-11-17 01:55:42', '2025-11-17 01:55:42'),
(693, 'Cập nhật công việc', 'Công việc: Sửa lại phần dự án có thể giao việc cho các nhân viên của tất cả các phòng vừa được cập nhật mới', 25, 'Cập nhật', 0, '2025-11-17 01:55:43', '2025-11-17 01:55:43'),
(694, 'Cập nhật quy trình', 'Công việc: Sửa lại phần thống kê báo cáo đang bị sai logic về % hoàn thành công việc vừa được cập nhật quy trình mới', 25, 'Cập nhật', 0, '2025-11-17 01:55:52', '2025-11-17 01:55:52'),
(695, 'Cập nhật công việc', 'Công việc: Sửa lại phần thống kê báo cáo đang bị sai logic về % hoàn thành công việc vừa được cập nhật mới', 25, 'Cập nhật', 0, '2025-11-17 01:55:53', '2025-11-17 01:55:53'),
(696, 'Cập nhật quy trình', 'Công việc: AI SOC đánh giá hồ sơ đăng ký dịch vụ an ninh mạng ( sản phẩm ) vừa được cập nhật quy trình mới', 24, 'Cập nhật', 0, '2025-11-17 02:04:29', '2025-11-17 02:04:29'),
(697, 'Cập nhật quy trình', 'Công việc: Báo cáo kết quả CSA chạy trên windows, Linux Server ( hiệu suất. tỉ lệ nhanh chậm) vừa được cập nhật quy trình mới', 24, 'Cập nhật', 0, '2025-11-17 02:04:41', '2025-11-17 02:04:41'),
(698, 'Cập nhật quy trình', 'Công việc: VietGuard đổi logo và chỉnh mã nguồn đúng tên VietGuard vừa được cập nhật quy trình mới', 24, 'Cập nhật', 0, '2025-11-17 02:04:50', '2025-11-17 02:04:50'),
(699, 'Cập nhật quy trình', 'Công việc: Kết quả báo cáo của 6 ngân hàng vừa được cập nhật quy trình mới', 24, 'Cập nhật', 0, '2025-11-17 02:05:14', '2025-11-17 02:05:14'),
(700, 'Cập nhật quy trình', 'Công việc: Hoàn thiện Dashboard Sales vừa được cập nhật quy trình mới', 24, 'Cập nhật', 0, '2025-11-17 02:05:35', '2025-11-17 02:05:35'),
(701, 'Cập nhật quy trình', 'Công việc: Hoàn thiện backend Dashboard đi thi A05 vừa được cập nhật quy trình mới', 24, 'Cập nhật', 0, '2025-11-17 02:06:02', '2025-11-17 02:06:02'),
(702, 'Cập nhật quy trình', 'Công việc: Triển khai CSA, lấy list danh sách web nhân viên sử dụng vừa được cập nhật quy trình mới', 24, 'Cập nhật', 0, '2025-11-17 02:06:17', '2025-11-17 02:06:17'),
(703, 'Cập nhật công việc', 'Công việc: Triển khai CSA, lấy list danh sách web nhân viên sử dụng vừa được cập nhật mới', 24, 'Cập nhật', 0, '2025-11-17 02:06:19', '2025-11-17 02:06:19'),
(704, 'Cập nhật quy trình', 'Công việc: Hoàn thiện backend Dashboard đi thi A05 vừa được cập nhật quy trình mới', 24, 'Cập nhật', 0, '2025-11-17 02:06:26', '2025-11-17 02:06:26'),
(705, 'Cập nhật công việc', 'Công việc: Hoàn thiện backend Dashboard đi thi A05 vừa được cập nhật mới', 24, 'Cập nhật', 0, '2025-11-17 02:06:26', '2025-11-17 02:06:26'),
(706, 'Cập nhật quy trình', 'Công việc: Hoàn thiện Dashboard Sales vừa được cập nhật quy trình mới', 24, 'Cập nhật', 0, '2025-11-17 02:06:37', '2025-11-17 02:06:37'),
(707, 'Cập nhật công việc', 'Công việc: Hoàn thiện Dashboard Sales vừa được cập nhật mới', 24, 'Cập nhật', 0, '2025-11-17 02:06:38', '2025-11-17 02:06:38'),
(708, 'Cập nhật công việc', 'Công việc: Hoàn thiện Dashboard Sales vừa được cập nhật mới', 24, 'Cập nhật', 0, '2025-11-17 02:06:59', '2025-11-17 02:06:59'),
(709, 'Cập nhật quy trình', 'Công việc: Hoàn thiện backend Dashboard đi thi A05 vừa được cập nhật quy trình mới', 24, 'Cập nhật', 0, '2025-11-17 02:07:14', '2025-11-17 02:07:14'),
(710, 'Cập nhật công việc', 'Công việc: Hoàn thiện backend Dashboard đi thi A05 vừa được cập nhật mới', 24, 'Cập nhật', 0, '2025-11-17 02:07:16', '2025-11-17 02:07:16'),
(711, 'Cập nhật quy trình', 'Công việc: Web HyperG ( Kết nối API web tổng và web con ) vừa được cập nhật quy trình mới', 24, 'Cập nhật', 0, '2025-11-17 02:07:56', '2025-11-17 02:07:56'),
(712, 'Cập nhật công việc', 'Công việc: Web HyperG ( Kết nối API web tổng và web con ) vừa được cập nhật mới', 24, 'Cập nhật', 0, '2025-11-17 02:07:57', '2025-11-17 02:07:57'),
(713, 'Cập nhật quy trình', 'Công việc: Web HyperG kiểm tra toàn bộ frontend và gửi HyperG check vừa được cập nhật quy trình mới', 24, 'Cập nhật', 0, '2025-11-17 02:08:25', '2025-11-17 02:08:25'),
(714, 'Cập nhật công việc', 'Công việc: Web HyperG kiểm tra toàn bộ frontend và gửi HyperG check vừa được cập nhật mới', 24, 'Cập nhật', 0, '2025-11-17 02:08:26', '2025-11-17 02:08:26'),
(715, 'Cập nhật công việc', 'Công việc: Web HyperG kiểm tra toàn bộ frontend và gửi HyperG check vừa được cập nhật mới', 24, 'Cập nhật', 0, '2025-11-17 02:08:26', '2025-11-17 02:08:26'),
(716, 'Cập nhật quy trình', 'Công việc: Hoàn thiện Dashboard Sales vừa được cập nhật quy trình mới', 24, 'Cập nhật', 0, '2025-11-17 02:08:52', '2025-11-17 02:08:52'),
(717, 'Cập nhật công việc', 'Công việc: Hoàn thiện Dashboard Sales vừa được cập nhật mới', 24, 'Cập nhật', 0, '2025-11-17 02:08:55', '2025-11-17 02:08:55'),
(718, 'Cập nhật quy trình', 'Công việc: Hoàn thiện Dashboard Sales vừa được cập nhật quy trình mới', 24, 'Cập nhật', 0, '2025-11-17 02:09:02', '2025-11-17 02:09:02'),
(719, 'Cập nhật công việc', 'Công việc: Hoàn thiện Dashboard Sales vừa được cập nhật mới', 24, 'Cập nhật', 0, '2025-11-17 02:09:03', '2025-11-17 02:09:03'),
(720, 'Cập nhật công việc', 'Công việc: Hoàn thiện Dashboard Sales vừa được cập nhật mới', 24, 'Cập nhật', 0, '2025-11-17 02:09:10', '2025-11-17 02:09:10'),
(721, 'Cập nhật quy trình', 'Công việc: Hoàn thiện Dashboard Sales vừa được cập nhật quy trình mới', 24, 'Cập nhật', 0, '2025-11-17 02:09:17', '2025-11-17 02:09:17'),
(722, 'Cập nhật công việc', 'Công việc: Hoàn thiện Dashboard Sales vừa được cập nhật mới', 24, 'Cập nhật', 0, '2025-11-17 02:09:18', '2025-11-17 02:09:18'),
(723, 'Cập nhật quy trình', 'Công việc: Tiếp tục hoàn thiện web Oracle, ghép API bella vừa được cập nhật quy trình mới', 8, 'Cập nhật', 0, '2025-11-17 02:09:36', '2025-11-17 02:09:36'),
(724, 'Cập nhật quy trình', 'Công việc: Oracle: Chức năng xác thực mail khi đăng ký vừa được cập nhật quy trình mới', 8, 'Cập nhật', 0, '2025-11-17 02:11:14', '2025-11-17 02:11:14'),
(725, 'Cập nhật công việc', 'Công việc: Oracle: Chức năng xác thực mail khi đăng ký vừa được cập nhật mới', 8, 'Cập nhật', 0, '2025-11-17 02:11:14', '2025-11-17 02:11:14'),
(726, 'Cập nhật quy trình', 'Công việc: Oracle: Thêm bộ đếm lượt truy cập vừa được cập nhật quy trình mới', 8, 'Cập nhật', 0, '2025-11-17 02:11:44', '2025-11-17 02:11:44'),
(727, 'Cập nhật công việc', 'Công việc: Oracle: Thêm bộ đếm lượt truy cập vừa được cập nhật mới', 8, 'Cập nhật', 0, '2025-11-17 02:11:45', '2025-11-17 02:11:45'),
(728, 'Cập nhật quy trình', 'Công việc: Oracle: Chức năng đăng nhập bằng Google vừa được cập nhật quy trình mới', 8, 'Cập nhật', 0, '2025-11-17 02:11:54', '2025-11-17 02:11:54'),
(729, 'Cập nhật công việc', 'Công việc: Oracle: Chức năng đăng nhập bằng Google vừa được cập nhật mới', 8, 'Cập nhật', 0, '2025-11-17 02:11:55', '2025-11-17 02:11:55'),
(730, 'Cập nhật quy trình', 'Công việc: Oracle: Chức năng quên mật khẩu => Gửi mail reset mật khẩu vừa được cập nhật quy trình mới', 8, 'Cập nhật', 0, '2025-11-17 02:12:05', '2025-11-17 02:12:05'),
(731, 'Cập nhật công việc', 'Công việc: Oracle: Chức năng quên mật khẩu => Gửi mail reset mật khẩu vừa được cập nhật mới', 8, 'Cập nhật', 0, '2025-11-17 02:12:05', '2025-11-17 02:12:05'),
(732, 'Cập nhật công việc', 'Công việc: Oracle: Chức năng quên mật khẩu => Gửi mail reset mật khẩu vừa được cập nhật mới', 8, 'Cập nhật', 0, '2025-11-17 02:12:18', '2025-11-17 02:12:18'),
(733, 'Cập nhật quy trình', 'Công việc: Update Oracle Cloud theo trao đổi với HyperG vừa được cập nhật quy trình mới', 8, 'Cập nhật', 0, '2025-11-17 02:12:31', '2025-11-17 02:12:31'),
(734, 'Cập nhật công việc', 'Công việc: Update Oracle Cloud theo trao đổi với HyperG vừa được cập nhật mới', 8, 'Cập nhật', 0, '2025-11-17 02:12:32', '2025-11-17 02:12:32'),
(735, 'Đánh giá công việc mới', 'Bạn vừa có thêm đánh giá cho công việc.', 17, 'Đánh giá', 0, '2025-11-17 02:12:51', '2025-11-17 02:12:51'),
(736, 'Đánh giá công việc mới', 'Bạn vừa có thêm đánh giá cho công việc.', 14, 'Đánh giá', 0, '2025-11-17 02:12:51', '2025-11-17 02:12:51'),
(737, 'Đánh giá công việc mới', 'Bạn vừa có thêm đánh giá cho công việc.', 3, 'Đánh giá', 0, '2025-11-17 02:12:51', '2025-11-17 02:12:51'),
(738, 'Đánh giá công việc mới', 'Bạn vừa có thêm đánh giá cho công việc.', 21, 'Đánh giá', 0, '2025-11-17 02:12:51', '2025-11-17 02:12:51'),
(739, 'Đánh giá công việc mới', 'Bạn vừa có thêm đánh giá cho công việc.', 8, 'Đánh giá', 0, '2025-11-17 02:12:51', '2025-11-17 02:12:51'),
(740, 'Đánh giá công việc mới', 'Bạn vừa có thêm đánh giá cho công việc.', 5, 'Đánh giá', 0, '2025-11-17 02:12:51', '2025-11-17 02:12:51'),
(741, 'Đánh giá công việc mới', 'Bạn vừa có thêm đánh giá cho công việc.', 6, 'Đánh giá', 0, '2025-11-17 02:12:51', '2025-11-17 02:12:51'),
(742, 'Cập nhật công việc', 'Công việc: Báo cáo kết quả CSA chạy trên windows, Linux Server ( hiệu suất. tỉ lệ nhanh chậm) vừa được cập nhật mới', 24, 'Cập nhật', 0, '2025-11-17 03:43:35', '2025-11-17 03:43:35'),
(743, 'Cập nhật công việc', 'Công việc: Xuất hóa đơn HyperG - Cathay vừa được cập nhật mới', 10, 'Cập nhật', 0, '2025-11-17 03:54:36', '2025-11-17 03:54:36'),
(744, 'Cập nhật công việc', 'Công việc: Xuất hóa đơn HyperG - Cathay vừa được cập nhật mới', 7, 'Cập nhật', 0, '2025-11-17 03:54:36', '2025-11-17 03:54:36'),
(745, 'Cập nhật công việc', 'Công việc: Bán được 5 gói đào tạo về AI vừa được cập nhật mới', 11, 'Cập nhật', 0, '2025-11-17 05:52:05', '2025-11-17 05:52:05'),
(746, 'Cập nhật công việc', 'Công việc: Bán được 5 gói đào tạo về AI vừa được cập nhật mới', 10, 'Cập nhật', 0, '2025-11-17 05:52:05', '2025-11-17 05:52:05'),
(747, 'Cập nhật công việc', 'Công việc: Oracle cloud: Ký hợp đồng với 3C vừa được cập nhật mới', 11, 'Cập nhật', 0, '2025-11-17 05:52:14', '2025-11-17 05:52:14'),
(748, 'Cập nhật công việc', 'Công việc: Xuất hóa đơn HyperG - Cathay vừa được cập nhật mới', 10, 'Cập nhật', 0, '2025-11-17 05:52:29', '2025-11-17 05:52:29'),
(749, 'Cập nhật công việc', 'Công việc: Xuất hóa đơn HyperG - Cathay vừa được cập nhật mới', 7, 'Cập nhật', 0, '2025-11-17 05:52:29', '2025-11-17 05:52:29'),
(750, 'Cập nhật công việc', 'Công việc: Làm lại số hotline cho facebook, zalo và các trang mạng xã hội của cty vừa được cập nhật mới', 7, 'Cập nhật', 0, '2025-11-17 05:52:35', '2025-11-17 05:52:35'),
(751, 'Cập nhật công việc', 'Công việc: Trong tháng 9 đến giữa tháng 10 phải bán được 1 Dashboard vừa được cập nhật mới', 11, 'Cập nhật', 0, '2025-11-17 05:52:40', '2025-11-17 05:52:40'),
(752, 'Công việc mới', 'Bạn được giao công việc: Bổ sung click vào các phòng ban sẽ hiện các công việc của phòng Ban đang thực hiện . Hạn: 2025-11-18.', 25, 'Công việc mới', 0, '2025-11-17 05:54:43', '2025-11-17 05:54:43'),
(753, 'Công việc mới', 'Bạn được giao công việc: Thêm phân loại theo ngày và tuần của list công việc. Hạn: 2025-11-18.', 25, 'Công việc mới', 0, '2025-11-17 05:56:03', '2025-11-17 05:56:03'),
(754, 'Cập nhật công việc', 'Công việc: Thêm phân loại theo ngày và tuần của list công việc vừa được cập nhật mới', 25, 'Cập nhật', 0, '2025-11-17 05:56:54', '2025-11-17 05:56:54'),
(755, 'Công việc mới', 'Bạn được giao công việc: Trao đổi với Phòng Văn Hóa về Netzero Tours. Hạn: 2025-11-20.', 11, 'Công việc mới', 0, '2025-11-17 06:04:04', '2025-11-17 06:04:04'),
(756, 'Công việc mới', 'Bạn được giao công việc: gửi báo giá dự toán. Hạn: 2025-11-17.', 3, 'Công việc mới', 0, '2025-11-17 06:19:43', '2025-11-17 06:19:43'),
(757, 'Công việc mới', 'Bạn được giao công việc: Ký hợp đồng triển khai. Hạn: 2025-12-31.', 6, 'Công việc mới', 0, '2025-11-17 06:21:40', '2025-11-17 06:21:40'),
(758, 'Cập nhật công việc', 'Công việc: gửi báo giá dự toán vừa được cập nhật mới', 3, 'Cập nhật', 0, '2025-11-17 06:21:50', '2025-11-17 06:21:50'),
(759, 'Thêm mới quy trình', 'Công việc: Ký hợp đồng triển khai vừa được thêm quy trình mới', 6, 'Cập nhật', 0, '2025-11-17 06:22:43', '2025-11-17 06:22:43'),
(760, 'Cập nhật công việc', 'Công việc: Ký hợp đồng triển khai vừa được cập nhật mới', 6, 'Cập nhật', 0, '2025-11-17 06:22:45', '2025-11-17 06:22:45'),
(761, 'Thêm mới quy trình', 'Công việc: Ký hợp đồng triển khai vừa được thêm quy trình mới', 6, 'Cập nhật', 0, '2025-11-17 06:24:04', '2025-11-17 06:24:04'),
(762, 'Cập nhật công việc', 'Công việc: Ký hợp đồng triển khai vừa được cập nhật mới', 6, 'Cập nhật', 0, '2025-11-17 06:24:07', '2025-11-17 06:24:07'),
(763, 'Thêm mới quy trình', 'Công việc: gửi báo giá dự toán vừa được thêm quy trình mới', 3, 'Cập nhật', 0, '2025-11-17 06:25:27', '2025-11-17 06:25:27'),
(764, 'Cập nhật công việc', 'Công việc: gửi báo giá dự toán vừa được cập nhật mới', 3, 'Cập nhật', 0, '2025-11-17 06:25:29', '2025-11-17 06:25:29'),
(765, 'Thêm mới quy trình', 'Công việc: Thêm phân loại theo ngày và tuần của list công việc vừa được thêm quy trình mới', 25, 'Cập nhật', 0, '2025-11-17 06:30:25', '2025-11-17 06:30:25'),
(766, 'Cập nhật công việc', 'Công việc: Thêm phân loại theo ngày và tuần của list công việc vừa được cập nhật mới', 25, 'Cập nhật', 0, '2025-11-17 06:30:34', '2025-11-17 06:30:34'),
(767, 'Cập nhật quy trình', 'Công việc: Thêm phân loại theo ngày và tuần của list công việc vừa được cập nhật quy trình mới', 25, 'Cập nhật', 0, '2025-11-17 06:30:45', '2025-11-17 06:30:45'),
(768, 'Cập nhật công việc', 'Công việc: Thêm phân loại theo ngày và tuần của list công việc vừa được cập nhật mới', 25, 'Cập nhật', 0, '2025-11-17 06:30:46', '2025-11-17 06:30:46'),
(769, 'Cập nhật công việc', 'Công việc: Thêm xem theo tuần, tháng tổng hợp công việc trang HRM vừa được cập nhật mới', 25, 'Cập nhật', 0, '2025-11-17 06:33:04', '2025-11-17 06:33:04'),
(770, 'Công việc mới', 'Bạn được giao công việc: Đưa mini app lên hệ thống Zalo Demo. Hạn: 2025-11-22.', 6, 'Công việc mới', 0, '2025-11-17 06:33:25', '2025-11-17 06:33:25'),
(771, 'Công việc mới', 'Bạn được giao công việc: Đưa mini app lên hệ thống Zalo Demo. Hạn: 2025-11-22.', 25, 'Công việc mới', 0, '2025-11-17 06:33:25', '2025-11-17 06:33:25'),
(772, 'Công việc mới', 'Bạn được giao công việc: Chính sách giá với ECHOSS. Hạn: 2025-11-22.', 11, 'Công việc mới', 0, '2025-11-17 06:37:40', '2025-11-17 06:37:40'),
(773, 'Công việc mới', 'Bạn được giao công việc: Ký hợp tác với ECHOSS. Hạn: 2025-11-22.', 10, 'Công việc mới', 0, '2025-11-17 06:38:28', '2025-11-17 06:38:28'),
(774, 'Cập nhật công việc', 'Công việc: Đưa mini app lên hệ thống Zalo Demo vừa được cập nhật mới', 25, 'Cập nhật', 0, '2025-11-17 06:38:44', '2025-11-17 06:38:44'),
(775, 'Cập nhật công việc', 'Công việc: Đưa mini app lên hệ thống Zalo Demo vừa được cập nhật mới', 6, 'Cập nhật', 0, '2025-11-17 06:38:44', '2025-11-17 06:38:44'),
(776, 'Công việc mới', 'Bạn được giao công việc: Đợi xét duyệt ngân sách. Hạn: 2025-12-31.', 11, 'Công việc mới', 0, '2025-11-17 06:40:16', '2025-11-17 06:40:16'),
(777, 'Thêm mới quy trình', 'Công việc: Đợi xét duyệt ngân sách vừa được thêm quy trình mới', 11, 'Cập nhật', 0, '2025-11-17 06:42:05', '2025-11-17 06:42:05'),
(778, 'Cập nhật công việc', 'Công việc: Đợi xét duyệt ngân sách vừa được cập nhật mới', 11, 'Cập nhật', 0, '2025-11-17 06:42:09', '2025-11-17 06:42:09'),
(779, 'Thêm mới quy trình', 'Công việc: Đợi xét duyệt ngân sách vừa được thêm quy trình mới', 11, 'Cập nhật', 0, '2025-11-17 06:42:42', '2025-11-17 06:42:42'),
(780, 'Cập nhật công việc', 'Công việc: Đợi xét duyệt ngân sách vừa được cập nhật mới', 11, 'Cập nhật', 0, '2025-11-17 06:42:45', '2025-11-17 06:42:45'),
(781, 'Cập nhật quy trình', 'Công việc: Đợi xét duyệt ngân sách vừa được cập nhật quy trình mới', 11, 'Cập nhật', 0, '2025-11-17 06:43:00', '2025-11-17 06:43:00'),
(782, 'Cập nhật công việc', 'Công việc: Đợi xét duyệt ngân sách vừa được cập nhật mới', 11, 'Cập nhật', 0, '2025-11-17 06:43:03', '2025-11-17 06:43:03'),
(783, 'Cập nhật công việc', 'Công việc: Đợi xét duyệt ngân sách vừa được cập nhật mới', 11, 'Cập nhật', 0, '2025-11-17 06:43:17', '2025-11-17 06:43:17'),
(784, 'Công việc mới', 'Bạn được giao công việc: Họp online xác định nhu cầu thực tế. Hạn: 2025-11-30.', 11, 'Công việc mới', 0, '2025-11-17 06:45:22', '2025-11-17 06:45:22'),
(785, 'Công việc mới', 'Bạn được giao công việc: Họp online xác định nhu cầu thực tế. Hạn: 2025-11-30.', 6, 'Công việc mới', 0, '2025-11-17 06:45:22', '2025-11-17 06:45:22'),
(786, 'Công việc mới', 'Bạn được giao công việc: Gặp mặt lần đầu nắm yêu cầu. Hạn: 2025-11-17.', 4, 'Công việc mới', 0, '2025-11-17 06:49:48', '2025-11-17 06:49:48'),
(787, 'Công việc mới', 'Bạn được giao công việc: Gặp mặt lần đầu nắm yêu cầu. Hạn: 2025-11-17.', 6, 'Công việc mới', 0, '2025-11-17 06:49:48', '2025-11-17 06:49:48'),
(788, 'Công việc mới', 'Bạn được giao công việc: Gặp mặt lần đầu nắm yêu cầu. Hạn: 2025-11-17.', 3, 'Công việc mới', 0, '2025-11-17 06:49:48', '2025-11-17 06:49:48'),
(789, 'Thêm mới quy trình', 'Công việc: Gặp mặt lần đầu nắm yêu cầu vừa được thêm quy trình mới', 4, 'Cập nhật', 0, '2025-11-17 06:50:27', '2025-11-17 06:50:27'),
(790, 'Thêm mới quy trình', 'Công việc: Gặp mặt lần đầu nắm yêu cầu vừa được thêm quy trình mới', 6, 'Cập nhật', 0, '2025-11-17 06:50:27', '2025-11-17 06:50:27'),
(791, 'Thêm mới quy trình', 'Công việc: Gặp mặt lần đầu nắm yêu cầu vừa được thêm quy trình mới', 3, 'Cập nhật', 0, '2025-11-17 06:50:27', '2025-11-17 06:50:27'),
(792, 'Cập nhật công việc', 'Công việc: Gặp mặt lần đầu nắm yêu cầu vừa được cập nhật mới', 3, 'Cập nhật', 0, '2025-11-17 06:51:02', '2025-11-17 06:51:02'),
(793, 'Cập nhật công việc', 'Công việc: Gặp mặt lần đầu nắm yêu cầu vừa được cập nhật mới', 4, 'Cập nhật', 0, '2025-11-17 06:51:02', '2025-11-17 06:51:02'),
(794, 'Cập nhật công việc', 'Công việc: Gặp mặt lần đầu nắm yêu cầu vừa được cập nhật mới', 6, 'Cập nhật', 0, '2025-11-17 06:51:02', '2025-11-17 06:51:02'),
(795, 'Cập nhật công việc', 'Công việc: Gặp mặt lần đầu nắm yêu cầu vừa được cập nhật mới', 3, 'Cập nhật', 0, '2025-11-17 06:52:41', '2025-11-17 06:52:41'),
(796, 'Cập nhật công việc', 'Công việc: Gặp mặt lần đầu nắm yêu cầu vừa được cập nhật mới', 4, 'Cập nhật', 0, '2025-11-17 06:52:41', '2025-11-17 06:52:41'),
(797, 'Cập nhật công việc', 'Công việc: Gặp mặt lần đầu nắm yêu cầu vừa được cập nhật mới', 6, 'Cập nhật', 0, '2025-11-17 06:52:41', '2025-11-17 06:52:41'),
(798, 'Công việc mới', 'Bạn được giao công việc: Khảo sát hạ tầng cơ bản. Hạn: 2025-11-14.', 6, 'Công việc mới', 0, '2025-11-17 06:53:45', '2025-11-17 06:53:45'),
(799, 'Công việc mới', 'Bạn được giao công việc: Khảo sát hạ tầng cơ bản. Hạn: 2025-11-14.', 3, 'Công việc mới', 0, '2025-11-17 06:53:45', '2025-11-17 06:53:45'),
(800, 'Công việc mới', 'Bạn được giao công việc: Khảo sát IT. Hạn: 2025-11-30.', 6, 'Công việc mới', 0, '2025-11-17 06:54:36', '2025-11-17 06:54:36'),
(801, 'Công việc mới', 'Bạn được giao công việc: Khảo sát IT. Hạn: 2025-11-30.', 3, 'Công việc mới', 0, '2025-11-17 06:54:36', '2025-11-17 06:54:36'),
(802, 'Thêm mới quy trình', 'Công việc: Khảo sát hạ tầng cơ bản vừa được thêm quy trình mới', 6, 'Cập nhật', 0, '2025-11-17 06:55:21', '2025-11-17 06:55:21'),
(803, 'Thêm mới quy trình', 'Công việc: Khảo sát hạ tầng cơ bản vừa được thêm quy trình mới', 3, 'Cập nhật', 0, '2025-11-17 06:55:21', '2025-11-17 06:55:21'),
(804, 'Cập nhật công việc', 'Công việc: Khảo sát hạ tầng cơ bản vừa được cập nhật mới', 3, 'Cập nhật', 0, '2025-11-17 06:55:24', '2025-11-17 06:55:24'),
(805, 'Cập nhật công việc', 'Công việc: Khảo sát hạ tầng cơ bản vừa được cập nhật mới', 6, 'Cập nhật', 0, '2025-11-17 06:55:24', '2025-11-17 06:55:24'),
(806, 'Cập nhật công việc', 'Công việc: Khảo sát hạ tầng cơ bản vừa được cập nhật mới', 3, 'Cập nhật', 0, '2025-11-17 06:55:38', '2025-11-17 06:55:38'),
(807, 'Cập nhật công việc', 'Công việc: Khảo sát hạ tầng cơ bản vừa được cập nhật mới', 6, 'Cập nhật', 0, '2025-11-17 06:55:38', '2025-11-17 06:55:38'),
(808, 'Công việc mới', 'Bạn được giao công việc: Hẹn cuối tháng 11 khảo sát. Hạn: 2025-11-30.', 6, 'Công việc mới', 0, '2025-11-17 06:56:27', '2025-11-17 06:56:27'),
(809, 'Công việc mới', 'Bạn được giao công việc: Hẹn cuối tháng 11 khảo sát. Hạn: 2025-11-30.', 3, 'Công việc mới', 0, '2025-11-17 06:56:27', '2025-11-17 06:56:27'),
(810, 'Thêm mới quy trình', 'Công việc: Hẹn cuối tháng 11 khảo sát vừa được thêm quy trình mới', 6, 'Cập nhật', 0, '2025-11-17 07:00:03', '2025-11-17 07:00:03'),
(811, 'Thêm mới quy trình', 'Công việc: Hẹn cuối tháng 11 khảo sát vừa được thêm quy trình mới', 3, 'Cập nhật', 0, '2025-11-17 07:00:03', '2025-11-17 07:00:03'),
(812, 'Cập nhật công việc', 'Công việc: Hẹn cuối tháng 11 khảo sát vừa được cập nhật mới', 3, 'Cập nhật', 0, '2025-11-17 07:00:07', '2025-11-17 07:00:07'),
(813, 'Cập nhật công việc', 'Công việc: Hẹn cuối tháng 11 khảo sát vừa được cập nhật mới', 6, 'Cập nhật', 0, '2025-11-17 07:00:07', '2025-11-17 07:00:07'),
(814, 'Cập nhật quy trình', 'Công việc: Làm lại số hotline cho facebook, zalo và các trang mạng xã hội của cty vừa được cập nhật quy trình mới', 7, 'Cập nhật', 0, '2025-11-17 07:08:59', '2025-11-17 07:08:59'),
(815, 'Cập nhật quy trình', 'Công việc: Xuất hóa đơn HyperG - Cathay vừa được cập nhật quy trình mới', 10, 'Cập nhật', 0, '2025-11-17 07:10:08', '2025-11-17 07:10:08'),
(816, 'Cập nhật quy trình', 'Công việc: Xuất hóa đơn HyperG - Cathay vừa được cập nhật quy trình mới', 7, 'Cập nhật', 0, '2025-11-17 07:10:08', '2025-11-17 07:10:08'),
(817, 'Công việc mới', 'Bạn được giao công việc: Dùng thử. Hạn: 2025-11-17.', 16, 'Công việc mới', 0, '2025-11-17 07:10:31', '2025-11-17 07:10:31'),
(818, 'Thêm mới quy trình', 'Công việc: Dùng thử vừa được thêm quy trình mới', 16, 'Cập nhật', 0, '2025-11-17 07:11:36', '2025-11-17 07:11:36'),
(819, 'Cập nhật công việc', 'Công việc: Dùng thử vừa được cập nhật mới', 16, 'Cập nhật', 0, '2025-11-17 07:11:39', '2025-11-17 07:11:39'),
(820, 'Công việc mới', 'Bạn được giao công việc: Lên chính sách báo giá. Hạn: 2025-11-21.', 4, 'Công việc mới', 0, '2025-11-17 07:12:42', '2025-11-17 07:12:42'),
(821, 'Cập nhật công việc', 'Công việc: Nghiên cứu thực trạng trang web phutraco vừa được cập nhật mới', 8, 'Cập nhật', 0, '2025-11-17 07:13:24', '2025-11-17 07:13:24'),
(822, 'Cập nhật công việc', 'Công việc: Nghiên cứu thực trạng trang web phutraco vừa được cập nhật mới', 8, 'Cập nhật', 0, '2025-11-17 07:13:41', '2025-11-17 07:13:41'),
(823, 'Công việc mới', 'Bạn được giao công việc: Test. Hạn: 2025-11-17.', 25, 'Công việc mới', 0, '2025-11-17 07:42:42', '2025-11-17 07:42:42'),
(824, 'Thêm mới quy trình', 'Công việc: Test vừa được thêm quy trình mới', 25, 'Cập nhật', 0, '2025-11-17 07:42:52', '2025-11-17 07:42:52'),
(825, 'Cập nhật quy trình', 'Công việc: Test vừa được cập nhật quy trình mới', 25, 'Cập nhật', 0, '2025-11-17 07:43:12', '2025-11-17 07:43:12'),
(826, 'Cập nhật công việc', 'Công việc: Test vừa được cập nhật mới', 25, 'Cập nhật', 0, '2025-11-17 07:43:14', '2025-11-17 07:43:14'),
(827, 'Cập nhật quy trình', 'Công việc: Test vừa được cập nhật quy trình mới', 25, 'Cập nhật', 0, '2025-11-17 07:43:37', '2025-11-17 07:43:37'),
(828, 'Cập nhật công việc', 'Công việc: Test vừa được cập nhật mới', 25, 'Cập nhật', 0, '2025-11-17 07:43:39', '2025-11-17 07:43:39'),
(829, 'Cập nhật quy trình', 'Công việc: Tìm kiếm đối tác và liên hệ lắp thêm đường internet mới chạy AI SOC vừa được cập nhật quy trình mới', 25, 'Cập nhật', 0, '2025-11-17 07:46:27', '2025-11-17 07:46:27'),
(830, 'Cập nhật công việc', 'Công việc: Tìm kiếm đối tác và liên hệ lắp thêm đường internet mới chạy AI SOC vừa được cập nhật mới', 25, 'Cập nhật', 0, '2025-11-17 07:46:36', '2025-11-17 07:46:36'),
(831, 'Cập nhật công việc', 'Công việc: Thêm xem theo tuần, tháng tổng hợp công việc trang HRM vừa được cập nhật mới', 25, 'Cập nhật', 0, '2025-11-17 07:46:45', '2025-11-17 07:46:45'),
(832, 'Cập nhật công việc', 'Công việc: Thêm phần gửi danh sách hoặc lí do checkin hoặc checkout muộn vừa được cập nhật mới', 25, 'Cập nhật', 0, '2025-11-17 07:46:52', '2025-11-17 07:46:52'),
(833, 'Cập nhật công việc', 'Công việc: Thêm phân loại theo ngày và tuần của list công việc vừa được cập nhật mới', 25, 'Cập nhật', 0, '2025-11-17 07:46:53', '2025-11-17 07:46:53'),
(834, 'Cập nhật công việc', 'Công việc: Thêm dự án cá nhân có thể thêm list công việc dự án cho từng cá nhân vừa được cập nhật mới', 25, 'Cập nhật', 0, '2025-11-17 07:46:59', '2025-11-17 07:46:59'),
(835, 'Cập nhật công việc', 'Công việc: Sửa lại phần thống kê báo cáo đang bị sai logic về % hoàn thành công việc vừa được cập nhật mới', 25, 'Cập nhật', 0, '2025-11-17 07:47:00', '2025-11-17 07:47:00'),
(836, 'Cập nhật công việc', 'Công việc: Sửa lại phần dự án có thể giao việc cho các nhân viên của tất cả các phòng vừa được cập nhật mới', 25, 'Cập nhật', 0, '2025-11-17 07:47:08', '2025-11-17 07:47:08'),
(837, 'Công việc mới', 'Bạn được giao công việc: Hỗ trợ kỹ thuật. Hạn: 2025-11-30.', 6, 'Công việc mới', 0, '2025-11-17 08:36:10', '2025-11-17 08:36:10'),
(838, 'Công việc mới', 'Bạn được giao công việc: Hỗ trợ kỹ thuật. Hạn: 2025-11-30.', 24, 'Công việc mới', 0, '2025-11-17 08:36:11', '2025-11-17 08:36:11'),
(839, 'Công việc mới', 'Bạn được giao công việc: Trao đổi chính sách IRTECH. Hạn: 2025-11-30.', 11, 'Công việc mới', 0, '2025-11-17 08:36:47', '2025-11-17 08:36:47'),
(840, 'Công việc mới', 'Bạn được giao công việc: Làm việc với CyStack để nắm khi nào khảo sát. Hạn: 2025-11-30.', 6, 'Công việc mới', 0, '2025-11-17 08:38:38', '2025-11-17 08:38:38'),
(841, 'Công việc mới', 'Bạn được giao công việc: Làm việc với CyStack để nắm khi nào khảo sát. Hạn: 2025-11-30.', 24, 'Công việc mới', 0, '2025-11-17 08:38:39', '2025-11-17 08:38:39'),
(842, 'Cập nhật công việc', 'Công việc: lên file quản lý dự án Agribank vừa được cập nhật mới', 11, 'Cập nhật', 0, '2025-11-17 08:39:29', '2025-11-17 08:39:29'),
(843, 'Cập nhật công việc', 'Công việc: GỬi báo giá vừa được cập nhật mới', 11, 'Cập nhật', 0, '2025-11-17 08:39:57', '2025-11-17 08:39:57'),
(844, 'Công việc mới', 'Bạn được giao công việc: Chốt được lịch sang thăm văn phòng. Hạn: 2025-11-30.', 6, 'Công việc mới', 0, '2025-11-17 08:41:19', '2025-11-17 08:41:19'),
(845, 'Thêm mới quy trình', 'Công việc: Hỗ trợ kỹ thuật vừa được thêm quy trình mới', 6, 'Cập nhật', 0, '2025-11-17 08:41:56', '2025-11-17 08:41:56'),
(846, 'Thêm mới quy trình', 'Công việc: Hỗ trợ kỹ thuật vừa được thêm quy trình mới', 24, 'Cập nhật', 0, '2025-11-17 08:41:56', '2025-11-17 08:41:56'),
(847, 'Cập nhật quy trình', 'Công việc: Hoàn thiện backend Dashboard đi thi A05 vừa được cập nhật quy trình mới', 24, 'Cập nhật', 0, '2025-11-17 09:16:08', '2025-11-17 09:16:08'),
(848, 'Cập nhật công việc', 'Công việc: Hoàn thiện backend Dashboard đi thi A05 vừa được cập nhật mới', 24, 'Cập nhật', 0, '2025-11-17 09:16:09', '2025-11-17 09:16:09'),
(849, 'Cập nhật công việc', 'Công việc: Hoàn thiện backend Dashboard đi thi A05 vừa được cập nhật mới', 24, 'Cập nhật', 0, '2025-11-17 09:16:22', '2025-11-17 09:16:22'),
(850, 'Cập nhật công việc', 'Công việc: Hoàn thiện backend Dashboard đi thi A05 vừa được cập nhật mới', 24, 'Cập nhật', 0, '2025-11-17 09:16:23', '2025-11-17 09:16:23'),
(851, 'Cập nhật quy trình', 'Công việc: Triển khai CSA, lấy list danh sách web nhân viên sử dụng vừa được cập nhật quy trình mới', 24, 'Cập nhật', 0, '2025-11-18 02:56:30', '2025-11-18 02:56:30'),
(852, 'Đánh giá công việc mới', 'Bạn vừa có thêm đánh giá cho công việc.', 14, 'Đánh giá', 0, '2025-11-18 05:56:50', '2025-11-18 05:56:50'),
(853, 'Đánh giá công việc mới', 'Bạn vừa có thêm đánh giá cho công việc.', 6, 'Đánh giá', 0, '2025-11-18 05:56:50', '2025-11-18 05:56:50'),
(854, 'Thêm mới quy trình', 'Công việc: Bổ sung click vào các phòng ban sẽ hiện các công việc của phòng Ban đang thực hiện  vừa được thêm quy trình mới', 25, 'Cập nhật', 0, '2025-11-18 07:53:25', '2025-11-18 07:53:25'),
(855, 'Cập nhật công việc', 'Công việc: Bổ sung click vào các phòng ban sẽ hiện các công việc của phòng Ban đang thực hiện  vừa được cập nhật mới', 25, 'Cập nhật', 0, '2025-11-18 07:53:30', '2025-11-18 07:53:30'),
(856, 'Cập nhật quy trình', 'Công việc: Bổ sung click vào các phòng ban sẽ hiện các công việc của phòng Ban đang thực hiện  vừa được cập nhật quy trình mới', 25, 'Cập nhật', 0, '2025-11-18 07:53:48', '2025-11-18 07:53:48'),
(857, 'Cập nhật công việc', 'Công việc: Bổ sung click vào các phòng ban sẽ hiện các công việc của phòng Ban đang thực hiện  vừa được cập nhật mới', 25, 'Cập nhật', 0, '2025-11-18 07:53:49', '2025-11-18 07:53:49'),
(858, 'Cập nhật công việc', 'Công việc: Khảo sát IT vừa được cập nhật mới', 3, 'Cập nhật', 0, '2025-11-18 13:28:43', '2025-11-18 13:28:43'),
(859, 'Cập nhật công việc', 'Công việc: Khảo sát IT vừa được cập nhật mới', 6, 'Cập nhật', 0, '2025-11-18 13:28:43', '2025-11-18 13:28:43'),
(860, 'Cập nhật công việc', 'Công việc: Khảo sát IT vừa được cập nhật mới', 3, 'Cập nhật', 0, '2025-11-18 13:28:55', '2025-11-18 13:28:55'),
(861, 'Cập nhật công việc', 'Công việc: Khảo sát IT vừa được cập nhật mới', 6, 'Cập nhật', 0, '2025-11-18 13:28:55', '2025-11-18 13:28:55'),
(862, 'Công việc mới', 'Bạn được giao công việc: 123. Hạn: 2025-11-14.', 25, 'Công việc mới', 0, '2025-11-18 13:35:49', '2025-11-18 13:35:49'),
(863, 'Nhân viên mới', 'Phòng Kỹ thuật: vừa thêm một nhân viên mới.', 6, 'Nhân viên mới', 0, '2025-11-19 10:08:38', '2025-11-19 10:08:38'),
(864, 'Cập nhật công việc', 'Công việc: Lên chính sách báo giá vừa được cập nhật mới', 4, 'Cập nhật', 0, '2025-11-19 13:59:04', '2025-11-19 13:59:04'),
(865, 'Công việc mới', 'Bạn được giao công việc: Chỉnh sửa 20.11.2025. Hạn: 2025-11-22.', 25, 'Công việc mới', 0, '2025-11-20 04:10:31', '2025-11-20 04:10:31'),
(866, 'Công việc mới', 'Bạn được giao công việc: Trao đổi với a Đạt Vinachem tư vấn ESG và các module nhà máy . Hạn: null.', 3, 'Công việc mới', 0, '2025-11-20 04:14:04', '2025-11-20 04:14:04'),
(867, 'Công việc mới', 'Bạn được giao công việc: Ký NDA giữa CyStack và Medlac. Hạn: 2025-11-17.', 11, 'Công việc mới', 0, '2025-11-20 04:23:45', '2025-11-20 04:23:45'),
(868, 'Cập nhật công việc', 'Công việc: Ký NDA giữa CyStack và Medlac vừa được cập nhật mới', 11, 'Cập nhật', 0, '2025-11-20 04:24:27', '2025-11-20 04:24:27'),
(869, 'Công việc mới', 'Bạn được giao công việc: Khảo Sát Công ty Dược. Hạn: 2025-11-30.', 24, 'Công việc mới', 0, '2025-11-20 04:32:43', '2025-11-20 04:32:43'),
(870, 'Thêm mới quy trình', 'Công việc: Trao đổi với a Đạt Vinachem tư vấn ESG và các module nhà máy  vừa được thêm quy trình mới', 3, 'Cập nhật', 0, '2025-11-20 04:33:13', '2025-11-20 04:33:13'),
(871, 'Công việc mới', 'Bạn được giao công việc: Khảo Sát Công ty Dược. Hạn: 2025-11-30.', 6, 'Công việc mới', 0, '2025-11-20 04:34:26', '2025-11-20 04:34:26'),
(872, 'Công việc mới', 'Bạn được giao công việc: Khảo Sát Công ty Dược. Hạn: 2025-11-30.', 24, 'Công việc mới', 0, '2025-11-20 04:34:26', '2025-11-20 04:34:26'),
(873, 'Công việc mới', 'Bạn được giao công việc: Khảo Sát Công ty Dược. Hạn: 2025-11-30.', 24, 'Công việc mới', 0, '2025-11-20 04:35:25', '2025-11-20 04:35:25'),
(874, 'Thêm mới quy trình', 'Công việc: Khảo Sát Công ty Dược vừa được thêm quy trình mới', 24, 'Cập nhật', 0, '2025-11-20 04:36:05', '2025-11-20 04:36:05'),
(875, 'Thêm mới quy trình', 'Công việc: Khảo Sát Công ty Dược vừa được thêm quy trình mới', 24, 'Cập nhật', 0, '2025-11-20 04:36:43', '2025-11-20 04:36:43'),
(876, 'Cập nhật công việc', 'Công việc: Khảo Sát Công ty Dược vừa được cập nhật mới', 24, 'Cập nhật', 0, '2025-11-20 04:36:51', '2025-11-20 04:36:51'),
(877, 'Cập nhật quy trình', 'Công việc: Khảo Sát Công ty Dược vừa được cập nhật quy trình mới', 24, 'Cập nhật', 0, '2025-11-20 04:37:11', '2025-11-20 04:37:11'),
(878, 'Cập nhật công việc', 'Công việc: Khảo Sát Công ty Dược vừa được cập nhật mới', 24, 'Cập nhật', 0, '2025-11-20 04:37:13', '2025-11-20 04:37:13'),
(879, 'Cập nhật quy trình', 'Công việc: Khảo Sát Công ty Dược vừa được cập nhật quy trình mới', 24, 'Cập nhật', 0, '2025-11-20 04:37:29', '2025-11-20 04:37:29'),
(880, 'Cập nhật công việc', 'Công việc: Khảo Sát Công ty Dược vừa được cập nhật mới', 24, 'Cập nhật', 0, '2025-11-20 04:37:30', '2025-11-20 04:37:30'),
(881, 'Công việc mới', 'Bạn được giao công việc: Đã xin lịch khảo sát, a ĐỈnh sẽ liên hệ trước 1 tuần. Hạn: 2025-12-15.', 3, 'Công việc mới', 0, '2025-11-20 04:46:51', '2025-11-20 04:46:51'),
(882, 'Công việc mới', 'Bạn được giao công việc: Đã gửi báo giá cho a Cường 3C. Hạn: 2025-12-20.', 8, 'Công việc mới', 0, '2025-11-20 04:51:13', '2025-11-20 04:51:13'),
(883, 'Cập nhật công việc', 'Công việc: Đã gửi báo giá cho a Cường 3C vừa được cập nhật mới', 8, 'Cập nhật', 0, '2025-11-20 04:57:22', '2025-11-20 04:57:22'),
(884, 'Cập nhật công việc', 'Công việc: Chỉnh sửa 20.11.2025 vừa được cập nhật mới', 25, 'Cập nhật', 0, '2025-11-20 06:24:34', '2025-11-20 06:24:34'),
(885, 'Công việc mới', 'Bạn được giao công việc: Test. Hạn: 2025-11-21.', 25, 'Công việc mới', 0, '2025-11-20 06:34:32', '2025-11-20 06:34:32'),
(886, 'Công việc mới', 'Bạn được giao công việc: Test việc cho Dũng. Hạn: 2025-11-21.', 25, 'Công việc mới', 0, '2025-11-20 06:35:00', '2025-11-20 06:35:00'),
(887, 'Cập nhật công việc', 'Công việc: Test vừa được cập nhật mới', 25, 'Cập nhật', 0, '2025-11-20 06:35:10', '2025-11-20 06:35:10'),
(888, 'Thêm mới quy trình', 'Công việc: Test vừa được thêm quy trình mới', 25, 'Cập nhật', 0, '2025-11-20 06:35:22', '2025-11-20 06:35:22'),
(889, 'Cập nhật công việc', 'Công việc: Test vừa được cập nhật mới', 25, 'Cập nhật', 0, '2025-11-20 06:35:24', '2025-11-20 06:35:24'),
(890, 'Cập nhật công việc', 'Công việc: Họp online xác định nhu cầu thực tế vừa được cập nhật mới', 11, 'Cập nhật', 0, '2025-11-20 06:41:52', '2025-11-20 06:41:52'),
(891, 'Cập nhật công việc', 'Công việc: Họp online xác định nhu cầu thực tế vừa được cập nhật mới', 6, 'Cập nhật', 0, '2025-11-20 06:41:53', '2025-11-20 06:41:53'),
(892, 'Cập nhật công việc', 'Công việc: Họp online xác định nhu cầu thực tế vừa được cập nhật mới', 27, 'Cập nhật', 0, '2025-11-20 06:41:53', '2025-11-20 06:41:53'),
(893, 'Cập nhật công việc', 'Công việc: Họp online xác định nhu cầu thực tế vừa được cập nhật mới', 11, 'Cập nhật', 0, '2025-11-20 06:43:01', '2025-11-20 06:43:01'),
(894, 'Cập nhật công việc', 'Công việc: Họp online xác định nhu cầu thực tế vừa được cập nhật mới', 27, 'Cập nhật', 0, '2025-11-20 06:43:02', '2025-11-20 06:43:02'),
(895, 'Cập nhật công việc', 'Công việc: Họp online xác định nhu cầu thực tế vừa được cập nhật mới', 6, 'Cập nhật', 0, '2025-11-20 06:43:02', '2025-11-20 06:43:02'),
(896, 'Cập nhật công việc', 'Công việc: Đưa mini app lên hệ thống Zalo Demo vừa được cập nhật mới', 25, 'Cập nhật', 0, '2025-11-20 06:43:36', '2025-11-20 06:43:36'),
(897, 'Cập nhật công việc', 'Công việc: Đưa mini app lên hệ thống Zalo Demo vừa được cập nhật mới', 6, 'Cập nhật', 0, '2025-11-20 06:43:36', '2025-11-20 06:43:36'),
(898, 'Cập nhật công việc', 'Công việc: Chính sách giá với ECHOSS vừa được cập nhật mới', 11, 'Cập nhật', 0, '2025-11-20 06:43:47', '2025-11-20 06:43:47'),
(899, 'Cập nhật công việc', 'Công việc: Ký hợp tác với ECHOSS vừa được cập nhật mới', 10, 'Cập nhật', 0, '2025-11-20 06:44:11', '2025-11-20 06:44:11'),
(900, 'Thêm mới quy trình', 'Công việc: Chỉnh sửa 20.11.2025 vừa được thêm quy trình mới', 25, 'Cập nhật', 0, '2025-11-20 06:44:56', '2025-11-20 06:44:56'),
(901, 'Cập nhật quy trình', 'Công việc: Chỉnh sửa 20.11.2025 vừa được cập nhật quy trình mới', 25, 'Cập nhật', 0, '2025-11-20 06:45:54', '2025-11-20 06:45:54'),
(902, 'Cập nhật công việc', 'Công việc: Chỉnh sửa 20.11.2025 vừa được cập nhật mới', 25, 'Cập nhật', 0, '2025-11-20 06:45:55', '2025-11-20 06:45:55'),
(903, 'Cập nhật công việc', 'Công việc: Chỉnh sửa 2 vừa được cập nhật mới', 25, 'Cập nhật', 0, '2025-11-20 17:54:34', '2025-11-20 17:54:34'),
(904, 'Công việc mới', 'Bạn được giao công việc: Họp trao đổi lại về Vyin AI. Hạn: 2025-11-25.', 24, 'Công việc mới', 0, '2025-11-21 01:27:04', '2025-11-21 01:27:04'),
(905, 'Công việc mới', 'Bạn được giao công việc: Họp trao đổi lại về Vyin AI. Hạn: 2025-11-25.', 25, 'Công việc mới', 0, '2025-11-21 01:27:04', '2025-11-21 01:27:04'),
(906, 'Công việc mới', 'Bạn được giao công việc: Frontend Learning KT. Hạn: 2025-11-28.', 21, 'Công việc mới', 0, '2025-11-21 01:29:10', '2025-11-21 01:29:10'),
(907, 'Công việc mới', 'Bạn được giao công việc: Backend Learning KT. Hạn: 2025-11-28.', 21, 'Công việc mới', 0, '2025-11-21 01:30:12', '2025-11-21 01:30:12'),
(908, 'Cập nhật công việc', 'Công việc: Trao đổi với a Đạt Vinachem tư vấn ESG và các module nhà máy  vừa được cập nhật mới', 3, 'Cập nhật', 0, '2025-11-21 06:46:19', '2025-11-21 06:46:19'),
(909, 'Công việc mới', 'Bạn được giao công việc: Làm việc với a Tim về Netzero. Hạn: 2025-11-30.', 12, 'Công việc mới', 0, '2025-11-21 06:47:50', '2025-11-21 06:47:50'),
(910, 'Công việc mới', 'Bạn được giao công việc: Làm việc với a Tim về Netzero. Hạn: 2025-11-30.', 3, 'Công việc mới', 0, '2025-11-21 06:47:50', '2025-11-21 06:47:50'),
(911, 'Công việc mới', 'Bạn được giao công việc: Dự án Netzero. Hạn: 2025-11-30.', 12, 'Công việc mới', 0, '2025-11-21 06:49:58', '2025-11-21 06:49:58'),
(912, 'Công việc mới', 'Bạn được giao công việc: Dự án Netzero. Hạn: 2025-11-30.', 3, 'Công việc mới', 0, '2025-11-21 06:49:58', '2025-11-21 06:49:58'),
(913, 'Công việc mới', 'Bạn được giao công việc: Làm việc với a Tim về Netzero. Hạn: 2025-11-30.', 12, 'Công việc mới', 0, '2025-11-21 06:51:17', '2025-11-21 06:51:17'),
(914, 'Công việc mới', 'Bạn được giao công việc: Làm việc với a Tim về Netzero. Hạn: 2025-11-30.', 3, 'Công việc mới', 0, '2025-11-21 06:51:17', '2025-11-21 06:51:17'),
(915, 'Cập nhật công việc', 'Công việc: Làm việc với a Tim về Netzero vừa được cập nhật mới', 3, 'Cập nhật', 0, '2025-11-21 06:51:25', '2025-11-21 06:51:25'),
(916, 'Cập nhật công việc', 'Công việc: Làm việc với a Tim về Netzero vừa được cập nhật mới', 12, 'Cập nhật', 0, '2025-11-21 06:51:25', '2025-11-21 06:51:25'),
(917, 'Thêm mới quy trình', 'Công việc: Làm việc với a Tim về Netzero vừa được thêm quy trình mới', 12, 'Cập nhật', 0, '2025-11-21 06:53:04', '2025-11-21 06:53:04'),
(918, 'Thêm mới quy trình', 'Công việc: Làm việc với a Tim về Netzero vừa được thêm quy trình mới', 3, 'Cập nhật', 0, '2025-11-21 06:53:04', '2025-11-21 06:53:04'),
(919, 'Cập nhật công việc', 'Công việc: Đã xin lịch khảo sát, a ĐỈnh sẽ liên hệ trước 1 tuần vừa được cập nhật mới', 3, 'Cập nhật', 0, '2025-11-21 06:53:41', '2025-11-21 06:53:41'),
(920, 'Công việc mới', 'Bạn được giao công việc: Giới thiệu smartdashboard. Hạn: 2025-11-14.', 11, 'Công việc mới', 0, '2025-11-21 06:54:51', '2025-11-21 06:54:51'),
(921, 'Thêm mới quy trình', 'Công việc: Giới thiệu smartdashboard vừa được thêm quy trình mới', 11, 'Cập nhật', 0, '2025-11-21 06:55:20', '2025-11-21 06:55:20'),
(922, 'Thêm mới quy trình', 'Công việc: Giới thiệu smartdashboard vừa được thêm quy trình mới', 11, 'Cập nhật', 0, '2025-11-21 06:55:54', '2025-11-21 06:55:54'),
(923, 'Cập nhật công việc', 'Công việc: Giới thiệu smartdashboard vừa được cập nhật mới', 11, 'Cập nhật', 0, '2025-11-21 06:55:57', '2025-11-21 06:55:57'),
(924, 'Cập nhật công việc', 'Công việc: Giới thiệu smartdashboard vừa được cập nhật mới', 11, 'Cập nhật', 0, '2025-11-21 06:56:16', '2025-11-21 06:56:16'),
(925, 'Cập nhật công việc', 'Công việc: Giới thiệu smartdashboard vừa được cập nhật mới', 11, 'Cập nhật', 0, '2025-11-21 06:56:26', '2025-11-21 06:56:26');
INSERT INTO `thong_bao` (`id`, `tieu_de`, `noi_dung`, `nguoi_nhan_id`, `loai_thong_bao`, `da_doc`, `ngay_doc`, `ngay_tao`) VALUES
(926, 'Cập nhật công việc', 'Công việc: Giới thiệu smartdashboard vừa được cập nhật mới', 11, 'Cập nhật', 0, '2025-11-21 06:56:36', '2025-11-21 06:56:36'),
(927, 'Công việc mới', 'Bạn được giao công việc: đã gửi đề xuất phương án cho Đà Nẵng. Hạn: 2025-11-03.', 11, 'Công việc mới', 0, '2025-11-21 06:57:37', '2025-11-21 06:57:37'),
(928, 'Thêm mới quy trình', 'Công việc: đã gửi đề xuất phương án cho Đà Nẵng vừa được thêm quy trình mới', 11, 'Cập nhật', 0, '2025-11-21 06:58:21', '2025-11-21 06:58:21'),
(929, 'Thêm mới quy trình', 'Công việc: đã gửi đề xuất phương án cho Đà Nẵng vừa được thêm quy trình mới', 11, 'Cập nhật', 0, '2025-11-21 06:58:50', '2025-11-21 06:58:50'),
(930, 'Cập nhật công việc', 'Công việc: đã gửi đề xuất phương án cho Đà Nẵng vừa được cập nhật mới', 11, 'Cập nhật', 0, '2025-11-21 06:58:53', '2025-11-21 06:58:53'),
(931, 'Cập nhật công việc', 'Công việc: đã gửi đề xuất phương án cho Đà Nẵng vừa được cập nhật mới', 11, 'Cập nhật', 0, '2025-11-21 06:59:07', '2025-11-21 06:59:07'),
(932, 'Cập nhật quy trình', 'Công việc: Làm lại số hotline cho facebook, zalo và các trang mạng xã hội của cty vừa được cập nhật quy trình mới', 7, 'Cập nhật', 0, '2025-11-21 09:48:34', '2025-11-21 09:48:34'),
(933, 'Cập nhật quy trình', 'Công việc: Làm lại số hotline cho facebook, zalo và các trang mạng xã hội của cty vừa được cập nhật quy trình mới', 7, 'Cập nhật', 0, '2025-11-21 09:48:58', '2025-11-21 09:48:58'),
(934, 'Cập nhật công việc', 'Công việc: Làm lại số hotline cho facebook, zalo và các trang mạng xã hội của cty vừa được cập nhật mới', 7, 'Cập nhật', 0, '2025-11-21 09:49:00', '2025-11-21 09:49:00'),
(935, 'Cập nhật quy trình', 'Công việc: Xuất hóa đơn HyperG - Cathay vừa được cập nhật quy trình mới', 10, 'Cập nhật', 0, '2025-11-21 09:49:18', '2025-11-21 09:49:18'),
(936, 'Cập nhật quy trình', 'Công việc: Xuất hóa đơn HyperG - Cathay vừa được cập nhật quy trình mới', 7, 'Cập nhật', 0, '2025-11-21 09:49:18', '2025-11-21 09:49:18'),
(937, 'Cập nhật công việc', 'Công việc: Xuất hóa đơn HyperG - Cathay vừa được cập nhật mới', 10, 'Cập nhật', 0, '2025-11-21 09:49:19', '2025-11-21 09:49:19'),
(938, 'Cập nhật công việc', 'Công việc: Xuất hóa đơn HyperG - Cathay vừa được cập nhật mới', 7, 'Cập nhật', 0, '2025-11-21 09:49:19', '2025-11-21 09:49:19'),
(939, 'Cập nhật công việc', 'Công việc: Xuất hóa đơn HyperG - Cathay vừa được cập nhật mới', 10, 'Cập nhật', 0, '2025-11-21 09:50:28', '2025-11-21 09:50:28'),
(940, 'Cập nhật công việc', 'Công việc: Xuất hóa đơn HyperG - Cathay vừa được cập nhật mới', 7, 'Cập nhật', 0, '2025-11-21 09:50:28', '2025-11-21 09:50:28'),
(941, 'Cập nhật công việc', 'Công việc: Xuất hóa đơn HyperG - Cathay vừa được cập nhật mới', 10, 'Cập nhật', 0, '2025-11-21 09:51:55', '2025-11-21 09:51:55'),
(942, 'Cập nhật công việc', 'Công việc: Xuất hóa đơn HyperG - Cathay vừa được cập nhật mới', 7, 'Cập nhật', 0, '2025-11-21 09:51:55', '2025-11-21 09:51:55'),
(943, 'Thêm mới quy trình', 'Công việc: Họp trao đổi lại về Vyin AI vừa được thêm quy trình mới', 24, 'Cập nhật', 0, '2025-11-22 13:04:27', '2025-11-22 13:04:27'),
(944, 'Thêm mới quy trình', 'Công việc: Họp trao đổi lại về Vyin AI vừa được thêm quy trình mới', 25, 'Cập nhật', 0, '2025-11-22 13:04:27', '2025-11-22 13:04:27'),
(945, 'Cập nhật công việc', 'Công việc: Họp trao đổi lại về Vyin AI vừa được cập nhật mới', 24, 'Cập nhật', 0, '2025-11-22 13:04:42', '2025-11-22 13:04:42'),
(946, 'Cập nhật công việc', 'Công việc: Họp trao đổi lại về Vyin AI vừa được cập nhật mới', 25, 'Cập nhật', 0, '2025-11-22 13:04:42', '2025-11-22 13:04:42'),
(947, 'Cập nhật quy trình', 'Công việc: Họp trao đổi lại về Vyin AI vừa được cập nhật quy trình mới', 24, 'Cập nhật', 0, '2025-11-22 13:04:57', '2025-11-22 13:04:57'),
(948, 'Cập nhật quy trình', 'Công việc: Họp trao đổi lại về Vyin AI vừa được cập nhật quy trình mới', 25, 'Cập nhật', 0, '2025-11-22 13:04:58', '2025-11-22 13:04:58'),
(949, 'Cập nhật công việc', 'Công việc: Họp trao đổi lại về Vyin AI vừa được cập nhật mới', 24, 'Cập nhật', 0, '2025-11-22 13:05:00', '2025-11-22 13:05:00'),
(950, 'Cập nhật công việc', 'Công việc: Họp trao đổi lại về Vyin AI vừa được cập nhật mới', 25, 'Cập nhật', 0, '2025-11-22 13:05:00', '2025-11-22 13:05:00'),
(951, 'Cập nhật công việc', 'Công việc: Chỉnh sửa 20.11.2025 vừa được cập nhật mới', 25, 'Cập nhật', 0, '2025-11-22 13:05:47', '2025-11-22 13:05:47'),
(952, 'Cập nhật công việc', 'Công việc: Chỉnh sửa 2 vừa được cập nhật mới', 25, 'Cập nhật', 0, '2025-11-22 13:05:53', '2025-11-22 13:05:53'),
(953, 'Thêm mới quy trình', 'Công việc: Chỉnh sửa 2 vừa được thêm quy trình mới', 25, 'Cập nhật', 0, '2025-11-22 13:06:12', '2025-11-22 13:06:12'),
(954, 'Cập nhật công việc', 'Công việc: Chỉnh sửa 2 vừa được cập nhật mới', 25, 'Cập nhật', 0, '2025-11-22 13:06:14', '2025-11-22 13:06:14'),
(955, 'Cập nhật quy trình', 'Công việc: Chỉnh sửa 2 vừa được cập nhật quy trình mới', 25, 'Cập nhật', 0, '2025-11-22 13:06:20', '2025-11-22 13:06:20'),
(956, 'Cập nhật công việc', 'Công việc: Chỉnh sửa 2 vừa được cập nhật mới', 25, 'Cập nhật', 0, '2025-11-22 13:06:20', '2025-11-22 13:06:20'),
(957, 'Thêm mới quy trình', 'Công việc: Đưa mini app lên hệ thống Zalo Demo vừa được thêm quy trình mới', 25, 'Cập nhật', 0, '2025-11-22 13:07:46', '2025-11-22 13:07:46'),
(958, 'Thêm mới quy trình', 'Công việc: Đưa mini app lên hệ thống Zalo Demo vừa được thêm quy trình mới', 6, 'Cập nhật', 0, '2025-11-22 13:07:46', '2025-11-22 13:07:46'),
(959, 'Cập nhật công việc', 'Công việc: Đưa mini app lên hệ thống Zalo Demo vừa được cập nhật mới', 25, 'Cập nhật', 0, '2025-11-22 13:07:52', '2025-11-22 13:07:52'),
(960, 'Cập nhật công việc', 'Công việc: Đưa mini app lên hệ thống Zalo Demo vừa được cập nhật mới', 6, 'Cập nhật', 0, '2025-11-22 13:07:52', '2025-11-22 13:07:52'),
(961, 'Cập nhật công việc', 'Công việc: Lên chương trình đào tạo cho BIDV vừa được cập nhật mới', 11, 'Cập nhật', 0, '2025-11-24 01:03:52', '2025-11-24 01:03:52'),
(962, 'Cập nhật công việc', 'Công việc: lên file quản lý dự án Agribank vừa được cập nhật mới', 11, 'Cập nhật', 0, '2025-11-24 01:04:09', '2025-11-24 01:04:09'),
(963, 'Cập nhật công việc', 'Công việc: Trao đổi với Phòng Văn Hóa về Netzero Tours vừa được cập nhật mới', 11, 'Cập nhật', 0, '2025-11-24 01:04:32', '2025-11-24 01:04:32'),
(964, 'Thêm mới quy trình', 'Công việc: Chính sách giá với ECHOSS vừa được thêm quy trình mới', 11, 'Cập nhật', 0, '2025-11-24 01:05:43', '2025-11-24 01:05:43'),
(965, 'Cập nhật công việc', 'Công việc: Chính sách giá với ECHOSS vừa được cập nhật mới', 11, 'Cập nhật', 0, '2025-11-24 01:05:47', '2025-11-24 01:05:47'),
(966, 'Thêm mới quy trình', 'Công việc: Khảo sát IT vừa được thêm quy trình mới', 3, 'Cập nhật', 0, '2025-11-24 01:17:14', '2025-11-24 01:17:14'),
(967, 'Thêm mới quy trình', 'Công việc: Khảo sát IT vừa được thêm quy trình mới', 6, 'Cập nhật', 0, '2025-11-24 01:17:14', '2025-11-24 01:17:14'),
(968, 'Cập nhật công việc', 'Công việc: Khảo sát IT vừa được cập nhật mới', 3, 'Cập nhật', 0, '2025-11-24 01:17:19', '2025-11-24 01:17:19'),
(969, 'Cập nhật công việc', 'Công việc: Khảo sát IT vừa được cập nhật mới', 6, 'Cập nhật', 0, '2025-11-24 01:17:19', '2025-11-24 01:17:19'),
(970, 'Cập nhật công việc', 'Công việc: Khảo sát IT vừa được cập nhật mới', 3, 'Cập nhật', 0, '2025-11-24 01:17:28', '2025-11-24 01:17:28'),
(971, 'Cập nhật công việc', 'Công việc: Khảo sát IT vừa được cập nhật mới', 6, 'Cập nhật', 0, '2025-11-24 01:17:28', '2025-11-24 01:17:28'),
(972, 'Thêm mới quy trình', 'Công việc: Trao đổi với Phòng Văn Hóa về Netzero Tours vừa được thêm quy trình mới', 11, 'Cập nhật', 0, '2025-11-24 01:36:37', '2025-11-24 01:36:37'),
(973, 'Cập nhật công việc', 'Công việc: Trao đổi với Phòng Văn Hóa về Netzero Tours vừa được cập nhật mới', 11, 'Cập nhật', 0, '2025-11-24 01:36:41', '2025-11-24 01:36:41'),
(974, 'Thêm mới quy trình', 'Công việc: Oracle cloud: Ký hợp đồng với 3C vừa được thêm quy trình mới', 11, 'Cập nhật', 0, '2025-11-24 01:44:26', '2025-11-24 01:44:26'),
(975, 'Cập nhật công việc', 'Công việc: Oracle cloud: Ký hợp đồng với 3C vừa được cập nhật mới', 11, 'Cập nhật', 0, '2025-11-24 01:44:28', '2025-11-24 01:44:28'),
(976, 'Cập nhật công việc', 'Công việc: Khảo sát IT vừa được cập nhật mới', 3, 'Cập nhật', 0, '2025-11-24 01:45:00', '2025-11-24 01:45:00'),
(977, 'Cập nhật công việc', 'Công việc: Khảo sát IT vừa được cập nhật mới', 6, 'Cập nhật', 0, '2025-11-24 01:45:00', '2025-11-24 01:45:00'),
(978, 'Thêm mới quy trình', 'Công việc: Họp online xác định nhu cầu thực tế vừa được thêm quy trình mới', 11, 'Cập nhật', 0, '2025-11-24 01:46:19', '2025-11-24 01:46:19'),
(979, 'Thêm mới quy trình', 'Công việc: Họp online xác định nhu cầu thực tế vừa được thêm quy trình mới', 27, 'Cập nhật', 0, '2025-11-24 01:46:19', '2025-11-24 01:46:19'),
(980, 'Thêm mới quy trình', 'Công việc: Họp online xác định nhu cầu thực tế vừa được thêm quy trình mới', 6, 'Cập nhật', 0, '2025-11-24 01:46:19', '2025-11-24 01:46:19'),
(981, 'Cập nhật công việc', 'Công việc: Họp online xác định nhu cầu thực tế vừa được cập nhật mới', 11, 'Cập nhật', 0, '2025-11-24 01:46:22', '2025-11-24 01:46:22'),
(982, 'Cập nhật quy trình', 'Công việc: Oracle cloud: Ký hợp đồng với 3C vừa được cập nhật quy trình mới', 11, 'Cập nhật', 0, '2025-11-24 01:46:58', '2025-11-24 01:46:58'),
(983, 'Cập nhật quy trình', 'Công việc: Oracle cloud: Ký hợp đồng với 3C vừa được cập nhật quy trình mới', 11, 'Cập nhật', 0, '2025-11-24 01:47:06', '2025-11-24 01:47:06'),
(984, 'Cập nhật công việc', 'Công việc: Oracle cloud: Ký hợp đồng với 3C vừa được cập nhật mới', 11, 'Cập nhật', 0, '2025-11-24 01:47:07', '2025-11-24 01:47:07'),
(985, 'Cập nhật công việc', 'Công việc: Oracle cloud: Ký hợp đồng với 3C vừa được cập nhật mới', 11, 'Cập nhật', 0, '2025-11-24 01:47:19', '2025-11-24 01:47:19'),
(986, 'Công việc mới', 'Bạn được giao công việc: Hỗ trợ hoàn thiện backend cho quang anh. Hạn: 2025-11-28.', 24, 'Công việc mới', 0, '2025-11-24 01:47:35', '2025-11-24 01:47:35'),
(987, 'Công việc mới', 'Bạn được giao công việc: Làm website Oracle Cloud VN. Hạn: 2025-11-30.', 8, 'Công việc mới', 0, '2025-11-24 01:49:25', '2025-11-24 01:49:25'),
(988, 'Thêm mới quy trình', 'Công việc: Làm website Oracle Cloud VN vừa được thêm quy trình mới', 8, 'Cập nhật', 0, '2025-11-24 01:53:32', '2025-11-24 01:53:32'),
(989, 'Thêm mới quy trình', 'Công việc: Bán được 5 gói đào tạo về AI vừa được thêm quy trình mới', 11, 'Cập nhật', 0, '2025-11-24 01:56:31', '2025-11-24 01:56:31'),
(990, 'Thêm mới quy trình', 'Công việc: Bán được 5 gói đào tạo về AI vừa được thêm quy trình mới', 10, 'Cập nhật', 0, '2025-11-24 01:56:31', '2025-11-24 01:56:31'),
(991, 'Cập nhật công việc', 'Công việc: Bán được 5 gói đào tạo về AI vừa được cập nhật mới', 11, 'Cập nhật', 0, '2025-11-24 01:56:33', '2025-11-24 01:56:33'),
(992, 'Cập nhật công việc', 'Công việc: Bán được 5 gói đào tạo về AI vừa được cập nhật mới', 10, 'Cập nhật', 0, '2025-11-24 01:56:33', '2025-11-24 01:56:33'),
(993, 'Thêm mới quy trình', 'Công việc: Trao đổi chính sách IRTECH vừa được thêm quy trình mới', 11, 'Cập nhật', 0, '2025-11-24 02:56:31', '2025-11-24 02:56:31'),
(994, 'Cập nhật công việc', 'Công việc: Trao đổi chính sách IRTECH vừa được cập nhật mới', 11, 'Cập nhật', 0, '2025-11-24 02:56:33', '2025-11-24 02:56:33'),
(995, 'Cập nhật quy trình', 'Công việc: Trao đổi chính sách IRTECH vừa được cập nhật quy trình mới', 11, 'Cập nhật', 0, '2025-11-24 02:57:50', '2025-11-24 02:57:50'),
(996, 'Cập nhật công việc', 'Công việc: Trao đổi chính sách IRTECH vừa được cập nhật mới', 11, 'Cập nhật', 0, '2025-11-24 02:57:53', '2025-11-24 02:57:53'),
(997, 'Cập nhật công việc', 'Công việc: Nghiên cứu thực trạng trang web phutraco vừa được cập nhật mới', 8, 'Cập nhật', 0, '2025-11-24 03:11:25', '2025-11-24 03:11:25'),
(998, 'Cập nhật công việc', 'Công việc: Nghiên cứu thực trạng trang web phutraco vừa được cập nhật mới', 8, 'Cập nhật', 0, '2025-11-24 03:11:46', '2025-11-24 03:11:46'),
(999, 'Thêm mới quy trình', 'Công việc: Đã xin lịch khảo sát, a ĐỈnh sẽ liên hệ trước 1 tuần vừa được thêm quy trình mới', 3, 'Cập nhật', 0, '2025-11-24 03:13:58', '2025-11-24 03:13:58'),
(1000, 'Cập nhật công việc', 'Công việc: Đã xin lịch khảo sát, a ĐỈnh sẽ liên hệ trước 1 tuần vừa được cập nhật mới', 3, 'Cập nhật', 0, '2025-11-24 03:14:02', '2025-11-24 03:14:02'),
(1001, 'Cập nhật công việc', 'Công việc: Đã gửi báo giá cho a Cường 3C vừa được cập nhật mới', 8, 'Cập nhật', 0, '2025-11-24 03:14:24', '2025-11-24 03:14:24'),
(1002, 'Thêm mới quy trình', 'Công việc: Dự án Netzero vừa được thêm quy trình mới', 12, 'Cập nhật', 0, '2025-11-24 03:15:15', '2025-11-24 03:15:15'),
(1003, 'Thêm mới quy trình', 'Công việc: Dự án Netzero vừa được thêm quy trình mới', 3, 'Cập nhật', 0, '2025-11-24 03:15:15', '2025-11-24 03:15:15'),
(1004, 'Cập nhật công việc', 'Công việc: Dự án Netzero vừa được cập nhật mới', 3, 'Cập nhật', 0, '2025-11-24 03:15:16', '2025-11-24 03:15:16'),
(1005, 'Cập nhật công việc', 'Công việc: Dự án Netzero vừa được cập nhật mới', 12, 'Cập nhật', 0, '2025-11-24 03:15:16', '2025-11-24 03:15:16'),
(1006, 'Cập nhật công việc', 'Công việc: Làm việc với a Tim về Netzero vừa được cập nhật mới', 3, 'Cập nhật', 0, '2025-11-24 03:15:30', '2025-11-24 03:15:30'),
(1007, 'Cập nhật công việc', 'Công việc: Làm việc với a Tim về Netzero vừa được cập nhật mới', 12, 'Cập nhật', 0, '2025-11-24 03:15:30', '2025-11-24 03:15:30'),
(1008, 'Thêm mới quy trình', 'Công việc: Chốt được lịch sang thăm văn phòng vừa được thêm quy trình mới', 6, 'Cập nhật', 0, '2025-11-24 03:16:02', '2025-11-24 03:16:02'),
(1009, 'Cập nhật quy trình', 'Công việc: Hỗ trợ kỹ thuật vừa được cập nhật quy trình mới', 6, 'Cập nhật', 0, '2025-11-24 03:16:03', '2025-11-24 03:16:03'),
(1010, 'Cập nhật quy trình', 'Công việc: Hỗ trợ kỹ thuật vừa được cập nhật quy trình mới', 24, 'Cập nhật', 0, '2025-11-24 03:16:03', '2025-11-24 03:16:03'),
(1011, 'Cập nhật công việc', 'Công việc: Hỗ trợ kỹ thuật vừa được cập nhật mới', 24, 'Cập nhật', 0, '2025-11-24 03:16:06', '2025-11-24 03:16:06'),
(1012, 'Cập nhật công việc', 'Công việc: Hỗ trợ kỹ thuật vừa được cập nhật mới', 6, 'Cập nhật', 0, '2025-11-24 03:16:06', '2025-11-24 03:16:06'),
(1013, 'Cập nhật công việc', 'Công việc: Chốt được lịch sang thăm văn phòng vừa được cập nhật mới', 6, 'Cập nhật', 0, '2025-11-24 03:16:09', '2025-11-24 03:16:09'),
(1014, 'Cập nhật quy trình', 'Công việc: Chốt được lịch sang thăm văn phòng vừa được cập nhật quy trình mới', 6, 'Cập nhật', 0, '2025-11-24 03:16:40', '2025-11-24 03:16:40'),
(1015, 'Cập nhật công việc', 'Công việc: Chốt được lịch sang thăm văn phòng vừa được cập nhật mới', 6, 'Cập nhật', 0, '2025-11-24 03:16:42', '2025-11-24 03:16:42'),
(1016, 'Thêm mới quy trình', 'Công việc: Làm việc với a Tim về Netzero vừa được thêm quy trình mới', 3, 'Cập nhật', 0, '2025-11-24 03:21:14', '2025-11-24 03:21:14'),
(1017, 'Thêm mới quy trình', 'Công việc: Làm việc với a Tim về Netzero vừa được thêm quy trình mới', 12, 'Cập nhật', 0, '2025-11-24 03:21:14', '2025-11-24 03:21:14'),
(1018, 'Cập nhật công việc', 'Công việc: Làm việc với a Tim về Netzero vừa được cập nhật mới', 3, 'Cập nhật', 0, '2025-11-24 03:21:23', '2025-11-24 03:21:23'),
(1019, 'Cập nhật công việc', 'Công việc: Làm việc với a Tim về Netzero vừa được cập nhật mới', 12, 'Cập nhật', 0, '2025-11-24 03:21:23', '2025-11-24 03:21:23'),
(1020, 'Cập nhật công việc', 'Công việc: Hoàn thiện Dashboard Sales vừa được cập nhật mới', 24, 'Cập nhật', 0, '2025-11-24 03:25:44', '2025-11-24 03:25:44'),
(1021, 'Cập nhật quy trình', 'Công việc: Trao đổi với a Đạt Vinachem tư vấn ESG và các module nhà máy  vừa được cập nhật quy trình mới', 3, 'Cập nhật', 0, '2025-11-24 03:39:32', '2025-11-24 03:39:32'),
(1022, 'Cập nhật công việc', 'Công việc: Trao đổi với a Đạt Vinachem tư vấn ESG và các module nhà máy  vừa được cập nhật mới', 3, 'Cập nhật', 0, '2025-11-24 03:39:52', '2025-11-24 03:39:52'),
(1023, 'Thêm mới quy trình', 'Công việc: Frontend Learning KT vừa được thêm quy trình mới', 21, 'Cập nhật', 0, '2025-11-24 07:10:37', '2025-11-24 07:10:37'),
(1024, 'Cập nhật quy trình', 'Công việc: Frontend Learning KT vừa được cập nhật quy trình mới', 21, 'Cập nhật', 0, '2025-11-24 07:11:41', '2025-11-24 07:11:41'),
(1025, 'Thêm mới quy trình', 'Công việc: Hỗ trợ hoàn thiện backend cho quang anh vừa được thêm quy trình mới', 24, 'Cập nhật', 0, '2025-11-24 07:13:39', '2025-11-24 07:13:39'),
(1026, 'Cập nhật công việc', 'Công việc: Hỗ trợ hoàn thiện backend cho quang anh vừa được cập nhật mới', 24, 'Cập nhật', 0, '2025-11-24 07:13:48', '2025-11-24 07:13:48'),
(1027, 'Cập nhật quy trình', 'Công việc: Hỗ trợ hoàn thiện backend cho quang anh vừa được cập nhật quy trình mới', 24, 'Cập nhật', 0, '2025-11-24 07:14:01', '2025-11-24 07:14:01'),
(1028, 'Cập nhật quy trình', 'Công việc: Hỗ trợ hoàn thiện backend cho quang anh vừa được cập nhật quy trình mới', 24, 'Cập nhật', 0, '2025-11-24 07:14:15', '2025-11-24 07:14:15'),
(1029, 'Cập nhật công việc', 'Công việc: Hỗ trợ hoàn thiện backend cho quang anh vừa được cập nhật mới', 24, 'Cập nhật', 0, '2025-11-24 07:14:17', '2025-11-24 07:14:17'),
(1030, 'Thêm mới quy trình', 'Công việc: Backend Learning KT vừa được thêm quy trình mới', 21, 'Cập nhật', 0, '2025-11-24 07:14:37', '2025-11-24 07:14:37'),
(1031, 'Cập nhật công việc', 'Công việc: Backend Learning KT vừa được cập nhật mới', 21, 'Cập nhật', 0, '2025-11-24 07:14:42', '2025-11-24 07:14:42'),
(1032, 'Cập nhật quy trình', 'Công việc: Backend Learning KT vừa được cập nhật quy trình mới', 21, 'Cập nhật', 0, '2025-11-24 07:14:54', '2025-11-24 07:14:54'),
(1033, 'Cập nhật công việc', 'Công việc: Backend Learning KT vừa được cập nhật mới', 21, 'Cập nhật', 0, '2025-11-24 07:14:55', '2025-11-24 07:14:55'),
(1034, 'Cập nhật quy trình', 'Công việc: Frontend Learning KT vừa được cập nhật quy trình mới', 21, 'Cập nhật', 0, '2025-11-24 07:15:11', '2025-11-24 07:15:11'),
(1035, 'Cập nhật công việc', 'Công việc: Frontend Learning KT vừa được cập nhật mới', 21, 'Cập nhật', 0, '2025-11-24 07:15:13', '2025-11-24 07:15:13'),
(1036, 'Cập nhật công việc', 'Công việc: Frontend Learning KT vừa được cập nhật mới', 21, 'Cập nhật', 0, '2025-11-24 07:15:17', '2025-11-24 07:15:17'),
(1037, 'Cập nhật quy trình', 'Công việc: Frontend Learning KT vừa được cập nhật quy trình mới', 21, 'Cập nhật', 0, '2025-11-24 07:48:08', '2025-11-24 07:48:08'),
(1038, 'Thêm mới quy trình', 'Công việc: Frontend Learning KT vừa được thêm quy trình mới', 21, 'Cập nhật', 0, '2025-11-24 07:48:36', '2025-11-24 07:48:36'),
(1039, 'Thêm mới quy trình', 'Công việc: Frontend Learning KT vừa được thêm quy trình mới', 21, 'Cập nhật', 0, '2025-11-24 07:49:34', '2025-11-24 07:49:34'),
(1040, 'Thêm mới quy trình', 'Công việc: Frontend Learning KT vừa được thêm quy trình mới', 21, 'Cập nhật', 0, '2025-11-24 07:50:03', '2025-11-24 07:50:03'),
(1041, 'Thêm mới quy trình', 'Công việc: Frontend Learning KT vừa được thêm quy trình mới', 21, 'Cập nhật', 0, '2025-11-24 07:50:47', '2025-11-24 07:50:47'),
(1042, 'Cập nhật quy trình', 'Công việc: Backend Learning KT vừa được cập nhật quy trình mới', 21, 'Cập nhật', 0, '2025-11-24 07:51:27', '2025-11-24 07:51:27'),
(1043, 'Cập nhật công việc', 'Công việc: Frontend Learning KT vừa được cập nhật mới', 21, 'Cập nhật', 0, '2025-11-24 07:52:00', '2025-11-24 07:52:00'),
(1044, 'Cập nhật công việc', 'Công việc: Backend Learning KT vừa được cập nhật mới', 21, 'Cập nhật', 0, '2025-11-24 07:52:11', '2025-11-24 07:52:11'),
(1045, 'Thêm mới quy trình', 'Công việc: Backend Learning KT vừa được thêm quy trình mới', 21, 'Cập nhật', 0, '2025-11-24 07:52:45', '2025-11-24 07:52:45'),
(1046, 'Công việc mới', 'Bạn được giao công việc: thử nhé1. Hạn: 2025-11-29.', 17, 'Công việc mới', 0, '2025-11-25 06:50:14', '2025-11-25 06:50:14'),
(1047, 'Công việc mới', 'Bạn được giao công việc: 5555555. Hạn: 2025-11-29.', 23, 'Công việc mới', 0, '2025-11-25 06:50:49', '2025-11-25 06:50:49'),
(1048, 'Công việc mới', 'Bạn được giao công việc: 5555555. Hạn: 2025-11-29.', 17, 'Công việc mới', 0, '2025-11-25 08:02:40', '2025-11-25 08:02:40'),
(1049, 'Công việc mới', 'Bạn được giao công việc: 11111. Hạn: 2025-11-29.', 17, 'Công việc mới', 0, '2025-11-25 08:02:52', '2025-11-25 08:02:52'),
(1050, 'Thêm mới quy trình', 'Công việc: 5555555 vừa được thêm quy trình mới', 17, 'Cập nhật', 0, '2025-11-25 08:03:03', '2025-11-25 08:03:03'),
(1051, 'Cập nhật công việc', 'Công việc: 5555555 vừa được cập nhật mới', 17, 'Cập nhật', 0, '2025-11-25 08:03:06', '2025-11-25 08:03:06'),
(1052, 'Cập nhật quy trình', 'Công việc: 5555555 vừa được cập nhật quy trình mới', 17, 'Cập nhật', 0, '2025-11-25 08:03:11', '2025-11-25 08:03:11'),
(1053, 'Cập nhật công việc', 'Công việc: 5555555 vừa được cập nhật mới', 17, 'Cập nhật', 0, '2025-11-25 08:03:11', '2025-11-25 08:03:11'),
(1054, 'Thêm mới quy trình', 'Công việc: 11111 vừa được thêm quy trình mới', 17, 'Cập nhật', 0, '2025-11-25 08:03:30', '2025-11-25 08:03:30'),
(1055, 'Cập nhật công việc', 'Công việc: 11111 vừa được cập nhật mới', 17, 'Cập nhật', 0, '2025-11-25 08:03:31', '2025-11-25 08:03:31'),
(1056, 'Công việc mới', 'Bạn được giao công việc: 11111. Hạn: 2025-11-29.', 25, 'Công việc mới', 0, '2025-11-26 02:03:20', '2025-11-26 02:03:20'),
(1057, 'Thêm mới quy trình', 'Công việc: 11111 vừa được thêm quy trình mới', 25, 'Cập nhật', 0, '2025-11-26 04:35:45', '2025-11-26 04:35:45'),
(1058, 'Đánh giá công việc mới', 'Bạn vừa có thêm đánh giá cho công việc.', 11, 'Đánh giá', 0, '2025-11-26 09:20:32', '2025-11-26 09:20:32'),
(1059, 'Đánh giá công việc mới', 'Bạn vừa có thêm đánh giá cho công việc.', 25, 'Đánh giá', 0, '2025-11-26 09:42:42', '2025-11-26 09:42:42'),
(1060, 'Đánh giá công việc mới', 'Bạn vừa có thêm đánh giá cho công việc.', 25, 'Đánh giá', 0, '2025-11-26 09:43:21', '2025-11-26 09:43:21'),
(1061, 'Đánh giá công việc mới', 'Bạn vừa có thêm đánh giá cho công việc.', 25, 'Đánh giá', 0, '2025-11-26 09:43:30', '2025-11-26 09:43:30'),
(1062, 'Đánh giá công việc mới', 'Bạn vừa có thêm đánh giá cho công việc.', 25, 'Đánh giá', 0, '2025-11-26 09:57:35', '2025-11-26 09:57:35'),
(1063, 'Đánh giá công việc mới', 'Bạn vừa có thêm đánh giá cho công việc.', 25, 'Đánh giá', 0, '2025-11-26 09:58:41', '2025-11-26 09:58:41'),
(1064, 'Đánh giá công việc mới', 'Bạn vừa có thêm đánh giá cho công việc.', 25, 'Đánh giá', 0, '2025-11-26 09:59:55', '2025-11-26 09:59:55'),
(1065, 'Đánh giá công việc mới', 'Bạn vừa có thêm đánh giá cho công việc.', 25, 'Đánh giá', 0, '2025-11-26 17:23:15', '2025-11-26 17:23:15'),
(1066, 'Đánh giá công việc mới', 'Bạn vừa có thêm đánh giá cho công việc.', 25, 'Đánh giá', 0, '2025-11-26 17:23:59', '2025-11-26 17:23:59'),
(1067, 'Đánh giá công việc mới', 'Bạn vừa có thêm đánh giá cho công việc.', 25, 'Đánh giá', 0, '2025-11-26 17:24:22', '2025-11-26 17:24:22'),
(1068, 'Đánh giá công việc mới', 'Bạn vừa có thêm đánh giá cho công việc.', 25, 'Đánh giá', 0, '2025-11-26 17:38:37', '2025-11-26 17:38:37'),
(1069, 'Đánh giá công việc mới', 'Bạn vừa có thêm đánh giá cho công việc.', 25, 'Đánh giá', 0, '2025-11-26 17:39:00', '2025-11-26 17:39:00'),
(1070, 'Đánh giá công việc mới', 'Bạn vừa có thêm đánh giá cho công việc.', 25, 'Đánh giá', 0, '2025-11-26 17:39:12', '2025-11-26 17:39:12'),
(1071, 'Đánh giá công việc mới', 'Bạn vừa có thêm đánh giá cho công việc.', 25, 'Đánh giá', 0, '2025-11-26 17:41:53', '2025-11-26 17:41:53'),
(1072, 'Cập nhật công việc', 'Công việc: 11111 vừa được cập nhật mới', 25, 'Cập nhật', 0, '2025-11-26 17:42:37', '2025-11-26 17:42:37'),
(1073, 'Cập nhật công việc', 'Công việc: 11111 vừa được cập nhật mới', 8, 'Cập nhật', 0, '2025-11-26 17:42:37', '2025-11-26 17:42:37'),
(1074, 'Đánh giá công việc mới', 'Bạn vừa có thêm đánh giá cho công việc.', 25, 'Đánh giá', 0, '2025-11-26 17:42:46', '2025-11-26 17:42:46'),
(1075, 'Đánh giá công việc mới', 'Bạn vừa có thêm đánh giá cho công việc.', 8, 'Đánh giá', 0, '2025-11-26 17:42:46', '2025-11-26 17:42:46'),
(1076, 'Đánh giá công việc mới', 'Bạn vừa có thêm đánh giá cho công việc.', 25, 'Đánh giá', 0, '2025-11-26 17:43:06', '2025-11-26 17:43:06'),
(1077, 'Đánh giá công việc mới', 'Bạn vừa có thêm đánh giá cho công việc.', 8, 'Đánh giá', 0, '2025-11-26 17:43:06', '2025-11-26 17:43:06'),
(1078, 'Đánh giá công việc mới', 'Bạn vừa có thêm đánh giá cho công việc.', 25, 'Đánh giá', 0, '2025-11-26 17:43:57', '2025-11-26 17:43:57'),
(1079, 'Đánh giá công việc mới', 'Bạn vừa có thêm đánh giá cho công việc.', 8, 'Đánh giá', 0, '2025-11-26 17:43:57', '2025-11-26 17:43:57'),
(1080, 'Đánh giá công việc mới', 'Bạn vừa có thêm đánh giá cho công việc.', 11, 'Đánh giá', 0, '2025-11-27 01:57:40', '2025-11-27 01:57:40'),
(1081, 'Cập nhật công việc', 'Công việc: Giới thiệu smartdashboard vừa được cập nhật mới', 11, 'Cập nhật', 0, '2025-11-27 02:10:28', '2025-11-27 02:10:28'),
(1082, 'Cập nhật công việc', 'Công việc: Giới thiệu smartdashboard vừa được cập nhật mới', 8, 'Cập nhật', 0, '2025-11-27 02:10:28', '2025-11-27 02:10:28'),
(1083, 'Đánh giá công việc mới', 'Bạn vừa có thêm đánh giá cho công việc.', 11, 'Đánh giá', 0, '2025-11-27 02:12:21', '2025-11-27 02:12:21'),
(1084, 'Đánh giá công việc mới', 'Bạn vừa có thêm đánh giá cho công việc.', 8, 'Đánh giá', 0, '2025-11-27 02:12:21', '2025-11-27 02:12:21'),
(1085, 'Cập nhật công việc', 'Công việc: Giới thiệu smartdashboard vừa được cập nhật mới', 8, 'Cập nhật', 0, '2025-11-27 02:15:37', '2025-11-27 02:15:37'),
(1086, 'Cập nhật công việc', 'Công việc: Giới thiệu smartdashboard vừa được cập nhật mới', 23, 'Cập nhật', 0, '2025-11-27 02:15:37', '2025-11-27 02:15:37'),
(1087, 'Công việc mới', 'Bạn được giao công việc: 1. Hạn: 2025-11-28.', 18, 'Công việc mới', 1, '2025-12-02 07:59:14', '2025-11-27 02:27:50'),
(1088, 'Công việc mới', 'Bạn được giao công việc: 2. Hạn: 2025-11-28.', 18, 'Công việc mới', 1, '2025-12-02 07:59:13', '2025-11-27 02:28:28'),
(1089, 'Công việc mới', 'Bạn được giao công việc: 2. Hạn: 2025-11-28.', 8, 'Công việc mới', 0, '2025-11-27 02:44:34', '2025-11-27 02:44:34'),
(1090, 'Cập nhật công việc', 'Công việc: Giới thiệu smartdashboard vừa được cập nhật mới', 8, 'Cập nhật', 0, '2025-11-27 02:47:36', '2025-11-27 02:47:36'),
(1091, 'Cập nhật công việc', 'Công việc: Giới thiệu smartdashboard vừa được cập nhật mới', 23, 'Cập nhật', 0, '2025-11-27 02:47:36', '2025-11-27 02:47:36'),
(1092, 'Công việc mới', 'Bạn được giao công việc: 1. Hạn: 2025-11-28.', 17, 'Công việc mới', 0, '2025-11-27 03:07:14', '2025-11-27 03:07:14'),
(1093, 'Công việc mới', 'Bạn được giao công việc: 1. Hạn: 2025-11-24.', 21, 'Công việc mới', 0, '2025-11-27 03:11:43', '2025-11-27 03:11:43'),
(1094, 'Cập nhật công việc', 'Công việc: 1 vừa được cập nhật mới', 22, 'Cập nhật', 0, '2025-11-27 03:12:24', '2025-11-27 03:12:24'),
(1095, 'Cập nhật công việc', 'Công việc: 1 vừa được cập nhật mới', 4, 'Cập nhật', 0, '2025-11-27 03:12:24', '2025-11-27 03:12:24'),
(1096, 'Cập nhật công việc', 'Công việc: 1 vừa được cập nhật mới', 11, 'Cập nhật', 0, '2025-11-27 03:12:24', '2025-11-27 03:12:24'),
(1097, 'Cập nhật công việc', 'Công việc: 1 vừa được cập nhật mới', 6, 'Cập nhật', 0, '2025-11-27 03:12:24', '2025-11-27 03:12:24'),
(1098, 'Cập nhật công việc', 'Công việc: 1 vừa được cập nhật mới', 3, 'Cập nhật', 0, '2025-11-27 03:12:24', '2025-11-27 03:12:24'),
(1099, 'Cập nhật công việc', 'Công việc: 1 vừa được cập nhật mới', 21, 'Cập nhật', 0, '2025-11-27 03:12:24', '2025-11-27 03:12:24'),
(1100, 'Cập nhật công việc', 'Công việc: 1 vừa được cập nhật mới', 23, 'Cập nhật', 0, '2025-11-27 03:12:24', '2025-11-27 03:12:24'),
(1101, 'Đánh giá công việc mới', 'Bạn vừa có thêm đánh giá cho công việc.', 22, 'Đánh giá', 0, '2025-11-27 03:12:33', '2025-11-27 03:12:33'),
(1102, 'Đánh giá công việc mới', 'Bạn vừa có thêm đánh giá cho công việc.', 4, 'Đánh giá', 0, '2025-11-27 03:12:33', '2025-11-27 03:12:33'),
(1103, 'Đánh giá công việc mới', 'Bạn vừa có thêm đánh giá cho công việc.', 11, 'Đánh giá', 0, '2025-11-27 03:12:33', '2025-11-27 03:12:33'),
(1104, 'Đánh giá công việc mới', 'Bạn vừa có thêm đánh giá cho công việc.', 6, 'Đánh giá', 0, '2025-11-27 03:12:33', '2025-11-27 03:12:33'),
(1105, 'Đánh giá công việc mới', 'Bạn vừa có thêm đánh giá cho công việc.', 3, 'Đánh giá', 0, '2025-11-27 03:12:33', '2025-11-27 03:12:33'),
(1106, 'Đánh giá công việc mới', 'Bạn vừa có thêm đánh giá cho công việc.', 21, 'Đánh giá', 0, '2025-11-27 03:12:33', '2025-11-27 03:12:33'),
(1107, 'Đánh giá công việc mới', 'Bạn vừa có thêm đánh giá cho công việc.', 23, 'Đánh giá', 0, '2025-11-27 03:12:33', '2025-11-27 03:12:33'),
(1108, 'Đánh giá công việc mới', 'Bạn vừa có thêm đánh giá cho công việc.', 22, 'Đánh giá', 0, '2025-11-27 03:12:36', '2025-11-27 03:12:36'),
(1109, 'Đánh giá công việc mới', 'Bạn vừa có thêm đánh giá cho công việc.', 4, 'Đánh giá', 0, '2025-11-27 03:12:36', '2025-11-27 03:12:36'),
(1110, 'Đánh giá công việc mới', 'Bạn vừa có thêm đánh giá cho công việc.', 11, 'Đánh giá', 0, '2025-11-27 03:12:36', '2025-11-27 03:12:36'),
(1111, 'Đánh giá công việc mới', 'Bạn vừa có thêm đánh giá cho công việc.', 6, 'Đánh giá', 0, '2025-11-27 03:12:36', '2025-11-27 03:12:36'),
(1112, 'Đánh giá công việc mới', 'Bạn vừa có thêm đánh giá cho công việc.', 3, 'Đánh giá', 0, '2025-11-27 03:12:36', '2025-11-27 03:12:36'),
(1113, 'Đánh giá công việc mới', 'Bạn vừa có thêm đánh giá cho công việc.', 21, 'Đánh giá', 0, '2025-11-27 03:12:36', '2025-11-27 03:12:36'),
(1114, 'Đánh giá công việc mới', 'Bạn vừa có thêm đánh giá cho công việc.', 23, 'Đánh giá', 0, '2025-11-27 03:12:36', '2025-11-27 03:12:36'),
(1115, 'Thêm mới quy trình', 'Công việc: Trong tháng 9 đến giữa tháng 10 phải bán được 1 Dashboard vừa được thêm quy trình mới', 11, 'Cập nhật', 0, '2025-11-27 09:27:51', '2025-11-27 09:27:51'),
(1116, 'Cập nhật công việc', 'Công việc: Trong tháng 9 đến giữa tháng 10 phải bán được 1 Dashboard vừa được cập nhật mới', 11, 'Cập nhật', 0, '2025-11-27 09:42:26', '2025-11-27 09:42:26'),
(1117, 'Cập nhật công việc', 'Công việc: Trong tháng 9 đến giữa tháng 10 phải bán được 1 Dashboard vừa được cập nhật mới', 27, 'Cập nhật', 0, '2025-11-27 09:42:26', '2025-11-27 09:42:26'),
(1118, 'Xóa bỏ quy trình', 'Công việc: Trong tháng 9 đến giữa tháng 10 phải bán được 1 Dashboard vừa xóa bỏ một quy trình', 11, 'Cập nhật', 0, '2025-11-27 09:52:12', '2025-11-27 09:52:12'),
(1119, 'Xóa bỏ quy trình', 'Công việc: Trong tháng 9 đến giữa tháng 10 phải bán được 1 Dashboard vừa xóa bỏ một quy trình', 27, 'Cập nhật', 0, '2025-11-27 09:52:12', '2025-11-27 09:52:12'),
(1120, 'Xóa bỏ quy trình', 'Công việc: Trong tháng 9 đến giữa tháng 10 phải bán được 1 Dashboard vừa xóa bỏ một quy trình', 11, 'Cập nhật', 0, '2025-11-27 09:52:13', '2025-11-27 09:52:13'),
(1121, 'Xóa bỏ quy trình', 'Công việc: Trong tháng 9 đến giữa tháng 10 phải bán được 1 Dashboard vừa xóa bỏ một quy trình', 27, 'Cập nhật', 0, '2025-11-27 09:52:13', '2025-11-27 09:52:13'),
(1122, 'Xóa bỏ quy trình', 'Công việc: Trong tháng 9 đến giữa tháng 10 phải bán được 1 Dashboard vừa xóa bỏ một quy trình', 11, 'Cập nhật', 0, '2025-11-27 09:52:18', '2025-11-27 09:52:18'),
(1123, 'Xóa bỏ quy trình', 'Công việc: Trong tháng 9 đến giữa tháng 10 phải bán được 1 Dashboard vừa xóa bỏ một quy trình', 27, 'Cập nhật', 0, '2025-11-27 09:52:18', '2025-11-27 09:52:18'),
(1124, 'Thêm mới quy trình', 'Công việc: Trong tháng 9 đến giữa tháng 10 phải bán được 1 Dashboard vừa được thêm quy trình mới', 11, 'Cập nhật', 0, '2025-11-27 09:52:35', '2025-11-27 09:52:35'),
(1125, 'Thêm mới quy trình', 'Công việc: Trong tháng 9 đến giữa tháng 10 phải bán được 1 Dashboard vừa được thêm quy trình mới', 27, 'Cập nhật', 0, '2025-11-27 09:52:35', '2025-11-27 09:52:35'),
(1126, 'Cập nhật quy trình', 'Công việc: Trong tháng 9 đến giữa tháng 10 phải bán được 1 Dashboard vừa được cập nhật quy trình mới', 11, 'Cập nhật', 0, '2025-11-27 18:28:11', '2025-11-27 18:28:11'),
(1127, 'Cập nhật quy trình', 'Công việc: Trong tháng 9 đến giữa tháng 10 phải bán được 1 Dashboard vừa được cập nhật quy trình mới', 27, 'Cập nhật', 0, '2025-11-27 18:28:11', '2025-11-27 18:28:11'),
(1128, 'Cập nhật quy trình', 'Công việc: Oracle cloud: Ký hợp đồng với 3C vừa được cập nhật quy trình mới', 11, 'Cập nhật', 0, '2025-11-27 18:38:26', '2025-11-27 18:38:26'),
(1129, 'Cập nhật công việc', 'Công việc: Oracle cloud: Ký hợp đồng với 3C vừa được cập nhật mới', 11, 'Cập nhật', 0, '2025-11-27 18:38:29', '2025-11-27 18:38:29'),
(1130, 'Cập nhật quy trình', 'Công việc: Trong tháng 9 đến giữa tháng 10 phải bán được 1 Dashboard vừa được cập nhật quy trình mới', 11, 'Cập nhật', 0, '2025-11-28 01:45:44', '2025-11-28 01:45:44'),
(1131, 'Cập nhật quy trình', 'Công việc: Trong tháng 9 đến giữa tháng 10 phải bán được 1 Dashboard vừa được cập nhật quy trình mới', 27, 'Cập nhật', 0, '2025-11-28 01:45:44', '2025-11-28 01:45:44'),
(1132, 'Cập nhật quy trình', 'Công việc: Đưa mini app lên hệ thống Zalo Demo vừa được cập nhật quy trình mới', 25, 'Cập nhật', 0, '2025-11-28 04:10:26', '2025-11-28 04:10:26'),
(1133, 'Cập nhật quy trình', 'Công việc: Đưa mini app lên hệ thống Zalo Demo vừa được cập nhật quy trình mới', 6, 'Cập nhật', 0, '2025-11-28 04:10:26', '2025-11-28 04:10:26'),
(1134, 'Công việc mới', 'Bạn được giao công việc: 1. Hạn: 2025-11-29.', 17, 'Công việc mới', 0, '2025-11-28 08:14:08', '2025-11-28 08:14:08'),
(1135, 'Công việc mới', 'Bạn được giao công việc: 1. Hạn: 2025-11-29.', 17, 'Công việc mới', 0, '2025-11-28 08:15:36', '2025-11-28 08:15:36'),
(1136, 'Thêm mới quy trình', 'Công việc: 1 vừa được thêm quy trình mới', 17, 'Cập nhật', 0, '2025-11-28 08:16:11', '2025-11-28 08:16:11'),
(1137, 'Cập nhật công việc', 'Công việc: 1 vừa được cập nhật mới', 17, 'Cập nhật', 0, '2025-11-28 08:16:23', '2025-11-28 08:16:23'),
(1138, 'Thêm mới quy trình', 'Công việc: 1 vừa được thêm quy trình mới', 17, 'Cập nhật', 0, '2025-11-28 08:16:44', '2025-11-28 08:16:44'),
(1139, 'Xóa bỏ quy trình', 'Công việc: Trong tháng 9 đến giữa tháng 10 phải bán được 1 Dashboard vừa xóa bỏ một quy trình', 11, 'Cập nhật', 0, '2025-11-28 08:17:21', '2025-11-28 08:17:21'),
(1140, 'Xóa bỏ quy trình', 'Công việc: Trong tháng 9 đến giữa tháng 10 phải bán được 1 Dashboard vừa xóa bỏ một quy trình', 27, 'Cập nhật', 0, '2025-11-28 08:17:21', '2025-11-28 08:17:21'),
(1141, 'Thêm mới quy trình', 'Công việc: Trong tháng 9 đến giữa tháng 10 phải bán được 1 Dashboard vừa được thêm quy trình mới', 11, 'Cập nhật', 0, '2025-11-28 08:17:50', '2025-11-28 08:17:50'),
(1142, 'Thêm mới quy trình', 'Công việc: Trong tháng 9 đến giữa tháng 10 phải bán được 1 Dashboard vừa được thêm quy trình mới', 27, 'Cập nhật', 0, '2025-11-28 08:17:50', '2025-11-28 08:17:50'),
(1143, 'Cập nhật công việc', 'Công việc: Trong tháng 9 đến giữa tháng 10 phải bán được 1 Dashboard vừa được cập nhật mới', 11, 'Cập nhật', 0, '2025-11-28 08:33:36', '2025-11-28 08:33:36'),
(1144, 'Cập nhật công việc', 'Công việc: Trong tháng 9 đến giữa tháng 10 phải bán được 1 Dashboard vừa được cập nhật mới', 27, 'Cập nhật', 0, '2025-11-28 08:33:36', '2025-11-28 08:33:36'),
(1145, 'Thêm mới quy trình', 'Công việc: Trong tháng 9 đến giữa tháng 10 phải bán được 1 Dashboard vừa được thêm quy trình mới', 11, 'Cập nhật', 0, '2025-11-28 08:34:02', '2025-11-28 08:34:02'),
(1146, 'Thêm mới quy trình', 'Công việc: Trong tháng 9 đến giữa tháng 10 phải bán được 1 Dashboard vừa được thêm quy trình mới', 27, 'Cập nhật', 0, '2025-11-28 08:34:02', '2025-11-28 08:34:02'),
(1147, 'Cập nhật công việc', 'Công việc: Trong tháng 9 đến giữa tháng 10 phải bán được 1 Dashboard vừa được cập nhật mới', 11, 'Cập nhật', 0, '2025-11-28 08:34:07', '2025-11-28 08:34:07'),
(1148, 'Cập nhật công việc', 'Công việc: Trong tháng 9 đến giữa tháng 10 phải bán được 1 Dashboard vừa được cập nhật mới', 27, 'Cập nhật', 0, '2025-11-28 08:34:07', '2025-11-28 08:34:07'),
(1149, 'Xóa bỏ quy trình', 'Công việc: Trong tháng 9 đến giữa tháng 10 phải bán được 1 Dashboard vừa xóa bỏ một quy trình', 11, 'Cập nhật', 0, '2025-11-28 08:44:48', '2025-11-28 08:44:48'),
(1150, 'Xóa bỏ quy trình', 'Công việc: Trong tháng 9 đến giữa tháng 10 phải bán được 1 Dashboard vừa xóa bỏ một quy trình', 27, 'Cập nhật', 0, '2025-11-28 08:44:48', '2025-11-28 08:44:48'),
(1151, 'Thêm mới quy trình', 'Công việc: Trong tháng 9 đến giữa tháng 10 phải bán được 1 Dashboard vừa được thêm quy trình mới', 11, 'Cập nhật', 0, '2025-11-28 08:50:37', '2025-11-28 08:50:37'),
(1152, 'Thêm mới quy trình', 'Công việc: Trong tháng 9 đến giữa tháng 10 phải bán được 1 Dashboard vừa được thêm quy trình mới', 27, 'Cập nhật', 0, '2025-11-28 08:50:37', '2025-11-28 08:50:37'),
(1153, 'Xóa bỏ quy trình', 'Công việc: Trong tháng 9 đến giữa tháng 10 phải bán được 1 Dashboard vừa xóa bỏ một quy trình', 11, 'Cập nhật', 0, '2025-11-28 08:54:04', '2025-11-28 08:54:04'),
(1154, 'Xóa bỏ quy trình', 'Công việc: Trong tháng 9 đến giữa tháng 10 phải bán được 1 Dashboard vừa xóa bỏ một quy trình', 27, 'Cập nhật', 0, '2025-11-28 08:54:04', '2025-11-28 08:54:04'),
(1155, 'Cập nhật công việc', 'Công việc: ba sáu vừa được cập nhật mới', 15, 'Cập nhật', 0, '2025-11-28 09:14:49', '2025-11-28 09:14:49'),
(1156, 'Cập nhật công việc', 'Công việc: ba sáu vừa được cập nhật mới', 5, 'Cập nhật', 0, '2025-11-28 09:14:49', '2025-11-28 09:14:49'),
(1157, 'Thêm mới quy trình', 'Công việc: ba sáu vừa được thêm quy trình mới', 15, 'Cập nhật', 0, '2025-11-28 09:15:06', '2025-11-28 09:15:06'),
(1158, 'Thêm mới quy trình', 'Công việc: ba sáu vừa được thêm quy trình mới', 5, 'Cập nhật', 0, '2025-11-28 09:15:06', '2025-11-28 09:15:06'),
(1159, 'Công việc mới', 'Bạn được giao công việc: ba sáu. Hạn: 2025-11-29.', 23, 'Công việc mới', 0, '2025-11-29 02:46:41', '2025-11-29 02:46:41'),
(1160, 'Công việc mới', 'Bạn được giao công việc: ba sáu. Hạn: 2025-11-29.', 17, 'Công việc mới', 0, '2025-11-29 02:46:41', '2025-11-29 02:46:41'),
(1161, 'Công việc mới', 'Bạn được giao công việc: ba bảy. Hạn: 2025-11-29.', 23, 'Công việc mới', 0, '2025-11-29 02:47:18', '2025-11-29 02:47:18'),
(1162, 'Công việc mới', 'Bạn được giao công việc: ba bảy. Hạn: 2025-11-29.', 17, 'Công việc mới', 0, '2025-11-29 02:47:19', '2025-11-29 02:47:19'),
(1163, 'Công việc mới', 'Bạn được giao công việc: ba sáu. Hạn: 2025-11-29.', 23, 'Công việc mới', 0, '2025-11-29 02:47:49', '2025-11-29 02:47:49'),
(1164, 'Công việc mới', 'Bạn được giao công việc: ba sáu. Hạn: 2025-11-29.', 17, 'Công việc mới', 0, '2025-11-29 02:47:49', '2025-11-29 02:47:49'),
(1165, 'Công việc mới', 'Bạn được giao công việc: ba sáu. Hạn: 2025-11-29.', 23, 'Công việc mới', 0, '2025-11-29 02:55:03', '2025-11-29 02:55:03'),
(1166, 'Công việc mới', 'Bạn được giao công việc: ba sáu. Hạn: 2025-11-29.', 17, 'Công việc mới', 0, '2025-11-29 02:55:03', '2025-11-29 02:55:03'),
(1167, 'Cập nhật công việc', 'Công việc: Làm việc với CyStack để nắm khi nào khảo sát vừa được cập nhật mới', 24, 'Cập nhật', 0, '2025-12-01 06:36:47', '2025-12-01 06:36:47'),
(1168, 'Cập nhật công việc', 'Công việc: Làm việc với CyStack để nắm khi nào khảo sát vừa được cập nhật mới', 6, 'Cập nhật', 0, '2025-12-01 06:36:47', '2025-12-01 06:36:47'),
(1169, 'Công việc mới', 'Bạn được giao công việc: ba sáu. Hạn: 2025-11-29.', 17, 'Công việc mới', 0, '2025-12-01 06:37:35', '2025-12-01 06:37:35'),
(1170, 'Công việc mới', 'Bạn được giao công việc: ba sáu. Hạn: 2025-11-29.', 17, 'Công việc mới', 0, '2025-12-01 06:38:24', '2025-12-01 06:38:24'),
(1171, 'Công việc mới', 'Bạn được giao công việc: ba sáu. Hạn: 2025-11-29.', 17, 'Công việc mới', 0, '2025-12-01 06:45:30', '2025-12-01 06:45:30'),
(1172, 'Cập nhật công việc', 'Công việc: ba sáu vừa được cập nhật mới', 17, 'Cập nhật', 0, '2025-12-01 06:50:23', '2025-12-01 06:50:23'),
(1173, 'Thêm mới quy trình', 'Công việc: Triển khai CSA, lấy list danh sách web nhân viên sử dụng vừa được thêm quy trình mới', 24, 'Cập nhật', 0, '2025-12-01 07:02:44', '2025-12-01 07:02:44'),
(1174, 'Cập nhật công việc', 'Công việc: Triển khai CSA, lấy list danh sách web nhân viên sử dụng vừa được cập nhật mới', 24, 'Cập nhật', 0, '2025-12-01 07:03:04', '2025-12-01 07:03:04'),
(1175, 'Cập nhật quy trình', 'Công việc: Triển khai CSA, lấy list danh sách web nhân viên sử dụng vừa được cập nhật quy trình mới', 24, 'Cập nhật', 0, '2025-12-01 07:03:15', '2025-12-01 07:03:15'),
(1176, 'Cập nhật công việc', 'Công việc: Triển khai CSA, lấy list danh sách web nhân viên sử dụng vừa được cập nhật mới', 24, 'Cập nhật', 0, '2025-12-01 07:03:16', '2025-12-01 07:03:16'),
(1177, 'Cập nhật quy trình', 'Công việc: Triển khai CSA, lấy list danh sách web nhân viên sử dụng vừa được cập nhật quy trình mới', 24, 'Cập nhật', 0, '2025-12-01 07:03:24', '2025-12-01 07:03:24'),
(1178, 'Cập nhật công việc', 'Công việc: Triển khai CSA, lấy list danh sách web nhân viên sử dụng vừa được cập nhật mới', 24, 'Cập nhật', 0, '2025-12-01 07:03:25', '2025-12-01 07:03:25'),
(1179, 'Cập nhật quy trình', 'Công việc: Triển khai CSA, lấy list danh sách web nhân viên sử dụng vừa được cập nhật quy trình mới', 24, 'Cập nhật', 0, '2025-12-01 07:27:27', '2025-12-01 07:27:27'),
(1180, 'Cập nhật công việc', 'Công việc: Triển khai CSA, lấy list danh sách web nhân viên sử dụng vừa được cập nhật mới', 24, 'Cập nhật', 0, '2025-12-01 07:27:28', '2025-12-01 07:27:28'),
(1181, 'Cập nhật công việc', 'Công việc: Bổ sung gói đào tạo 2 ngày, lên báo giá và các công việc triển khai vừa được cập nhật mới', 11, 'Cập nhật', 0, '2025-12-01 07:27:55', '2025-12-01 07:27:55'),
(1182, 'Cập nhật quy trình', 'Công việc: Triển khai CSA, lấy list danh sách web nhân viên sử dụng vừa được cập nhật quy trình mới', 24, 'Cập nhật', 0, '2025-12-01 07:42:46', '2025-12-01 07:42:46'),
(1183, 'Cập nhật công việc', 'Công việc: Triển khai CSA, lấy list danh sách web nhân viên sử dụng vừa được cập nhật mới', 24, 'Cập nhật', 0, '2025-12-01 07:42:47', '2025-12-01 07:42:47'),
(1184, 'Cập nhật công việc', 'Công việc: Bán được 5 gói đào tạo về AI vừa được cập nhật mới', 11, 'Cập nhật', 0, '2025-12-01 08:49:45', '2025-12-01 08:49:45'),
(1185, 'Cập nhật công việc', 'Công việc: Bán được 5 gói đào tạo về AI vừa được cập nhật mới', 10, 'Cập nhật', 0, '2025-12-01 08:49:45', '2025-12-01 08:49:45'),
(1186, 'Cập nhật công việc', 'Công việc: Bán được 5 gói đào tạo về AI vừa được cập nhật mới', 11, 'Cập nhật', 0, '2025-12-01 08:50:16', '2025-12-01 08:50:16'),
(1187, 'Cập nhật công việc', 'Công việc: Bán được 5 gói đào tạo về AI vừa được cập nhật mới', 10, 'Cập nhật', 0, '2025-12-01 08:50:16', '2025-12-01 08:50:16'),
(1188, 'Cập nhật công việc', 'Công việc: Bán được 5 gói đào tạo về AI vừa được cập nhật mới', 11, 'Cập nhật', 0, '2025-12-01 08:54:19', '2025-12-01 08:54:19'),
(1189, 'Cập nhật công việc', 'Công việc: Bán được 5 gói đào tạo về AI vừa được cập nhật mới', 10, 'Cập nhật', 0, '2025-12-01 08:54:19', '2025-12-01 08:54:19'),
(1190, 'Cập nhật công việc', 'Công việc: Bán được 5 gói đào tạo về AI vừa được cập nhật mới', 11, 'Cập nhật', 0, '2025-12-01 08:54:31', '2025-12-01 08:54:31'),
(1191, 'Cập nhật công việc', 'Công việc: Bán được 5 gói đào tạo về AI vừa được cập nhật mới', 10, 'Cập nhật', 0, '2025-12-01 08:54:31', '2025-12-01 08:54:31'),
(1192, 'Cập nhật quy trình', 'Công việc: Bán được 5 gói đào tạo về AI vừa được cập nhật quy trình mới', 11, 'Cập nhật', 0, '2025-12-01 08:55:07', '2025-12-01 08:55:07'),
(1193, 'Cập nhật quy trình', 'Công việc: Bán được 5 gói đào tạo về AI vừa được cập nhật quy trình mới', 10, 'Cập nhật', 0, '2025-12-01 08:55:07', '2025-12-01 08:55:07'),
(1194, 'Cập nhật công việc', 'Công việc: Bán được 5 gói đào tạo về AI vừa được cập nhật mới', 11, 'Cập nhật', 0, '2025-12-01 08:55:08', '2025-12-01 08:55:08'),
(1195, 'Cập nhật công việc', 'Công việc: Bán được 5 gói đào tạo về AI vừa được cập nhật mới', 10, 'Cập nhật', 0, '2025-12-01 08:55:08', '2025-12-01 08:55:08'),
(1196, 'Cập nhật quy trình', 'Công việc: Bán được 5 gói đào tạo về AI vừa được cập nhật quy trình mới', 11, 'Cập nhật', 0, '2025-12-01 08:55:34', '2025-12-01 08:55:34'),
(1197, 'Cập nhật quy trình', 'Công việc: Bán được 5 gói đào tạo về AI vừa được cập nhật quy trình mới', 10, 'Cập nhật', 0, '2025-12-01 08:55:34', '2025-12-01 08:55:34'),
(1198, 'Cập nhật công việc', 'Công việc: Bán được 5 gói đào tạo về AI vừa được cập nhật mới', 11, 'Cập nhật', 0, '2025-12-01 08:55:35', '2025-12-01 08:55:35'),
(1199, 'Cập nhật công việc', 'Công việc: Bán được 5 gói đào tạo về AI vừa được cập nhật mới', 10, 'Cập nhật', 0, '2025-12-01 08:55:35', '2025-12-01 08:55:35'),
(1200, 'Cập nhật công việc', 'Công việc: Bán được 5 gói đào tạo về AI vừa được cập nhật mới', 11, 'Cập nhật', 0, '2025-12-01 09:03:45', '2025-12-01 09:03:45'),
(1201, 'Cập nhật công việc', 'Công việc: Bán được 5 gói đào tạo về AI vừa được cập nhật mới', 10, 'Cập nhật', 0, '2025-12-01 09:03:45', '2025-12-01 09:03:45'),
(1202, 'Cập nhật công việc', 'Công việc: Bán được 5 gói đào tạo về AI vừa được cập nhật mới', 11, 'Cập nhật', 0, '2025-12-01 09:04:07', '2025-12-01 09:04:07'),
(1203, 'Cập nhật công việc', 'Công việc: Bán được 5 gói đào tạo về AI vừa được cập nhật mới', 10, 'Cập nhật', 0, '2025-12-01 09:04:07', '2025-12-01 09:04:07'),
(1204, 'Cập nhật công việc', 'Công việc: Bán được 5 gói đào tạo về AI vừa được cập nhật mới', 11, 'Cập nhật', 0, '2025-12-01 09:04:54', '2025-12-01 09:04:54'),
(1205, 'Cập nhật công việc', 'Công việc: Bán được 5 gói đào tạo về AI vừa được cập nhật mới', 10, 'Cập nhật', 0, '2025-12-01 09:04:54', '2025-12-01 09:04:54'),
(1206, 'Công việc mới', 'Bạn được giao công việc: Lên1 bản checklist quy trình giữa ICS và Luxtech. Hạn: 2025-12-26.', 18, 'Công việc mới', 1, '2025-12-02 08:02:10', '2025-12-02 08:02:04');

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
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_duan_lead` (`lead_id`);

--
-- Chỉ mục cho bảng `file_dinh_kem`
--
ALTER TABLE `file_dinh_kem`
  ADD PRIMARY KEY (`id`),
  ADD KEY `cong_viec_id` (`cong_viec_id`),
  ADD KEY `tien_do_id` (`tien_do_id`);

--
-- Chỉ mục cho bảng `he_thong_quyen`
--
ALTER TABLE `he_thong_quyen`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `ma_quyen` (`ma_quyen`),
  ADD KEY `idx_ma_quyen` (`ma_quyen`),
  ADD KEY `idx_nhom_quyen` (`nhom_quyen`);

--
-- Chỉ mục cho bảng `lich_su_phan_quyen`
--
ALTER TABLE `lich_su_phan_quyen`
  ADD PRIMARY KEY (`id`),
  ADD KEY `nguoi_thuc_hien_id` (`nguoi_thuc_hien_id`),
  ADD KEY `idx_nhan_vien` (`nhan_vien_id`),
  ADD KEY `idx_thoi_gian` (`thoi_gian`);

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
-- Chỉ mục cho bảng `nhanvien_quyen`
--
ALTER TABLE `nhanvien_quyen`
  ADD PRIMARY KEY (`nhanvien_id`,`quyen_id`),
  ADD KEY `quyen_id` (`quyen_id`);

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
-- Chỉ mục cho bảng `quyen`
--
ALTER TABLE `quyen`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `ma_quyen` (`ma_quyen`);

--
-- Chỉ mục cho bảng `quy_trinh_nguoi_nhan`
--
ALTER TABLE `quy_trinh_nguoi_nhan`
  ADD PRIMARY KEY (`id`),
  ADD KEY `step_id` (`step_id`),
  ADD KEY `nhan_id` (`nhan_id`);

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
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=606;

--
-- AUTO_INCREMENT cho bảng `cong_viec`
--
ALTER TABLE `cong_viec`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=311;

--
-- AUTO_INCREMENT cho bảng `cong_viec_danh_gia`
--
ALTER TABLE `cong_viec_danh_gia`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=32;

--
-- AUTO_INCREMENT cho bảng `cong_viec_lich_su`
--
ALTER TABLE `cong_viec_lich_su`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=621;

--
-- AUTO_INCREMENT cho bảng `cong_viec_nguoi_nhan`
--
ALTER TABLE `cong_viec_nguoi_nhan`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=840;

--
-- AUTO_INCREMENT cho bảng `cong_viec_quy_trinh`
--
ALTER TABLE `cong_viec_quy_trinh`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=294;

--
-- AUTO_INCREMENT cho bảng `cong_viec_tien_do`
--
ALTER TABLE `cong_viec_tien_do`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=199;

--
-- AUTO_INCREMENT cho bảng `du_an`
--
ALTER TABLE `du_an`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=77;

--
-- AUTO_INCREMENT cho bảng `file_dinh_kem`
--
ALTER TABLE `file_dinh_kem`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT cho bảng `he_thong_quyen`
--
ALTER TABLE `he_thong_quyen`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=30;

--
-- AUTO_INCREMENT cho bảng `lich_su_phan_quyen`
--
ALTER TABLE `lich_su_phan_quyen`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `lich_trinh`
--
ALTER TABLE `lich_trinh`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

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
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=28;

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
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT cho bảng `quyen`
--
ALTER TABLE `quyen`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=61;

--
-- AUTO_INCREMENT cho bảng `quy_trinh_nguoi_nhan`
--
ALTER TABLE `quy_trinh_nguoi_nhan`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20;

--
-- AUTO_INCREMENT cho bảng `thong_bao`
--
ALTER TABLE `thong_bao`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1207;

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
-- Các ràng buộc cho bảng `du_an`
--
ALTER TABLE `du_an`
  ADD CONSTRAINT `fk_duan_lead` FOREIGN KEY (`lead_id`) REFERENCES `nhanvien` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Các ràng buộc cho bảng `file_dinh_kem`
--
ALTER TABLE `file_dinh_kem`
  ADD CONSTRAINT `file_dinh_kem_ibfk_1` FOREIGN KEY (`cong_viec_id`) REFERENCES `cong_viec` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `file_dinh_kem_ibfk_2` FOREIGN KEY (`tien_do_id`) REFERENCES `cong_viec_tien_do` (`id`) ON DELETE CASCADE;

--
-- Các ràng buộc cho bảng `lich_su_phan_quyen`
--
ALTER TABLE `lich_su_phan_quyen`
  ADD CONSTRAINT `lich_su_phan_quyen_ibfk_1` FOREIGN KEY (`nhan_vien_id`) REFERENCES `nhanvien` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `lich_su_phan_quyen_ibfk_2` FOREIGN KEY (`nguoi_thuc_hien_id`) REFERENCES `nhanvien` (`id`) ON DELETE SET NULL;

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
-- Các ràng buộc cho bảng `nhanvien_quyen`
--
ALTER TABLE `nhanvien_quyen`
  ADD CONSTRAINT `nhanvien_quyen_ibfk_1` FOREIGN KEY (`nhanvien_id`) REFERENCES `nhanvien` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `nhanvien_quyen_ibfk_2` FOREIGN KEY (`quyen_id`) REFERENCES `quyen` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

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
-- Các ràng buộc cho bảng `quy_trinh_nguoi_nhan`
--
ALTER TABLE `quy_trinh_nguoi_nhan`
  ADD CONSTRAINT `quy_trinh_nguoi_nhan_ibfk_1` FOREIGN KEY (`step_id`) REFERENCES `cong_viec_quy_trinh` (`id`),
  ADD CONSTRAINT `quy_trinh_nguoi_nhan_ibfk_2` FOREIGN KEY (`nhan_id`) REFERENCES `nhanvien` (`id`);

--
-- Các ràng buộc cho bảng `thong_bao`
--
ALTER TABLE `thong_bao`
  ADD CONSTRAINT `thong_bao_ibfk_1` FOREIGN KEY (`nguoi_nhan_id`) REFERENCES `nhanvien` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
