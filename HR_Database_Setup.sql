-- HR DATABASE SQL CAPSTONE PROJECT
-- ==========================================================================================================

-- HR-STYLE SCHEMA (Oracle 11g)
-- Tables: REGIONS, COUNTRIES, LOCATIONS, DEPARTMENTS,
--         JOBS, EMPLOYEES, JOB_HISTORY, JOB_GRADES
-- Maintains FK relationships as per ER diagram

-- ==========================================================================================================

SET DEFINE OFF;
SET SERVEROUTPUT ON;

-- ==========================================================================================================

-- ---------- DROP (safe) ----------

BEGIN EXECUTE IMMEDIATE 'DROP TABLE job_history CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE employees CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE departments CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE locations CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE countries CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE regions CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE job_grades CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/

BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE locations_seq'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE departments_seq'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE employees_seq'; EXCEPTION WHEN OTHERS THEN NULL; END;
/

-- ==========================================================================================================

-- 1) CREATE TABLES

-- ==========================================================================================================

-- REGIONS
CREATE TABLE regions
( region_id   NUMBER CONSTRAINT region_id_nn NOT NULL, 
region_name VARCHAR2(25), CONSTRAINT reg_id_pk PRIMARY KEY (region_id)
);

-- COUNTRIES
CREATE TABLE countries
( country_id   CHAR(2) CONSTRAINT country_id_nn NOT NULL, 
country_name VARCHAR2(40), region_id    NUMBER, 
CONSTRAINT country_c_id_pk PRIMARY KEY (country_id), 
CONSTRAINT countr_reg_fk FOREIGN KEY (region_id) 
REFERENCES regions(region_id)
)
ORGANIZATION INDEX;

-- LOCATIONS
CREATE TABLE locations
( location_id    NUMBER(4) CONSTRAINT loc_id_pk PRIMARY KEY, 
street_address VARCHAR2(40), postal_code    VARCHAR2(12), 
city   VARCHAR2(30) CONSTRAINT loc_city_nn NOT NULL, state_province VARCHAR2(25),
country_id     CHAR(2), 
CONSTRAINT loc_c_id_fk FOREIGN KEY (country_id) REFERENCES countries(country_id)
);

CREATE SEQUENCE locations_seq START WITH 3300 INCREMENT BY 100 MAXVALUE 9900 NOCACHE NOCYCLE;


-- DEPARTMENTS (manager_id FK added later, after EMPLOYEES exists)
CREATE TABLE departments
( department_id   NUMBER(4) CONSTRAINT dept_id_pk PRIMARY KEY, 
department_name VARCHAR2(30) CONSTRAINT dept_name_nn NOT NULL, 
manager_id      NUMBER(6), location_id     NUMBER(4), 
CONSTRAINT dept_loc_fk FOREIGN KEY (location_id) REFERENCES locations(location_id)
);

CREATE SEQUENCE departments_seq START WITH 280 INCREMENT BY 10 MAXVALUE 9990 NOCACHE NOCYCLE;

-- JOBS
CREATE TABLE jobs
( job_id     VARCHAR2(10) CONSTRAINT job_id_pk PRIMARY KEY, 
job_title  VARCHAR2(35) CONSTRAINT job_title_nn NOT NULL, min_salary NUMBER(6), 
max_salary NUMBER(6)
);

-- EMPLOYEES (self-FK manager_id, plus dept/job FKs)
CREATE TABLE employees
( employee_id    NUMBER(6) CONSTRAINT emp_emp_id_pk PRIMARY KEY, 
first_name     VARCHAR2(20), 
last_name      VARCHAR2(25) CONSTRAINT emp_last_name_nn NOT NULL, 
email          VARCHAR2(25) CONSTRAINT emp_email_nn NOT NULL, 
phone_number   VARCHAR2(20), 
hire_date      DATE CONSTRAINT emp_hire_date_nn NOT NULL, 
job_id         VARCHAR2(10) CONSTRAINT emp_job_nn NOT NULL, 
salary         NUMBER(8,2) CONSTRAINT emp_salary_min CHECK (salary > 0), 
commission_pct NUMBER(2,2), 
manager_id     NUMBER(6), 
department_id  NUMBER(4), 
CONSTRAINT emp_email_uk UNIQUE (email), 
CONSTRAINT emp_manager_fk FOREIGN KEY (manager_id) REFERENCES employees(employee_id), 
CONSTRAINT emp_dept_fk    FOREIGN KEY (department_id) REFERENCES departments(department_id), 
CONSTRAINT emp_job_fk     FOREIGN KEY (job_id) REFERENCES jobs(job_id)
);

