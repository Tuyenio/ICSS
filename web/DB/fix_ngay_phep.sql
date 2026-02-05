-- ============================================================================
-- FILE: fix_ngay_phep.sql
-- Purpose: Delete and recalculate leave data with new logic
-- Date: 28/01/2026
-- ============================================================================

-- WARNING: This file will DELETE all data in 3 tables:
-- 1. ngay_phep_nam
-- 2. don_nghi_phep
-- 3. lich_su_cong_phep
-- 
-- Only run this file after creating a database BACKUP!

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+07:00";

-- ============================================================================
-- STEP 1: DROP AND RECREATE STORED PROCEDURES WITH NEW LOGIC
-- ============================================================================

-- Drop old stored procedures
DROP PROCEDURE IF EXISTS `sp_cong_phep_dau_nam`;
DROP PROCEDURE IF EXISTS `sp_cong_phep_hang_thang`;
DROP PROCEDURE IF EXISTS `sp_xoa_phep_nam_cu`;

DELIMITER $$

-- ============================================================================
-- Stored Procedure: sp_cong_phep_dau_nam (NEW LOGIC)
-- Description: Add 12 days annual leave for employees with > 12 months service
-- Logic: 
--   - If > 12 months service as of 01/01/new year: Add 12 days, set flag = 1
--   - Transfer remaining previous year leave to new year (if still in Q1)
-- ============================================================================
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_cong_phep_dau_nam`(IN `p_nam` INT)
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_nhan_vien_id INT;
    DECLARE v_ngay_vao_lam DATE;
    DECLARE v_thang_lam_viec INT;
    DECLARE v_ngay_phep_nam_truoc DECIMAL(4,1);
    
    -- Cursor to iterate through all active employees
    DECLARE cur_nhan_vien CURSOR FOR 
        SELECT id, ngay_vao_lam 
        FROM nhanvien 
        WHERE trang_thai_lam_viec = 'Dang lam';
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    OPEN cur_nhan_vien;
    
    read_loop: LOOP
        FETCH cur_nhan_vien INTO v_nhan_vien_id, v_ngay_vao_lam;
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        -- Calculate months of service to new year start (01/01/p_nam)
        IF v_ngay_vao_lam IS NOT NULL THEN
            SET v_thang_lam_viec = TIMESTAMPDIFF(MONTH, v_ngay_vao_lam, CONCAT(p_nam, '-01-01'));
            
            -- NEW LOGIC: If > 12 months service as of 01/01/new year
            IF v_thang_lam_viec > 12 THEN
                -- Get remaining leave from previous year (if any)
                SELECT COALESCE(ngay_phep_con_lai, 0) INTO v_ngay_phep_nam_truoc
                FROM ngay_phep_nam
                WHERE nhan_vien_id = v_nhan_vien_id AND nam = (p_nam - 1);
                
                IF v_ngay_phep_nam_truoc IS NULL THEN
                    SET v_ngay_phep_nam_truoc = 0;
                END IF;
                
                -- Create or update record for new year
                INSERT INTO ngay_phep_nam (nhan_vien_id, nam, tong_ngay_phep, ngay_phep_da_dung, ngay_phep_con_lai, ngay_phep_nam_truoc, da_cong_phep_dau_nam)
                VALUES (v_nhan_vien_id, p_nam, 12.0, 0.0, 12.0 + v_ngay_phep_nam_truoc, v_ngay_phep_nam_truoc, 1)
                ON DUPLICATE KEY UPDATE
                    tong_ngay_phep = 12.0,
                    ngay_phep_con_lai = 12.0 + v_ngay_phep_nam_truoc,
                    ngay_phep_nam_truoc = v_ngay_phep_nam_truoc,
                    da_cong_phep_dau_nam = 1;
                
                -- Save history
                INSERT INTO lich_su_cong_phep (nhan_vien_id, nam, thang, so_ngay_cong, loai_cong, ly_do)
                VALUES (v_nhan_vien_id, p_nam, NULL, 12.0, 'dau_nam', 
                    CONCAT('Add 12 annual days ', p_nam, 
                           CASE WHEN v_ngay_phep_nam_truoc > 0 
                                THEN CONCAT('. Transfer ', v_ngay_phep_nam_truoc, ' days from ', (p_nam-1))
                                ELSE '' 
                           END));
            END IF;
        END IF;
    END LOOP;
    
    CLOSE cur_nhan_vien;
END$$

-- ============================================================================
-- Stored Procedure: sp_cong_phep_hang_thang (LOGIC MỚI)
-- Mô tả: Cộng 1 ngày phép hàng tháng cho NV chưa được cộng 12 ngày đầu năm
-- Logic:
--   - Chỉ cộng cho NV có da_cong_phep_dau_nam = 0
--   - Vào làm TRƯỚC ngày 15: được cộng phép cho tháng đó
--   - Vào làm SAU ngày 15: KHÔNG được cộng phép cho tháng đó
--   - Cộng vào cuối tháng cho tháng vừa qua
-- Ví dụ: 
--   - NV vào làm 01/09/2025: Hết tháng 9 được +1, hết tháng 10 được +1,...
--   - NV vào làm 14/09/2025: Hết tháng 9 được +1, hết tháng 10 được +1,...
--   - NV vào làm 16/09/2025: Hết tháng 9 KHÔNG được +1, hết tháng 10 được +1,...
-- ============================================================================
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_cong_phep_hang_thang`(IN `p_nam` INT, IN `p_thang` INT)
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_nhan_vien_id INT;
    DECLARE v_ngay_vao_lam DATE;
    DECLARE v_da_cong_dau_nam INT;
    
    -- Cursor để duyệt nhân viên CHƯA được cộng phép đầu năm
    DECLARE cur_nhan_vien CURSOR FOR 
        SELECT nv.id, nv.ngay_vao_lam, COALESCE(npn.da_cong_phep_dau_nam, 0) as da_cong
        FROM nhanvien nv
        LEFT JOIN ngay_phep_nam npn ON nv.id = npn.nhan_vien_id AND npn.nam = p_nam
        WHERE nv.trang_thai_lam_viec = 'Dang lam';
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    OPEN cur_nhan_vien;
    
    read_loop: LOOP
        FETCH cur_nhan_vien INTO v_nhan_vien_id, v_ngay_vao_lam, v_da_cong_dau_nam;
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        -- NEW LOGIC: Only add for employees NOT yet given 12 annual days
        IF v_da_cong_dau_nam = 0 AND v_ngay_vao_lam IS NOT NULL THEN
            
            -- Check conditions:
            -- 1. Joined BEFORE month p_thang/p_nam: Eligible
            -- 2. Joined IN month p_thang/p_nam AND before day 15: Eligible
            -- 3. Joined IN month p_thang/p_nam AND after day 15: NOT eligible
            -- 4. Joined AFTER month p_thang/p_nam: NOT eligible
            
            IF (YEAR(v_ngay_vao_lam) < p_nam) OR
               (YEAR(v_ngay_vao_lam) = p_nam AND MONTH(v_ngay_vao_lam) < p_thang) OR
               (YEAR(v_ngay_vao_lam) = p_nam AND MONTH(v_ngay_vao_lam) = p_thang AND DAY(v_ngay_vao_lam) <= 15) THEN
                
                -- Eligible to add 1 day for month p_thang
                -- Create or update record
                INSERT INTO ngay_phep_nam (nhan_vien_id, nam, tong_ngay_phep, ngay_phep_da_dung, ngay_phep_con_lai, ngay_phep_nam_truoc, da_cong_phep_dau_nam)
                VALUES (v_nhan_vien_id, p_nam, 1.0, 0.0, 1.0, 0, 0)
                ON DUPLICATE KEY UPDATE
                    tong_ngay_phep = tong_ngay_phep + 1.0,
                    ngay_phep_con_lai = ngay_phep_con_lai + 1.0;
                
                -- Save history
                INSERT INTO lich_su_cong_phep (nhan_vien_id, nam, thang, so_ngay_cong, loai_cong, ly_do)
                VALUES (v_nhan_vien_id, p_nam, p_thang, 1.0, 'hang_thang', 
                    CONCAT('Add 1 day for month ', p_thang, '/', p_nam));
            END IF;
        END IF;
    END LOOP;
    
    CLOSE cur_nhan_vien;
