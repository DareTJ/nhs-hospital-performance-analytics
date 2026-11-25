
/*
PROJECT: NHS Hospital Performance & Patient Flow Intelligence
SCRIPT: 11_ae_five_month_performance_trends.sql

PURPOSE:
I examine the monthly A&E performance of the ten trusts
identified in my earlier deterioration analysis.

This helps me distinguish sustained deterioration
from changes between two reporting months.
*/

WITH monthly_performance AS
(
    SELECT
        r.org_code,
        r.org_name,
        m.reporting_month,

        TRY_CONVERT(BIGINT, r.ae_attendances_type1)
            AS type1_attendances,

        TRY_CONVERT(BIGINT, r.over4hrs_type1)
            AS over4hrs_attendances

    FROM raw.ae_monthly AS r

    INNER JOIN (
        VALUES
            ('MSITAE-APRIL-2026', '2026-04'),
            ('MSITAE-MAY-2026', '2026-05'),
            ('MSITAE-JUNE-2026', '2026-06'),
            ('MSITAE-JULY-2026', '2026-07'),
            ('MSITAE-AUGUST-2026', '2026-08')
    ) AS m(period_code, reporting_month)
        ON UPPER(LTRIM(RTRIM(r.period))) = m.period_code

    WHERE r.org_code IN (
        'RCB', 'RVV', 'RAX', 'RBK', 'RWD',
        'RXL', 'RNZ', 'RVW', 'RTP', 'RFS'
    )
),

-- Calculate each month's Type 1 over-four-hour percentage.

monthly_rates AS
(
    SELECT
        org_code,
        org_name,
        reporting_month,
        type1_attendances,

        CAST(
            100.0 * over4hrs_attendances
            / NULLIF(type1_attendances, 0)
            AS DECIMAL(6,2)
        ) AS over4hrs_percentage

    FROM monthly_performance
)

-- Display all five months for each organisation.

SELECT
    org_code,
    MAX(org_name) AS org_name,

    MAX(CASE WHEN reporting_month = '2026-04'
        THEN over4hrs_percentage END) AS april_pct,

    MAX(CASE WHEN reporting_month = '2026-05'
        THEN over4hrs_percentage END) AS may_pct,

    MAX(CASE WHEN reporting_month = '2026-06'
        THEN over4hrs_percentage END) AS june_pct,

    MAX(CASE WHEN reporting_month = '2026-07'
        THEN over4hrs_percentage END) AS july_pct,

    MAX(CASE WHEN reporting_month = '2026-08'
        THEN over4hrs_percentage END) AS august_pct,

    MAX(CASE WHEN reporting_month = '2026-04'
        THEN type1_attendances END) AS april_attendances,

    MAX(CASE WHEN reporting_month = '2026-08'
        THEN type1_attendances END) AS august_attendances

FROM monthly_rates

GROUP BY org_code
ORDER BY org_code;
