/*
PROJECT: NHS Hospital Performance & Patient Flow Intelligence
SCRIPT: 17_type1_ae_performance_comparability.sql

PURPOSE:
I assess Type 1 A&E performance across September 2024 to August 2026.
I validate the measures, define a consistent 24-month provider cohort,
reconcile results with national totals, and compare monthly and annual trends.
I keep booked Type 1 appointments separate and flag organisation name changes.
*/

USE [NHSHealthcareAnalytics];

-- I prepare reusable reporting records without changing the raw table.
DROP TABLE IF EXISTS #s17_data;

WITH reporting_periods AS
(
    SELECT
        source_file,
        MAX(LTRIM(RTRIM(period))) AS reporting_period
    FROM raw.ae_monthly
    WHERE org_code IS NOT NULL
      AND UPPER(LTRIM(RTRIM(org_code))) <> 'TOTAL'
    GROUP BY source_file
),
monthly_dates AS
(
    SELECT
        source_file,
        TRY_CONVERT(INT, RIGHT(reporting_period, 4)) AS report_year,
        CASE
            WHEN reporting_period LIKE '%JANUARY%' THEN 1
            WHEN reporting_period LIKE '%FEBRUARY%' THEN 2
            WHEN reporting_period LIKE '%MARCH%' THEN 3
            WHEN reporting_period LIKE '%APRIL%' THEN 4
            WHEN reporting_period LIKE '%MAY%' THEN 5
            WHEN reporting_period LIKE '%JUNE%' THEN 6
            WHEN reporting_period LIKE '%JULY%' THEN 7
            WHEN reporting_period LIKE '%AUGUST%' THEN 8
            WHEN reporting_period LIKE '%SEPTEMBER%' THEN 9
            WHEN reporting_period LIKE '%OCTOBER%' THEN 10
            WHEN reporting_period LIKE '%NOVEMBER%' THEN 11
            WHEN reporting_period LIKE '%DECEMBER%' THEN 12
        END AS report_month
    FROM reporting_periods
)
SELECT
    a.source_file,
    DATEFROMPARTS(m.report_year, m.report_month, 1) AS reporting_month,
    UPPER(LTRIM(RTRIM(a.org_code))) AS org_code,
    LTRIM(RTRIM(a.org_name)) AS org_name,
    CASE WHEN UPPER(LTRIM(RTRIM(a.org_code))) = 'TOTAL'
         THEN 1 ELSE 0 END AS is_national,
    TRY_CONVERT(BIGINT, a.ae_attendances_type1) AS type1_attendances,
    TRY_CONVERT(BIGINT, a.over4hrs_type1) AS type1_over4hrs,
    TRY_CONVERT(BIGINT, a.ae_booked_type1) AS booked_type1_attendances,
    TRY_CONVERT(BIGINT, a.over4hrs_booked_type1) AS booked_type1_over4hrs
INTO #s17_data
FROM raw.ae_monthly a
INNER JOIN monthly_dates m ON a.source_file = m.source_file;

-- 1. I verify numerical integrity before calculating any rates.
SELECT
    COUNT(*) AS organisation_month_records,
    SUM(CASE WHEN type1_attendances IS NULL THEN 1 ELSE 0 END)
        AS invalid_attendance_values,
    SUM(CASE WHEN type1_over4hrs IS NULL THEN 1 ELSE 0 END)
        AS invalid_over4hrs_values,
    SUM(CASE WHEN type1_attendances < 0 OR type1_over4hrs < 0
        THEN 1 ELSE 0 END) AS negative_value_records,
    SUM(CASE WHEN type1_over4hrs > type1_attendances
        THEN 1 ELSE 0 END) AS over4hrs_exceeds_attendances
FROM #s17_data
WHERE is_national = 0;

-- 2. I identify organisations with positive Type 1 activity in all 24 months.
DROP TABLE IF EXISTS #s17_cohort;

WITH organisation_history AS
(
    SELECT
        org_code,
        COUNT(DISTINCT reporting_month) AS months_reported,
        SUM(CASE WHEN type1_attendances > 0 THEN 1 ELSE 0 END)
            AS positive_activity_months,
        SUM(type1_attendances) AS total_attendances,
        COUNT(DISTINCT UPPER(org_name)) AS distinct_names
    FROM #s17_data
    WHERE is_national = 0
    GROUP BY org_code
),
latest_names AS
(
    SELECT
        org_code,
        org_name,
        ROW_NUMBER() OVER (
            PARTITION BY org_code
            ORDER BY reporting_month DESC, org_name
        ) AS name_order
    FROM #s17_data
    WHERE is_national = 0
)
SELECT
    h.org_code,
    n.org_name AS latest_reported_name,
    h.months_reported,
    h.positive_activity_months,
    h.total_attendances,
    h.distinct_names,
    CASE WHEN h.months_reported = 24
               AND h.positive_activity_months = 24
         THEN 1 ELSE 0 END AS in_complete_cohort
INTO #s17_cohort
FROM organisation_history h
INNER JOIN latest_names n
    ON h.org_code = n.org_code AND n.name_order = 1;

SELECT
    COUNT(*) AS total_organisations,
    SUM(CASE WHEN total_attendances > 0 THEN 1 ELSE 0 END)
        AS organisations_with_type1_activity,
    SUM(CASE WHEN total_attendances = 0 THEN 1 ELSE 0 END)
        AS organisations_without_type1_activity,
    SUM(in_complete_cohort) AS complete_type1_cohort
