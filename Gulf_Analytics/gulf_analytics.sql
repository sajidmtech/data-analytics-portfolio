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
