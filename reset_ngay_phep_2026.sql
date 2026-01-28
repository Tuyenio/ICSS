-- Script xóa và tính lại số ngày phép năm 2026 cho toàn bộ nhân viên
-- Theo logic cộng phép mới:
--   - NV vào làm trước 1/1/2025 (đã làm > 12 tháng): 12 ngày, đánh dấu da_cong_phep_dau_nam = 1
--   - NV vào làm từ 1/1/2025 trở về sau: +1 ngày mỗi tháng (nếu vào trước ngày 15)

-- ============================================================
-- BƯỚC 1: XÓA DỮ LIỆU NGÀY PHÉP NĂM 2026 CỦA TẤT CẢ NHÂN VIÊN
-- ============================================================
DELETE FROM ngay_phep_nam WHERE nam = 2026;

-- Kiểm tra đã xóa chưa
SELECT COUNT(*) as so_ban_ghi_con FROM ngay_phep_nam WHERE nam = 2026;

-- ============================================================
-- BƯỚC 2: TÍNH LẠI NGÀY PHÉP NĂM 2026 THEO LOGIC MỚI
-- ============================================================
-- Logic:
-- - NV vào trước 1/1/2025: được +12 ngày vào đầu 2026 (da_cong_phep_dau_nam = 1)
-- - NV vào từ 1/1/2025 - 31/12/2025:
--   + Nếu vào trước ngày 15: tháng đó được tính (mỗi tháng +1 ngày)
--   + Nếu vào sau ngày 15: tháng đó không được tính
-- - NV vào năm 2026: tính theo số tháng còn lại từ vào làm đến 31/12/2026

-- Xem dữ liệu trước khi cập nhật (SELECT dùng để kiểm tra)
SELECT 
    nv.id,
    nv.ho_ten,
    nv.ngay_vao_lam,
    nv.trang_thai_lam_viec,
    -- Tính số tháng làm việc đến 31/12/2026
    TIMESTAMPDIFF(MONTH, nv.ngay_vao_lam, '2026-12-31') as so_thang_lam_den_cuoi_2026,
    -- Tính số ngày phép theo logic mới
    CASE
        -- Nếu vào làm trước 1/1/2025 (đã làm > 12 tháng vào 1/1/2026)
        WHEN nv.ngay_vao_lam < '2025-01-01' THEN 12.0
        -- Nếu vào làm từ 1/1/2025 đến 31/12/2025
        WHEN nv.ngay_vao_lam >= '2025-01-01' AND nv.ngay_vao_lam <= '2025-12-31' THEN
            CASE 
                -- Vào trước ngày 15: tính từ tháng vào làm đến 31/12/2026 + 1 (tháng vào làm)
                WHEN DAY(nv.ngay_vao_lam) <= 15 THEN
                    LEAST(12.0, TIMESTAMPDIFF(MONTH, nv.ngay_vao_lam, '2026-12-31') + 1)
                -- Vào sau ngày 15: tính từ tháng sau tháng vào làm đến 31/12/2026
                ELSE
                    LEAST(12.0, TIMESTAMPDIFF(MONTH, nv.ngay_vao_lam, '2026-12-31'))
            END
        -- Nếu vào làm năm 2026
        WHEN nv.ngay_vao_lam >= '2026-01-01' AND nv.ngay_vao_lam <= '2026-12-31' THEN
            CASE 
                -- Vào trước ngày 15: tính từ tháng vào làm đến 31/12/2026
                WHEN DAY(nv.ngay_vao_lam) <= 15 THEN
                    13 - MONTH(nv.ngay_vao_lam)
                -- Vào sau ngày 15: tính từ tháng sau tháng vào làm đến 31/12/2026
                ELSE
                    12 - MONTH(nv.ngay_vao_lam)
            END
        -- Nếu vào làm sau 2026
        ELSE 0.0
    END as so_ngay_phep_nen_co_2026
FROM nhanvien nv
WHERE nv.trang_thai_lam_viec = 'Đang làm'
ORDER BY nv.ngay_vao_lam;

