
from pathlib import Path
import csv

# Locate the original NHS A&E dataset
project_folder = Path(__file__).resolve().parent.parent

file_path = (
    project_folder
    / "data"
    / "raw"
    / "August-2026-CSV-De2k3n.csv"
)

print("NHS A&E DATA INSPECTION")
print("-" * 50)

print("File name:", file_path.name)
print("File exists:", file_path.exists())

# Inspect the original CSV structure
with open(file_path, "r", encoding="utf-8-sig", newline="") as file:
    reader = csv.reader(file)

    for row_number, row in enumerate(reader, start=1):
        print(f"\nRow {row_number}:")
        print(row)

        if row_number >= 12:
            break

print("\nInitial inspection completed.")


import pandas as pd

print("\nNHS A&E DATA PROFILING")
print("-" * 50)

# Read source values as text to preserve organisation codes
df = pd.read_csv(
    file_path,
    dtype=str,
    encoding="utf-8-sig"
)

print("Total rows:", len(df))
print("Total columns:", len(df.columns))

print("\nUnique organisation codes:")
print(df["Org Code"].nunique(dropna=True))

print("\nDuplicate organisation codes:")
print(df["Org Code"].duplicated().sum())

print("\nMissing organisation codes:")
print(df["Org Code"].isna().sum())

print("\nReporting periods:")
print(df["Period"].value_counts(dropna=False))

print("\nLast 10 records:")
print(
    df[
        ["Period", "Org Code", "Org name"]
    ].tail(10).to_string(index=False)
)

print("\nProfiling completed.")


print("\nNHS A&E NATIONAL TOTAL RECONCILIATION")
print("-" * 50)

# Separate provider records from the published TOTAL row
providers = df[
    df["Period"] == "MSitAE-AUGUST-2026"
].copy()

national_total = df[
    df["Period"] == "TOTAL"
].copy()

# Reconcile the three attendance categories
attendance_columns = [
    "A&E attendances Type 1",
    "A&E attendances Type 2",
    "A&E attendances Other A&E Department"
]

for column in attendance_columns:

    # Convert original CSV values into numeric values
    provider_values = pd.to_numeric(
        providers[column],
        errors="raise"
    )

    national_value = pd.to_numeric(
        national_total[column],
        errors="raise"
    ).iloc[0]

    calculated_total = int(provider_values.sum())
    published_total = int(national_value)

    difference = calculated_total - published_total

    print(f"\nMetric: {column}")
    print(f"Calculated total: {calculated_total:,}")
    print(f"Published total:  {published_total:,}")
    print(f"Difference:       {difference:,}")

    if difference == 0:
        print("Status: PASS")
    else:
        print("Status: INVESTIGATE")

print("\nReconciliation completed.")


