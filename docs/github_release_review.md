# GitHub release review

I reviewed the repository on 25 November 2026. The baseline below uses the GitHub portfolio rubric. The earlier 89/100 score describes the overall analytics portfolio after the Desktop design pass and uses a different rubric.

## Before and after

| Criterion | Baseline | Release candidate | Evidence and deduction |
|---|---:|---:|---|
| Professional presentation and first impression | 12/15 | 14/15 | The main result, scope and latest executive page appear before the implementation detail. The final GitHub presentation remains to be checked on the destination repository. |
| README quality and originality | 12/15 | 14/15 | The text explains the two wait clocks, release revisions, provider comparability and decisions that the results can support. A review by a recruiter or external analyst would test whether the balance works for a new reader. |
| Technical depth and implementation | 18/20 | 18/20 | SQL lineage, typed reporting view, rolling rates, matched months, separate fact tables and DAX filter context have direct evidence. A full SQL rebuild on a separate installation and controlled report timings remain open. |
| Data accuracy and analytical credibility | 13/15 | 14/15 | The 24 official-source comparisons, 432 reconciliations and reproducible snapshot support the quantitative claims. The comparison remains descriptive and has limited case-mix and cohort-sensitivity evidence. |
| Dashboard and visual presentation | 12/15 | 14/15 | Seven current 1,800-pixel-wide exports and the prior Desktop acceptance provide visual and interaction evidence. Full screen-reader and small-window acceptance remain open. |
| Repository organisation and reproducibility | 8/10 | 9/10 | Linkable PBIP, source manifest, local setup, clean snapshot regeneration and Git exclusions. A separate SQL environment remains untested. |
| Business relevance and storytelling | 9/10 | 9/10 | The national wait burden and Mid and South Essex comparison lead to specific verification questions for flow teams. Local service data and stakeholder review would be needed to substantiate operational causes or interventions. |
| **Total** | **84/100** | **92/100** | The release candidate is suitable for application and interview use. |

## What changed

- I rewrote [the README](../README.md) around the national findings, provider comparability, actual report outputs and a short setup.
- I added seven current PNGs under [assets/powerbi](../assets/powerbi). These came from an export in Power BI Desktop. Four-Hour Performance and Provider Detail show Airedale selected.
- I added the [source manifest](data_sources.md) with official links, release versions, checksums, attribution and the September cleaning comparison. I compared the five original summer-period releases with their later revisions by provider.
- I added [reproduction instructions](reproduce.md), updated the methodology and historical validation links, and removed a machine-specific Power BI path and SQL host. The three SQL connection scripts use the `NHS_SQL_SERVER` environment variable with a local Express default. The snapshot exporter now creates the output folder if it is missing.
- I extended the Git exclusions for local settings, data caches and local exports. The CSV attributes preserve source bytes during cloning. The SQL files, report layouts, DAX calculations and input data remain as validated.

I inspected the Desktop export of all seven pages and rendered the README locally as HTML. I checked 58 internal link targets and 36 distinct external URLs. The 177-file Git inventory excluded local caches, logs and settings. A pattern scan of release text found no credentials or private machine paths. A separate folder with copied raw files regenerated a byte-identical reporting snapshot and passed the validator, including the England, provider coverage and Bristol controls. I also opened a cache-free PBIP copy from a separate folder, set its snapshot path in Desktop and refreshed. The four England headline cards matched, and Airedale showed 59.49% while England stayed at 60.03%. The Python connection check reached the existing SQL database when I supplied the actual server instance through the environment variable. The prior read-only SQL and SQL-backed Power BI acceptance are in the [validation review](validation_and_portfolio_review.md).

## Publish after reviewing the staged files

**Suggested description**  
England A&E performance and patient flow across 24 months of NHS returns, reconciled in SQL Server and explored in Power BI.

**Suggested topics**  
`power-bi`, `sql-server`, `dax`, `python`, `nhs`, `healthcare-analytics`, `data-quality`, `business-intelligence`

The workspace has no Git metadata. If using it as the new repository root, initialise it after approval. If the intended repository already exists, start from its clone and copy the reviewed files into it. Run the review commands before committing. The inclusion of `data` below is intentional. It contains the documented public aggregates and their derived snapshot.

```powershell
git init -b main
git status --short --ignored
git add -- .gitignore .gitattributes README.md assets docs data powerbi python sql
git diff --cached --stat
git diff --cached --name-status
git diff --cached -- README.md docs/reproduce.md .gitignore .gitattributes
```

Once you have approved the staged files, commit and push to the empty repository you selected. Replace the example remote with its actual address. Review the rendered README, assets and file downloads on GitHub before changing visibility.

```powershell
git commit -m "Present NHS A&E performance analytics portfolio"
git remote add origin https://github.com/OWNER/REPOSITORY.git
git push -u origin main
```

I kept the release preparation local. The checkpoint for existing files is `logs/NHS-before-github-preparation.zip`. The prior exporter is saved separately as `logs/06_export_ae_reporting_snapshot.before-github.py`. Both are excluded from Git.
