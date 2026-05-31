# PostgreSQL 18 on WSL2 (Ubuntu) — Beginner's Guide

A complete guide to install, configure, validate, and practice PostgreSQL 18 inside WSL2 (Ubuntu).  
Designed for developers learning PostgreSQL and PL/pgSQL from scratch.

---

## 📋 Table of Contents

- [Prerequisites](#-prerequisites)
- [Part 1: WSL2 Setup](#-part-1-wsl2-setup)
- [Part 2: Install PostgreSQL 18](#-part-2-install-postgresql-18)
- [Part 3: Connect from Windows Tools](#-part-3-connect-from-windows-tools)
- [Part 4: Validation](#-part-4-validation)
- [Part 5: SCOTT Schema — Practice Dataset](#-part-5-scott-schema--practice-dataset)
- [Part 6: PL/pgSQL Practice](#-part-6-plpgsql-practice)
- [Part 7: Troubleshooting](#-part-7-troubleshooting)
- [Part 8: Uninstall / Cleanup](#-part-8-uninstall--cleanup)

---

## ✅ Prerequisites

- Windows 10 (build 19041+) or Windows 11
- WSL2 enabled
- Ubuntu 22.04 or 24.04 installed from Microsoft Store

---

## ✅ Part 1: WSL2 Setup

### Install WSL2

Open **PowerShell as Administrator**:

```powershell
wsl --install
```

- Restart your system if prompted
- Open **Ubuntu** from the Start Menu
- Create your Linux username and password

> **Tip:** Run `wsl --set-default-version 2` to ensure WSL2 is the default.

---

## ✅ Part 2: Install PostgreSQL 18

### Step 1: Update Packages

```bash
sudo apt update && sudo apt upgrade -y
```

---

### Step 2: Add the Official PostgreSQL Repository

> ⚠️ The older `apt-key add` method is deprecated in Ubuntu 22.04+. Use the modern keyring approach below.

```bash
sudo apt install -y wget gnupg lsb-release
```

```bash
sudo install -d /usr/share/postgresql-common/pgdg

sudo wget -qO /usr/share/postgresql-common/pgdg/apt.postgresql.org.asc \
  https://www.postgresql.org/media/keys/ACCC4CF8.asc
```

```bash
echo "deb [signed-by=/usr/share/postgresql-common/pgdg/apt.postgresql.org.asc] \
  https://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" \
  | sudo tee /etc/apt/sources.list.d/pgdg.list
```

```bash
sudo apt update
```

---

### Step 3: Install PostgreSQL 18

```bash
sudo apt install -y postgresql-18 postgresql-client-18
```

---

### Step 4: Start PostgreSQL Service

```bash
sudo service postgresql start
```

Check status:

```bash
sudo service postgresql status
```

> ⚠️ **WSL2 important note:** WSL2 does not use `systemd` by default, so PostgreSQL **does not start automatically** when you open a new terminal. You need to run `sudo service postgresql start` each session, or add it to your `~/.bashrc` / `~/.profile`:
>
> ```bash
> # Add to ~/.bashrc to auto-start PostgreSQL in WSL2
> sudo service postgresql start > /dev/null 2>&1
> ```

---

### Step 5: Connect to PostgreSQL

```bash
sudo -i -u postgres
psql
```

---

### Step 6: Set a Password for the postgres User

```sql
ALTER USER postgres PASSWORD 'StrongPassword123';
\q
```

Exit back to your regular user:

```bash
exit
```

---

### Step 7: Create a Practice Database

```bash
sudo -i -u postgres createdb practicedb
sudo -i -u postgres psql practicedb
```

```sql
-- Create a sample table
CREATE TABLE employees (
  id     SERIAL PRIMARY KEY,
  name   TEXT   NOT NULL,
  dept   TEXT,
  salary NUMERIC(10, 2)
);

-- Insert sample data
INSERT INTO employees (name, dept, salary) VALUES
  ('Alice',   'Engineering', 90000),
  ('Bob',     'Marketing',   70000),
  ('Charlie', 'Engineering', 85000),
  ('Diana',   'HR',          65000);

-- Verify
SELECT * FROM employees;

\q

```

---

## ✅ Part 3: Connect from Windows Tools

Connect to PostgreSQL running in WSL2 from **pgAdmin** or **DBeaver** on Windows.

---

### Step 1: Update `postgresql.conf`

```bash
sudo nano /etc/postgresql/18/main/postgresql.conf
```

Find 
To search for text in the nano editor, press Ctrl + W , 
type your search term at the prompt at the bottom of the screen, and press Enter
```
#listen_addresses = 'localhost'
```

Change to:
```
listen_addresses = '*'
```
To save and exit the nano text editor, press Ctrl + X, then type Y, and press Enter

---

### Step 2: Update `pg_hba.conf`

```bash
sudo nano /etc/postgresql/18/main/pg_hba.conf
```

Add this line at the bottom:

```
host    all    all    0.0.0.0/0    scram-sha-256
```

> ⚠️ **Security note:** This allows connections from any IP. This is acceptable for a local development environment, but **never use this configuration in production**. Use `scram-sha-256` (not `md5`) as it is the stronger default in PostgreSQL 14+.

---

### Step 3: Restart PostgreSQL

```bash
sudo service postgresql restart
```

---

### Step 4: Connect from pgAdmin / DBeaver

Use these connection details:

| Field    | Value               |
|----------|---------------------|
| Host     | `localhost`         |
| Port     | `5432`              |
| Database | `practicedb`        |
| User     | `postgres`          |
| Password | `StrongPassword123` |

**Download links:**
- **pgAdmin** → https://www.pgadmin.org/download/
- **DBeaver** → https://dbeaver.io/download/

---

## ✅ Part 4: Validation

### Check PostgreSQL Version

```bash
psql --version
```

### Check Cluster Status

```bash
pg_lsclusters
```

### Check Running Processes

```bash
ps -ef | grep postgres
```

### Check Port is Listening

```bash
ss -nlt | grep 5432
```

### Test Connection

```bash
psql -U postgres -h localhost
```

### Verify Data Directory

```bash
ls /var/lib/postgresql/18/main
```

---

## ✅ Part 5: SCOTT Schema — Practice Dataset

The **SCOTT schema** is the classic Oracle training dataset, used by generations of SQL learners.  
It ships with four tables that model a simple company — perfect for practising joins, aggregations, subqueries, and PL/pgSQL.

### Schema Overview

```
dept      ──< emp >── emp        (self-join: mgr references empno)
              │
              └──< salgrade      (emp.sal falls between losal and hisal)
```

| Table      | Rows | Description                              |
|------------|------|------------------------------------------|
| `dept`     | 4    | Departments (deptno, dname, loc)         |
| `emp`      | 14   | Employees (empno, ename, job, mgr, sal…) |
| `salgrade` | 5    | Salary bands (grade 1–5)                 |
| `bonus`    | 0    | Bonus records (empty — for practice use) |

---

### Load the SCOTT Schema

The file `scott.sql` (included in this repo) creates the `scottdb` database, the `scott` schema, and loads all data.

```bash
# Run as the postgres superuser from your WSL2 terminal
sudo -i -u postgres psql -f /path/to/scott.sql
```

Verify the load:

```bash
sudo -i -u postgres psql -d scottdb
```

```sql
-- Set the schema search path for this session
SET search_path TO scott;

-- Quick check
SELECT * FROM dept;
SELECT * FROM emp;
SELECT * FROM salgrade;
```

Connect from **pgAdmin / DBeaver** using:

| Field    | Value               |
|----------|---------------------|
| Host     | `localhost`         |
| Port     | `5432`              |
| Database | `scottdb`           |
| Schema   | `scott`             |
| User     | `postgres`          |
| Password | `StrongPassword123` |

---

### Oracle → PostgreSQL: Key Differences

| Oracle           | PostgreSQL           | Notes                                      |
|------------------|----------------------|--------------------------------------------|
| `NUMBER(p,s)`    | `NUMERIC(p,s)`       | Identical precision/scale behaviour        |
| `VARCHAR2(n)`    | `VARCHAR(n)`         | Functionally equivalent                    |
| `DATE`           | `DATE` / `TIMESTAMP` | PG `DATE` is date-only; use `TIMESTAMP` if time is needed |
| `SEQUENCE` + trigger | `SERIAL` / `GENERATED ALWAYS AS IDENTITY` | PG has built-in identity columns |
| `NVL(x, y)`      | `COALESCE(x, y)`     | Null substitution                          |
| `DECODE(...)`    | `CASE WHEN … END`    | Conditional expression                     |
| `ROWNUM`         | `LIMIT n`            | Row limiting                               |
| `CONNECT BY`     | Recursive CTE (`WITH RECURSIVE`) | Hierarchical queries           |
| `SYSDATE`        | `CURRENT_DATE` / `NOW()` | Current date/time                      |

---

### SQL Practice Exercises

Work through these in order — each builds on the last.

```sql
SET search_path TO scott;

-- 1. List all employees with their department name
SELECT e.ename, e.job, d.dname, d.loc
FROM emp e
JOIN dept d ON e.deptno = d.deptno
ORDER BY d.dname, e.ename;

-- 2. Employees and their salary grade
SELECT e.ename, e.sal, s.grade
FROM emp e
JOIN salgrade s ON e.sal BETWEEN s.losal AND s.hisal
ORDER BY s.grade DESC;

-- 3. Each employee alongside their manager's name (self-join)
SELECT e.ename AS employee, m.ename AS manager
FROM emp e
LEFT JOIN emp m ON e.mgr = m.empno
ORDER BY manager NULLS FIRST;

-- 4. Department headcount and average salary
SELECT d.dname,
       COUNT(e.empno)       AS headcount,
       ROUND(AVG(e.sal), 2) AS avg_salary,
       SUM(e.sal)           AS total_salary
FROM dept d
LEFT JOIN emp e ON d.deptno = e.deptno
GROUP BY d.dname
ORDER BY avg_salary DESC NULLS LAST;

-- 5. Employees earning more than the average salary
SELECT ename, sal
FROM emp
WHERE sal > (SELECT AVG(sal) FROM emp)
ORDER BY sal DESC;

-- 6. Total compensation (salary + commission); NULL comm treated as 0
SELECT ename, sal, COALESCE(comm, 0) AS comm,
       sal + COALESCE(comm, 0) AS total_comp
FROM emp
ORDER BY total_comp DESC;

-- 7. Employees hired in the 1980s, formatted date
SELECT ename,
       TO_CHAR(hiredate, 'DD-Mon-YYYY') AS hired_on,
       EXTRACT(YEAR FROM hiredate)      AS hire_year
FROM emp
WHERE hiredate BETWEEN DATE '1980-01-01' AND DATE '1989-12-31'
ORDER BY hiredate;

-- 8. Hierarchical reporting chain using a recursive CTE
--    (PostgreSQL equivalent of Oracle's CONNECT BY)
WITH RECURSIVE org_chart AS (
  -- Anchor: top of the chain (no manager)
  SELECT empno, ename, mgr, job, 0 AS depth,
         ename::TEXT AS chain
  FROM emp
  WHERE mgr IS NULL

  UNION ALL

  SELECT e.empno, e.ename, e.mgr, e.job,
         oc.depth + 1,
         oc.chain || ' → ' || e.ename
  FROM emp e
  JOIN org_chart oc ON e.mgr = oc.empno
)
SELECT depth,
       REPEAT('  ', depth) || ename AS org_chart,
       job,
       chain
FROM org_chart
ORDER BY chain;
```

---

## ✅ Part 6: PL/pgSQL Practice

All examples below use the `scott` schema. Make sure you are connected to `scottdb`.

```sql
SET search_path TO scott;
```

---

### 1. Anonymous Block (DO)

```sql
DO $$
BEGIN
  RAISE NOTICE 'Connected to SCOTT schema. Employees: %',
    (SELECT COUNT(*) FROM emp);
END;
$$;
```

---

### 2. Scalar Function — Salary Grade Label

```sql
CREATE OR REPLACE FUNCTION scott.get_grade_label(p_sal NUMERIC)
RETURNS TEXT AS $$
DECLARE
  v_grade NUMERIC;
BEGIN
  SELECT grade INTO v_grade
  FROM salgrade
  WHERE p_sal BETWEEN losal AND hisal;

  RETURN CASE v_grade
    WHEN 1 THEN 'Grade 1 – Entry'
    WHEN 2 THEN 'Grade 2 – Junior'
    WHEN 3 THEN 'Grade 3 – Mid'
    WHEN 4 THEN 'Grade 4 – Senior'
    WHEN 5 THEN 'Grade 5 – Principal'
    ELSE        'Unknown'
  END;
END;
$$ LANGUAGE plpgsql;

-- Test
SELECT ename, sal, get_grade_label(sal) AS grade_label
FROM emp
ORDER BY sal;
```

---

### 3. Function with IF / ELSIF — Annual Bonus Calculator

```sql
CREATE OR REPLACE FUNCTION scott.calc_bonus(p_empno NUMERIC)
RETURNS NUMERIC AS $$
DECLARE
  v_job  emp.job%TYPE;
  v_sal  emp.sal%TYPE;
  v_bonus NUMERIC;
BEGIN
  SELECT job, sal INTO v_job, v_sal
  FROM emp
  WHERE empno = p_empno;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Employee % not found', p_empno;
  END IF;

  IF v_job = 'PRESIDENT' THEN
    v_bonus := v_sal * 0.20;
  ELSIF v_job IN ('MANAGER', 'ANALYST') THEN
    v_bonus := v_sal * 0.15;
  ELSIF v_job = 'SALESMAN' THEN
    v_bonus := v_sal * 0.10;
  ELSE
    v_bonus := v_sal * 0.05;   -- CLERK
  END IF;

  RETURN ROUND(v_bonus, 2);
END;
$$ LANGUAGE plpgsql;

-- Test for every employee
SELECT empno, ename, job, sal,
       calc_bonus(empno) AS bonus
FROM emp
ORDER BY bonus DESC;
```

---

### 4. FOR Loop — Department Salary Report

```sql
CREATE OR REPLACE FUNCTION scott.dept_salary_report()
RETURNS VOID AS $$
DECLARE
  rec RECORD;
BEGIN
  RAISE NOTICE '%-20s  %6s  %10s', 'Department', 'Count', 'Total Sal';
  RAISE NOTICE '%', REPEAT('-', 42);

  FOR rec IN
    SELECT d.dname,
           COUNT(e.empno)  AS cnt,
           SUM(e.sal)      AS total
    FROM dept d
    LEFT JOIN emp e ON d.deptno = e.deptno
    GROUP BY d.dname
    ORDER BY total DESC NULLS LAST
  LOOP
    RAISE NOTICE '%-20s  %6s  %10s',
      rec.dname, rec.cnt, COALESCE(rec.total::TEXT, '—');
  END LOOP;
END;
$$ LANGUAGE plpgsql;

SELECT dept_salary_report();
```

---

### 5. Exception Handling — Safe Employee Lookup

```sql
CREATE OR REPLACE FUNCTION scott.get_employee(p_empno NUMERIC)
RETURNS TEXT AS $$
DECLARE
  v_result TEXT;
BEGIN
  SELECT ename || ' (' || job || ') — Dept ' || deptno
  INTO STRICT v_result
  FROM emp
  WHERE empno = p_empno;

  RETURN v_result;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN 'Employee ' || p_empno || ' does not exist.';
  WHEN TOO_MANY_ROWS THEN
    RETURN 'Unexpected: multiple rows for empno ' || p_empno;
  WHEN OTHERS THEN
    RAISE NOTICE 'Unexpected error: %', SQLERRM;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

SELECT get_employee(7839);   -- KING
SELECT get_employee(9999);   -- Not found
```

---

### 6. Cursor — Walk Through Employees Manually

```sql
CREATE OR REPLACE FUNCTION scott.cursor_demo()
RETURNS VOID AS $$
DECLARE
  cur    CURSOR FOR
           SELECT ename, sal FROM emp ORDER BY sal DESC;
  v_name emp.ename%TYPE;
  v_sal  emp.sal%TYPE;
BEGIN
  OPEN cur;
  LOOP
    FETCH cur INTO v_name, v_sal;
    EXIT WHEN NOT FOUND;
    RAISE NOTICE '%-10s  %s', v_name, v_sal;
  END LOOP;
  CLOSE cur;
END;
$$ LANGUAGE plpgsql;

SELECT cursor_demo();
```

---

### 7. Useful `psql` Commands

| Command                   | Description                              |
|---------------------------|------------------------------------------|
| `\l`                      | List all databases                       |
| `\c scottdb`              | Connect to `scottdb`                     |
| `SET search_path TO scott;` | Use the scott schema in this session   |
| `\dt scott.*`             | List all tables in the scott schema      |
| `\df scott.*`             | List all functions in the scott schema   |
| `\d scott.emp`            | Describe the emp table                   |
| `\sf scott.calc_bonus`    | Show source of a function                |
| `\timing`                 | Toggle query execution time display      |
| `\x`                      | Toggle expanded (vertical) output        |
| `\q`                      | Quit psql                                |

---

## ✅ Part 7: Troubleshooting

### PostgreSQL won't start

```bash
sudo service postgresql start
# If it fails, check logs:
sudo tail -n 30 /var/log/postgresql/postgresql-18-main.log
```

### `psql: error: connection to server on socket failed`

PostgreSQL is not running. Start it:

```bash
sudo service postgresql start
```

### `FATAL: password authentication failed for user "postgres"`

Reset the password:

```bash
# Switch to the postgres OS user and open psql
sudo -i -u postgres psql
ALTER USER postgres PASSWORD 'NewPassword123';
\q
```

### Port 5432 already in use

```bash
ss -nlt | grep 5432
# Find the PID using port 5432
sudo lsof -i :5432
# Kill if needed
sudo kill -9 <PID>
```

### Can't connect from pgAdmin / DBeaver

1. Confirm `listen_addresses = '*'` in `postgresql.conf`
2. Confirm the `0.0.0.0/0 scram-sha-256` line is in `pg_hba.conf`
3. Restart PostgreSQL: `sudo service postgresql restart`
4. Verify the port is open: `ss -nlt | grep 5432`

---

## ✅ Part 8: Uninstall / Cleanup

### Step 1: Stop PostgreSQL

```bash
sudo service postgresql stop
```

### Step 2: Remove Packages

```bash
sudo apt remove --purge -y postgresql-18 postgresql-client-18 postgresql-common
```

### Step 3: Remove Unused Packages

```bash
sudo apt autoremove -y && sudo apt autoclean
```

### Step 4: Delete Data ⚠️ Permanent

```bash
sudo rm -rf /var/lib/postgresql/
sudo rm -rf /etc/postgresql/
sudo rm -rf /var/log/postgresql/
```

### Step 5: Remove Repository (Optional)

```bash
sudo rm /etc/apt/sources.list.d/pgdg.list
sudo rm /usr/share/postgresql-common/pgdg/apt.postgresql.org.asc
sudo apt update
```

### Step 6: Validate Cleanup

```bash
psql --version          # Expected: command not found
ps -ef | grep postgres  # Expected: no postgres processes
ss -nlt | grep 5432     # Expected: no output
ls /var/lib/postgresql  # Expected: No such file or directory
```

---

## 📚 Further Learning

- [PostgreSQL 18 Official Docs](https://www.postgresql.org/docs/18/)
- [PL/pgSQL Reference](https://www.postgresql.org/docs/18/plpgsql.html)
