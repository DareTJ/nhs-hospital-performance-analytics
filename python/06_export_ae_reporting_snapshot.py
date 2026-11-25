"""I prepare a validated, database-independent snapshot for Power BI Desktop."""

from calendar import month_name
import csv
from datetime import date
from pathlib import Path
import re

PROJECT = Path(__file__).resolve().parents[1]
MEASURES = {
    "A&E attendances Type 1": "type1_attendances",
    "A&E attendances Type 2": "type2_attendances",
    "A&E attendances Other A&E Department": "other_attendances",
    "Attendances over 4hrs Type 1": "type1_over4hrs",
    "Attendances over 4hrs Type 2": "type2_over4hrs",
    "Attendances over 4hrs Other Department": "other_over4hrs",
    "A&E attendances Booked Appointments Type 1": "type1_booked",
    "Attendances over 4hrs Booked Appointments Type 1": "type1_booked_over4hrs",
    "Patients who have waited 4-12 hs from DTA to admission": "dta_4_to_12hrs",
    "Patients who have waited 12+ hrs from DTA to admission": "dta_12plus_hrs",
    "Emergency admissions via A&E - Type 1": "type1_admissions",
    "A&E attendances Booked Appointments Type 2": "type2_booked",
    "A&E attendances Booked Appointments Other Department": "other_booked",
    "Attendances over 4hrs Booked Appointments Type 2": "type2_booked_over4hrs",
    "Attendances over 4hrs Booked Appointments Other Department": "other_booked_over4hrs",
    "Emergency admissions via A&E - Type 2": "type2_admissions",
    "Emergency admissions via A&E - Other A&E department": "other_ae_admissions",
    "Other emergency admissions": "other_emergency_admissions",
}
PAIRS = (
    ("type1_over4hrs", "type1_attendances"),
    ("type2_over4hrs", "type2_attendances"),
    ("other_over4hrs", "other_attendances"),
    ("type1_booked_over4hrs", "type1_booked"),
    ("type2_booked_over4hrs", "type2_booked"),
    ("other_booked_over4hrs", "other_booked"),
)
MONTHS = {name.upper(): i for i, name in enumerate(month_name) if i}


def read_month(path):
    with path.open(encoding="utf-8-sig", newline="") as source:
        rows = list(csv.DictReader(source))

    periods = {
        row["Period"].strip().upper()
        for row in rows if row["Org Code"].strip().upper() != "TOTAL"
    }
    if len(periods) != 1:
        raise ValueError(f"{path.name}: expected one provider reporting period")
    match = re.fullmatch(r"MSITAE-([A-Z]+)-(20[0-9]{2})", periods.pop())
    if not match or match[1] not in MONTHS:
        raise ValueError(f"{path.name}: invalid provider reporting period")
    month = date(int(match[2]), MONTHS[match[1]], 1)

    records = []
    codes = set()
    for row in rows:
        code = row["Org Code"].strip().upper()
        if not code or code in codes:
            raise ValueError(f"{path.name}: invalid or duplicate code {code!r}")
        codes.add(code)
        name = row["Org name"].strip()
        # I split the retained Bristol code at the ODS merger date.
        key = "RA7-PRE" if code == "RA7" and month < date(2026, 7, 1) else code
        metrics = {target: int(row[source]) for source, target in MEASURES.items()}
        if min(metrics.values()) < 0 or any(metrics[a] > metrics[b] for a, b in PAIRS):
            raise ValueError(f"{path.name}: out-of-range measure for {code}")
        records.append({
            "reporting_month": month.isoformat(),
            "provider_key": key,
            "org_code": code,
            "org_name": name,
            **metrics,
        })

    totals = [row for row in records if row["org_code"] == "TOTAL"]
    providers = [row for row in records if row["org_code"] != "TOTAL"]
    if len(totals) != 1 or any(
        sum(row[key] for row in providers) != totals[0][key] for key in MEASURES.values()
    ):
        raise ValueError(f"{path.name}: national total reconciliation failed")
    return month, records


def main():
    files = sorted((PROJECT / "data" / "raw").glob("*.csv"))
    months = {}
    for path in files:
        month, records = read_month(path)
        if month in months:
            raise ValueError(f"Duplicate source month: {month}")
        months[month] = records

    expected = {
        date(year, month, 1)
        for year, first, last in [(2024, 9, 12), (2025, 1, 12), (2026, 1, 8)]
        for month in range(first, last + 1)
    }
    if months.keys() != expected:
        raise ValueError("The portfolio snapshot requires September 2024 to August 2026")

    records = [row for month in sorted(months) for row in months[month]]
    destination = PROJECT / "data" / "processed" / "ae_reporting_monthly.csv"
    destination.parent.mkdir(parents=True, exist_ok=True)
    pending = destination.with_suffix(".tmp")
    with pending.open("w", encoding="utf-8", newline="") as output:
        writer = csv.DictWriter(output, fieldnames=list(records[0]))
        writer.writeheader()
        writer.writerows(records)
    pending.replace(destination)
    print(f"{len(records)} rows, {len(months)} months, {len(MEASURES)} reconciled measures")


if __name__ == "__main__":
    main()
