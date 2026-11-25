
/*
PROJECT: NHS Hospital Performance & Patient Flow Intelligence
SCRIPT: 13_ae_long_wait_burden.sql

PURPOSE:
I compare the number of Type 1 A&E attendances exceeding
four hours in April and August 2026.

I account for differences in the number of calendar days
to make monthly activity volumes more comparable.
*/

WITH monthly_data AS
(
    SELECT
        org_code,
        MAX(org_name) AS org_name,

        MAX(CASE
            WHEN UPPER(period) = 'MSITAE-APRIL-2026'
            THEN TRY_CONVERT(BIGINT, over4hrs_type1)
        END) AS april_over4hrs,

        MAX(CASE
            WHEN UPPER(period) = 'MSITAE-AUGUST-2026'
            THEN TRY_CONVERT(BIGINT, over4hrs_type1)
        END) AS august_over4hrs,

        MAX(CASE
            WHEN UPPER(period) = 'MSITAE-AUGUST-2026'
            THEN TRY_CONVERT(BIGINT, ae_attendances_type1)
        END) AS august_attendances

    FROM raw.ae_monthly

    WHERE org_code IN (
        'RCB', 'RVV', 'RAX', 'RBK', 'RWD',
        'RXL', 'RNZ', 'RVW', 'RTP', 'RFS'
    )
    AND UPPER(period) IN (
        'MSITAE-APRIL-2026',
        'MSITAE-AUGUST-2026'
    )

    GROUP BY org_code
)

SELECT
    org_code,
    org_name,
    april_over4hrs,
    august_over4hrs,

    CAST(
        april_over4hrs / 30.0
        AS DECIMAL(10,1)
    ) AS april_daily_over4hrs,

    CAST(
        august_over4hrs / 31.0
        AS DECIMAL(10,1)
    ) AS august_daily_over4hrs,

    CAST(
        august_over4hrs / 31.0 - april_over4hrs / 30.0
        AS DECIMAL(10,1)
    ) AS change_daily_over4hrs,

    CAST(
        100.0 * august_over4hrs
        / NULLIF(august_attendances, 0)
        AS DECIMAL(6,2)
    ) AS august_over4hrs_pct

FROM monthly_data

WHERE april_over4hrs IS NOT NULL
  AND august_over4hrs IS NOT NULL
  AND august_attendances > 0

ORDER BY august_over4hrs DESC;
