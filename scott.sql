-- ============================================================
--  SCOTT Schema for PostgreSQL 18
--  Classic Oracle training schema adapted for PostgreSQL.
--
--  Usage:
--    sudo -i -u postgres psql -f scott.sql
--
--  What this script does:
--    1. Creates the 'scottdb' database
--    2. Creates the 'scott' schema inside it
--    3. Creates tables: dept, emp, salgrade, bonus
--    4. Loads all sample data
-- ============================================================

-- ------------------------------------------------------------
-- 1. Create database (run as postgres superuser)
-- ------------------------------------------------------------
-- Drop if re-running from scratch (comment out if not needed)
-- DROP DATABASE IF EXISTS scottdb;

CREATE DATABASE scottdb
  ENCODING    = 'UTF8'
  LC_COLLATE  = 'en_US.UTF-8'
  LC_CTYPE    = 'en_US.UTF-8'
  TEMPLATE    = template0;

-- ------------------------------------------------------------
-- 2. Connect to scottdb
-- ------------------------------------------------------------
\connect scottdb

-- ------------------------------------------------------------
-- 3. Create and set the scott schema
-- ------------------------------------------------------------
CREATE SCHEMA IF NOT EXISTS scott;
SET search_path TO scott;

-- ------------------------------------------------------------
-- 4. DDL  (Oracle → PostgreSQL conversions)
--    NUMBER(p,s) → NUMERIC(p,s)
--    VARCHAR2(n) → VARCHAR(n)
--    DATE        → DATE  (PostgreSQL DATE stores date only;
--                         use TIMESTAMP if time part is needed)
-- ------------------------------------------------------------

-- DEPT
CREATE TABLE dept (
  deptno  NUMERIC(2, 0)  NOT NULL,
  dname   VARCHAR(14),
  loc     VARCHAR(13),
  CONSTRAINT pk_dept PRIMARY KEY (deptno)
);

-- EMP
CREATE TABLE emp (
  empno    NUMERIC(4, 0)  NOT NULL,
  ename    VARCHAR(10),
  job      VARCHAR(9),
  mgr      NUMERIC(4, 0),                          -- self-referencing (manager empno)
  hiredate DATE,
  sal      NUMERIC(7, 2),
  comm     NUMERIC(7, 2),
  deptno   NUMERIC(2, 0),
  CONSTRAINT pk_emp     PRIMARY KEY (empno),
  CONSTRAINT fk_deptno  FOREIGN KEY (deptno) REFERENCES dept (deptno)
);

-- SALGRADE
CREATE TABLE salgrade (
  grade  NUMERIC,
  losal  NUMERIC,
  hisal  NUMERIC
);

-- BONUS  (intentionally schema-less in the original; kept for completeness)
CREATE TABLE bonus (
  ename  VARCHAR(10),
  job    VARCHAR(9),
  sal    NUMERIC,
  comm   NUMERIC
);

-- ------------------------------------------------------------
-- 5. DML — Department data
-- ------------------------------------------------------------
INSERT INTO dept VALUES (10, 'ACCOUNTING', 'NEW YORK');
INSERT INTO dept VALUES (20, 'RESEARCH',   'DALLAS');
INSERT INTO dept VALUES (30, 'SALES',      'CHICAGO');
INSERT INTO dept VALUES (40, 'OPERATIONS', 'BOSTON');

-- ------------------------------------------------------------
-- 6. DML — Employee data
--    Oracle DATE '...' literal → PostgreSQL DATE '...' (same syntax, works fine)
-- ------------------------------------------------------------
INSERT INTO emp VALUES (7839, 'KING',   'PRESIDENT', NULL, DATE '1981-11-17', 5000, NULL, 10);
INSERT INTO emp VALUES (7698, 'BLAKE',  'MANAGER',   7839, DATE '1981-05-01', 2850, NULL, 30);
INSERT INTO emp VALUES (7782, 'CLARK',  'MANAGER',   7839, DATE '1981-06-09', 2450, NULL, 10);
INSERT INTO emp VALUES (7566, 'JONES',  'MANAGER',   7839, DATE '1981-04-02', 2975, NULL, 20);
INSERT INTO emp VALUES (7654, 'MARTIN', 'SALESMAN',  7698, DATE '1981-09-28', 1250, 1400, 30);
INSERT INTO emp VALUES (7499, 'ALLEN',  'SALESMAN',  7698, DATE '1981-02-20', 1600,  300, 30);
INSERT INTO emp VALUES (7844, 'TURNER', 'SALESMAN',  7698, DATE '1981-09-08', 1500,    0, 30);
INSERT INTO emp VALUES (7900, 'JAMES',  'CLERK',     7698, DATE '1981-12-03',  950, NULL, 30);
INSERT INTO emp VALUES (7521, 'WARD',   'SALESMAN',  7698, DATE '1981-02-22', 1250,  500, 30);
INSERT INTO emp VALUES (7902, 'FORD',   'ANALYST',   7566, DATE '1981-12-03', 3000, NULL, 20);
INSERT INTO emp VALUES (7369, 'SMITH',  'CLERK',     7902, DATE '1980-12-17',  800, NULL, 20);
INSERT INTO emp VALUES (7788, 'SCOTT',  'ANALYST',   7566, DATE '1982-12-09', 3000, NULL, 20);
INSERT INTO emp VALUES (7876, 'ADAMS',  'CLERK',     7788, DATE '1983-01-12', 1100, NULL, 20);
INSERT INTO emp VALUES (7934, 'MILLER', 'CLERK',     7782, DATE '1982-01-23', 1300, NULL, 10);

-- ------------------------------------------------------------
-- 7. DML — Salary grade data
-- ------------------------------------------------------------
INSERT INTO salgrade VALUES (1,  700, 1200);
INSERT INTO salgrade VALUES (2, 1201, 1400);
INSERT INTO salgrade VALUES (3, 1401, 2000);
INSERT INTO salgrade VALUES (4, 2001, 3000);
INSERT INTO salgrade VALUES (5, 3001, 9999);

-- ------------------------------------------------------------
-- 8. Verify load
-- ------------------------------------------------------------
SELECT 'dept'     AS "table", COUNT(*) AS rows FROM dept
UNION ALL
SELECT 'emp',                  COUNT(*)        FROM emp
UNION ALL
SELECT 'salgrade',             COUNT(*)        FROM salgrade;
