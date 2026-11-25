
"""
PROJECT: NHS Hospital Performance & Patient Flow Intelligence
SCRIPT: 04_check_ae_monthly_structure.py

PURPOSE:
I compare the July and August NHS A&E files to confirm
that their structures are consistent before ingestion.
"""

from pathlib import Path
import csv
from collections import Counter

# Locate the monthly NHS A&E files.
project_folder = Path(__file__).resolve().parent.parent
raw_folder = project_folder / "data" / "raw"

august_file = raw_folder / "August-2026-CSV-De2k3n.csv"
july_file = raw_folder / "July-2026-CSV-Trf28h.csv"


# Read the original column headings.
with august_file.open(
    "r", encoding="utf-8-sig", newline=""
) as file:
    august_columns = next(csv.reader(file))


with july_file.open(
    "r", encoding="utf-8-sig", newline=""
) as file:
    reader = csv.DictReader(file)

    july_columns = reader.fieldnames
    july_rows = list(reader)


# Compare the two monthly files.
print("NHS A&E MONTHLY STRUCTURE VALIDATION")
print("-" * 45)

print("August columns:", len(august_columns))
print("July columns:", len(july_columns))
print("Column structure matches:", august_columns == july_columns)

print("\nJuly total records:", len(july_rows))

print("\nJuly reporting periods:")
for period, count in Counter(
    row["Period"] for row in july_rows
).items():
    print(period, count)

print("\nStructure validation completed.")
