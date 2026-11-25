
/*
PROJECT: NHS Hospital Performance & Patient Flow Intelligence
SCRIPT: 12_ae_deterioration_and_demand.sql

PURPOSE:
I assess whether worsening Type 1 A&E performance was
continuous or fluctuating across the ten trusts identified
in my earlier analysis.

I also compare attendance volumes to understand whether
changes in demand accompanied the performance deterioration.
*/

WITH monthly_rates AS
(
    SELECT
        r.org_code,
        r.org_name,
        m.month_number,

        TRY_CONVERT(BIGINT, r.ae_attendances_type1)
            AS type1_attendances,

        100.0 * TRY_CONVERT(BIGINT, r.over4hrs_type1)
        / NULLIF(
            TRY_CONVERT(BIGINT, r.ae_attendances_type1), 0
        ) AS over4hrs_rate

    FROM raw.ae_monthly AS r

    INNER JOIN (
        VALUES
            ('MSITAE-APRIL-2026', 1),
            ('MSITAE-MAY-2026', 2),
            ('MSITAE-JUNE-2026', 3),
            ('MSITAE-JULY-2026', 4),
            ('MSITAE-AUGUST-2026', 5)
    ) AS m(period_code, month_number)
        ON UPPER(LTRIM(RTRIM(r.period))) = m.period_code

    WHERE r.org_code IN (
        'RCB', 'RVV', 'RAX', 'RBK', 'RWD',
        'RXL', 'RNZ', 'RVW', 'RTP', 'RFS'
    )
),

-- Compare each month's rate with the preceding month.

monthly_changes AS
(
    SELECT
        *,
        LAG(over4hrs_rate) OVER (
            PARTITION BY org_code
            ORDER BY month_number
        ) AS previous_month_rate

    FROM monthly_rates
),

trust_summary AS
(
    SELECT
        org_code,
        MAX(org_name) AS org_name,

        COUNT(*) AS months_reported,

        SUM(CASE
            WHEN over4hrs_rate > previous_month_rate
            THEN 1 ELSE 0
        END) AS worsening_intervals,

        MAX(CASE WHEN month_number = 1
            THEN type1_attendances END) AS april_attendances,

        MAX(CASE WHEN month_number = 5
            THEN type1_attendances END) AS august_attendances,

        MAX(CASE WHEN month_number = 1
            THEN over4hrs_rate END) AS april_rate,

        MAX(CASE WHEN month_number = 5
            THEN over4hrs_rate END) AS august_rate

    FROM monthly_changes
    GROUP BY org_code
)

-- Summarise performance patterns and attendance changes.

SELECT
    org_code,
    org_name,
    worsening_intervals,

    CASE
        WHEN worsening_intervals = 4
            THEN 'Continuous deterioration'
        ELSE 'Fluctuating deterioration'
    END AS performance_pattern,

    april_attendances,
    august_attendances,

    CAST(
        100.0 * (august_attendances - april_attendances)
        / NULLIF(april_attendances, 0)
        AS DECIMAL(8,2)
    ) AS attendance_change_pct,

    CAST(
        august_rate - april_rate
        AS DECIMAL(6,2)
    ) AS performance_change_pp

FROM trust_summary
WHERE months_reported = 5

ORDER BY
    worsening_intervals DESC,
    performance_change_pp DESC;
