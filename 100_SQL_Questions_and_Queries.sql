-- HR Database SQL Capstone Project
-- 100 SQL Practice & Business Questions

Select * from Regions;
Select * from Countries;
Select * from Locations;
Select * from Departments;
Select * from Jobs;
Select * from Employees;
Select * from Job_history;
Select * from Job_Grades;
==========================================================================================================================================
1-20: BASIC JOINS
==========================================================================================================================================
-- 1. List all employees with their department names

SELECT e.First_Name, e.last_Name, d.department_Name 
FROM employees e JOIN departments d
ON e.department_id = d.department_id;

-- 2. Show employees and their manager names (self-join)

SELECT e.first_name||' '||e.last_name as "Employee Name", m.first_name||' '||m.last_name as "Manager Name" 
FROM employees e LEFT JOIN employees m 
ON e.manager_id = m.employee_id;

-- 3. Find employees and their city of work

Select e.first_Name ||' '||e.last_Name as "Employee_Name", L.City as "City"
FROM Employees e JOIN departments d ON e.department_id = d.department_id
JOIN Locations L ON d.Location_id = L.Location_id;

-- 4. List departments with no employees

SELECT d.department_Name FROM departments d LEFT JOIN employees e
ON d.department_id = e.department_id
WHERE e.employee_id IS NULL;

-- 5. Show jobs with employee count per job

SELECT J.Job_title, COUNT(e.employee_id) as "Employee Count" 
FROM Jobs J JOIN Employees e
ON j.job_id = e.job_id
GROUP BY J.Job_title; 

-- 6. Find employees earning more than their manager

SELECT e.first_Name as "Employee_Name", e.Salary as "Employee Salary", m.Salary as "Manager Salary"
FROM Employees e JOIN Employees m
ON e.manager_id = m.employee_id
WHERE e.salary > m.salary;

-- 7. List employees who work in India

SELECT e.first_Name, e.Last_Name, c.country_Name FROM Employees e JOIN Departments d
ON e.department_id = d.department_id
JOIN Locations l 
ON d.Location_id = l.Location_id
JOIN Countries c
ON l.country_id = c.country_id
WHERE c.country_name = 'India';

-- 8. Show department managers and their department names

SELECT DISTINCT m.first_name||' '||m.last_name as Manager_Name, d.department_name 
FROM employees m JOIN departments d 
ON m.employee_id = d.manager_id 
WHERE d.manager_id IS NOT NULL;

-- 9. Find employees hired after 2005 with job titles
SELECT e.first_name, e.last_name, j.job_title 
FROM employees e JOIN jobs j 
ON e.job_id = j.job_id 
WHERE e.hire_date > DATE'2005-01-01';

-- 10. List all locations with department names (if any)
SELECT l.city, d.department_name 
FROM locations l LEFT JOIN departments d 
ON l.location_id = d.location_id;

-- 11. Show employees with commission and their total earnings
SELECT e.last_name, e.salary + NVL(e.salary*e.commission_pct,0) as Total_earnings 
FROM employees e 
WHERE e.commission_pct IS NOT NULL;

-- 12. Find job history records with current job comparison
 SELECT jh.employee_id, jh.job_id old_job, e.job_id current_job 
FROM job_history jh JOIN employees e 
ON jh.employee_id = e.employee_id 
WHERE jh.end_date < SYSDATE;

-- 13. List regions → countries → cities hierarchy
SELECT r.region_name, c.country_name, l.city 
FROM regions r JOIN countries c 
ON r.region_id = c.region_id 
JOIN locations l 
ON c.country_id = l.country_id;

-- 14. Show employees and their job grade level
SELECT e.last_name, e.salary, g.grade_level 
FROM employees e JOIN job_grades g 
ON e.salary BETWEEN g.lowest_sal AND g.highest_sal;

-- 15. Find departments in Europe only
SELECT DISTINCT d.department_name FROM departments d JOIN locations l 
ON d.location_id = l.location_id 
JOIN countries c 
ON l.country_id = c.country_id 
JOIN regions r 
ON c.region_id = r.region_id 
WHERE r.region_name = 'Europe';

-- 16. List employees who changed jobs (job_history vs current)
SELECT DISTINCT e.employee_id, e.last_name 
FROM employees e JOIN job_history jh 
ON e.employee_id = jh.employee_id 
WHERE e.job_id != jh.job_id;

-- 17. Show employees with highest salary per department
SELECT e1.* FROM employees e1 JOIN (SELECT department_id, MAX(salary) max_sal FROM
employees GROUP BY department_id) e2 
ON e1.department_id = e2.department_id AND e1.salary = e2.max_sal;

