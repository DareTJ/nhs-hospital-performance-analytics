
/*
PROJECT: NHS Hospital Performance & Patient Flow Intelligence
SCRIPT: 05_reconcile_ae_attendance.sql

PURPOSE:
I reconcile the NHS A&E activity and waiting-time figures
stored in SQL Server against the published national totals.

This helps me identify discrepancies before using the data
for operational performance analysis and reporting.
*/

WITH reconciliation AS
(
    SELECT
        m.measure_name,

        SUM(
            CASE
                WHEN UPPER(TRIM(r.org_code)) <> 'TOTAL'
                THEN v.metric_value
                ELSE 0
            END
        ) AS calculated_total,

        MAX(
            CASE
                WHEN UPPER(TRIM(r.org_code)) = 'TOTAL'
                THEN v.metric_value
            END
        ) AS published_total,

        SUM(
            CASE
                WHEN v.metric_value IS NULL THEN 1
                ELSE 0
            END
        ) AS invalid_values

    FROM raw.ae_monthly AS r

    CROSS APPLY
    (
        VALUES
        ('A&E attendances Type 1', r.ae_attendances_type1),
        ('A&E attendances Type 2', r.ae_attendances_type2),
        ('A&E attendances Other', r.ae_attendances_other),

        ('Booked appointments Type 1', r.ae_booked_type1),
        ('Booked appointments Type 2', r.ae_booked_type2),
        ('Booked appointments Other', r.ae_booked_other),

        ('Over 4 hours Type 1', r.over4hrs_type1),
        ('Over 4 hours Type 2', r.over4hrs_type2),
        ('Over 4 hours Other', r.over4hrs_other),

        ('Over 4 hours Booked Type 1', r.over4hrs_booked_type1),
        ('Over 4 hours Booked Type 2', r.over4hrs_booked_type2),
        ('Over 4 hours Booked Other', r.over4hrs_booked_other),

        ('DTA waits 4-12 hours', r.dta_wait_4_to_12hrs),
        ('DTA waits 12+ hours', r.dta_wait_12plus_hrs),

        ('Emergency admissions A&E Type 1', r.emergency_admissions_ae_type1),
        ('Emergency admissions A&E Type 2', r.emergency_admissions_ae_type2),
        ('Emergency admissions A&E Other', r.emergency_admissions_ae_other),
        ('Other emergency admissions', r.other_emergency_admissions)
    ) AS m(measure_name, source_value)

    CROSS APPLY
    (
        VALUES
        (
            TRY_CONVERT(
                BIGINT,
                NULLIF(LTRIM(RTRIM(m.source_value)), '')
            )
        )
    ) AS v(metric_value)

    WHERE r.source_file = 'August-2026-CSV-De2k3n.csv'

    GROUP BY m.measure_name
)

-- Compare the calculated totals with the published figures.

SELECT
    measure_name,
    calculated_total,
    published_total,
    calculated_total - published_total AS difference,
    invalid_values,

    CASE
        WHEN invalid_values > 0 THEN 'CHECK INVALID VALUES'
        WHEN calculated_total = published_total THEN 'PASS'
        ELSE 'INVESTIGATE'
    END AS validation_status

FROM reconciliation
ORDER BY measure_name;
