# Power BI Retail Analytics — Implementation and Verification

Updated 5 November 2026 (Asia/Jakarta). Work is in the original `Project Data engineer.pbip` project.

## Completed

All three existing pages are implemented with the Purple & Cream theme, 15 dropdown slicers, 12 primary KPI cards, and the requested analytical visuals. The economic yearly comparison uses three independent line charts with separate scales. The correlation summary is a native table, and three additional text-valued cards provide dynamic business insights. There are 69 native visual containers in total (including header/sidebar shapes and explanatory text): 20 / 21 / 28 per page.

Only 23 new measures were added to the existing `public retail_eda` table, in the `Retail Analytics` display folder. No new columns or tables were introduced. All original DAX expressions, calculated columns, relationships, partition/M expression and PostgreSQL connection settings are unchanged. Removing exactly the new measure block recreates the original table file byte for byte (SHA-256 verified). ETL file hashes also remain unchanged. `.env` was not read or modified.

The existing `Non-Holiday Avg Sales` measure has an empty expression, and the old `Holiday Difference %` depends on it. Those legacy measures were preserved and are not used by the new holiday analysis. New measures have distinct names and verified calculations.

## Changed files

- `Project Data engineer.Report/definition/report.json`: registered custom theme; retained base theme/settings.
- `definition/pages/b758050fc4d0163a63b4/page.json`: Sales Overview background/layout metadata.
- `definition/pages/2dde3b493c2a9d455454/page.json`: renamed Page 2 to Store & Department Performance.
- `definition/pages/dda9ea0f3b0048912402/page.json`: renamed Page 3 to Economic & Holiday Insights.
- All 69 `visual.json` paths are listed individually in `DASHBOARD_DESIGN_SPEC.md`. The existing department ranking `bc290d51e47f49ae8192` moved from Page 1 to Page 2, retaining its ID. Other existing Page 1 IDs were retained.
- `Project Data engineer.Report/StaticResources/RegisteredResources/Retail_Purple_Cream.json`: embedded theme.
- `Retail_Purple_Cream.json`: identical theme for manual import if needed.
- `Project Data engineer.SemanticModel/definition/tables/public retail_eda.tmdl`: additive measure block only.
- `DASHBOARD_DESIGN_SPEC.md` and this file.

The `.pbip` file, `.pbir` data connection reference, `pages.json` page IDs/order, base theme, and all other SemanticModel files remain unchanged. No backup folders, extra projects, ETL changes, source imports or GitHub pushes were created.

## Metric definitions

| Metric | Definition / grain |
|---|---|
| Total Sales | Existing sum of `weekly_sales` |
| Average Weekly Sales | Existing arithmetic mean of the transaction table's Store–Department–Date weekly sales rows; retained for Page 1 and clearly named in Page 2's table |
| Active Stores / Total Departments | Existing distinct counts in the current context |
| Average Store Sales | Total Sales / distinct Store count |
| Highest Performing Store | Store ID with largest sales; smallest ID breaks ties |
| Store Size | MAX for one selected store; blank across multiple stores; never SUM of repeated rows |
| Store / Department rank | Sales descending; ID ascending breaks ties; selection-aware ordinal rank gives exactly up to N eligible categories |
| Average economic indicator | One observation per Store–Date, then equal-weight mean; SELECTEDVALUE excludes conflicting values and blanks |
| Average Store Weekly Sales | Sum selected departments for each Store–Date, then equal-weight average of those store-week totals |
| Holiday difference | `(holiday store-week mean − non-holiday store-week mean) / non-holiday store-week mean`; overrides only Holiday; blank if either group is missing or denominator is zero |
| Monthly seasonality | Average of the per-year store-week means for the calendar month; selected available years have equal weight |
| Correlation | Pearson r between an indicator and total store-week sales, pairwise-complete Store–Date records; minimum 3 pairs and nonzero variance |

Unemployment is stored in percentage-point units (approximately 8, not 0.08), so the KPI shows `8.00` with `(%)` in its label. Correlations are pooled descriptive relationships, not causal estimates or models adjusted for store effects/seasonality. Fuel-price currency and temperature units are not inferred from the field names.

