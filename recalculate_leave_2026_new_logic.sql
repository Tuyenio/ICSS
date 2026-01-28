
CREATE TEMPORARY TABLE temp_leave_2025_old AS
SELECT nhan_vien_id, ngay_phep_da_dung, ngay_phep_con_lai 
FROM ngay_phep_nam 
WHERE nam = 2025;

-- ============================================================
-- BƯỚC 1: XÓA DỮ LIỆU NGÀY PHÉP NĂM 2025 & 2026 CỦA TẤT CẢ NHÂN VIÊN
-- ============================================================
DELETE FROM ngay_phep_nam WHERE nam IN (2025, 2026);

-- ============================================================
-- BƯỚC 2: TÍNH LẠI NGÀY PHÉP NĂM 2025 & 2026 THEO LOGIC MỚI
-- ============================================================
-- Xem dữ liệu trước khi cập nhật (kiểm tra logic cho cả 2025 và 2026)
SELECT 
    nv.id,
    nv.ho_ten,
    nv.ngay_vao_lam,
    CASE
        WHEN nv.ngay_vao_lam < '2024-01-01' THEN 
            '12 (trước 2024)'
        WHEN nv.ngay_vao_lam >= '2024-01-01' AND nv.ngay_vao_lam <= '2024-12-31' THEN
            CONCAT(
                CASE 
                    WHEN DAY(nv.ngay_vao_lam) <= 15 THEN
                        (13 - MONTH(nv.ngay_vao_lam))
                    ELSE
                        (12 - MONTH(nv.ngay_vao_lam))
                END,
                ' (vào tháng ', MONTH(nv.ngay_vao_lam), ' năm 2024)'
            )
        ELSE 
            '0 (vào năm 2025 hoặc 2026)'
    END as so_ngay_phep_2025,
    CASE
        WHEN nv.ngay_vao_lam < '2025-01-01' THEN 
            '12 (từ 1/1/2026)'
        WHEN nv.ngay_vao_lam >= '2025-01-01' AND nv.ngay_vao_lam <= '2025-12-31' THEN
            CONCAT(
                CASE 
                    WHEN DAY(nv.ngay_vao_lam) <= 15 THEN
                        (13 - MONTH(nv.ngay_vao_lam))
                    ELSE
                        (12 - MONTH(nv.ngay_vao_lam))
                END,
                ' (cộng từ tháng ', 
                CASE 
                    WHEN DAY(nv.ngay_vao_lam) <= 15 THEN MONTH(nv.ngay_vao_lam)
                    ELSE (MONTH(nv.ngay_vao_lam) + 1)
                END,
                ' năm 2026)'
            )
        ELSE 
            '0 (vào năm 2026)'
    END as so_ngay_phep_2026
FROM nhanvien nv
WHERE nv.trang_thai_lam_viec = 'Đang làm'
ORDER BY nv.ngay_vao_lam;