CREATE SEQUENCE employees_seq START WITH 207 INCREMENT BY 1 NOCACHE NOCYCLE;

-- Add DEPARTMENTS.manager_id FK (circular dependency resolved after EMPLOYEES exists)
ALTER TABLE departments
ADD CONSTRAINT dept_mgr_fk 
FOREIGN KEY (manager_id) 
REFERENCES employees(employee_id);

-- JOB_HISTORY
CREATE TABLE job_history
( employee_id   NUMBER(6) CONSTRAINT jhist_employee_nn NOT NULL, 
start_date    DATE      CONSTRAINT jhist_start_date_nn NOT NULL, 
end_date      DATE      CONSTRAINT jhist_end_date_nn NOT NULL, 
job_id        VARCHAR2(10) CONSTRAINT jhist_job_nn NOT NULL, 
department_id NUMBER(4), 
CONSTRAINT jhist_emp_id_st_date_pk PRIMARY KEY (employee_id, start_date), 
CONSTRAINT jhist_date_interval CHECK (end_date > start_date), 
CONSTRAINT jhist_emp_fk  FOREIGN KEY (employee_id) REFERENCES employees(employee_id), 
CONSTRAINT jhist_job_fk  FOREIGN KEY (job_id) REFERENCES jobs(job_id), 
CONSTRAINT jhist_dept_fk FOREIGN KEY (department_id) REFERENCES departments(department_id)
);


-- JOB_GRADES (not in the standard HR DDL above, but in your ERD)
CREATE TABLE job_grades
( grade_level  VARCHAR2(2) CONSTRAINT job_grades_pk PRIMARY KEY, 
lowest_sal   NUMBER, highest_sal  NUMBER);

-- ==========================================================================================================

-- 2) INSERT DATA (parent -> child order)

-- ==========================================================================================================

-- REGIONS
BEGIN
  INSERT INTO regions VALUES (1, 'Europe');
  INSERT INTO regions VALUES (2, 'Americas');
  INSERT INTO regions VALUES (3, 'Asia');
  INSERT INTO regions VALUES (4, 'Middle East and Africa');
END;
/

-- COUNTRIES (more rows)
BEGIN
  INSERT INTO countries VALUES ('IT','Italy',1);
  INSERT INTO countries VALUES ('JP','Japan',3);
  INSERT INTO countries VALUES ('US','United States of America',2);
  INSERT INTO countries VALUES ('CA','Canada',2);
  INSERT INTO countries VALUES ('CN','China',3);
  INSERT INTO countries VALUES ('IN','India',3);
  INSERT INTO countries VALUES ('AU','Australia',3);
  INSERT INTO countries VALUES ('SG','Singapore',3);
  INSERT INTO countries VALUES ('UK','United Kingdom',1);
  INSERT INTO countries VALUES ('FR','France',1);
  INSERT INTO countries VALUES ('DE','Germany',1);
  INSERT INTO countries VALUES ('BR','Brazil',2);
  INSERT INTO countries VALUES ('MX','Mexico',2);
  INSERT INTO countries VALUES ('EG','Egypt',4);
  INSERT INTO countries VALUES ('ZA','South Africa',4);
  INSERT INTO countries VALUES ('AE','United Arab Emirates',4);
END;
/

