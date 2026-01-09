-- Script cập nhật phân quyền xem tài liệu
-- Ngày: 2026-01-07

-- Thêm cột doi_tuong_xem cho bảng nhom_tai_lieu
ALTER TABLE `nhom_tai_lieu` 
ADD COLUMN `doi_tuong_xem` ENUM('Tất cả', 'Giám đốc và Trưởng phòng', 'Chỉ nhân viên') DEFAULT 'Tất cả' 
AFTER `thu_tu`;

-- Thêm cột doi_tuong_xem cho bảng tai_lieu
ALTER TABLE `tai_lieu` 
ADD COLUMN `doi_tuong_xem` ENUM('Tất cả', 'Giám đốc và Trưởng phòng', 'Chỉ nhân viên') DEFAULT 'Tất cả' 
AFTER `luot_tai`;

-- Thêm cột tai_lieu_link và tai_lieu_file cho bảng cong_viec_quy_trinh
ALTER TABLE `cong_viec_quy_trinh` 
ADD COLUMN `tai_lieu_link` VARCHAR(500) DEFAULT NULL COMMENT 'Link tài liệu' 
AFTER `ngay_tao`;

ALTER TABLE `cong_viec_quy_trinh` 
ADD COLUMN `tai_lieu_file` VARCHAR(500) DEFAULT NULL COMMENT 'File tài liệu đính kèm (nhiều file cách nhau bởi ;)' 
AFTER `tai_lieu_link`;

-- Cập nhật dữ liệu mẫu (tùy chọn)
-- UPDATE `nhom_tai_lieu` SET `doi_tuong_xem` = 'Giám đốc và Trưởng phòng' WHERE `id` IN (1, 3, 4, 6);
-- UPDATE `nhom_tai_lieu` SET `doi_tuong_xem` = 'Chỉ nhân viên' WHERE `id` IN (2, 5);

