
/*
PROJECT: NHS Hospital Performance & Patient Flow Intelligence
SCRIPT: 14_ae_decision_to_admit_delays.sql

PURPOSE:
I investigate changes in 12-hour decision-to-admit waits
across the ten trusts identified in my A&E analysis.

I compare average daily delays to account for differences
in the number of days between reporting months.
*/

WITH admission_delays AS
(
    SELECT
        org_code,
        MAX(org_name) AS org_name,

        MAX(CASE
            WHEN UPPER(LTRIM(RTRIM(period))) =
                 'MSITAE-APRIL-2026'
            THEN TRY_CONVERT(BIGINT, dta_wait_12plus_hrs)
        END) AS april_dta_12plus,

        MAX(CASE
            WHEN UPPER(LTRIM(RTRIM(period))) =
                 'MSITAE-AUGUST-2026'
            THEN TRY_CONVERT(BIGINT, dta_wait_12plus_hrs)
        END) AS august_dta_12plus

    FROM raw.ae_monthly

    WHERE org_code IN (
        'RCB', 'RVV', 'RAX', 'RBK', 'RWD',
        'RXL', 'RNZ', 'RVW', 'RTP', 'RFS'
    )

    GROUP BY org_code
)

-- Compare the daily volume of long admission delays.

SELECT
    org_code,
    org_name,
    april_dta_12plus,
    august_dta_12plus,

    CAST(
        april_dta_12plus / 30.0
        AS DECIMAL(10,2)
    ) AS april_daily_dta,

    CAST(
        august_dta_12plus / 31.0
        AS DECIMAL(10,2)
    ) AS august_daily_dta,

    CAST(
        august_dta_12plus / 31.0
        - april_dta_12plus / 30.0
        AS DECIMAL(10,2)
    ) AS change_daily_dta

FROM admission_delays

WHERE april_dta_12plus IS NOT NULL
  AND august_dta_12plus IS NOT NULL

ORDER BY change_daily_dta DESC;
