-- ====================================================================
-- LIFEDROP / RAUF BLOOD MANAGEMENT SYSTEM DATABASE SCHEMA
-- Database: blood_bank_db
-- Target Server: MySQL Server 8.0+
-- ====================================================================

CREATE DATABASE IF NOT EXISTS `blood_bank_db`
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE `blood_bank_db`;

SET FOREIGN_KEY_CHECKS = 0;

-- Drop tables if needed for clean setup
DROP TABLE IF EXISTS `contact_messages`;
DROP TABLE IF EXISTS `blood_requests`;
DROP TABLE IF EXISTS `blood_stock`;
DROP TABLE IF EXISTS `donors`;
DROP TABLE IF EXISTS `users`;
DROP TABLE IF EXISTS `hospitals`;
DROP TABLE IF EXISTS `blood_units`;
DROP TABLE IF EXISTS `donations`;

SET FOREIGN_KEY_CHECKS = 1;

-- --------------------------------------------------------------------
-- TABLE 1: donors
-- --------------------------------------------------------------------
CREATE TABLE `donors` (
  `donor_id` INT PRIMARY KEY AUTO_INCREMENT,
  `name` VARCHAR(100) NOT NULL,
  `age` INT DEFAULT 25,
  `gender` VARCHAR(20) DEFAULT 'Male',
  `blood_group` VARCHAR(5) NOT NULL,
  `phone` VARCHAR(15) UNIQUE NOT NULL,
  `email` VARCHAR(150),
  `city` VARCHAR(100),
  `address` TEXT,
  `last_donation_date` DATE NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX `idx_donors_blood_group` (`blood_group`),
  INDEX `idx_donors_city` (`city`),
  INDEX `idx_donors_phone` (`phone`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------------------
-- TABLE 2: blood_requests
-- --------------------------------------------------------------------
CREATE TABLE `blood_requests` (
  `request_id` INT PRIMARY KEY AUTO_INCREMENT,
  `patient_name` VARCHAR(100) NOT NULL,
  `blood_group` VARCHAR(5) NOT NULL,
  `units_required` INT NOT NULL,
  `hospital_name` VARCHAR(200),
  `city` VARCHAR(100),
  `contact_number` VARCHAR(15),
  `urgency` VARCHAR(30) DEFAULT 'Standard',
  `status` VARCHAR(30) DEFAULT 'Pending',
  `request_date` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX `idx_req_status` (`status`),
  INDEX `idx_req_blood_group` (`blood_group`),
  INDEX `idx_req_city` (`city`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------------------
-- TABLE 3: blood_stock
-- --------------------------------------------------------------------
CREATE TABLE `blood_stock` (
  `stock_id` INT PRIMARY KEY AUTO_INCREMENT,
  `blood_group` VARCHAR(5) UNIQUE NOT NULL,
  `available_units` INT DEFAULT 0,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX `idx_stock_blood_group` (`blood_group`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------------------
-- TABLE 4: users
-- --------------------------------------------------------------------
CREATE TABLE `users` (
  `user_id` INT PRIMARY KEY AUTO_INCREMENT,
  `name` VARCHAR(100),
  `email` VARCHAR(150) UNIQUE,
  `password` VARCHAR(255),
  `role` VARCHAR(30) DEFAULT 'donor',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX `idx_users_email` (`email`),
  INDEX `idx_users_role` (`role`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------------------
-- TABLE 5: contact_messages
-- --------------------------------------------------------------------
CREATE TABLE `contact_messages` (
  `message_id` INT PRIMARY KEY AUTO_INCREMENT,
  `name` VARCHAR(100),
  `email` VARCHAR(150),
  `phone` VARCHAR(15),
  `subject` VARCHAR(200),
  `message` TEXT,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX `idx_contact_created` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Auxiliary tables for extended hospital and transfusion features
CREATE TABLE `hospitals` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `name` VARCHAR(200) NOT NULL,
  `registration_number` VARCHAR(100),
  `contact_person` VARCHAR(100),
  `phone` VARCHAR(30),
  `email` VARCHAR(150),
  `address` TEXT,
  `city` VARCHAR(100),
  `state` VARCHAR(100),
  `pincode` VARCHAR(20),
  `verification_status` ENUM('Pending', 'Verified', 'Rejected') DEFAULT 'Verified',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `donations` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `donation_code` VARCHAR(50) UNIQUE,
  `donor_id` INT,
  `donation_date` DATE,
  `blood_group` VARCHAR(5),
  `component_type` VARCHAR(50) DEFAULT 'Whole Blood',
  `units_donated` INT DEFAULT 1,
  `hemoglobin_level` DECIMAL(4,1) DEFAULT 14.5,
  `blood_pressure` VARCHAR(20) DEFAULT '120/80',
  `pulse_rate` INT DEFAULT 72,
  `donation_status` VARCHAR(30) DEFAULT 'Completed',
  `nurse_or_phlebotomist` VARCHAR(100) DEFAULT 'Nurse Coordinator',
  `certificate_issued` TINYINT(1) DEFAULT 1,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------------------
-- SEED DATA
-- --------------------------------------------------------------------

-- Seed Users (bcrypt hash for 'admin123' is $2b$10$qswkcR9B7ruS0KcItYv5CezOr3sx77IP2uuNnVjSmrsh3BphnCcru)
INSERT INTO `users` (`user_id`, `name`, `email`, `password`, `role`) VALUES
(1, 'LIFEDROP Admin', 'admin@lifedrop.org', '$2b$10$qswkcR9B7ruS0KcItYv5CezOr3sx77IP2uuNnVjSmrsh3BphnCcru', 'admin'),
(2, 'Robert Chen', 'robert.chen@email.com', '$2b$10$qswkcR9B7ruS0KcItYv5CezOr3sx77IP2uuNnVjSmrsh3BphnCcru', 'donor'),
(3, 'Anita Patel', 'anita.patel@email.com', '$2b$10$qswkcR9B7ruS0KcItYv5CezOr3sx77IP2uuNnVjSmrsh3BphnCcru', 'donor'),
(4, 'St. Jude General Hospital', 'stjude@metrohealth.org', '$2b$10$qswkcR9B7ruS0KcItYv5CezOr3sx77IP2uuNnVjSmrsh3BphnCcru', 'hospital'),
(5, 'Rauf Admin', 'admin@raufblood.org', '$2b$10$qswkcR9B7ruS0KcItYv5CezOr3sx77IP2uuNnVjSmrsh3BphnCcru', 'admin');

-- Seed Blood Stock (All 8 blood groups)
INSERT INTO `blood_stock` (`stock_id`, `blood_group`, `available_units`) VALUES
(1, 'A+', 48),
(2, 'A-', 14),
(3, 'B+', 52),
(4, 'B-', 9),
(5, 'AB+', 22),
(6, 'AB-', 6),
(7, 'O+', 85),
(8, 'O-', 11);

-- Seed Donors
INSERT INTO `donors` (`donor_id`, `name`, `age`, `gender`, `blood_group`, `phone`, `email`, `city`, `address`, `last_donation_date`) VALUES
(1, 'Robert Chen', 32, 'Male', 'O+', '+1 555-234-5678', 'robert.chen@email.com', 'Metro City', '452 Pinecrest Ave', '2026-08-10'),
(2, 'Anita Patel', 28, 'Female', 'A+', '+1 555-345-6789', 'anita.patel@email.com', 'Metro City', '88 Maple Grove Lane', '2026-09-02'),
(3, 'Marcus Vance', 36, 'Male', 'B-', '+1 555-456-7890', 'marcus.vance@email.com', 'North Valley', '312 Oakwood Heights', '2026-10-12'),
(4, 'Elena Rostova', 29, 'Female', 'AB+', '+1 555-567-8901', 'elena.rostova@sample.org', 'Metro City', '19 Riverview Terrace', '2026-06-25'),
(5, 'David Kim', 34, 'Male', 'O-', '+1 555-678-9012', 'david.kim@sample.org', 'North Valley', '702 Horizon Blvd', '2026-07-15');

-- Seed Blood Requests
INSERT INTO `blood_requests` (`request_id`, `patient_name`, `blood_group`, `units_required`, `hospital_name`, `city`, `contact_number`, `urgency`, `status`, `request_date`) VALUES
(1, 'Jonathan Miller', 'O-', 3, 'St. Jude General Hospital', 'Metro City', '+1 555-987-0911', 'Emergency - Critical', 'Fulfilled', NOW() - INTERVAL 2 DAY),
(2, 'Sophia Ramirez', 'A+', 2, 'Apex Trauma & Multispecialty', 'Metro City', '+1 555-876-0911', 'Urgent', 'Approved', NOW() - INTERVAL 1 DAY),
(3, 'Chloe Evans', 'O+', 2, 'City Care Memorial Hospital', 'North Valley', '+1 555-765-0911', 'Urgent', 'Pending', NOW());

-- Seed Contact Messages
INSERT INTO `contact_messages` (`message_id`, `name`, `email`, `phone`, `subject`, `message`) VALUES
(1, 'Dr. Arthur Sterling', 'arthur@example.com', '+1 555-123-4567', 'Blood Donation Camp Inquiry', 'We would like to organize an upcoming annual blood drive at our healthcare university next month.');

-- Seed Hospitals
INSERT INTO `hospitals` (`id`, `name`, `registration_number`, `contact_person`, `phone`, `email`, `address`, `city`, `state`, `pincode`, `verification_status`) VALUES
(1, 'St. Jude General Hospital', 'REG-HOSP-NY-9021', 'Dr. Evelyn Howard', '+1 555-987-6543', 'stjude@metrohealth.org', '500 Health Sciences Way', 'Metro City', 'State', '10003', 'Verified'),
(2, 'Apex Trauma & Multispecialty', 'REG-HOSP-NY-8452', 'Dr. James Thorne', '+1 555-876-5432', 'apex.trauma@apexhealth.net', '1200 Emergency Corridor', 'Metro City', 'State', '10004', 'Verified'),
(3, 'City Care Memorial Hospital', 'REG-HOSP-NY-7721', 'Carla Cruz', '+1 555-765-4321', 'citycare@healthnet.org', '321 Civic Center Dr', 'North Valley', 'State', '10047', 'Pending');
