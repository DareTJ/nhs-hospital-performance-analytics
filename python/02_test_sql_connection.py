
"""
PROJECT: NHS Hospital Performance & Patient Flow Intelligence
SCRIPT: 02_test_sql_connection.py

PURPOSE:
I use this script to verify the connection between Python
and my NHS Healthcare Analytics database before loading
the monthly A&E data.
"""

import os

import pyodbc

# Connect to my NHS Healthcare Analytics database.
server = os.environ.get("NHS_SQL_SERVER", r".\SQLEXPRESS")
connection_string = (
    "DRIVER={ODBC Driver 18 for SQL Server};"
    f"SERVER={server};"
    "DATABASE=NHSHealthcareAnalytics;"
    "Trusted_Connection=yes;"
    "Encrypt=yes;"
    "TrustServerCertificate=yes;"
)

try:
    with pyodbc.connect(connection_string, timeout=10) as connection:
        cursor = connection.cursor()

        # Confirm the database and destination table.
        cursor.execute("""
            SELECT
                DB_NAME() AS database_name,
                OBJECT_ID('raw.ae_monthly', 'U') AS table_id;
        """)

        result = cursor.fetchone()

        print("Database:", result.database_name)
        print("Raw A&E table exists:", result.table_id is not None)
        print("SQL Server connection successful.")

except pyodbc.Error as error:
    print("SQL Server connection failed.")
    print(error)
