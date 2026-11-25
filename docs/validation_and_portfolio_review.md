# Validation and portfolio review

The [GitHub release review](github_release_review.md) records the later source verification, portable snapshot test and repository assessment. The scores below describe the project at each earlier checkpoint.

## 25 November 2026 follow-up

I ran scripts 18–21 in SQL Server Management Studio and checked the deployed view through the read-only connection. I also refreshed a separate Power BI Desktop copy with the SQL source selected. The workspace report retains the CSV as its default source.

| Check | Result |
|---|---|
| SQL 18 | I confirmed `analytics.vw_ae_reporting_monthly` with 25 typed columns. It covers September 2024 to August 2026 and retains all 4,751 raw lineage keys. The reader could see column types. SQL Server returned no stored definition to that account, so I reviewed the local DDL and compared the deployed data. |
| SQL 19 | I found zero exceptions in organisation-month grain, national-row coverage, missing or negative counts, or the six breach bounds. All 432 provider-to-England month-measure checks matched. All 4,751 rows matched the CSV across the 22 shared fields using monthly SHA-256 comparisons of sorted values. |
| SQL 20 | The 24 England records totalled 55,978,147 attendances, 14,237,403 four-hour breaches and 1,155,186 waits of 12 hours or more after the decision to admit. The weighted within-four-hours rate was 74.57%. Type 1 reconciliation returned 33,523,262 attendances, 13,400,360 breaches and 60.03% within four hours. |
| SQL 21 | The live matched-period check returned 112 eligible provider keys. Performance deteriorated in all three matched months for 37 and improved in all three for 27. Mid and South Essex fell 9.29 percentage points and recorded 2,927 more 12-hour DTA waits. |
| Power BI SQL refresh | The executive cards matched the SQL totals and the −20.43 percentage-point gap to the standard. August 2026 showed 2,342,959 attendances, 75.04%, 44,951 waits and −19.96 percentage points. Both trend charts responded to the month filter. |
| Power BI provider interaction | I used the Four-Hour Performance page tab and selected Airedale. The provider rate showed 59.49%, the England rate held at 60.03% and the gap showed −0.54 percentage points. Both lines rendered, and the page labels, navigator and card styling were visible. |

I used independent SELECT statements for the live checks of scripts 19–21. The reader restricts batch execution. I compared the selected report pages and interactions after refresh. Full accessibility, small-window behaviour and every navigation route still need coverage.

### Updated assessment

I score the portfolio **88/100**, up from 85/100 in the 24 November review below. SQL implementation rises from 12 to 14 out of 15 with the deployed view and live controls. Power BI modelling rises from 8 to 9 out of 10 with the SQL-backed refresh and direct KPI comparisons. I keep the other scores as recorded below.

Before GitHub publication, I would confirm the provenance of the September 2024 cleaned file and redistribution terms for the included data, check a clean-folder rebuild, and remove machine-specific paths from the release. For interviews, I would rehearse the England benchmark under a provider filter and the Mid and South Essex matched-period finding, including the limits of the available data.

## 24 November 2026 baseline

I ran the live checks on 24 November 2026 using the configured `nhs-local` reader. I extracted all rows by source ID, matched the 22 source values against the local CSV at each filename and row position, and calculated independent controls from the live extract. I also refreshed the changed Power BI project in Desktop using the local CSV snapshot.

| Control | Expected | Actual | Status |
|---|---|---|---|
| Raw schema, views and relationship visibility | 26 columns, approved objects visible, raw import table at source-row grain | 26 columns, raw/clean/analytics/dq schemas visible, one table, no views or FKs visible. Direct view query returned invalid object name. | Pass for raw inventory. View pending. |
| Source content and row lineage | Identical to local input CSVs | 4,751 rows, 22 source fields per row, zero disagreements by filename and source row number. Both lineage and raw IDs were unique. The four organisation and period fields had zero blanks. | Pass |
| Monthly grain, dates and coverage | 4,727 provider rows, 24 England totals, September 2024–August 2026 | Matches. One provider period per file and no duplicate organisation-month rows. February 2026 England row has a monthly period. | Pass |
| Numeric quality and impossible waits | No missing/invalid/negative counts and no breaches above paired attendances | Zero exceptions across 18 counts and six paired bounds. 52,666 numeric zero cells retained. | Pass |
| Published reconciliation | 24 × 18 provider sums equal published totals | 432 matched comparisons | Pass |
| Historical code coverage | 207 codes, 181 complete, 241 missing code-months | Matches. 120 codes with positive Type 1 activity across all 24 months. 12 codes have more than one normalised name. | Pass |
| Model coverage after splitting Bristol | 208 keys, 180 complete, 265 missing key-months | Matches in Power BI. A split adds one key to the grid and reduces the number of complete keys by one. | Pass |
| Weighted England Type 1 control | 33,523,262 visits, 13,400,360 breaches, 60.03% within four hours | Matches the live extract and report visuals across demand and four-hour pages. | Pass |
| Executive overview, all months | 55,978,147 visits, 74.57% within four hours, 1,155,186 12-hour DTA waits, −20.43 pp versus standard | All four matched after refresh. | Pass |
| Executive overview, August slicer | 2,342,959 visits, 75.04%, 44,951 DTA waits, −19.96 pp | Attendance confirmed with a live SQL SELECT. Desktop showed 75.04%, 44,951 and −19.96 pp. The open slicer obscured the attendance card during that interaction. | Pass for SQL control and visible filtered KPIs |
| Provider filter independence | Provider rate changes and published benchmark stays 60.03% | Airedale displayed 59.49% and −0.54 pp with the England trend retained. | Pass |
| Provider pages and pressure totals | Rendered benchmark and monthly detail, 9,495,458 Type 1 admissions and 1,155,186 DTA waits | Matched in Desktop. The adjusted Bristol chart rendered. June and July counts independently reconciled to 25,969/9,653 and 26,582/9,055 visits/breaches. | Pass for render and independent counts |
| Matched calendars and sustained change | National controls across 24 months, undefined early comparisons blank, and 112 comparable keys | SQL 20–21 reproduced these controls and the 37/27 direction counts in an in-memory SQLite check with compatibility functions for SQL Server date expressions. The Python snapshot check separately returned the same cohort and direction counts. | Pass for calculation logic. SQL Server execution pending. |
| View calculations and end-to-end SQL branch | Deploy 18, pass 19, verify 20–21 and compare both Power BI sources | Work is prepared. The reader cannot deploy database objects. Desktop testing used the snapshot. | Pending authorised deployment |
| Public data version and reproducibility | Source versions documented and root setup rerunnable | Local regeneration produced the same snapshot hash. April–August 2026 England attendance totals match the original published release column. September 2024 cleaning provenance and provider-level revision differences remain open. | Partial |

