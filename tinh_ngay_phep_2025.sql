-- Script tính và cập nhật số ngày phép năm 2025 cho toàn bộ nhân viên
-- Dựa trên ngày vào làm và logic cũ (mỗi nhân viên 12 ngày/năm)
-- Chạy script này để khởi tạo dữ liệu ban đầu cho năm 2025

-- Bước 1: Tính số ngày phép đã được cộng trong năm 2025 theo logic cũ
-- Logic: 
--   - NV vào làm trước 1/1/2024: đủ 12 tháng vào 1/1/2025 → 12 ngày
--   - NV vào làm từ 1/1/2024 trở về sau: tính số tháng đã làm đến 31/12/2025
--     + Vào trước ngày 15 của tháng: tháng đó được tính
--     + Vào sau ngày 15: tháng đó không tính

-- Xem dữ liệu trước khi cập nhật
SELECT 
    nv.id,
    nv.ho_ten,
    nv.ngay_vao_lam,
    nv.trang_thai_lam_viec,
    -- Tính số tháng làm việc đến 31/12/2025
    TIMESTAMPDIFF(MONTH, nv.ngay_vao_lam, '2025-12-31') as so_thang_lam_den_cuoi_2025,
    -- Tính số ngày phép theo logic cũ
    CASE
        -- Nếu vào làm trước 1/1/2024 (đã làm > 12 tháng vào đầu 2025)
        WHEN nv.ngay_vao_lam < '2024-01-01' THEN 12.0
        -- Nếu vào làm từ 1/1/2024 đến 31/12/2024
        WHEN nv.ngay_vao_lam >= '2024-01-01' AND nv.ngay_vao_lam <= '2024-12-31' THEN
            -- Tính số tháng từ ngày vào làm đến 31/12/2025
            -- Nếu vào trước ngày 15 thì tháng đó được tính
            LEAST(12.0, 
                CASE 
                    WHEN DAY(nv.ngay_vao_lam) <= 15 THEN
                        TIMESTAMPDIFF(MONTH, nv.ngay_vao_lam, '2025-12-31') + 1
                    ELSE
                        TIMESTAMPDIFF(MONTH, nv.ngay_vao_lam, '2025-12-31')
                END
            ) * 1.0
        -- Nếu vào làm năm 2025
        WHEN nv.ngay_vao_lam >= '2025-01-01' AND nv.ngay_vao_lam <= '2025-12-31' THEN
            CASE 
                WHEN DAY(nv.ngay_vao_lam) <= 15 THEN
                    (13 - MONTH(nv.ngay_vao_lam)) * 1.0
                ELSE
                    (12 - MONTH(nv.ngay_vao_lam)) * 1.0
            END
        ELSE 0.0
    END as so_ngay_phep_nen_co_2025
FROM nhanvien nv
WHERE nv.trang_thai_lam_viec = 'Đang làm'
ORDER BY nv.ngay_vao_lam;

