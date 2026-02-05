
SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+07:00";

-- Drop old stored procedures
DROP PROCEDURE IF EXISTS `sp_cong_phep_dau_nam`;
DROP PROCEDURE IF EXISTS `sp_cong_phep_hang_thang`;
DROP PROCEDURE IF EXISTS `sp_xoa_phep_nam_cu`;

DELIMITER $$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_cong_phep_dau_nam`(IN `p_nam` INT)
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_nhan_vien_id INT;
    DECLARE v_ngay_vao_lam DATE;
    DECLARE v_thang_lam_viec INT;
    DECLARE v_ngay_phep_nam_truoc DECIMAL(4,1);
    
    -- Cursor để duyệt toàn bộ nhân viên đang làm việc
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
        
        -- Tính tháng làm việc tính tới 01/01 năm mới
        IF v_ngay_vao_lam IS NOT NULL THEN
            SET v_thang_lam_viec = TIMESTAMPDIFF(MONTH, v_ngay_vao_lam, CONCAT(p_nam, '-01-01'));
            
            -- NHÓM 1: Nếu làm > 12 tháng tính tới 01/01/p_nam
            IF v_thang_lam_viec > 12 THEN
                -- Lấy phép năm cũ còn lại (để chuyển sang trong Q1)
                SELECT COALESCE(ngay_phep_con_lai, 0) INTO v_ngay_phep_nam_truoc
                FROM ngay_phep_nam
                WHERE nhan_vien_id = v_nhan_vien_id AND nam = (p_nam - 1);
                
                IF v_ngay_phep_nam_truoc IS NULL THEN
                    SET v_ngay_phep_nam_truoc = 0;
                END IF;
                
                -- Tạo bản ghi năm mới với 12 ngày + chuyển phép năm cũ
                -- ngay_phep_con_lai chỉ tính phép năm hiện tại, phép năm cũ lưu riêng trong ngay_phep_nam_truoc
                INSERT INTO ngay_phep_nam (nhan_vien_id, nam, tong_ngay_phep, ngay_phep_da_dung, ngay_phep_con_lai, ngay_phep_nam_truoc, da_cong_phep_dau_nam)
                VALUES (v_nhan_vien_id, p_nam, 12.0, 0.0, 12.0, v_ngay_phep_nam_truoc, 1)
                ON DUPLICATE KEY UPDATE
                    tong_ngay_phep = 12.0,
                    ngay_phep_con_lai = 12.0,
                    ngay_phep_nam_truoc = v_ngay_phep_nam_truoc,
                    da_cong_phep_dau_nam = 1;
                
                -- Lưu lịch sử cộng phép
                INSERT INTO lich_su_cong_phep (nhan_vien_id, nam, thang, so_ngay_cong, loai_cong, ly_do)
                VALUES (v_nhan_vien_id, p_nam, NULL, 12.0, 'dau_nam', 
                    CONCAT('Cộng 12 ngày phép đầu năm ', p_nam, 
                           CASE WHEN v_ngay_phep_nam_truoc > 0 
                                THEN CONCAT(' + Chuyển ', v_ngay_phep_nam_truoc, ' ngày từ năm ', (p_nam-1), ' (dùng trong Q1)')
                                ELSE '' 
                           END));
            END IF;
        END IF;
    END LOOP;
    
    CLOSE cur_nhan_vien;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_cong_phep_hang_thang`(IN `p_nam` INT, IN `p_thang` INT)
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_nhan_vien_id INT;
    DECLARE v_ngay_vao_lam DATE;
    DECLARE v_da_cong_dau_nam INT;
    
    -- Cursor để duyệt nhân viên NHÓM 2: da_cong_phep_dau_nam = 0
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
        
        -- NHÓM 2: Chỉ cộng cho NV CHƯA được +12 ngày đầu năm (da_cong_phep_dau_nam = 0)
        IF v_da_cong_dau_nam = 0 AND v_ngay_vao_lam IS NOT NULL THEN
            
            -- Kiểm tra điều kiện cộng phép tháng p_thang/p_nam:
            -- 1. Vào làm TRƯỚC tháng p_thang/p_nam: LUÔN được cộng
            -- 2. Vào làm CÙNG tháng p_thang/p_nam:
            --    - Vào ≤ ngày 15: được cộng
            --    - Vào > ngày 15: KHÔNG được cộng
            -- 3. Vào làm SAU tháng p_thang/p_nam: không áp dụng
            
            IF (YEAR(v_ngay_vao_lam) < p_nam) OR
               (YEAR(v_ngay_vao_lam) = p_nam AND MONTH(v_ngay_vao_lam) < p_thang) OR
               (YEAR(v_ngay_vao_lam) = p_nam AND MONTH(v_ngay_vao_lam) = p_thang AND DAY(v_ngay_vao_lam) <= 15) THEN
                
                -- Đủ điều kiện: cộng 1 ngày cho tháng p_thang
                INSERT INTO ngay_phep_nam (nhan_vien_id, nam, tong_ngay_phep, ngay_phep_da_dung, ngay_phep_con_lai, ngay_phep_nam_truoc, da_cong_phep_dau_nam)
                VALUES (v_nhan_vien_id, p_nam, 1.0, 0.0, 1.0, 0.0, 0)
                ON DUPLICATE KEY UPDATE
                    tong_ngay_phep = tong_ngay_phep + 1.0,
                    ngay_phep_con_lai = ngay_phep_con_lai + 1.0;
                
                -- Lưu lịch sử cộng phép
                INSERT INTO lich_su_cong_phep (nhan_vien_id, nam, thang, so_ngay_cong, loai_cong, ly_do)
                VALUES (v_nhan_vien_id, p_nam, p_thang, 1.0, 'hang_thang', 
                    CONCAT('Cộng 1 ngày phép cho tháng ', p_thang, '/', p_nam));
            END IF;
        END IF;
    END LOOP;
    
    CLOSE cur_nhan_vien;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_xoa_phep_nam_cu`(IN `p_nam` INT)
BEGIN
    -- Trừ phép năm cũ khỏi tổng, rồi xóa ngay_phep_nam_truoc
    UPDATE ngay_phep_nam
    SET 
        ngay_phep_con_lai = ngay_phep_con_lai - ngay_phep_nam_truoc,
        ngay_phep_nam_truoc = 0
    WHERE nam = p_nam AND ngay_phep_nam_truoc > 0;
    
    -- Lưu lịch sử xóa phép năm cũ
    INSERT INTO lich_su_cong_phep (nhan_vien_id, nam, thang, so_ngay_cong, loai_cong, ly_do)
    SELECT 
        nhan_vien_id, 
        p_nam, 
        4, 
        ngay_phep_nam_truoc, 
        'xoa_phep_nam_cu', 
        CONCAT('Xóa ', ngay_phep_nam_truoc, ' ngày phép năm ', (p_nam-1), ' tại cuối Q1 (hết 31/03)')
    FROM ngay_phep_nam
    WHERE nam = p_nam AND ngay_phep_nam_truoc > 0;
END$$

DELIMITER ;

-- Vô hiệu hóa foreign key check tạm thời
SET FOREIGN_KEY_CHECKS = 0;

-- Xóa dữ liệu từ bảng lich_su_cong_phep
DELETE FROM `lich_su_cong_phep`;
ALTER TABLE `lich_su_cong_phep` AUTO_INCREMENT = 1;

-- Xóa dữ liệu từ bảng don_nghi_phep
DELETE FROM `don_nghi_phep`;
ALTER TABLE `don_nghi_phep` AUTO_INCREMENT = 1;

-- Xóa dữ liệu từ bảng ngay_phep_nam
DELETE FROM `ngay_phep_nam`;
ALTER TABLE `ngay_phep_nam` AUTO_INCREMENT = 1;

-- Bật lại foreign key check
SET FOREIGN_KEY_CHECKS = 1;

-- ID=4: Võ Trung Âu - Vào làm 01/08/2024 → Đã làm > 12 tháng tính tới 01/01/2025 ✅ NHÓM 1
INSERT INTO ngay_phep_nam (nhan_vien_id, nam, tong_ngay_phep, ngay_phep_da_dung, ngay_phep_con_lai, ngay_phep_nam_truoc, da_cong_phep_dau_nam)
VALUES (4, 2025, 12.0, 0.0, 12.0, 0.0, 1);

INSERT INTO lich_su_cong_phep (nhan_vien_id, nam, thang, so_ngay_cong, loai_cong, ly_do)
VALUES (4, 2025, NULL, 12.0, 'dau_nam', 'Cộng 12 ngày phép đầu năm 2025');

-- ID=3: Nguyễn Tấn Dũng - Vào làm 05/05/2025 → Tháng 5,6,7,8,9,10,11,12 (vào trước 15) = 8 ngày ✅ NHÓM 2
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

-- ID=6: Vũ Tam Hanh - Vào làm 03/09/2025 → Tháng 9,10,11,12 (vào trước 15) = 4 ngày ✅ NHÓM 2
INSERT INTO ngay_phep_nam (nhan_vien_id, nam, tong_ngay_phep, ngay_phep_da_dung, ngay_phep_con_lai, ngay_phep_nam_truoc, da_cong_phep_dau_nam)
VALUES (6, 2025, 4.0, 0.0, 4.0, 0.0, 0);

INSERT INTO lich_su_cong_phep (nhan_vien_id, nam, thang, so_ngay_cong, loai_cong, ly_do)
VALUES 
(6, 2025, 9, 1.0, 'hang_thang', 'Cộng 1 ngày phép cho tháng 9/2025'),
(6, 2025, 10, 1.0, 'hang_thang', 'Cộng 1 ngày phép cho tháng 10/2025'),
(6, 2025, 11, 1.0, 'hang_thang', 'Cộng 1 ngày phép cho tháng 11/2025'),
(6, 2025, 12, 1.0, 'hang_thang', 'Cộng 1 ngày phép cho tháng 12/2025');

-- ID=7: Nguyễn Thị Diễm Quỳnh - Vào làm 16/06/2025 → Tháng 6 (vào > 15) KHÔNG +1, 7,8,9,10,11,12 = 6 ngày ✅ NHÓM 2
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

-- ID=8: Trần Đình Nam - Vào làm 03/09/2025 → Tháng 9,10,11,12 (vào trước 15) = 4 ngày ✅ NHÓM 2
INSERT INTO ngay_phep_nam (nhan_vien_id, nam, tong_ngay_phep, ngay_phep_da_dung, ngay_phep_con_lai, ngay_phep_nam_truoc, da_cong_phep_dau_nam)
VALUES (8, 2025, 4.0, 0.0, 4.0, 0.0, 0);

INSERT INTO lich_su_cong_phep (nhan_vien_id, nam, thang, so_ngay_cong, loai_cong, ly_do)
VALUES 
(8, 2025, 9, 1.0, 'hang_thang', 'Cộng 1 ngày phép cho tháng 9/2025'),
(8, 2025, 10, 1.0, 'hang_thang', 'Cộng 1 ngày phép cho tháng 10/2025'),
(8, 2025, 11, 1.0, 'hang_thang', 'Cộng 1 ngày phép cho tháng 11/2025'),
(8, 2025, 12, 1.0, 'hang_thang', 'Cộng 1 ngày phép cho tháng 12/2025');

-- ID=10: Nguyễn Đức Dương - Vào làm 02/08/2025 → Tháng 8,9,10,11,12 (vào trước 15) = 5 ngày ✅ NHÓM 2
INSERT INTO ngay_phep_nam (nhan_vien_id, nam, tong_ngay_phep, ngay_phep_da_dung, ngay_phep_con_lai, ngay_phep_nam_truoc, da_cong_phep_dau_nam)
VALUES (10, 2025, 5.0, 0.0, 5.0, 0.0, 0);

INSERT INTO lich_su_cong_phep (nhan_vien_id, nam, thang, so_ngay_cong, loai_cong, ly_do)
VALUES 
(10, 2025, 8, 1.0, 'hang_thang', 'Cộng 1 ngày phép cho tháng 8/2025'),
(10, 2025, 9, 1.0, 'hang_thang', 'Cộng 1 ngày phép cho tháng 9/2025'),
(10, 2025, 10, 1.0, 'hang_thang', 'Cộng 1 ngày phép cho tháng 10/2025'),
(10, 2025, 11, 1.0, 'hang_thang', 'Cộng 1 ngày phép cho tháng 11/2025'),
(10, 2025, 12, 1.0, 'hang_thang', 'Cộng 1 ngày phép cho tháng 12/2025');

-- ID=11: Đặng Lê Trung - Vào làm 21/07/2025 → Tháng 7 (vào > 15) KHÔNG +1, 8,9,10,11,12 = 5 ngày ✅ NHÓM 2
INSERT INTO ngay_phep_nam (nhan_vien_id, nam, tong_ngay_phep, ngay_phep_da_dung, ngay_phep_con_lai, ngay_phep_nam_truoc, da_cong_phep_dau_nam)
VALUES (11, 2025, 5.0, 0.0, 5.0, 0.0, 0);

INSERT INTO lich_su_cong_phep (nhan_vien_id, nam, thang, so_ngay_cong, loai_cong, ly_do)
VALUES 
(11, 2025, 8, 1.0, 'hang_thang', 'Cộng 1 ngày phép cho tháng 8/2025'),
(11, 2025, 9, 1.0, 'hang_thang', 'Cộng 1 ngày phép cho tháng 9/2025'),
(11, 2025, 10, 1.0, 'hang_thang', 'Cộng 1 ngày phép cho tháng 10/2025'),
(11, 2025, 11, 1.0, 'hang_thang', 'Cộng 1 ngày phép cho tháng 11/2025'),
(11, 2025, 12, 1.0, 'hang_thang', 'Cộng 1 ngày phép cho tháng 12/2025');

-- ID=12: Vũ Thị Hải Yến - Vào làm 04/09/2025 → Tháng 9,10,11,12 (vào trước 15) = 4 ngày ✅ NHÓM 2
INSERT INTO ngay_phep_nam (nhan_vien_id, nam, tong_ngay_phep, ngay_phep_da_dung, ngay_phep_con_lai, ngay_phep_nam_truoc, da_cong_phep_dau_nam)
VALUES (12, 2025, 4.0, 0.0, 4.0, 0.0, 0);

INSERT INTO lich_su_cong_phep (nhan_vien_id, nam, thang, so_ngay_cong, loai_cong, ly_do)
VALUES 
(12, 2025, 9, 1.0, 'hang_thang', 'Cộng 1 ngày phép cho tháng 9/2025'),
(12, 2025, 10, 1.0, 'hang_thang', 'Cộng 1 ngày phép cho tháng 10/2025'),
(12, 2025, 11, 1.0, 'hang_thang', 'Cộng 1 ngày phép cho tháng 11/2025'),
(12, 2025, 12, 1.0, 'hang_thang', 'Cộng 1 ngày phép cho tháng 12/2025');

-- ID=15: Đặng Thu Hồng - Vào làm 01/07/2025 → Tháng 7,8,9,10,11,12 (vào trước 15) = 6 ngày ✅ NHÓM 2
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

-- ID=16: Phan Tuấn Linh - Vào làm 21/03/2025 → Tháng 3 (vào > 15) KHÔNG +1, 4,5,6,7,8,9,10,11,12 = 9 ngày ✅ NHÓM 2
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

-- ID=18: zAdmin - Vào làm 13/09/2025 → Tháng 9,10,11,12 (vào trước 15) = 4 ngày ✅ NHÓM 2
INSERT INTO ngay_phep_nam (nhan_vien_id, nam, tong_ngay_phep, ngay_phep_da_dung, ngay_phep_con_lai, ngay_phep_nam_truoc, da_cong_phep_dau_nam)
VALUES (18, 2025, 4.0, 0.0, 4.0, 0.0, 0);

INSERT INTO lich_su_cong_phep (nhan_vien_id, nam, thang, so_ngay_cong, loai_cong, ly_do)
VALUES 
(18, 2025, 9, 1.0, 'hang_thang', 'Cộng 1 ngày phép cho tháng 9/2025'),
(18, 2025, 10, 1.0, 'hang_thang', 'Cộng 1 ngày phép cho tháng 10/2025'),
(18, 2025, 11, 1.0, 'hang_thang', 'Cộng 1 ngày phép cho tháng 11/2025'),
(18, 2025, 12, 1.0, 'hang_thang', 'Cộng 1 ngày phép cho tháng 12/2025');

-- ID=22: Đào Huy Hoàng - Vào làm 01/10/2025 → Tháng 10,11,12 (vào trước 15) = 3 ngày ✅ NHÓM 2
INSERT INTO ngay_phep_nam (nhan_vien_id, nam, tong_ngay_phep, ngay_phep_da_dung, ngay_phep_con_lai, ngay_phep_nam_truoc, da_cong_phep_dau_nam)
VALUES (22, 2025, 3.0, 0.0, 3.0, 0.0, 0);

INSERT INTO lich_su_cong_phep (nhan_vien_id, nam, thang, so_ngay_cong, loai_cong, ly_do)
VALUES 
(22, 2025, 10, 1.0, 'hang_thang', 'Cộng 1 ngày phép cho tháng 10/2025'),
(22, 2025, 11, 1.0, 'hang_thang', 'Cộng 1 ngày phép cho tháng 11/2025'),
(22, 2025, 12, 1.0, 'hang_thang', 'Cộng 1 ngày phép cho tháng 12/2025');

-- ID=23: Tuấn Anh - Vào làm 01/11/2025 → Tháng 11,12 (vào trước 15) = 2 ngày ✅ NHÓM 2
INSERT INTO ngay_phep_nam (nhan_vien_id, nam, tong_ngay_phep, ngay_phep_da_dung, ngay_phep_con_lai, ngay_phep_nam_truoc, da_cong_phep_dau_nam)
VALUES (23, 2025, 2.0, 0.0, 2.0, 0.0, 0);

INSERT INTO lich_su_cong_phep (nhan_vien_id, nam, thang, so_ngay_cong, loai_cong, ly_do)
VALUES 
(23, 2025, 11, 1.0, 'hang_thang', 'Cộng 1 ngày phép cho tháng 11/2025'),
(23, 2025, 12, 1.0, 'hang_thang', 'Cộng 1 ngày phép cho tháng 12/2025');

-- ID=24: Nguyễn Ngọc Tuyền - Vào làm 22/07/2025 → Tháng 7 (vào > 15) KHÔNG +1, 8,9,10,11,12 = 5 ngày ✅ NHÓM 2
INSERT INTO ngay_phep_nam (nhan_vien_id, nam, tong_ngay_phep, ngay_phep_da_dung, ngay_phep_con_lai, ngay_phep_nam_truoc, da_cong_phep_dau_nam)
VALUES (24, 2025, 5.0, 0.0, 5.0, 0.0, 0);

INSERT INTO lich_su_cong_phep (nhan_vien_id, nam, thang, so_ngay_cong, loai_cong, ly_do)
VALUES 
(24, 2025, 8, 1.0, 'hang_thang', 'Cộng 1 ngày phép cho tháng 8/2025'),
(24, 2025, 9, 1.0, 'hang_thang', 'Cộng 1 ngày phép cho tháng 9/2025'),
(24, 2025, 10, 1.0, 'hang_thang', 'Cộng 1 ngày phép cho tháng 10/2025'),
(24, 2025, 11, 1.0, 'hang_thang', 'Cộng 1 ngày phép cho tháng 11/2025'),
(24, 2025, 12, 1.0, 'hang_thang', 'Cộng 1 ngày phép cho tháng 12/2025');

-- ID=25: Phạm Minh Thắng - Vào làm 20/07/2025 → Tháng 7 (vào > 15) KHÔNG +1, 8,9,10,11,12 = 5 ngày ✅ NHÓM 2
INSERT INTO ngay_phep_nam (nhan_vien_id, nam, tong_ngay_phep, ngay_phep_da_dung, ngay_phep_con_lai, ngay_phep_nam_truoc, da_cong_phep_dau_nam)
VALUES (25, 2025, 5.0, 0.0, 5.0, 0.0, 0);

INSERT INTO lich_su_cong_phep (nhan_vien_id, nam, thang, so_ngay_cong, loai_cong, ly_do)
VALUES 
(25, 2025, 8, 1.0, 'hang_thang', 'Cộng 1 ngày phép cho tháng 8/2025'),
(25, 2025, 9, 1.0, 'hang_thang', 'Cộng 1 ngày phép cho tháng 9/2025'),
(25, 2025, 10, 1.0, 'hang_thang', 'Cộng 1 ngày phép cho tháng 10/2025'),
(25, 2025, 11, 1.0, 'hang_thang', 'Cộng 1 ngày phép cho tháng 11/2025'),
(25, 2025, 12, 1.0, 'hang_thang', 'Cộng 1 ngày phép cho tháng 12/2025');

-- ID=27: Nguyễn Công Bảo - Vào làm 20/11/2025 → Tháng 11 (vào > 15) KHÔNG +1, 12 = 1 ngày ✅ NHÓM 2
INSERT INTO ngay_phep_nam (nhan_vien_id, nam, tong_ngay_phep, ngay_phep_da_dung, ngay_phep_con_lai, ngay_phep_nam_truoc, da_cong_phep_dau_nam)
VALUES (27, 2025, 1.0, 0.0, 1.0, 0.0, 0);

INSERT INTO lich_su_cong_phep (nhan_vien_id, nam, thang, so_ngay_cong, loai_cong, ly_do)
VALUES (27, 2025, 12, 1.0, 'hang_thang', 'Cộng 1 ngày phép cho tháng 12/2025');

-- ID=28: Nguyễn Tiến Minh - Vào làm 27/11/2025 → Tháng 11 (vào > 15) KHÔNG +1, 12 = 1 ngày ✅ NHÓM 2
INSERT INTO ngay_phep_nam (nhan_vien_id, nam, tong_ngay_phep, ngay_phep_da_dung, ngay_phep_con_lai, ngay_phep_nam_truoc, da_cong_phep_dau_nam)
VALUES (28, 2025, 1.0, 0.0, 1.0, 0.0, 0);

INSERT INTO lich_su_cong_phep (nhan_vien_id, nam, thang, so_ngay_cong, loai_cong, ly_do)
VALUES (28, 2025, 12, 1.0, 'hang_thang', 'Cộng 1 ngày phép cho tháng 12/2025');

-- ID=4: Võ Trung Âu - NHÓM 1: Đã có 12 ngày năm 2025 → Chuyển sang + +12 năm 2026
INSERT INTO ngay_phep_nam (nhan_vien_id, nam, tong_ngay_phep, ngay_phep_da_dung, ngay_phep_con_lai, ngay_phep_nam_truoc, da_cong_phep_dau_nam)
VALUES (4, 2026, 12.0, 0.0, 12.0, 12.0, 1);

INSERT INTO lich_su_cong_phep (nhan_vien_id, nam, thang, so_ngay_cong, loai_cong, ly_do)
VALUES (4, 2026, NULL, 12.0, 'dau_nam', 'Cộng 12 ngày phép đầu năm 2026 + Chuyển 12 ngày phép năm 2025 (dùng trong Q1)');

-- NHÓM 2: Các nhân viên chưa đủ 12 tháng tính tới 01/01/2026
-- Chỉ lưu phép năm 2025, KHÔNG cộng 12 ngày, KHÔNG cộng phép tháng 1 (chưa hết tháng)

-- ID=3: Nguyễn Tấn Dũng - Chuyển 8 ngày phép 2025
INSERT INTO ngay_phep_nam (nhan_vien_id, nam, tong_ngay_phep, ngay_phep_da_dung, ngay_phep_con_lai, ngay_phep_nam_truoc, da_cong_phep_dau_nam)
VALUES (3, 2026, 0.0, 0.0, 0.0, 8.0, 0);

-- ID=6: Vũ Tam Hanh - Chuyển 4 ngày phép 2025
INSERT INTO ngay_phep_nam (nhan_vien_id, nam, tong_ngay_phep, ngay_phep_da_dung, ngay_phep_con_lai, ngay_phep_nam_truoc, da_cong_phep_dau_nam)
VALUES (6, 2026, 0.0, 0.0, 0.0, 4.0, 0);

-- ID=7: Nguyễn Thị Diễm Quỳnh - Chuyển 6 ngày phép 2025
INSERT INTO ngay_phep_nam (nhan_vien_id, nam, tong_ngay_phep, ngay_phep_da_dung, ngay_phep_con_lai, ngay_phep_nam_truoc, da_cong_phep_dau_nam)
VALUES (7, 2026, 0.0, 0.0, 0.0, 6.0, 0);

-- ID=8: Trần Đình Nam - Chuyển 4 ngày phép 2025
INSERT INTO ngay_phep_nam (nhan_vien_id, nam, tong_ngay_phep, ngay_phep_da_dung, ngay_phep_con_lai, ngay_phep_nam_truoc, da_cong_phep_dau_nam)
VALUES (8, 2026, 0.0, 0.0, 0.0, 4.0, 0);

-- ID=10: Nguyễn Đức Dương - Chuyển 5 ngày phép 2025
INSERT INTO ngay_phep_nam (nhan_vien_id, nam, tong_ngay_phep, ngay_phep_da_dung, ngay_phep_con_lai, ngay_phep_nam_truoc, da_cong_phep_dau_nam)
VALUES (10, 2026, 0.0, 0.0, 0.0, 5.0, 0);

-- ID=11: Đặng Lê Trung - Chuyển 5 ngày phép 2025
INSERT INTO ngay_phep_nam (nhan_vien_id, nam, tong_ngay_phep, ngay_phep_da_dung, ngay_phep_con_lai, ngay_phep_nam_truoc, da_cong_phep_dau_nam)
VALUES (11, 2026, 0.0, 0.0, 0.0, 5.0, 0);

-- ID=12: Vũ Thị Hải Yến - Chuyển 4 ngày phép 2025
INSERT INTO ngay_phep_nam (nhan_vien_id, nam, tong_ngay_phep, ngay_phep_da_dung, ngay_phep_con_lai, ngay_phep_nam_truoc, da_cong_phep_dau_nam)
VALUES (12, 2026, 0.0, 0.0, 0.0, 4.0, 0);

-- ID=15: Đặng Thu Hồng - Chuyển 6 ngày phép 2025
INSERT INTO ngay_phep_nam (nhan_vien_id, nam, tong_ngay_phep, ngay_phep_da_dung, ngay_phep_con_lai, ngay_phep_nam_truoc, da_cong_phep_dau_nam)
VALUES (15, 2026, 0.0, 0.0, 0.0, 6.0, 0);

-- ID=16: Phan Tuấn Linh - Chuyển 9 ngày phép 2025
INSERT INTO ngay_phep_nam (nhan_vien_id, nam, tong_ngay_phep, ngay_phep_da_dung, ngay_phep_con_lai, ngay_phep_nam_truoc, da_cong_phep_dau_nam)
VALUES (16, 2026, 0.0, 0.0, 0.0, 9.0, 0);

-- ID=18: zAdmin - Chuyển 4 ngày phép 2025
INSERT INTO ngay_phep_nam (nhan_vien_id, nam, tong_ngay_phep, ngay_phep_da_dung, ngay_phep_con_lai, ngay_phep_nam_truoc, da_cong_phep_dau_nam)
VALUES (18, 2026, 0.0, 0.0, 0.0, 4.0, 0);

-- ID=22: Đào Huy Hoàng - Chuyển 3 ngày phép 2025
INSERT INTO ngay_phep_nam (nhan_vien_id, nam, tong_ngay_phep, ngay_phep_da_dung, ngay_phep_con_lai, ngay_phep_nam_truoc, da_cong_phep_dau_nam)
VALUES (22, 2026, 0.0, 0.0, 0.0, 3.0, 0);

-- ID=23: Tuấn Anh - Chuyển 2 ngày phép 2025
INSERT INTO ngay_phep_nam (nhan_vien_id, nam, tong_ngay_phep, ngay_phep_da_dung, ngay_phep_con_lai, ngay_phep_nam_truoc, da_cong_phep_dau_nam)
VALUES (23, 2026, 0.0, 0.0, 0.0, 2.0, 0);

-- ID=24: Nguyễn Ngọc Tuyền - Chuyển 5 ngày phép 2025
INSERT INTO ngay_phep_nam (nhan_vien_id, nam, tong_ngay_phep, ngay_phep_da_dung, ngay_phep_con_lai, ngay_phep_nam_truoc, da_cong_phep_dau_nam)
VALUES (24, 2026, 0.0, 0.0, 0.0, 5.0, 0);

-- ID=25: Phạm Minh Thắng - Chuyển 5 ngày phép 2025
INSERT INTO ngay_phep_nam (nhan_vien_id, nam, tong_ngay_phep, ngay_phep_da_dung, ngay_phep_con_lai, ngay_phep_nam_truoc, da_cong_phep_dau_nam)
VALUES (25, 2026, 0.0, 0.0, 0.0, 5.0, 0);

-- ID=27: Nguyễn Công Bảo - Chuyển 1 ngày phép 2025
INSERT INTO ngay_phep_nam (nhan_vien_id, nam, tong_ngay_phep, ngay_phep_da_dung, ngay_phep_con_lai, ngay_phep_nam_truoc, da_cong_phep_dau_nam)
VALUES (27, 2026, 0.0, 0.0, 0.0, 1.0, 0);

-- ID=28: Nguyễn Tiến Minh - Chuyển 1 ngày phép 2025
INSERT INTO ngay_phep_nam (nhan_vien_id, nam, tong_ngay_phep, ngay_phep_da_dung, ngay_phep_con_lai, ngay_phep_nam_truoc, da_cong_phep_dau_nam)
VALUES (28, 2026, 0.0, 0.0, 0.0, 1.0, 0);

-- ID=30, 31, 32: Vào làm 05/01/2026 - Chưa hết tháng 1 → Không có phép
INSERT INTO ngay_phep_nam (nhan_vien_id, nam, tong_ngay_phep, ngay_phep_da_dung, ngay_phep_con_lai, ngay_phep_nam_truoc, da_cong_phep_dau_nam)
VALUES (30, 2026, 0.0, 0.0, 0.0, 0.0, 0);

INSERT INTO ngay_phep_nam (nhan_vien_id, nam, tong_ngay_phep, ngay_phep_da_dung, ngay_phep_con_lai, ngay_phep_nam_truoc, da_cong_phep_dau_nam)
VALUES (31, 2026, 0.0, 0.0, 0.0, 0.0, 0);

INSERT INTO ngay_phep_nam (nhan_vien_id, nam, tong_ngay_phep, ngay_phep_da_dung, ngay_phep_con_lai, ngay_phep_nam_truoc, da_cong_phep_dau_nam)
VALUES (32, 2026, 0.0, 0.0, 0.0, 0.0, 0);

COMMIT;
