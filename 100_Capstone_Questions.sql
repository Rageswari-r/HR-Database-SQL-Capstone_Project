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

9. Find employees hired after 2005 with job titles
10. List all locations with department names (if any)
11. Show employees with commission and their total earnings
12. Find job history records with current job comparison
13. List regions → countries → cities hierarchy
14. Show employees and their job grade level
15. Find departments in Europe only
16. List employees who changed jobs (job_history vs current)
17. Show employees with highest salary per department
18. Find employees reporting to Steven King directly/indirectly
19. List jobs with min/max salary and actual salaries
20. Show employees working in departments with >5 employees
21-35: SUBQUERIES
21. Find 2nd highest salary employee
22. Show employees earning above department average
23. List departments with salary > company average
24. Find employees who earn more than all IT department employees
25. Show top 3 highest paid employees per department
26. Find employees hired on same day as their manager
27. List jobs never assigned to any employee
28. Show employees with salary in job grade range
29. Find departments with no job history records
30. List employees who have job history records
31. Show cities with no departments located
32. Find employees earning exactly average salary
33. List managers who manage >5 employees
34. Show regions with no countries
35. Find employees whose salary matches someone else's
==========================================================================================================================================
36-50: WINDOW FUNCTIONS
==========================================================================================================================================
36. Show employee rank by salary globally
37. Rank employees by salary within each department
38. Show running total of salaries by hire date
39. Find salary difference from department average
40. Show top 3 salaries per job title (DENSE_RANK)
41. Calculate year-to-date salary per employee
42. Find employees with consecutive job changes
43. Show salary percentile within departments
44. List employees with salary growth % vs previous job
45. Show department-wise salary distribution (NTILE)
46. Find first/last employee hired per department
47. Calculate moving average salary (3-month window)
48. Show employees above/below department median salary
49. Rank employees by total compensation (salary+commission)
50. Find salary gaps between consecutive employees
==========================================================================================================================================
51-65: STRING & NUMBER FUNCTIONS
==========================================================================================================================================
51. Format employee names as "LAST, FIRST"
52. Extract year from hire_date
53. Show employee full names in uppercase
54. Find emails ending with company domain
55. Calculate employee age from hire_date
56. Show phone numbers formatted as XXX-XXX-XXXX
57. Concatenate city, state, country
58. Find employees whose name contains "an"
59. Calculate total years worked per employee
60. Show salary with currency formatting
61. Extract numeric salary from text
62. Find employees with names >15 characters
63. Generate employee ID as DEPT_EMP001 format
64. Calculate commission as percentage of salary
65. Show department names padded to 20 chars
==========================================================================================================================================
66-80: REGEX & LOGICAL OPERATORS
==========================================================================================================================================
66. Find emails with valid format (regex)
67. Show employees whose name starts with vowel
68. List phone numbers with country code +91
69. Find cities matching pattern "San*"
70. Show employees NOT working in US/UK
71. List jobs with "Manager" OR "Director" in title
72. Find employees with salary BETWEEN 5000-15000
73. Show records where city IS NULL or empty
74. List employees whose name contains AND "a" OR "e"
75. Find job titles matching pattern "IT_*"
76. Show departments where manager_id IS NULL
77. List employees with commission > salary*0.1
78. Find cities NOT LIKE 'San%'
79. Show employees hired 2005 AND salary >10000
80. List records where ANY condition matches
==========================================================================================================================================
81-100: REAL-TIME INTERVIEW QUESTIONS
==========================================================================================================================================
81. Find duplicate emails (if any exist)
82. Show employees with >10% salary growth in job history
83. Calculate department wise salary variance
84. Pivot job titles to columns with employee count
85. Find employees who worked in multiple countries
86. Show top 10% earners globally
87. Calculate 90-day retention rate by department
88. Find employees with gaps in employment >6 months
89. Show correlation between salary and hire year
90. Generate employee performance bands (A/B/C grades)
91. Find departments with highest salary dispersion
92. Show employees eligible for promotion (top 20%)
93. Calculate ROI on training (salary growth post-hire)
94. Find employees violating job salary range
95. Show cross-tab of departments by regions
96. Calculate employee turnover rate by job
97. Find employees with inconsistent department history
98. Show salary compression issues (new hires vs seniors)
99. Generate cohort analysis by hire month
100. Find employees for layoff (bottom 10% performers)
==========================================================================================================================================
