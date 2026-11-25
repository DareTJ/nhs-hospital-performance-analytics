/*
PROJECT: NHS Hospital Performance & Patient Flow Intelligence
SCRIPT: 20_england_ae_activity_and_performance.sql

PURPOSE:
I monitor England demand, four-hour performance and admission pressure.
I use the published England rows and include booked attendances in the
all-department denominator. I keep decision-to-admit waits separate.
I run this query after the reporting view passes script 19.
*/

WITH activity AS
(
    SELECT reporting_month,
        type1_attendances + type1_booked AS type1_visits,
        type2_attendances + type2_booked AS type2_visits,
        other_attendances + other_booked AS other_visits,
        type1_over4hrs + type2_over4hrs + other_over4hrs
            + type1_booked_over4hrs + type2_booked_over4hrs + other_booked_over4hrs AS breaches,
        type1_admissions + type2_admissions + other_ae_admissions AS admissions_via_ae,
        other_emergency_admissions,
        dta_4_to_12hrs,
        dta_12plus_hrs
    FROM analytics.vw_ae_reporting_monthly
    WHERE is_national = 1
),
monthly AS
(
    SELECT *, type1_visits + type2_visits + other_visits AS attendances,
        DAY(EOMONTH(reporting_month)) AS days_in_month
    FROM activity
),
trend AS
(
    SELECT *,
        SUM(attendances - breaches) OVER (
            ORDER BY reporting_month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS within_4h_3m,
        SUM(attendances) OVER (
            ORDER BY reporting_month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS attendances_3m,
        LAG(reporting_month, 2) OVER (ORDER BY reporting_month) AS start_3m
    FROM monthly
)
SELECT t.reporting_month, t.type1_visits, t.type2_visits, t.other_visits,
    t.attendances, t.breaches,
    1.0 * t.attendances / NULLIF(t.days_in_month, 0) AS attendances_per_day,
    100.0 * (t.attendances - t.breaches) / NULLIF(t.attendances, 0) AS within_4h_pct,
    100.0 * (t.attendances - t.breaches) / NULLIF(t.attendances, 0) - 95 AS gap_to_standard_pp,
    100.0 * (t.attendances - previous.attendances) / NULLIF(previous.attendances, 0)
        AS attendance_mom_pct,
    100.0 * (t.attendances - prior_year.attendances) / NULLIF(prior_year.attendances, 0)
        AS attendance_yoy_pct,
    100.0 * (1.0 * prior_year.breaches / NULLIF(prior_year.attendances, 0)
        - 1.0 * t.breaches / NULLIF(t.attendances, 0)) AS within_4h_yoy_pp,
    CASE WHEN t.start_3m = DATEADD(month, -2, t.reporting_month)
        THEN 100.0 * t.within_4h_3m / NULLIF(t.attendances_3m, 0)
    END AS within_4h_3m_pct,
    t.admissions_via_ae, t.other_emergency_admissions,
    100.0 * t.admissions_via_ae / NULLIF(t.attendances, 0) AS ae_admission_conversion_pct,
    t.dta_4_to_12hrs, t.dta_12plus_hrs,
    1.0 * t.dta_12plus_hrs / NULLIF(t.days_in_month, 0) AS dta_12plus_per_day
FROM trend AS t
LEFT JOIN monthly AS previous ON previous.reporting_month = DATEADD(month, -1, t.reporting_month)
LEFT JOIN monthly AS prior_year ON prior_year.reporting_month = DATEADD(year, -1, t.reporting_month)
ORDER BY t.reporting_month;
