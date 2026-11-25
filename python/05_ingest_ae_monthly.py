
"""
PROJECT: NHS Hospital Performance & Patient Flow Intelligence
SCRIPT: 05_ingest_ae_monthly.py

PURPOSE:
I automate the ingestion of monthly NHS A&E datasets into
SQL Server. I validate each file before loading it and
prevent duplicate monthly imports.
"""

from pathlib import Path
import csv
import re
import os

import pyodbc


# Locate the original monthly NHS files.
project_folder = Path(__file__).resolve().parent.parent
raw_folder = project_folder / "data" / "raw"

csv_files = sorted(raw_folder.glob("*.csv"))

if not csv_files:
    raise FileNotFoundError("No monthly NHS A&E CSV files found.")


# Map NHS source columns to the existing SQL Server table.
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
    "source_file", "source_row_number"
]

insert_columns = ", ".join(
    f"[{column}]" for column in sql_columns
)

placeholders = ", ".join("?" for _ in sql_columns)

insert_sql = f"""
INSERT INTO raw.ae_monthly ({insert_columns})
VALUES ({placeholders})
"""


connection = pyodbc.connect(
    connection_string,
    autocommit=False
)

try:
    for file_path in csv_files:
        cursor = connection.cursor()

        try:
            # Skip files that have already been imported.
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
                print(
                    f"SKIPPED: {file_path.name} "
                    f"({existing_rows} records already loaded)"
                )
                connection.rollback()
                continue

           
            # Identify the reporting month from the filename.
            match = re.search(
                r"(?:^|-)(January|February|March|April|May|June|July|August|September|October|November|December)-(20\d{2})(?=-|\.csv)",
                file_path.name,
                flags=re.IGNORECASE
            )



            if not match:
                raise ValueError(
                    f"Unexpected filename: {file_path.name}"
                )

            month, year = match.groups()
            expected_period = f"MSITAE-{month.upper()}-{year}"

            # Read and validate the original CSV structure.
            with file_path.open(
                "r", encoding="utf-8-sig", newline=""
            ) as file:

                reader = csv.DictReader(file)

                if reader.fieldnames != list(column_mapping):
                    raise ValueError(
                        f"Unexpected columns: {file_path.name}"
                    )

                records = list(reader)

            if not records:
                raise ValueError("The source file is empty.")

            providers = []
            national_rows = []

            for row_number, record in enumerate(
                records, start=2
            ):
                if None in record or any(
                    value is None for value in record.values()
                ):
                    raise ValueError(
                        f"Invalid CSV structure at row {row_number}"
                    )

                period = record["Period"].strip().upper()

                if record["Org Code"].strip().upper() == "TOTAL":
                    national_rows.append(record)

                elif period == expected_period:
                    if not record["Org Code"].strip():
                        raise ValueError(
                            f"Missing organisation code at row {row_number}"
                        )
                    providers.append(record)

                else:
                    raise ValueError(
                        f"Unexpected reporting period at row {row_number}"
                    )

            if len(national_rows) != 1:
                raise ValueError(
                    "Expected exactly one national TOTAL row."
                )

            org_codes = [
                row["Org Code"].strip() for row in providers
            ]

            if len(org_codes) != len(set(org_codes)):
                raise ValueError(
                    "Duplicate organisation codes detected."
                )

            # Reconcile all 18 measures before loading.
            national = national_rows[0]

            for column in list(column_mapping)[4:]:
                try:
                    calculated = sum(
                        int(row[column].strip())
                        for row in providers
                    )
                    published = int(national[column].strip())

                except ValueError as error:
                    raise ValueError(
                        f"Invalid numeric value in {column}"
                    ) from error

                if calculated != published:
                    raise ValueError(
                        f"Reconciliation failed: {column}"
                    )

            # Prevent a different file duplicating the same month.
            cursor.execute(
                """
                SELECT COUNT(*)
                FROM raw.ae_monthly WITH (UPDLOCK, HOLDLOCK)
                WHERE UPPER(period) = ?
                  AND source_file <> ?
                """,
                expected_period,
                file_path.name
            )

            if cursor.fetchone()[0] > 0:
                raise ValueError(
                    f"Reporting month already loaded: {expected_period}"
                )

            # Preserve the original values and source row numbers.
            rows = [
                tuple(record[column] for column in column_mapping)
                + (file_path.name, row_number)
                for row_number, record in enumerate(
                    records, start=2
                )
            ]

            cursor.executemany(insert_sql, rows)

            # Confirm the records loaded before committing.
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
                    "Loaded row count does not match source."
                )

            connection.commit()

            print(
                f"SUCCESS: {file_path.name} "
                f"({loaded_rows} records loaded; "
                f"18 measures reconciled)"
            )

        except Exception:
            connection.rollback()
            raise

finally:
    connection.close()

print("\nMonthly NHS A&E ingestion completed.")
