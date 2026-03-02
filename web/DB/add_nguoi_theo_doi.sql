-- ============================================================
-- Migration: Thêm bảng người theo dõi cho công việc
-- ============================================================

CREATE TABLE IF NOT EXISTS `cong_viec_nguoi_theo_doi` (
  `id` int NOT NULL AUTO_INCREMENT,
  `cong_viec_id` int NOT NULL,
  `nhan_vien_id` int NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_cv_nv_theo_doi` (`cong_viec_id`, `nhan_vien_id`),
  CONSTRAINT `fk_ntd_cv` FOREIGN KEY (`cong_viec_id`) REFERENCES `cong_viec` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_ntd_nv` FOREIGN KEY (`nhan_vien_id`) REFERENCES `nhanvien` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Danh sách người theo dõi cho từng công việc';