END$$

-- ============================================================================
-- Stored Procedure: sp_xoa_phep_nam_cu (NEW LOGIC)
-- Description: Delete old year leave at end of Q1 (transition to Q2 = 01/04)
-- Logic: When moving to month 4, delete unused previous year leave
-- ============================================================================
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_xoa_phep_nam_cu`(IN `p_nam` INT)
BEGIN
    -- Subtract previous year leave from ngay_phep_con_lai, then set ngay_phep_nam_truoc = 0
    UPDATE ngay_phep_nam
    SET 
        ngay_phep_con_lai = ngay_phep_con_lai - ngay_phep_nam_truoc,
        ngay_phep_nam_truoc = 0
    WHERE nam = p_nam AND ngay_phep_nam_truoc > 0;
    
    -- Save history
    INSERT INTO lich_su_cong_phep (nhan_vien_id, nam, thang, so_ngay_cong, loai_cong, ly_do)
    SELECT 
        nhan_vien_id, 
        p_nam, 
        4, 
        0, 
        'dau_nam', 
        CONCAT('Delete leave from year ', (p_nam-1), ' at end of Q1')
    FROM ngay_phep_nam
    WHERE nam = p_nam;
END$$

DELIMITER ;

-- ============================================================================
-- STEP 2: DELETE OLD DATA FROM 3 TABLES
-- ============================================================================

-- Disable foreign key check temporarily
SET FOREIGN_KEY_CHECKS = 0;

-- Delete data from lich_su_cong_phep table
DELETE FROM `lich_su_cong_phep`;
ALTER TABLE `lich_su_cong_phep` AUTO_INCREMENT = 1;

-- Delete data from don_nghi_phep table
DELETE FROM `don_nghi_phep`;
ALTER TABLE `don_nghi_phep` AUTO_INCREMENT = 1;

-- Delete data from ngay_phep_nam table
DELETE FROM `ngay_phep_nam`;
ALTER TABLE `ngay_phep_nam` AUTO_INCREMENT = 1;

-- Re-enable foreign key check
SET FOREIGN_KEY_CHECKS = 1;

-- ============================================================================
-- STEP 3: CALCULATE AND INSERT NEW DATA
-- ============================================================================

-- ============================================================================
-- 3.1. CALCULATE LEAVE DAYS FOR YEAR 2025
-- ============================================================================
-- Logic: 
-- - For each employee, calculate months worked in 2025
-- - Each month earns 1 leave day (if joined before day 15)
-- - Join month: if after day 15, that month does not count

-- ID=3: Nguyễn Tấn Dũng - Vào làm 05/05/2025
-- Tháng 5: vào ngày 5 (trước 15) -> +1
-- Tháng 6,7,8,9,10,11,12: +7
-- Tổng 2025: 8 ngày
INSERT INTO ngay_phep_nam (nhan_vien_id, nam, tong_ngay_phep, ngay_phep_da_dung, ngay_phep_con_lai, ngay_phep_nam_truoc, da_cong_phep_dau_nam)
VALUES (3, 2025, 8.0, 0.0, 8.0, 0.0, 0);

INSERT INTO lich_su_cong_phep (nhan_vien_id, nam, thang, so_ngay_cong, loai_cong, ly_do)
VALUES 
(3, 2025, 5, 1.0, 'hang_thang', 'Cộng 1 ngày phép cho tháng 5/2025'),
(3, 2025, 6, 1.0, 'hang_thang', 'Cộng 1 ngày phép cho tháng 6/2025'),
(3, 2025, 7, 1.0, 'hang_thang', 'Cộng 1 ngày phép cho tháng 7/2025'),
(3, 2025, 8, 1.0, 'hang_thang', 'Cộng 1 ngày phép cho tháng 8/2025'),
(3, 2025, 9, 1.0, 'hang_thang', 'Cộng 1 ngày phép cho tháng 9/2025'),
(3, 2025, 10, 1.0, 'hang_thang', 'Cộng 1 ngày phép cho tháng 10/2025'),
(3, 2025, 11, 1.0, 'hang_thang', 'Cộng 1 ngày phép cho tháng 11/2025'),
(3, 2025, 12, 1.0, 'hang_thang', 'Cộng 1 ngày phép cho tháng 12/2025');

-- ID=4: Võ Trung Âu - Vào làm 01/08/2024 -> Đã làm > 12 tháng tính đến 01/01/2025
-- Năm 2025: +12 ngày đầu năm, da_cong_phep_dau_nam = 1
INSERT INTO ngay_phep_nam (nhan_vien_id, nam, tong_ngay_phep, ngay_phep_da_dung, ngay_phep_con_lai, ngay_phep_nam_truoc, da_cong_phep_dau_nam)
VALUES (4, 2025, 12.0, 0.0, 12.0, 0.0, 1);

INSERT INTO lich_su_cong_phep (nhan_vien_id, nam, thang, so_ngay_cong, loai_cong, ly_do)
VALUES (4, 2025, NULL, 12.0, 'dau_nam', 'Cộng 12 ngày phép đầu năm 2025');

-- ID=5: Trịnh Văn Chiến - Vào làm 01/07/2025 - Nghỉ việc (bỏ qua)

-- ID=6: Vũ Tam Hanh - Vào làm 03/09/2025
-- Tháng 9: vào ngày 3 (trước 15) -> +1
-- Tháng 10,11,12: +3
-- Tổng 2025: 4 ngày
INSERT INTO ngay_phep_nam (nhan_vien_id, nam, tong_ngay_phep, ngay_phep_da_dung, ngay_phep_con_lai, ngay_phep_nam_truoc, da_cong_phep_dau_nam)
VALUES (6, 2025, 4.0, 0.0, 4.0, 0.0, 0);

INSERT INTO lich_su_cong_phep (nhan_vien_id, nam, thang, so_ngay_cong, loai_cong, ly_do)
VALUES 
(6, 2025, 9, 1.0, 'hang_thang', 'Cộng 1 ngày phép cho tháng 9/2025'),
(6, 2025, 10, 1.0, 'hang_thang', 'Cộng 1 ngày phép cho tháng 10/2025'),
(6, 2025, 11, 1.0, 'hang_thang', 'Cộng 1 ngày phép cho tháng 11/2025'),
(6, 2025, 12, 1.0, 'hang_thang', 'Cộng 1 ngày phép cho tháng 12/2025');

-- ID=7: Nguyễn Thị Diễm Quỳnh - Vào làm 16/06/2025
-- Tháng 6: vào ngày 16 (sau 15) -> KHÔNG +1
-- Tháng 7,8,9,10,11,12: +6
-- Tổng 2025: 6 ngày
INSERT INTO ngay_phep_nam (nhan_vien_id, nam, tong_ngay_phep, ngay_phep_da_dung, ngay_phep_con_lai, ngay_phep_nam_truoc, da_cong_phep_dau_nam)
VALUES (7, 2025, 6.0, 0.0, 6.0, 0.0, 0);

INSERT INTO lich_su_cong_phep (nhan_vien_id, nam, thang, so_ngay_cong, loai_cong, ly_do)
VALUES 
(7, 2025, 7, 1.0, 'hang_thang', 'Cộng 1 ngày phép cho tháng 7/2025'),
(7, 2025, 8, 1.0, 'hang_thang', 'Cộng 1 ngày phép cho tháng 8/2025'),
(7, 2025, 9, 1.0, 'hang_thang', 'Cộng 1 ngày phép cho tháng 9/2025'),
(7, 2025, 10, 1.0, 'hang_thang', 'Cộng 1 ngày phép cho tháng 10/2025'),
(7, 2025, 11, 1.0, 'hang_thang', 'Cộng 1 ngày phép cho tháng 11/2025'),
(7, 2025, 12, 1.0, 'hang_thang', 'Cộng 1 ngày phép cho tháng 12/2025');

-- ID=8: Trần Đình Nam - Vào làm 03/09/2025
-- Tháng 9: vào ngày 3 (trước 15) -> +1
-- Tháng 10,11,12: +3
-- Tổng 2025: 4 ngày
INSERT INTO ngay_phep_nam (nhan_vien_id, nam, tong_ngay_phep, ngay_phep_da_dung, ngay_phep_con_lai, ngay_phep_nam_truoc, da_cong_phep_dau_nam)
VALUES (8, 2025, 4.0, 0.0, 4.0, 0.0, 0);

INSERT INTO lich_su_cong_phep (nhan_vien_id, nam, thang, so_ngay_cong, loai_cong, ly_do)
VALUES 
(8, 2025, 9, 1.0, 'hang_thang', 'Cộng 1 ngày phép cho tháng 9/2025'),
(8, 2025, 10, 1.0, 'hang_thang', 'Cộng 1 ngày phép cho tháng 10/2025'),
(8, 2025, 11, 1.0, 'hang_thang', 'Cộng 1 ngày phép cho tháng 11/2025'),
(8, 2025, 12, 1.0, 'hang_thang', 'Cộng 1 ngày phép cho tháng 12/2025');

-- ID=9: Phạm Thị Lê Vinh - Vào làm 01/07/2025 - Nghỉ việc (bỏ qua)

-- ID=10: Nguyễn Đức Dương - Vào làm 02/08/2025
-- Tháng 8: vào ngày 2 (trước 15) -> +1
-- Tháng 9,10,11,12: +4
-- Tổng 2025: 5 ngày
INSERT INTO ngay_phep_nam (nhan_vien_id, nam, tong_ngay_phep, ngay_phep_da_dung, ngay_phep_con_lai, ngay_phep_nam_truoc, da_cong_phep_dau_nam)
VALUES (10, 2025, 5.0, 0.0, 5.0, 0.0, 0);

INSERT INTO lich_su_cong_phep (nhan_vien_id, nam, thang, so_ngay_cong, loai_cong, ly_do)
VALUES 
(10, 2025, 8, 1.0, 'hang_thang', 'Cộng 1 ngày phép cho tháng 8/2025'),
(10, 2025, 9, 1.0, 'hang_thang', 'Cộng 1 ngày phép cho tháng 9/2025'),
(10, 2025, 10, 1.0, 'hang_thang', 'Cộng 1 ngày phép cho tháng 10/2025'),
(10, 2025, 11, 1.0, 'hang_thang', 'Cộng 1 ngày phép cho tháng 11/2025'),
(10, 2025, 12, 1.0, 'hang_thang', 'Cộng 1 ngày phép cho tháng 12/2025');

-- ID=11: Đặng Lê Trung - Vào làm 21/07/2025
-- Tháng 7: vào ngày 21 (sau 15) -> KHÔNG +1
-- Tháng 8,9,10,11,12: +5
-- Tổng 2025: 5 ngày
INSERT INTO ngay_phep_nam (nhan_vien_id, nam, tong_ngay_phep, ngay_phep_da_dung, ngay_phep_con_lai, ngay_phep_nam_truoc, da_cong_phep_dau_nam)
VALUES (11, 2025, 5.0, 0.0, 5.0, 0.0, 0);

INSERT INTO lich_su_cong_phep (nhan_vien_id, nam, thang, so_ngay_cong, loai_cong, ly_do)
VALUES 
(11, 2025, 8, 1.0, 'hang_thang', 'Cộng 1 ngày phép cho tháng 8/2025'),
(11, 2025, 9, 1.0, 'hang_thang', 'Cộng 1 ngày phép cho tháng 9/2025'),
(11, 2025, 10, 1.0, 'hang_thang', 'Cộng 1 ngày phép cho tháng 10/2025'),
(11, 2025, 11, 1.0, 'hang_thang', 'Cộng 1 ngày phép cho tháng 11/2025'),
(11, 2025, 12, 1.0, 'hang_thang', 'Cộng 1 ngày phép cho tháng 12/2025');

-- ID=12: Vũ Thị Hải Yến - Vào làm 04/09/2025
-- Tháng 9: vào ngày 4 (trước 15) -> +1
-- Tháng 10,11,12: +3
-- Tổng 2025: 4 ngày
INSERT INTO ngay_phep_nam (nhan_vien_id, nam, tong_ngay_phep, ngay_phep_da_dung, ngay_phep_con_lai, ngay_phep_nam_truoc, da_cong_phep_dau_nam)
VALUES (12, 2025, 4.0, 0.0, 4.0, 0.0, 0);

INSERT INTO lich_su_cong_phep (nhan_vien_id, nam, thang, so_ngay_cong, loai_cong, ly_do)
VALUES 
(12, 2025, 9, 1.0, 'hang_thang', 'Cộng 1 ngày phép cho tháng 9/2025'),
(12, 2025, 10, 1.0, 'hang_thang', 'Cộng 1 ngày phép cho tháng 10/2025'),
(12, 2025, 11, 1.0, 'hang_thang', 'Cộng 1 ngày phép cho tháng 11/2025'),
(12, 2025, 12, 1.0, 'hang_thang', 'Cộng 1 ngày phép cho tháng 12/2025');

-- ID=15: Đặng Thu Hồng - Vào làm 01/07/2025
-- Tháng 7,8,9,10,11,12: +6
-- Tổng 2025: 6 ngày
INSERT INTO ngay_phep_nam (nhan_vien_id, nam, tong_ngay_phep, ngay_phep_da_dung, ngay_phep_con_lai, ngay_phep_nam_truoc, da_cong_phep_dau_nam)
VALUES (15, 2025, 6.0, 0.0, 6.0, 0.0, 0);

INSERT INTO lich_su_cong_phep (nhan_vien_id, nam, thang, so_ngay_cong, loai_cong, ly_do)
VALUES 
(15, 2025, 7, 1.0, 'hang_thang', 'Cộng 1 ngày phép cho tháng 7/2025'),
(15, 2025, 8, 1.0, 'hang_thang', 'Cộng 1 ngày phép cho tháng 8/2025'),
(15, 2025, 9, 1.0, 'hang_thang', 'Cộng 1 ngày phép cho tháng 9/2025'),
(15, 2025, 10, 1.0, 'hang_thang', 'Cộng 1 ngày phép cho tháng 10/2025'),
(15, 2025, 11, 1.0, 'hang_thang', 'Cộng 1 ngày phép cho tháng 11/2025'),
(15, 2025, 12, 1.0, 'hang_thang', 'Cộng 1 ngày phép cho tháng 12/2025');

-- ID=16: Phan Tuấn Linh - Vào làm 21/03/2025
-- Tháng 3: vào ngày 21 (sau 15) -> KHÔNG +1
-- Tháng 4,5,6,7,8,9,10,11,12: +9
-- Tổng 2025: 9 ngày
INSERT INTO ngay_phep_nam (nhan_vien_id, nam, tong_ngay_phep, ngay_phep_da_dung, ngay_phep_con_lai, ngay_phep_nam_truoc, da_cong_phep_dau_nam)
VALUES (16, 2025, 9.0, 0.0, 9.0, 0.0, 0);

INSERT INTO lich_su_cong_phep (nhan_vien_id, nam, thang, so_ngay_cong, loai_cong, ly_do)
VALUES 
(16, 2025, 4, 1.0, 'hang_thang', 'Cộng 1 ngày phép cho tháng 4/2025'),
(16, 2025, 5, 1.0, 'hang_thang', 'Cộng 1 ngày phép cho tháng 5/2025'),
(16, 2025, 6, 1.0, 'hang_thang', 'Cộng 1 ngày phép cho tháng 6/2025'),
(16, 2025, 7, 1.0, 'hang_thang', 'Cộng 1 ngày phép cho tháng 7/2025'),
(16, 2025, 8, 1.0, 'hang_thang', 'Cộng 1 ngày phép cho tháng 8/2025'),
(16, 2025, 9, 1.0, 'hang_thang', 'Cộng 1 ngày phép cho tháng 9/2025'),
(16, 2025, 10, 1.0, 'hang_thang', 'Cộng 1 ngày phép cho tháng 10/2025'),
(16, 2025, 11, 1.0, 'hang_thang', 'Cộng 1 ngày phép cho tháng 11/2025'),
(16, 2025, 12, 1.0, 'hang_thang', 'Cộng 1 ngày phép cho tháng 12/2025');

-- ID=17: Nguyễn Huy Hoàng - Vào làm 02/07/2025 - Nghỉ việc (bỏ qua)

-- ID=18: zAdmin - Vào làm 13/09/2025
-- Tháng 9: vào ngày 13 (trước 15) -> +1
-- Tháng 10,11,12: +3
-- Tổng 2025: 4 ngày
INSERT INTO ngay_phep_nam (nhan_vien_id, nam, tong_ngay_phep, ngay_phep_da_dung, ngay_phep_con_lai, ngay_phep_nam_truoc, da_cong_phep_dau_nam)
VALUES (18, 2025, 4.0, 0.0, 4.0, 0.0, 0);

INSERT INTO lich_su_cong_phep (nhan_vien_id, nam, thang, so_ngay_cong, loai_cong, ly_do)
VALUES 
(18, 2025, 9, 1.0, 'hang_thang', 'Cộng 1 ngày phép cho tháng 9/2025'),
(18, 2025, 10, 1.0, 'hang_thang', 'Cộng 1 ngày phép cho tháng 10/2025'),
(18, 2025, 11, 1.0, 'hang_thang', 'Cộng 1 ngày phép cho tháng 11/2025'),
(18, 2025, 12, 1.0, 'hang_thang', 'Cộng 1 ngày phép cho tháng 12/2025');

-- ID=21: Tạ Quang Anh - Vào làm 22/09/2025 - Nghỉ việc (bỏ qua)

-- ID=22: Đào Huy Hoàng - Vào làm 01/10/2025
-- Tháng 10,11,12: +3
-- Tổng 2025: 3 ngày
INSERT INTO ngay_phep_nam (nhan_vien_id, nam, tong_ngay_phep, ngay_phep_da_dung, ngay_phep_con_lai, ngay_phep_nam_truoc, da_cong_phep_dau_nam)
VALUES (22, 2025, 3.0, 0.0, 3.0, 0.0, 0);

INSERT INTO lich_su_cong_phep (nhan_vien_id, nam, thang, so_ngay_cong, loai_cong, ly_do)
VALUES 
(22, 2025, 10, 1.0, 'hang_thang', 'Cộng 1 ngày phép cho tháng 10/2025'),
(22, 2025, 11, 1.0, 'hang_thang', 'Cộng 1 ngày phép cho tháng 11/2025'),
(22, 2025, 12, 1.0, 'hang_thang', 'Cộng 1 ngày phép cho tháng 12/2025');

-- ID=23: Tuấn Anh - Vào làm 01/11/2025
-- Tháng 11,12: +2
-- Tổng 2025: 2 ngày
INSERT INTO ngay_phep_nam (nhan_vien_id, nam, tong_ngay_phep, ngay_phep_da_dung, ngay_phep_con_lai, ngay_phep_nam_truoc, da_cong_phep_dau_nam)
VALUES (23, 2025, 2.0, 0.0, 2.0, 0.0, 0);

INSERT INTO lich_su_cong_phep (nhan_vien_id, nam, thang, so_ngay_cong, loai_cong, ly_do)
VALUES 
(23, 2025, 11, 1.0, 'hang_thang', 'Cộng 1 ngày phép cho tháng 11/2025'),
(23, 2025, 12, 1.0, 'hang_thang', 'Cộng 1 ngày phép cho tháng 12/2025');

-- ID=24: Nguyễn Ngọc Tuyền - Vào làm 22/07/2025
-- Tháng 7: vào ngày 22 (sau 15) -> KHÔNG +1
-- Tháng 8,9,10,11,12: +5
-- Tổng 2025: 5 ngày
INSERT INTO ngay_phep_nam (nhan_vien_id, nam, tong_ngay_phep, ngay_phep_da_dung, ngay_phep_con_lai, ngay_phep_nam_truoc, da_cong_phep_dau_nam)
VALUES (24, 2025, 5.0, 0.0, 5.0, 0.0, 0);

INSERT INTO lich_su_cong_phep (nhan_vien_id, nam, thang, so_ngay_cong, loai_cong, ly_do)
VALUES 
(24, 2025, 8, 1.0, 'hang_thang', 'Cộng 1 ngày phép cho tháng 8/2025'),
(24, 2025, 9, 1.0, 'hang_thang', 'Cộng 1 ngày phép cho tháng 9/2025'),
(24, 2025, 10, 1.0, 'hang_thang', 'Cộng 1 ngày phép cho tháng 10/2025'),
(24, 2025, 11, 1.0, 'hang_thang', 'Cộng 1 ngày phép cho tháng 11/2025'),
(24, 2025, 12, 1.0, 'hang_thang', 'Cộng 1 ngày phép cho tháng 12/2025');

-- ID=25: Phạm Minh Thắng - Vào làm 20/07/2025
-- Tháng 7: vào ngày 20 (sau 15) -> KHÔNG +1
-- Tháng 8,9,10,11,12: +5
-- Tổng 2025: 5 ngày
INSERT INTO ngay_phep_nam (nhan_vien_id, nam, tong_ngay_phep, ngay_phep_da_dung, ngay_phep_con_lai, ngay_phep_nam_truoc, da_cong_phep_dau_nam)
VALUES (25, 2025, 5.0, 0.0, 5.0, 0.0, 0);

INSERT INTO lich_su_cong_phep (nhan_vien_id, nam, thang, so_ngay_cong, loai_cong, ly_do)
VALUES 
(25, 2025, 8, 1.0, 'hang_thang', 'Cộng 1 ngày phép cho tháng 8/2025'),
(25, 2025, 9, 1.0, 'hang_thang', 'Cộng 1 ngày phép cho tháng 9/2025'),
(25, 2025, 10, 1.0, 'hang_thang', 'Cộng 1 ngày phép cho tháng 10/2025'),
(25, 2025, 11, 1.0, 'hang_thang', 'Cộng 1 ngày phép cho tháng 11/2025'),
(25, 2025, 12, 1.0, 'hang_thang', 'Cộng 1 ngày phép cho tháng 12/2025');

-- ID=27: Nguyễn Công Bảo - Vào làm 20/11/2025
-- Tháng 11: vào ngày 20 (sau 15) -> KHÔNG +1
-- Tháng 12: +1
-- Tổng 2025: 1 ngày
INSERT INTO ngay_phep_nam (nhan_vien_id, nam, tong_ngay_phep, ngay_phep_da_dung, ngay_phep_con_lai, ngay_phep_nam_truoc, da_cong_phep_dau_nam)
VALUES (27, 2025, 1.0, 0.0, 1.0, 0.0, 0);

INSERT INTO lich_su_cong_phep (nhan_vien_id, nam, thang, so_ngay_cong, loai_cong, ly_do)
VALUES (27, 2025, 12, 1.0, 'hang_thang', 'Cộng 1 ngày phép cho tháng 12/2025');

-- ID=28: Nguyễn Tiến Minh - Vào làm 27/11/2025
-- Tháng 11: vào ngày 27 (sau 15) -> KHÔNG +1
-- Tháng 12: +1
-- Tổng 2025: 1 ngày
INSERT INTO ngay_phep_nam (nhan_vien_id, nam, tong_ngay_phep, ngay_phep_da_dung, ngay_phep_con_lai, ngay_phep_nam_truoc, da_cong_phep_dau_nam)
VALUES (28, 2025, 1.0, 0.0, 1.0, 0.0, 0);

INSERT INTO lich_su_cong_phep (nhan_vien_id, nam, thang, so_ngay_cong, loai_cong, ly_do)
VALUES (28, 2025, 12, 1.0, 'hang_thang', 'Cộng 1 ngày phép cho tháng 12/2025');

-- ID=30: Nguyễn Thành Đạt - Vào làm 05/01/2026 (chưa tính cho 2025)

-- ID=31: Vũ Ngọc Tiến - Vào làm 05/01/2026 (chưa tính cho 2025)

-- ID=32: Đỗ Toàn - Vào làm 05/01/2026 (chưa tính cho 2025)

-- ============================================================================
-- 3.2. TÍNH NGÀY PHÉP NĂM 2026
-- ============================================================================
-- Hiện tại là 28/01/2026 -> ĐANG TRONG tháng 1/2026, CHƯA HẾT tháng 1
-- Logic:
-- - Nhân viên đã làm > 12 tháng tính đến 01/01/2026: +12 ngày đầu năm, da_cong_phep_dau_nam = 1
-- - Nhân viên còn lại: CHƯA được cộng phép tháng 1/2026 (vì chưa hết tháng 1)
--   → Chỉ có phép năm 2025 chuyển sang (nếu trong Q1)

-- ID=3: Nguyễn Tấn Dũng - Vào làm 05/05/2025 -> Đã làm 8 tháng đến 01/01/2026 (chưa đủ 12 tháng)
-- Hiện tại (28/01/2026): CHƯA hết tháng 1 → CHƯA được cộng phép tháng 1/2026
-- Tổng 2026: 0 ngày (Còn 8 ngày phép năm 2025 chuyển sang, sử dụng được đến hết Q1)
INSERT INTO ngay_phep_nam (nhan_vien_id, nam, tong_ngay_phep, ngay_phep_da_dung, ngay_phep_con_lai, ngay_phep_nam_truoc, da_cong_phep_dau_nam)
VALUES (3, 2026, 0.0, 0.0, 8.0, 8.0, 0);

-- ID=4: Võ Trung Âu - Vào làm 01/08/2024 -> Đã làm > 12 tháng đến 01/01/2026
-- Năm 2026: +12 ngày đầu năm, da_cong_phep_dau_nam = 1
-- Chuyển 12 ngày phép 2025 còn lại sang 2026
INSERT INTO ngay_phep_nam (nhan_vien_id, nam, tong_ngay_phep, ngay_phep_da_dung, ngay_phep_con_lai, ngay_phep_nam_truoc, da_cong_phep_dau_nam)
VALUES (4, 2026, 12.0, 0.0, 24.0, 12.0, 1);

INSERT INTO lich_su_cong_phep (nhan_vien_id, nam, thang, so_ngay_cong, loai_cong, ly_do)
VALUES (4, 2026, NULL, 12.0, 'dau_nam', 'Cộng 12 ngày phép đầu năm 2026. Chuyển sang 12.0 ngày phép năm 2025');

-- ID=6: Vũ Tam Hanh - Vào làm 03/09/2025 -> Đã làm 4 tháng đến 01/01/2026 (chưa đủ 12 tháng)
-- Hiện tại (28/01/2026): CHƯA hết tháng 1 → CHƯA được cộng phép tháng 1/2026
-- Tổng 2026: 0 ngày (Còn 4 ngày phép 2025 chuyển sang)
INSERT INTO ngay_phep_nam (nhan_vien_id, nam, tong_ngay_phep, ngay_phep_da_dung, ngay_phep_con_lai, ngay_phep_nam_truoc, da_cong_phep_dau_nam)
VALUES (6, 2026, 0.0, 0.0, 4.0, 4.0, 0);

-- ID=7: Nguyễn Thị Diễm Quỳnh - Vào làm 16/06/2025 -> Đã làm 7 tháng (chưa đủ 12 tháng)
-- Hiện tại (28/01/2026): CHƯA hết tháng 1 → CHƯA được cộng phép tháng 1/2026
-- Tổng 2026: 0 ngày (Còn 6 ngày phép 2025 chuyển sang)
INSERT INTO ngay_phep_nam (nhan_vien_id, nam, tong_ngay_phep, ngay_phep_da_dung, ngay_phep_con_lai, ngay_phep_nam_truoc, da_cong_phep_dau_nam)
VALUES (7, 2026, 0.0, 0.0, 6.0, 6.0, 0);

-- ID=8: Trần Đình Nam - Vào làm 03/09/2025 -> Đã làm 4 tháng (chưa đủ 12 tháng)
-- Hiện tại (28/01/2026): CHƯA hết tháng 1 → CHƯA được cộng phép tháng 1/2026
-- Tổng 2026: 0 ngày (Còn 4 ngày phép 2025 chuyển sang)
INSERT INTO ngay_phep_nam (nhan_vien_id, nam, tong_ngay_phep, ngay_phep_da_dung, ngay_phep_con_lai, ngay_phep_nam_truoc, da_cong_phep_dau_nam)
VALUES (8, 2026, 0.0, 0.0, 4.0, 4.0, 0);

-- ID=10: Nguyễn Đức Dương - Vào làm 02/08/2025 -> Đã làm 5 tháng (chưa đủ 12 tháng)
-- Hiện tại (28/01/2026): CHƯA hết tháng 1 → CHƯA được cộng phép tháng 1/2026
-- Tổng 2026: 0 ngày (Còn 5 ngày phép 2025 chuyển sang)
INSERT INTO ngay_phep_nam (nhan_vien_id, nam, tong_ngay_phep, ngay_phep_da_dung, ngay_phep_con_lai, ngay_phep_nam_truoc, da_cong_phep_dau_nam)
VALUES (10, 2026, 0.0, 0.0, 5.0, 5.0, 0);

-- ID=11: Đặng Lê Trung - Vào làm 21/07/2025 -> Đã làm 6 tháng (chưa đủ 12 tháng)
-- Hiện tại (28/01/2026): CHƯA hết tháng 1 → CHƯA được cộng phép tháng 1/2026
-- Tổng 2026: 0 ngày (Còn 5 ngày phép 2025 chuyển sang)
INSERT INTO ngay_phep_nam (nhan_vien_id, nam, tong_ngay_phep, ngay_phep_da_dung, ngay_phep_con_lai, ngay_phep_nam_truoc, da_cong_phep_dau_nam)
VALUES (11, 2026, 0.0, 0.0, 5.0, 5.0, 0);

-- ID=12: Vũ Thị Hải Yến - Vào làm 04/09/2025 -> Đã làm 4 tháng (chưa đủ 12 tháng)
-- Hiện tại (28/01/2026): CHƯA hết tháng 1 → CHƯA được cộng phép tháng 1/2026
-- Tổng 2026: 0 ngày (Còn 4 ngày phép 2025 chuyển sang)
INSERT INTO ngay_phep_nam (nhan_vien_id, nam, tong_ngay_phep, ngay_phep_da_dung, ngay_phep_con_lai, ngay_phep_nam_truoc, da_cong_phep_dau_nam)
VALUES (12, 2026, 0.0, 0.0, 4.0, 4.0, 0);

-- ID=15: Đặng Thu Hồng - Vào làm 01/07/2025 -> Đã làm 6 tháng (chưa đủ 12 tháng)
-- Hiện tại (28/01/2026): CHƯA hết tháng 1 → CHƯA được cộng phép tháng 1/2026
-- Tổng 2026: 0 ngày (Còn 6 ngày phép 2025 chuyển sang)
INSERT INTO ngay_phep_nam (nhan_vien_id, nam, tong_ngay_phep, ngay_phep_da_dung, ngay_phep_con_lai, ngay_phep_nam_truoc, da_cong_phep_dau_nam)
VALUES (15, 2026, 0.0, 0.0, 6.0, 6.0, 0);

-- ID=16: Phan Tuấn Linh - Vào làm 21/03/2025 -> Đã làm 10 tháng (chưa đủ 12 tháng)
-- Hiện tại (28/01/2026): CHƯA hết tháng 1 → CHƯA được cộng phép tháng 1/2026
-- Tổng 2026: 0 ngày (Còn 9 ngày phép 2025 chuyển sang)
INSERT INTO ngay_phep_nam (nhan_vien_id, nam, tong_ngay_phep, ngay_phep_da_dung, ngay_phep_con_lai, ngay_phep_nam_truoc, da_cong_phep_dau_nam)
VALUES (16, 2026, 0.0, 0.0, 9.0, 9.0, 0);

-- ID=18: zAdmin - Vào làm 13/09/2025 -> Đã làm 4 tháng (chưa đủ 12 tháng)
-- Hiện tại (28/01/2026): CHƯA hết tháng 1 → CHƯA được cộng phép tháng 1/2026
-- Tổng 2026: 0 ngày (Còn 4 ngày phép 2025 chuyển sang)
INSERT INTO ngay_phep_nam (nhan_vien_id, nam, tong_ngay_phep, ngay_phep_da_dung, ngay_phep_con_lai, ngay_phep_nam_truoc, da_cong_phep_dau_nam)
VALUES (18, 2026, 0.0, 0.0, 4.0, 4.0, 0);

-- ID=22: Đào Huy Hoàng - Vào làm 01/10/2025 -> Đã làm 3 tháng (chưa đủ 12 tháng)
-- Hiện tại (28/01/2026): CHƯA hết tháng 1 → CHƯA được cộng phép tháng 1/2026
-- Tổng 2026: 0 ngày (Còn 3 ngày phép 2025 chuyển sang)
INSERT INTO ngay_phep_nam (nhan_vien_id, nam, tong_ngay_phep, ngay_phep_da_dung, ngay_phep_con_lai, ngay_phep_nam_truoc, da_cong_phep_dau_nam)
VALUES (22, 2026, 0.0, 0.0, 3.0, 3.0, 0);

-- ID=23: Tuấn Anh - Vào làm 01/11/2025 -> Đã làm 2 tháng (chưa đủ 12 tháng)
-- Hiện tại (28/01/2026): CHƯA hết tháng 1 → CHƯA được cộng phép tháng 1/2026
-- Tổng 2026: 0 ngày (Còn 2 ngày phép 2025 chuyển sang)
INSERT INTO ngay_phep_nam (nhan_vien_id, nam, tong_ngay_phep, ngay_phep_da_dung, ngay_phep_con_lai, ngay_phep_nam_truoc, da_cong_phep_dau_nam)
VALUES (23, 2026, 0.0, 0.0, 2.0, 2.0, 0);

-- ID=24: Nguyễn Ngọc Tuyền - Vào làm 22/07/2025 -> Đã làm 6 tháng (chưa đủ 12 tháng)
-- Hiện tại (28/01/2026): CHƯA hết tháng 1 → CHƯA được cộng phép tháng 1/2026
-- Tổng 2026: 0 ngày (Còn 5 ngày phép 2025 chuyển sang)
INSERT INTO ngay_phep_nam (nhan_vien_id, nam, tong_ngay_phep, ngay_phep_da_dung, ngay_phep_con_lai, ngay_phep_nam_truoc, da_cong_phep_dau_nam)
VALUES (24, 2026, 0.0, 0.0, 5.0, 5.0, 0);

-- ID=25: Phạm Minh Thắng - Vào làm 20/07/2025 -> Đã làm 6 tháng (chưa đủ 12 tháng)
-- Hiện tại (28/01/2026): CHƯA hết tháng 1 → CHƯA được cộng phép tháng 1/2026
-- Tổng 2026: 0 ngày (Còn 5 ngày phép 2025 chuyển sang)
INSERT INTO ngay_phep_nam (nhan_vien_id, nam, tong_ngay_phep, ngay_phep_da_dung, ngay_phep_con_lai, ngay_phep_nam_truoc, da_cong_phep_dau_nam)
VALUES (25, 2026, 0.0, 0.0, 5.0, 5.0, 0);

-- ID=27: Nguyễn Công Bảo - Vào làm 20/11/2025 -> Đã làm 2 tháng (chưa đủ 12 tháng)
-- Hiện tại (28/01/2026): CHƯA hết tháng 1 → CHƯA được cộng phép tháng 1/2026
-- Tổng 2026: 0 ngày (Còn 1 ngày phép 2025 chuyển sang)
INSERT INTO ngay_phep_nam (nhan_vien_id, nam, tong_ngay_phep, ngay_phep_da_dung, ngay_phep_con_lai, ngay_phep_nam_truoc, da_cong_phep_dau_nam)
VALUES (27, 2026, 0.0, 0.0, 1.0, 1.0, 0);

-- ID=28: Nguyễn Tiến Minh - Vào làm 27/11/2025 -> Đã làm 2 tháng (chưa đủ 12 tháng)
-- Hiện tại (28/01/2026): CHƯA hết tháng 1 → CHƯA được cộng phép tháng 1/2026
-- Tổng 2026: 0 ngày (Còn 1 ngày phép 2025 chuyển sang)
INSERT INTO ngay_phep_nam (nhan_vien_id, nam, tong_ngay_phep, ngay_phep_da_dung, ngay_phep_con_lai, ngay_phep_nam_truoc, da_cong_phep_dau_nam)
VALUES (28, 2026, 0.0, 0.0, 1.0, 1.0, 0);

-- ID=30: Nguyễn Thành Đạt - Vào làm 05/01/2026
-- Tháng 1: vào ngày 5 (trước 15) -> +1 khi hết tháng 1
-- Hiện tại chưa hết tháng 1 nên chưa cộng
-- Tổng 2026: 0 ngày
INSERT INTO ngay_phep_nam (nhan_vien_id, nam, tong_ngay_phep, ngay_phep_da_dung, ngay_phep_con_lai, ngay_phep_nam_truoc, da_cong_phep_dau_nam)
VALUES (30, 2026, 0.0, 0.0, 0.0, 0.0, 0);

-- ID=31: Vũ Ngọc Tiến - Vào làm 05/01/2026
-- Tháng 1: vào ngày 5 (trước 15) -> +1 khi hết tháng 1
-- Hiện tại chưa hết tháng 1 nên chưa cộng
-- Tổng 2026: 0 ngày
INSERT INTO ngay_phep_nam (nhan_vien_id, nam, tong_ngay_phep, ngay_phep_da_dung, ngay_phep_con_lai, ngay_phep_nam_truoc, da_cong_phep_dau_nam)
VALUES (31, 2026, 0.0, 0.0, 0.0, 0.0, 0);

-- ID=32: Đỗ Toàn - Vào làm 05/01/2026
-- Tháng 1: vào ngày 5 (trước 15) -> +1 khi hết tháng 1
-- Hiện tại chưa hết tháng 1 nên chưa cộng
-- Tổng 2026: 0 ngày
INSERT INTO ngay_phep_nam (nhan_vien_id, nam, tong_ngay_phep, ngay_phep_da_dung, ngay_phep_con_lai, ngay_phep_nam_truoc, da_cong_phep_dau_nam)
VALUES (32, 2026, 0.0, 0.0, 0.0, 0.0, 0);

-- ============================================================================
-- COMPLETED
-- ============================================================================

COMMIT;

-- ============================================================================
-- USAGE INSTRUCTIONS
-- ============================================================================
-- 1. BACKUP database before running this file
-- 2. Run this file in phpMyAdmin or MySQL Workbench
-- 3. Verify results:
--    - SELECT * FROM ngay_phep_nam ORDER BY nhan_vien_id, nam;
--    - SELECT * FROM lich_su_cong_phep ORDER BY nhan_vien_id, nam, thang;
-- 4. From now, system will auto add leave per new logic:
--    - 01/01: Add 12 days for employees with > 12 months service
--    - 01 of each month: Add 1 day for previous month (employees < 12 months)
--    - 01/04: Delete unused previous year leave
-- 5. Important note at 28/01/2026:
--    - Employees < 12 months: ONLY have 2025 leave, NO 2026 leave yet
--    - January 2026 leave will be added on 01/02/2026