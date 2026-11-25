
/*
PROJECT: NHS Hospital Performance & Patient Flow Intelligence
SCRIPT: 04_validate_ae_ingestion.sql

PURPOSE:
I validate the August 2026 A&E records loaded into SQL Server
against the original NHS England dataset.

This check confirms the imported row counts, reporting
periods and organisation identifiers before further analysis.
*/

-- Check the number of imported source records.

SELECT
    COUNT(*) AS total_records,
    COUNT(DISTINCT org_code) AS unique_org_codes,
    SUM(CASE WHEN UPPER(TRIM(org_code)) = 'TOTAL' THEN 1 ELSE 0 END)
        AS national_total_rows,
    COUNT(*) -
        SUM(CASE WHEN UPPER(TRIM(org_code)) = 'TOTAL' THEN 1 ELSE 0 END)
        AS organisation_records
FROM raw.ae_monthly
WHERE source_file = 'August-2026-CSV-De2k3n.csv';


-- Check whether any organisation codes are missing.

SELECT
    COUNT(*) AS missing_org_codes
FROM raw.ae_monthly
WHERE source_file = 'August-2026-CSV-De2k3n.csv'
  AND (
      org_code IS NULL
      OR LTRIM(RTRIM(org_code)) = ''
  );


-- Check for duplicate organisation codes within the source file.

SELECT
    org_code,
    COUNT(*) AS duplicate_count
FROM raw.ae_monthly
WHERE source_file = 'August-2026-CSV-De2k3n.csv'
GROUP BY org_code
HAVING COUNT(*) > 1;


-- Confirm the reporting periods.

SELECT
    period,
    COUNT(*) AS record_count
FROM raw.ae_monthly
WHERE source_file = 'August-2026-CSV-De2k3n.csv'
GROUP BY period
ORDER BY period;


-- Reconcile imported A&E attendance figures with NHS published totals.
-- This confirms that the numerical values were preserved during ingestion.

WITH attendance_totals AS (
    SELECT
        org_code,
        TRY_CONVERT(BIGINT, ae_attendances_type1) AS type1,
        TRY_CONVERT(BIGINT, ae_attendances_type2) AS type2,
        TRY_CONVERT(BIGINT, ae_attendances_other) AS other_ae
    FROM raw.ae_monthly
    WHERE source_file = 'August-2026-CSV-De2k3n.csv'
),
reconciliation AS (
    SELECT
        SUM(CASE WHEN UPPER(TRIM(org_code)) <> 'TOTAL' THEN type1 ELSE 0 END)
            AS calculated_type1,
        MAX(CASE WHEN UPPER(TRIM(org_code)) = 'TOTAL' THEN type1 END)
            AS published_type1,

        SUM(CASE WHEN UPPER(TRIM(org_code)) <> 'TOTAL' THEN type2 ELSE 0 END)
            AS calculated_type2,
        MAX(CASE WHEN UPPER(TRIM(org_code)) = 'TOTAL' THEN type2 END)
            AS published_type2,

        SUM(CASE WHEN UPPER(TRIM(org_code)) <> 'TOTAL' THEN other_ae ELSE 0 END)
            AS calculated_other,
        MAX(CASE WHEN UPPER(TRIM(org_code)) = 'TOTAL' THEN other_ae END)
            AS published_other
    FROM attendance_totals
)
SELECT
    calculated_type1 - published_type1 AS type1_difference,
    calculated_type2 - published_type2 AS type2_difference,
    calculated_other - published_other AS other_ae_difference
FROM reconciliation;
