
"""
PROJECT: NHS Hospital Performance & Patient Flow Intelligence
SCRIPT: 03_ingest_ae_data.py

PURPOSE:
I use Python to load monthly NHS A&E activity data into
SQL Server while preserving the original source records.

I check the file structure, track the source filename
and prevent the same file from being imported twice.
"""

from pathlib import Path
import csv
import os

import pyodbc


# Locate the NHS source file.
project_folder = Path(__file__).resolve().parent.parent

file_path = (
    project_folder
    / "data"
    / "raw"
    / "August-2026-CSV-De2k3n.csv"
)


# Map the original NHS columns to my SQL Server table.
column_mapping = {
    "Period": "period",
    "Org Code": "org_code",
    "Parent Org": "parent_org",
    "Org name": "org_name",
    "A&E attendances Type 1": "ae_attendances_type1",
    "A&E attendances Type 2": "ae_attendances_type2",
    "A&E attendances Other A&E Department": "ae_attendances_other",
    "A&E attendances Booked Appointments Type 1": "ae_booked_type1",
    "A&E attendances Booked Appointments Type 2": "ae_booked_type2",
    "A&E attendances Booked Appointments Other Department": "ae_booked_other",
    "Attendances over 4hrs Type 1": "over4hrs_type1",
    "Attendances over 4hrs Type 2": "over4hrs_type2",
    "Attendances over 4hrs Other Department": "over4hrs_other",
    "Attendances over 4hrs Booked Appointments Type 1": "over4hrs_booked_type1",
    "Attendances over 4hrs Booked Appointments Type 2": "over4hrs_booked_type2",
    "Attendances over 4hrs Booked Appointments Other Department": "over4hrs_booked_other",
    "Patients who have waited 4-12 hs from DTA to admission": "dta_wait_4_to_12hrs",
    "Patients who have waited 12+ hrs from DTA to admission": "dta_wait_12plus_hrs",
    "Emergency admissions via A&E - Type 1": "emergency_admissions_ae_type1",
    "Emergency admissions via A&E - Type 2": "emergency_admissions_ae_type2",
    "Emergency admissions via A&E - Other A&E department": "emergency_admissions_ae_other",
    "Other emergency admissions": "other_emergency_admissions",
}


# Read the original CSV without changing source values.
with file_path.open(
    "r", encoding="utf-8-sig", newline=""
) as file:

    reader = csv.DictReader(file)

    if reader.fieldnames != list(column_mapping):
        raise ValueError(
            "The CSV columns do not match the expected NHS structure."
        )

    rows = []

    for row_number, record in enumerate(reader, start=2):
        if None in record:
            raise ValueError(
                f"Unexpected extra fields on CSV row {row_number}"
            )

        rows.append(
            tuple(record[column] for column in column_mapping)
            + (file_path.name, row_number)
        )


# Validate the reporting period and national summary.
periods = [row[0] for row in rows]

if not rows:
    raise ValueError("The NHS CSV contains no data records.")

if periods.count("TOTAL") != 1:
    raise ValueError("Expected exactly one national TOTAL row.")

if any(
    period not in ("MSitAE-AUGUST-2026", "TOTAL")
    for period in periods
):
    raise ValueError("Unexpected reporting period found.")


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


sql_columns = list(column_mapping.values()) + [
    "source_file",
    "source_row_number"
]

column_names = ", ".join(
    f"[{column}]" for column in sql_columns
)

placeholders = ", ".join("?" for _ in sql_columns)

insert_sql = f"""
INSERT INTO raw.ae_monthly ({column_names})
VALUES ({placeholders})
"""


connection = pyodbc.connect(
    connection_string,
    autocommit=False
)

try:
    cursor = connection.cursor()

    # Prevent duplicate loading of the same source file.
    cursor.execute(
        """
        SELECT COUNT(*)
        FROM raw.ae_monthly WITH (UPDLOCK, HOLDLOCK)
        WHERE source_file = ?
        """,
        file_path.name
    )

    existing_rows = cursor.fetchone()[0]

    if existing_rows > 0:
        print("This NHS file has already been imported.")
        print("Existing records:", existing_rows)
        connection.rollback()

    else:
        # Insert all source records in one transaction.
        cursor.executemany(insert_sql, rows)

        cursor.execute(
            """
            SELECT COUNT(*)
            FROM raw.ae_monthly
            WHERE source_file = ?
            """,
            file_path.name
        )

        loaded_rows = cursor.fetchone()[0]

        if loaded_rows != len(rows):
            raise ValueError(
                "SQL row count does not match the source file."
            )

        connection.commit()

        print("NHS A&E DATA INGESTION")
        print("-" * 40)
        print("Source file:", file_path.name)
        print("Source records:", len(rows))
        print("Loaded records:", loaded_rows)
        print("Status: SUCCESS")

except Exception:
    connection.rollback()
    raise

finally:
    connection.close()