-- Bước 2: Cập nhật hoặc tạo bản ghi ngày phép năm 2025
-- Chỉ cập nhật cho những nhân viên chưa có bản ghi hoặc bản ghi = 0
INSERT INTO ngay_phep_nam (nhan_vien_id, nam, tong_ngay_phep, ngay_phep_da_dung, ngay_phep_con_lai, ngay_phep_nam_truoc, da_cong_phep_dau_nam)
SELECT 
    nv.id as nhan_vien_id,
    2025 as nam,
    -- Tính số ngày phép theo logic cũ
    CASE
        -- Nếu vào làm trước 1/1/2024 (đã làm > 12 tháng vào đầu 2025)
        WHEN nv.ngay_vao_lam < '2024-01-01' THEN 12.0
        -- Nếu vào làm từ 1/1/2024 đến 31/12/2024
        WHEN nv.ngay_vao_lam >= '2024-01-01' AND nv.ngay_vao_lam <= '2024-12-31' THEN
            LEAST(12.0, 
                CASE 
                    WHEN DAY(nv.ngay_vao_lam) <= 15 THEN
                        TIMESTAMPDIFF(MONTH, nv.ngay_vao_lam, '2025-12-31') + 1
                    ELSE
                        TIMESTAMPDIFF(MONTH, nv.ngay_vao_lam, '2025-12-31')
                END
            ) * 1.0
        -- Nếu vào làm năm 2025
        WHEN nv.ngay_vao_lam >= '2025-01-01' AND nv.ngay_vao_lam <= '2025-12-31' THEN
            CASE 
                WHEN DAY(nv.ngay_vao_lam) <= 15 THEN
                    (13 - MONTH(nv.ngay_vao_lam)) * 1.0
                ELSE
                    (12 - MONTH(nv.ngay_vao_lam)) * 1.0
            END
        ELSE 0.0
    END as tong_ngay_phep,
    -- Lấy số ngày đã dùng từ bảng hiện tại (nếu có)
    COALESCE((SELECT ngay_phep_da_dung FROM ngay_phep_nam WHERE nhan_vien_id = nv.id AND nam = 2025), 0.0) as ngay_phep_da_dung,
    -- Tính ngày còn lại
    CASE
        WHEN nv.ngay_vao_lam < '2024-01-01' THEN 12.0
        WHEN nv.ngay_vao_lam >= '2024-01-01' AND nv.ngay_vao_lam <= '2024-12-31' THEN
            LEAST(12.0, 
                CASE 
                    WHEN DAY(nv.ngay_vao_lam) <= 15 THEN
                        TIMESTAMPDIFF(MONTH, nv.ngay_vao_lam, '2025-12-31') + 1
                    ELSE
                        TIMESTAMPDIFF(MONTH, nv.ngay_vao_lam, '2025-12-31')
                END
            ) * 1.0
        WHEN nv.ngay_vao_lam >= '2025-01-01' AND nv.ngay_vao_lam <= '2025-12-31' THEN
            CASE 
                WHEN DAY(nv.ngay_vao_lam) <= 15 THEN
                    (13 - MONTH(nv.ngay_vao_lam)) * 1.0
                ELSE
                    (12 - MONTH(nv.ngay_vao_lam)) * 1.0
            END
        ELSE 0.0
    END - COALESCE((SELECT ngay_phep_da_dung FROM ngay_phep_nam WHERE nhan_vien_id = nv.id AND nam = 2025), 0.0) as ngay_phep_con_lai,
    0.0 as ngay_phep_nam_truoc, -- Chưa có phép năm trước vì mới 2025
    CASE 
        WHEN nv.ngay_vao_lam < '2024-01-01' THEN 1 -- Đã đủ 12 tháng, đánh dấu đã cộng đầu năm
        ELSE 0
    END as da_cong_phep_dau_nam
FROM nhanvien nv
WHERE nv.trang_thai_lam_viec = 'Đang làm'
ON DUPLICATE KEY UPDATE
    tong_ngay_phep = VALUES(tong_ngay_phep),
    ngay_phep_con_lai = VALUES(tong_ngay_phep) - ngay_phep_da_dung,
    da_cong_phep_dau_nam = VALUES(da_cong_phep_dau_nam);

-- Bước 3: Kiểm tra kết quả sau khi cập nhật
SELECT 
    nv.id,
    nv.ho_ten,
    nv.ngay_vao_lam,
    np.tong_ngay_phep,
    np.ngay_phep_da_dung,
    np.ngay_phep_con_lai,
    np.da_cong_phep_dau_nam,
    TIMESTAMPDIFF(MONTH, nv.ngay_vao_lam, '2025-12-31') as thang_lam_viec
FROM ngay_phep_nam np
JOIN nhanvien nv ON np.nhan_vien_id = nv.id
WHERE np.nam = 2025
ORDER BY nv.ngay_vao_lam;

-- Bước 4: Tính tổng số ngày phép đã cấp
SELECT 
    COUNT(*) as tong_nhan_vien,
    SUM(np.tong_ngay_phep) as tong_ngay_phep_da_cap,
    AVG(np.tong_ngay_phep) as trung_binh_ngay_phep,
    SUM(np.ngay_phep_da_dung) as tong_da_dung,
    SUM(np.ngay_phep_con_lai) as tong_con_lai
FROM ngay_phep_nam np
WHERE np.nam = 2025;

COMMIT;