FROM #s17_cohort;

-- 3. I compare all provider records, my complete cohort and national totals.
WITH performance_groups AS
(
    SELECT
        'All reporting organisations' AS comparison_group,
        d.type1_attendances AS attendances,
        d.type1_over4hrs AS over4hrs
    FROM #s17_data d
    WHERE d.is_national = 0

    UNION ALL

    SELECT
        'Complete Type 1 cohort (120)',
        d.type1_attendances,
        d.type1_over4hrs
    FROM #s17_data d
    INNER JOIN #s17_cohort c ON d.org_code = c.org_code
    WHERE c.in_complete_cohort = 1 AND d.is_national = 0

    UNION ALL

    SELECT 'Published national totals', type1_attendances, type1_over4hrs
    FROM #s17_data
    WHERE is_national = 1
)
SELECT
    comparison_group,
    COUNT(*) AS records,
    SUM(attendances) AS total_attendances,
    SUM(over4hrs) AS total_over4hrs,
    CAST(100.0 * (SUM(attendances) - SUM(over4hrs))
         / NULLIF(SUM(attendances), 0) AS DECIMAL(6,2))
         AS within_4hr_percentage
FROM performance_groups
GROUP BY comparison_group
ORDER BY comparison_group;

-- 4. I calculate activity-weighted rates for the 120 complete-history providers.
SELECT
    c.org_code,
    c.latest_reported_name AS org_name,
    c.months_reported,
    SUM(d.type1_attendances) AS total_type1_attendances,
    SUM(d.type1_over4hrs) AS total_over4hrs,
    CAST(100.0 * (SUM(d.type1_attendances) - SUM(d.type1_over4hrs))
         / NULLIF(SUM(d.type1_attendances), 0) AS DECIMAL(6,2))
         AS within_4hr_percentage,
    CASE WHEN c.distinct_names > 1 THEN 'Name history review'
         ELSE 'No name variation detected' END AS comparability_note
FROM #s17_data d
INNER JOIN #s17_cohort c ON d.org_code = c.org_code
WHERE d.is_national = 0 AND c.in_complete_cohort = 1
GROUP BY c.org_code, c.latest_reported_name, c.months_reported, c.distinct_names
ORDER BY within_4hr_percentage DESC, c.org_code;

-- 5. I track national monthly performance using the reconciled TOTAL rows.
SELECT
    reporting_month,
    SUM(type1_attendances) AS type1_attendances,
    SUM(type1_over4hrs) AS type1_over4hrs,
    CAST(100.0 * (SUM(type1_attendances) - SUM(type1_over4hrs))
         / NULLIF(SUM(type1_attendances), 0) AS DECIMAL(6,2))
         AS within_4hr_percentage
FROM #s17_data
WHERE is_national = 1
GROUP BY reporting_month
ORDER BY reporting_month;

-- 6. I compare two equal September-to-August reporting years.
SELECT
    CASE WHEN reporting_month < '20250901' THEN 'Sep 2024 - Aug 2025'
         ELSE 'Sep 2025 - Aug 2026' END AS reporting_year,
    COUNT(*) AS months_reported,
    SUM(type1_attendances) AS total_attendances,
    SUM(type1_over4hrs) AS total_over4hrs,
    CAST(100.0 * (SUM(type1_attendances) - SUM(type1_over4hrs))
         / NULLIF(SUM(type1_attendances), 0) AS DECIMAL(6,2))
         AS within_4hr_percentage
FROM #s17_data
WHERE is_national = 1
  AND reporting_month BETWEEN '20240901' AND '20260801'
GROUP BY CASE WHEN reporting_month < '20250901'
              THEN 'Sep 2024 - Aug 2025'
              ELSE 'Sep 2025 - Aug 2026' END
ORDER BY reporting_year;

-- 7. I report booked Type 1 activity separately from the main Type 1 KPI.
SELECT
    COUNT(*) AS national_months,
    SUM(type1_attendances) AS type1_attendances,
    SUM(type1_over4hrs) AS type1_over4hrs,
    SUM(booked_type1_attendances) AS booked_type1_attendances,
    SUM(booked_type1_over4hrs) AS booked_type1_over4hrs,
    CAST(100.0 * (SUM(booked_type1_attendances)
               - SUM(booked_type1_over4hrs))
         / NULLIF(SUM(booked_type1_attendances), 0) AS DECIMAL(6,2))
         AS booked_within_4hr_percentage
FROM #s17_data
WHERE is_national = 1;

/*
KEY FINDINGS (validated in the individual steps; reconfirm with this script):
I found 120 organisations with positive Type 1 activity in all 24 months.
I reconciled 33,523,262 attendances and 13,400,360 over-four-hour
attendances to national totals, giving an activity-weighted rate of 60.03%.
The two September-to-August years produced rates of 59.28% and 60.75%.
I retain the original reporting records and flag changing provider names.

LIMITATIONS:
The cohort contains different hospital types and may include changes in
operational scope. These descriptive rates do not establish causation or
provide a fully risk-adjusted provider ranking. Booked visits are separate.
*/

-- I remove only my temporary working tables after producing the results.
DROP TABLE IF EXISTS #s17_cohort;
DROP TABLE IF EXISTS #s17_data;
