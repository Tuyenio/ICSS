-- Thêm cột trang_thai vào bảng cham_cong để hỗ trợ Work From Home (WFH)
-- Chạy script này trên database của bạn

ALTER TABLE `cham_cong` ADD COLUMN `trang_thai` VARCHAR(50) DEFAULT 'Bình thường' AFTER `check_out`;
DESCRIBE cham_cong;
-- Nếu muốn, bạn có thể set giá trị mặc định cho những record cũ
-- UPDATE cham_cong SET trang_thai = 'Bình thường' WHERE trang_thai IS NULL;

-- Xem cấu trúc bảng để kiểm tra
