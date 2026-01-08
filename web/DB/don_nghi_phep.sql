-- ============================================
-- BẢNG QUẢN LÝ ĐƠN XIN NGHỈ PHÉP
-- Author: ICSS System
-- Date: 2025
-- ============================================

-- Tạo bảng đơn nghỉ phép
CREATE TABLE IF NOT EXISTS `don_nghi_phep` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nhan_vien_id` int(11) NOT NULL COMMENT 'ID nhân viên gửi đơn',
  `loai_phep` varchar(50) NOT NULL COMMENT 'Loại nghỉ phép: Phép năm, Phép không lương, Nghỉ ốm, Nghỉ thai sản, Nghỉ việc riêng, Khác',
  `ngay_bat_dau` date NOT NULL COMMENT 'Ngày bắt đầu nghỉ',
  `ngay_ket_thuc` date NOT NULL COMMENT 'Ngày kết thúc nghỉ',
  `so_ngay` decimal(4,1) NOT NULL COMMENT 'Số ngày nghỉ (có thể 0.5 cho nửa ngày)',
  `ly_do` text NOT NULL COMMENT 'Lý do xin nghỉ',
  `trang_thai` enum('cho_duyet','da_duyet','tu_choi') DEFAULT 'cho_duyet' COMMENT 'Trạng thái đơn',
  `ly_do_tu_choi` text DEFAULT NULL COMMENT 'Lý do từ chối (nếu có)',
  `nguoi_duyet_id` int(11) DEFAULT NULL COMMENT 'ID người duyệt đơn',
  `nguoi_tao_id` int(11) DEFAULT NULL COMMENT 'ID người tạo đơn (nếu admin tạo hộ)',
  `thoi_gian_tao` timestamp NOT NULL DEFAULT current_timestamp() COMMENT 'Thời gian tạo đơn',
  `thoi_gian_duyet` timestamp NULL DEFAULT NULL COMMENT 'Thời gian duyệt/từ chối',
  `ghi_chu` text DEFAULT NULL COMMENT 'Ghi chú thêm',
  PRIMARY KEY (`id`),
  KEY `idx_nhan_vien_id` (`nhan_vien_id`),
  KEY `idx_trang_thai` (`trang_thai`),
  KEY `idx_ngay_bat_dau` (`ngay_bat_dau`),
  KEY `idx_nguoi_duyet_id` (`nguoi_duyet_id`),
  CONSTRAINT `fk_don_nghi_phep_nhanvien` FOREIGN KEY (`nhan_vien_id`) REFERENCES `nhanvien` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_don_nghi_phep_nguoiduyet` FOREIGN KEY (`nguoi_duyet_id`) REFERENCES `nhanvien` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- BẢNG THỐNG KÊ SỐ NGÀY PHÉP THEO NĂM
-- ============================================

CREATE TABLE IF NOT EXISTS `ngay_phep_nam` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nhan_vien_id` int(11) NOT NULL,
  `nam` int(4) NOT NULL COMMENT 'Năm',
  `tong_ngay_phep` decimal(4,1) DEFAULT 12.0 COMMENT 'Tổng số ngày phép được cấp',
  `ngay_phep_da_dung` decimal(4,1) DEFAULT 0.0 COMMENT 'Số ngày đã sử dụng',
  `ngay_phep_con_lai` decimal(4,1) DEFAULT 12.0 COMMENT 'Số ngày còn lại',
  `ngay_cap_nhat` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_nhanvien_nam` (`nhan_vien_id`, `nam`),
  CONSTRAINT `fk_ngay_phep_nhanvien` FOREIGN KEY (`nhan_vien_id`) REFERENCES `nhanvien` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- DỮ LIỆU MẪU CHO TESTING
-- ============================================

-- Tạo số ngày phép năm 2025 cho tất cả nhân viên đang làm việc
INSERT IGNORE INTO `ngay_phep_nam` (`nhan_vien_id`, `nam`, `tong_ngay_phep`, `ngay_phep_da_dung`, `ngay_phep_con_lai`)
SELECT id, 2025, 12.0, 0.0, 12.0 
FROM nhanvien 
WHERE trang_thai_lam_viec = 'Đang làm';

-- Thêm một số đơn nghỉ phép mẫu
-- INSERT INTO `don_nghi_phep` (`nhan_vien_id`, `loai_phep`, `ngay_bat_dau`, `ngay_ket_thuc`, `so_ngay`, `ly_do`, `trang_thai`) VALUES
-- (3, 'Phép năm', '2025-01-15', '2025-01-16', 2.0, 'Nghỉ phép năm để giải quyết việc gia đình', 'cho_duyet'),
-- (5, 'Nghỉ ốm', '2025-01-10', '2025-01-10', 1.0, 'Bị cảm sốt, cần nghỉ ngơi', 'da_duyet'),
-- (7, 'Việc riêng', '2025-01-20', '2025-01-20', 0.5, 'Xin nghỉ nửa ngày chiều để đưa con đi khám bệnh', 'cho_duyet');

