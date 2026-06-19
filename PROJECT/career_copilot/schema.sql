-- ============================================================
-- AI CAREER COPILOT — "Is My Career Healthy?"
-- Dataset: IBM HR Analytics Employee Attrition & Performance
-- Source: WA_Fn-UseC_-HR-Employee-Attrition.csv (1470 rows, 35 cols, 0 nulls)
-- ============================================================

CREATE DATABASE IF NOT EXISTS career_copilot;
USE career_copilot;

SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS predictions;
DROP TABLE IF EXISTS employees_clean;
DROP TABLE IF EXISTS employees;
DROP TABLE IF EXISTS job_roles;
DROP TABLE IF EXISTS departments;

SET FOREIGN_KEY_CHECKS = 1;

-- ============================================================
-- LOOKUP TABLES
-- Small reference tables derived from the categorical columns.
-- Not strictly required for 1470 rows, but keeps the schema
-- normalized and gives you real JOIN practice in SQL.
-- ============================================================

CREATE TABLE departments (
    department_id   INT AUTO_INCREMENT PRIMARY KEY,
    department_name VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE job_roles (
    job_role_id     INT AUTO_INCREMENT PRIMARY KEY,
    job_role_name   VARCHAR(50) UNIQUE NOT NULL,
    department_id   INT,
    FOREIGN KEY (department_id) REFERENCES departments(department_id)
);

-- ============================================================
-- EMPLOYEES (raw, one row per CSV record)
-- Columns kept 1:1 with the source file. Constant/non-informative
-- columns (EmployeeCount, Over18, StandardHours) are intentionally
-- excluded — they carry zero variance and zero predictive signal.
-- ============================================================

CREATE TABLE employees (
    employee_number             INT PRIMARY KEY,        -- source: EmployeeNumber

    age                          INT,
    attrition                    ENUM('Yes','No'),
    business_travel              VARCHAR(30),            -- Travel_Rarely / Travel_Frequently / Non-Travel
    daily_rate                   INT,
    department                   VARCHAR(50),
    distance_from_home           INT,
    education                    TINYINT,                -- 1-5 (Below College..Doctor)
    education_field               VARCHAR(50),
    environment_satisfaction      TINYINT,                -- 1-4
    gender                        VARCHAR(10),
    hourly_rate                  INT,
    job_involvement               TINYINT,                -- 1-4
    job_level                    TINYINT,                -- 1-5
    job_role                     VARCHAR(50),
    job_satisfaction              TINYINT,                -- 1-4
    marital_status                VARCHAR(20),
    monthly_income                INT,
    monthly_rate                 INT,
    num_companies_worked          TINYINT,
    overtime                     ENUM('Yes','No'),
    percent_salary_hike           TINYINT,
    performance_rating            TINYINT,                -- 1-4
    relationship_satisfaction     TINYINT,                -- 1-4
    stock_option_level            TINYINT,                -- 0-3
    total_working_years           TINYINT,
    training_times_last_year      TINYINT,
    work_life_balance             TINYINT,                -- 1-4
    years_at_company              TINYINT,
    years_in_current_role         TINYINT,
    years_since_last_promotion    TINYINT,
    years_with_curr_manager       TINYINT
);

-- ============================================================
-- EMPLOYEES_CLEAN (ML-ready, engineered features)
-- Populated by the Python ETL notebook. This is what the model
-- trains on; keeps engineered/derived columns out of the raw table.
-- ============================================================

CREATE TABLE employees_clean (
    employee_number              INT PRIMARY KEY,

    -- engineered targets ------------------------------------------------
    attrition_flag                TINYINT,        -- 1 = Yes, 0 = No
    stagnation_flag                TINYINT,        -- 1 = years_since_last_promotion > dataset median

    -- engineered features --------------------------------------------------
    income_per_year_experience     FLOAT,          -- monthly_income*12 / (total_working_years+1)
    tenure_ratio                   FLOAT,           -- years_at_company / (total_working_years+1)
    promotion_gap_ratio            FLOAT,           -- years_since_last_promotion / (years_at_company+1)
    satisfaction_index             FLOAT,           -- mean of the four satisfaction-style scores
    is_frequent_traveler            TINYINT,
    is_overtime                    TINYINT,

    FOREIGN KEY (employee_number) REFERENCES employees(employee_number)
);

-- ============================================================
-- PREDICTIONS (model output log — useful once Streamlit app
-- is live and logging real user self-assessments)
-- ============================================================

CREATE TABLE predictions (
    prediction_id        INT AUTO_INCREMENT PRIMARY KEY,
    employee_number       INT NULL,                -- NULL when input is an ad-hoc user, not a dataset row
    model_name            VARCHAR(50),              -- e.g. 'attrition_rf_v1'
    attrition_risk_score   FLOAT,                    -- predicted probability 0-1
    stagnation_risk_score  FLOAT,
    predicted_at           DATETIME DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (employee_number) REFERENCES employees(employee_number)
);

-- ============================================================
-- INDEXES
-- ============================================================

CREATE INDEX idx_employees_department      ON employees(department);
CREATE INDEX idx_employees_job_role        ON employees(job_role);
CREATE INDEX idx_employees_attrition       ON employees(attrition);
CREATE INDEX idx_clean_attrition_flag      ON employees_clean(attrition_flag);
CREATE INDEX idx_clean_stagnation_flag     ON employees_clean(stagnation_flag);

SELECT 'Schema Created Successfully' AS status;