-- LOCATIONS (more rows, includes India)
BEGIN
  INSERT INTO locations VALUES (1000,'1297 Via Cola di Rie','00989','Roma',NULL,'IT');
  INSERT INTO locations VALUES (1100,'93091 Calle della Testa','10934','Venice',NULL,'IT');
  INSERT INTO locations VALUES (1200,'2017 Shinjuku-ku','1689','Tokyo','Tokyo Prefecture','JP');
  INSERT INTO locations VALUES (1400,'2014 Jabberwocky Rd','26192','Southlake','Texas','US');
  INSERT INTO locations VALUES (1500,'2011 Interiors Blvd','99236','South San Francisco','California','US');
  INSERT INTO locations VALUES (1700,'2004 Charade Rd','98199','Seattle','Washington','US');
  INSERT INTO locations VALUES (1800,'147 Spadina Ave','M5V 2L7','Toronto','Ontario','CA');
  INSERT INTO locations VALUES (2000,'40-5-12 Laogianggen','190518','Beijing',NULL,'CN');
  INSERT INTO locations VALUES (2100,'1298 Vileparle (E)','490231','Mumbai','Maharashtra','IN');
  INSERT INTO locations VALUES (2110,'DLF Cyber City','122002','Gurugram','Haryana','IN');
  INSERT INTO locations VALUES (2200,'12-98 Victoria Street','2901','Sydney','New South Wales','AU');
  INSERT INTO locations VALUES (2300,'198 Clementi North','540198','Singapore',NULL,'SG');
  INSERT INTO locations VALUES (2400,'8204 Arthur St',NULL,'London',NULL,'UK');
  INSERT INTO locations VALUES (2500,'Magdalen Centre, The Oxford Science Park','OX4 4GA','Oxford','Oxfordshire','UK');
  INSERT INTO locations VALUES (2700,'Schwanthalerstr. 7031','80925','Munich','Bavaria','DE');
  INSERT INTO locations VALUES (2800,'Rua Frei Caneca 1360','01307-002','Sao Paulo','Sao Paulo','BR');
  INSERT INTO locations VALUES (3200,'Mariano Escobedo 9991','11932','Mexico City','Distrito Federal','MX');
  INSERT INTO locations VALUES (4000,'Sheikh Zayed Rd','00000','Dubai','Dubai','AE');
  INSERT INTO locations VALUES (4100,'Nile Corniche','11511','Cairo','Cairo','EG');
  INSERT INTO locations VALUES (4200,'Sandton Drive','2196','Johannesburg','Gauteng','ZA');
END;
/

-- JOBS (expanded)
BEGIN
  INSERT INTO jobs VALUES ('AD_PRES','President',20080,40000);
  INSERT INTO jobs VALUES ('AD_VP','Administration Vice President',15000,30000);
  INSERT INTO jobs VALUES ('AD_ASST','Administration Assistant',3000,6000);
  INSERT INTO jobs VALUES ('FI_MGR','Finance Manager',8200,16000);
  INSERT INTO jobs VALUES ('FI_ACCOUNT','Accountant',4200,9000);
  INSERT INTO jobs VALUES ('AC_MGR','Accounting Manager',8200,16000);
  INSERT INTO jobs VALUES ('AC_ACCOUNT','Public Accountant',4200,9000);
  INSERT INTO jobs VALUES ('IT_PROG','Programmer',4000,10000);
  INSERT INTO jobs VALUES ('SA_MAN','Sales Manager',10000,20080);
  INSERT INTO jobs VALUES ('SA_REP','Sales Representative',6000,12008);
  INSERT INTO jobs VALUES ('PU_MAN','Purchasing Manager',8000,15000);
  INSERT INTO jobs VALUES ('PU_CLERK','Purchasing Clerk',2500,5500);
  INSERT INTO jobs VALUES ('ST_MAN','Stock Manager',5500,8500);
  INSERT INTO jobs VALUES ('ST_CLERK','Stock Clerk',2008,5000);
  INSERT INTO jobs VALUES ('SH_CLERK','Shipping Clerk',2500,5500);
  INSERT INTO jobs VALUES ('MK_MAN','Marketing Manager',9000,15000);
  INSERT INTO jobs VALUES ('MK_REP','Marketing Representative',4000,9000);
  INSERT INTO jobs VALUES ('HR_REP','Human Resources Representative',4000,9000);
  INSERT INTO jobs VALUES ('PR_REP','Public Relations Representative',4500,10500);
END;
/

-- Temporarily disable dept_mgr_fk (because departments reference employees; employees also reference departments)
-- Because Hereafter only employees table values will be inserted
-- The manager id comes from the employee_id in the employees table. So, it will show error.
-- So, disable the dept_mgr_fk
ALTER TABLE departments DISABLE CONSTRAINT dept_mgr_fk;


