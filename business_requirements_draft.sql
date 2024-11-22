-- Step 1: Alter the userrole table to add an expires column for role expiry dates.
ALTER TABLE userrole 
ADD COLUMN expires DATE NULL;

-- Step 2: Create the AssignUserRole procedure to assign a role with an expiry date.
DELIMITER $$

CREATE PROCEDURE AssignUserRole(IN p_user_id INT, IN p_role_id INT, IN p_expires DATE)
BEGIN
    DECLARE role_exists INT;

    -- Check if the user already has a role assigned
    SELECT COUNT(*) INTO role_exists
    FROM userrole
    WHERE user_id = p_user_id;

    -- If a role exists, update it; otherwise, insert a new role assignment
    IF role_exists > 0 THEN
        UPDATE userrole
        SET role_id = p_role_id, expires = p_expires
        WHERE user_id = p_user_id;
    ELSE
        INSERT INTO userrole (user_id, role_id, expires)
        VALUES (p_user_id, p_role_id, p_expires);
    END IF;
END$$

DELIMITER ;


-- Step 3: Create a trigger to prevent assigning an already expired role.
DELIMITER $$
CREATE TRIGGER RevokeExpiredRole
BEFORE INSERT ON userrole
FOR EACH ROW
BEGIN
    DECLARE v_today DATE;
    SET v_today = CURDATE();

    -- Check if the role assignment has already expired
    IF NEW.expires < v_today THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot assign an expired role to the user.';
    END IF;
END$$
DELIMITER ;

-- Step 4: Create the IsUserRoleActive function to check if a user's role is still active.
DELIMITER $$
CREATE FUNCTION IsUserRoleActive(p_user_id INT, p_role_id INT)
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    DECLARE v_is_active BOOLEAN;

    -- Check if the user's role is still active
    SELECT COUNT(*) > 0 INTO v_is_active
    FROM userrole
    WHERE user_id = p_user_id
    AND role_id = p_role_id
    AND expires >= CURDATE();

    RETURN v_is_active;
END$$
DELIMITER ;

-- Step 5: Create the AccessFeature procedure to check if the user has an active role before accessing a feature.
DELIMITER $$
CREATE PROCEDURE AccessFeature(IN p_user_id INT, IN p_role_id INT)
BEGIN
    DECLARE v_is_active BOOLEAN;

    -- Check if the user's role is active
    SET v_is_active = IsUserRoleActive(p_user_id, p_role_id);

    IF v_is_active THEN
        -- Proceed with the feature access
        SELECT 'Access Granted' AS Status;
    ELSE
        -- Deny access
        SELECT 'Access Denied: Role has expired or is not assigned' AS Status;
    END IF;
END$$
DELIMITER ;

-- Step 6: Example usage of the procedures and function.

-- Assign a role to a user with an expiry date
CALL AssignUserRole(1, 1, '2025-01-01');  -- Assign Admin role to user 1

-- Try accessing a feature
 -- CALL AccessFeature(1, 1);  -- Check access for user 1's Admin role
-- CALL AccessFeature(1, 2);  -- Check access for user 1's Admin role

DELIMITER $$

CREATE FUNCTION CalculateAttendanceRate(p_student_id INT, p_start_date DATE, p_end_date DATE)
RETURNS DECIMAL(5,2)
DETERMINISTIC
BEGIN
    DECLARE total_days INT DEFAULT 0;
    DECLARE present_days INT DEFAULT 0;
    DECLARE attendance_rate DECIMAL(5,2);

    -- Count total days
    SELECT COUNT(*) INTO total_days 
    FROM attendance 
    WHERE student_id = p_student_id 
      AND date BETWEEN p_start_date AND p_end_date;

    -- Count days marked as 'Present'
    SELECT COUNT(*) INTO present_days 
    FROM attendance 
    WHERE student_id = p_student_id 
      AND status = 'Present' 
      AND date BETWEEN p_start_date AND p_end_date;

    -- Calculate attendance rate, checking for division by zero
    IF total_days = 0 THEN
        SET attendance_rate = 0;
    ELSE
        SET attendance_rate = (present_days / total_days) * 100;
    END IF;

    RETURN attendance_rate;
END$$

DELIMITER ;



-- Step 2 notify Admin of all low attendance rates for further action on administration end. 
DELIMITER $$

