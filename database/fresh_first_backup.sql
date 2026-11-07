-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1:3306
-- Generation Time: Nov 07, 2026 at 04:58 PM
-- Server version: 9.1.0
-- PHP Version: 8.3.14

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `fresh_first`
--

-- --------------------------------------------------------

--
-- Table structure for table `actions`
--

DROP TABLE IF EXISTS `actions`;
CREATE TABLE IF NOT EXISTS `actions` (
  `action_id` int NOT NULL AUTO_INCREMENT,
  `product_id` int NOT NULL,
  `verification_id` int NOT NULL,
  `suggested_action` varchar(30) NOT NULL,
  `final_action` varchar(30) NOT NULL,
  `status` enum('PENDING','DONE') DEFAULT 'PENDING',
  `action_date` datetime DEFAULT NULL,
  `decided_by` int DEFAULT NULL,
  PRIMARY KEY (`action_id`),
  KEY `product_id` (`product_id`),
  KEY `verification_id` (`verification_id`),
  KEY `decided_by` (`decided_by`)
) ENGINE=MyISAM AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `actions`
--

INSERT INTO `actions` (`action_id`, `product_id`, `verification_id`, `suggested_action`, `final_action`, `status`, `action_date`, `decided_by`) VALUES
(1, 1, 1, 'CONTINUE', 'CONTINUE', 'DONE', '2026-11-07 22:16:58', 1),
(2, 3, 2, 'CONTINUE', 'CONTINUE', 'DONE', '2026-11-07 22:16:58', 1),
(3, 4, 3, 'CONTINUE', 'CONTINUE', 'DONE', '2026-11-07 22:16:58', 1);

-- --------------------------------------------------------

--
-- Table structure for table `category_rules`
--

DROP TABLE IF EXISTS `category_rules`;
CREATE TABLE IF NOT EXISTS `category_rules` (
  `category` varchar(50) NOT NULL,
  `near_expiry_days` int NOT NULL DEFAULT '3',
  `min_temp` decimal(5,2) NOT NULL,
  `max_temp` decimal(5,2) NOT NULL,
  `large_qty` int NOT NULL DEFAULT '20',
  PRIMARY KEY (`category`)
) ;

--
-- Dumping data for table `category_rules`
--

INSERT INTO `category_rules` (`category`, `near_expiry_days`, `min_temp`, `max_temp`, `large_qty`) VALUES
('Dairy', 3, 2.00, 8.00, 20),
('Bakery', 2, 15.00, 25.00, 30),
('Fruits', 3, 4.00, 12.00, 25),
('Vegetables', 3, 4.00, 12.00, 25);

-- --------------------------------------------------------

--
-- Table structure for table `history`
--

DROP TABLE IF EXISTS `history`;
CREATE TABLE IF NOT EXISTS `history` (
  `history_id` int NOT NULL AUTO_INCREMENT,
  `product_id` int NOT NULL,
  `user_id` int NOT NULL,
  `event_type` varchar(30) NOT NULL,
  `details` varchar(255) DEFAULT NULL,
  `event_time` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`history_id`),
  KEY `user_id` (`user_id`),
  KEY `idx_history_product` (`product_id`)
) ENGINE=MyISAM AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `history`
--

INSERT INTO `history` (`history_id`, `product_id`, `user_id`, `event_type`, `details`, `event_time`) VALUES
(1, 1, 1, 'PRODUCT_ADDED', 'Apple added to stock', '2026-11-07 22:17:22'),
(2, 3, 1, 'PRODUCT_ADDED', 'Tomato added to stock', '2026-11-07 22:17:22'),
(3, 4, 1, 'PRODUCT_ADDED', 'Carrot added to stock', '2026-11-07 22:17:22'),
(4, 1, 1, 'VERIFIED', 'Apple verification completed', '2026-11-07 22:17:22'),
(5, 3, 1, 'VERIFIED', 'Tomato verification completed', '2026-11-07 22:17:22'),
(6, 4, 1, 'VERIFIED', 'Carrot verification completed', '2026-11-07 22:17:22');

--
-- Triggers `history`
--
DROP TRIGGER IF EXISTS `trg_history_no_delete`;
DELIMITER $$
CREATE TRIGGER `trg_history_no_delete` BEFORE DELETE ON `history` FOR EACH ROW SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT = 'History records cannot be deleted'
$$
DELIMITER ;
DROP TRIGGER IF EXISTS `trg_history_no_update`;
DELIMITER $$
CREATE TRIGGER `trg_history_no_update` BEFORE UPDATE ON `history` FOR EACH ROW SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT = 'History records cannot be modified'
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `products`
--

