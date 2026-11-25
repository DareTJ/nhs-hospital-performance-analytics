/*
PROJECT: NHS Hospital Performance & Patient Flow Intelligence
SCRIPT: 21_comparable_provider_pressure.sql

PURPOSE:
I identify persistent Type 1 performance changes on matched months.
The fixed cohort requires 24 positive-activity months and one reported
name per reporting key after the Bristol split. I keep DTA waits at
provider scope and order by current burden for operational review.
I run this query after the reporting view passes script 19.
*/

WITH portfolio AS
(
    SELECT reporting_month, provider_key, org_name, type1_attendances,
        type1_over4hrs, dta_12plus_hrs
    FROM analytics.vw_ae_reporting_monthly
    WHERE is_national = 0
      AND reporting_month BETWEEN '20240901' AND '20260801'
),
cohort AS
(
    SELECT provider_key
    FROM portfolio
    GROUP BY provider_key
    HAVING COUNT(*) = 24 AND COUNT(DISTINCT reporting_month) = 24
       AND MIN(type1_attendances) > 0
       AND COUNT(DISTINCT UPPER(TRIM(org_name))) = 1
       AND COUNT(NULLIF(TRIM(org_name), '')) = 24
),
paired AS
(
    SELECT p.provider_key, MAX(p.org_name) AS provider_name,
        SUM(p.type1_attendances) AS current_visits, SUM(y.type1_attendances) AS prior_visits,
        SUM(p.type1_over4hrs) AS current_breaches, SUM(y.type1_over4hrs) AS prior_breaches,
        SUM(p.dta_12plus_hrs) AS current_dta_12plus, SUM(y.dta_12plus_hrs) AS prior_dta_12plus,
        SUM(CASE WHEN p.type1_over4hrs * y.type1_attendances
                    > y.type1_over4hrs * p.type1_attendances THEN 1 ELSE 0 END) AS worse_months,
        SUM(CASE WHEN p.type1_over4hrs * y.type1_attendances
                    < y.type1_over4hrs * p.type1_attendances THEN 1 ELSE 0 END) AS better_months
    FROM portfolio AS p
    JOIN cohort AS c ON c.provider_key = p.provider_key
    JOIN portfolio AS y ON y.provider_key = p.provider_key
        AND y.reporting_month = DATEADD(year, -1, p.reporting_month)
    WHERE p.reporting_month BETWEEN '20260601' AND '20260801'
    GROUP BY p.provider_key
    HAVING COUNT(*) = 3
)
SELECT provider_key, provider_name, current_visits, prior_visits, current_breaches,
    100.0 * (prior_breaches * 1.0 / NULLIF(prior_visits, 0)
        - current_breaches * 1.0 / NULLIF(current_visits, 0)) AS within_4h_yoy_pp,
    worse_months, better_months, current_dta_12plus, prior_dta_12plus,
    current_dta_12plus - prior_dta_12plus AS dta_12plus_change
FROM paired
ORDER BY current_dta_12plus DESC, provider_key;