CREATE PROCEDURE NotifyAttendanceRate(
    IN p_student_id INT,
    IN p_start_date DATE,
    IN p_end_date DATE
)
BEGIN
    DECLARE v_attendance_rate DECIMAL(5,2);
    DECLARE v_message VARCHAR(255);
    DECLARE v_user_id INT;

    -- Calculate the attendance rate using the function
    SET v_attendance_rate = CalculateAttendanceRate(p_student_id, p_start_date, p_end_date);
    IF v_attendance_rate < 70 THEN
    -- Format the message to display the attendance rate
      SET v_message = CONCAT('Your attendance rate from ', DATE_FORMAT(p_start_date, '%Y-%m-%d'), 
                           ' to ', DATE_FORMAT(p_end_date, '%Y-%m-%d'), 
                           ' is ', FORMAT(v_attendance_rate, 2), '%.');

    -- grab user_id for the student
      SELECT student_id INTO v_user_id FROM attendance WHERE student_id = p_student_id LIMIT 1;

    -- Insert the notification with the attendance rate message
      INSERT INTO notifications (user_id, message, created_at)
      VALUES (v_user_id, v_message, CURDATE());
	END IF;
END$$




DELIMITER ;


-- testing notification of attendence

-- CALL NotifyAttendanceRate(4, '2024-01-01', '2024-12-31');
-- CALL NotifyAttendanceRate(3, '2024-01-01', '2024-12-31');


DELIMITER $$

CREATE PROCEDURE CalculateAndStoreAllTotalGrades()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_student_id INT;
    DECLARE v_total_assignment_points DECIMAL(10,2) DEFAULT 0;
    DECLARE v_total_exam_points DECIMAL(10,2) DEFAULT 0;
    DECLARE v_earned_assignment_points DECIMAL(10,2) DEFAULT 0;
    DECLARE v_earned_exam_points DECIMAL(10,2) DEFAULT 0;
    DECLARE v_final_grade_value DECIMAL(5,2);
    DECLARE v_total_points DECIMAL(10,2) DEFAULT 0;
    DECLARE v_points_earned DECIMAL(10,2) DEFAULT 0;

    -- Cursor to iterate over each student
    DECLARE cur CURSOR FOR 
        SELECT DISTINCT student_id
        FROM assignmentgrade
        UNION
        SELECT DISTINCT student_id
        FROM examgrade;

    -- Handle for end of cursor
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur;

    -- Loop through each student
    read_loop: LOOP
        FETCH cur INTO v_student_id;
        IF done THEN
            LEAVE read_loop;
        END IF;

        -- Reset point totals
        SET v_total_assignment_points = 0;
        SET v_earned_assignment_points = 0;
        SET v_total_exam_points = 0;
        SET v_earned_exam_points = 0;
        SET v_total_points = 0;
        SET v_points_earned = 0;

        -- Calculate total possible points and points earned for assignments
        SELECT IFNULL(SUM(total_grade_value), 0), IFNULL(SUM(grade_value), 0)
        INTO v_total_assignment_points, v_earned_assignment_points
        FROM assignmentgrade
        WHERE student_id = v_student_id;

        -- Calculate total possible points and points earned for exams
        SELECT IFNULL(COUNT(*), 0) * 100, IFNULL(SUM(grade_value), 0)
        INTO v_total_exam_points, v_earned_exam_points
        FROM examgrade
        WHERE student_id = v_student_id;

        -- Calculate total points and points earned
        SET v_total_points = v_total_assignment_points + v_total_exam_points;
        SET v_points_earned = v_earned_assignment_points + v_earned_exam_points;

        -- Calculate the final grade as a percentage
        IF v_total_points > 0 THEN
            SET v_final_grade_value = (v_points_earned / v_total_points) * 100;
        ELSE
            SET v_final_grade_value = 0;  -- Avoid division by zero if there are no points
        END IF;

        -- Insert the result into the totalgrade table, replacing any previous record
        INSERT INTO totalgrade (student_id, final_grade_value, date_calculated)
        VALUES (v_student_id, v_final_grade_value, NOW())
        ON DUPLICATE KEY UPDATE 
            final_grade_value = v_final_grade_value, 
            date_calculated = NOW();
    END LOOP;

    CLOSE cur;
END$$

DELIMITER ;


-- C:\Users\coleb\Desktop\business_requirements_draft.sql


-- DELIMITER ;


