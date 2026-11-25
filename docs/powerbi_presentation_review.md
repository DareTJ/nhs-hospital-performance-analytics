# Power BI presentation review

I refined the seven existing pages for portfolio and interview use. The changes are in the report’s page and visual definitions. I retained the 67 visual positions, underlying query bindings, model, SQL and page interactions. A local rollback archive is available at `logs/NHS-PBIR-before-presentation.zip`.

## Colour and terminology

| Colour | Use |
|---|---|
| Deep navy `#003087` | Report titles, chart headings and headline figures |
| Professional blue `#005EB8` | Core activity and performance trends |
| Slate `#425563` | Secondary text and England comparison line |
| Teal `#007F73` | Other department attendances as a separate analytical series |
| Dark amber `#9A6200` | Type 1 waits exceeding four hours |
| Muted red `#AE3448` | Long waits after the decision to admit |
| Off-white `#F5F7FA`, white `#FFFFFF` and pale border `#D5E1EB` | Canvas, visual containers and separation |

I use red and amber to draw attention to wait measures. Comparing periods still requires reading the value and its direction. Signed gaps retain their sign and state the unit as percentage points. The four-hour arrival clock and the admission-decision clock are written separately. The report uses NHS-inspired colours and remains an independent portfolio project.

## Page review

| Page | Score | Rendered evidence and limitation |
|---|---:|---|
| Overview | 94/100 | All four large values and expanded captions fit. The source note distinguishes the two wait clocks. The 95% reference is in the gap card. |
| Demand | 91/100 | The three department lines and amber long-wait line rendered as intended. The low-volume Type 2 series shares an axis with much higher-volume series. |
| Four-hour waits | 93/100 | The full unit fits and blue provider and slate England lines are distinguishable after a provider is selected. The lines coincide when all providers are selected. |
| Benchmark | 88/100 | The full percentage-point heading and sampled long names fit. The detailed table still benefits from a large canvas. |
| Patient flow | 92/100 | The wait-band labels and red prolonged-wait series rendered, and the dated note remained visible across two lines. The daily rate is an aggregate across selected providers. |
| Provider detail | 89/100 | All six sampled table headings and the Bristol chart fit. The monthly table scrolls vertically to show all 24 months. |
| Coverage | 89/100 | The 208, 180 and 265 control cards and expanded headers fit. The detailed inventory is intended for inspection at desktop scale. |

The [interaction and design review](powerbi_refinement_review.md) records the earlier comprehensive filter and performance tests. I use targeted checks for this presentation change.

## Targeted acceptance

- I inspected all seven pages after refreshing the existing CSV import in Power BI Desktop at 63% fit-to-page on a 1280 × 759 capture. I also inspected the Overview at reduced scales with the authoring panes open. I found no material clipping in the reviewed views.
- The Overview displayed 55,978,147 attendances, 74.57% within four hours, 1,155,186 waits of 12 hours or more and a gap of −20.43 percentage points to 95%.
- Airedale displayed 59.49% across all months, while published England stayed at 60.03%. The gap was −0.54 percentage points. Selecting September 2024 returned 59.49% for England, with the signed gap at +0.21 percentage points. Clearing the month restored the all-month baseline.
- All 67 visual query definitions matched the checkpoint except for display captions. All seven page interaction lists matched exactly. The snapshot hash remained unchanged, and the independent snapshot validation passed.
- I found no remaining visible `pp`, `DTA` or `YoY` in the title, alias and narrative scan. The existing internal measure identifiers remain bound to their original calculations.
- The principal foreground colours have calculated contrast of 4.90:1 to 11.85:1 on white. I checked the coloured series and named legends visually. The contrast calculation covers the selected palette, and I did not conduct a screen-reader acceptance test.

## Overall assessment

| Criterion | Score | Basis |
|---|---:|---|
| Professional appearance and colour | 23/25 | Rendered palette separates activity, benchmark and pressure measures. |
| Terminology and communication | 14/15 | Expanded units, defined wait clocks and concise existing tooltip field captions. |
| Hierarchy, alignment and spacing | 14/15 | Existing grid preserved. Headline values and pressure indicators are easy to identify. |
| Readability and truncation | 13/15 | Tested fit-to-page labels fit. Dense tables and smaller windows need further sampling. |
| Storytelling and stakeholder relevance | 9/10 | Each page has a defined analytical question and the patient-flow note anchors an actual change. |
| Functional preservation | 9/10 | Targeted provider and month tests passed and exact interaction configuration was preserved. |
| Accessibility and consistency | 4/5 | Contrast checked and series have text labels. Assistive technology remains untested. |
| Portfolio presentation | 5/5 | Current Desktop screenshots, documented scope and a recoverable report definition. |
| **Overall** | **91/100** | **Verified Desktop presentation.** |

Full screen-reader and small-window acceptance remain open. The report uses the existing native tooltips and contextual notes. See the [validation and portfolio review](validation_and_portfolio_review.md) for the later SQL deployment and refresh checks.

[Overview](powerbi_executive_overview.jpg) · [Airedale compared with England](powerbi_four_hour_comparison.jpg) · [Patient flow](powerbi_patient_flow.jpg) · [Provider detail](powerbi_provider_detail.jpg) · [Coverage](powerbi_data_quality.jpg)