The holiday baseline ignores only Holiday by design; both columns and the KPI still follow period, Store and Store Type filters. The other Page 3 visuals retain the full slicer context. The chart subtitle and insight make this exception visible.

## Validation completed

1. All modified JSON parses successfully.
2. `report.json`, all `page.json`, page metadata and nested PBIR query/filter/format structures were checked against downloaded official Microsoft schemas.
3. Existing visual declarations use `visualContainer/2.14.0`, whose official endpoint returned HTTP 404 during verification. The declarations were preserved. Structural compatibility was checked against the published `2.7.0` schema and its nested dependencies, changing only the `$schema` string in an in-memory validation copy. This is **not** a claim of exact-version 2.14.0 validation.
4. Theme and per-visual formatting properties passed Microsoft's `reportThemeSchema-2.159.json`; no unsupported property names were found by that check.
5. All 69 visual IDs are unique; visual folders and names match; all bindings resolve to actual columns/measures; charts/slicers use native visual types. All data visuals are inside 1920 × 1080 and have no overlaps with each other.
6. Microsoft's locally installed `TmdlSerializer.DeserializeModelFromFolder` successfully parsed the complete SemanticModel: 3 existing tables, 16 retail columns and 31 retail measures (8 original + 23 added).
7. New DAX expressions were executed as query-scoped measures against the **existing local Power BI Desktop model** using read-only ADOMD queries. The open Desktop model was not changed. No sign-in, Power BI Service or publishing was used.
8. Rank tests: 45 distinct store ranks; Top 10 store/department rank filters matched independently ordered DAX TOPN results. A 2011 filter plus Stores 1,2,3 returned 3 ranks from 1 through 3.
9. Context/edge tests passed: economic means respond to year filtering; Store Size matches the single-store raw MAX; one-point and zero-variance correlations return blank; no-data holiday/correlation results are blank; the holiday comparison is stable under a Holiday-only selection as intended.
10. Actual model data had 6,435 distinct Store–Date observations. CPI, fuel price, unemployment and temperature each had zero within-observation value conflicts; store sizes had zero within-store conflicts.
11. Independent NumPy calculations on those same locally queried Store–Date observations reproduced economic means, all four correlation coefficients and holiday difference to within 1e-10.

### Unfiltered baseline from the live local model

These are verification results, **not hardcoded visual values**. They can change after refresh or filtering.

| Check | Value |
|---|---:|
| Source sales rows | 421,570 |
| Unique store-week observations | 6,435 |
| Holiday / non-holiday observations | 450 / 5,985 |
| Data coverage | February 2010 – October 2012 |
| Total Sales | 6,737,218,987.11 |
| Average Store Sales | 149,715,977.49 |
| Highest Performing Store | 20 |
| Average Store Weekly Sales | 1,046,964.88 |
| Average CPI | 171.578394 |
| Average Fuel Price | 3.358607 |
| Average Unemployment | 7.999151 |
| Holiday store-week average | 1,122,887.89 |
| Non-holiday store-week average | 1,041,256.38 |
| Holiday Sales Difference | +7.839713% |
| Temperature / Sales r | -0.063810 |
| Fuel Price / Sales r | +0.009464 |
| CPI / Sales r | -0.072634 |
| Unemployment / Sales r | -0.106176 |

## Remaining Desktop verification

No requested visualization or calculation is intentionally left unimplemented. **Rendering, actual click interactions, theme appearance, tooltip layout, and text clipping have not been visually verified.** The computer-use helper could not connect to its native pipe (`os error 2`), including recovery attempts. Reading the model successfully does not prove that report visuals render.

