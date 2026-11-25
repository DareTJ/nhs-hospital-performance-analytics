# Reproduce the report

## Open the supplied snapshot

Use Power BI Desktop for Windows with PBIP support. Keep the entire `powerbi` folder together. Open [the PBIP](../powerbi/NHS_Hospital_Performance.pbip), go to **Home → Transform data → Edit parameters**, and set `SnapshotPath` to the absolute path of [ae_reporting_monthly.csv](../data/processed/ae_reporting_monthly.csv). Leave `SqlServerName` blank. Select **OK** and **Apply changes**, then use **Refresh now** if Desktop reports incomplete data or relationships awaiting refresh.

Start at Executive Overview with all months selected. Expect 55,978,147 attendances, 74.57% within four hours, 1,155,186 waits of 12 hours or more after the decision to admit, and a −20.43 percentage-point gap to the 95% standard. In Four-Hour Performance, select Airedale. The provider rate should be 59.49% and the England benchmark 60.03%. [Desktop acceptance evidence](powerbi_refinement_review.md)

## Regenerate and validate the snapshot

Use Python 3.13 for the verified setup. Scripts 06 and 07 use the standard library. Keep one monthly CSV per period in `data/raw` and use the [frozen sources and checksums](data_sources.md) to match this project. Run from the repository root. The exporter writes the snapshot in place, so use a copy of the files if you need to keep a separate reference.

```powershell
python -B python/06_export_ae_reporting_snapshot.py
python -B python/07_validate_ae_reporting_snapshot.py
```

Expect 4,751 rows, 24 months, 18 measures and 24 England totals. The validator also checks national KPIs, reporting coverage, the comparable provider cohort and the Bristol merger boundary.

## Optional SQL Server route

Use SQL Server 2017 or later for the SQL syntax in this project. The original run used SQL Server Express, SQL Server Management Studio, Python, `pyodbc`, Microsoft ODBC Driver 18 for SQL Server and Windows authentication. The earlier inspection scripts also use `pandas`. Use an account with the database permissions needed for setup and loading.

1. In SSMS run SQL 01, 02 and 03 in order. Select `NHSHealthcareAnalytics` before running script 03. Confirm that `raw.ae_monthly` exists.
2. From PowerShell in the repository root, install `pyodbc` in your chosen environment and set the server instance name. The scripts default to the local named instance `.\SQLEXPRESS`. Replace that value if using a different instance. The supplied connection uses encrypted transport and trusts the server certificate for the original local setup. Use your organisation’s TLS configuration for a remote server.

   ```powershell
   python -m pip install pyodbc
   $env:NHS_SQL_SERVER = '.\SQLEXPRESS'
   python -B python/02_test_sql_connection.py
   python -B python/05_ingest_ae_monthly.py
   ```

3. Run SQL 05 and 06 with the monthly data loaded, then SQL 18 to create the reporting view and SQL 19 to validate it. The validation exception outputs should be empty and the England Type 1 summary should contain 24 months. Run SQL 20 and 21 for national activity and the comparable provider analysis. SQL 04 and Python 03 are pilot checks and loading, respectively. For a full monthly load, use Python 05.
4. To refresh from SQL, set Power Query’s `SqlServerName` to the instance you used during setup and refresh. Recheck the same executive figures and provider benchmark. Switch back by clearing `SqlServerName` and using the absolute CSV path in `SnapshotPath`.

I verified the deployed view and both Power BI source paths in the project environment. I also refreshed a cache-free PBIP copy from a different folder and reproduced the headline cards and the Airedale comparison. The Python connection check passed with the actual instance name set in NHS_SQL_SERVER. A complete SQL rebuild on a second installation remains untested. [SQL deployment evidence](validation_and_portfolio_review.md) · [Script inventory](project_audit.md)
