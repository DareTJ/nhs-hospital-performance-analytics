# Reporting methodology and validation

## Source and reporting grain

I use the local monthly CSVs from the [NHS England A&E Attendances and Emergency Admissions collection](https://www.england.nhs.uk/statistics/statistical-work-areas/ae-waiting-times-and-activity/). The reporting grain is one organisation and month, with one published England total per month. I retain the exact filenames in the raw directory. The [source manifest](data_sources.md) identifies each frozen release. The September 2024 input matches the official CSV after six empty columns are removed.

The model uses separate provider and published England fact tables linked to a reporting month dimension. The organisation dimension filters the provider fact only. Published England measures follow the month filter and remain the same when I choose a provider. I use the latest name within each reporting key for display. Where other provider names change, I flag the history for review and retain the reported code.

The month and organisation dimensions each have one row per key. Their three one-to-many, single-direction relationships connect month to both facts and organisation to the provider fact. I use a month-grain date key and sort the display label by its date. The provider and England facts have no direct relationship. The reporting facts load in import mode. The SQL Server and CSV branches use the same fixed reporting window, and the month labels and relationships are independent of the chosen branch.

For Bristol, I distinguish the pre-merger RA7 from the merged RA7 in provider comparisons. The adjusted Bristol series combines RA7 and RVJ before July 2026 and uses merged RA7 from July. The month selector applies to the Bristol chart. Provider selections retain the Bristol comparison series. The [ODS merger register](https://digital.nhs.uk/services/organisation-data-service/news-and-alerts/mergers-and-acquisitions) confirms the effective date and retained code.

## Measures

| Measure | Definition |
|---|---|
| England all A&E within four hours | Published England attendance volume less breaches, divided by attendance volume. Both counts include booked and unbooked Type 1, Type 2 and other departments. |
| Type 1 within four hours | Sum of unbooked Type 1 attendances less the sum over four hours, divided by summed unbooked Type 1 attendances. The rate is blank when the denominator is zero. |
| Gap to England | Provider within-four-hour rate minus the published England Type 1 rate for the selected months, in percentage points. |
| Reported months | Distinct months with a provider record in the current filter context. It can include months with zero Type 1 activity. |
| Type 1 admissions | Emergency admissions via Type 1 A&E, using the corresponding source column. |
| DTA waits | Provider-wide counts in the published decision-to-admit wait bands. Their clock starts at the decision to admit. The measure does not represent the full A&E journey or a Type 1-only count. |
| DTA 12 hours or more per reporting day | Selected 12-hour DTA waits divided by the calendar days in distinct months with provider records under the current selection. |
| Booked Type 1 attendances | The separate booked Type 1 source measure. I leave it out of the main Type 1 numerator and denominator. |
| A&E admission conversion | Emergency admissions via Type 1, Type 2 and other A&E divided by all A&E attendances. Other emergency admissions are reported separately. I use conversion as an aggregate activity ratio. |

## Evidence and interpretation

I reconciled the live SQL Server records and local provider CSVs to all 18 published measures across 24 files. The dashboard exporter checks all 18 fields, rejects missing or duplicate organisation codes, tests breach bounds and requires each month to reconcile to its England record. It produced 4,751 rows across 24 months, including 24 England totals.

My earlier analysis in SQL 16 records 181 of 207 organisations with complete reporting coverage and 241 missing organisation-month combinations. SQL 17 records an England total of 33,523,262 Type 1 attendances and 13,400,360 over four hours. Organisation coverage and positive activity are separate criteria. A missing return or changed name can justify a review of comparability.

These figures describe activity and waits at provider level. They do not identify individual patient journeys or establish the causes of delays. Comparisons reflect different provider roles and coverage. The gap to England is descriptive and should be interpreted with the provider's reporting months and case mix in mind.

## SQL deployment and acceptance

I ran SQL 18–21 in SQL Server Management Studio. The deployed reporting view has 4,751 rows and matches the snapshot across all 22 shared fields. Read-only checks confirmed the fixed 24-month window, raw lineage and the England and provider controls. I recorded the results in the [validation and portfolio review](validation_and_portfolio_review.md).

For report acceptance I check the England totals, select a single month, filter a provider, check that England is unchanged by the provider selection, and compare the pressure and detail visuals against the snapshot. I also verify the Bristol series at the June–July boundary and clear the filter selections. Custom drill-through and a single reset-all bookmark are future interaction work unless separately implemented and tested.

An independent SQL aggregate against the local CSV snapshot reproduced 33,523,262 Type 1 attendances, 13,400,360 breaches and 60.03% within four hours. It returned 1,407,535 attendances and 60.86% for August 2026. The Bristol control totals were 25,969 attendances and 9,653 breaches in June, and 26,582 attendances and 9,055 breaches in July. This check used a temporary in-memory SQL engine and the local snapshot.

## Standards and release versions

I apply the 95% constitutional standard to all-department arrival-to-disposal performance. I record 78% as the March 2026 operational milestone and 82% as the March 2027 trust ambition. I use the March 2026 national outturn as a historical comparison and keep the March 2027 milestone outside the observed period. I retain the Type 1 England rate as a descriptive peer reference. The 2026/27 12-hour improvement ambition uses time from arrival in the ED, a separate measure from the DTA waits in this project. [NHS Constitution handbook](https://www.gov.uk/government/publications/supplements-to-the-nhs-constitution-for-england/the-handbook-to-the-nhs-constitution-for-england) · [2025/26 urgent and emergency care plan](https://www.england.nhs.uk/long-read/urgent-and-emergency-care-plan-2025-26/) · [2026/27 planning framework](https://www.england.nhs.uk/long-read/medium-term-planning-framework-delivering-change-together-2026-27-to-2028-29/)

The 2024/25 planning guidance also set a minimum of 78% for March 2025. The frozen all-department result was 74.98%, 3.02 percentage points below that milestone. [2024/25 NHS operational planning guidance](https://www.england.nhs.uk/long-read/2024-25-priorities-and-operational-planning-guidance/)

I preserve the frozen extract for reproducibility. The five local monthly attendance totals for April–August 2026 match the original figures in the NHS England revision table. The revised August figure was 2,344,278, 1,319 higher than the 2,342,959 in this project. I would use the latest approved releases for operational reporting and reconcile provider changes before interpreting them. [NHS England revisions](https://www.england.nhs.uk/statistics/wp-content/uploads/sites/2/2026/11/Statistical-commentary-October-2026-DW43tf-1.pdf)

I attribute the published data to NHS England. Its website permits reuse of eligible information under the Open Government Licence and identifies exclusions. I verified all 24 inputs against the published files and recorded the comparison and attribution in the [source manifest](data_sources.md). [NHS England copyright and reuse terms](https://www.england.nhs.uk/terms-and-conditions-2/)

## Findings and actions

| What I found in the frozen data | Why it matters and who can act |
|---|---|
| Across 24 months England recorded 55,978,147 attendances, 74.57% within four hours and 1,155,186 12-hour DTA waits. In March 2026 the all-department rate was 77.11%, around 0.89 points below the 78% recovery milestone. | Executive performance teams can use the all-department baseline and should display the period, measure scope and standard alongside the rate. |
| June–August attendances rose from 7,027,384 in 2025 to 7,268,445 in 2026 (+3.43%). The weighted four-hour rate fell from 75.95% to 75.15%. DTA waits of 12 hours or more rose from 110,059 to 141,855 (+28.89%). | Urgent-care and flow leads can review demand and long waits together using the same calendar period. Two summer windows support a year-on-year comparison and are insufficient for a robust seasonality model. |
| August 2026 recorded 2,342,959 attendances and 75.04% within four hours. The Type 1 unbooked rate was 60.86%. The August DTA 12-hour count rose from 35,909 to 44,951 year-on-year. | The executive rate and the Type 1 benchmark answer different questions. Performance teams should retain the department and booking scope when briefing results. |
| Among 112 comparison keys, 37 had worse Type 1 rates in all three matched months and 27 improved in all three. Mid and South Essex (RAJ) fell 9.29 points in the weighted summer comparison while Type 1 unbooked demand fell 7.13%. Its 12-hour DTA waits rose from 733 to 3,660. | Provider performance and flow teams could verify coding and scope first, then review admission pathways and local flow records. The aggregate trend cannot identify the causes. |
| University Hospitals Birmingham (RRK) had 6,568 summer DTA 12-hour waits in the eligible cohort compared with 4,861 the previous summer. Royal Free London (RAL) improved its weighted Type 1 rate by 2.45 points while DTA waits rose by 687. | The largest workload and the largest movement identify different review priorities. Examine both clocks and reconcile each with local activity before taking action. |
| Across the 112 eligible keys, the Pearson association between summer Type 1 volume growth and improvement in the within-four-hour rate was +0.32. | I treat this as an exploratory, unweighted association across providers. Case mix, coding and service footprint can affect both variables. I would test sensitivity before using the association in planning. |

I chose the three summer months to match the year-on-year demand analysis. I require positive Type 1 activity in every portfolio month and a consistent reported name within each benchmark key. A worse month means a higher breach rate than the same month the previous year, with a tie counted separately. I use absolute DTA burden and report change alongside it. Cohort rules reduce obvious scope effects and leave residual differences in case mix.
