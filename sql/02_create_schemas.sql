
/*
PROJECT: NHS Hospital Performance & Patient Flow Intelligence
SCRIPT: 02_create_schemas.sql

PURPOSE:
I organise my NHS database into four schemas to manage
raw data, cleaned records, analytical reporting and
data quality checks.
*/

USE [NHSHealthcareAnalytics];

-- Create the raw schema for original NHS data.

IF NOT EXISTS (
    SELECT 1 FROM sys.schemas WHERE name = 'raw'
)
    EXEC('CREATE SCHEMA raw');

-- Create the clean schema for validated data.

IF NOT EXISTS (
    SELECT 1 FROM sys.schemas WHERE name = 'clean'
)
    EXEC('CREATE SCHEMA clean');

-- Create the analytics schema for performance reporting.

IF NOT EXISTS (
    SELECT 1 FROM sys.schemas WHERE name = 'analytics'
)
    EXEC('CREATE SCHEMA analytics');

-- Create the data quality schema for validation results.

IF NOT EXISTS (
    SELECT 1 FROM sys.schemas WHERE name = 'dq'
)
    EXEC('CREATE SCHEMA dq');

-- Verify the four schemas.

SELECT
    DB_NAME() AS database_name,
    name AS schema_name
FROM sys.schemas
WHERE name IN ('raw', 'clean', 'analytics', 'dq')
ORDER BY name;
