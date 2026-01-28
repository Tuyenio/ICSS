-- Script cập nhật database cho hệ thống nghỉ phép mới
-- Chạy script này trên database hiện tại

-- 1. Thêm cột mới vào bảng ngay_phep_nam để quản lý ngày phép năm cũ và đánh dấu nhân viên
ALTER TABLE `ngay_phep_nam` 
ADD COLUMN `ngay_phep_nam_truoc` DECIMAL(4,1) DEFAULT 0.0 COMMENT 'Số ngày phép năm trước chuyển sang' AFTER `ngay_phep_con_lai`,
ADD COLUMN `da_cong_phep_dau_nam` TINYINT(1) DEFAULT 0 COMMENT '1 = Đã cộng 12 ngày đầu năm, không cộng hàng tháng nữa' AFTER `ngay_phep_nam_truoc`;

-- 2. Tạo bảng lưu danh sách ngày nghỉ lễ
CREATE TABLE IF NOT EXISTS `ngay_nghi_le` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `ten_ngay_le` VARCHAR(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Tên ngày lễ',
  `ngay_bat_dau` DATE NOT NULL COMMENT 'Ngày bắt đầu nghỉ lễ',
  `ngay_ket_thuc` DATE NOT NULL COMMENT 'Ngày kết thúc nghỉ lễ',
  `lap_lai_hang_nam` TINYINT(1) DEFAULT 0 COMMENT '1 = lặp lại hàng năm (Tết, Quốc khánh...)',
  `ngay_tao` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_ngay_bat_dau` (`ngay_bat_dau`),
  KEY `idx_ngay_ket_thuc` (`ngay_ket_thuc`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 3. Thêm dữ liệu mẫu cho các ngày nghỉ lễ Việt Nam 2026
INSERT INTO `ngay_nghi_le` (`ten_ngay_le`, `ngay_bat_dau`, `ngay_ket_thuc`, `lap_lai_hang_nam`) VALUES
('Tết Dương lịch', '2026-01-01', '2026-01-01', 1),
('Tết Nguyên Đán', '2026-02-15', '2026-02-21', 0), -- Tết Âm lịch thay đổi hàng năm
('Giỗ Tổ Hùng Vương', '2026-04-02', '2026-04-02', 0), -- 10/3 Âm lịch
('Ngày Giải phóng miền Nam', '2026-04-30', '2026-04-30', 1),
('Ngày Quốc tế Lao động', '2026-05-01', '2026-05-01', 1),
('Ngày Quốc khánh', '2026-09-02', '2026-09-02', 1);

-- 4. Tạo bảng lưu lịch sử cộng ngày phép tự động
CREATE TABLE IF NOT EXISTS `lich_su_cong_phep` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `nhan_vien_id` INT NOT NULL,
  `nam` INT NOT NULL,
  `thang` INT DEFAULT NULL COMMENT 'NULL = cộng đầu năm, có giá trị = cộng theo tháng',
  `so_ngay_cong` DECIMAL(4,1) NOT NULL COMMENT 'Số ngày phép được cộng',
  `loai_cong` ENUM('dau_nam', 'hang_thang') NOT NULL COMMENT 'Loại cộng phép',
  `ly_do` TEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `ngay_cong` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_nhan_vien_nam` (`nhan_vien_id`, `nam`),
  CONSTRAINT `fk_lich_su_cong_phep` FOREIGN KEY (`nhan_vien_id`) REFERENCES `nhanvien` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 5. Cập nhật trigger để xử lý việc trừ phép năm từ năm cũ trước
DROP TRIGGER IF EXISTS `trg_cap_nhat_ngay_phep_sau_duyet`;

DELIMITER ;;
CREATE TRIGGER `trg_cap_nhat_ngay_phep_sau_duyet` AFTER UPDATE ON `don_nghi_phep` 
FOR EACH ROW 
BEGIN
    DECLARE so_ngay_con_lai DECIMAL(4,1);
    DECLARE ngay_phep_nam_truoc_con DECIMAL(4,1);
    DECLARE ngay_phep_hien_tai_con DECIMAL(4,1);
    DECLARE so_ngay_tru_nam_cu DECIMAL(4,1);
    DECLARE so_ngay_tru_nam_moi DECIMAL(4,1);
    
    -- Khi duyệt đơn phép năm
    IF NEW.trang_thai = 'da_duyet' AND OLD.trang_thai = 'cho_duyet' AND NEW.loai_phep = 'Phép năm' THEN
        
        -- Lấy thông tin ngày phép hiện tại
        SELECT ngay_phep_con_lai, ngay_phep_nam_truoc 
        INTO so_ngay_con_lai, ngay_phep_nam_truoc_con
        FROM ngay_phep_nam 
        WHERE nhan_vien_id = NEW.nhan_vien_id AND nam = YEAR(NEW.ngay_bat_dau);
        
        -- Tính toán trừ ngày phép từ năm cũ trước
        IF ngay_phep_nam_truoc_con >= NEW.so_ngay THEN
            -- Đủ ngày phép năm cũ để trừ
            SET so_ngay_tru_nam_cu = NEW.so_ngay;
            SET so_ngay_tru_nam_moi = 0;
        ELSE
            -- Không đủ ngày phép năm cũ, trừ cả năm mới
            SET so_ngay_tru_nam_cu = ngay_phep_nam_truoc_con;
            SET so_ngay_tru_nam_moi = NEW.so_ngay - ngay_phep_nam_truoc_con;
        END IF;
        
        -- Cập nhật ngày phép
        UPDATE ngay_phep_nam 
        SET 
            ngay_phep_da_dung = ngay_phep_da_dung + so_ngay_tru_nam_moi,
            ngay_phep_con_lai = tong_ngay_phep - (ngay_phep_da_dung + so_ngay_tru_nam_moi),
            ngay_phep_nam_truoc = GREATEST(0, ngay_phep_nam_truoc - so_ngay_tru_nam_cu)
        WHERE nhan_vien_id = NEW.nhan_vien_id AND nam = YEAR(NEW.ngay_bat_dau);
    END IF;
    
    -- Khi từ chối đơn đã duyệt (hoàn lại phép)
    IF NEW.trang_thai = 'tu_choi' AND OLD.trang_thai = 'da_duyet' AND NEW.loai_phep = 'Phép năm' THEN
        UPDATE ngay_phep_nam 
        SET 
            ngay_phep_da_dung = GREATEST(0, ngay_phep_da_dung - NEW.so_ngay),
            ngay_phep_con_lai = tong_ngay_phep - GREATEST(0, ngay_phep_da_dung - NEW.so_ngay)
        WHERE nhan_vien_id = NEW.nhan_vien_id AND nam = YEAR(NEW.ngay_bat_dau);
    END IF;
END;;
DELIMITER ;

-- 6. Tạo Stored Procedure: Cộng phép đầu năm (chạy vào 1/1 hàng năm)
DROP PROCEDURE IF EXISTS sp_cong_phep_dau_nam;

DELIMITER ;;
CREATE PROCEDURE sp_cong_phep_dau_nam(IN p_nam INT)
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_nhan_vien_id INT;
    DECLARE v_ngay_vao_lam DATE;
    DECLARE v_thang_lam_viec INT;
    DECLARE v_ngay_phep_nam_truoc DECIMAL(4,1);
    
    -- Cursor để duyệt qua tất cả nhân viên đang làm
    DECLARE cur_nhan_vien CURSOR FOR 
        SELECT id, ngay_vao_lam 
        FROM nhanvien 
        WHERE trang_thai_lam_viec = 'Đang làm';
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    OPEN cur_nhan_vien;
    
    read_loop: LOOP
        FETCH cur_nhan_vien INTO v_nhan_vien_id, v_ngay_vao_lam;
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        -- Tính số tháng đã làm việc đến đầu năm mới
        IF v_ngay_vao_lam IS NOT NULL THEN
            SET v_thang_lam_viec = TIMESTAMPDIFF(MONTH, v_ngay_vao_lam, CONCAT(p_nam, '-01-01'));
            
            -- Nếu đã làm > 12 tháng
            IF v_thang_lam_viec > 12 THEN
                -- Lấy ngày phép năm cũ còn lại
                SELECT COALESCE(ngay_phep_con_lai, 0) INTO v_ngay_phep_nam_truoc
                FROM ngay_phep_nam
                WHERE nhan_vien_id = v_nhan_vien_id AND nam = (p_nam - 1);
                
                -- Tạo hoặc cập nhật bản ghi năm mới
                INSERT INTO ngay_phep_nam (nhan_vien_id, nam, tong_ngay_phep, ngay_phep_da_dung, ngay_phep_con_lai, ngay_phep_nam_truoc, da_cong_phep_dau_nam)
                VALUES (v_nhan_vien_id, p_nam, 12.0, 0.0, 12.0, COALESCE(v_ngay_phep_nam_truoc, 0), 1)
                ON DUPLICATE KEY UPDATE
                    tong_ngay_phep = 12.0,
                    ngay_phep_con_lai = 12.0,
                    ngay_phep_nam_truoc = COALESCE(v_ngay_phep_nam_truoc, 0),
                    da_cong_phep_dau_nam = 1;
                
                -- Lưu lịch sử
                INSERT INTO lich_su_cong_phep (nhan_vien_id, nam, thang, so_ngay_cong, loai_cong, ly_do)
                VALUES (v_nhan_vien_id, p_nam, NULL, 12.0, 'dau_nam', CONCAT('Cộng 12 ngày phép đầu năm ', p_nam, '. Ngày phép năm ', (p_nam-1), ' chuyển sang: ', COALESCE(v_ngay_phep_nam_truoc, 0), ' ngày'));
            END IF;
        END IF;
    END LOOP;
    
    CLOSE cur_nhan_vien;
END;;
DELIMITER ;

-- 7. Tạo Stored Procedure: Cộng phép hàng tháng 
-- LOGIC: Vào ngày 1 của tháng m mới, cộng phép của tháng (m-1) cho những NV đã làm >1 tháng
-- Ví dụ: Ngày 1/1/2026 → Cộng phép tháng 12/2025
--        Ngày 1/2/2026 → Cộng phép tháng 1/2026
DROP PROCEDURE IF EXISTS sp_cong_phep_hang_thang;

DELIMITER ;;
CREATE PROCEDURE sp_cong_phep_hang_thang(IN p_nam_thang INT, IN p_thang INT)
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_nhan_vien_id INT;
    DECLARE v_ngay_vao_lam DATE;
    DECLARE v_da_cong_dau_nam INT;
    
    -- Ngày cuối cùng của tháng được cộng phép
    DECLARE v_ngay_cuoi_thang_cong DATE;
    
    -- Cursor để duyệt tất cả nhân viên đang làm việc
    DECLARE cur_nhan_vien CURSOR FOR 
        SELECT nv.id, nv.ngay_vao_lam, COALESCE(npn.da_cong_phep_dau_nam, 0) as da_cong
        FROM nhanvien nv
        LEFT JOIN ngay_phep_nam npn ON nv.id = npn.nhan_vien_id AND npn.nam = p_nam_thang
        WHERE nv.trang_thai_lam_viec = 'Đang làm';
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    -- Tính ngày cuối cùng của tháng cần cộng phép (tháng trước)
    -- Ví dụ: nếu tháng cộng là 1 → tính ngày cuối tháng 12 năm (năm-1)
    SET v_ngay_cuoi_thang_cong = LAST_DAY(STR_TO_DATE(CONCAT(p_nam_thang, '-', p_thang, '-01'), '%Y-%m-%d') - INTERVAL 1 DAY);
    
    OPEN cur_nhan_vien;
    
    read_loop: LOOP
        FETCH cur_nhan_vien INTO v_nhan_vien_id, v_ngay_vao_lam, v_da_cong_dau_nam;
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        -- Chỉ cộng cho nhân viên chưa được cộng 12 ngày đầu năm (NV mới)
        IF v_da_cong_dau_nam = 0 AND v_ngay_vao_lam IS NOT NULL THEN
            
            -- LOGIC: Nhân viên được cộng 1 ngày phép nếu:
            -- 1. Đã vào làm trước hoặc trong tháng cần cộng phép
            -- 2. Nếu vào trong tháng cần cộng, thì phải vào trước hoặc vào ngày 15
            -- Ví dụ: Ngày 1/1/2026 cộng phép tháng 12/2025:
            --   - NV vào 12/10/2025: ✅ cộng (vào trước tháng 12)
            --   - NV vào 12/15/2025: ✅ cộng (vào ngày 15 của tháng 12)
            --   - NV vào 12/16/2025: ❌ không cộng (vào sau ngày 15)
            
            IF (v_ngay_vao_lam < v_ngay_cuoi_thang_cong) OR 
               (MONTH(v_ngay_vao_lam) = MONTH(v_ngay_cuoi_thang_cong) AND 
                YEAR(v_ngay_vao_lam) = YEAR(v_ngay_cuoi_thang_cong) AND 
                DAY(v_ngay_vao_lam) <= 15) THEN
                
                -- Đủ điều kiện được cộng 1 ngày phép cho tháng được cộng
                -- Tạo hoặc cập nhật bản ghi năm hiện tại
                INSERT INTO ngay_phep_nam (nhan_vien_id, nam, tong_ngay_phep, ngay_phep_da_dung, ngay_phep_con_lai, ngay_phep_nam_truoc, da_cong_phep_dau_nam)
                VALUES (v_nhan_vien_id, p_nam_thang, 1.0, 0.0, 1.0, 0, 0)
                ON DUPLICATE KEY UPDATE
                    tong_ngay_phep = tong_ngay_phep + 1.0,
                    ngay_phep_con_lai = ngay_phep_con_lai + 1.0;
                
                -- Lưu lịch sử cộng phép
                INSERT INTO lich_su_cong_phep (nhan_vien_id, nam, thang, so_ngay_cong, loai_cong, ly_do)
                VALUES (v_nhan_vien_id, p_nam_thang, MONTH(v_ngay_cuoi_thang_cong), 1.0, 'hang_thang', 
                        CONCAT('Cộng 1 ngày phép cho tháng ', MONTH(v_ngay_cuoi_thang_cong), '/', YEAR(v_ngay_cuoi_thang_cong)));
            END IF;
        END IF;
    END LOOP;
    
    CLOSE cur_nhan_vien;
END;;
DELIMITER ;

-- 8. Tạo Stored Procedure: Xóa ngày phép năm cũ khi hết quý 1
DROP PROCEDURE IF EXISTS sp_xoa_phep_nam_cu;

DELIMITER ;;
CREATE PROCEDURE sp_xoa_phep_nam_cu(IN p_nam INT)
BEGIN
    -- Xóa ngày phép năm cũ khi bước sang quý 2
    UPDATE ngay_phep_nam
    SET ngay_phep_nam_truoc = 0
    WHERE nam = p_nam;
    
    -- Log lại
    INSERT INTO lich_su_cong_phep (nhan_vien_id, nam, thang, so_ngay_cong, loai_cong, ly_do)
    SELECT nhan_vien_id, p_nam, 4, 0, 'dau_nam', CONCAT('Xóa ngày phép năm ', (p_nam-1), ' còn lại khi hết quý 1')
    FROM ngay_phep_nam
    WHERE nam = p_nam;
END;;
DELIMITER ;

-- 9. Chạy procedure cho năm 2026 (nếu đang trong quý 1)
-- Nếu hiện tại là sau ngày 1/1/2026 nhưng trước 1/4/2026
CALL sp_cong_phep_dau_nam(2026);

COMMIT;