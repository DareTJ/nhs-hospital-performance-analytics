
/*
PROJECT: NHS Hospital Performance & Patient Flow Intelligence
SCRIPT: 01_create_database.sql

PURPOSE:
I created this database to store, manage and analyse
NHS hospital activity, emergency care performance
and patient waiting times.
*/

-- Check whether the database exists before creating it.

IF DB_ID(N'NHSHealthcareAnalytics') IS NULL
BEGIN
    CREATE DATABASE [NHSHealthcareAnalytics];
END;

-- Confirm that the database has been created.

SELECT
    name AS database_name
FROM sys.databases
WHERE name = N'NHSHealthcareAnalytics';
