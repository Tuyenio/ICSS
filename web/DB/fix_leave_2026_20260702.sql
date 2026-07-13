-- ================================================================
-- Migration: Sửa lỗi tính ngày phép năm (2026-07-02)
-- ----------------------------------------------------------------
-- Bối cảnh các lỗi đã phát hiện & khắc phục:
--   1. Cộng phép hàng tháng bị TRÙNG do race condition
--      (congPhepTheoThang: check count==0 rồi INSERT, 2 request đồng
--       thời cùng chèn). Đã sửa code -> INSERT IGNORE + chỉ cộng
--       aggregate khi INSERT thành công. DB cần UNIQUE KEY bên dưới.
--   2. Khoản "anniversary" (bù đủ 12 ngày khi tròn 12 tháng) không
--      chạy được vì cột loai_cong là ENUM KHÔNG có giá trị 'anniversary'
--      -> INSERT bị lỗi/truncate dưới strict mode. Bổ sung ENUM bên dưới.
--   3. Anniversary chỉ chạy khi truy cập ĐÚNG ngày kỷ niệm & chỉ ghi
--      ledger (không cập nhật bảng hiển thị). Đã sửa trong code
--      (date-based + cập nhật ngay_phep_nam + da_cong_phep_dau_nam=1).
--
-- File này chỉ chứa thay đổi SCHEMA (DDL) cần cho lần deploy mới.
-- Việc làm sạch dữ liệu cũ (dedup + recompute) đã thực hiện riêng.
-- ================================================================

-- (1) Bổ sung 'anniversary' vào ENUM loai_cong
ALTER TABLE lich_su_cong_phep
  MODIFY COLUMN loai_cong ENUM('dau_nam','hang_thang','xoa_phep_nam_cu','anniversary') NOT NULL;

-- (2) Chặn cộng phép trùng: mỗi nhân viên / năm / tháng / loại chỉ 1 dòng.
--     LƯU Ý: phải xóa các dòng trùng hiện có TRƯỚC khi thêm khóa này:
--     DELETE t1 FROM lich_su_cong_phep t1 JOIN lich_su_cong_phep t2
--       ON t1.nhan_vien_id=t2.nhan_vien_id AND t1.nam=t2.nam
--       AND t1.thang<=>t2.thang AND t1.loai_cong=t2.loai_cong AND t1.id>t2.id;
ALTER TABLE lich_su_cong_phep
  ADD UNIQUE KEY uk_lscp_nv_nam_thang_loai (nhan_vien_id, nam, thang, loai_cong);
