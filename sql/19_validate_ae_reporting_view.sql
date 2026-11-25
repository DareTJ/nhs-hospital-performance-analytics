/*
PROJECT: NHS Hospital Performance & Patient Flow Intelligence
SCRIPT: 19_validate_ae_reporting_view.sql

PURPOSE:
I check the dashboard grain, values and monthly national reconciliation.
I also calculate the England Type 1 control totals for the portfolio period.
*/

USE [NHSHealthcareAnalytics];

SELECT reporting_month, org_code, COUNT(*) AS row_count
FROM analytics.vw_ae_reporting_monthly
GROUP BY reporting_month, org_code
HAVING COUNT(*) <> 1
    OR reporting_month IS NULL
    OR NULLIF(org_code, '') IS NULL;

SELECT reporting_month
FROM analytics.vw_ae_reporting_monthly
GROUP BY reporting_month
HAVING SUM(CONVERT(int, is_national)) <> 1;

SELECT r.source_file, r.source_row_number, v.measure_name
FROM analytics.vw_ae_reporting_monthly AS r
CROSS APPLY (VALUES
    ('type1_attendances', r.type1_attendances, NULL),
    ('type2_attendances', r.type2_attendances, NULL),
    ('other_attendances', r.other_attendances, NULL),
    ('type1_over4hrs', r.type1_over4hrs, r.type1_attendances),
    ('type2_over4hrs', r.type2_over4hrs, r.type2_attendances),
    ('other_over4hrs', r.other_over4hrs, r.other_attendances),
    ('type1_booked', r.type1_booked, NULL),
    ('type1_booked_over4hrs', r.type1_booked_over4hrs, r.type1_booked),
    ('dta_4_to_12hrs', r.dta_4_to_12hrs, NULL),
    ('dta_12plus_hrs', r.dta_12plus_hrs, NULL),
    ('type1_admissions', r.type1_admissions, NULL),
    ('type2_booked', r.type2_booked, NULL),
    ('other_booked', r.other_booked, NULL),
    ('type2_booked_over4hrs', r.type2_booked_over4hrs, r.type2_booked),
    ('other_booked_over4hrs', r.other_booked_over4hrs, r.other_booked),
    ('type2_admissions', r.type2_admissions, NULL),
    ('other_ae_admissions', r.other_ae_admissions, NULL),
    ('other_emergency_admissions', r.other_emergency_admissions, NULL)
) AS v(measure_name, measure_value, upper_bound)
WHERE v.measure_value IS NULL OR v.measure_value < 0
   OR v.measure_value > v.upper_bound;

WITH reconciliation AS
(
    SELECT
        r.reporting_month,
        v.measure_name,
        SUM(CASE WHEN r.is_national = 0 THEN v.measure_value END) AS providers,
        MAX(CASE WHEN r.is_national = 1 THEN v.measure_value END) AS england
    FROM analytics.vw_ae_reporting_monthly AS r
    CROSS APPLY (VALUES
        ('type1_attendances', r.type1_attendances),
        ('type2_attendances', r.type2_attendances),
        ('other_attendances', r.other_attendances),
        ('type1_over4hrs', r.type1_over4hrs),
        ('type2_over4hrs', r.type2_over4hrs),
        ('other_over4hrs', r.other_over4hrs),
        ('type1_booked', r.type1_booked),
        ('type1_booked_over4hrs', r.type1_booked_over4hrs),
        ('dta_4_to_12hrs', r.dta_4_to_12hrs),
        ('dta_12plus_hrs', r.dta_12plus_hrs),
        ('type1_admissions', r.type1_admissions),
        ('type2_booked', r.type2_booked),
        ('other_booked', r.other_booked),
        ('type2_booked_over4hrs', r.type2_booked_over4hrs),
        ('other_booked_over4hrs', r.other_booked_over4hrs),
        ('type2_admissions', r.type2_admissions),
        ('other_ae_admissions', r.other_ae_admissions),
        ('other_emergency_admissions', r.other_emergency_admissions)
    ) AS v(measure_name, measure_value)
    GROUP BY r.reporting_month, v.measure_name
)
SELECT reporting_month, measure_name, providers, england
FROM reconciliation
WHERE providers <> england OR providers IS NULL OR england IS NULL;

-- I verify the fixed reporting window and that the view preserves raw lineage.
SELECT COUNT(*) AS view_rows,
    COUNT(DISTINCT reporting_month) AS months_reported,
    MIN(reporting_month) AS first_month,
    MAX(reporting_month) AS last_month
FROM analytics.vw_ae_reporting_monthly
WHERE reporting_month BETWEEN '20240901' AND '20260801'
HAVING COUNT(*) <> 4751
    OR COUNT(DISTINCT reporting_month) <> 24
    OR MIN(reporting_month) <> '20240901'
    OR MAX(reporting_month) <> '20260801';

SELECT raw.source_file, raw.source_row_number
FROM raw.ae_monthly AS raw
LEFT JOIN analytics.vw_ae_reporting_monthly AS report
    ON report.source_file = raw.source_file
    AND report.source_row_number = raw.source_row_number
WHERE report.source_row_number IS NULL;

SELECT
    COUNT(DISTINCT reporting_month) AS months_reported,
    SUM(type1_attendances) AS england_type1_attendances,
    SUM(type1_over4hrs) AS england_type1_over4hrs,
    CAST(100.0 * (SUM(type1_attendances) - SUM(type1_over4hrs))
        / NULLIF(SUM(type1_attendances), 0) AS decimal(6,2)) AS within_4hr_percentage
FROM analytics.vw_ae_reporting_monthly
WHERE is_national = 1
  AND reporting_month BETWEEN '20240901' AND '20260801';
