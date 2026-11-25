"""I independently check the published England and provider controls in the snapshot."""

from collections import defaultdict
import csv
from pathlib import Path
from statistics import correlation


SNAPSHOT = Path(__file__).resolve().parents[1] / "data/processed/ae_reporting_monthly.csv"
DEPARTMENTS = ("type1", "type2", "other")


def check(actual, expected, name):
    if actual != expected:
        raise ValueError(f"{name}: expected {expected!r}, got {actual!r}")
    print(f"PASS {name}: {actual}")


def load_rows():
    with SNAPSHOT.open(encoding="utf-8", newline="") as source:
        reader = csv.DictReader(source)
        measures = reader.fieldnames[4:]
        by_month = defaultdict(list)
        for row in reader:
            for field in measures:
                row[field] = int(row[field])
                if row[field] < 0:
                    raise ValueError(f"Negative {field} for {row['provider_key']}")
            by_month[row["reporting_month"]].append(row)
    return by_month, measures


def compare_summers(history):
    worse = improved = 0
    volume_changes, rate_changes = [], []
    for months in history.values():
        names = {row["org_name"].strip().upper() for row in months.values()}
        if len(months) != 24 or len(names) != 1 or "" in names:
            continue
        if any(row["type1_attendances"] <= 0 for row in months.values()):
            continue
        current = [months[f"2026-{month:02d}-01"] for month in range(6, 9)]
        prior = [months[f"2025-{month:02d}-01"] for month in range(6, 9)]
        pairs = [
            a["type1_over4hrs"] * b["type1_attendances"]
            - b["type1_over4hrs"] * a["type1_attendances"]
            for a, b in zip(current, prior)
        ]
        worse += all(value > 0 for value in pairs)
        improved += all(value < 0 for value in pairs)
        visits = sum(row["type1_attendances"] for row in current)
        previous_visits = sum(row["type1_attendances"] for row in prior)
        volume_changes.append(visits / previous_visits - 1)
        rate_changes.append(
            sum(row["type1_over4hrs"] for row in prior) / previous_visits
            - sum(row["type1_over4hrs"] for row in current) / visits
        )
    return len(volume_changes), worse, improved, round(correlation(volume_changes, rate_changes), 3)


def main():
    by_month, measures = load_rows()
    expected_months = {
        f"{year}-{month:02d}-01"
        for year, months in ((2024, range(9, 13)), (2025, range(1, 13)), (2026, range(1, 9)))
        for month in months
    }
    check(sorted(by_month), sorted(expected_months), "Reporting months")
    check(len(measures), 18, "Numeric source measures")
    england = {}
    history = defaultdict(dict)
    codes = defaultdict(set)
    for month, rows in by_month.items():
        national, = [row for row in rows if row["org_code"] == "TOTAL"]
        providers = [row for row in rows if row["org_code"] != "TOTAL"]
        if len({row["org_code"] for row in providers}) != len(providers):
            raise ValueError(f"{month}: duplicate provider code")
        for field in measures:
            if sum(row[field] for row in providers) != national[field]:
                raise ValueError(f"{month}: England reconciliation failed for {field}")
        for row in rows:
            for department in DEPARTMENTS:
                for activity, breach in (("attendances", "over4hrs"), ("booked", "booked_over4hrs")):
                    if row[f"{department}_{breach}"] > row[f"{department}_{activity}"]:
                        raise ValueError(f"{month}: invalid {department} breach count")
        england[month] = national
        for row in providers:
            history[row["provider_key"]][month] = row
            codes[row["org_code"]].add(month)

    check(sum(map(len, by_month.values())), 4751, "Raw snapshot rows")
    check(len(england), 24, "Reconciled England rows")
    check(len(codes), 207, "Historical organisation codes")
    check(sum(len(months) == 24 for months in codes.values()), 181, "Complete raw codes")
    check(sum(24 - len(months) for months in codes.values()), 241, "Missing raw code-months")
    check(len(history), 208, "Provider keys")
    check(sum(len(months) == 24 for months in history.values()), 180, "Complete provider keys")
    check(sum(24 - len(months) for months in history.values()), 265, "Missing provider key-months")

    def headline(rows):
        visits = sum(row[f"{dept}_{field}"] for row in rows for dept in DEPARTMENTS
                     for field in ("attendances", "booked"))
        breaches = sum(row[f"{dept}_{field}"] for row in rows for dept in DEPARTMENTS
                       for field in ("over4hrs", "booked_over4hrs"))
        dta = sum(row["dta_12plus_hrs"] for row in rows)
        return visits, round(100 * (visits - breaches) / visits, 2), dta

    check(headline(list(england.values())), (55978147, 74.57, 1155186), "England full period")
    check(headline([england["2026-08-01"]]), (2342959, 75.04, 44951), "England August 2026")
    check(sum(row["type1_attendances"] for row in england.values()), 33523262, "England Type 1 visits")
    check(sum(row["type1_over4hrs"] for row in england.values()), 13400360, "England Type 1 breaches")
    check(compare_summers(history), (112, 37, 27, 0.315), "Matched summer provider analysis")

    for month, keys, expected in (
        ("2026-06-01", ("RA7-PRE", "RVJ"), (25969, 9653)),
        ("2026-07-01", ("RA7",), (26582, 9055)),
    ):
        counts = tuple(sum(history[key][month][field] for key in keys)
                       for field in ("type1_attendances", "type1_over4hrs"))
        check(counts, expected, f"Adjusted Bristol {month}")


if __name__ == "__main__":
    main()
