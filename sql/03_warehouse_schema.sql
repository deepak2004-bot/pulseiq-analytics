CREATE TABLE dw.dim_department (
    department_id   TEXT PRIMARY KEY,
    department_name TEXT,
    cost_center     TEXT,
    description     TEXT,
    is_leadership   BOOLEAN
);

CREATE TABLE dw.dim_role (
    role_id              TEXT PRIMARY KEY,
    department_id        TEXT,
    role_title           TEXT,
    level                TEXT,
    grade                TEXT,
    band_min_annual      NUMERIC(14,2),
    band_mid_annual      NUMERIC(14,2),
    band_max_annual      NUMERIC(14,2),
    overtime_eligible    BOOLEAN,
    band_reference_year  INT
);

CREATE TABLE dw.dim_leave_type (
    leave_type_code       TEXT PRIMARY KEY,
    leave_type_name       TEXT,
    pay_type              TEXT,
    annual_quota_days     NUMERIC(6,2),
    prorated_for_joiners  BOOLEAN,
    carry_forward_allowed BOOLEAN,
    max_carry_forward_days NUMERIC(6,2),
    policy_note           TEXT
);

CREATE TABLE dw.dim_date (
    date_key         INT PRIMARY KEY,
    full_date        DATE,
    year             INT,
    month_number     INT,
    month_start_date DATE,
    month_end_date   DATE
);

CREATE TABLE dw.dim_employee (
    employee_key  SERIAL PRIMARY KEY,
    employee_id   TEXT NOT NULL,
    full_name     TEXT,
    department_id TEXT,
    role_id       TEXT,
    role_title    TEXT,
    job_level     TEXT,
    manager_id    TEXT,
    valid_from    DATE NOT NULL,
    valid_to      DATE NOT NULL,
    is_current    BOOLEAN,
    change_reason TEXT,
    UNIQUE (employee_id, valid_from)
);

CREATE TABLE dw.fact_payroll (
    payroll_item_id    TEXT PRIMARY KEY,
    run_id             TEXT NOT NULL,
    employee_id        TEXT NOT NULL,
    employee_key       INT,
    date_key           INT,
    period_end_date    DATE,
    department_id      TEXT,
    role_id            TEXT,
    gross_pay          NUMERIC(14,2),
    total_deductions   NUMERIC(14,2),
    net_pay            NUMERIC(14,2),
    employer_cost      NUMERIC(14,2)
);

CREATE TABLE dw.fact_attendance (
    attendance_id  TEXT PRIMARY KEY,
    employee_id    TEXT NOT NULL,
    employee_key   INT,
    date_key       INT,
    attendance_date DATE,
    status         TEXT,
    hours_worked   NUMERIC(6,2),
    late_flag      BOOLEAN
);

CREATE TABLE dw.fact_leave (
    leave_request_id TEXT PRIMARY KEY,
    employee_id      TEXT NOT NULL,
    employee_key     INT,
    leave_type_code  TEXT,
    start_date       DATE,
    end_date         DATE,
    days             NUMERIC(6,2),
    status           TEXT
);

CREATE TABLE dw.fact_headcount_monthly (
    date_key                 INT,
    month_start_date         DATE,
    department_id            TEXT,
    headcount_start          INT,
    hires                    INT,
    exits                    INT,
    transfers_in             INT,
    transfers_out            INT,
    headcount_end            INT,
    PRIMARY KEY (date_key, department_id)
);

CREATE INDEX ix_dim_employee_lookup ON dw.dim_employee (employee_id, valid_from, valid_to);
CREATE INDEX ix_fact_payroll_run    ON dw.fact_payroll (run_id);
CREATE INDEX ix_fact_payroll_emp    ON dw.fact_payroll (employee_key);
CREATE INDEX ix_fact_payroll_date   ON dw.fact_payroll (date_key);
CREATE INDEX ix_fact_attendance_emp ON dw.fact_attendance (employee_key, attendance_date);