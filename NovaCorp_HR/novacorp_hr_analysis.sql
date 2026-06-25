-- ============================================
-- NOVACORP HR ANALYTICS PROJECT
-- Tool: MySQL | Database: novacorp_hr
-- ============================================


-- ============================================
-- SETUP: Create and populate tables
-- ============================================

-- Creates the employees table
CREATE DATABASE novacorp_hr;
USE novacorp_hr;

CREATE TABLE employees (
    employee_id   INT PRIMARY KEY,
    name          VARCHAR(100),
    department    VARCHAR(50),
    job_title     VARCHAR(100),
    salary        INT,
    status        VARCHAR(20)
);

INSERT INTO employees VALUES
(1001,'Ayesha Khan','Engineering','Software Engineer',92000,'Active'),
(1002,'Rahul Mehta','Engineering','Senior Engineer',115000,'Active'),
(1003,'Priya Sharma','HR','HR Manager',78000,'Active'),
(1004,'James Okafor','Sales','Sales Executive',62000,'Active'),
(1005,'Linda Torres','Marketing','Marketing Lead',84000,'Active'),
(1006,'Vikram Nair','Engineering','Junior Engineer',68000,'Active'),
(1007,'Sophie Chen','Finance','Financial Analyst',88000,'Active'),
(1008,'Ananya Das','HR','HR Coordinator',55000,'Active'),
(1009,'Carlos Rivera','Sales','Sales Manager',97000,'Active'),
(1010,'Emily Clark','Marketing','Content Strategist',71000,'Active'),
(1011,'Arjun Patel','Finance','Senior Analyst',102000,'Active'),
(1012,'Neha Gupta','Engineering','QA Engineer',74000,'Active'),
(1013,'Daniel Kim','Sales','Sales Executive',59000,'Inactive'),
(1014,'Fatima Al-Sayed','Marketing','Digital Marketer',67000,'Active'),
(1015,'Tom Bennett','HR','Recruiter',61000,'Active');

CREATE TABLE employment_details (
    employee_id     INT PRIMARY KEY,
    hire_date       DATE,
    employment_type VARCHAR(20)
);

INSERT INTO employment_details VALUES
(1001, '2018-03-15', 'Full-time'),
(1002, '2016-07-01', 'Full-time'),
(1003, '2019-11-20', 'Full-time'),
(1004, '2021-05-10', 'Full-time'),
(1005, '2017-09-03', 'Full-time'),
(1006, '2022-01-18', 'Full-time'),
(1007, '2020-06-25', 'Full-time'),
(1008, '2023-02-14', 'Part-time'),
(1009, '2015-12-01', 'Full-time'),
(1010, '2021-08-30', 'Full-time'),
(1011, '2017-04-11', 'Full-time'),
(1012, '2022-10-05', 'Full-time'),
(1013, '2020-03-22', 'Full-time'),
(1014, '2023-06-01', 'Part-time'),
(1015, '2019-07-15', 'Full-time');

CREATE TABLE attrition (
    employee_id    INT PRIMARY KEY,
    departure_date DATE,
    reason         VARCHAR(50)
);

INSERT INTO attrition VALUES
(1013, '2024-11-15', 'Resigned'),
(1004, '2024-08-20', 'Resigned'),
(1008, '2024-06-10', 'Terminated'),
(1010, '2025-01-05', 'Resigned'),
(1006, '2024-09-30', 'Resigned');


-- ============================================
-- QUESTION 1: Who Works Here?
-- ============================================

-- Lists all employees
SELECT * FROM employees;

-- Filters to active employees only
SELECT * FROM employees
WHERE status = 'Active';

-- Retrieves active employees sorted by department and salary
SELECT *
FROM employees
WHERE status = 'Active'
ORDER BY department, salary DESC;


-- ============================================
-- QUESTION 2: What Are We Paying Per Team?
-- ============================================

-- Counts headcount and calculates average salary by department
SELECT department,
       COUNT(*) AS numofemployees,
       AVG(salary) AS avg_salary
FROM employees
WHERE status = 'Active'
GROUP BY department
ORDER BY avg_salary DESC;


-- ============================================
-- QUESTION 3: Who Has Been Here The Longest?
-- ============================================

-- Views employment details table
SELECT * FROM employment_details;

-- Calculates years of service per active employee
SELECT e.name,
       e.department,
       ed.hire_date,
       TIMESTAMPDIFF(YEAR, ed.hire_date, CURDATE()) AS years_of_service
FROM employees e
JOIN employment_details ed
    ON e.employee_id = ed.employee_id
WHERE e.status = 'Active'
ORDER BY years_of_service DESC;


-- ============================================
-- QUESTION 4: Where Is Attrition Happening?
-- ============================================

-- Views attrition table
SELECT * FROM attrition;

-- Retrieves employees who left with department and reason
SELECT e.name,
       e.department,
       a.departure_date,
       a.reason
FROM employees e
JOIN attrition a
    ON e.employee_id = a.employee_id
ORDER BY a.departure_date DESC;

-- Counts departures per department
SELECT e.department,
       COUNT(*) AS employees_left
FROM employees e
JOIN attrition a
    ON e.employee_id = a.employee_id
GROUP BY e.department;

-- Flagged each employee as Active or Left using CASE WHEN
SELECT e.name,
       e.department,
       e.salary,
       CASE
           WHEN a.employee_id IS NOT NULL THEN 'Left'
           ELSE 'Active'
       END AS current_status
FROM employees e
LEFT JOIN attrition a
    ON e.employee_id = a.employee_id
ORDER BY e.department;

-- Identified departments where more than 1 person left using a subquery
SELECT department,
       employees_left
FROM (
    SELECT e.department,
           COUNT(*) AS employees_left
    FROM employees e
    JOIN attrition a
        ON e.employee_id = a.employee_id
    GROUP BY e.department
) AS dept_attrition
WHERE employees_left > 1
ORDER BY employees_left DESC;