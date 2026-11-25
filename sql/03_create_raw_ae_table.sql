
/*
PROJECT: NHS Hospital Performance & Patient Flow Intelligence
SCRIPT: 03_create_raw_ae_table.sql

PURPOSE:
I created this table to store monthly NHS A&E activity
and waiting-time data before cleaning and analysis.

I retain the original values as text to preserve the
source data and validate numeric fields before conversion.
*/

-- Create the raw A&E table if it does not already exist.

IF OBJECT_ID(N'raw.ae_monthly', N'U') IS NULL
BEGIN
    CREATE TABLE raw.ae_monthly
    (
        raw_row_id BIGINT IDENTITY(1,1) PRIMARY KEY,

        -- Organisation information
        period NVARCHAR(50),
        org_code NVARCHAR(20),
        parent_org NVARCHAR(150),
        org_name NVARCHAR(250),

        -- A&E attendances
        ae_attendances_type1 NVARCHAR(50),
        ae_attendances_type2 NVARCHAR(50),
        ae_attendances_other NVARCHAR(50),

        -- Booked appointments
        ae_booked_type1 NVARCHAR(50),
        ae_booked_type2 NVARCHAR(50),
        ae_booked_other NVARCHAR(50),

        -- Attendances exceeding four hours
        over4hrs_type1 NVARCHAR(50),
        over4hrs_type2 NVARCHAR(50),
        over4hrs_other NVARCHAR(50),

        -- Booked appointments exceeding four hours
        over4hrs_booked_type1 NVARCHAR(50),
        over4hrs_booked_type2 NVARCHAR(50),
        over4hrs_booked_other NVARCHAR(50),

        -- Decision-to-admit waiting times
        dta_wait_4_to_12hrs NVARCHAR(50),
        dta_wait_12plus_hrs NVARCHAR(50),

        -- Emergency admissions
        emergency_admissions_ae_type1 NVARCHAR(50),
        emergency_admissions_ae_type2 NVARCHAR(50),
        emergency_admissions_ae_other NVARCHAR(50),
        other_emergency_admissions NVARCHAR(50),

        -- Import tracking
        source_file NVARCHAR(260) NOT NULL,
        source_row_number INT NOT NULL,
        loaded_at_utc DATETIME2(0)
            NOT NULL DEFAULT SYSUTCDATETIME(),

        CONSTRAINT UQ_ae_monthly_source_row
            UNIQUE (source_file, source_row_number)
    );
END;

-- Confirm that the raw table exists.

SELECT
    TABLE_SCHEMA,
    TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'raw'
  AND TABLE_NAME = 'ae_monthly';