-- ============================================================
-- BƯỚC 3: THÊM DỮ LIỆU NGÀY PHÉP NĂM 2026
-- ============================================================
INSERT INTO ngay_phep_nam (nhan_vien_id, nam, tong_ngay_phep, ngay_phep_da_dung, ngay_phep_con_lai, ngay_phep_nam_truoc, da_cong_phep_dau_nam)
SELECT 
    nv.id as nhan_vien_id,
    2026 as nam,
    -- Tính số ngày phép theo logic mới
    CASE
        -- Nếu vào làm trước 1/1/2025 (đã làm > 12 tháng vào 1/1/2026)
        WHEN nv.ngay_vao_lam < '2025-01-01' THEN 12.0
        -- Nếu vào làm từ 1/1/2025 đến 31/12/2025
        WHEN nv.ngay_vao_lam >= '2025-01-01' AND nv.ngay_vao_lam <= '2025-12-31' THEN
            CASE 
                WHEN DAY(nv.ngay_vao_lam) <= 15 THEN
                    LEAST(12.0, TIMESTAMPDIFF(MONTH, nv.ngay_vao_lam, '2026-12-31') + 1)
                ELSE
                    LEAST(12.0, TIMESTAMPDIFF(MONTH, nv.ngay_vao_lam, '2026-12-31'))
            END
        -- Nếu vào làm năm 2026
        WHEN nv.ngay_vao_lam >= '2026-01-01' AND nv.ngay_vao_lam <= '2026-12-31' THEN
            CASE 
                WHEN DAY(nv.ngay_vao_lam) <= 15 THEN
                    13 - MONTH(nv.ngay_vao_lam)
                ELSE
                    12 - MONTH(nv.ngay_vao_lam)
            END
        ELSE 0.0
    END as tong_ngay_phep,
    0.0 as ngay_phep_da_dung, -- Ban đầu chưa dùng ngày phép nào
    -- Tính ngày còn lại = tổng ngày phép - đã dùng
    CASE
        WHEN nv.ngay_vao_lam < '2025-01-01' THEN 12.0
        WHEN nv.ngay_vao_lam >= '2025-01-01' AND nv.ngay_vao_lam <= '2025-12-31' THEN
            CASE 
                WHEN DAY(nv.ngay_vao_lam) <= 15 THEN
                    LEAST(12.0, TIMESTAMPDIFF(MONTH, nv.ngay_vao_lam, '2026-12-31') + 1)
                ELSE
                    LEAST(12.0, TIMESTAMPDIFF(MONTH, nv.ngay_vao_lam, '2026-12-31'))
            END
        WHEN nv.ngay_vao_lam >= '2026-01-01' AND nv.ngay_vao_lam <= '2026-12-31' THEN
            CASE 
                WHEN DAY(nv.ngay_vao_lam) <= 15 THEN
                    13 - MONTH(nv.ngay_vao_lam)
                ELSE
                    12 - MONTH(nv.ngay_vao_lam)
            END
        ELSE 0.0
    END as ngay_phep_con_lai,
    -- Lấy phép năm 2025 còn lại để chuyển sang 2026 (nếu có)
    COALESCE((SELECT ngay_phep_con_lai FROM ngay_phep_nam WHERE nhan_vien_id = nv.id AND nam = 2025), 0.0) as ngay_phep_nam_truoc,
    -- Đánh dấu đã cộng phép đầu năm cho NV > 12 tháng
    CASE 
        WHEN nv.ngay_vao_lam < '2025-01-01' THEN 1 -- Đã đủ 12 tháng, đánh dấu = 1
        ELSE 0 -- NV mới, sẽ được cộng hàng tháng
    END as da_cong_phep_dau_nam
FROM nhanvien nv
WHERE nv.trang_thai_lam_viec = 'Đang làm';

-- ============================================================
-- BƯỚC 4: KIỂM TRA KẾT QUẢ SAU KHI CẬP NHẬT
-- ============================================================
SELECT 
    nv.id,
    nv.ho_ten,
    nv.ngay_vao_lam,
    np.tong_ngay_phep as 'Tổng phép 2026',
    np.ngay_phep_da_dung as 'Đã dùng',
    np.ngay_phep_con_lai as 'Còn lại năm nay',
    np.ngay_phep_nam_truoc as 'Phép năm 2025 chuyển sang',
    np.da_cong_phep_dau_nam as 'Đánh dấu cộng đầu năm',
    CASE 
        WHEN np.ngay_phep_nam_truoc > 0 THEN CONCAT(np.ngay_phep_con_lai, ' (2026) + ', np.ngay_phep_nam_truoc, ' (2025)')
        ELSE np.ngay_phep_con_lai
    END as 'Hiển thị cho người dùng'
FROM ngay_phep_nam np
JOIN nhanvien nv ON np.nhan_vien_id = nv.id
WHERE np.nam = 2026
ORDER BY nv.ho_ten;

-- ============================================================
-- BƯỚC 5: THỐNG KÊ TỔNG HỢP
-- ============================================================
SELECT 
    COUNT(*) as 'Tổng nhân viên đang làm',
    SUM(np.tong_ngay_phep) as 'Tổng phép năm 2026 cấp',
    AVG(np.tong_ngay_phep) as 'Trung bình phép/người',
    SUM(CASE WHEN np.da_cong_phep_dau_nam = 1 THEN 1 ELSE 0 END) as 'NV > 12 tháng (cộng 12 ngày)',
    SUM(CASE WHEN np.da_cong_phep_dau_nam = 0 THEN 1 ELSE 0 END) as 'NV mới (cộng hàng tháng)',
    SUM(np.ngay_phep_nam_truoc) as 'Tổng phép 2025 chuyển sang'
FROM ngay_phep_nam np
WHERE np.nam = 2026;

-- ============================================================
-- BƯỚC 6: LƯỚI LỊCH SỬ (TÙY CHỌN)
-- ============================================================
-- Nếu muốn lưu lịch sử cập nhật, có thể thêm vào bảng lich_su_cong_phep
INSERT INTO lich_su_cong_phep (nhan_vien_id, nam, thang, so_ngay_cong, loai_cong, ly_do)
SELECT 
    nv.id as nhan_vien_id,
    2026 as nam,
    NULL as thang,
    12.0 as so_ngay_cong,
    'dau_nam' as loai_cong,
    'Cộng lại 12 ngày phép đầu năm 2026 (reset dữ liệu)' as ly_do
FROM nhanvien nv
WHERE nv.trang_thai_lam_viec = 'Đang làm' 
  AND nv.ngay_vao_lam < '2025-01-01';

COMMIT;