-- DEPARTMENTS (more rows; manager_id will be validated after enabling FK)
BEGIN
  INSERT INTO departments VALUES (10,'Administration',200,1700);
  INSERT INTO departments VALUES (20,'Marketing',201,1800);
  INSERT INTO departments VALUES (30,'Purchasing',114,1700);
  INSERT INTO departments VALUES (40,'Human Resources',203,2400);
  INSERT INTO departments VALUES (50,'Shipping',121,1500);
  INSERT INTO departments VALUES (60,'IT',103,1400);
  INSERT INTO departments VALUES (70,'Public Relations',204,2700);
  INSERT INTO departments VALUES (80,'Sales',145,2500);
  INSERT INTO departments VALUES (90,'Executive',100,1700);
  INSERT INTO departments VALUES (100,'Finance',108,1700);
  INSERT INTO departments VALUES (110,'Accounting',205,1700);
  -- extra departments
  INSERT INTO departments VALUES (120,'Data Engineering',103,2110);
  INSERT INTO departments VALUES (130,'AI Research',102,2110);
  INSERT INTO departments VALUES (140,'Cloud Ops',101,1700);
  INSERT INTO departments VALUES (150,'Customer Success',146,2400);
END;
/

-- EMPLOYEES (many rows; kept consistent with HR pattern + added few extra)
BEGIN
  INSERT INTO employees VALUES (100,'Steven','King','SKING','515.123.4567',TO_DATE('17-06-2003','dd-MM-yyyy'),'AD_PRES',24000,NULL,NULL,90);
  INSERT INTO employees VALUES (101,'Neena','Kochhar','NKOCHHAR','515.123.4568',TO_DATE('21-09-2005','dd-MM-yyyy'),'AD_VP',17000,NULL,100,90);
  INSERT INTO employees VALUES (102,'Lex','De Haan','LDEHAAN','515.123.4569',TO_DATE('13-01-2001','dd-MM-yyyy'),'AD_VP',17000,NULL,100,90);
  
  INSERT INTO employees VALUES (103,'Alexander','Hunold','AHUNOLD','590.423.4567',TO_DATE('03-01-2006','dd-MM-yyyy'),'IT_PROG',9000,NULL,102,60);
  INSERT INTO employees VALUES (104,'Bruce','Ernst','BERNST','590.423.4568',TO_DATE('21-05-2007','dd-MM-yyyy'),'IT_PROG',6000,NULL,103,60);
  INSERT INTO employees VALUES (105,'David','Austin','DAUSTIN','590.423.4569',TO_DATE('25-06-2005','dd-MM-yyyy'),'IT_PROG',4800,NULL,103,60);
  
  INSERT INTO employees VALUES (106,'Valli','Pataballa','VPATABAL','590.423.4560',TO_DATE('05-02-2006','dd-MM-yyyy'),'IT_PROG',4800,NULL,103,60);
  INSERT INTO employees VALUES (107,'Diana','Lorentz','DLORENTZ','590.423.5567',TO_DATE('07-02-2007','dd-MM-yyyy'),'IT_PROG',4200,NULL,103,60);
  INSERT INTO employees VALUES (108,'Nancy','Greenberg','NGREENBE','515.124.4569',TO_DATE('17-08-2002','dd-MM-yyyy'),'FI_MGR',12008,NULL,101,100);
  
  INSERT INTO employees VALUES (109,'Daniel','Faviet','DFAVIET','515.124.4169',TO_DATE('16-08-2002','dd-MM-yyyy'),'FI_ACCOUNT',9000,NULL,108,100);
  INSERT INTO employees VALUES (110,'John','Chen','JCHEN','515.124.4269',TO_DATE('28-09-2005','dd-MM-yyyy'),'FI_ACCOUNT',8200,NULL,108,100);
  INSERT INTO employees VALUES (114,'Den','Raphaely','DRAPHEAL','515.127.4561',TO_DATE('07-12-2002','dd-MM-yyyy'),'PU_MAN',11000,NULL,100,30);
  
  INSERT INTO employees VALUES (115,'Alexander','Khoo','AKHOO','515.127.4562',TO_DATE('18-05-2003','dd-MM-yyyy'),'PU_CLERK',3100,NULL,114,30);
  INSERT INTO employees VALUES (116,'Shelli','Baida','SBAIDA','515.127.4563',TO_DATE('24-12-2005','dd-MM-yyyy'),'PU_CLERK',2900,NULL,114,30);
  INSERT INTO employees VALUES (121,'Adam','Fripp','AFRIPP','650.123.2234',TO_DATE('10-04-2005','dd-MM-yyyy'),'ST_MAN',8200,NULL,100,50);
  
  INSERT INTO employees VALUES (120,'Matthew','Weiss','MWEISS','650.123.1234',TO_DATE('18-07-2004','dd-MM-yyyy'),'ST_MAN',8000,NULL,100,50);
  INSERT INTO employees VALUES (125,'Julia','Nayer','JNAYER','650.124.1214',TO_DATE('16-07-2005','dd-MM-yyyy'),'ST_CLERK',3200,NULL,120,50);
  INSERT INTO employees VALUES (126,'Irene','Mikkilineni','IMIKKILI','650.124.1224',TO_DATE('28-09-2006','dd-MM-yyyy'),'ST_CLERK',2700,NULL,120,50);

  INSERT INTO employees VALUES (145,'John','Russell','JRUSSEL','011.44.1344.429268',TO_DATE('01-10-2004','dd-MM-yyyy'),'SA_MAN',14000,.40,100,80);
  INSERT INTO employees VALUES (146,'Karen','Partners','KPARTNER','011.44.1344.467268',TO_DATE('05-01-2005','dd-MM-yyyy'),'SA_MAN',13500,.30,100,80);
  INSERT INTO employees VALUES (150,'Peter','Tucker','PTUCKER','011.44.1344.129268',TO_DATE('30-01-2005','dd-MM-yyyy'),'SA_REP',10000,.30,145,80);
  
  INSERT INTO employees VALUES (151,'David','Bernstein','DBERNSTE','011.44.1344.345268',TO_DATE('24-03-2005','dd-MM-yyyy'),'SA_REP',9500,.25,145,80);
  INSERT INTO employees VALUES (200,'Jennifer','Whalen','JWHALEN','515.123.4444',TO_DATE('17-09-2003','dd-MM-yyyy'),'AD_ASST',4400,NULL,101,10);
  INSERT INTO employees VALUES (201,'Michael','Hartstein','MHARTSTE','515.123.5555',TO_DATE('17-02-2004','dd-MM-yyyy'),'MK_MAN',13000,NULL,100,20);
  
  INSERT INTO employees VALUES (202,'Pat','Fay','PFAY','603.123.6666',TO_DATE('17-08-2005','dd-MM-yyyy'),'MK_REP',6000,NULL,201,20);
  INSERT INTO employees VALUES (203,'Susan','Mavris','SMAVRIS','515.123.7777',TO_DATE('07-06-2002','dd-MM-yyyy'),'HR_REP',6500,NULL,101,40);
  INSERT INTO employees VALUES (204,'Hermann','Baer','HBAER','515.123.8888',TO_DATE('07-06-2002','dd-MM-yyyy'),'PR_REP',10000,NULL,101,70);
  
  INSERT INTO employees VALUES (205,'Shelley','Higgins','SHIGGINS','515.123.8080',TO_DATE('07-06-2002','dd-MM-yyyy'),'AC_MGR',12008,NULL,101,110);
  INSERT INTO employees VALUES (206,'William','Gietz','WGIETZ','515.123.8181',TO_DATE('07-06-2002','dd-MM-yyyy'),'AC_ACCOUNT',8300,NULL,205,110);
  -- extra employees for extra departments
  INSERT INTO employees VALUES (207,'Aarav','Sharma','AARAVS','91.98765.00001',TO_DATE('10-01-2019','dd-MM-yyyy'),'IT_PROG',9500,NULL,103,120);
  INSERT INTO employees VALUES (208,'Isha','Verma','ISHAV','91.98765.00002',TO_DATE('12-03-2020','dd-MM-yyyy'),'IT_PROG',9800,NULL,103,130);
  INSERT INTO employees VALUES (209,'Rohit','Gupta','ROHITG','91.98765.00003',TO_DATE('15-07-2021','dd-MM-yyyy'),'FI_ACCOUNT',7200,NULL,108,140);
  INSERT INTO employees VALUES (210,'Meera','Nair','MEERAN','91.98765.00004',TO_DATE('20-09-2022','dd-MM-yyyy'),'SA_REP',8000,.10,146,150);
