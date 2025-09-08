-- MySQL dump 10.13  Distrib 8.4.6, for Linux (x86_64)
--
-- Host: localhost    Database: qlns
-- ------------------------------------------------------
-- Server version	8.4.6

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Current Database: `qlns`
--

/*!40000 DROP DATABASE IF EXISTS `qlns`*/;

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `qlns` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;

USE `qlns`;

--
-- Table structure for table `cau_hinh_he_thong`
--

DROP TABLE IF EXISTS `cau_hinh_he_thong`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cau_hinh_he_thong` (
  `id` int NOT NULL AUTO_INCREMENT,
  `ten_cau_hinh` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `gia_tri` text COLLATE utf8mb4_unicode_ci,
  `mo_ta` text COLLATE utf8mb4_unicode_ci,
  `ngay_tao` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cau_hinh_he_thong`
--

LOCK TABLES `cau_hinh_he_thong` WRITE;
/*!40000 ALTER TABLE `cau_hinh_he_thong` DISABLE KEYS */;
INSERT INTO `cau_hinh_he_thong` VALUES (1,'company_name','CÔNG TY TNHH ICSS','Tên công ty','2025-09-03 03:26:58'),(2,'working_hours_start','08:45','Giờ bắt đầu làm việc','2025-09-03 03:26:58'),(3,'working_hours_end','17:30','Giờ kết thúc làm việc','2025-09-03 03:26:58'),(4,'annual_leave_days','12','Số ngày phép năm','2025-09-03 03:26:58');
/*!40000 ALTER TABLE `cau_hinh_he_thong` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cham_cong`
--

DROP TABLE IF EXISTS `cham_cong`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cham_cong` (
  `id` int NOT NULL AUTO_INCREMENT,
  `nhan_vien_id` int DEFAULT NULL,
  `ngay` date DEFAULT NULL,
  `check_in` time DEFAULT NULL,
  `check_out` time DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `nhan_vien_id` (`nhan_vien_id`,`ngay`),
  CONSTRAINT `cham_cong_ibfk_1` FOREIGN KEY (`nhan_vien_id`) REFERENCES `nhanvien` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=423 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cham_cong`
--

LOCK TABLES `cham_cong` WRITE;
/*!40000 ALTER TABLE `cham_cong` DISABLE KEYS */;
INSERT INTO `cham_cong` VALUES (419,9,'2025-09-04','04:42:51','04:46:37'),(420,8,'2025-09-04','06:31:43',NULL),(421,14,'2025-09-04','07:35:17',NULL),(422,2,'2025-09-04','08:24:12','08:24:40');
/*!40000 ALTER TABLE `cham_cong` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cong_viec`
--

DROP TABLE IF EXISTS `cong_viec`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cong_viec` (
  `id` int NOT NULL AUTO_INCREMENT,
  `ten_cong_viec` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `mo_ta` text COLLATE utf8mb4_unicode_ci,
  `han_hoan_thanh` date DEFAULT NULL,
  `muc_do_uu_tien` enum('Thấp','Trung bình','Cao') COLLATE utf8mb4_unicode_ci DEFAULT 'Trung bình',
  `nguoi_giao_id` int DEFAULT NULL,
  `nguoi_nhan_id` int DEFAULT NULL,
  `phong_ban_id` int DEFAULT NULL,
  `trang_thai` enum('Chưa bắt đầu','Đang thực hiện','Đã hoàn thành','Trễ hạn') COLLATE utf8mb4_unicode_ci DEFAULT 'Chưa bắt đầu',
  `tai_lieu_cv` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `ngay_tao` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `ngay_bat_dau` date DEFAULT NULL,
  `ngay_hoan_thanh` date DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `nguoi_giao_id` (`nguoi_giao_id`),
  KEY `nguoi_nhan_id` (`nguoi_nhan_id`),
  KEY `phong_ban_id` (`phong_ban_id`),
  CONSTRAINT `cong_viec_ibfk_1` FOREIGN KEY (`nguoi_giao_id`) REFERENCES `nhanvien` (`id`) ON DELETE CASCADE,
  CONSTRAINT `cong_viec_ibfk_2` FOREIGN KEY (`nguoi_nhan_id`) REFERENCES `nhanvien` (`id`) ON DELETE CASCADE,
  CONSTRAINT `cong_viec_ibfk_3` FOREIGN KEY (`phong_ban_id`) REFERENCES `phong_ban` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=48 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cong_viec`
--

LOCK TABLES `cong_viec` WRITE;
/*!40000 ALTER TABLE `cong_viec` DISABLE KEYS */;
INSERT INTO `cong_viec` VALUES (41,'Test việc cho Dũng','123','2025-09-09','Cao',1,3,6,'Đã hoàn thành','Chưa có','2025-09-04 04:34:38','2025-09-04','2025-09-04'),(42,'Test việc cho Quỳnh','123','2025-09-09','Thấp',1,7,1,'Đang thực hiện','Chưa có','2025-09-04 04:35:22','2025-09-04',NULL),(43,'Test việc cho Chiến','123','2025-09-09','Thấp',1,5,6,'Đang thực hiện','Chưa có','2025-09-04 04:35:47','2025-09-04',NULL),(44,'Test việc cho Dương','123','2025-09-09','Thấp',1,10,8,'Chưa bắt đầu','Chưa có','2025-09-04 04:36:28',NULL,NULL),(45,'Test việc cho Nam','123','2025-09-09','Thấp',1,8,6,'Chưa bắt đầu','Chưa có','2025-09-04 04:37:28',NULL,NULL),(46,'Test việc cho Vinh','123','2025-09-09','Trung bình',1,9,7,'Chưa bắt đầu','Chưa có','2025-09-04 04:37:57',NULL,NULL),(47,'Test việc cho Nam','132','2025-09-09','Trung bình',1,8,6,'Đã hoàn thành','Chưa có','2025-09-04 04:48:54','2025-09-04','2025-09-04');
/*!40000 ALTER TABLE `cong_viec` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cong_viec_danh_gia`
--

DROP TABLE IF EXISTS `cong_viec_danh_gia`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cong_viec_danh_gia` (
  `id` int NOT NULL AUTO_INCREMENT,
  `cong_viec_id` int DEFAULT NULL,
  `nguoi_danh_gia_id` int DEFAULT NULL,
  `nhan_xet` text COLLATE utf8mb4_unicode_ci,
  `thoi_gian` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `cong_viec_id` (`cong_viec_id`),
  KEY `nguoi_danh_gia_id` (`nguoi_danh_gia_id`),
  CONSTRAINT `cong_viec_danh_gia_ibfk_1` FOREIGN KEY (`cong_viec_id`) REFERENCES `cong_viec` (`id`) ON DELETE CASCADE,
  CONSTRAINT `cong_viec_danh_gia_ibfk_2` FOREIGN KEY (`nguoi_danh_gia_id`) REFERENCES `nhanvien` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cong_viec_danh_gia`
--

LOCK TABLES `cong_viec_danh_gia` WRITE;
/*!40000 ALTER TABLE `cong_viec_danh_gia` DISABLE KEYS */;
/*!40000 ALTER TABLE `cong_viec_danh_gia` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cong_viec_lich_su`
--

DROP TABLE IF EXISTS `cong_viec_lich_su`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cong_viec_lich_su` (
  `id` int NOT NULL AUTO_INCREMENT,
  `cong_viec_id` int DEFAULT NULL,
  `nguoi_thay_doi_id` int DEFAULT NULL,
  `mo_ta_thay_doi` text COLLATE utf8mb4_unicode_ci,
  `thoi_gian` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `cong_viec_id` (`cong_viec_id`),
  KEY `nguoi_thay_doi_id` (`nguoi_thay_doi_id`),
  CONSTRAINT `cong_viec_lich_su_ibfk_1` FOREIGN KEY (`cong_viec_id`) REFERENCES `cong_viec` (`id`) ON DELETE CASCADE,
  CONSTRAINT `cong_viec_lich_su_ibfk_2` FOREIGN KEY (`nguoi_thay_doi_id`) REFERENCES `nhanvien` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cong_viec_lich_su`
--

LOCK TABLES `cong_viec_lich_su` WRITE;
/*!40000 ALTER TABLE `cong_viec_lich_su` DISABLE KEYS */;
/*!40000 ALTER TABLE `cong_viec_lich_su` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cong_viec_quy_trinh`
--

DROP TABLE IF EXISTS `cong_viec_quy_trinh`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cong_viec_quy_trinh` (
  `id` int NOT NULL AUTO_INCREMENT,
  `cong_viec_id` int DEFAULT NULL,
  `ten_buoc` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `mo_ta` text COLLATE utf8mb4_unicode_ci,
  `trang_thai` enum('Chưa bắt đầu','Đang thực hiện','Đã hoàn thành') COLLATE utf8mb4_unicode_ci DEFAULT 'Chưa bắt đầu',
  `ngay_bat_dau` date DEFAULT NULL,
  `ngay_ket_thuc` date DEFAULT NULL,
  `ngay_tao` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `cong_viec_id` (`cong_viec_id`),
  CONSTRAINT `cong_viec_quy_trinh_ibfk_1` FOREIGN KEY (`cong_viec_id`) REFERENCES `cong_viec` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=121 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cong_viec_quy_trinh`
--

LOCK TABLES `cong_viec_quy_trinh` WRITE;
/*!40000 ALTER TABLE `cong_viec_quy_trinh` DISABLE KEYS */;
INSERT INTO `cong_viec_quy_trinh` VALUES (117,41,'Bước 2: Thực hiện','11','Đã hoàn thành','2025-09-07','2025-09-21','2025-09-04 04:43:36'),(118,42,'Bước 3: Kiểm thử/Nghiệm thu','123','Đang thực hiện','2025-09-13','2025-09-30','2025-09-04 04:44:52'),(119,47,'Bước 2: Thực hiện','131','Đã hoàn thành','2025-09-12','2025-09-14','2025-09-04 04:49:17'),(120,43,'Bước 2: Thực hiện','13123','Đang thực hiện','2025-09-05','2025-09-08','2025-09-04 04:50:11');
/*!40000 ALTER TABLE `cong_viec_quy_trinh` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cong_viec_tien_do`
--

DROP TABLE IF EXISTS `cong_viec_tien_do`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cong_viec_tien_do` (
  `id` int NOT NULL AUTO_INCREMENT,
  `cong_viec_id` int DEFAULT NULL,
  `nguoi_cap_nhat_id` int DEFAULT NULL,
  `phan_tram` int DEFAULT NULL,
  `ghi_chu` text COLLATE utf8mb4_unicode_ci,
  `file_dinh_kem` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `thoi_gian_cap_nhat` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `cong_viec_id` (`cong_viec_id`),
  KEY `nguoi_cap_nhat_id` (`nguoi_cap_nhat_id`),
  CONSTRAINT `cong_viec_tien_do_ibfk_1` FOREIGN KEY (`cong_viec_id`) REFERENCES `cong_viec` (`id`) ON DELETE CASCADE,
  CONSTRAINT `cong_viec_tien_do_ibfk_2` FOREIGN KEY (`nguoi_cap_nhat_id`) REFERENCES `nhanvien` (`id`) ON DELETE CASCADE,
  CONSTRAINT `cong_viec_tien_do_chk_1` CHECK ((`phan_tram` between 0 and 100))
) ENGINE=InnoDB AUTO_INCREMENT=27 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cong_viec_tien_do`
--

LOCK TABLES `cong_viec_tien_do` WRITE;
/*!40000 ALTER TABLE `cong_viec_tien_do` DISABLE KEYS */;
INSERT INTO `cong_viec_tien_do` VALUES (20,46,NULL,0,NULL,NULL,'2025-09-05 02:21:52'),(21,41,NULL,0,NULL,NULL,'2025-09-05 02:19:19'),(22,42,NULL,0,NULL,NULL,'2025-09-04 04:45:05'),(23,45,NULL,0,NULL,NULL,'2025-09-04 04:51:11'),(24,43,NULL,0,NULL,NULL,'2025-09-04 07:15:37'),(25,47,NULL,100,NULL,NULL,'2025-09-04 06:32:39'),(26,44,NULL,0,NULL,NULL,'2025-09-05 02:19:11');
/*!40000 ALTER TABLE `cong_viec_tien_do` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `file_dinh_kem`
--

DROP TABLE IF EXISTS `file_dinh_kem`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `file_dinh_kem` (
  `id` int NOT NULL AUTO_INCREMENT,
  `cong_viec_id` int DEFAULT NULL,
  `tien_do_id` int DEFAULT NULL,
  `duong_dan_file` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `mo_ta` text COLLATE utf8mb4_unicode_ci,
  `thoi_gian_upload` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `cong_viec_id` (`cong_viec_id`),
  KEY `tien_do_id` (`tien_do_id`),
  CONSTRAINT `file_dinh_kem_ibfk_1` FOREIGN KEY (`cong_viec_id`) REFERENCES `cong_viec` (`id`) ON DELETE CASCADE,
  CONSTRAINT `file_dinh_kem_ibfk_2` FOREIGN KEY (`tien_do_id`) REFERENCES `cong_viec_tien_do` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `file_dinh_kem`
--

LOCK TABLES `file_dinh_kem` WRITE;
/*!40000 ALTER TABLE `file_dinh_kem` DISABLE KEYS */;
/*!40000 ALTER TABLE `file_dinh_kem` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `luong`
--

DROP TABLE IF EXISTS `luong`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `luong` (
  `id` int NOT NULL AUTO_INCREMENT,
  `nhan_vien_id` int DEFAULT NULL,
  `thang` int DEFAULT NULL,
  `nam` int DEFAULT NULL,
  `luong_co_ban` decimal(12,2) DEFAULT NULL,
  `phu_cap` decimal(12,2) DEFAULT '0.00',
  `thuong` decimal(12,2) DEFAULT '0.00',
  `phat` decimal(12,2) DEFAULT '0.00',
  `bao_hiem` decimal(12,2) DEFAULT '0.00',
  `thue` decimal(12,2) DEFAULT '0.00',
  `luong_thuc_te` decimal(12,2) DEFAULT NULL,
  `ghi_chu` text COLLATE utf8mb4_unicode_ci,
  `trang_thai` enum('Chưa trả','Đã trả') COLLATE utf8mb4_unicode_ci DEFAULT 'Chưa trả',
  `ngay_tra_luong` date DEFAULT NULL,
  `ngay_tao` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `nhan_vien_id` (`nhan_vien_id`),
  CONSTRAINT `luong_ibfk_1` FOREIGN KEY (`nhan_vien_id`) REFERENCES `nhanvien` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `luong`
--

LOCK TABLES `luong` WRITE;
/*!40000 ALTER TABLE `luong` DISABLE KEYS */;
/*!40000 ALTER TABLE `luong` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `luong_cau_hinh`
--

DROP TABLE IF EXISTS `luong_cau_hinh`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `luong_cau_hinh` (
  `id` int NOT NULL AUTO_INCREMENT,
  `ten_cau_hinh` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `gia_tri` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `mo_ta` text COLLATE utf8mb4_unicode_ci,
  `ngay_tao` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `luong_cau_hinh`
--

LOCK TABLES `luong_cau_hinh` WRITE;
/*!40000 ALTER TABLE `luong_cau_hinh` DISABLE KEYS */;
/*!40000 ALTER TABLE `luong_cau_hinh` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `luu_kpi`
--

DROP TABLE IF EXISTS `luu_kpi`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `luu_kpi` (
  `id` int NOT NULL AUTO_INCREMENT,
  `nhan_vien_id` int DEFAULT NULL,
  `thang` int DEFAULT NULL,
  `nam` int DEFAULT NULL,
  `chi_tieu` text COLLATE utf8mb4_unicode_ci,
  `ket_qua` text COLLATE utf8mb4_unicode_ci,
  `diem_kpi` float DEFAULT NULL,
  `ghi_chu` text COLLATE utf8mb4_unicode_ci,
  `ngay_tao` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `nhan_vien_id` (`nhan_vien_id`),
  CONSTRAINT `luu_kpi_ibfk_1` FOREIGN KEY (`nhan_vien_id`) REFERENCES `nhanvien` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `luu_kpi`
--

LOCK TABLES `luu_kpi` WRITE;
/*!40000 ALTER TABLE `luu_kpi` DISABLE KEYS */;
/*!40000 ALTER TABLE `luu_kpi` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `nhan_su_lich_su`
--

DROP TABLE IF EXISTS `nhan_su_lich_su`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `nhan_su_lich_su` (
  `id` int NOT NULL AUTO_INCREMENT,
  `nhan_vien_id` int DEFAULT NULL,
  `loai_thay_doi` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `gia_tri_cu` text COLLATE utf8mb4_unicode_ci,
  `gia_tri_moi` text COLLATE utf8mb4_unicode_ci,
  `nguoi_thay_doi_id` int DEFAULT NULL,
  `ghi_chu` text COLLATE utf8mb4_unicode_ci,
  `thoi_gian` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `nhan_vien_id` (`nhan_vien_id`),
  KEY `nguoi_thay_doi_id` (`nguoi_thay_doi_id`),
  CONSTRAINT `nhan_su_lich_su_ibfk_1` FOREIGN KEY (`nhan_vien_id`) REFERENCES `nhanvien` (`id`) ON DELETE CASCADE,
  CONSTRAINT `nhan_su_lich_su_ibfk_2` FOREIGN KEY (`nguoi_thay_doi_id`) REFERENCES `nhanvien` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `nhan_su_lich_su`
--

LOCK TABLES `nhan_su_lich_su` WRITE;
/*!40000 ALTER TABLE `nhan_su_lich_su` DISABLE KEYS */;
/*!40000 ALTER TABLE `nhan_su_lich_su` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `nhanvien`
--

DROP TABLE IF EXISTS `nhanvien`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `nhanvien` (
  `id` int NOT NULL AUTO_INCREMENT,
  `ho_ten` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `mat_khau` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `so_dien_thoai` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `gioi_tinh` enum('Nam','Nữ','Khác') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `ngay_sinh` date DEFAULT NULL,
  `phong_ban_id` int DEFAULT NULL,
  `chuc_vu` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `luong_co_ban` decimal(12,2) DEFAULT '0.00',
  `trang_thai_lam_viec` enum('Đang làm','Tạm nghỉ','Nghỉ việc') COLLATE utf8mb4_unicode_ci DEFAULT 'Đang làm',
  `vai_tro` enum('Admin','Quản lý','Nhân viên') COLLATE utf8mb4_unicode_ci DEFAULT 'Nhân viên',
  `ngay_vao_lam` date DEFAULT NULL,
  `avatar_url` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `ngay_tao` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`),
  KEY `phong_ban_id` (`phong_ban_id`),
  CONSTRAINT `nhanvien_ibfk_1` FOREIGN KEY (`phong_ban_id`) REFERENCES `phong_ban` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `nhanvien`
--

LOCK TABLES `nhanvien` WRITE;
/*!40000 ALTER TABLE `nhanvien` DISABLE KEYS */;
INSERT INTO `nhanvien` VALUES (1,'Phạm Minh Thắng','minhthang@gmail.com','11112222','0834035090','Nam','2003-11-23',6,'Nhân viên',20000000.00,'Đang làm','Nhân viên','2025-09-03','https://i.postimg.cc/x1mhwnFR/IMG-8032.jpg','2025-09-03 03:26:57'),(2,'Nguyễn Ngọc Tuyền','tt98tuyen@gmail.com','tuyendz321','0399045920','Nam','2003-03-11',6,'Nhân viên',0.00,'Đang làm','Nhân viên','2025-07-20','https://i.postimg.cc/q7nxs24X/z6976269052999-e22e9cb5e367830aede3a369c5f977b6.jpg','2025-09-04 03:59:59'),(3,'Nguyễn Tấn Dũng','jindonguyen2015@gmail.com','12345678','0943924816','Nam','2002-08-24',6,'Nhân viên',0.00,'Đang làm','Nhân viên','2025-05-05','https://i.postimg.cc/CLrmzggp/z6913446856097-ac16f34c6ba3cb76c40d753bb051e0a6-Nguyen-Dung.jpg','2025-09-04 04:03:30'),(4,'Võ Trung Âu','dr.votrungau@gmail.com','12345678','0931487231','Nam','1989-03-03',1,'Tổng Giám đốc',0.00,'Đang làm','Admin','2024-08-01','https://i.postimg.cc/QCX0WNCh/IMG-9548-Vo-Au.jpg','2025-09-04 04:03:44'),(5,'Trịnh Văn Chiến','trinhchienalone@gmail.com','Chien123@','0819881399','Nam','2004-09-15',6,'Thực tập sinh',0.00,'Đang làm','Nhân viên','2025-07-01','https://i.postimg.cc/660HxZb3/z3773863902306-3dcbc5c61ac55cf92ead58604f04d7c2-V-n-Chi-n-Tr-nh-Tr-Chi-n.jpg','2025-09-04 04:04:34'),(6,'Vũ Tam Hanh','vutamhanh@gmail.com','12345678','0900000001','Nam','1974-09-21',6,'Trưởng phòng',0.00,'Đang làm','Quản lý','2025-09-03','https://i.postimg.cc/x1mhwnFR/IMG-8032.jpg','2025-09-04 04:05:00'),(7,'Nguyễn Thị Diễm Quỳnh','quynhdiem@icss.com.vn','12345678','0972363821','Nữ','2001-11-15',1,'Nhân viên',0.00,'Đang làm','Nhân viên','2025-06-16','https://i.postimg.cc/x1mhwnFR/IMG-8032.jpg','2025-09-04 04:07:07'),(8,'Trần Đình Nam','trandinhnamuet@gmail.com','12345678','0962989431','Nam','2001-09-01',6,'Nhân viên',0.00,'Đang làm','Nhân viên','2025-09-03','https://i.postimg.cc/76rBwnyC/Anhdaidien-Tr-n-nh-Nam.png','2025-09-04 04:08:41'),(9,'Phạm Thị Lê Vinh','phamvinh2004hb@gmail.com','Levinh123@','0356249734','Nữ','2004-07-28',7,'Thực tập sinh',0.00,'Đang làm','Nhân viên','2025-07-01','https://i.postimg.cc/vZjqSdqt/nh-c-y-Vinh-Ph-m.jpg','2025-09-04 04:10:16'),(10,'Nguyễn Đức Dương','linhduonghb1992@gmail.com','12345678','0977230903','Nam','2003-09-23',8,'Nhân viên',0.00,'Đang làm','Nhân viên','2025-08-02','https://i.postimg.cc/VNC7xH2Q/509756574-8617132495078515-4794128757965032491-n-Linh-Duong-Nguyen.jpg','2025-09-04 04:10:23'),(11,'Đặng Lê Trung','trungics@gmail.com','12345678','0900000001','Nam','2025-09-05',7,'Giám đốc',0.00,'Đang làm','Quản lý','2025-09-04','https://i.postimg.cc/x1mhwnFR/IMG-8032.jpg','2025-09-04 04:28:13'),(12,'Vũ Thị Hải Yến','yenics@gmail.com','12345678','0900000001','Nữ','2025-09-04',1,'Giám đốc',0.00,'Đang làm','Admin','2025-09-04','https://i.postimg.cc/x1mhwnFR/IMG-8032.jpg','2025-09-04 04:30:16'),(13,'Đặng Như Quỳnh','dangnhuquynh108@gmail.com','12345678','0352881187','Nữ','2004-05-28',7,'Thực tập sinh',0.00,'Đang làm','Nhân viên','2025-07-01','https://i.postimg.cc/XqQxKMBF/z6611166684599-bef42c73e3c6652f77e87eb8a82c5bc6-ng-Nh-Qu-nh.jpg','2025-09-04 04:42:04'),(14,'Nguyễn Ngọc Phúc','mancity.phuc2004@gmail.com','12345678','0961522506','Nam','2025-08-20',6,'Thực tập sinh',0.00,'Đang làm','Nhân viên','2025-06-28','https://i.postimg.cc/x1mhwnFR/IMG-8032.jpg','2025-09-04 06:29:30'),(15,'Đặng Thu Hồng','dangthuhong1101@gmail.com','12345678','0363631856','Nữ','2004-12-02',7,'Thực tập sinh',0.00,'Đang làm','Nhân viên','2025-07-01','https://i.postimg.cc/x1mhwnFR/IMG-8032.jpg','2025-09-04 06:32:20'),(16,'Phan Tuấn Linh','linhphan227366@gmail.com','12345678','0911162004','Nam','2004-06-11',6,'Nhân viên',0.00,'Đang làm','Nhân viên','2025-03-21','https://i.postimg.cc/xTSQT8mh/IMG-1142-linh-phan.avif','2025-09-04 06:50:11'),(17,'Nguyễn Huy Hoàng','huyhoangnguyen20704@gmail.com','12345678   ','0395491415','Nam','2004-07-20',6,'Thực tập sinh',0.00,'Đang làm','Nhân viên','2025-07-02','https://i.postimg.cc/x1mhwnFR/IMG-8032.jpg','2025-09-04 07:02:17'),(18,'Admin','admin@gmail.com','12345678','Admin','Nam','2025-09-04',6,'Giám đốc',0.00,'Đang làm','Admin','2025-09-13','https://i.postimg.cc/x1mhwnFR/IMG-8032.jpg','2025-09-04 07:43:56');
/*!40000 ALTER TABLE `nhanvien` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `phan_quyen_chuc_nang`
--

DROP TABLE IF EXISTS `phan_quyen_chuc_nang`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `phan_quyen_chuc_nang` (
  `id` int NOT NULL AUTO_INCREMENT,
  `vai_tro` enum('Admin','Quản lý','Nhân viên','Trưởng nhóm','Nhân viên cấp cao') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `chuc_nang` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `co_quyen` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `phan_quyen_chuc_nang`
--

LOCK TABLES `phan_quyen_chuc_nang` WRITE;
/*!40000 ALTER TABLE `phan_quyen_chuc_nang` DISABLE KEYS */;
/*!40000 ALTER TABLE `phan_quyen_chuc_nang` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `phong_ban`
--

DROP TABLE IF EXISTS `phong_ban`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `phong_ban` (
  `id` int NOT NULL AUTO_INCREMENT,
  `ten_phong` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `truong_phong_id` int DEFAULT NULL,
  `ngay_tao` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `fk_truong_phong` (`truong_phong_id`),
  CONSTRAINT `fk_truong_phong` FOREIGN KEY (`truong_phong_id`) REFERENCES `nhanvien` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `phong_ban`
--

LOCK TABLES `phong_ban` WRITE;
/*!40000 ALTER TABLE `phong_ban` DISABLE KEYS */;
INSERT INTO `phong_ban` VALUES (1,'Phòng Nhân sự',NULL,'2025-09-03 03:26:57'),(6,'Phòng Kỹ thuật',6,'2025-09-04 04:19:49'),(7,'Phòng Marketing & Sales',NULL,'2025-09-04 04:20:02'),(8,'Phòng Tài chính & Pháp chế',NULL,'2025-09-04 04:20:52');
/*!40000 ALTER TABLE `phong_ban` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `thong_bao`
--

DROP TABLE IF EXISTS `thong_bao`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `thong_bao` (
  `id` int NOT NULL AUTO_INCREMENT,
  `tieu_de` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `noi_dung` text COLLATE utf8mb4_unicode_ci,
  `nguoi_nhan_id` int DEFAULT NULL,
  `loai_thong_bao` text COLLATE utf8mb4_unicode_ci,
  `da_doc` tinyint(1) DEFAULT '0',
  `ngay_doc` timestamp NULL DEFAULT NULL,
  `ngay_tao` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `nguoi_nhan_id` (`nguoi_nhan_id`),
  CONSTRAINT `thong_bao_ibfk_1` FOREIGN KEY (`nguoi_nhan_id`) REFERENCES `nhanvien` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=54 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `thong_bao`
--

LOCK TABLES `thong_bao` WRITE;
/*!40000 ALTER TABLE `thong_bao` DISABLE KEYS */;
INSERT INTO `thong_bao` VALUES (27,'Công việc mới','Bạn được giao công việc: Test việc cho Dũng. Hạn: 2025-09-10.',3,'Công việc mới',0,'2025-09-04 04:34:38','2025-09-04 04:34:38'),(28,'Công việc mới','Bạn được giao công việc: Test việc cho Quỳnh. Hạn: 2025-09-10.',7,'Công việc mới',0,'2025-09-04 04:35:22','2025-09-04 04:35:22'),(29,'Công việc mới','Bạn được giao công việc: Test việc cho Chiến. Hạn: 2025-09-10.',5,'Công việc mới',1,'2025-09-04 04:48:44','2025-09-04 04:35:47'),(30,'Công việc mới','Bạn được giao công việc: Test việc cho Dương. Hạn: 2025-09-09.',10,'Công việc mới',1,'2025-09-04 04:37:57','2025-09-04 04:36:28'),(31,'Cập nhật công việc','Công việc: Test việc cho Dũng vừa được cập nhật mới',3,'Cập nhật',0,'2025-09-04 04:36:37','2025-09-04 04:36:37'),(32,'Cập nhật công việc','Công việc: Test việc cho Quỳnh vừa được cập nhật mới',7,'Cập nhật',0,'2025-09-04 04:36:45','2025-09-04 04:36:45'),(33,'Cập nhật công việc','Công việc: Test việc cho Chiến vừa được cập nhật mới',5,'Cập nhật',1,'2025-09-04 04:48:43','2025-09-04 04:36:54'),(34,'Công việc mới','Bạn được giao công việc: Test việc cho Nam. Hạn: 2025-09-09.',8,'Công việc mới',1,'2025-09-04 04:47:43','2025-09-04 04:37:28'),(35,'Công việc mới','Bạn được giao công việc: Test việc cho Vinh. Hạn: 2025-09-09.',9,'Công việc mới',1,'2025-09-04 04:42:03','2025-09-04 04:37:57'),(36,'Nhân viên mới','Phòng Marketing & Sale: vừa thêm một nhân viên mới.',11,'Nhân viên mới',0,'2025-09-04 04:42:04','2025-09-04 04:42:04'),(37,'Thêm mới quy trình','Công việc: Test việc cho Dũng vừa được thêm quy trình mới',3,'Thêm mới',0,'2025-09-04 04:43:36','2025-09-04 04:43:36'),(38,'Cập nhật quy trình','Công việc: Test việc cho Dũng vừa được cập nhật quy trình mới',3,'Cập nhật',0,'2025-09-04 04:44:08','2025-09-04 04:44:08'),(39,'Cập nhật quy trình','Công việc: Test việc cho Dũng vừa được cập nhật quy trình mới',3,'Cập nhật',0,'2025-09-04 04:44:13','2025-09-04 04:44:13'),(40,'Thêm mới quy trình','Công việc: Test việc cho Quỳnh vừa được thêm quy trình mới',7,'Thêm mới',0,'2025-09-04 04:44:52','2025-09-04 04:44:52'),(41,'Cập nhật quy trình','Công việc: Test việc cho Quỳnh vừa được cập nhật quy trình mới',7,'Cập nhật',0,'2025-09-04 04:45:05','2025-09-04 04:45:05'),(42,'Cập nhật công việc','Công việc: Test việc cho Dũng vừa được cập nhật mới',3,'Cập nhật',0,'2025-09-04 04:45:19','2025-09-04 04:45:19'),(43,'Công việc mới','Bạn được giao công việc: Test việc cho Nam. Hạn: 2025-09-09.',8,'Công việc mới',1,'2025-09-04 06:32:33','2025-09-04 04:48:54'),(44,'Thêm mới quy trình','Công việc: Test việc cho Nam vừa được thêm quy trình mới',8,'Thêm mới',1,'2025-09-04 06:32:33','2025-09-04 04:49:17'),(45,'Cập nhật quy trình','Công việc: Test việc cho Nam vừa được cập nhật quy trình mới',8,'Cập nhật',1,'2025-09-04 06:32:33','2025-09-04 04:50:01'),(46,'Thêm mới quy trình','Công việc: Test việc cho Chiến vừa được thêm quy trình mới',5,'Thêm mới',0,'2025-09-04 04:50:11','2025-09-04 04:50:11'),(47,'Cập nhật quy trình','Công việc: Test việc cho Nam vừa được cập nhật quy trình mới',8,'Cập nhật',1,'2025-09-04 06:32:32','2025-09-04 04:50:12'),(48,'Cập nhật quy trình','Công việc: Test việc cho Chiến vừa được cập nhật quy trình mới',5,'Cập nhật',0,'2025-09-04 04:50:17','2025-09-04 04:50:17'),(49,'Cập nhật quy trình','Công việc: Test việc cho Nam vừa được cập nhật quy trình mới',8,'Cập nhật',1,'2025-09-04 06:32:31','2025-09-04 04:51:33'),(50,'Cập nhật quy trình','Công việc: Test việc cho Nam vừa được cập nhật quy trình mới',8,'Cập nhật',1,'2025-09-04 06:32:30','2025-09-04 05:15:46'),(51,'Cập nhật công việc','Công việc: Test việc cho Dũng vừa được cập nhật mới',3,'Cập nhật',0,'2025-09-04 06:36:37','2025-09-04 06:36:37'),(52,'Cập nhật quy trình','Công việc: Test việc cho Chiến vừa được cập nhật quy trình mới',5,'Cập nhật',0,'2025-09-04 06:47:35','2025-09-04 06:47:35'),(53,'Cập nhật quy trình','Công việc: Test việc cho Dũng vừa được cập nhật quy trình mới',3,'Cập nhật',0,'2025-09-04 06:57:20','2025-09-04 06:57:20');
/*!40000 ALTER TABLE `thong_bao` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping events for database 'qlns'
--

--
-- Dumping routines for database 'qlns'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-09-05  3:40:36