1. Close the old open report session before reopening the edited project. Avoid saving that stale session over the changed PBIR files. Resolve any personal unsaved changes first.
2. In Power BI Desktop, open `C:\Gawe\Retail_Project\Project Data engineer.pbip`. Keep the adjacent `.Report` and `.SemanticModel` folders in place. Use a Desktop version supporting this existing PBIP/PBIR project. No Microsoft account sign-in is needed for local editing/viewing.
3. Let the local cached model load. A refresh is not required just to inspect the existing imported data. If refreshing, use the existing local PostgreSQL connection; no connection settings were changed here.
4. Select each of the three page tabs. Use **View → Page view → Fit to page**. Verify all visual titles, labels, dropdown selectors and KPI values are visible.
5. Check the three page names and title/subtitle text against `DASHBOARD_DESIGN_SPEC.md`. The theme should load automatically. If a theme is not displayed, use **View → Themes → Browse for themes** and select the root `Retail_Purple_Cream.json`.
6. Test Year=2011, choose a Month, Store Type and Store. Confirm relevant visuals recalculate. On Page 2, also test Department. Clear selections after each test.
7. Confirm Page 1 has at most 5 store bars; Page 2 has at most 10 store bars and 10 department bars. Inspect the Filters pane to confirm `Store Sales Rank <= 5/10` or `Department Sales Rank <= 10`. Values must be sorted descending.
8. Confirm the Monthly Sales Trend proceeds chronologically across December/January. Seasonality should run from month 1 through 12, not by alphabetic label.
9. Confirm Store Size scatter shows one point per store; hover to inspect Store, Type, Size, Sales. Detailed table should have one row per store, with a vertical scrollbar for additional rows. Use Focus mode for a larger table when needed.
10. Confirm the Page 3 temperature scatter uses Store + Date grouping, with one point per store-week before native sampling. Hover should show Store, Week ending, Temperature and Sales. The hidden legend is intentional.
11. Confirm the holiday columns are labelled Non-Holiday/Holiday and colored purple/gold. Selecting Holiday should still leave both comparison averages and their difference visible; other visuals should filter normally. This baseline behavior is deliberate and labelled.
12. Confirm the insight cards recalculate when changing year/store/type and that the four correlations remain within [-1,1] or blank. These insight texts are measure results, not static snapshot claims.
13. Check chart cross-highlighting/filtering and native page-tab navigation. If a particular cross-highlight is unsuitable for a presentation, use **Format → Edit interactions** in Desktop to choose Filter/Highlight/None for that pair; no custom overrides were assumed here.
14. After these visual checks, save the reopened project. No publishing or Power BI Service is required.

## Exact new DAX

All definitions below are implemented in `public retail_eda.tmdl`, in display folder `Retail Analytics`. No existing calculation is replaced.

### Average Store Sales

Total sales divided by distinct stores in the current selection.

Format string: `#,0.00`.

```dax
Average Store Sales =
DIVIDE([Total Sales], [Total Stores])
```

### Store Size

Single-store size; repeated department records are not summed.

Format string: `#,0`.

```dax
Store Size =
IF(HASONEVALUE('public retail_eda'[store]), MAX('public retail_eda'[store_size]))
```

### Store Type Label

Type of the store in the current table row.

```dax
Store Type Label =
SELECTEDVALUE('public retail_eda'[store_type])
```

### Highest Performing Store

Store ID with greatest sales; ties resolved by smallest Store ID.

Format string: `0`.

```dax
Highest Performing Store =
VAR Candidates = FILTER(ADDCOLUMNS(VALUES('public retail_eda'[store]), "__Sales", [Total Sales]), NOT ISBLANK([__Sales]))
VAR Winner = TOPN(1, Candidates, [__Sales], DESC, 'public retail_eda'[store], ASC)
RETURN MINX(Winner, 'public retail_eda'[store])
```

### Store Sales Rank

Sales-descending ordinal rank among selected store values; ID ascending breaks ties, so Top N contains at most N items.

Format string: `0`.

```dax
Store Sales Rank =
VAR CurrentID = SELECTEDVALUE('public retail_eda'[store])
VAR CurrentSales = [Total Sales]
VAR Candidates = FILTER(ADDCOLUMNS(ALLSELECTED('public retail_eda'[store]), "__Sales", CALCULATE([Total Sales])), NOT ISBLANK([__Sales]))
RETURN
IF(NOT ISBLANK(CurrentID) && NOT ISBLANK(CurrentSales),
    1 + COUNTROWS(FILTER(Candidates,
        [__Sales] > CurrentSales || ([__Sales] = CurrentSales && 'public retail_eda'[store] < CurrentID))))
```

### Department Sales Rank

Sales-descending ordinal rank among selected dept values; ID ascending breaks ties, so Top N contains at most N items.

Format string: `0`.