END;
/

-- Enable dept manager FK after employees exist
ALTER TABLE departments ENABLE CONSTRAINT dept_mgr_fk;

-- JOB_HISTORY
BEGIN
  INSERT INTO job_history VALUES (102, TO_DATE('13-01-2001','dd-MM-yyyy'), TO_DATE('24-07-2006','dd-MM-yyyy'), 'IT_PROG', 60);
  INSERT INTO job_history VALUES (101, TO_DATE('21-09-1997','dd-MM-yyyy'), TO_DATE('27-10-2001','dd-MM-yyyy'), 'AC_ACCOUNT', 110);
  INSERT INTO job_history VALUES (201, TO_DATE('17-02-2004','dd-MM-yyyy'), TO_DATE('19-12-2007','dd-MM-yyyy'), 'MK_REP', 20);

  -- extra job history rows
  INSERT INTO job_history VALUES (207, TO_DATE('10-01-2019','dd-MM-yyyy'), TO_DATE('31-12-2020','dd-MM-yyyy'), 'IT_PROG', 60);
  INSERT INTO job_history VALUES (208, TO_DATE('12-03-2020','dd-MM-yyyy'), TO_DATE('31-12-2021','dd-MM-yyyy'), 'IT_PROG', 120);
  INSERT INTO job_history VALUES (210, TO_DATE('20-09-2022','dd-MM-yyyy'), TO_DATE('30-06-2023','dd-MM-yyyy'), 'SA_REP', 80);
