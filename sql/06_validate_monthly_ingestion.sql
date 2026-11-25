
/*
PROJECT: NHS Hospital Performance & Patient Flow Intelligence
SCRIPT: 06_validate_monthly_ingestion.sql

PURPOSE:
I verify that the monthly NHS A&E datasets have been
loaded correctly before analysing hospital performance
and waiting-time trends.
*/

-- Check the number of records imported for each month.

SELECT
    source_file,
    COUNT(*) AS total_records,

    SUM(
        CASE
            WHEN UPPER(TRIM(org_code)) = 'TOTAL'
            THEN 1 ELSE 0
        END
    ) AS national_total_rows,

    SUM(
        CASE
            WHEN UPPER(TRIM(org_code)) <> 'TOTAL'
            THEN 1 ELSE 0
        END
    ) AS organisation_records,

    COUNT(DISTINCT
        CASE
            WHEN UPPER(TRIM(org_code)) <> 'TOTAL'
            THEN org_code
        END
    ) AS unique_organisations

FROM raw.ae_monthly

GROUP BY source_file
ORDER BY source_file;
