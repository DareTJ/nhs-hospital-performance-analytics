# Power BI refinement and acceptance

## 25 November 2026 portfolio refinement

I used the 88/100 portfolio assessment as the baseline for this pass. The older 72/100 and 86/100 scores below cover dashboard design only. I inspected the seven page definitions, 74 visual definitions, 12 slicers, 122 explicit interaction rules, 28 measures, four tables and three relationships. The report, pages and visuals have no saved explicit filter rules. Page filtering comes through slicers, the configured visual interactions and the model. Comparing the revised report with the checkpoint confirmed that all visual bindings and page interaction rules matched.

| Page | Review and change |
|---|---|
| Executive Overview | Four England KPIs and two monthly trends. I added a dated June–August comparison alongside the definitions of both wait clocks. The comparison is fixed to those calendar periods while cards and trends respond to the month slicer. |
| A&E Demand & Activity | Three Type 1 cards and two trends separate booked activity from the unbooked department series. I increased the clearance under the month and provider controls. |
| Four-Hour Performance | Three cards and two chart series show weighted Type 1 rates and the England gap. The national fact is linked to Period, so provider selection does not change the benchmark. I increased the clearance beneath the slicers. |
| Provider Performance | Three cards and the provider table apply the month, provider and history selections. I kept the table for comparing exact results and reporting coverage. |
| Patient Flow & Admissions | Two trends and three cards distinguish Type 1 admissions from provider-wide decision-to-admit waits. The daily measure uses all calendar days in the reported months. |
| Provider Detail & Bristol | The monthly table follows the selected provider. The Bristol series uses the merger-adjusted footprint, retains the month context and remains independent of the provider dropdown. |
| Data Quality & Coverage | The cards and table report the full period. Absent provider-month combinations and reported zero activity are separate concepts. |