-- 18. Find employees reporting to Steven King directly/indirectly
SELECT e.* FROM employees e START WITH e.manager_id = 100 CONNECT BY PRIOR
employee_id = manager_id;

-- 19. List jobs with min/max salary and actual salaries
SELECT j.job_title, j.min_salary, j.max_salary, AVG(e.salary) avg_salary 
FROM jobs j LEFT JOIN employees e 
ON j.job_id = e.job_id 
GROUP BY j.job_title, j.min_salary, j.max_salary;

-- 20. Show employees working in departments with >5 employees
SELECT d.department_name FROM departments d JOIN employees e 
ON d.department_id = e.department_id 
GROUP BY d.department_name 
HAVING COUNT(e.employee_id) > 5;

-- ==============================================================================================
-- 21-35: SUBQUERIES
=================================================================================================

-- 21. Find 2nd highest salary employee
SELECT MIN(salary) 
FROM (SELECT DISTINCT salary FROM employees ORDER BY salary DESC)
WHERE ROWNUM <= 2;

-- 22. Show employees earning above department average
SELECT e.* FROM employees e WHERE e.salary > (SELECT AVG(salary) FROM employees e2
WHERE e2.department_id = e.department_id);


-- 23. List departments with salary > company average
SELECT department_id FROM employees 
GROUP BY department_id HAVING AVG(salary) >
(SELECT AVG(salary) FROM employees);

-- 24. Find employees who earn more than all IT department employees
SELECT e.* FROM employees e 
WHERE e.salary > ALL (SELECT salary FROM employees e2 JOIN departments d 
ON e2.department_id = d.department_id 
WHERE d.department_name = 'IT');

-- 25. Show top 3 highest paid employees per department
SELECT * FROM (SELECT e.*, DENSE_RANK() OVER 
(PARTITION BY department_id 
ORDER BY salary DESC) as Rank 
FROM employees e) WHERE Rank <= 3;

-- 26. Find employees hired on same day as their manager
SELECT e.* FROM employees e 
WHERE e.hire_date = (SELECT hire_date FROM employees
WHERE employee_id = e.manager_id);

-- 27. List jobs never assigned to any employee
SELECT job_id FROM jobs 
WHERE job_id NOT IN (SELECT DISTINCT job_id FROM employees
WHERE job_id IS NOT NULL);

-- 28. Show employees with salary in job grade range
SELECT e.* FROM employees e 
WHERE e.salary IN (SELECT salary FROM job_grades
WHERE grade_level = (SELECT grade_level FROM job_grades g1 
WHERE e.salary BETWEEN g1.lowest_sal AND g1.highest_sal));

-- 29. Find departments with no job history records
SELECT d.department_id FROM departments d 
WHERE d.department_id NOT IN (SELECT DISTINCT department_id 
FROM job_history 
WHERE department_id IS NOT NULL);

-- 30. List employees who have job history records
SELECT DISTINCT e.* FROM employees e
WHERE e.employee_id IN (SELECT employee_id FROM job_history);

-- 31. Show cities with no departments located
SELECT city FROM locations 
WHERE location_id NOT IN (SELECT location_id FROM departments 
WHERE location_id IS NOT NULL);

-- 32. Find employees earning exactly average salary
SELECT * FROM employees 
WHERE salary = (SELECT AVG(salary) FROM employees);

-- 33. List managers who manage >5 employees
SELECT m.* FROM employees m 
JOIN (SELECT manager_id, COUNT(*) cnt FROM employees
WHERE manager_id IS NOT NULL 
GROUP BY manager_id 
HAVING COUNT(*) > 5) mgr 
ON m.employee_id = mgr.manager_id;

-- 34. Show regions with no countries
SELECT * FROM regions 
WHERE region_id NOT IN (SELECT region_id FROM countries);

-- 35. Find employees whose salary matches someone else's
SELECT * FROM employees e1 
WHERE salary IN (SELECT salary FROM employees e2 
WHERE e1.employee_id != e2.employee_id);

-- ==============================================================================================
-- 36-50: WINDOW FUNCTIONS
=================================================================================================

-- 36. Show employee rank by salary globally
SELECT employee_id, last_name, salary, RANK() 
OVER (ORDER BY salary DESC)
salary_rank FROM employees;

-- 37. Rank employees by salary within each department
SELECT employee_id, last_name, department_id, salary, RANK() 
OVER (PARTITION BY department_id ORDER BY salary DESC) dept_rank FROM employees;