```dax
Department Sales Rank =
VAR CurrentID = SELECTEDVALUE('public retail_eda'[dept])
VAR CurrentSales = [Total Sales]
VAR Candidates = FILTER(ADDCOLUMNS(ALLSELECTED('public retail_eda'[dept]), "__Sales", CALCULATE([Total Sales])), NOT ISBLANK([__Sales]))
RETURN
IF(NOT ISBLANK(CurrentID) && NOT ISBLANK(CurrentSales),
    1 + COUNTROWS(FILTER(Candidates,
        [__Sales] > CurrentSales || ([__Sales] = CurrentSales && 'public retail_eda'[dept] < CurrentID))))
```

### Average Store Weekly Sales

Equal-weight average of total department sales for each unique Store-Date observation; one date represents one sales week.

Format string: `#,0.00`.

```dax
Average Store Weekly Sales =
AVERAGEX(SUMMARIZE('public retail_eda', 'public retail_eda'[store], 'public retail_eda'[date]), CALCULATE([Total Sales]))
```

### Store-Week Observations

Number of distinct Store-Date observations in the current filter context.

Format string: `#,0`.

```dax
Store-Week Observations =
COUNTROWS(SUMMARIZE('public retail_eda', 'public retail_eda'[store], 'public retail_eda'[date]))
```

### Average CPI

Equal-weight mean over unique Store-Date observations. Missing or conflicting indicator values are excluded by SELECTEDVALUE, not silently summed.

Format string: `0.00`.

```dax
Average CPI =
AVERAGEX(SUMMARIZE('public retail_eda', 'public retail_eda'[store], 'public retail_eda'[date]), CALCULATE(SELECTEDVALUE('public retail_eda'[cpi])))
```

### Average Fuel Price

Equal-weight mean over unique Store-Date observations. Missing or conflicting indicator values are excluded by SELECTEDVALUE, not silently summed.

Format string: `0.00`.

```dax
Average Fuel Price =
AVERAGEX(SUMMARIZE('public retail_eda', 'public retail_eda'[store], 'public retail_eda'[date]), CALCULATE(SELECTEDVALUE('public retail_eda'[fuel_price])))
```

### Average Unemployment

Equal-weight mean over unique Store-Date observations. Missing or conflicting indicator values are excluded by SELECTEDVALUE, not silently summed.

Format string: `0.00`.

```dax
Average Unemployment =
AVERAGEX(SUMMARIZE('public retail_eda', 'public retail_eda'[store], 'public retail_eda'[date]), CALCULATE(SELECTEDVALUE('public retail_eda'[unemployment])))
```

### Average Temperature

Equal-weight mean over unique Store-Date observations. Missing or conflicting indicator values are excluded by SELECTEDVALUE, not silently summed.

Format string: `0.00`.

```dax
Average Temperature =
AVERAGEX(SUMMARIZE('public retail_eda', 'public retail_eda'[store], 'public retail_eda'[date]), CALCULATE(SELECTEDVALUE('public retail_eda'[temperature])))
```

### Holiday Store Weekly Sales

Average store-week sales for this holiday class; intentionally overrides only the Holiday slicer for a two-class baseline comparison.

Format string: `#,0.00`.

```dax
Holiday Store Weekly Sales =
CALCULATE([Average Store Weekly Sales], REMOVEFILTERS('public retail_eda'[isholiday]), 'public retail_eda'[isholiday] = TRUE())
```

### Non-Holiday Store Weekly Sales

Average store-week sales for this holiday class; intentionally overrides only the Holiday slicer for a two-class baseline comparison.

Format string: `#,0.00`.

```dax
Non-Holiday Store Weekly Sales =
CALCULATE([Average Store Weekly Sales], REMOVEFILTERS('public retail_eda'[isholiday]), 'public retail_eda'[isholiday] = FALSE())
```

### Holiday Store Weekly Difference %

Relative difference between average holiday and non-holiday store-week sales; denominator is the non-holiday average. Other filters remain active; blank if either class is missing or denominator is zero.

Format string: `0.0%;-0.0%;0.0%`.

```dax
Holiday Store Weekly Difference % =
VAR HolidayAverage = [Holiday Store Weekly Sales]
VAR NonHolidayAverage = [Non-Holiday Store Weekly Sales]
RETURN IF(NOT ISBLANK(HolidayAverage) && NOT ISBLANK(NonHolidayAverage),
    DIVIDE(HolidayAverage - NonHolidayAverage, NonHolidayAverage))
```

