-- Thêm bảng du_an (dự án)
CREATE TABLE `du_an` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `ten_du_an` VARCHAR(255) NOT NULL,
  `mo_ta` TEXT DEFAULT NULL,
  `ngay_bat_dau` DATE DEFAULT NULL,
  `ngay_ket_thuc` DATE DEFAULT NULL,
  `ngay_tao` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Thêm cột du_an_id vào bảng cong_viec
ALTER TABLE `cong_viec` ADD COLUMN `du_an_id` INT(11) DEFAULT NULL AFTER `id`;
ALTER TABLE `cong_viec` ADD CONSTRAINT `fk_cong_viec_du_an` FOREIGN KEY (`du_an_id`) REFERENCES `du_an`(`id`) ON DELETE SET NULL ON UPDATE CASCADE;