The live reader restricted some compound catalogue and profiling statements. I used simple approved reads and independently calculated the outcomes from the returned rows. I did not run SQL 19–21 against a deployed object. Desktop checks sampled interactions for selected visuals and do not cover every filter combination, accessibility workflow or display size.

## Recruitment evidence

| Role benchmark | What I demonstrate | Experience I would evidence separately |
|---|---|---|
| Band 5 Information Analyst | SQL transformations, source counts, reconciliation, Power BI, interpretation and communicating performance to non-technical readers | Advanced Excel where requested, handling live information requests, local reporting procedures and working in an information team |
| Band 6 Information and Performance Analyst | A maintainable analytical layer, explicit definitions, exception handling, comparative analysis and dashboard reporting | Trust or commissioner reporting ownership, negotiating specifications, formal data assurance and live stakeholder delivery |
| Band 6 Data Analyst | Complex health activity, data quality, diagnosis of discrepancies and scorecard design | Patient administration systems, information governance in production and managing real operational deadlines |

The employer specifications include SQL and reporting tools alongside communication, domain knowledge and practical delivery requirements. I reviewed Trac vacancies 8427865, 8366753 and 8367497 as role examples.

## Evidence-based scoring

I score each criterion as points earned out of its assigned weight. I reserve full marks for work with complete evidence, including the intended runtime and release checks.

| Criterion | Score | Evidence | Remaining weakness and action |
|---|---:|---|---|
| Business relevance and problem-solving | 14/15 | Executive and provider decisions, case study, operational questions | Validate the prioritisation with actual service leads in a work setting. |
| SQL architecture and technical implementation | 12/15 | Live raw schema and lineage, typed view, acceptance and analysis scripts | Deploy with approval. Run SQL 19–21 in SQL Server and validate execution against the intended batch and version. |
| Data quality and accuracy | 13/15 | Full live-to-source comparison, six bound checks, 432 reconciliations | Verify source publication versions and compare updated releases before using figures operationally. |
| Analytical depth and methodology | 13/15 | Weighted rates, matched-period comparisons, completeness, DTA burden and provider cohort | Assess sensitivity to cohort definition and case mix. A longer series would support seasonal modelling. |
| Power BI modelling and DAX | 8/10 | Separate facts, dimensions and explicit reconciled measures | Exercise the SQL source and remaining DAX/filter scenarios. |
| Dashboard design and usability | 8/10 | Seven rendered pages, month/provider controls, consistent palette and labelled measure scope | Validate keyboard and screen-reader use, and review card and axis readability at smaller sizes. |
| Business insights and recommendations | 9/10 | Quantified national and provider evidence with separate decision clocks | Corroborate priority signals with local pathways and data owners. |
| Documentation and reproducibility | 4/5 | Audit, model methodology, acceptance record, exporter and independent snapshot checks | Rebuild the SQL database from a clean instance with the approved deployment workflow. |
| Portfolio presentation and interview readiness | 4/5 | README, role comparison and practical study materials | Confirm publication rights and initialise or locate the intended Git repository before release. |
| **Total** | **85/100** | **Verified local analytics and Power BI report** | **SQL cutover and release gates remain.** |

I used AI assistance to review the project, write and check changes, compare live data with files and draft documentation. The figures above come from executed reads and Desktop observations. The code and acceptance steps are available to reproduce and explain independently.