-- ============================================================
-- BƯỚC 3: THÊM DỮ LIỆU NGÀY PHÉP NĂM 2025 (giữ lại số đã dùng từ dữ liệu cũ)
-- ============================================================
INSERT INTO ngay_phep_nam (nhan_vien_id, nam, tong_ngay_phep, ngay_phep_da_dung, ngay_phep_con_lai, ngay_phep_nam_truoc, da_cong_phep_dau_nam)
SELECT 
    nv.id as nhan_vien_id,
    2025 as nam,
    -- Tính số ngày phép năm 2025
    CASE
        -- Nếu vào làm trước 1/1/2024
        WHEN nv.ngay_vao_lam < '2024-01-01' THEN 12.0
        
        -- Nếu vào làm từ 1/1/2024 đến 31/12/2024
        WHEN nv.ngay_vao_lam >= '2024-01-01' AND nv.ngay_vao_lam <= '2024-12-31' THEN
            CASE 
                -- Nếu vào trước ngày 15: tính từ tháng vào đến tháng 12
                WHEN DAY(nv.ngay_vao_lam) <= 15 THEN
                    (13 - MONTH(nv.ngay_vao_lam)) * 1.0
                -- Nếu vào sau ngày 15: tính từ tháng sau đến tháng 12
                ELSE
                    (12 - MONTH(nv.ngay_vao_lam)) * 1.0
            END
        
        -- Nếu vào từ 1/1/2025 trở về sau: không được cộng phép năm 2025
        ELSE 0.0
    END as tong_ngay_phep,
    
    -- Lấy số đã dùng từ dữ liệu cũ (nếu có), nếu không thì = 0
    COALESCE(old.ngay_phep_da_dung, 0.0) as ngay_phep_da_dung,
    
    -- Tính ngày còn lại = tổng ngày phép - đã dùng (từ dữ liệu cũ)
    CASE
        WHEN nv.ngay_vao_lam < '2024-01-01' THEN 
            12.0 - COALESCE(old.ngay_phep_da_dung, 0.0)
        WHEN nv.ngay_vao_lam >= '2024-01-01' AND nv.ngay_vao_lam <= '2024-12-31' THEN
            CASE 
                WHEN DAY(nv.ngay_vao_lam) <= 15 THEN
                    (13 - MONTH(nv.ngay_vao_lam)) * 1.0 - COALESCE(old.ngay_phep_da_dung, 0.0)
                ELSE
                    (12 - MONTH(nv.ngay_vao_lam)) * 1.0 - COALESCE(old.ngay_phep_da_dung, 0.0)
            END
        ELSE 0.0 - COALESCE(old.ngay_phep_da_dung, 0.0)
    END as ngay_phep_con_lai,
    
    0.0 as ngay_phep_nam_truoc, -- Năm 2025 không có phép năm trước
    
    -- Đánh dấu đã cộng phép đầu năm cho NV >= 12 tháng
    CASE 
        WHEN nv.ngay_vao_lam < '2024-01-01' THEN 1
        WHEN nv.ngay_vao_lam >= '2024-01-01' AND nv.ngay_vao_lam <= '2024-12-31' THEN
            CASE 
                WHEN DAY(nv.ngay_vao_lam) <= 15 AND (13 - MONTH(nv.ngay_vao_lam)) >= 12 THEN 1
                WHEN DAY(nv.ngay_vao_lam) > 15 AND (12 - MONTH(nv.ngay_vao_lam)) >= 12 THEN 1
                ELSE 0
            END
        ELSE 0
    END as da_cong_phep_dau_nam
    
FROM nhanvien nv
LEFT JOIN temp_leave_2025_old old ON nv.id = old.nhan_vien_id
WHERE nv.trang_thai_lam_viec = 'Đang làm';

