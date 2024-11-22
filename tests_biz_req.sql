-- CALL CalculateAndStoreAllTotalGrades();
INSERT INTO examgrade (exam_id, student_id, grade_value) VALUES
(1, 4, 85.00),
(2, 4, 90.00),
(3, 4, 78.00);
CALL CalculateAndStoreAllTotalGrades();
 SELECT * FROM totalgrade;
 
-- SELECT @total_points AS 'Total Points Possible', @points_earned AS 'Points Earned';
 -- SELECT CalculateAttendanceRate(4, '2024-11-01', '2024-11-11') AS attendance_rate;
-- CALL NotifyAdminForLowAttendance();
-- CALL NotifyAttendanceRate(4, '2024-01-01', '2024-12-31');
-- CALL NotifyAttendanceRate(4, '2024-01-01', '2024-12-31');
-- CALL NotifyAttendanceRate(3, '2024-01-01', '2024-12-31');

 -- SELECT * from notifications;
-- CALL CalculateAndStoreTotalGrade(4, 1, @total_points, @points_earned);
-- SELECT @total_points AS 'Total Points Possible', @points_earned AS 'Points Earned';

-- CALL NotifyAdminForLowAttendance();
-- SELECT * FROM notifications;


--  SELECT * FROM attendance WHERE student_id = 4 AND date BETWEEN '2024-11-01' AND '2024-11-11';
-- Count total days
-- SELECT COUNT(*) AS total_days 
-- FROM attendance 
-- WHERE student_id = 4 AND date BETWEEN '2024-11-01' AND '2024-11-11';

-- Count present days
-- SELECT COUNT(*) AS present_days 
-- FROM attendance 
-- WHERE student_id = 4 AND status = 'Present' AND date BETWEEN '2024-11-01' AND '2024-11-11';