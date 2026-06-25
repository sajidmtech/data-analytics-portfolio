-- ============================================
-- IBM HR ANALYTICS PROJECT
-- Tool: MySQL | Database: ibm_hr
-- Dataset: IBM HR Analytics (Kaggle, 1,470 rows)
-- ============================================


-- ============================================
-- SETUP
-- ============================================

CREATE DATABASE ibm_hr;
USE ibm_hr;


-- ============================================
-- QUESTION 1: Which Departments Have The
--             Highest Performing Employees?
-- ============================================

-- Retrieved overall performance overview by department
SELECT Department,
       COUNT(*) AS headcount,
       ROUND(AVG(MonthlyIncome), 0) AS avg_salary,
       ROUND(AVG(PerformanceRating), 2) AS avg_performance
FROM employees
GROUP BY Department
ORDER BY avg_performance DESC;

-- Drilled deeper into performance by job role
SELECT JobRole,
       COUNT(*) AS headcount,
       ROUND(AVG(PerformanceRating), 2) AS avg_performance,
       ROUND(AVG(MonthlyIncome), 0) AS avg_salary
FROM employees
GROUP BY JobRole
ORDER BY avg_performance DESC;

-- Combined department and job role to identify performance patterns
SELECT Department,
       JobRole,
       COUNT(*) AS headcount,
       ROUND(AVG(PerformanceRating), 2) AS avg_performance
FROM employees
GROUP BY Department, JobRole
ORDER BY Department, avg_performance DESC;

-- Isolated high performers (rating of 4) by department and job role
SELECT Department,
       JobRole,
       COUNT(*) AS high_performers
FROM employees
WHERE PerformanceRating = 4
GROUP BY Department, JobRole
ORDER BY high_performers DESC;


-- ============================================
-- QUESTION 2: Does Overtime Affect
--             Attrition Rates?
-- ============================================

-- Retrieved basic headcount split by overtime status
SELECT OverTime,
       COUNT(*) AS headcount
FROM employees
GROUP BY OverTime;

-- Compared performance ratings between overtime and non-overtime workers
SELECT OverTime,
       COUNT(*) AS headcount,
       ROUND(AVG(PerformanceRating), 2) AS avg_performance
FROM employees
GROUP BY OverTime
ORDER BY avg_performance DESC;

-- Compared income and performance between overtime and non-overtime workers
SELECT OverTime,
       COUNT(*) AS headcount,
       ROUND(AVG(PerformanceRating), 2) AS avg_performance,
       ROUND(AVG(MonthlyIncome), 0) AS avg_income
FROM employees
GROUP BY OverTime
ORDER BY avg_income DESC;

-- Broke down headcount, performance and income by department and overtime
SELECT Department,
       OverTime,
       COUNT(*) AS headcount,
       ROUND(AVG(PerformanceRating), 2) AS avg_performance,
       ROUND(AVG(MonthlyIncome), 0) AS avg_income
FROM employees
GROUP BY Department, OverTime
ORDER BY Department, avg_income DESC;

-- Labelled employees by overtime status and performance category using CASE WHEN
SELECT OverTime,
       CASE
           WHEN PerformanceRating = 4 THEN 'High Performer'
           WHEN PerformanceRating = 3 THEN 'Average Performer'
           WHEN PerformanceRating <= 2 THEN 'Low Performer'
       END AS performance_category,
       COUNT(*) AS headcount
FROM employees
GROUP BY OverTime, performance_category
ORDER BY OverTime, headcount DESC;

-- Checked whether overtime workers leave at a higher rate
SELECT OverTime,
       Attrition,
       COUNT(*) AS headcount
FROM employees
GROUP BY OverTime, Attrition
ORDER BY OverTime;

-- Calculated estimated replacement cost for departed employees by overtime status
SELECT OverTime,
       COUNT(*) AS employees_left,
       ROUND(AVG(MonthlyIncome), 0) AS avg_income,
       ROUND(COUNT(*) * AVG(MonthlyIncome) * 6, 0) AS estimated_replacement_cost
FROM employees
WHERE Attrition = 'Yes'
GROUP BY OverTime;

-- Calculated attrition rate as a percentage for overtime vs non-overtime workers
SELECT OverTime,
       COUNT(*) AS total_employees,
       SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS employees_left,
       ROUND(SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) AS attrition_rate_percent,
       ROUND(AVG(MonthlyIncome), 0) AS avg_income,
       ROUND(COUNT(*) * AVG(MonthlyIncome) * 6, 0) AS estimated_replacement_cost
FROM employees
GROUP BY OverTime;

-- Broke down attrition rate by department and overtime status
SELECT Department,
       OverTime,
       COUNT(*) AS total_employees,
       SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS employees_left,
       ROUND(SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) AS attrition_rate_percent
FROM employees
GROUP BY Department, OverTime
ORDER BY Department, attrition_rate_percent DESC;


-- ============================================
-- QUESTION 3: Are High Performers
--             Compensated Fairly?
-- ============================================

-- Retrieved income and salary hike overview by performance rating
SELECT PerformanceRating,
       COUNT(*) AS headcount,
       ROUND(AVG(MonthlyIncome), 0) AS avg_income,
       ROUND(AVG(PercentSalaryHike), 1) AS avg_salary_hike
FROM employees
GROUP BY PerformanceRating
ORDER BY PerformanceRating DESC;

-- Analysed whether job level influences the salary and performance relationship
SELECT JobLevel,
       COUNT(*) AS headcount,
       ROUND(AVG(MonthlyIncome), 0) AS avg_income,
       ROUND(AVG(PerformanceRating), 2) AS avg_performance
FROM employees
GROUP BY JobLevel
ORDER BY JobLevel;

-- Compared high performers vs average performers by department
SELECT Department,
       CASE
           WHEN PerformanceRating = 4 THEN 'High Performer'
           ELSE 'Average Performer'
       END AS performance_category,
       COUNT(*) AS headcount,
       ROUND(AVG(MonthlyIncome), 0) AS avg_income,
       ROUND(AVG(PercentSalaryHike), 1) AS avg_salary_hike
FROM employees
GROUP BY Department, performance_category
ORDER BY Department, avg_income DESC;

-- Confirmed whether high performers earn more despite receiving larger hikes
SELECT PerformanceRating,
       COUNT(*) AS headcount,
       ROUND(AVG(MonthlyIncome), 0) AS avg_income,
       ROUND(AVG(PercentSalaryHike), 1) AS avg_hike_percent,
       ROUND(AVG(YearsAtCompany), 1) AS avg_tenure
FROM employees
GROUP BY PerformanceRating
ORDER BY PerformanceRating DESC;

-- Flagged high performers as above or below company average pay using a subquery
SELECT EmployeeNumber,
       Department,
       MonthlyIncome,
       PerformanceRating,
       CASE
           WHEN MonthlyIncome > (SELECT AVG(MonthlyIncome) FROM employees)
           THEN 'Above Average Pay'
           ELSE 'Below Average Pay'
       END AS pay_status
FROM employees
WHERE PerformanceRating = 4
ORDER BY MonthlyIncome DESC;

-- Calculated attrition rate by performance rating to check if high performers leave more
SELECT PerformanceRating,
       COUNT(*) AS total_employees,
       SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS employees_left,
       ROUND(AVG(MonthlyIncome), 0) AS avg_income,
       ROUND(SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) AS attrition_rate
FROM employees
GROUP BY PerformanceRating
ORDER BY PerformanceRating DESC;