-- ============================================================
-- BƯỚC 4: THÊM DỮ LIỆU NGÀY PHÉP NĂM 2026
-- ============================================================
-- ============================================================
-- BƯỚC 4: THÊM DỮ LIỆU NGÀY PHÉP NĂM 2026
-- ============================================================
INSERT INTO ngay_phep_nam (nhan_vien_id, nam, tong_ngay_phep, ngay_phep_da_dung, ngay_phep_con_lai, ngay_phep_nam_truoc, da_cong_phep_dau_nam)
SELECT 
    nv.id as nhan_vien_id,
    2026 as nam,
    -- Tính số ngày phép năm 2026
    CASE
        -- Nếu vào làm trước 1/1/2025 (đã làm > 12 tháng vào 1/1/2026)
        WHEN nv.ngay_vao_lam < '2025-01-01' THEN 12.0
        
        -- Nếu vào làm từ 1/1/2025 đến 31/12/2025
        WHEN nv.ngay_vao_lam >= '2025-01-01' AND nv.ngay_vao_lam <= '2025-12-31' THEN
            CASE 
                -- Nếu vào trước ngày 15: tính từ tháng vào đến tháng 12
                WHEN DAY(nv.ngay_vao_lam) <= 15 THEN
                    (13 - MONTH(nv.ngay_vao_lam)) * 1.0
                -- Nếu vào sau ngày 15: tính từ tháng sau đến tháng 12
                ELSE
                    (12 - MONTH(nv.ngay_vao_lam)) * 1.0
            END
        
        -- Nếu vào làm năm 2026: tạm không cộng
        ELSE 0.0
    END as tong_ngay_phep,
    
    0.0 as ngay_phep_da_dung,
    
    -- Tính ngày còn lại = tổng ngày phép - đã dùng
    CASE
        WHEN nv.ngay_vao_lam < '2025-01-01' THEN 12.0
        WHEN nv.ngay_vao_lam >= '2025-01-01' AND nv.ngay_vao_lam <= '2025-12-31' THEN
            CASE 
                WHEN DAY(nv.ngay_vao_lam) <= 15 THEN
                    (13 - MONTH(nv.ngay_vao_lam)) * 1.0
                ELSE
                    (12 - MONTH(nv.ngay_vao_lam)) * 1.0
            END
        ELSE 0.0
    END as ngay_phep_con_lai,
    
    -- Lấy phép năm 2025 còn lại để chuyển sang 2026 (nếu có)
    COALESCE((SELECT ngay_phep_con_lai FROM ngay_phep_nam WHERE nhan_vien_id = nv.id AND nam = 2025), 0.0) as ngay_phep_nam_truoc,
    
    -- Đánh dấu đã cộng phép đầu năm cho NV >= 12 tháng
    CASE 
        WHEN nv.ngay_vao_lam < '2025-01-01' THEN 1 -- Đã đủ 12 tháng
        WHEN nv.ngay_vao_lam >= '2025-01-01' AND nv.ngay_vao_lam <= '2025-12-31' THEN
            CASE 
                WHEN DAY(nv.ngay_vao_lam) <= 15 AND (13 - MONTH(nv.ngay_vao_lam)) >= 12 THEN 1
                WHEN DAY(nv.ngay_vao_lam) > 15 AND (12 - MONTH(nv.ngay_vao_lam)) >= 12 THEN 1
                ELSE 0
            END
        ELSE 0
    END as da_cong_phep_dau_nam
    
FROM nhanvien nv
WHERE nv.trang_thai_lam_viec = 'Đang làm';

-- ============================================================
-- BƯỚC 5: KIỂM TRA KẾT QUẢ SAU KHI CẬP NHẬT
-- ============================================================
-- ============================================================
-- BƯỚC 5: KIỂM TRA KẾT QUẢ SAU KHI CẬP NHẬT
-- ============================================================
-- Kiểm tra năm 2025
SELECT 
    '=== KẾT QUẢ NĂM 2025 ===' as '---',
    nv.id,
    nv.ho_ten,
    nv.ngay_vao_lam,
    np.tong_ngay_phep as 'Tổng phép 2025',
    np.ngay_phep_da_dung as 'Đã dùng',
    np.ngay_phep_con_lai as 'Còn lại',
    np.da_cong_phep_dau_nam as 'Đánh dấu'
FROM ngay_phep_nam np
JOIN nhanvien nv ON np.nhan_vien_id = nv.id
WHERE np.nam = 2025
ORDER BY nv.ho_ten;

-- Kiểm tra năm 2026
SELECT 
    '=== KẾT QUẢ NĂM 2026 ===' as '---',
    nv.id,
    nv.ho_ten,
    nv.ngay_vao_lam,
    np.tong_ngay_phep as 'Tổng phép 2026',
    np.ngay_phep_da_dung as 'Đã dùng',
    np.ngay_phep_con_lai as 'Còn lại năm nay',
    np.ngay_phep_nam_truoc as 'Phép 2025 chuyển sang',
    np.da_cong_phep_dau_nam as 'Đánh dấu',
    CASE 
        WHEN np.ngay_phep_nam_truoc > 0 THEN CONCAT(np.ngay_phep_con_lai, ' (2026) + ', np.ngay_phep_nam_truoc, ' (2025)')
        ELSE CAST(np.ngay_phep_con_lai AS CHAR)
    END as 'Hiển thị cho người dùng'
