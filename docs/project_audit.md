# Technical and business audit

I reviewed the local SQL 01–19, the ingestion and export scripts, the 24 raw files, the processed snapshot and the existing Power BI project. SQL 19 was the last existing script. The workspace contains an ignore file and no Git metadata. I continued with SQL 20–21 and preserved the six existing report pages.

| Script | Question, inputs and outputs | Validation, limitations and disposition |
|---|---|---|
| 01 | Can I provision the project database? Creates the database and returns its catalogue entry. | Live reader reached the database. Retained the installer for an authorised clean build. |
| 02 | Where do pipeline stages belong? Creates raw, clean, analytics and data-quality schemas. Depends on 01. | All four schemas visible. Clean and data-quality schemas have no exposed analytical objects. |
| 03 | Can I preserve source values and row lineage? Creates the text-first raw table with source-file and row uniqueness. Depends on 02. | All 26 columns confirmed. A source-row key alone does not protect organisation-month grain. |
| 04 | Did the August pilot load correctly? Summarises source rows and reconciles three attendance columns. Depends on 03 and pilot ingestion. | Retained as pilot evidence. I standardised the total identifier to organisation code. |
| 05 | Do the pilot measures reconcile? Unpivots and sums raw counts against published totals. | Independent check covered all 18 measures and all 24 months. Invalid conversions need separate checks because sums can omit nulls. I standardised the total identifier. |
| 06 | Did each monthly file contribute the expected records? Groups raw data by import file and reports coverage and key exceptions. | Live row comparison confirmed exact file and row provenance. I corrected the February total classification. A revised file with a new name still needs a month-level duplicate check. |
| 07 | Did reporting scope change from April to August 2026? Pivots provider presence from raw. | Useful short-window investigation. SQL 16 provides the wider coverage analysis. Presence can include zero activity. |
| 08 | What changed in Bristol? Extracts raw RA7 and RVJ records around the merger. | Keeps predecessor evidence visible. A retained code can mask a footprint change. |
| 09 | How can I compare Bristol across July? Aggregates predecessors and successor and calculates a weighted Type 1 rate. | June and July controls are in the validation record. The short fixed window is retained as a case study. |
| 10 | Which consistent reporters added the most breaches between April and August? Ranks raw Type 1 cohorts by absolute change. | Useful for workload triage. Endpoint changes are sensitive to month length, volume and regression to the mean. |
| 11 | What happened between those endpoints? Lists monthly rates for the shortlist from 10. | Retained as exploratory work. Fixed shortlist and window limit reuse. |
| 12 | Do deterioration and demand move together in the shortlist? Compares successive rates and volumes. | Retained as exploratory work. Selection on deterioration and monthly aggregation limit causal interpretation. |
| 13 | Is the change in breach burden sensitive to month length? Converts raw April and August Type 1 breaches to daily averages. | Retained as a workload lens. Rate and daily burden answer different questions. |
| 14 | Did admission delays move with Type 1 deterioration? Compares provider-wide 12-hour DTA delays per day for selected organisations. | Retained with the DTA clock and all-provider scope explicit. It cannot assign those waits to Type 1. |
| 15 | What was national Type 1 performance over the short window? Uses England rows and weighted rates. | Retained as a historical benchmark. I standardised the total identifier. SQL 20 adds all-department performance and dynamic period comparisons. |
| 16 | Which codes report across the historical window and where are gaps? Builds a month grid and summarises coverage and name variation. | Independently confirmed 181 complete codes and 241 absent combinations. Raw code coverage counts retained RA7 as one code. |
| 17 | How does national Type 1 compare with a consistent cohort? Validates rate inputs and summarises raw monthly and annual counts. | Confirmed the England Type 1 controls independently. A name flag alone cannot resolve organisational changes. |
| 18 | Can I normalise periods, measures and reporting keys once? Defines a typed analytics view over raw. | Deployed and verified at 4,751 rows with all 18 source measures. File-level periods preserve the February national row and the Bristol split preserves benchmark scope. |
| 19 | Can I accept the reporting view? Checks grain, nulls, ranges, published reconciliation and control totals. Depends on 18. | Extended to validate all 18 numeric fields and six breach/attendance pairs. I ran the script in SSMS. Independent checks against the deployed view found zero exceptions. |
| 20 | What changed in demand, four-hour waits and admissions nationally? Uses the published rows from 18 for department totals, matched calendar comparisons, weighted rolling results and admission conversion. | I ran the script in SSMS. Independent checks against the live view confirmed the 24 monthly England records and headline totals. |
| 21 | Where should performance teams investigate persistence and burden? Pairs June–August 2026 with the same prior-year months in a fixed cohort. | I ran the script in SSMS. The live view confirmed 112 eligible keys, 37 worse in all three months and 27 better in all three. |

## Business questions and deliverables

| Decision | Evidence |
|---|---|
| Track England demand, standards and pressure | Executive overview, SQL 20 and the findings section |
| Distinguish activity volume, type mix and seasonal comparisons | Demand and waiting times, SQL 20, same-month year-on-year comparisons |
| Identify sustained change and check the benchmark | Four-hour performance, provider benchmarking, SQL 17 and 21 |
| Prioritise admission-delay investigation | Patient flow and pressure, SQL 14 and 21, DTA measures and admission conversion in SQL 20 |
| Decide when historical comparisons are defensible | Data quality and coverage, provider detail, SQL 07–09 and 16–17 |

I prioritised validating the existing imports, correcting the headline scope and introducing comparable-period controls. The next release gate is authorised view deployment, followed by SQL 19–21 and a Power BI refresh using the view. Publication also requires resolving or explicitly documenting the source release versions and removing local environment details.
