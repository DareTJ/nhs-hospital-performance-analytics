/*
PROJECT: NHS Hospital Performance & Patient Flow Intelligence
SCRIPT: 18_create_ae_reporting_view.sql

PURPOSE:
I expose one typed record per source row for reporting and preserve
the provider and national records for separate comparisons.

I deploy this view only after approval. I leave the raw table unchanged.
I run script 19 before using the view in a report.
*/

USE [NHSHealthcareAnalytics];
GO

CREATE OR ALTER VIEW analytics.vw_ae_reporting_monthly
AS
WITH provider_periods AS
(
    SELECT
        source_file,
        MIN(UPPER(TRIM(period))) AS period_code
    FROM raw.ae_monthly
    WHERE UPPER(TRIM(org_code)) <> 'TOTAL'
    GROUP BY source_file
    HAVING COUNT(DISTINCT UPPER(TRIM(period))) = 1
       AND COUNT(period) = COUNT(*)
),
reporting_months AS
(
    SELECT
        p.source_file,
        TRY_CONVERT(date, CONCAT(RIGHT(p.period_code, 4), m.month_number, '01'), 112)
            AS reporting_month
    FROM provider_periods AS p
    INNER JOIN (VALUES
        ('JANUARY','01'), ('FEBRUARY','02'), ('MARCH','03'),
        ('APRIL','04'), ('MAY','05'), ('JUNE','06'),
        ('JULY','07'), ('AUGUST','08'), ('SEPTEMBER','09'),
        ('OCTOBER','10'), ('NOVEMBER','11'), ('DECEMBER','12')
    ) AS m(month_name, month_number)
        ON p.period_code = CONCAT('MSITAE-', m.month_name, '-', RIGHT(p.period_code, 4))
)
SELECT
    m.reporting_month,
    CASE
        WHEN UPPER(TRIM(r.org_code)) = 'RA7' AND m.reporting_month < '20260701'
            THEN 'RA7-PRE'
        ELSE UPPER(TRIM(r.org_code))
    END AS provider_key,
    UPPER(TRIM(r.org_code)) AS org_code,
    TRIM(r.org_name) AS org_name,
    CONVERT(bit, CASE WHEN UPPER(TRIM(r.org_code)) = 'TOTAL' THEN 1 ELSE 0 END)
        AS is_national,
    TRY_CONVERT(bigint, NULLIF(TRIM(r.ae_attendances_type1), '')) AS type1_attendances,
    TRY_CONVERT(bigint, NULLIF(TRIM(r.ae_attendances_type2), '')) AS type2_attendances,
    TRY_CONVERT(bigint, NULLIF(TRIM(r.ae_attendances_other), '')) AS other_attendances,
    TRY_CONVERT(bigint, NULLIF(TRIM(r.over4hrs_type1), '')) AS type1_over4hrs,
    TRY_CONVERT(bigint, NULLIF(TRIM(r.over4hrs_type2), '')) AS type2_over4hrs,
    TRY_CONVERT(bigint, NULLIF(TRIM(r.over4hrs_other), '')) AS other_over4hrs,
    TRY_CONVERT(bigint, NULLIF(TRIM(r.ae_booked_type1), '')) AS type1_booked,
    TRY_CONVERT(bigint, NULLIF(TRIM(r.over4hrs_booked_type1), '')) AS type1_booked_over4hrs,
    TRY_CONVERT(bigint, NULLIF(TRIM(r.dta_wait_4_to_12hrs), '')) AS dta_4_to_12hrs,
    TRY_CONVERT(bigint, NULLIF(TRIM(r.dta_wait_12plus_hrs), '')) AS dta_12plus_hrs,
    TRY_CONVERT(bigint, NULLIF(TRIM(r.emergency_admissions_ae_type1), '')) AS type1_admissions,
    TRY_CONVERT(bigint, NULLIF(TRIM(r.ae_booked_type2), '')) AS type2_booked,
    TRY_CONVERT(bigint, NULLIF(TRIM(r.ae_booked_other), '')) AS other_booked,
    TRY_CONVERT(bigint, NULLIF(TRIM(r.over4hrs_booked_type2), '')) AS type2_booked_over4hrs,
    TRY_CONVERT(bigint, NULLIF(TRIM(r.over4hrs_booked_other), '')) AS other_booked_over4hrs,
    TRY_CONVERT(bigint, NULLIF(TRIM(r.emergency_admissions_ae_type2), '')) AS type2_admissions,
    TRY_CONVERT(bigint, NULLIF(TRIM(r.emergency_admissions_ae_other), '')) AS other_ae_admissions,
    TRY_CONVERT(bigint, NULLIF(TRIM(r.other_emergency_admissions), '')) AS other_emergency_admissions,
    r.source_file,
    r.source_row_number
FROM raw.ae_monthly AS r
LEFT JOIN reporting_months AS m ON m.source_file = r.source_file;
GO
