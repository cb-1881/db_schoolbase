-- This file inserts sample data to populate the schoolmanage database
USE schoolmanage;

-- -----------------------------------------------------
-- Strong Entities (No Foreign Key Dependencies)
-- -----------------------------------------------------

-- Insert data into the `role` table
INSERT INTO role (role_name, role_type, description) VALUES
('Administrator', 'Admin', 'System administrator with full access'),
('Math Teacher', 'Teacher', 'Teaches math courses'),
('Parent', 'Parent', 'Parent of enrolled students'),
('Student', 'Student', 'Enrolled student');




-- -----------------------------------------------------
-- Primary Entities with Direct Dependencies
-- -----------------------------------------------------

-- Insert data into the `userrole` table (depends on `registereduser` and `role`)
INSERT INTO userrole (user_role_id, user_id, role_id) VALUES
(1, 1, 1),  -- Admin
(2, 2, 2),  -- Teacher
(3, 3, 3),  -- Parent
(4, 4, 4);  -- Student

-- Insert data into the `registereduser` table
INSERT INTO registereduser (email, contact_information, dob) VALUES
('admin@example.com', '123-456-7890', '1980-04-05'),
('teacher@example.com', '234-567-8901', '1985-06-15'),
('parent@example.com', '345-678-9012', '1990-10-25'),
('student@example.com', '456-789-0123', '2005-09-20');

-- Insert data into the `department` table first
INSERT INTO department (department_id, admin_id, department_name, associated_classroom_id) VALUES
(1, 1, 'Admin Department', NULL),
(2, 1, 'Mathematics Department', NULL);



-- Now, insert data into the `course` table, using valid department_id values
INSERT INTO course (course_id, department_id, user_course_id, course_name, schedule_id) VALUES
(1, 1, 1, 'Admin Course', NULL),
(2, 2, 2, 'Algebra 101', NULL),
(3, 2, 3, 'Physics 101', NULL),
(4, 2, 4, 'World History', NULL);



-- Insert data into the `enrollment` table (depends on `registereduser` and `course`)
INSERT INTO enrollment (user_id, course_id, progress) VALUES
(4, 1, 'In Progress'),
(4, 2, 'Completed'),
(4, 3, 'Not Started');


-- Insert data into the `record` table (depends on `enrollment` and `recordtype`)
INSERT INTO record (user_id, record_type_id, date_created) VALUES
(4, 1, '2024-01-10 10:00:00'),
(4, 2, '2024-02-10 11:15:00'),
(4, 3, '2024-03-15 14:30:00');

-- Insert data into the `recordtype` table
INSERT INTO recordtype (description, category, status, date_started) VALUES
('Assignment Submission', 'Academics', 'In Progress', '2024-01-01 08:30:00'),
('Exam Record', 'Assessment', 'Completed', '2024-02-01 09:45:00'),
('Project Work', 'Academics', 'Incomplete', '2024-03-01 11:00:00');
-- -----------------------------------------------------
-- Secondary Entities with Indirect Dependencies
-- -----------------------------------------------------

-- Insert data into the `account` table (depends on `registereduser`)
INSERT INTO account (user_id, created_at, status, description) VALUES
(1, '2024-01-01 09:00:00', 'active', 'Admin account'),
(2, '2024-02-01 10:30:00', 'active', 'Math teacher account'),
(3, '2024-03-01 11:45:00', 'inactive', 'Parent account'),
(4, '2024-04-01 12:00:00', 'active', 'Student account');

-- Insert data into the `address` table (depends on `account`)
INSERT INTO address (email, postal_address, phone) VALUES
('admin@example.com', '123 Admin St, Admin City', '123-456-7890'),
('teacher@example.com', '234 Teacher Ln, Teacher City', '234-567-8901'),
('parent@example.com', '345 Parent Ave, Parent City', '345-678-9012'),
('student@example.com', '456 Student Rd, Student City', '456-789-0123');

-- Insert data into the `subject` table (depends on `course` and `userrole`)
INSERT INTO subject (subject_name, course_id, teacher_id) VALUES
('Algebra', 1, 2),
('Physics', 2, 2),
('History', 3, 2);





-- Insert data into the `assignment` table (depends on `subject`, `course`, `userrole`)
INSERT INTO assignment (subject_id, asn_grade, description, course_id, teacher_id, student_id) VALUES
(1, 88.50, 'Algebra Assignment 1', 1, 2, 4),
(2, 92.00, 'Physics Lab Report', 2, 2, 4),
(3, 76.00, 'History Essay', 3, 2, 4);

-- -----------------------------------------------------
-- Weak Entities (Dependent on Primary Entities)
-- -----------------------------------------------------