END;
/

-- JOB_GRADES
BEGIN
  INSERT INTO job_grades VALUES('A',  1000,  2999);
  INSERT INTO job_grades VALUES('B',  3000,  5999);
  INSERT INTO job_grades VALUES('C',  6000,  9999);
  INSERT INTO job_grades VALUES('D', 10000, 14999);
  INSERT INTO job_grades VALUES('E', 15000, 24999);
  INSERT INTO job_grades VALUES('F', 25000, 40000);
END;
/
COMMIT;


-- 1) Add missing parent row (Location 2500)
INSERT INTO locations (location_id, street_address, postal_code, city, state_province, country_id)
VALUES (2500, 'Magdalen Centre, The Oxford Science Park', 'OX4 4GA', 'Oxford', 'Oxfordshire', 'UK');

COMMIT;

-- 2) Now rerun ONLY the inserts that failed earlier:
--    - DEPARTMENTS block
--    - EMPLOYEES block
--    - JOB_HISTORY block
-- (Use the same INSERT blocks from the previous script.)

-- FIX: Add missing LOCATION 2500 (required by Sales dept)
-- ==========================================================================================================
INSERT INTO locations (location_id, street_address, postal_code, city, state_province, country_id) 
VALUES (2500, 'Magdalen Centre, The Oxford Science Park', 'OX4 4GA', 'Oxford', 'Oxfordshire', 'UK');
COMMIT;

-- ==========================================================================================================
-- Temporarily disable dept_mgr_fk (circular dependency)
-- ==========================================================================================================
ALTER TABLE departments DISABLE CONSTRAINT dept_mgr_fk;

-- ==========================================================================================================
-- DEPARTMENTS (now location 2500 exists)
-- ==========================================================================================================
BEGIN
  INSERT INTO departments VALUES (10,'Administration',200,1700);
  INSERT INTO departments VALUES (20,'Marketing',201,1800);
  INSERT INTO departments VALUES (30,'Purchasing',114,1700);
  INSERT INTO departments VALUES (40,'Human Resources',203,2400);
  INSERT INTO departments VALUES (50,'Shipping',121,1500);
  INSERT INTO departments VALUES (60,'IT',103,1400);
  INSERT INTO departments VALUES (70,'Public Relations',204,2700);
  INSERT INTO departments VALUES (80,'Sales',145,2500);  -- NOW VALID!
  INSERT INTO departments VALUES (90,'Executive',100,1700);
  INSERT INTO departments VALUES (100,'Finance',108,1700);
  INSERT INTO departments VALUES (110,'Accounting',205,1700);
  INSERT INTO departments VALUES (120,'Data Engineering',103,2110);
  INSERT INTO departments VALUES (130,'AI Research',102,2110);
  INSERT INTO departments VALUES (140,'Cloud Ops',101,1700);
  INSERT INTO departments VALUES (150,'Customer Success',146,2400);
END;
/