### Seasonal Average Store Weekly Sales

For each calendar month, averages the store-week mean for each available selected year with equal year weight.

Format string: `#,0.00`.

```dax
Seasonal Average Store Weekly Sales =
AVERAGEX(VALUES('public retail_eda'[year]), [Average Store Weekly Sales])
```

### Temperature Sales Correlation

Pearson r between indicator and total store-week sales over pairwise complete unique Store-Date observations. Blank for fewer than 3 pairs or zero variance; association is not causation.

Format string: `0.000;-0.000;0.000`.

```dax
Temperature Sales Correlation =
VAR Observations = FILTER(
    ADDCOLUMNS(SUMMARIZE('public retail_eda', 'public retail_eda'[store], 'public retail_eda'[date]),
        "__X", CALCULATE(SELECTEDVALUE('public retail_eda'[temperature])),
        "__Y", CALCULATE([Total Sales])),
    NOT ISBLANK([__X]) && NOT ISBLANK([__Y]))
VAR N = COUNTROWS(Observations)
VAR MeanX = AVERAGEX(Observations, [__X])
VAR MeanY = AVERAGEX(Observations, [__Y])
VAR Numerator = SUMX(Observations, ([__X] - MeanX) * ([__Y] - MeanY))
VAR Denominator = SQRT(SUMX(Observations, POWER([__X] - MeanX, 2)) * SUMX(Observations, POWER([__Y] - MeanY, 2)))
RETURN IF(N >= 3 && Denominator > 0, DIVIDE(Numerator, Denominator))
```

### Fuel Price Sales Correlation

Pearson r between indicator and total store-week sales over pairwise complete unique Store-Date observations. Blank for fewer than 3 pairs or zero variance; association is not causation.

Format string: `0.000;-0.000;0.000`.

```dax
Fuel Price Sales Correlation =
VAR Observations = FILTER(
    ADDCOLUMNS(SUMMARIZE('public retail_eda', 'public retail_eda'[store], 'public retail_eda'[date]),
        "__X", CALCULATE(SELECTEDVALUE('public retail_eda'[fuel_price])),
        "__Y", CALCULATE([Total Sales])),
    NOT ISBLANK([__X]) && NOT ISBLANK([__Y]))
VAR N = COUNTROWS(Observations)
VAR MeanX = AVERAGEX(Observations, [__X])
VAR MeanY = AVERAGEX(Observations, [__Y])
VAR Numerator = SUMX(Observations, ([__X] - MeanX) * ([__Y] - MeanY))
VAR Denominator = SQRT(SUMX(Observations, POWER([__X] - MeanX, 2)) * SUMX(Observations, POWER([__Y] - MeanY, 2)))
RETURN IF(N >= 3 && Denominator > 0, DIVIDE(Numerator, Denominator))
```

### CPI Sales Correlation

Pearson r between indicator and total store-week sales over pairwise complete unique Store-Date observations. Blank for fewer than 3 pairs or zero variance; association is not causation.

Format string: `0.000;-0.000;0.000`.

```dax
CPI Sales Correlation =
VAR Observations = FILTER(
    ADDCOLUMNS(SUMMARIZE('public retail_eda', 'public retail_eda'[store], 'public retail_eda'[date]),
        "__X", CALCULATE(SELECTEDVALUE('public retail_eda'[cpi])),
        "__Y", CALCULATE([Total Sales])),
    NOT ISBLANK([__X]) && NOT ISBLANK([__Y]))
VAR N = COUNTROWS(Observations)
VAR MeanX = AVERAGEX(Observations, [__X])
VAR MeanY = AVERAGEX(Observations, [__Y])
VAR Numerator = SUMX(Observations, ([__X] - MeanX) * ([__Y] - MeanY))
VAR Denominator = SQRT(SUMX(Observations, POWER([__X] - MeanX, 2)) * SUMX(Observations, POWER([__Y] - MeanY, 2)))
RETURN IF(N >= 3 && Denominator > 0, DIVIDE(Numerator, Denominator))
```

### Unemployment Sales Correlation

