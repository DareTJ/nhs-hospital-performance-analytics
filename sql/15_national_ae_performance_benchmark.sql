
/*
PROJECT: NHS Hospital Performance & Patient Flow Intelligence
SCRIPT: 15_national_ae_performance_benchmark.sql

PURPOSE:
I examine national Type 1 A&E performance between
April and August 2026 to provide a benchmark for
my trust-level performance analysis.
*/

WITH national_performance AS
(
    SELECT
        CASE
            WHEN source_file LIKE 'April-2026-%' THEN '2026-04'
            WHEN source_file LIKE 'May-2026-%' THEN '2026-05'
            WHEN source_file LIKE 'June-2026-%' THEN '2026-06'
            WHEN source_file LIKE 'July-2026-%' THEN '2026-07'
            WHEN source_file LIKE 'August-2026-%' THEN '2026-08'
        END AS reporting_month,

        TRY_CONVERT(BIGINT, ae_attendances_type1)
            AS type1_attendances,

        TRY_CONVERT(BIGINT, over4hrs_type1)
            AS type1_over4hrs

    FROM raw.ae_monthly

    -- Use published national totals without double-counting providers.
    WHERE UPPER(TRIM(org_code)) = 'TOTAL'
)

SELECT
    reporting_month,
    type1_attendances,
    type1_over4hrs,

    CAST(
        100.0 * type1_over4hrs
        / NULLIF(type1_attendances, 0)
        AS DECIMAL(6,2)
    ) AS national_over4hrs_pct

FROM national_performance

WHERE reporting_month IS NOT NULL

ORDER BY reporting_month;
