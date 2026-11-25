# Interview study guide

## 60-second introduction

I built an NHS A&E performance portfolio to answer how demand, four-hour performance and admission delays changed over two years. I kept the NHS England returns in a text-first SQL Server table, reconciled 18 measures against England totals and separated provider and national facts in Power BI. I used a fixed provider cohort and split the Bristol reporting key at the merger. In the frozen data, August 2026 had 2.34 million attendances, 75.04% within four hours and 44,951 waits of at least 12 hours after a decision to admit. I used the year-on-year and provider-level evidence to identify questions for further investigation. The report refreshes from the CSV snapshot, and I prepared a SQL Server view and acceptance checks for authorised deployment.

## Five-minute walkthrough

1. **0:00–0:45.** Explain the audience, the monthly reporting grain, and the operational questions. Describe when the two waiting clocks start.
2. **0:45–1:40.** Walk through SQL 01–06. Explain text-first ingestion, file and row lineage, reproducible loading, numeric validation and independent national reconciliation.
3. **1:40–2:25.** Use SQL 07–17 to demonstrate coverage, shortlist design, the Bristol predecessor comparison and the difference between workload and rates. Explain why 181 complete codes and 112 comparison keys answer different questions.
4. **2:25–3:30.** Use SQL 18–21 and the report. Explain the typed layer, 18 controls, weighted rates, matched calendar months, the star-style model and the provider filter boundary.
5. **3:30–5:00.** Discuss the summer changes and Mid and South Essex. Explain the next evidence you would seek and explain how the SQL view reconciles to the Power BI snapshot.

## Questions I can practise

| Question | My answer |
|---|---|
| Why store numbers as text initially? | I retain the source representation and can detect invalid values before typing. I retain file and row lineage for investigation. |
| How do I prevent double counting? | I validate one row per organisation and month, check one England row per month and keep those rows in separate analytical facts. |
| What happens if no eligible Type 1 visits exist? | SQL uses NULLIF and DAX uses DIVIDE so the rate is blank. A count of recorded zero remains a legitimate zero. |
| Why use date matching instead of LAG for YoY? | An exact date join preserves a missing comparison as null. A row offset can jump over a missing month. |
| Why do I sum numerators and denominators? | A 1,000-visit month should have more influence than a 100-visit month. A simple average gives equal weight. |
| What does CALCULATE do here? | It changes filter context. The count of positive Type 1 months uses it to restrict fact rows before counting distinct reporting months. |
| Why does the England benchmark survive a provider slicer? | The organisation dimension filters only the provider fact. Both facts receive filters from the reporting month dimension. |
| What does 95% mean? | It is the constitutional four-hour standard for arrival through admission, transfer or discharge across A&E types. The 78% March 2026 and 82% March 2027 recovery milestones are separate. |
| What does a 12-hour DTA delay measure? | It counts the interval after the decision to admit, at provider scope. Arrival-based 12-hour ED stay uses a different clock and would require a separate measure. |
| How would I respond to an executive querying a deterioration? | I would check source version, cohort, denominator and counts, then compare matched periods and ask local teams to review provider and pathway context. |
| What did I learn about comparing organisations? | An unchanged code can span a footprint change. Reporting completeness, positive activity, case mix and local definitions affect comparability. |
| What did AI help with? | AI assisted with code review, implementation, reconciliation and documentation. I can reproduce the checks and explain each decision from the source data and scripts. |

## Independent exercises

- Recreate the August 2026 England all-department rate using all six activity fields and the corresponding breach fields. Then compute the Type 1 unbooked rate and explain the difference.
- Build a 24-month grid in SQL using the raw organisation codes. Count missing combinations and repeat after splitting RA7. Explain why the count increases by 24.
- Remove one month from a scratch extract, then compare an offset-based year-on-year query with an exact calendar join.
- In Desktop, filter August 2026 and then choose a provider on its benchmark page. Explain which numbers move and reconcile one against the source.
- Identify the highest comparable-provider 12-hour DTA burden, then find a provider with the largest change among the reviewed rows and explain how those priorities differ.

The [audit](project_audit.md) gives the purpose of every SQL script. The [methodology](reporting_methodology.md) documents the findings and evidence limits.
