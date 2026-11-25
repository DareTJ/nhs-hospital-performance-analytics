
/*
PROJECT: NHS Hospital Performance & Patient Flow Intelligence
SCRIPT: 07_check_organisation_coverage.sql

PURPOSE:
I examine changes in NHS reporting organisation coverage
between April and August 2026 to support reliable
comparisons of emergency care performance.
*/

WITH organisation_coverage AS
(
    SELECT
        org_code,
        MAX(org_name) AS organisation_name,

        COUNT(DISTINCT UPPER(LTRIM(RTRIM(period))))
            AS months_reported,

        MAX(CASE WHEN UPPER(period) = 'MSITAE-APRIL-2026'
                 THEN 1 ELSE 0 END) AS april_2026,

        MAX(CASE WHEN UPPER(period) = 'MSITAE-MAY-2026'
                 THEN 1 ELSE 0 END) AS may_2026,

        MAX(CASE WHEN UPPER(period) = 'MSITAE-JUNE-2026'
                 THEN 1 ELSE 0 END) AS june_2026,

        MAX(CASE WHEN UPPER(period) = 'MSITAE-JULY-2026'
                 THEN 1 ELSE 0 END) AS july_2026,

        MAX(CASE WHEN UPPER(period) = 'MSITAE-AUGUST-2026'
                 THEN 1 ELSE 0 END) AS august_2026

    FROM raw.ae_monthly

    WHERE UPPER(LTRIM(RTRIM(period))) IN (
        'MSITAE-APRIL-2026',
        'MSITAE-MAY-2026',
        'MSITAE-JUNE-2026',
        'MSITAE-JULY-2026',
        'MSITAE-AUGUST-2026'
    )

    GROUP BY org_code
)

-- Identify organisations not present in all five months.

SELECT
    org_code,
    organisation_name,
    months_reported,
    april_2026,
    may_2026,
    june_2026,
    july_2026,
    august_2026

FROM organisation_coverage

WHERE months_reported < 5

ORDER BY
    months_reported,
    org_code;
