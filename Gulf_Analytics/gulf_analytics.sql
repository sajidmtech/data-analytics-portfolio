CREATE DATABASE gulf_analytics
USE gulf_analytics;

-- Total headcount
SELECT COUNT(*) AS total_employees
FROM al_rashid_workforce_data

-- Headcount by country
SELECT country, COUNT(*) AS headcount
FROM al_rashid_workforce_data
GROUP BY country;

-- List all distinct departments
SELECT DISTINCT department
FROM al_rashid_workforce_data;

-- ALl nationals only, sorted by salary
SELECT employee_id, country, department, nationality_status, monthly_salary
FROM al_rashid_workforce_data
WHERE nationality_status IN ("Saudi National", "Emirati National")
ORDER BY monthly_salary DESC
LIMIT 20;

-- National headcount % by department and country
SELECT
    country,
    department,
    COUNT(*) AS total_headcount,
    SUM(CASE WHEN nationality_status IN ('Saudi National', 'Emirati National') THEN 1 ELSE 0 END) AS national_headcount,
    ROUND(
        SUM(CASE WHEN nationality_status IN ('Saudi National', 'Emirati National') THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        1
    ) AS national_pct
FROM al_rashid_workforce_data
GROUP BY country, department
ORDER BY country, national_pct ASC;

-- Flag departments below a 20% national threshold ("at risk")
SELECT
    country,
    department,
    ROUND(SUM(CASE WHEN nationality_status IN ('Saudi National', 'Emirati National') THEN 1 ELSE 0 END) * 100 / COUNT(*), 1) as national_pct
    FROM al_rashid_workforce_data
    GROUP BY country, department
    HAVING national_pct < 20
    ORDER BY national_pct ASC;

-- Average salary comparison: nationals vs expatriates by country
SELECT
    country,
    CASE
        WHEN nationality_status IN ('Saudi National', 'Emirati National') THEN 'National'
        ELSE 'Expatriate'
    END AS status_group,
    ROUND(AVG(monthly_salary), 0) AS avg_salary,
    COUNT(*) AS headcount
FROM al_rashid_workforce_data
GROUP BY country, status_group
ORDER BY country, status_group;

-- Ranking departments by national %
SELECT
    country,
    department,
    ROUND(SUM(CASE WHEN nationality_status IN ('Saudi National', 'Emirati National') THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) AS national_pct,
    RANK() OVER (PARTITION BY country ORDER BY
        SUM(CASE WHEN nationality_status IN ('Saudi National', 'Emirati National') THEN 1 ELSE 0 END) * 100.0 / COUNT(*) ASC
        ) AS rank_risk
FROM al_rashid_workforce_data
GROUP BY country,department
ORDER BY country, rank_risk

-- Compare each department national % to the company-wide average, same country
WITH dept_stats AS (
    SELECT
    country,
    department,
    ROUND(SUM(CASE WHEN nationality_status IN ('Saudi National', 'Emirati National') THEN 1 ELSE 0 END) * 100.0/ COUNT(*), 1) as national_pct
    FROM al_rashid_workforce_data
    GROUP BY country, department
)
SELECT
    country,
    department,
    national_pct,
    ROUND(AVG(national_pct) OVER (PARTITION BY country), 1) AS country_avg_pct,
    ROUND(national_pct - AVG(national_pct) OVER (PARTITION BY country), 1) AS gap_vs_avg
FROM dept_stats
ORDER BY country, gap_vs_avg ASC;

-- Salary gap ranked within each department (nationals vs expats)
WITH salary_stats AS (
    SELECT
        country,
        department,
        CASE WHEN nationality_status IN ('Saudi National', 'Emirati National') THEN 'National' ELSE 'Expatriate' END AS status_group,
        ROUND(AVG(monthly_salary), 0) AS avg_salary
    FROM al_rashid_workforce_data
    GROUP BY country, department, status_group
)
SELECT country,
       department,
       MAX(CASE WHEN status_group = 'National' THEN avg_salary END) AS national_avg_salary,
       MAX(CASE WHEN status_group = 'Expatriate' THEN avg_salary END) AS expat_avg_salary
    FROM salary_stats
GROUP BY country, department
ORDER BY country, department

-- Departments below country average, exact gap
SELECT
    w1.country,
    w1.department,
    ROUND(SUM(CASE WHEN w1.nationality_status IN ('Saudi National', 'Emirati National') THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) AS national_pct,
    (
        SELECT ROUND(AVG(sub.national_pct), 1)
        FROM (
            SELECT
                department,
                SUM(CASE WHEN nationality_status IN ('Saudi National', 'Emirati National') THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS national_pct
            FROM al_rashid_workforce_data w2
            WHERE w2.country = w1.country
            GROUP BY department
        ) sub
    ) AS country_avg_pct
FROM al_rashid_workforce_data w1
GROUP BY w1.country, w1.department
ORDER BY w1.country, national_pct ASC;


-- Is Hiring seen as better or worse over time
SELECT
    country,
    YEAR(hire_date) AS hire_date,
    COUNT(*) AS total_hired,
    SUM(CASE WHEN nationality_status iN ('Saudi National', 'Emirati National') THEN 1 ELSE 0 END) AS nationals_hired,
    ROUND(SUM(CASE WHEN nationality_status IN ('Saudi National', 'Emirati National') THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) AS pct_national_hires
FROM al_rashid_workforce_data
GROUP BY country, YEAR(hire_date)
ORDER BY country, hire_date


-- Risk score combined with headcount and compliance gap
    WITH dept_stats AS (
        SELECT
        country,
        department,
        COUNT(*) AS headcount,
        ROUND(SUM(CASE WHEN nationality_status IN ('Saudi National', 'Emirati National') THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) AS national_pct
        FROM al_rashid_workforce_data
        GROUP BY country, department
    ),
    country_avg AS (
        SELECT country, ROUND(AVG(national_pct), 1) AS avg_pct
        FROM dept_stats
        GROUP BY country
    )
    SELECT
        d.country,
        d.department,
        d.headcount,
        d.national_pct,
        c.avg_pct AS country_avg_pct,
        ROUND(d.national_pct - c.avg_pct, 1) AS gap_vs_avg,
        CASE
    WHEN d.national_pct < c.avg_pct
    THEN ROUND((c.avg_pct - d.national_pct) * d.headcount / 100.0, 0)
    ELSE 0
        END AS approx_hires_needed_to_close_gap
    FROM dept_stats d
    JOIN country_avg c ON d.country = c.country
    ORDER BY d.country, gap_vs_avg ASC;
