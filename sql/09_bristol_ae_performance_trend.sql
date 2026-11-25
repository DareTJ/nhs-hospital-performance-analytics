
/*
PROJECT: NHS Hospital Performance & Patient Flow Intelligence
SCRIPT: 09_bristol_ae_performance_trend.sql

PURPOSE:
I compare Bristol's monthly A&E activity before and after
the July 2026 trust merger, using the combined activity
of both predecessor trusts for earlier months.
*/

WITH bristol_monthly AS
(
    SELECT
        m.reporting_month,
        COUNT(DISTINCT r.org_code) AS reporting_organisations,
        SUM(TRY_CONVERT(BIGINT, r.ae_attendances_type1))
            AS type1_attendances,
        SUM(TRY_CONVERT(BIGINT, r.over4hrs_type1))
            AS type1_over4hrs

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

    WHERE
        (m.reporting_month < '2026-07'
            AND r.org_code IN ('RA7', 'RVJ'))
        OR
        (m.reporting_month >= '2026-07'
            AND r.org_code = 'RA7')

    GROUP BY m.reporting_month
)

-- Calculate the proportion of Type 1 attendances over four hours.

SELECT
    reporting_month,
    reporting_organisations,
    type1_attendances,
    type1_over4hrs,

    CAST(
        100.0 * type1_over4hrs
        / NULLIF(type1_attendances, 0)
        AS DECIMAL(6,2)
    ) AS over4hrs_percentage

FROM bristol_monthly
ORDER BY reporting_month;
