-- ============================================================
-- HR ATTRITION ANALYSIS
-- Author: Elizabeth
-- Tools: SQL
-- Description: Queries to investigate employee attrition patterns
--              and identify key drivers of turnover
-- ============================================================


-- ── 1. OVERALL ATTRITION SUMMARY ─────────────────────────────────────────────
SELECT
    COUNT(employee_id)                                          AS total_employees,
    SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END)         AS employees_left,
    ROUND(SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0
        / COUNT(employee_id), 2)                                AS attrition_rate_pct,
    ROUND(AVG(monthly_salary), 2)                               AS avg_salary,
    ROUND(AVG(years_at_company), 2)                             AS avg_tenure_years,
    ROUND(AVG(job_satisfaction), 2)                             AS avg_job_satisfaction
FROM hr_data;


-- ── 2. ATTRITION BY DEPARTMENT ───────────────────────────────────────────────
-- Find which departments are losing the most employees

SELECT
    department,
    COUNT(employee_id)                                          AS total_employees,
    SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END)         AS employees_left,
    ROUND(SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0
        / COUNT(employee_id), 2)                                AS attrition_rate_pct
FROM hr_data
GROUP BY department
ORDER BY attrition_rate_pct DESC;


-- ── 3. ATTRITION BY JOB ROLE ─────────────────────────────────────────────────
-- Identify specific roles with the highest turnover

SELECT
    job_role,
    department,
    COUNT(employee_id)                                          AS total_employees,
    SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END)         AS employees_left,
    ROUND(SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0
        / COUNT(employee_id), 2)                                AS attrition_rate_pct
FROM hr_data
GROUP BY job_role, department
ORDER BY attrition_rate_pct DESC;


-- ── 4. ATTRITION BY JOB SATISFACTION ─────────────────────────────────────────
-- Test the link between satisfaction and attrition

SELECT
    job_satisfaction,
    CASE job_satisfaction
        WHEN 1 THEN 'Low'
        WHEN 2 THEN 'Medium'
        WHEN 3 THEN 'High'
        WHEN 4 THEN 'Very High'
    END                                                         AS satisfaction_label,
    COUNT(employee_id)                                          AS total_employees,
    SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END)         AS employees_left,
    ROUND(SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0
        / COUNT(employee_id), 2)                                AS attrition_rate_pct
FROM hr_data
GROUP BY job_satisfaction
ORDER BY job_satisfaction;


-- ── 5. ATTRITION BY WORK LIFE BALANCE ────────────────────────────────────────
-- Examine whether poor work-life balance drives attrition

SELECT
    work_life_balance,
    CASE work_life_balance
        WHEN 1 THEN 'Bad'
        WHEN 2 THEN 'Good'
        WHEN 3 THEN 'Better'
        WHEN 4 THEN 'Best'
    END                                                         AS wlb_label,
    COUNT(employee_id)                                          AS total_employees,
    SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END)         AS employees_left,
    ROUND(SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0
        / COUNT(employee_id), 2)                                AS attrition_rate_pct
FROM hr_data
GROUP BY work_life_balance
ORDER BY work_life_balance;


-- ── 6. SALARY VS ATTRITION ────────────────────────────────────────────────────
-- Compare average salary of employees who left vs stayed

SELECT
    attrition,
    COUNT(employee_id)                  AS num_employees,
    ROUND(AVG(monthly_salary), 2)       AS avg_salary,
    ROUND(MIN(monthly_salary), 2)       AS min_salary,
    ROUND(MAX(monthly_salary), 2)       AS max_salary
FROM hr_data
GROUP BY attrition;


-- ── 7. ATTRITION BY TENURE ───────────────────────────────────────────────────
-- See if newer employees leave more than long-tenured ones

SELECT
    CASE
        WHEN years_at_company <= 2  THEN '0-2 Years'
        WHEN years_at_company <= 5  THEN '3-5 Years'
        WHEN years_at_company <= 10 THEN '6-10 Years'
        ELSE '10+ Years'
    END                                                         AS tenure_group,
    COUNT(employee_id)                                          AS total_employees,
    SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END)         AS employees_left,
    ROUND(SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0
        / COUNT(employee_id), 2)                                AS attrition_rate_pct
FROM hr_data
GROUP BY tenure_group
ORDER BY MIN(years_at_company);


-- ── 8. DISTANCE FROM HOME VS ATTRITION ───────────────────────────────────────
-- Does commute distance affect likelihood to leave?

SELECT
    CASE
        WHEN distance_from_home <= 10 THEN 'Near (0-10 km)'
        WHEN distance_from_home <= 30 THEN 'Mid (11-30 km)'
        ELSE 'Far (31+ km)'
    END                                                         AS distance_group,
    COUNT(employee_id)                                          AS total_employees,
    SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END)         AS employees_left,
    ROUND(SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0
        / COUNT(employee_id), 2)                                AS attrition_rate_pct
FROM hr_data
GROUP BY distance_group
ORDER BY MIN(distance_from_home);
