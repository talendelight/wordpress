/*M!999999\- enable the sandbox mode */ 
-- MariaDB dump 10.19-11.8.3-MariaDB, for debian-linux-gnu (x86_64)
--
-- Host: localhost    Database: wordpress
-- ------------------------------------------------------
-- Server version	11.8.3-MariaDB-ubu2404

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*M!100616 SET @OLD_NOTE_VERBOSITY=@@NOTE_VERBOSITY, NOTE_VERBOSITY=0 */;

--
-- Table structure for table `wp_frmt_form_entry`
--

DROP TABLE IF EXISTS `wp_frmt_form_entry`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `wp_frmt_form_entry` (
  `entry_id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `entry_type` varchar(191) NOT NULL,
  `draft_id` varchar(12) DEFAULT NULL,
  `form_id` bigint(20) unsigned NOT NULL,
  `is_spam` tinyint(1) NOT NULL DEFAULT 0,
  `date_created` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `status` enum('active','spam','draft','abandoned') NOT NULL DEFAULT 'active',
  PRIMARY KEY (`entry_id`),
  KEY `entry_is_spam` (`is_spam`),
  KEY `entry_status` (`status`),
  KEY `entry_form_status` (`form_id`,`status`),
  KEY `entry_type` (`entry_type`),
  KEY `entry_form_id` (`form_id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `wp_frmt_form_entry`
--

LOCK TABLES `wp_frmt_form_entry` WRITE;
/*!40000 ALTER TABLE `wp_frmt_form_entry` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `wp_frmt_form_entry` VALUES
(1,'custom-forms',NULL,80,0,'2026-01-18 19:57:58','active'),
(2,'custom-forms',NULL,80,0,'2026-01-20 21:45:34','active'),
(3,'custom-forms',NULL,80,0,'2026-01-20 22:12:46','active'),
(4,'custom-forms',NULL,80,0,'2026-01-21 08:55:25','active'),
(5,'custom-forms',NULL,80,0,'2026-01-21 09:08:52','active'),
(6,'custom-forms',NULL,80,0,'2026-01-21 09:13:56','active'),
(7,'custom-forms',NULL,80,0,'2026-01-21 20:05:37','active'),
(8,'custom-forms',NULL,80,0,'2026-01-26 22:50:53','active');
/*!40000 ALTER TABLE `wp_frmt_form_entry` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `wp_frmt_form_entry_meta`
--

DROP TABLE IF EXISTS `wp_frmt_form_entry_meta`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `wp_frmt_form_entry_meta` (
  `meta_id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `entry_id` bigint(20) unsigned NOT NULL,
  `meta_key` varchar(191) DEFAULT NULL,
  `meta_value` longtext DEFAULT NULL,
  `date_created` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `date_updated` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  PRIMARY KEY (`meta_id`),
  KEY `meta_key` (`meta_key`),
  KEY `meta_entry_id` (`entry_id`),
  KEY `meta_key_object` (`entry_id`,`meta_key`)
) ENGINE=InnoDB AUTO_INCREMENT=103 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `wp_frmt_form_entry_meta`
--

LOCK TABLES `wp_frmt_form_entry_meta` WRITE;
/*!40000 ALTER TABLE `wp_frmt_form_entry_meta` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `wp_frmt_form_entry_meta` VALUES
(1,1,'name-1','abc','2026-01-18 19:57:58','0000-00-00 00:00:00'),
(2,1,'name-2','abc','2026-01-18 19:57:58','0000-00-00 00:00:00'),
(3,1,'name-3','abc','2026-01-18 19:57:58','0000-00-00 00:00:00'),
(4,1,'email-1','abc@abc.com','2026-01-18 19:57:58','0000-00-00 00:00:00'),
(5,1,'phone-1','+371287834377','2026-01-18 19:57:58','0000-00-00 00:00:00'),
(6,1,'checkbox-1','LinkedIn, CV / Resume file','2026-01-18 19:57:58','0000-00-00 00:00:00'),
(7,1,'url-2','http://abc.com','2026-01-18 19:57:58','0000-00-00 00:00:00'),
(8,1,'upload-1','a:1:{s:4:\"file\";a:5:{s:7:\"success\";b:1;s:9:\"file_name\";s:64:\"AzzG3beJ4zCY-SIA-DeLuxe.Riga-Faktur-rekins-Nr.-54-25-payment.pdf\";s:8:\"file_url\";s:163:\"https://talendelight.com/wp-content/uploads/forminator/80_2cc7da7bb09a3e7e55214507b0773b79/uploads/AzzG3beJ4zCY-SIA-DeLuxe.Riga-Faktur-rekins-Nr.-54-25-payment.pdf\";s:7:\"message\";s:0:\"\";s:9:\"file_path\";s:192:\"/home/u909075950/domains/talendelight.com/public_html/wp-content/uploads/forminator/80_2cc7da7bb09a3e7e55214507b0773b79/uploads/AzzG3beJ4zCY-SIA-DeLuxe.Riga-Faktur-rekins-Nr.-54-25-payment.pdf\";}}','2026-01-18 19:57:58','0000-00-00 00:00:00'),
(9,1,'upload-2','a:1:{s:4:\"file\";a:5:{s:7:\"success\";b:1;s:9:\"file_name\";s:48:\"T9ZGpvGlf0C7-Phone-appointment-Dr-Nikolajeva.pdf\";s:8:\"file_url\";s:147:\"https://talendelight.com/wp-content/uploads/forminator/80_2cc7da7bb09a3e7e55214507b0773b79/uploads/T9ZGpvGlf0C7-Phone-appointment-Dr-Nikolajeva.pdf\";s:7:\"message\";s:0:\"\";s:9:\"file_path\";s:176:\"/home/u909075950/domains/talendelight.com/public_html/wp-content/uploads/forminator/80_2cc7da7bb09a3e7e55214507b0773b79/uploads/T9ZGpvGlf0C7-Phone-appointment-Dr-Nikolajeva.pdf\";}}','2026-01-18 19:57:58','0000-00-00 00:00:00'),
(10,1,'radio-1','No, I live in a different country','2026-01-18 19:57:58','0000-00-00 00:00:00'),
(11,1,'upload-3','a:1:{s:4:\"file\";a:5:{s:7:\"success\";b:1;s:9:\"file_name\";s:33:\"ZNAZUFhR3LJN-INVOICE_23752470.pdf\";s:8:\"file_url\";s:132:\"https://talendelight.com/wp-content/uploads/forminator/80_2cc7da7bb09a3e7e55214507b0773b79/uploads/ZNAZUFhR3LJN-INVOICE_23752470.pdf\";s:7:\"message\";s:0:\"\";s:9:\"file_path\";s:161:\"/home/u909075950/domains/talendelight.com/public_html/wp-content/uploads/forminator/80_2cc7da7bb09a3e7e55214507b0773b79/uploads/ZNAZUFhR3LJN-INVOICE_23752470.pdf\";}}','2026-01-18 19:57:58','0000-00-00 00:00:00'),
(12,1,'consent-1','checked','2026-01-18 19:57:58','0000-00-00 00:00:00'),
(13,1,'_forminator_user_ip','2a03:ec00:b983:edb5:599e:4bfa:f6b2:8532','2026-01-18 19:57:58','0000-00-00 00:00:00'),
(14,2,'name-1','abc','2026-01-20 21:45:34','0000-00-00 00:00:00'),
(15,2,'name-2','abc','2026-01-20 21:45:34','0000-00-00 00:00:00'),
(16,2,'name-3','abc','2026-01-20 21:45:34','0000-00-00 00:00:00'),
(17,2,'email-1','abc@abc.com','2026-01-20 21:45:34','0000-00-00 00:00:00'),
(18,2,'phone-1','+37843743274','2026-01-20 21:45:34','0000-00-00 00:00:00'),
(19,2,'checkbox-1','LinkedIn, CV / Resume file','2026-01-20 21:45:34','0000-00-00 00:00:00'),
(20,2,'url-2','https://www.abc.com','2026-01-20 21:45:34','0000-00-00 00:00:00'),
(21,2,'upload-1','a:1:{s:4:\"file\";a:5:{s:7:\"success\";b:1;s:9:\"file_name\";s:64:\"ydemujiJ9DZm-SIA-DeLuxe.Riga-Faktur-rekins-Nr.-54-25-payment.pdf\";s:8:\"file_url\";s:163:\"https://talendelight.com/wp-content/uploads/forminator/80_2cc7da7bb09a3e7e55214507b0773b79/uploads/ydemujiJ9DZm-SIA-DeLuxe.Riga-Faktur-rekins-Nr.-54-25-payment.pdf\";s:7:\"message\";s:0:\"\";s:9:\"file_path\";s:192:\"/home/u909075950/domains/talendelight.com/public_html/wp-content/uploads/forminator/80_2cc7da7bb09a3e7e55214507b0773b79/uploads/ydemujiJ9DZm-SIA-DeLuxe.Riga-Faktur-rekins-Nr.-54-25-payment.pdf\";}}','2026-01-20 21:45:34','0000-00-00 00:00:00'),
(22,2,'upload-2','a:1:{s:4:\"file\";a:5:{s:7:\"success\";b:1;s:9:\"file_name\";s:45:\"etxLrsJcf8QS-202512291215407188PWDdigital.pdf\";s:8:\"file_url\";s:144:\"https://talendelight.com/wp-content/uploads/forminator/80_2cc7da7bb09a3e7e55214507b0773b79/uploads/etxLrsJcf8QS-202512291215407188PWDdigital.pdf\";s:7:\"message\";s:0:\"\";s:9:\"file_path\";s:173:\"/home/u909075950/domains/talendelight.com/public_html/wp-content/uploads/forminator/80_2cc7da7bb09a3e7e55214507b0773b79/uploads/etxLrsJcf8QS-202512291215407188PWDdigital.pdf\";}}','2026-01-20 21:45:34','0000-00-00 00:00:00'),
(23,2,'radio-1','No, I live in a different country','2026-01-20 21:45:34','0000-00-00 00:00:00'),
(24,2,'upload-3','a:1:{s:4:\"file\";a:5:{s:7:\"success\";b:1;s:9:\"file_name\";s:49:\"L9cN7mDslAuW-AccountStatement_29122025_080705.pdf\";s:8:\"file_url\";s:148:\"https://talendelight.com/wp-content/uploads/forminator/80_2cc7da7bb09a3e7e55214507b0773b79/uploads/L9cN7mDslAuW-AccountStatement_29122025_080705.pdf\";s:7:\"message\";s:0:\"\";s:9:\"file_path\";s:177:\"/home/u909075950/domains/talendelight.com/public_html/wp-content/uploads/forminator/80_2cc7da7bb09a3e7e55214507b0773b79/uploads/L9cN7mDslAuW-AccountStatement_29122025_080705.pdf\";}}','2026-01-20 21:45:34','0000-00-00 00:00:00'),
(25,2,'consent-1','checked','2026-01-20 21:45:34','0000-00-00 00:00:00'),
(26,2,'_forminator_user_ip','2a03:ec00:b983:edb5:173:5ffa:3dd1:fb72','2026-01-20 21:45:34','0000-00-00 00:00:00'),
(27,3,'name-1','abc','2026-01-20 22:12:46','0000-00-00 00:00:00'),
(28,3,'name-2','abc','2026-01-20 22:12:46','0000-00-00 00:00:00'),
(29,3,'name-3','abc','2026-01-20 22:12:46','0000-00-00 00:00:00'),
(30,3,'email-1','abc@abc.com','2026-01-20 22:12:46','0000-00-00 00:00:00'),
(31,3,'phone-1','+371934738438','2026-01-20 22:12:46','0000-00-00 00:00:00'),
(32,3,'checkbox-1','LinkedIn, CV / Resume file','2026-01-20 22:12:46','0000-00-00 00:00:00'),
(33,3,'url-2','https://www.abc.com','2026-01-20 22:12:46','0000-00-00 00:00:00'),
(34,3,'upload-1','a:1:{s:4:\"file\";a:5:{s:7:\"success\";b:1;s:9:\"file_name\";s:64:\"UTc7Zskjhvj0-SIA-DeLuxe.Riga-Faktur-rekins-Nr.-54-25-payment.pdf\";s:8:\"file_url\";s:163:\"https://talendelight.com/wp-content/uploads/forminator/80_2cc7da7bb09a3e7e55214507b0773b79/uploads/UTc7Zskjhvj0-SIA-DeLuxe.Riga-Faktur-rekins-Nr.-54-25-payment.pdf\";s:7:\"message\";s:0:\"\";s:9:\"file_path\";s:192:\"/home/u909075950/domains/talendelight.com/public_html/wp-content/uploads/forminator/80_2cc7da7bb09a3e7e55214507b0773b79/uploads/UTc7Zskjhvj0-SIA-DeLuxe.Riga-Faktur-rekins-Nr.-54-25-payment.pdf\";}}','2026-01-20 22:12:46','0000-00-00 00:00:00'),
(35,3,'upload-2','a:1:{s:4:\"file\";a:5:{s:7:\"success\";b:1;s:9:\"file_name\";s:45:\"babLhGlq015f-202512291215407188PWDdigital.pdf\";s:8:\"file_url\";s:144:\"https://talendelight.com/wp-content/uploads/forminator/80_2cc7da7bb09a3e7e55214507b0773b79/uploads/babLhGlq015f-202512291215407188PWDdigital.pdf\";s:7:\"message\";s:0:\"\";s:9:\"file_path\";s:173:\"/home/u909075950/domains/talendelight.com/public_html/wp-content/uploads/forminator/80_2cc7da7bb09a3e7e55214507b0773b79/uploads/babLhGlq015f-202512291215407188PWDdigital.pdf\";}}','2026-01-20 22:12:46','0000-00-00 00:00:00'),
(36,3,'radio-1','No, I live in a different country','2026-01-20 22:12:46','0000-00-00 00:00:00'),
(37,3,'upload-3','a:1:{s:4:\"file\";a:5:{s:7:\"success\";b:1;s:9:\"file_name\";s:49:\"JqISxqA8dZLM-AccountStatement_29122025_080705.pdf\";s:8:\"file_url\";s:148:\"https://talendelight.com/wp-content/uploads/forminator/80_2cc7da7bb09a3e7e55214507b0773b79/uploads/JqISxqA8dZLM-AccountStatement_29122025_080705.pdf\";s:7:\"message\";s:0:\"\";s:9:\"file_path\";s:177:\"/home/u909075950/domains/talendelight.com/public_html/wp-content/uploads/forminator/80_2cc7da7bb09a3e7e55214507b0773b79/uploads/JqISxqA8dZLM-AccountStatement_29122025_080705.pdf\";}}','2026-01-20 22:12:46','0000-00-00 00:00:00'),
(38,3,'consent-1','checked','2026-01-20 22:12:46','0000-00-00 00:00:00'),
(39,3,'_forminator_user_ip','2a03:ec00:b983:edb5:173:5ffa:3dd1:fb72','2026-01-20 22:12:46','0000-00-00 00:00:00'),
(40,4,'name-1','abc','2026-01-21 08:55:25','0000-00-00 00:00:00'),
(41,4,'name-2','abc','2026-01-21 08:55:25','0000-00-00 00:00:00'),
(42,4,'name-3','abc','2026-01-21 08:55:25','0000-00-00 00:00:00'),
(43,4,'email-1','abc@abc.com','2026-01-21 08:55:25','0000-00-00 00:00:00'),
(44,4,'phone-1','+3712387483748','2026-01-21 08:55:25','0000-00-00 00:00:00'),
(45,4,'checkbox-1','LinkedIn, CV / Resume file','2026-01-21 08:55:25','0000-00-00 00:00:00'),
(46,4,'url-2','https://www.abc.com','2026-01-21 08:55:25','0000-00-00 00:00:00'),
(47,4,'upload-1','a:1:{s:4:\"file\";a:5:{s:7:\"success\";b:1;s:9:\"file_name\";s:64:\"YVl8LvXLSi60-SIA-DeLuxe.Riga-Faktur-rekins-Nr.-54-25-payment.pdf\";s:8:\"file_url\";s:163:\"https://talendelight.com/wp-content/uploads/forminator/80_2cc7da7bb09a3e7e55214507b0773b79/uploads/YVl8LvXLSi60-SIA-DeLuxe.Riga-Faktur-rekins-Nr.-54-25-payment.pdf\";s:7:\"message\";s:0:\"\";s:9:\"file_path\";s:192:\"/home/u909075950/domains/talendelight.com/public_html/wp-content/uploads/forminator/80_2cc7da7bb09a3e7e55214507b0773b79/uploads/YVl8LvXLSi60-SIA-DeLuxe.Riga-Faktur-rekins-Nr.-54-25-payment.pdf\";}}','2026-01-21 08:55:25','0000-00-00 00:00:00'),
(48,4,'upload-2','a:1:{s:4:\"file\";a:5:{s:7:\"success\";b:1;s:9:\"file_name\";s:45:\"BeUJ9YofMK5P-202512291215407188PWDdigital.pdf\";s:8:\"file_url\";s:144:\"https://talendelight.com/wp-content/uploads/forminator/80_2cc7da7bb09a3e7e55214507b0773b79/uploads/BeUJ9YofMK5P-202512291215407188PWDdigital.pdf\";s:7:\"message\";s:0:\"\";s:9:\"file_path\";s:173:\"/home/u909075950/domains/talendelight.com/public_html/wp-content/uploads/forminator/80_2cc7da7bb09a3e7e55214507b0773b79/uploads/BeUJ9YofMK5P-202512291215407188PWDdigital.pdf\";}}','2026-01-21 08:55:25','0000-00-00 00:00:00'),
(49,4,'radio-1','No, I live in a different country','2026-01-21 08:55:25','0000-00-00 00:00:00'),
(50,4,'upload-3','a:1:{s:4:\"file\";a:5:{s:7:\"success\";b:1;s:9:\"file_name\";s:49:\"mzvcXaRlEoG5-AccountStatement_29122025_080705.pdf\";s:8:\"file_url\";s:148:\"https://talendelight.com/wp-content/uploads/forminator/80_2cc7da7bb09a3e7e55214507b0773b79/uploads/mzvcXaRlEoG5-AccountStatement_29122025_080705.pdf\";s:7:\"message\";s:0:\"\";s:9:\"file_path\";s:177:\"/home/u909075950/domains/talendelight.com/public_html/wp-content/uploads/forminator/80_2cc7da7bb09a3e7e55214507b0773b79/uploads/mzvcXaRlEoG5-AccountStatement_29122025_080705.pdf\";}}','2026-01-21 08:55:25','0000-00-00 00:00:00'),
(51,4,'consent-1','checked','2026-01-21 08:55:25','0000-00-00 00:00:00'),
(52,4,'_forminator_user_ip','2a03:ec00:b983:ede0:593f:fec3:584f:9821','2026-01-21 08:55:25','0000-00-00 00:00:00'),
(53,5,'name-1','abc','2026-01-21 09:08:52','0000-00-00 00:00:00'),
(54,5,'name-2','abc','2026-01-21 09:08:52','0000-00-00 00:00:00'),
(55,5,'name-3','abc','2026-01-21 09:08:52','0000-00-00 00:00:00'),
(56,5,'email-1','abc@abc.com','2026-01-21 09:08:52','0000-00-00 00:00:00'),
(57,5,'phone-1','+37057573467','2026-01-21 09:08:52','0000-00-00 00:00:00'),
(58,5,'checkbox-1','LinkedIn, CV / Resume file','2026-01-21 09:08:52','0000-00-00 00:00:00'),
(59,5,'url-2','https://www.abc.com','2026-01-21 09:08:52','0000-00-00 00:00:00'),
(60,5,'upload-1','a:1:{s:4:\"file\";a:5:{s:7:\"success\";b:1;s:9:\"file_name\";s:64:\"3ng2PE48wobj-SIA-DeLuxe.Riga-Faktur-rekins-Nr.-54-25-payment.pdf\";s:8:\"file_url\";s:163:\"https://talendelight.com/wp-content/uploads/forminator/80_2cc7da7bb09a3e7e55214507b0773b79/uploads/3ng2PE48wobj-SIA-DeLuxe.Riga-Faktur-rekins-Nr.-54-25-payment.pdf\";s:7:\"message\";s:0:\"\";s:9:\"file_path\";s:192:\"/home/u909075950/domains/talendelight.com/public_html/wp-content/uploads/forminator/80_2cc7da7bb09a3e7e55214507b0773b79/uploads/3ng2PE48wobj-SIA-DeLuxe.Riga-Faktur-rekins-Nr.-54-25-payment.pdf\";}}','2026-01-21 09:08:52','0000-00-00 00:00:00'),
(61,5,'upload-2','a:1:{s:4:\"file\";a:5:{s:7:\"success\";b:1;s:9:\"file_name\";s:45:\"Oq6DZ9vOpcHB-202512291215407188PWDdigital.pdf\";s:8:\"file_url\";s:144:\"https://talendelight.com/wp-content/uploads/forminator/80_2cc7da7bb09a3e7e55214507b0773b79/uploads/Oq6DZ9vOpcHB-202512291215407188PWDdigital.pdf\";s:7:\"message\";s:0:\"\";s:9:\"file_path\";s:173:\"/home/u909075950/domains/talendelight.com/public_html/wp-content/uploads/forminator/80_2cc7da7bb09a3e7e55214507b0773b79/uploads/Oq6DZ9vOpcHB-202512291215407188PWDdigital.pdf\";}}','2026-01-21 09:08:52','0000-00-00 00:00:00'),
(62,5,'radio-1','No, I live in a different country','2026-01-21 09:08:52','0000-00-00 00:00:00'),
(63,5,'upload-3','a:1:{s:4:\"file\";a:5:{s:7:\"success\";b:1;s:9:\"file_name\";s:49:\"RgXrkJ6NvdcV-AccountStatement_29122025_080705.pdf\";s:8:\"file_url\";s:148:\"https://talendelight.com/wp-content/uploads/forminator/80_2cc7da7bb09a3e7e55214507b0773b79/uploads/RgXrkJ6NvdcV-AccountStatement_29122025_080705.pdf\";s:7:\"message\";s:0:\"\";s:9:\"file_path\";s:177:\"/home/u909075950/domains/talendelight.com/public_html/wp-content/uploads/forminator/80_2cc7da7bb09a3e7e55214507b0773b79/uploads/RgXrkJ6NvdcV-AccountStatement_29122025_080705.pdf\";}}','2026-01-21 09:08:52','0000-00-00 00:00:00'),
(64,5,'consent-1','checked','2026-01-21 09:08:52','0000-00-00 00:00:00'),
(65,5,'_forminator_user_ip','2a03:ec00:b983:ede0:593f:fec3:584f:9821','2026-01-21 09:08:52','0000-00-00 00:00:00'),
(66,6,'name-1','abc','2026-01-21 09:13:56','0000-00-00 00:00:00'),
(67,6,'name-2','abc','2026-01-21 09:13:56','0000-00-00 00:00:00'),
(68,6,'name-3','abc','2026-01-21 09:13:56','0000-00-00 00:00:00'),
(69,6,'email-1','abc@abc.com','2026-01-21 09:13:56','0000-00-00 00:00:00'),
(70,6,'phone-1','+3637446264632','2026-01-21 09:13:56','0000-00-00 00:00:00'),
(71,6,'checkbox-1','LinkedIn','2026-01-21 09:13:56','0000-00-00 00:00:00'),
(72,6,'url-2','https://www.abc.com','2026-01-21 09:13:56','0000-00-00 00:00:00'),
(73,6,'upload-2','a:1:{s:4:\"file\";a:5:{s:7:\"success\";b:1;s:9:\"file_name\";s:49:\"KQXZKs1BqCQU-AccountStatement_29122025_080705.pdf\";s:8:\"file_url\";s:148:\"https://talendelight.com/wp-content/uploads/forminator/80_2cc7da7bb09a3e7e55214507b0773b79/uploads/KQXZKs1BqCQU-AccountStatement_29122025_080705.pdf\";s:7:\"message\";s:0:\"\";s:9:\"file_path\";s:177:\"/home/u909075950/domains/talendelight.com/public_html/wp-content/uploads/forminator/80_2cc7da7bb09a3e7e55214507b0773b79/uploads/KQXZKs1BqCQU-AccountStatement_29122025_080705.pdf\";}}','2026-01-21 09:13:56','0000-00-00 00:00:00'),
(74,6,'radio-1','No, I live in a different country','2026-01-21 09:13:56','0000-00-00 00:00:00'),
(75,6,'upload-3','a:1:{s:4:\"file\";a:5:{s:7:\"success\";b:1;s:9:\"file_name\";s:45:\"veVNFnG8XXiM-202512291215407188PWDdigital.pdf\";s:8:\"file_url\";s:144:\"https://talendelight.com/wp-content/uploads/forminator/80_2cc7da7bb09a3e7e55214507b0773b79/uploads/veVNFnG8XXiM-202512291215407188PWDdigital.pdf\";s:7:\"message\";s:0:\"\";s:9:\"file_path\";s:173:\"/home/u909075950/domains/talendelight.com/public_html/wp-content/uploads/forminator/80_2cc7da7bb09a3e7e55214507b0773b79/uploads/veVNFnG8XXiM-202512291215407188PWDdigital.pdf\";}}','2026-01-21 09:13:56','0000-00-00 00:00:00'),
(76,6,'consent-1','checked','2026-01-21 09:13:56','0000-00-00 00:00:00'),
(77,6,'_forminator_user_ip','2a03:ec00:b983:ede0:593f:fec3:584f:9821','2026-01-21 09:13:56','0000-00-00 00:00:00'),
(78,7,'name-1','abcd','2026-01-21 20:05:37','0000-00-00 00:00:00'),
(79,7,'name-2','abcd','2026-01-21 20:05:37','0000-00-00 00:00:00'),
(80,7,'name-3','abcd','2026-01-21 20:05:37','0000-00-00 00:00:00'),
(81,7,'email-1','abcd@abcd.com','2026-01-21 20:05:37','0000-00-00 00:00:00'),
(82,7,'phone-1','+3745395763756','2026-01-21 20:05:37','0000-00-00 00:00:00'),
(83,7,'checkbox-1','LinkedIn, CV / Resume file','2026-01-21 20:05:37','0000-00-00 00:00:00'),
(84,7,'url-2','https://www.abcd.com','2026-01-21 20:05:37','0000-00-00 00:00:00'),
(85,7,'upload-1','a:1:{s:4:\"file\";a:5:{s:7:\"success\";b:1;s:9:\"file_name\";s:38:\"S29lfa3pcvCD-Atg_Bridin_87554481-1.pdf\";s:8:\"file_url\";s:137:\"https://talendelight.com/wp-content/uploads/forminator/80_2cc7da7bb09a3e7e55214507b0773b79/uploads/S29lfa3pcvCD-Atg_Bridin_87554481-1.pdf\";s:7:\"message\";s:0:\"\";s:9:\"file_path\";s:166:\"/home/u909075950/domains/talendelight.com/public_html/wp-content/uploads/forminator/80_2cc7da7bb09a3e7e55214507b0773b79/uploads/S29lfa3pcvCD-Atg_Bridin_87554481-1.pdf\";}}','2026-01-21 20:05:37','0000-00-00 00:00:00'),
(86,7,'upload-2','a:1:{s:4:\"file\";a:5:{s:7:\"success\";b:1;s:9:\"file_name\";s:48:\"QJZ1twNV9tnX-Phone-appointment-Dr-Nikolajeva.pdf\";s:8:\"file_url\";s:147:\"https://talendelight.com/wp-content/uploads/forminator/80_2cc7da7bb09a3e7e55214507b0773b79/uploads/QJZ1twNV9tnX-Phone-appointment-Dr-Nikolajeva.pdf\";s:7:\"message\";s:0:\"\";s:9:\"file_path\";s:176:\"/home/u909075950/domains/talendelight.com/public_html/wp-content/uploads/forminator/80_2cc7da7bb09a3e7e55214507b0773b79/uploads/QJZ1twNV9tnX-Phone-appointment-Dr-Nikolajeva.pdf\";}}','2026-01-21 20:05:37','0000-00-00 00:00:00'),
(87,7,'radio-1','No, I live in a different country','2026-01-21 20:05:37','0000-00-00 00:00:00'),
(88,7,'upload-3','a:1:{s:4:\"file\";a:5:{s:7:\"success\";b:1;s:9:\"file_name\";s:33:\"z0ieXVsdmsyC-INVOICE_23752470.pdf\";s:8:\"file_url\";s:132:\"https://talendelight.com/wp-content/uploads/forminator/80_2cc7da7bb09a3e7e55214507b0773b79/uploads/z0ieXVsdmsyC-INVOICE_23752470.pdf\";s:7:\"message\";s:0:\"\";s:9:\"file_path\";s:161:\"/home/u909075950/domains/talendelight.com/public_html/wp-content/uploads/forminator/80_2cc7da7bb09a3e7e55214507b0773b79/uploads/z0ieXVsdmsyC-INVOICE_23752470.pdf\";}}','2026-01-21 20:05:37','0000-00-00 00:00:00'),
(89,7,'consent-1','checked','2026-01-21 20:05:37','0000-00-00 00:00:00'),
(90,7,'_forminator_user_ip','2a03:ec00:b983:ede0:593f:fec3:584f:9821','2026-01-21 20:05:37','0000-00-00 00:00:00'),
(91,8,'name-1','abc','2026-01-26 22:50:53','0000-00-00 00:00:00'),
(92,8,'name-2','abc','2026-01-26 22:50:53','0000-00-00 00:00:00'),
(93,8,'name-3','abc','2026-01-26 22:50:53','0000-00-00 00:00:00'),
(94,8,'email-1','abc@abc.com','2026-01-26 22:50:53','0000-00-00 00:00:00'),
(95,8,'phone-1','+4756748563875','2026-01-26 22:50:53','0000-00-00 00:00:00'),
(96,8,'checkbox-1','LinkedIn, CV / Resume file','2026-01-26 22:50:53','0000-00-00 00:00:00'),
(97,8,'url-2','https://www.abc.com','2026-01-26 22:50:53','0000-00-00 00:00:00'),
(98,8,'upload-1','a:1:{s:4:\"file\";a:5:{s:7:\"success\";b:1;s:9:\"file_name\";s:38:\"nAZEKwMucnrd-Atg_Bridin_87554481-1.pdf\";s:8:\"file_url\";s:137:\"https://talendelight.com/wp-content/uploads/forminator/80_2cc7da7bb09a3e7e55214507b0773b79/uploads/nAZEKwMucnrd-Atg_Bridin_87554481-1.pdf\";s:7:\"message\";s:0:\"\";s:9:\"file_path\";s:166:\"/home/u909075950/domains/talendelight.com/public_html/wp-content/uploads/forminator/80_2cc7da7bb09a3e7e55214507b0773b79/uploads/nAZEKwMucnrd-Atg_Bridin_87554481-1.pdf\";}}','2026-01-26 22:50:53','0000-00-00 00:00:00'),
(99,8,'upload-2','a:1:{s:4:\"file\";a:5:{s:7:\"success\";b:1;s:9:\"file_name\";s:49:\"WenOPn5o6dgS-AccountStatement_29122025_080705.pdf\";s:8:\"file_url\";s:148:\"https://talendelight.com/wp-content/uploads/forminator/80_2cc7da7bb09a3e7e55214507b0773b79/uploads/WenOPn5o6dgS-AccountStatement_29122025_080705.pdf\";s:7:\"message\";s:0:\"\";s:9:\"file_path\";s:177:\"/home/u909075950/domains/talendelight.com/public_html/wp-content/uploads/forminator/80_2cc7da7bb09a3e7e55214507b0773b79/uploads/WenOPn5o6dgS-AccountStatement_29122025_080705.pdf\";}}','2026-01-26 22:50:53','0000-00-00 00:00:00'),
(100,8,'radio-1','Yes, I live in my  Country of Citizenship','2026-01-26 22:50:53','0000-00-00 00:00:00'),
(101,8,'consent-1','checked','2026-01-26 22:50:53','0000-00-00 00:00:00'),
(102,8,'_forminator_user_ip','2a03:ec00:b983:ede0:e814:c731:5159:acda','2026-01-26 22:50:53','0000-00-00 00:00:00');
/*!40000 ALTER TABLE `wp_frmt_form_entry_meta` ENABLE KEYS */;
UNLOCK TABLES;
commit;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*M!100616 SET NOTE_VERBOSITY=@OLD_NOTE_VERBOSITY */;

-- Dump completed on 2026-02-05  0:49:44