I added alternative text to 53 data visuals, slicers and navigators and set tab order from top to bottom and left to right. The six pages with filters received 28 extra canvas units between slicers and cards. I kept the existing layout, navy and neutral palette, card treatments, chart encodings and numeric formats. The navy and body text used in the revised overview note measure 11.85:1 and 7.75:1 on white respectively. These are two colour-pair checks. [Power BI accessibility guidance](https://learn.microsoft.com/en-us/power-bi/create-reports/desktop-accessibility-creating-reports)

The dimension-to-fact model keeps England at month grain and providers at provider-month grain. The 28 DAX measures use additive counts, ratios of sums and explicit blank handling where a denominator is missing. The largest fact contains 4,727 rows. I retained the existing model, SQL and data and did not claim a performance improvement from layout changes. The snapshot validator passed, including the England, provider coverage, comparability and Bristol controls. An independent sum of the source snapshot gave 7,027,384 and 7,268,445 summer attendances and 110,059 and 141,855 12-hour waits, supporting the overview comparison.

The rollback file is `logs/NHS-PBIR-before-accessibility-pass.zip`, SHA-256 `E120757EE871194D1736FB9DDF2425D3B9F3C7E78B013F06948C045B83F91171`. To restore, close the project and extract its `definition` directory over `powerbi/NHS_Hospital_Performance.Report`.

### Desktop acceptance after the changes

I refreshed the workspace PBIP from its CSV source and reviewed all seven populated pages at 37% fit with Desktop authoring panes visible. I navigated through the native page tabs and checked the matching active states on the canvas navigator.

| Test | Observed result |
|---|---|
| Executive totals and month selection | Default cards showed 55,978,147 attendances, 74.57% within four hours, 1,155,186 waits and a −20.43 percentage-point gap. September 2024 showed 2,214,217, 74.22%, 38,880 and −20.78 percentage points. Both charts narrowed to September and returned to the full period when cleared. The dated summer comparison remained visible. |
| Provider selector clearance | The Four-Hour Performance and Provider Detail dropdown arrows opened directly at 37% fit. |
| Single and multiple provider selections | Airedale showed 59.49% versus England at 60.03%. Adding Ashford and St Peter's yielded 58.12% for the selected providers. Clearing both restored the 60.03% overall rate. |
| Blank rate | Barking Hospital UTC showed blank Type 1 rate and gap cards. The England card still showed 60.03% and the England series remained visible. |
| Bristol reference | Selecting Airedale changed the monthly detail and displayed 143,153 Type 1 attendances and 4,636 12-hour waits. The Bristol series retained its full-period shape. |
| Coverage and patient flow | Coverage showed 208 reporting histories, 180 complete histories and 265 missing provider-month records. Patient Flow showed 9,495,458 Type 1 admissions and 1,155,186 12-hour waits. |

### Before and after

I score the portfolio **89/100**, up from **88/100**. Dashboard design and usability moves from 8/10 to 9/10 for the revised layout, reproducible dropdown fix, report descriptions and clearer executive comparison. Other category scores are unchanged. The score meets the 89 minimum. It falls short of 95 because some accessibility, release and runtime evidence is still missing.

For accessibility acceptance, use Tab and Shift+Tab through the reading order on all seven pages with a screen reader active, check that it announces each visual description, and exercise each canvas navigator destination. Repeat with the authoring panes closed and a smaller window to check the provider dropdown and the longest table labels. I verified the saved descriptions and order in the report definition. I did not verify spoken output. The revised report was refreshed from CSV. The [previous SQL refresh](validation_and_portfolio_review.md) verified the same model before these presentation edits. No new controlled Performance Analyzer or Service timing is available.

This pass keeps the native tooltips, visible provider detail page and individual slicer clearing. It adds no report-page tooltip, drill-through destination, reset-all control or dynamic titles. The Desktop checks above sample actual interactions and do not cover every visual pair or provider/month combination. Use the [validation and portfolio review](validation_and_portfolio_review.md) for the release checks, including data provenance and a portable rebuild.

## Earlier refinement and acceptance

I refined the existing seven-page project in place. I kept all 67 visuals and the existing SQL, source data, relationships and DAX calculations. I changed seven `page.json` files and the visual definitions under `powerbi/NHS_Hospital_Performance.Report/definition/pages`. I updated the README, this review and the Desktop captures. The rollback archive is `logs/NHS-PBIR-before-refinement.zip`. It contains the previous report definition and is excluded by the existing log ignore rule. Its SHA-256 starts with `C297463BF53B670C`.

## Page review

| Page | Issue in the original layout | Refinement |
|---|---|---|
| Overview | Long DTA card caption and cramped chart labels | Four equal KPI cards, compact captions and explicitly labelled percentage gap |
| Demand | Cropped card captions and repeated axis wording | Taller KPI cards, shorter legends and a wider provider selection |
| Four-hour waits | Dense measure names and potential confusion about England context | Short labels, protected national benchmark card and an explicit scope note |
| Benchmark | Long reporting names and dense headings | Wrapped table text, compact headings and separate provider and history dropdowns |
| Patient flow | Long daily DTA caption and ambiguous abbreviations | Compact labels, a clear decision-to-admit chart title and an explanation of the daily denominator |
| Provider detail | Table required horizontal scrolling to reach DTA counts | Broader table, compact headers, full-period Bristol trend axis and a provider filter that leaves the Bristol reference alone |
| Coverage | Dense headings and grand totals for measures with mixed grains | Shorter table and card captions, wrapped text and a suppressed grand-total row |

I also shortened the native tabs so all seven fit in the Desktop navigation strip. Charts use the existing month-start key as a continuous axis. The slicers and detail tables retain their month labels. I retain both full provider names and reporting keys.

## Interaction matrix

| Input | Intended response | Protected context |
|---|---|---|
| Overview month | Filter four England cards and both England trends | Published England rows remain the source |
| Demand month and provider | Filter the three cards and two activity charts | Department series show their published unbooked counts |
| Four-hour month | Filter the provider and England cards and both chart series | Both rates use summed numerators and denominators |
| Four-hour provider | Filter provider rate, gap and provider series | The England card ignores this interaction. The England series retains national scope through the model |
| Benchmark month, provider and history | Filter the KPI cards and provider table | England retains published scope over the selected months |
| Patient flow month and provider | Filter cards and both charts | DTA remains a provider-wide clock |
| Detail month | Filter cards, monthly table and Bristol chart | Bristol uses the adjusted reporting footprint |
| Detail provider | Filter cards and monthly table | Bristol chart ignores provider selection |
| Chart marks and table rows | Permit inspection, tooltips and table sorting | Selection does not re-slice KPIs, peer visuals or dropdowns |
| Coverage | Inspect and sort the full-period reporting-key inventory | Coverage cards stay on the full portfolio |
| Native tabs and selecting or clearing items | Navigate and clear a slicer independently | Each page retains its own filter context |

I use the existing department series for scope comparisons. A global department slicer would invite comparisons against Type 1-specific metrics and provider-wide DTA waits using incompatible scopes. I retain local slicers and native tabs. Provider detail remains a visible page with its own provider selector.

## Weighted assessment

The baseline uses the original saved definition and earlier Desktop evidence. The second score reflects the checks in this review. Both scores are out of 100 and apply to the dashboard only.

| Criterion | Before | After | Evidence and remaining limitation |
|---|---:|---:|---|
| Visual design | 15/20 | 18/20 | Common card treatment, concise typography and a consistent palette. No stakeholder design review. |
| Text readability | 10/15 | 13/15 | Short captions, wider provider controls and detail table, wrapped table text. Very small windows can still require zoom or scroll. |
| Alignment and layout | 8/10 | 9/10 | Seven pages checked for bounds and overlap. Additional spacing prevents competition between slicers and card authoring controls. |
| Chart communication | 7/10 | 9/10 | Same analytical series and measures. Clear units, shorter legends, continuous time axes and weighted comparisons. Custom tooltip pages are outside the current design. |
| Interactions | 9/15 | 12/15 | Explicit slicer and protected-context rules. The complete cross-product of filters and empty states still needs testing. |
| Navigation and experience | 7/10 | 8/10 | All seven tabs navigable with active-page indicators. Filter clearing uses each slicer. |
| Data accuracy | 10/10 | 10/10 | Snapshot controls and live raw SQL checks reconciled. Live reporting-view cutover remains a separate release gate. |
| Accessibility and consistency | 3/5 | 4/5 | Legible captions and textual scope cues. Assistive technology and small-screen acceptance remain open. |
| Responsiveness | 3/5 | 3/5 | Visual count and model unchanged. Desktop redraw observed. No comparable Performance Analyzer baseline or Service timing. |
| **Total** | **72/100** | **86/100** | Desktop dashboard assessment. |

## Data and layout checks

I reran the independent snapshot control script and used the read-only SQL connection to verify 24 national rows, 33,523,262 Type 1 visits, 13,400,360 Type 1 breaches and 1,155,186 waits of at least 12 hours after decision to admit. The live August attendance and DTA counts were 2,342,959 and 44,951. The live validation used the raw SQL table because the reporting view is awaiting deployment.

### Desktop acceptance results

| Test | Observed result |
|---|---|
| Default render and tab navigation | All seven pages rendered after refreshing the CSV import. I reviewed the complete canvas at 63% fit-to-page and sampled the Overview with the authoring panes open at 45%. |
| Large executive values | 55,978,147 attendances, 74.57% within four hours, 1,155,186 12-hour DTA waits and −20.43 pp all fit in their cards. |
| Single provider and long name | Airedale returned 59.49%. Ashford and St Peter’s Hospitals NHS Foundation Trust fit in the expanded dropdown. |
| Two providers, all months | Airedale plus Ashford and St Peter’s returned 58.12%, with published England still at 60.03% and the gap at −1.91 pp. |
| One and two months with two providers | September 2024 gave 59.49% for England and a +5.14 pp gap. September and October together gave 64.08% for the two providers, 58.58% for England and +5.51 pp before rounding the component rates. |
| Clear selections | Unchecking the selected months and providers restored All and the 60.03%/60.03% default. |
| Zero-activity provider | Barking Hospital UTC showed a blank Type 1 rate while the national trend remained visible. |
| Bristol isolation | Selecting Airedale reduced provider activity to 143,153 Type 1 visits and 4,636 DTA 12-hour waits. The Bristol chart retained its full-period trajectory. |
| Benchmark row and history interactions | Selecting the Birmingham row did not change the KPI totals. The Bristol merger history filter returned only its three reporting keys, with 22, 22 and 2 reported months. Clearing it restored 33,523,262 visits and 60.03%. |
| Historical coverage | The cards displayed 208 reporting keys, 180 complete histories and 265 missing key-months. Partial coverage remained visible in the table without a grand total across the different grains. |
| Performance Analyzer | One refreshed Coverage render showed 463 ms for the table and 339–393 ms for the cards. One change to Demand showed 945–946 ms for the charts and 963–1,048 ms for the cards. These are individual post-refresh Desktop visual durations, with no controlled before-and-after timing baseline. |

The report uses a navy-neutral palette, readable numeric labels and explicit series names. Colour is an additional cue. I kept the existing visual count and import model. Remaining checks include representative missing-month combinations, all visual-pair interactions, keyboard navigation, screen readers, smaller windows and Service performance. Drill-through, reset-all bookmarks and synced slicers were outside the implemented interaction design. The continuous date axis may show intermediate calendar ticks when a narrow range is selected. Data points remain monthly.

[Overview](powerbi_executive_overview.jpg) · [Provider detail](powerbi_provider_detail.jpg) · [Coverage](powerbi_data_quality.jpg)