-- 38. Show running total of salaries by hire date
SELECT employee_id, hire_date, salary, SUM(salary) 
OVER (ORDER BY hire_date ROWS UNBOUNDED PRECEDING) running_total 
FROM employees ORDER BY hire_date;

-- 39. Find salary difference from department average
SELECT employee_id, department_id, salary, salary - AVG(salary) 
OVER (PARTITION BY department_id) salary_vs_dept_avg FROM employees;

-- 40. Show top 3 salaries per job title (DENSE_RANK)
SELECT * FROM (SELECT job_id, salary, DENSE_RANK() 
OVER (PARTITION BY job_id 
ORDER BY salary DESC) rnk 
FROM employees) WHERE rnk <= 3;

-- 41. Calculate year-to-date salary per employee
SELECT employee_id, hire_date, salary * (SYSDATE - hire_date)/365 ytd_salary 
FROM employees;

-- 42. Find employees with consecutive job changes
SELECT DISTINCT employee_id 
FROM (SELECT employee_id, job_id, LAG(job_id) 
OVER (PARTITION BY employee_id
ORDER BY start_date) AS previous_job
FROM job_history)
WHERE previous_job IS NOT NULL AND previous_job <> job_id;

-- 43. Show salary percentile within departments
SELECT employee_id, salary, NTILE(4) 
OVER (PARTITION BY department_id 
ORDER BY salary) salary_quartile FROM employees;

-- 44. List employees who have changed jobs more than once
SELECT employee_id, COUNT(*) AS job_changes
FROM job_history
GROUP BY employee_id
HAVING COUNT(*) > 1;

-- 45. Show department-wise salary distribution (NTILE)
SELECT employee_id, department_id, salary, NTILE(5) 
OVER (PARTITION BY department_id
ORDER BY salary) salary_bucket FROM employees;

-- 46. Find first/last employee hired per department
SELECT FIRST_VALUE(employee_id) 
OVER (PARTITION BY department_id ORDER BY hire_date)
first_hired, LAST_VALUE(employee_id) 
OVER (PARTITION BY department_id ORDER BY hire_date 
ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) last_hired FROM employees;

-- 47. Calculate moving average salary (3-month window)
SELECT employee_id, hire_date, salary, AVG(salary) 
OVER (ORDER BY hire_date ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) moving_avg 
FROM employees ORDER BY hire_date;

-- 48. Show employees above/below department median salary
SELECT employee_id, department_id, salary, CASE WHEN salary > PERCENTILE_CONT(0.5)
WITHIN GROUP (ORDER BY salary)
OVER (PARTITION BY department_id)
THEN 'Above Median' ELSE 'Below Median'
END AS status FROM employees;

-- 49. Rank employees by total compensation (salary+commission)
SELECT employee_id, salary + NVL(salary*commission_pct,0) total_comp, RANK() 
OVER (ORDER BY salary + NVL(salary*commission_pct,0) DESC) comp_rank FROM employees;

-- 50. Find salary gaps between consecutive employees
SELECT employee_id, salary, salary - LAG(salary) 
OVER (ORDER BY salary) AS salary_gap FROM employees 
ORDER BY salary;

=================================================================================================
-- 51-65: STRING & NUMBER FUNCTIONS
=================================================================================================

-- 51. Format employee names as "LAST, FIRST"
SELECT UPPER(last_name)||', '||first_name AS formatted_name FROM employees;

-- 52. Extract year from hire_date
SELECT EXTRACT(YEAR FROM hire_date) hire_year FROM employees;

-- 53. Show employee full names in uppercase
SELECT UPPER(first_name||' '||last_name) full_name FROM employees;

-- 54. Find emails ending with company domain
SELECT email FROM employees 
WHERE REGEXP_LIKE(email, '@company\.com$');
 
-- 55. Calculate employee age from hire_date
SELECT last_name, ROUND((SYSDATE - hire_date)/365) years_employed FROM employees;

-- 56. Show phone numbers formatted as XXX-XXX-XXXX
SELECT REGEXP_REPLACE(phone_number, '(\d{3})(\d{3})(\d{4})', '\\1-\\2-\\3') 
FROM employees WHERE phone_number IS NOT NULL;

-- 57. Concatenate city, state, country
SELECT l.city||', '||l.state_province||', '||c.country_name full_address 
FROM locations l JOIN countries c 
ON l.country_id = c.country_id;

-- 58. Find employees whose name contains "an"
SELECT last_name FROM employees 
WHERE UPPER(last_name) LIKE '%AN%';

-- 59. Calculate total years worked per employee
SELECT employee_id, ROUND((SYSDATE - hire_date)/365.25, 1) years_worked 
FROM employees ORDER BY years_worked DESC;

