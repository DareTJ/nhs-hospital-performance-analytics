
/*
PROJECT: NHS Hospital Performance & Patient Flow Intelligence
SCRIPT: 08_investigate_organisation_changes.sql

PURPOSE:
I investigate how the July 2026 Bristol trust merger
affected organisation-level A&E reporting.

This helps me assess whether historical performance
figures can be compared consistently.
*/

-- Examine A&E activity for the predecessor and retained trust codes.

SELECT
    source_file,
    org_code,
    org_name,

    TRY_CONVERT(BIGINT, ae_attendances_type1)
        AS type1_attendances,

    TRY_CONVERT(BIGINT, over4hrs_type1)
        AS type1_over4hrs

FROM raw.ae_monthly

WHERE org_code IN ('RVJ', 'RA7')

ORDER BY
    CASE
        WHEN source_file LIKE 'April-%' THEN 1
        WHEN source_file LIKE 'May-%' THEN 2
        WHEN source_file LIKE 'June-%' THEN 3
        WHEN source_file LIKE 'July-%' THEN 4
        WHEN source_file LIKE 'August-%' THEN 5
    END,
    org_code;
