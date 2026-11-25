
/*
PROJECT: NHS Hospital Performance & Patient Flow Intelligence
SCRIPT: 10_identify_ae_performance_deterioration.sql

PURPOSE:
I identify NHS organisations with the greatest increase
in Type 1 A&E attendances exceeding four hours between
April and August 2026.

I use organisations with consistent monthly reporting
and exclude the Bristol merger from this initial comparison.
*/

WITH monthly_performance AS
(
    SELECT
        org_code,
        org_name,
        UPPER(LTRIM(RTRIM(period))) AS reporting_period,

        TRY_CONVERT(BIGINT, ae_attendances_type1)
            AS type1_attendances,

        TRY_CONVERT(BIGINT, over4hrs_type1)
            AS over4hrs_attendances

    FROM raw.ae_monthly

    WHERE UPPER(LTRIM(RTRIM(period))) IN (
        'MSITAE-APRIL-2026',
        'MSITAE-MAY-2026',
        'MSITAE-JUNE-2026',
        'MSITAE-JULY-2026',
        'MSITAE-AUGUST-2026'
    )
    AND org_code NOT IN ('RA7', 'RVJ')
),

-- Select organisations with valid Type 1 data in all five months.

consistent_organisations AS
(
    SELECT org_code
    FROM monthly_performance
    GROUP BY org_code
    HAVING COUNT(DISTINCT reporting_period) = 5
       AND MIN(type1_attendances) > 0
       AND SUM(
           CASE
               WHEN over4hrs_attendances IS NULL
                 OR over4hrs_attendances < 0
                 OR over4hrs_attendances > type1_attendances
               THEN 1 ELSE 0
           END
       ) = 0
),

-- Compare the April and August waiting-time percentages.

performance_comparison AS
(
    SELECT
        m.org_code,
        MAX(m.org_name) AS org_name,

        MAX(CASE
            WHEN reporting_period = 'MSITAE-APRIL-2026'
            THEN 100.0 * over4hrs_attendances
                 / NULLIF(type1_attendances, 0)
        END) AS april_over4hrs_pct,

        MAX(CASE
            WHEN reporting_period = 'MSITAE-AUGUST-2026'
            THEN 100.0 * over4hrs_attendances
                 / NULLIF(type1_attendances, 0)
        END) AS august_over4hrs_pct

    FROM monthly_performance AS m

    INNER JOIN consistent_organisations AS c
        ON m.org_code = c.org_code

    GROUP BY m.org_code
)

SELECT TOP (10)
    org_code,
    org_name,

    CAST(april_over4hrs_pct AS DECIMAL(6,2))
        AS april_over4hrs_pct,

    CAST(august_over4hrs_pct AS DECIMAL(6,2))
        AS august_over4hrs_pct,

    CAST(
        august_over4hrs_pct - april_over4hrs_pct
        AS DECIMAL(6,2)
    ) AS change_percentage_points

FROM performance_comparison

ORDER BY
    change_percentage_points DESC,
    org_code;