-- 60. Show salary with currency formatting
SELECT TO_CHAR(salary, '$99,999.00') formatted_salary FROM employees;

-- 61. Extract numeric salary from text
SELECT REGEXP_REPLACE(salary, '[^0-9.]', '') numeric_salary FROM employees;

-- 62. Find employees with names >15 characters
SELECT last_name FROM employees WHERE LENGTH(last_name) > 15;

-- 63. Generate employee ID as DEPT_EMP001 format
SELECT 'DEPT_'||LPAD(department_id,3,'0')||'_'||LPAD(employee_id,3,'0') emp_id 
FROM employees;

-- 64. Calculate commission as percentage of salary
SELECT employee_id, salary, commission_pct, salary*commission_pct commission_amount
FROM employees WHERE commission_pct IS NOT NULL;

-- 65. Show department names padded to 20 chars
SELECT RPAD(department_name, 20, '*') padded_dept FROM departments;

=================================================================================================
-- 66-80: REGEX & LOGICAL OPERATORS
=================================================================================================

-- 66. Find emails with valid format (regex)
SELECT email FROM employees 
WHERE REGEXP_LIKE
(email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');

-- 67. Show employees whose name starts with vowel
SELECT first_name FROM employees 
WHERE REGEXP_LIKE(first_name, '^[AEIOUaeiou]');

-- 68. List phone numbers with country code +91
SELECT phone_number FROM employees 
WHERE phone_number LIKE '+91%';

-- 69. Find cities matching pattern "San*"
SELECT city FROM locations WHERE city LIKE 'San%';

-- 70. Show employees NOT working in US/UK
SELECT e.* FROM employees e JOIN departments d 
ON e.department_id = d.department_id
JOIN locations l ON d.location_id = l.location_id 
JOIN countries c ON l.country_id = c.country_id 
WHERE c.country_id NOT IN ('US','UK');

-- 71. List jobs with "Manager" OR "Director" in title
SELECT job_title FROM jobs WHERE UPPER(job_title) 
LIKE '%MANAGER%' OR UPPER(job_title) LIKE '%DIRECTOR%';

-- 72. Find employees with salary BETWEEN 5000-15000
SELECT * FROM employees WHERE salary BETWEEN 5000 AND 15000;

-- 73. Show records where city IS NULL or empty
SELECT city FROM locations WHERE city IS NULL OR TRIM(city) = '';

-- 74. List employees whose name contains AND "a" OR "e"
SELECT first_name, last_name FROM employees 
WHERE last_name LIKE '%a%' OR last_name LIKE '%e%';

-- 75. Find job titles matching pattern "IT_*"
SELECT job_title FROM jobs WHERE REGEXP_LIKE(job_id, '^IT_');

-- 76. Show departments where manager_id IS NULL
 SELECT department_name FROM departments WHERE manager_id IS NULL;

-- 77. List employees with commission > salary*0.1
SELECT employee_id FROM employees WHERE commission_pct > 0.1;

-- 78. Find cities NOT LIKE 'San%'
SELECT city FROM locations WHERE city NOT LIKE 'San%';

-- 79. Show employees hired 2005 AND salary >10000
SELECT * FROM employees WHERE hire_date >= DATE'2005-01-01' AND salary > 10000;

-- 80. List records where ANY condition matches
SELECT * FROM employees WHERE department_id = 90 OR job_id = 'IT_PROG';

=================================================================================================
-- 81-100: REAL-TIME INTERVIEW QUESTIONS
=================================================================================================

-- 81. Find duplicate emails (if any exist)
SELECT email, COUNT(*) FROM employees GROUP BY email HAVING COUNT(*) > 1;

-- 82. Show employees with >10% salary growth in job history
SELECT jh.employee_id FROM job_history jh 
JOIN employees e ON jh.employee_id = e.employee_id 
WHERE e.salary > (SELECT salary FROM employees e2 JOIN job_history jh2 
ON e2.employee_id = jh2.employee_id 
WHERE jh2.employee_id = jh.employee_id AND jh2.end_date < jh.start_date 
ORDER BY jh2.end_date DESC FETCH FIRST 1 ROW ONLY) * 1.1;

-- 83. Calculate department wise salary variance
SELECT department_id, VARIANCE(salary) FROM employees 
GROUP BY department_id ORDER BY VARIANCE(salary) DESC;

-- 84. Pivot job titles to columns with employee count
SELECT * FROM (SELECT job_id, COUNT(*) FROM employees 
GROUP BY job_id) PIVOT(COUNT(*) FOR job_id 
IN ('AD_PRES' pres, 'IT_PROG' prog, 'SA_REP' sales));

-- 85. Find employees who worked in multiple countries
SELECT DISTINCT e.employee_id FROM employees e 
JOIN departments d ON e.department_id = d.department_id 
JOIN locations l ON d.location_id = l.location_id 
JOIN job_history jh ON e.employee_id = jh.employee_id 
JOIN departments dh ON jh.department_id = dh.department_id 
JOIN locations lh ON dh.location_id = lh.location_id 
WHERE l.country_id != lh.country_id;

-- 86. Show top 10% earners globally
SELECT * FROM (SELECT salary, PERCENT_RANK() 
OVER (ORDER BY salary) pct FROM employees) WHERE pct <= 0.1;

-- 87. Calculate 90-day retention rate by department
SELECT department_id, 
COUNT(CASE WHEN SYSDATE - hire_date <= 90 THEN 1 END)*100/COUNT(*) retention_rate 
FROM employees GROUP BY department_id;

-- 88. Find employees with gaps in employment >6 months
SELECT employee_id FROM (SELECT employee_id, start_date,LAG(end_date) 
OVER (PARTITION BY employee_id
ORDER BY start_date) AS prev_end FROM job_history)
WHERE start_date - prev_end > 180;

-- 89. Show correlation between salary and hire year
SELECT CORR(EXTRACT(YEAR FROM hire_date), salary) FROM employees;

-- 90. Generate employee performance bands (A/B/C grades)
SELECT CORR(EXTRACT(YEAR FROM hire_date), salary) FROM employees;

-- 91. Find departments with highest salary dispersion
SELECT department_id, STDDEV(salary)/AVG(salary) dispersion 
FROM employees GROUP BY department_id ORDER BY dispersion DESC;

-- 92. Show employees in the top 20% by salary within each department.
SELECT * FROM (SELECT e.*,PERCENT_RANK() 
OVER (PARTITION BY department_id
ORDER BY salary DESC) AS salary_percent_rank FROM employees e)
WHERE salary_percent_rank <= 0.20
ORDER BY department_id, salary DESC;

-- 93. Find employees who have held more than one job.
SELECT employee_id, COUNT(DISTINCT job_id) AS job_count
FROM job_history GROUP BY employee_id
HAVING COUNT(DISTINCT job_id) > 1;

-- 94. Find employees violating job salary range
SELECT e.* FROM employees e JOIN jobs j 
ON e.job_id = j.job_id 
WHERE e.salary < j.min_salary OR e.salary > j.max_salary;

-- 95. Show cross-tab of departments by regions
SELECT r.region_name, d.department_name, COUNT(e.employee_id) emp_count 
FROM regions r JOIN countries c ON r.region_id = c.region_id 
JOIN locations l ON c.country_id = l.country_id 
JOIN departments d ON l.location_id = d.location_id 
LEFT JOIN employees e ON d.department_id = e.department_id 
GROUP BY r.region_name, d.department_name;

-- 96. Calculate employee turnover rate by job
SELECT j.job_title, COUNT(DISTINCT CASE WHEN jh.end_date IS NOT NULL THEN
e.employee_id END)*100/COUNT(DISTINCT e.employee_id) turnover_rate FROM jobs j 
JOIN employees e ON j.job_id = e.job_id 
LEFT JOIN job_history jh ON e.employee_id = jh.employee_id 
GROUP BY j.job_title;

-- 97. Find employees with inconsistent department history
SELECT DISTINCT e.employee_id FROM employees e 
JOIN job_history jh ON e.employee_id = jh.employee_id 
WHERE e.department_id != jh.department_id;

-- 98. Show salary compression issues (new hires vs seniors)
SELECT e1.last_name new_hire, e2.last_name senior, 
e1.salary new_salary, e2.salary senior_salary 
FROM employees e1 
JOIN employees e2 ON e1.department_id = e2.department_id
WHERE e1.hire_date > e2.hire_date AND e1.salary > e2.salary;

-- 99. Generate cohort analysis by hire month
SELECT TRUNC(hire_date, 'MM') hire_month, COUNT(*) cohort_size, 
AVG(CASE WHEN SYSDATE - hire_date <= 365 THEN 1 ELSE 0 END)*100 retention 
FROM employees GROUP BY TRUNC(hire_date, 'MM') 
ORDER BY hire_month;

-- 100. Find employees in the bottom 10% by salary
SELECT * FROM (SELECT e.*, RANK() OVER (ORDER BY salary ASC) AS perf_rank,
COUNT(*) OVER () AS total_employees FROM employees e)
WHERE perf_rank <= total_employees * 0.10;

==========================================================================================================================================