-- Insert data into the `assignmentgrade` table (depends on `assignment`)
INSERT INTO assignmentgrade (assignment_id, student_id, grade_value, total_grade_value) VALUES
(1, 4, 88.50, 100.00),
(2, 4, 92.00, 100.00),
(3, 4, 76.00, 100.00);


-- Assuming user IDs 1, 2, and 3 exist for teacher and student in userrole
-- Assuming course IDs 1 and 2 exist in the course table

INSERT INTO `classroom` (`teacher_id`, `student_id`, `schedule_id`, `course_id`)
VALUES
    (1, 4, 1, 1),  -- Classroom 1 with teacher_id 1, student_id 4, schedule_id 1, course_id 1
    (1, 4, 2, 1),  -- Classroom 2 with teacher_id 2, student_id 4, schedule_id 2, course_id 1
    (1, 4, 1, 2),  -- Classroom 3 with teacher_id 1, student_id 5, schedule_id 1, course_id 2
    (1, 4, 3, 2),  -- Classroom 4 with teacher_id 3, student_id 6, schedule_id 3, course_id 2
    (1, 3, 3, 2),  -- Classroom 4 with teacher_id 3, student_id 6, schedule_id 3, course_id 2
	(1, 3, 3, 2);  -- Classroom 4 with teacher_id 3, student_id 6, schedule_id 3, course_id 2

-- Check that the IDs used (1, 2, 3, 4, etc.) match the ones in your actual database

-- Insert data into the `attendance` table (depends on `classroom`)
INSERT INTO attendance (student_id, class_id, status, date) VALUES
(4, 1, 'Present', '2024-11-10'),
(4, 2, 'Absent', '2024-11-10'),
(4, 3, 'Present', '2024-11-10'),
(3, 1, 'Present', '2024-11-10'),
(3, 2, 'Present', '2024-11-10'),
(3, 3, 'Present', '2024-11-10');

-- Insert data into the `exam` table (depends on `subject`)
INSERT INTO exam (subject_id, exam_date, duration) VALUES
(1, '2024-06-01', '02:00:00'),
(2, '2024-06-15', '02:30:00'),
(3, '2024-07-01', '03:00:00');

-- Insert data into the `examgrade` table (depends on `exam`, `course`)
INSERT INTO examgrade (exam_id, student_id, grade_value) VALUES
(1, 4, 85.00),
(2, 4, 90.00),
(3, 4, 78.00);


-- Insert data into the `fees` table (depends on `feetype`, `userrole`)
INSERT INTO fees (fee_type_id, student_id, amount, admin_id) VALUES
(1, 4, 50.00, 1),
(2, 4, 100.00, 1),
(3, 4, 30.00, 1);

-- Insert data into the `feetype` table (depends on `fees`)
INSERT INTO feetype (student_id, type_description, amount) VALUES
(4, 'FieldTripFees', 50.00),
(4, 'TextBooks', 100.00),
(4, 'LabFees', 30.00);


-- Insert data into the `permissions` table (depends on `userrole`)
INSERT INTO permissions (user_role_id, table_name, access_level) VALUES
(1, 'registereduser', 'admin'),
(2, 'subject', 'write'),
(3, 'enrollment', 'read');

-- Insert data into the `section` table (depends on `course`)
INSERT INTO section (section_num, description, parent_id, course_id) VALUES
(101, 'Algebra Basics', NULL, 1),
(102, 'Physics Fundamentals', NULL, 2),
(103, 'Historical Events', NULL, 3);





-- Insert data into the `timeslot` table (depends on `classschedule`, `subject`)
INSERT INTO timeslot (class_id, start_time, end_time, subject_id) VALUES
(1, '08:00:00', '09:30:00', 1),
(2, '10:00:00', '11:30:00', 2),
(3, '13:00:00', '14:30:00', 3);


-- classschedule
--  `course_id` INT NULL DEFAULT NULL,
--   `subject_id` INT NULL DEFAULT NULL,
--   `time_slot_id` INT NULL DEFAULT NULL,
--   `date` DATE NULL DEFAULT NULL,

INSERT INTO classschedule(subject_id, time_slot_id, date) VALUES
(1, 1, '2024-07-10'),
(2, 2, '2024-07-12'),
(3, 3, '2024-06-11');

-- Insert data into the `totalgrade` table (depends on `assignment`, `exam`)
-- INSERT INTO totalgrade (student_id, course_id, final_grade_value, date_calculated, exam_id, assignment_id) VALUES
-- (4, 1, 88.50, '2024-07-10', 1, 1),
-- (4, 2, 91.00, '2024-07-20', 2, 2),
-- (4, 3, 76.50, '2024-07-30', 3, 3);