-- ============================================
-- VIEW THỐNG KÊ ĐƠN NGHỈ PHÉP
-- ============================================

CREATE OR REPLACE VIEW `v_don_nghi_phep_chi_tiet` AS
SELECT 
    d.id,
    d.nhan_vien_id,
    nv.ho_ten AS ten_nhan_vien,
    nv.email AS email_nhan_vien,
    nv.avatar_url,
    pb.ten_phong AS ten_phong_ban,
    d.loai_phep,
    d.ngay_bat_dau,
    d.ngay_ket_thuc,
    d.so_ngay,
    d.ly_do,
    d.trang_thai,
    d.ly_do_tu_choi,
    d.nguoi_duyet_id,
    nd.ho_ten AS ten_nguoi_duyet,
    d.nguoi_tao_id,
    nt.ho_ten AS ten_nguoi_tao,
    d.thoi_gian_tao,
    d.thoi_gian_duyet,
    d.ghi_chu,
    np.tong_ngay_phep,
    np.ngay_phep_da_dung,
    np.ngay_phep_con_lai
FROM don_nghi_phep d
LEFT JOIN nhanvien nv ON d.nhan_vien_id = nv.id
LEFT JOIN phong_ban pb ON nv.phong_ban_id = pb.id
LEFT JOIN nhanvien nd ON d.nguoi_duyet_id = nd.id
LEFT JOIN nhanvien nt ON d.nguoi_tao_id = nt.id
LEFT JOIN ngay_phep_nam np ON d.nhan_vien_id = np.nhan_vien_id AND YEAR(d.ngay_bat_dau) = np.nam;

-- ============================================
-- TRIGGER CẬP NHẬT SỐ NGÀY PHÉP KHI DUYỆT ĐƠN
-- ============================================

DELIMITER $$

CREATE TRIGGER IF NOT EXISTS `trg_cap_nhat_ngay_phep_sau_duyet`
AFTER UPDATE ON `don_nghi_phep`
FOR EACH ROW
BEGIN
    -- Nếu đơn được duyệt (chuyển từ cho_duyet sang da_duyet) và là phép năm
    IF NEW.trang_thai = 'da_duyet' AND OLD.trang_thai = 'cho_duyet' AND NEW.loai_phep = 'Phép năm' THEN
        -- Cập nhật số ngày phép đã dùng
        UPDATE ngay_phep_nam 
        SET 
            ngay_phep_da_dung = ngay_phep_da_dung + NEW.so_ngay,
            ngay_phep_con_lai = tong_ngay_phep - (ngay_phep_da_dung + NEW.so_ngay)
        WHERE nhan_vien_id = NEW.nhan_vien_id 
        AND nam = YEAR(NEW.ngay_bat_dau);
    END IF;
    
    -- Nếu đơn đã duyệt bị từ chối lại (hoàn lại ngày phép) và là phép năm
    IF NEW.trang_thai = 'tu_choi' AND OLD.trang_thai = 'da_duyet' AND NEW.loai_phep = 'Phép năm' THEN
        UPDATE ngay_phep_nam 
        SET 
            ngay_phep_da_dung = GREATEST(0, ngay_phep_da_dung - NEW.so_ngay),
            ngay_phep_con_lai = tong_ngay_phep - GREATEST(0, ngay_phep_da_dung - NEW.so_ngay)
        WHERE nhan_vien_id = NEW.nhan_vien_id 
        AND nam = YEAR(NEW.ngay_bat_dau);
    END IF;
END$$

DELIMITER ;

-- ============================================
-- STORED PROCEDURE TẠO NGÀY PHÉP ĐẦU NĂM
-- ============================================

DELIMITER $$

CREATE PROCEDURE IF NOT EXISTS `sp_tao_ngay_phep_nam_moi`(IN p_nam INT)
BEGIN
    DECLARE v_so_ngay_phep DECIMAL(4,1);
    
    -- Lấy số ngày phép từ cấu hình
    SELECT CAST(gia_tri AS DECIMAL(4,1)) INTO v_so_ngay_phep
    FROM cau_hinh_he_thong 
    WHERE ten_cau_hinh = 'annual_leave_days';
    
    IF v_so_ngay_phep IS NULL THEN
        SET v_so_ngay_phep = 12.0;
    END IF;
    
    -- Tạo bản ghi ngày phép cho năm mới
    INSERT IGNORE INTO ngay_phep_nam (nhan_vien_id, nam, tong_ngay_phep, ngay_phep_da_dung, ngay_phep_con_lai)
    SELECT id, p_nam, v_so_ngay_phep, 0.0, v_so_ngay_phep
    FROM nhanvien 
    WHERE trang_thai_lam_viec = 'Đang làm';
    
END$$

DELIMITER ;

-- Chạy procedure để tạo ngày phép năm 2025
-- CALL sp_tao_ngay_phep_nam_moi(2025);
