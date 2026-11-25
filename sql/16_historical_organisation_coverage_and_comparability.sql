/*
PROJECT: NHS Hospital Performance & Patient Flow Intelligence
SCRIPT: 16_historical_organisation_coverage_and_comparability.sql

PURPOSE:
I assess organisation-level coverage across 24 months of NHS A&E data
(September 2024 to August 2026). I identify missing reporting months,
check organisation identity and classify reporting gaps before making
like-for-like performance comparisons.
*/

USE [NHSHealthcareAnalytics];

-- I use temporary tables so the original NHS data remains unchanged.
DROP TABLE IF EXISTS #monthly_reporting;
DROP TABLE IF EXISTS #reporting_calendar;
DROP TABLE IF EXISTS #organisation_coverage;

-- 1. I prepare a valid reporting date and exclude national TOTAL rows.
WITH prepared AS
(
    SELECT
        UPPER(LTRIM(RTRIM(org_code))) AS org_code,
        LTRIM(RTRIM(org_name)) AS org_name,
        UPPER(LTRIM(RTRIM(period))) AS period,
        source_file,
        CASE
            WHEN UPPER(period) LIKE '%JANUARY%' THEN 1
            WHEN UPPER(period) LIKE '%FEBRUARY%' THEN 2
            WHEN UPPER(period) LIKE '%MARCH%' THEN 3
            WHEN UPPER(period) LIKE '%APRIL%' THEN 4
            WHEN UPPER(period) LIKE '%MAY%' THEN 5
            WHEN UPPER(period) LIKE '%JUNE%' THEN 6
            WHEN UPPER(period) LIKE '%JULY%' THEN 7
            WHEN UPPER(period) LIKE '%AUGUST%' THEN 8
            WHEN UPPER(period) LIKE '%SEPTEMBER%' THEN 9
            WHEN UPPER(period) LIKE '%OCTOBER%' THEN 10
            WHEN UPPER(period) LIKE '%NOVEMBER%' THEN 11
            WHEN UPPER(period) LIKE '%DECEMBER%' THEN 12
        END AS month_number
    FROM raw.ae_monthly
    WHERE org_code IS NOT NULL
      AND UPPER(LTRIM(RTRIM(org_code))) <> 'TOTAL'
)
SELECT
    org_code,
    org_name,
    source_file,
    period,
    TRY_CONVERT(DATE, CONCAT(
        RIGHT(period, 4), '-',
        RIGHT(CONCAT('0', month_number), 2), '-01'
    )) AS reporting_month
INTO #monthly_reporting
FROM prepared;

-- 2. I check the dataset and look for invalid reporting dates.
SELECT
    (SELECT COUNT(*) FROM raw.ae_monthly) AS raw_records,
    (SELECT COUNT(*) FROM raw.ae_monthly
     WHERE UPPER(LTRIM(RTRIM(org_code))) = 'TOTAL') AS national_records,
    COUNT(*) AS organisation_records,
    COUNT(DISTINCT reporting_month) AS distinct_months
FROM #monthly_reporting;
-- Expected: 4751 raw, 24 national, 4727 organisation records, 24 months.

SELECT org_code, period, source_file
FROM #monthly_reporting
WHERE reporting_month IS NULL
   OR reporting_month NOT BETWEEN '20240901' AND '20260801';
-- Expected: zero rows.

-- 3. I check that organisation-month records are unique.
SELECT org_code, reporting_month, COUNT(*) AS record_count
FROM #monthly_reporting
GROUP BY org_code, reporting_month
HAVING COUNT(*) > 1;
-- Expected: zero rows.

-- I flag codes associated with different names for further review.
SELECT
    org_code,
    COUNT(DISTINCT UPPER(org_name)) AS distinct_names,
    MIN(org_name) AS example_name_1,
    MAX(org_name) AS example_name_2
FROM #monthly_reporting
GROUP BY org_code
HAVING COUNT(DISTINCT UPPER(org_name)) > 1
ORDER BY org_code;
-- I will inspect any returned rows before finalising provider comparisons.

-- I check when each reported name was used for codes with name changes.
WITH name_variations AS
(
    SELECT org_code
    FROM #monthly_reporting
    GROUP BY org_code
    HAVING COUNT(DISTINCT UPPER(org_name)) > 1
)
SELECT
    m.org_code,
    m.org_name,
    COUNT(DISTINCT m.reporting_month) AS months_reported,
    MIN(m.reporting_month) AS first_reported_month,
    MAX(m.reporting_month) AS last_reported_month
