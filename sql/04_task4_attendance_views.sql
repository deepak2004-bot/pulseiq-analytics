CREATE OR REPLACE VIEW task4.vw_att_month AS
SELECT date_trunc('month', period_end_date::date)::date AS month_start,
       (SUM(present_days) + 0.5*SUM(half_days_unpaid))::numeric / NULLIF(SUM(scheduled_days),0) AS attendance_rate_m13,
       SUM(late_arrivals)::numeric / NULLIF(SUM(present_days),0) AS late_rate_m14,
       SUM(late_arrivals) AS late_arrivals,
       COUNT(DISTINCT employee_id) AS employees
FROM task4.fact_attendance_monthly
GROUP BY 1;

CREATE OR REPLACE VIEW task4.vw_att_month_dept AS
SELECT date_trunc('month', f.period_end_date::date)::date AS month_start,
       d.department_name,
       (SUM(f.present_days) + 0.5*SUM(f.half_days_unpaid))::numeric / NULLIF(SUM(f.scheduled_days),0) AS attendance_rate_m13,
       SUM(f.late_arrivals)::numeric / NULLIF(SUM(f.present_days),0) AS late_rate_m14,
       COUNT(DISTINCT f.employee_id) AS employees
FROM task4.fact_attendance_monthly f
JOIN task4.dim_department d ON d.department_id = f.department_id
GROUP BY 1, 2
HAVING COUNT(DISTINCT f.employee_id) >= 5;

CREATE OR REPLACE VIEW task4.vw_att_weekday AS
SELECT EXTRACT(ISODOW FROM attendance_date::date)::int AS weekday_no,
       to_char(attendance_date::date, 'Dy') AS weekday,
       (SUM(CASE WHEN status IN ('PRESENT','WFH') THEN 1 WHEN status='HALF_DAY_UNPAID' THEN 0.5 ELSE 0 END))::numeric
         / COUNT(*) AS attendance_rate_m13
FROM task4.attendance_daily
GROUP BY 1, 2;

CREATE OR REPLACE VIEW task4.vw_leave_type_month AS
SELECT date_trunc('month', l.start_date::date)::date AS month_start,
       t.leave_type_name,
       SUM(l.days) AS leave_days
FROM task4.fact_leave l
JOIN task4.dim_leave_type t ON t.leave_type_code = l.leave_type_code
WHERE l.status = 'Approved'
GROUP BY 1, 2;

CREATE OR REPLACE VIEW task4.vw_ai_flags_month AS
SELECT period::date AS month_start, COUNT(*) AS ai_flag_count
FROM task4.fact_anomaly
WHERE source_dataset = 'attendance_monthly_features' AND flagged = 'Y'
GROUP BY 1;

CREATE OR REPLACE VIEW task4.vw_att_month_ai AS
SELECT m.month_start,
       m.attendance_rate_m13,
       m.late_rate_m14,
       COALESCE(f.ai_flag_count, 0) AS ai_flag_count
FROM task4.vw_att_month m
LEFT JOIN task4.vw_ai_flags_month f ON f.month_start = m.month_start;