DROP TABLE IF EXISTS `products`;
CREATE TABLE IF NOT EXISTS `products` (
  `product_id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `category` varchar(50) NOT NULL,
  `quantity` int NOT NULL,
  `purchase_date` date NOT NULL,
  `expiry_date` date NOT NULL,
  `storage_condition` varchar(50) NOT NULL,
  `recorded_temp` decimal(5,2) DEFAULT NULL,
  `created_by` int NOT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `is_deleted` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`product_id`),
  KEY `category` (`category`),
  KEY `created_by` (`created_by`),
  KEY `idx_products_expiry` (`expiry_date`)
) ;

--
-- Dumping data for table `products`
--

INSERT INTO `products` (`product_id`, `name`, `category`, `quantity`, `purchase_date`, `expiry_date`, `storage_condition`, `recorded_temp`, `created_by`, `created_at`, `is_deleted`) VALUES
(1, 'Apple', 'Fruits', 25, '2026-11-06', '2026-11-15', 'Refrigerated', 5.00, 1, '2026-11-07 21:53:59', 0),
(2, 'Banana', 'Fruits', 15, '2026-11-06', '2026-11-10', 'Room Temperature', 22.00, 1, '2026-11-07 21:53:59', 1),
(3, 'Tomato', 'Vegetable', 10, '2026-11-06', '2026-11-12', 'Refrigerated', 6.00, 1, '2026-11-07 21:53:59', 0),
(4, 'Carrot', 'Vegetable', 25, '2026-11-06', '2026-11-14', 'Refrigerated', 5.00, 1, '2026-11-07 21:53:59', 0),
(5, 'Test Product', 'Fruits', 5, '2026-11-06', '2026-11-15', 'Refrigerated', 5.00, 999, '2026-11-07 22:21:42', 0);

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
CREATE TABLE IF NOT EXISTS `users` (
  `user_id` int NOT NULL AUTO_INCREMENT,
  `username` varchar(50) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `full_name` varchar(100) NOT NULL,
  `role` enum('ADMIN','MANAGER','STAFF') NOT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `username` (`username`)
) ENGINE=MyISAM AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`user_id`, `username`, `password_hash`, `full_name`, `role`, `is_active`, `created_at`) VALUES
(1, 'admin', 'demo_hash_1', 'Fresh First Admin', 'ADMIN', 1, '2026-11-07 21:49:51'),
(2, 'manager1', 'demo_hash_2', 'Store Manager', 'MANAGER', 1, '2026-11-07 21:49:51'),
(3, 'staff1', 'demo_hash_3', 'Store Staff', 'STAFF', 1, '2026-11-07 21:49:51');

-- --------------------------------------------------------

--
-- Table structure for table `verification`
--

DROP TABLE IF EXISTS `verification`;
CREATE TABLE IF NOT EXISTS `verification` (
  `verification_id` int NOT NULL AUTO_INCREMENT,
  `product_id` int NOT NULL,
  `verified_by` int NOT NULL,
  `verified_on` datetime DEFAULT CURRENT_TIMESTAMP,
  `days_left` int DEFAULT NULL,
  `expiry_status` varchar(20) NOT NULL,
  `storage_status` varchar(20) NOT NULL,
  `data_issue` varchar(30) DEFAULT NULL,
  `overall_status` varchar(30) NOT NULL,
  `priority` varchar(20) NOT NULL,
  `suggested_action` varchar(30) NOT NULL,
  PRIMARY KEY (`verification_id`),
  KEY `verified_by` (`verified_by`),
  KEY `idx_verification_product` (`product_id`)
) ENGINE=MyISAM AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `verification`
--

INSERT INTO `verification` (`verification_id`, `product_id`, `verified_by`, `verified_on`, `days_left`, `expiry_status`, `storage_status`, `data_issue`, `overall_status`, `priority`, `suggested_action`) VALUES
(1, 1, 1, '2026-11-07 22:15:56', 8, 'SAFE', 'OK', NULL, 'ACCEPTABLE', 'LOW', 'CONTINUE'),
(2, 3, 1, '2026-11-07 22:15:56', 5, 'SAFE', 'OK', NULL, 'ACCEPTABLE', 'LOW', 'CONTINUE'),
(3, 4, 1, '2026-11-07 22:15:56', 7, 'SAFE', 'OK', NULL, 'ACCEPTABLE', 'LOW', 'CONTINUE');
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