FROM #monthly_reporting AS m
INNER JOIN name_variations AS v
    ON m.org_code = v.org_code
GROUP BY m.org_code, m.org_name
ORDER BY m.org_code, first_reported_month;
-- Observed: 12 codes with 2 names each (24 name histories).
-- Their name histories appear sequentially, without overlapping months.
-- This does not establish whether their underlying reporting scope changed.

-- 4. I create the full 24-month comparison calendar.
WITH reporting_calendar AS
(
    SELECT CAST('20240901' AS DATE) AS reporting_month
    UNION ALL
    SELECT DATEADD(MONTH, 1, reporting_month)
    FROM reporting_calendar
    WHERE reporting_month < '20260801'
)
SELECT reporting_month
INTO #reporting_calendar
FROM reporting_calendar
OPTION (MAXRECURSION 24);

-- 5. I measure the coverage of every organisation.
SELECT
    org_code,
    MAX(org_name) AS org_name,
    COUNT(DISTINCT reporting_month) AS months_reported,
    COUNT(DISTINCT source_file) AS files_reported,
    MIN(reporting_month) AS first_month,
    MAX(reporting_month) AS last_month
INTO #organisation_coverage
FROM #monthly_reporting
WHERE reporting_month BETWEEN '20240901' AND '20260801'
GROUP BY org_code;

SELECT
    COUNT(*) AS organisations,
    SUM(CASE WHEN months_reported = 24 THEN 1 ELSE 0 END)
        AS complete_coverage,
    SUM(CASE WHEN months_reported < 24 THEN 1 ELSE 0 END)
        AS incomplete_coverage,
    SUM(CASE WHEN months_reported <> files_reported THEN 1 ELSE 0 END)
        AS file_period_mismatches
FROM #organisation_coverage;
-- Expected: 207 organisations, 181 complete, 26 incomplete, 0 mismatches.

-- 6. I identify missing combinations of organisation and month.
SELECT
    COUNT(*) AS missing_organisation_months
FROM #organisation_coverage AS o
CROSS JOIN #reporting_calendar AS c
WHERE NOT EXISTS
(
    SELECT 1
    FROM #monthly_reporting AS m
    WHERE m.org_code = o.org_code
      AND m.reporting_month = c.reporting_month
);
-- Expected: 241 missing organisation-month combinations.

-- 7. I classify incomplete histories to support fair comparisons.
WITH reporting_gaps AS
(
    SELECT
        org_code,
        org_name,
        months_reported,
        DATEDIFF(MONTH, '20240901', first_month) AS leading_gaps,
        DATEDIFF(MONTH, first_month, last_month) + 1
            - months_reported AS internal_gaps,
        DATEDIFF(MONTH, last_month, '20260801') AS trailing_gaps
    FROM #organisation_coverage
)
SELECT
    org_code,
    org_name,
    months_reported,
    leading_gaps,
    internal_gaps,
    trailing_gaps,
    CASE
        WHEN internal_gaps > 0 THEN 'Internal or combined gaps'
        WHEN leading_gaps > 0 AND trailing_gaps > 0
            THEN 'Leading and trailing gaps'
        WHEN leading_gaps > 0 THEN 'Leading gaps only'
        WHEN trailing_gaps > 0 THEN 'Trailing gaps only'
        ELSE 'Review required'
    END AS coverage_pattern
FROM reporting_gaps
WHERE months_reported < 24
ORDER BY months_reported DESC, org_name;
-- Expected: 26 incomplete organisations.

/*
FINDINGS:
I identified 181 organisations with complete reporting coverage and 26
with incomplete histories. I found 241 missing organisation-month combinations.
I also identified 12 organisation codes with two reported names each. Their
name histories appear in consecutive periods without overlapping months.
I flag these codes for comparability review rather than assuming that name
continuity or code continuity guarantees an unchanged reporting scope.

LIMITATION:
I cannot conclude from a missing record alone that an organisation failed
to report, closed or merged. I will review provider identity and reporting
scope before making operational comparisons.
*/

-- I remove only the temporary tables created for this analysis.
DROP TABLE IF EXISTS #organisation_coverage;
DROP TABLE IF EXISTS #reporting_calendar;
DROP TABLE IF EXISTS #monthly_reporting;