-- ==========================================================================================================
-- EMPLOYEES (departments now exist)
-- ==========================================================================================================
BEGIN
  INSERT INTO employees VALUES (100,'Steven','King','SKING','515.123.4567',TO_DATE('17-06-2003','dd-MM-yyyy'),'AD_PRES',24000,NULL,NULL,90);
  INSERT INTO employees VALUES (101,'Neena','Kochhar','NKOCHHAR','515.123.4568',TO_DATE('21-09-2005','dd-MM-yyyy'),'AD_VP',17000,NULL,100,90);
  INSERT INTO employees VALUES (102,'Lex','De Haan','LDEHAAN','515.123.4569',TO_DATE('13-01-2001','dd-MM-yyyy'),'AD_VP',17000,NULL,100,90);
  INSERT INTO employees VALUES (103,'Alexander','Hunold','AHUNOLD','590.423.4567',TO_DATE('03-01-2006','dd-MM-yyyy'),'IT_PROG',9000,NULL,102,60);
  INSERT INTO employees VALUES (104,'Bruce','Ernst','BERNST','590.423.4568',TO_DATE('21-05-2007','dd-MM-yyyy'),'IT_PROG',6000,NULL,103,60);
  INSERT INTO employees VALUES (105,'David','Austin','DAUSTIN','590.423.4569',TO_DATE('25-06-2005','dd-MM-yyyy'),'IT_PROG',4800,NULL,103,60);
  INSERT INTO employees VALUES (108,'Nancy','Greenberg','NGREENBE','515.124.4569',TO_DATE('17-08-2002','dd-MM-yyyy'),'FI_MGR',12008,NULL,101,100);
  INSERT INTO employees VALUES (114,'Den','Raphaely','DRAPHEAL','515.127.4561',TO_DATE('07-12-2002','dd-MM-yyyy'),'PU_MAN',11000,NULL,100,30);
  INSERT INTO employees VALUES (145,'John','Russell','JRUSSEL','011.44.1344.429268',TO_DATE('01-10-2004','dd-MM-yyyy'),'SA_MAN',14000,.40,100,80);
  INSERT INTO employees VALUES (200,'Jennifer','Whalen','JWHALEN','515.123.4444',TO_DATE('17-09-2003','dd-MM-yyyy'),'AD_ASST',4400,NULL,101,10);
  INSERT INTO employees VALUES (201,'Michael','Hartstein','MHARTSTE','515.123.5555',TO_DATE('17-02-2004','dd-MM-yyyy'),'MK_MAN',13000,NULL,100,20);
  INSERT INTO employees VALUES (202,'Pat','Fay','PFAY','603.123.6666',TO_DATE('17-08-2005','dd-MM-yyyy'),'MK_REP',6000,NULL,201,20);
  INSERT INTO employees VALUES (203,'Susan','Mavris','SMAVRIS','515.123.7777',TO_DATE('07-06-2002','dd-MM-yyyy'),'HR_REP',6500,NULL,101,40);
  INSERT INTO employees VALUES (204,'Hermann','Baer','HBAER','515.123.8888',TO_DATE('07-06-2002','dd-MM-yyyy'),'PR_REP',10000,NULL,101,70);
  INSERT INTO employees VALUES (205,'Shelley','Higgins','SHIGGINS','515.123.8080',TO_DATE('07-06-2002','dd-MM-yyyy'),'AC_MGR',12008,NULL,101,110);
END;
/

--- ==========================================================================================================
-- JOB_HISTORY (employees + departments exist)
-- ==========================================================================================================
BEGIN
  INSERT INTO job_history VALUES (102, TO_DATE('13-01-2001','dd-MM-yyyy'), TO_DATE('24-07-2006','dd-MM-yyyy'), 'IT_PROG', 60);
  INSERT INTO job_history VALUES (101, TO_DATE('21-09-1997','dd-MM-yyyy'), TO_DATE('27-10-2001','dd-MM-yyyy'), 'AC_ACCOUNT', 110);
END;
/

-- ==========================================================================================================
  
-- Final Check
SELECT COUNT(*) AS total_employees FROM employees;

SELECT COUNT(*) AS total_departments FROM departments;

SELECT COUNT(*) AS total_jobs FROM jobs;

SELECT employee_id, first_name, last_name, department_id FROM employees
WHERE department_id IS NOT NULL
AND department_id NOT IN (SELECT department_id FROM departments);

SELECT employee_id, first_name, job_id FROM employees 
WHERE job_id NOT IN ( SELECT job_id FROM jobs);  

SELECT employee_id, first_name, manager_id FROM employees 
WHERE manager_id IS NOT NULL AND manager_id NOT IN (SELECT employee_id FROM employees);

SELECT employee_id, job_id, department_id FROM job_history
WHERE employee_id NOT IN (SELECT employee_id FROM employees)
OR job_id NOT IN (SELECT job_id FROM jobs)
OR department_id NOT IN (SELECT department_id FROM departments);

-- ==========================================================================================================