FROM ngay_phep_nam np
JOIN nhanvien nv ON np.nhan_vien_id = nv.id
WHERE np.nam = 2026
ORDER BY nv.ho_ten;

-- ============================================================
-- BƯỚC 6: THỐNG KÊ TỔNG HỢP
-- ============================================================
SELECT 
    '=== THỐNG KÊ NĂM 2025 ===' as 'Năm',
    COUNT(*) as 'Tổng nhân viên đang làm',
    SUM(CASE WHEN np.tong_ngay_phep > 0 THEN 1 ELSE 0 END) as 'NV được cộng phép',
    SUM(np.tong_ngay_phep) as 'Tổng phép cấp',
    ROUND(AVG(np.tong_ngay_phep), 1) as 'Trung bình phép/người'
FROM ngay_phep_nam np
WHERE np.nam = 2025;

SELECT 
    '=== THỐNG KÊ NĂM 2026 ===' as 'Năm',
    COUNT(*) as 'Tổng nhân viên đang làm',
    SUM(CASE WHEN np.tong_ngay_phep > 0 THEN 1 ELSE 0 END) as 'NV được cộng phép',
    SUM(np.tong_ngay_phep) as 'Tổng phép cấp',
    ROUND(AVG(np.tong_ngay_phep), 1) as 'Trung bình phép/người',
    SUM(CASE WHEN np.da_cong_phep_dau_nam = 1 THEN 1 ELSE 0 END) as 'NV >= 12 tháng',
    SUM(CASE WHEN np.da_cong_phep_dau_nam = 0 AND np.tong_ngay_phep > 0 THEN 1 ELSE 0 END) as 'NV < 12 tháng',
    SUM(np.ngay_phep_nam_truoc) as 'Phép 2025 chuyển sang'
FROM ngay_phep_nam np
WHERE np.nam = 2026;

-- ============================================================
-- BƯỚC 7: LƯU LỊCH SỬ CẬP NHẬT (TÙY CHỌN)
-- ============================================================
-- Lưu lịch sử cộng phép năm 2025
INSERT INTO lich_su_cong_phep (nhan_vien_id, nam, thang, so_ngay_cong, loai_cong, ly_do)
SELECT 
    np.nhan_vien_id,
    2025 as nam,
    NULL as thang,
    np.tong_ngay_phep as so_ngay_cong,
    'dau_nam' as loai_cong,
    CONCAT('Cộng phép năm 2025 - ', np.tong_ngay_phep, ' ngày (tính lại theo logic mới)') as ly_do
FROM ngay_phep_nam np
WHERE np.nam = 2025 AND np.tong_ngay_phep > 0;

-- Lưu lịch sử cộng phép năm 2026 cho NV được cộng 12 ngày đầu năm
INSERT INTO lich_su_cong_phep (nhan_vien_id, nam, thang, so_ngay_cong, loai_cong, ly_do)
SELECT 
    np.nhan_vien_id,
    2026 as nam,
    NULL as thang,
    np.tong_ngay_phep as so_ngay_cong,
    'dau_nam' as loai_cong,
    CONCAT('Cộng phép đầu năm 2026 - ', np.tong_ngay_phep, ' ngày (tính lại theo logic mới)') as ly_do
FROM ngay_phep_nam np
WHERE np.nam = 2026 AND np.da_cong_phep_dau_nam = 1 AND np.tong_ngay_phep > 0;

-- ============================================================
-- BƯỚC 8: DỰN DỌN BẢNG TẠM
-- ============================================================
DROP TEMPORARY TABLE temp_leave_2025_old;

-- ============================================================
-- BƯỚC 9: COMMIT DỮ LIỆU
-- ============================================================
COMMIT;