Pearson r between indicator and total store-week sales over pairwise complete unique Store-Date observations. Blank for fewer than 3 pairs or zero variance; association is not causation.

Format string: `0.000;-0.000;0.000`.

```dax
Unemployment Sales Correlation =
VAR Observations = FILTER(
    ADDCOLUMNS(SUMMARIZE('public retail_eda', 'public retail_eda'[store], 'public retail_eda'[date]),
        "__X", CALCULATE(SELECTEDVALUE('public retail_eda'[unemployment])),
        "__Y", CALCULATE([Total Sales])),
    NOT ISBLANK([__X]) && NOT ISBLANK([__Y]))
VAR N = COUNTROWS(Observations)
VAR MeanX = AVERAGEX(Observations, [__X])
VAR MeanY = AVERAGEX(Observations, [__Y])
VAR Numerator = SUMX(Observations, ([__X] - MeanX) * ([__Y] - MeanY))
VAR Denominator = SQRT(SUMX(Observations, POWER([__X] - MeanX, 2)) * SUMX(Observations, POWER([__Y] - MeanY, 2)))
RETURN IF(N >= 3 && Denominator > 0, DIVIDE(Numerator, Denominator))
```

### Insight Leading Store

Dynamic observation recalculated for the selected stores and period.

```dax
Insight Leading Store =
VAR Winner = [Highest Performing Store]
VAR WinnerSales = CALCULATE([Total Sales], KEEPFILTERS('public retail_eda'[store] = Winner))
RETURN IF(ISBLANK(Winner), "No store sales in the current selection.",
    "Store " & FORMAT(Winner, "0") & " leads with " & FORMAT(DIVIDE(WinnerSales,1000000), "0.0") & "M in sales (" & FORMAT(DIVIDE(WinnerSales,[Total Sales]), "0.0%") & " of selected sales).")
```

### Insight Holiday Comparison

Dynamic comparison using equal-weight Store-Date averages; no causal claim.

```dax
Insight Holiday Comparison =
VAR Difference = [Holiday Store Weekly Difference %]
RETURN IF(ISBLANK(Difference), "Holiday comparison unavailable: both classes and a nonzero baseline are required.",
    "Holiday store-week sales are " & FORMAT(ABS(Difference), "0.0%") & IF(Difference >= 0, " higher", " lower") & " than non-holiday weeks; Holiday filter excluded from this comparison.")
```

### Insight Observation Scope

Dynamic observation count and date coverage for the current context.

```dax
Insight Observation Scope =
VAR N = [Store-Week Observations]
RETURN IF(N = 0, "No store-week observations in the current selection.",
    FORMAT(N, "#,0") & " store-week observations from " & FORMAT(MIN('public retail_eda'[date]), "MMM yyyy") & " to " & FORMAT(MAX('public retail_eda'[date]), "MMM yyyy") & ". Correlation describes association, not causation.")
```

## Microsoft references used for verification

- [PBIR visual-container schema 2.7.0](https://developer.microsoft.com/json-schemas/fabric/item/report/definition/visualContainer/2.7.0/schema.json): structural validation fallback while preserving the project's existing 2.14.0 declaration.
- [Report theme schema 2.159](https://github.com/microsoft/powerbi-desktop-samples/blob/main/Report%20Theme%20JSON%20Schema/reportThemeSchema-2.159.json): theme and formatting property validation.
- [Native slicer authoring](https://github.com/microsoft/skills-for-fabric/blob/main/skills/powerbi-report-cli/references/authoring/slicers.md): dropdown binding and sizing reference.
- [Native Cartesian visual roles](https://github.com/microsoft/skills-for-fabric/blob/main/skills/powerbi-report-cli/references/authoring/cartesian.md): Category/Series/X/Y grouping and measure-series colors.
- [SUMMARIZE](https://learn.microsoft.com/en-us/dax/summarize-function-dax), [AVERAGEX](https://learn.microsoft.com/en-us/dax/averagex-function-dax), [ALLSELECTED](https://learn.microsoft.com/en-us/dax/allselected-function-dax), and [TOPN](https://learn.microsoft.com/en-us/dax/topn-function-dax): calculation semantics. All new expressions were additionally evaluated against the actual local model.
