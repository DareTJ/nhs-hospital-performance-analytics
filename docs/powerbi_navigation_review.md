# Power BI navigation and page titles

I renamed the seven existing pages and matched each canvas heading to its tab. The report order and internal page identifiers remain the same.

| Previous tab | New tab and page heading | Purpose |
|---|---|---|
| Overview | Executive Overview | Summarise national demand, four-hour performance and long waits. |
| Demand | A&E Demand & Activity | Compare attendances by department and Type 1 volumes and waits. |
| Four-hour waits | Four-Hour Performance | Compare Type 1 performance within four hours with published England figures. |
| Benchmark | Provider Performance | Compare provider results and reporting histories. |
| Patient flow | Patient Flow & Admissions | Review emergency admissions and waits after the decision to admit. |
| Provider detail | Provider Detail & Bristol | Inspect monthly provider results and the merger-adjusted Bristol series. |
| Coverage | Data Quality & Coverage | Review missing returns, reporting history and changes in provider names. |

I used Power BI’s built-in Page Navigator with equal-height buttons, deep navy for the current page and pale blue-grey for the other destinations. I placed it between the title and the analysis on each page. The navigator derives labels and order from the existing pages. Desktop retains its native tabs beneath the canvas. [Microsoft Page Navigator guidance](https://learn.microsoft.com/en-us/power-bi/create-reports/button-navigators)

I reserved 62 additional vertical canvas pixels for the navigation row. The charts, tables, cards and slicers retain their dimensions and relative spacing. The seven internal page identifiers, page order and visual interaction lists matched the checkpoint. After allowing for the vertical offset and renamed headings, all 67 original visual definitions matched the checkpoint. I found no saved report bookmarks or drill-through destinations that required retargeting.

The local rollback archive is `logs/NHS-PBIR-before-navigation.zip`. It contains the report definition from before these changes. The semantic model, SQL scripts and snapshot were outside the editing scope.

## Desktop acceptance and score

I refreshed the existing snapshot and activated all seven on-canvas destinations using button focus and Ctrl+Enter in Power BI Desktop. Each activation loaded the matching heading and moved the navy selection to the destination. I returned to Executive Overview and confirmed the existing headline values, including 55,978,147 attendances and 74.57% within four hours.

| Criterion | Score | Evidence |
|---|---:|---|
| Business communication | 25/25 | Each tab matches its heading and analytical scope. Four-Hour Performance covers the within-four-hours rate and benchmark. |
| Professional appearance | 23/25 | Equal-height and equal-width buttons, white-on-navy selected state and consistent blue-grey resting state. Native Desktop tabs retain their platform appearance. |
| Text readability and completeness | 19/20 | Every on-canvas label fit on a single line in the tested Desktop views. The native authoring strip can scroll, and smaller display sizes were not assessed. |
| Design consistency | 15/15 | The same navigator sits at the same position on all seven pages and uses the existing palette. |
| Navigation functionality | 14/15 | All seven in-report destinations and their active states were verified with Ctrl+Enter. Power BI Service and mobile navigation were outside this check. |
| **Total** | **96/100** | **Targeted desktop navigation assessment.** |

The final report was left open on Executive Overview. [Desktop navigation screenshot](powerbi_executive_overview.jpg)
