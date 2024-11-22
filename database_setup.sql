-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------
-- -----------------------------------------------------
-- Schema schoolmanage
-- -----------------------------------------------------
DROP DATABASE IF EXISTS schoolmanage;
CREATE DATABASE schoolmanage;
USE schoolmanage;
-- -----------------------------------------------------
-- Table `role`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `role` (
  `role_id` INT NOT NULL AUTO_INCREMENT,
  `role_name` VARCHAR(255) NULL DEFAULT NULL,
  `role_type` ENUM('Admin', 'Teacher', 'Parent', 'Student') NULL DEFAULT NULL,
  `description` TEXT NULL DEFAULT NULL,
  PRIMARY KEY (`role_id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `userrole`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `userrole` (
  `user_role_id` INT NOT NULL AUTO_INCREMENT,
  `user_id` INT NOT NULL,
  `role_id` INT NOT NULL,
  PRIMARY KEY (`user_role_id`, `user_id`, `role_id`),
  UNIQUE INDEX `user_id_UNIQUE` (`user_id` ASC) VISIBLE,
  UNIQUE INDEX `role_id_UNIQUE` (`role_id` ASC) VISIBLE,
  CONSTRAINT `role_id_fk`
    FOREIGN KEY (`role_id`)
    REFERENCES `role` (`role_id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `registereduser`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `registereduser` (
  `user_id` INT NOT NULL AUTO_INCREMENT,
  `email` VARCHAR(255) NULL DEFAULT NULL,
  `contact_information` VARCHAR(255) NULL DEFAULT NULL,
  `dob` DATE NULL DEFAULT NULL,
  PRIMARY KEY (`user_id`),
  UNIQUE INDEX `email_UNIQUE` (`email` ASC) VISIBLE,
  CONSTRAINT `user_id_fk`
    FOREIGN KEY (`user_id`)
    REFERENCES `userrole` (`user_id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `account`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `account` (
  `account_id` INT NOT NULL AUTO_INCREMENT,
  `user_id` INT NOT NULL,
  `created_at` DATETIME NULL DEFAULT NULL,
  `status` ENUM('active', 'inactive') NULL DEFAULT NULL,
  `description` VARCHAR(255) NULL DEFAULT NULL,
  PRIMARY KEY (`account_id`, `user_id`),
  INDEX `user_id_fk_idx` (`user_id` ASC) VISIBLE,
  CONSTRAINT `account_user_id_fk`
    FOREIGN KEY (`user_id`)
    REFERENCES `registereduser` (`user_id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `address`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `address` (
  `address_id` INT NOT NULL AUTO_INCREMENT,
  `email` VARCHAR(255) NULL DEFAULT NULL,
  `postal_address` VARCHAR(255) NULL DEFAULT NULL,
  `phone` VARCHAR(50) NULL DEFAULT NULL,
  PRIMARY KEY (`address_id`),
  INDEX `address_id_idx` (`address_id` ASC) VISIBLE,
  CONSTRAINT `address_id_fk`
    FOREIGN KEY (`address_id`)
    REFERENCES `account` (`account_id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `department`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `department` (
  `department_id` INT NOT NULL AUTO_INCREMENT,
  `admin_id` INT NOT NULL,
  `department_name` VARCHAR(100) NULL DEFAULT NULL,
  `associated_classroom_id` INT NULL DEFAULT NULL,
  PRIMARY KEY (`department_id`),
  INDEX `admin_user_role_fk_idx` (`admin_id` ASC) VISIBLE,
  CONSTRAINT `admin_user_role_fk`
    FOREIGN KEY (`admin_id`)
    REFERENCES `userrole` (`user_id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `course`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `course` (
  `course_id` INT NOT NULL AUTO_INCREMENT,
  `department_id` INT NOT NULL,
  `user_course_id` INT NOT NULL,
  `course_name` VARCHAR(100) NULL DEFAULT NULL,
  `schedule_id` INT NULL DEFAULT NULL,
  PRIMARY KEY (`course_id`, `user_course_id`, `department_id`),
  INDEX `department_id_idk` (`department_id` ASC) INVISIBLE,
  INDEX `user_course_id_idx` (`user_course_id` ASC) VISIBLE,
  CONSTRAINT `department_id_fk`
    FOREIGN KEY (`department_id`)
    REFERENCES `department` (`department_id`),
  CONSTRAINT `user_course_id_fk`
    FOREIGN KEY (`user_course_id`)
    REFERENCES `registereduser` (`user_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `subject`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `subject` (
  `subject_id` INT NOT NULL AUTO_INCREMENT,
  `subject_name` VARCHAR(100) NULL DEFAULT NULL,
  `course_id` INT NULL DEFAULT NULL,
  `teacher_id` INT NULL DEFAULT NULL,
  PRIMARY KEY (`subject_id`),
  INDEX `teacher_id_idx` (`teacher_id` ASC) INVISIBLE,
  INDEX `course_id_idx` (`course_id` ASC) VISIBLE,
  CONSTRAINT `subject_course_id_fk`
    FOREIGN KEY (`course_id`)
    REFERENCES `course` (`course_id`),
  CONSTRAINT `teacher_id_fk`
    FOREIGN KEY (`teacher_id`)
    REFERENCES `userrole` (`user_id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `assignment`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `assignment` (
  `assignment_id` INT NOT NULL AUTO_INCREMENT,
  `subject_id` INT NOT NULL,
  `asn_grade` DECIMAL(5,2) NULL DEFAULT NULL,
  `description` VARCHAR(255) NULL DEFAULT NULL,
  `course_id` INT NULL DEFAULT NULL,
  `teacher_id` INT NULL DEFAULT NULL,
  `student_id` INT NULL DEFAULT NULL,
  PRIMARY KEY (`assignment_id`, `subject_id`),
  INDEX `subject_id_idx` (`subject_id` ASC) INVISIBLE,
  INDEX `course_id_idx` (`course_id` ASC) INVISIBLE,
  INDEX `teacher_id_idx` (`teacher_id` ASC) INVISIBLE,
  INDEX `student_id_idx` (`student_id` ASC) VISIBLE,
  CONSTRAINT `assignement_student_id_fk`
    FOREIGN KEY (`student_id`)
    REFERENCES `userrole` (`user_id`),
  CONSTRAINT `assignment_course_id_fk`
    FOREIGN KEY (`course_id`)
    REFERENCES `subject` (`course_id`),
  CONSTRAINT `assignment_teacher_id_fk`
    FOREIGN KEY (`teacher_id`)
    REFERENCES `userrole` (`user_id`),
  CONSTRAINT `subject_id_fk`
    FOREIGN KEY (`subject_id`)
    REFERENCES `subject` (`subject_id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `assignmentgrade`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `assignmentgrade` (
  `asn_grade_id` INT NOT NULL AUTO_INCREMENT,
  `assignment_id` INT NULL DEFAULT NULL,
  `student_id` INT NULL DEFAULT NULL,
  `grade_value` DECIMAL(5,2) NULL DEFAULT NULL,
  `total_grade_value` DECIMAL(5,2) NULL DEFAULT NULL,
  PRIMARY KEY (`asn_grade_id`),
  INDEX `assignment_id_idk` (`assignment_id` ASC) INVISIBLE,
  INDEX `student_id_idk` (`student_id` ASC) VISIBLE,
  CONSTRAINT `assignment_id_fk`
    FOREIGN KEY (`assignment_id`)
    REFERENCES `assignment` (`assignment_id`),
  CONSTRAINT `student_id_fk`
    FOREIGN KEY (`student_id`)
    REFERENCES `assignment` (`student_id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `classroom`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `classroom` (
  `class_id` INT NOT NULL AUTO_INCREMENT,
  `teacher_id` INT NULL DEFAULT NULL,
  `student_id` INT NULL DEFAULT NULL,
  `schedule_id` INT NULL DEFAULT NULL,
  `course_id` INT NULL DEFAULT NULL,
  PRIMARY KEY (`class_id`),
  INDEX `teacher_user_id_idx` (`teacher_id` ASC) INVISIBLE,
  INDEX `student_user_id_idx` (`student_id` ASC) INVISIBLE,
  INDEX `course_id_idx` (`course_id` ASC) INVISIBLE,
  INDEX `schedule_id_idx` (`schedule_id` ASC) INVISIBLE,
  CONSTRAINT `classroom_course_id_fk`
    FOREIGN KEY (`course_id`)
    REFERENCES `course` (`course_id`),
  CONSTRAINT `student_user_id_fk`
    FOREIGN KEY (`student_id`)
    REFERENCES `userrole` (`user_id`),
  CONSTRAINT `teacher_user_id_fk`
    FOREIGN KEY (`teacher_id`)
    REFERENCES `userrole` (`user_id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `attendance`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `attendance` (
  `attendance_id` INT NOT NULL AUTO_INCREMENT,
  `student_id` INT NULL DEFAULT NULL,
  `class_id` INT NULL DEFAULT NULL,
  `status` ENUM('Present', 'Absent') NULL DEFAULT NULL,
  `date` DATE NOT NULL,
  PRIMARY KEY (`attendance_id`),
  INDEX `student_id_idx` (`student_id` ASC) VISIBLE,
  INDEX `class_id_idx` (`class_id` ASC) VISIBLE,
  CONSTRAINT `attendance_class_id_fk`
    FOREIGN KEY (`class_id`)
    REFERENCES `classroom` (`class_id`),
  CONSTRAINT `attendance_student_id_fk`
    FOREIGN KEY (`student_id`)
    REFERENCES `classroom` (`student_id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `classschedule`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `classschedule` (
  `schedule_id` INT NOT NULL AUTO_INCREMENT,
  `subject_id` INT NULL DEFAULT NULL,
  `time_slot_id` INT NULL DEFAULT NULL,
  `date` DATE NULL DEFAULT NULL,
  PRIMARY KEY (`schedule_id`),
  INDEX `schedule_id_idx` (`schedule_id` ASC) INVISIBLE,
  INDEX `subject_id_idx` (`subject_id` ASC) INVISIBLE,
  CONSTRAINT `classschedule_subject_id_fk`
    FOREIGN KEY (`subject_id`)
    REFERENCES `subject` (`subject_id`)
    ON DELETE CASCADE,
  CONSTRAINT `schedule_id_fk`
    FOREIGN KEY (`schedule_id`)
    REFERENCES `classroom` (`class_id`)
    ON DELETE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `enrollment`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `enrollment` (
  `enrollment_id` INT NOT NULL AUTO_INCREMENT,
  `user_id` INT NOT NULL,
  `course_id` INT NOT NULL,
  `progress` VARCHAR(45) NULL,
  PRIMARY KEY (`enrollment_id`),
  INDEX `student_id_idx` (`user_id` ASC) VISIBLE,
  INDEX `course_id_idx` (`course_id` ASC) VISIBLE,
  CONSTRAINT `course_id_fk`
    FOREIGN KEY (`course_id`)
    REFERENCES `course` (`course_id`),
  CONSTRAINT `student_id`
    FOREIGN KEY (`user_id`)
    REFERENCES `registereduser` (`user_id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `exam`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `exam` (
  `exam_id` INT NOT NULL AUTO_INCREMENT,
  `subject_id` INT NOT NULL,
  `exam_date` DATE NULL DEFAULT NULL,
  `duration` TIME NULL DEFAULT NULL,
  PRIMARY KEY (`exam_id`),
  INDEX `subject_id_idk` (`subject_id` ASC) VISIBLE,
  CONSTRAINT `exam_subject_id_fk`
    FOREIGN KEY (`subject_id`)
    REFERENCES `subject` (`subject_id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `examgrade`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `examgrade` (
  `examgrade_id` INT NOT NULL AUTO_INCREMENT,
  `exam_id` INT NULL DEFAULT NULL,
  `student_id` INT NOT NULL,
  `grade_value` DECIMAL(5,2) NULL DEFAULT NULL,
  PRIMARY KEY (`examgrade_id`),
  INDEX `exam_id_idx` (`exam_id` ASC) VISIBLE,
  INDEX `student_id_course_id_idx` (`student_id` ASC) VISIBLE,
  CONSTRAINT `exam_id_fk`
    FOREIGN KEY (`exam_id`)
    REFERENCES `exam` (`exam_id`),
  CONSTRAINT `student_id_course_id_fk`
    FOREIGN KEY (`student_id`)
    REFERENCES `course` (`user_course_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `fees`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `fees` (
  `fee_id` INT NOT NULL AUTO_INCREMENT,
  `fee_type_id` INT NOT NULL,
  `student_id` INT NULL DEFAULT NULL,
  `amount` DECIMAL(10,2) NULL DEFAULT NULL,
  `admin_id` INT NOT NULL,
  PRIMARY KEY (`fee_id`),
  INDEX `student_id_fk_idx` (`student_id` ASC) VISIBLE,
  INDEX `admin_id_fk` (`admin_id` ASC) VISIBLE,
  CONSTRAINT `admin_id_fk`
    FOREIGN KEY (`admin_id`)
    REFERENCES `department` (`admin_id`),
  CONSTRAINT `fee_student_id_fk`
    FOREIGN KEY (`student_id`)
    REFERENCES `userrole` (`user_id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `feetype`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `feetype` (
  `fee_type_id` INT NOT NULL AUTO_INCREMENT,
  `student_id` INT NOT NULL,
  `type_description` ENUM('FieldTripFees', 'TextBooks', 'LabFees', 'Misc') NULL DEFAULT NULL,
  `amount` DECIMAL(10,2) NULL DEFAULT NULL,
  PRIMARY KEY (`fee_type_id`),
  INDEX `student_id_idx` (`student_id` ASC) VISIBLE,
  CONSTRAINT `feetype_student_id_fk`
    FOREIGN KEY (`student_id`)
    REFERENCES `fees` (`student_id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `permissions`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `permissions` (
  `permission_id` INT NOT NULL AUTO_INCREMENT,
  `user_role_id` INT NULL DEFAULT NULL,
  `table_name` VARCHAR(100) NULL DEFAULT NULL,
  `access_level` ENUM('read', 'write', 'admin') NULL DEFAULT NULL,
  PRIMARY KEY (`permission_id`),
  INDEX `user_role_id_idx` (`user_role_id` ASC) INVISIBLE,
  CONSTRAINT `user_role_id_fk`
    FOREIGN KEY (`user_role_id`)
    REFERENCES `userrole` (`user_id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `record`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `record` (
  `record_id` INT NOT NULL AUTO_INCREMENT,
  `user_id` INT NULL DEFAULT NULL,
  `record_type_id` INT NULL DEFAULT NULL,
  `date_created` DATETIME NULL DEFAULT NULL,
  PRIMARY KEY (`record_id`),
  INDEX `user_id_idx` (`user_id` ASC) VISIBLE,
  INDEX `record_type_idx` (`record_type_id` ASC) VISIBLE,
  CONSTRAINT `record_user_id_fk`
    FOREIGN KEY (`user_id`)
    REFERENCES `enrollment` (`user_id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `recordtype`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `recordtype` (
  `record_type_id` INT NOT NULL AUTO_INCREMENT,
  `description` VARCHAR(255) NULL DEFAULT NULL,
  `category` VARCHAR(100) NULL DEFAULT NULL,
  `status` ENUM('Completed', 'In Progress', 'Incomplete') NULL DEFAULT NULL,
  `date_started` DATETIME NULL DEFAULT NULL,
  PRIMARY KEY (`record_type_id`),
  INDEX `record_type_id_record_idx` (`record_type_id` ASC) INVISIBLE,
  CONSTRAINT `record_type_record_id_fk`
    FOREIGN KEY (`record_type_id`)
    REFERENCES `record` (`record_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `section`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `section` (
  `section_id` INT NOT NULL AUTO_INCREMENT,
  `section_num` INT NULL DEFAULT NULL,
  `description` VARCHAR(255) NULL DEFAULT NULL,
  `parent_id` INT NULL DEFAULT NULL,
  `course_id` INT NULL DEFAULT NULL,
  PRIMARY KEY (`section_id`),
  INDEX `parent_section_id_idx` (`parent_id` ASC) VISIBLE,
  INDEX `course_id_idx` (`course_id` ASC) INVISIBLE,
  CONSTRAINT `feetype_course_id_fk`
    FOREIGN KEY (`course_id`)
    REFERENCES `course` (`course_id`),
  CONSTRAINT `parent_section_id_fk`
    FOREIGN KEY (`parent_id`)
    REFERENCES `section` (`section_id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `timeslot`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `timeslot` (
  `slot_id` INT NOT NULL AUTO_INCREMENT,
  `class_id` INT NOT NULL,
  `start_time` TIME NULL DEFAULT NULL,
  `end_time` TIME NULL DEFAULT NULL,
  `subject_id` INT NOT NULL,
  `schedule_id` INT NULL DEFAULT NULL,
  PRIMARY KEY (`slot_id`, `class_id`, `subject_id`),
  INDEX `timesl_class_id_idx` (`class_id` ASC) VISIBLE,
  INDEX `timeslot_subject_id_fk_idx` (`subject_id` ASC) VISIBLE,
  CONSTRAINT `timeslot_subject_id_fk`
    FOREIGN KEY (`subject_id`)
    REFERENCES `subject` (`subject_id`)
    ON DELETE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `totalgrade`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `totalgrade` (
  `total_grade_id` INT NOT NULL AUTO_INCREMENT,
  `student_id` INT NULL DEFAULT NULL,
  `course_id` INT NULL DEFAULT NULL,
  `final_grade_value` DECIMAL(5,2) NULL DEFAULT NULL,
  `date_calculated` DATETIME NULL DEFAULT NULL,
  `exam_id` INT NULL DEFAULT NULL,
  `assignment_id` INT NULL DEFAULT NULL,
  PRIMARY KEY (`total_grade_id`),
  INDEX `student_id_idx` (`student_id` ASC) VISIBLE,
  INDEX `course_id_idx` (`course_id` ASC) INVISIBLE,
  INDEX `exam_id_idx` (`exam_id` ASC) INVISIBLE,
  INDEX `assignment_id_idx` (`assignment_id` ASC) INVISIBLE,
  CONSTRAINT `totalgrade_assignment_id_fk`
    FOREIGN KEY (`assignment_id`)
    REFERENCES `assignment` (`assignment_id`),
  CONSTRAINT `totalgrade_course_id_fk`
    FOREIGN KEY (`course_id`)
    REFERENCES `course` (`course_id`),
  CONSTRAINT `totalgrade_exam_id_fk`
    FOREIGN KEY (`exam_id`)
    REFERENCES `exam` (`exam_id`),
  CONSTRAINT `totalgrade_student_id_fk`
    FOREIGN KEY (`student_id`)
    REFERENCES `assignment` (`student_id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `notifications`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `notifications` (
  `notification_id` INT NOT NULL AUTO_INCREMENT,
  `user_id` INT NULL,
  `message` VARCHAR(255) NULL,
  `created_at` DATE NULL,
  PRIMARY KEY (`notification_id`),
  INDEX `user_id_notification_idx` (`user_id` ASC) INVISIBLE,
  CONSTRAINT `user_id_notification_fk`
    FOREIGN KEY (`user_id`)
    REFERENCES `userrole` (`user_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
