# Retail Analytics — Dashboard Design Specification

Implemented in the existing PBIP/PBIR project on 5 November 2026 (Asia/Jakarta).

## Design system

All three existing page IDs are reused. Canvas: **1920 × 1080**, Fit to Page. All visuals are native Power BI visuals. No web application or additional source tables are involved.

| Token | Hex | Usage |
|---|---|---|
| Header | #4B2E63 | Full-width header |
| Sidebar | #5A3E78 | Filter panel |
| Primary Purple | #8759BA | Main data series |
| Secondary Violet | #765B91 | Secondary series |
| Lavender | #B79AD6 | Department ranking and palette |
| Cream Canvas | #F7F1E8 | Page background |
| Ivory Cards | #FFFDF8 | KPIs and chart containers |
| Primary Text | #2F223A | Titles and values |
| Secondary Text | #75677B | Axis, labels and subtitles |
| Border | #E7DDD2 | Subtle 1 px borders, 4 px radius |
| Gold Highlight | #D8B277 | Holiday comparison series |

Segoe UI throughout. Header title 26 pt; subtitle 12 pt; KPI values 27 pt; KPI labels and sidebar controls 11 pt; chart titles 15 pt; axes and chart data labels 10 pt; insight text 12 pt. Shadows and accent strips are disabled. Lines are straight rather than smoothed. Chart units use K/M/B where appropriate. No currency symbol is inferred from incomplete model metadata.

`Retail_Purple_Cream.json` is the importable theme. Its identical embedded copy is registered in `Project Data engineer.Report/StaticResources/RegisteredResources/`; the report references this resource automatically.

## Layout

Coordinates are actual canvas pixels, not scaled screenshot coordinates.

| Region | X | Y | Width | Height |
|---|---:|---:|---:|---:|
| Header | 0 | 0 | 1920 | 108 |
| Sidebar | 24 | 132 | 320 | 924 |
| KPI 1 | 368 | 132 | 370 | 116 |
| KPI 2 | 754 | 132 | 370 | 116 |
| KPI 3 | 1140 | 132 | 370 | 116 |
| KPI 4 | 1526 | 132 | 370 | 116 |

Slicers are 288 × 96 at X=40, Y=208/320/432/544/656. Headers and dropdown selectors have enough reserved height; sidebar text explains numeric months and Boolean holiday values. Native page tabs provide navigation. Sidebar navigation text is instructional text, not a simulated button.

### Sales Overview

Title: RETAIL SALES DASHBOARD

Subtitle: Sales Performance, Store Insights, and Economic Context

- Filters: Year, Month, Store, Store Type, Holiday.
- Existing four KPI measures and visual IDs preserved.
- Monthly Sales Trend: line, X=368, Y=264, W=976, H=384. `YearMonth` retains the existing model sort by `YearMonthSort`.
- Holiday vs Non-Holiday: clustered columns, X=1360, Y=264, W=536, H=384. Equal-weight average store-week sales; purple Non-Holiday, muted gold Holiday.
- Top 5 Stores: horizontal bars, X=368, Y=664, W=752, H=392. Actual DAX ordinal rank ≤5 and sales descending.
- Total Sales by Store Type: donut, X=1136, Y=664, W=760, H=392.

The prior department ranking visual is moved with its existing ID to Page 2. Existing header, sidebar, slicer containers, KPI, trend and store-ranking IDs are reused. The old Page 1 department filter becomes Store Type to match the new brief. These changes adapt the earlier layout to the newly requested composition.

### Store & Department Performance

Title: STORE & DEPARTMENT PERFORMANCE

Subtitle: Store Rankings, Department Contributions & Operational Insights

- Filters: Year, Month, Store, Store Type, Department.
- KPIs: Active Stores; Average Store Sales; Highest Performing Store (ID); Total Departments.
- Row 1, Y=264/H=292: Top 10 Stores (752 wide) and Top 10 Departments (760 wide).
- Row 2, Y=572/H=248: Store Size vs Total Sales and Total Sales by Store Type.
- Bottom, X=368/Y=836/W=1528/H=220: Detailed Store Performance native table. One row per store, sorted by Total Sales; remaining store rows are available by table scrolling.
- Table: Store ID, Store Type, Store Size, Total Sales, Average Weekly Sales / Dept, Sales Rank. Store Type and Size are scalar measures, avoiding extra grouping rows or summed size.
- Scatter: `Category=store`, `Series=store_type`, `X=[Store Size]`, `Y=[Total Sales]`. One point per store; category, series and axes provide Store/Type/Size/Sales tooltips. Additional tooltip fields include type and average weekly sales.

### Economic & Holiday Insights

Title: ECONOMIC & HOLIDAY INSIGHTS

Subtitle: Economic Conditions, Seasonality & Sales Relationships

- Filters: Year, Month, Store, Store Type, Holiday.
- KPIs: Average CPI, Average Fuel Price, Average Unemployment (%), Holiday Sales Difference (%).
- Row 1, Y=264/H=248: three separate 240-pixel-wide yearly charts for CPI, Fuel Price and Unemployment at X=368/624/880; Holiday vs Non-Holiday at X=1136/W=760. Separate axes avoid mixing incompatible scales.
- Row 2, Y=528/H=280: Temperature vs Sales at X=368/W=752; Monthly Sales Seasonality at X=1136/W=760.
- Bottom, Y=824/H=232: native correlation table and a panel with three dynamic measure-driven insights.
- Temperature scatter: `Category=date`, `Series=store`, X=Average Temperature, Y=Average Store Weekly Sales; legend hidden. The composite grouping is Store–Date. Native Power BI point reduction/sampling may apply to the 6,435-point full selection; the correlation measures use all qualifying observations.
- Seasonality: numeric month 1–12, sorted ascending. Equal weight per available selected year, based on each year's average store-week sales for that month. Unavailable year–month combinations are excluded.
- Correlation table: Temperature r, Fuel Price r, CPI r, Unemployment r. Pearson correlation uses pairwise-complete Store–Date observations and total store-week sales.
- Key insights are computed at runtime: leading store and share, holiday average difference, observation count/date range. They are not hardcoded to the baseline results.

## Interaction behavior

Slicers use native field bindings and default filtering. Existing valid report interaction settings are retained; no `NoFilter` overrides were introduced. Rankings respond to the selected period, stores, type and department. Other chart selections use native Power BI interaction behavior.

The holiday comparison and its KPI/insight intentionally override only `isholiday`, so both classes remain available for comparison even when the Holiday slicer selects one class. This exception is stated on the chart and in the insight. Other filters remain in effect. Other visuals respond to the Holiday slicer normally.

Navigation uses the three existing page tabs. No buttons requiring unverified action configuration were added.

## Visual inventory and exact paths

Each entry below is `Project Data engineer.Report/definition/pages/<page ID>/visuals/<visual ID>/visual.json`. Background shapes and their contained text/slicers overlap intentionally; data visuals do not overlap each other.

### Sales Overview — `b758050fc4d0163a63b4`

| Visual | Type | ID | X, Y, W, H |
|---|---|---|---|
| header | shape | `11af53abe65a253da9e5` | 0, 0, 1920, 108 |
| title | textbox | `f30c7d32e9741927001e` | 32, 12, 1740, 48 |
| subtitle | textbox | `0e6a5902d412eb6cc909` | 34, 65, 1680, 30 |
| sidebar | shape | `ca7d6a910c6b0d40d5ae` | 24, 132, 320, 924 |
| filter_title | textbox | `08a96816e6d0e3667370` | 48, 156, 272, 36 |
| filter_0 | slicer | `8506ef8e36103b946170` | 40, 208, 288, 96 |
| filter_1 | slicer | `648ce6469b29970cba36` | 40, 320, 288, 96 |
| filter_2 | slicer | `2e98056c9377dc6e5611` | 40, 432, 288, 96 |
| filter_3 | slicer | `545dbf2d0b069860d225` | 40, 544, 288, 96 |
| filter_4 | slicer | `10a9457854c410e1201d` | 40, 656, 288, 96 |
| filter_help | textbox | `77f32581603e6d4e84ad` | 48, 824, 272, 148 |
| navigation_help | textbox | `877897b509aa1aaa998e` | 48, 988, 272, 52 |
| kpi_0 | cardVisual | `87b6a5fe8a2946941403` | 368, 132, 370, 116 |
| kpi_1 | cardVisual | `ea45aa835005de624157` | 754, 132, 370, 116 |
| kpi_2 | cardVisual | `e7420387a43e549045ed` | 1140, 132, 370, 116 |
| kpi_3 | cardVisual | `7f8c67340696b0e59116` | 1526, 132, 370, 116 |
| monthly_trend | lineChart | `5cc24cd9d9c061740a73` | 368, 264, 976, 384 |
| holiday_comparison | clusteredColumnChart | `cb1467f0fc1fea2596d8` | 1360, 264, 536, 384 |
| top_stores | clusteredBarChart | `ab190c40d36e48fd9081` | 368, 664, 752, 392 |
| store_type_donut | donutChart | `d94e2f3a7b848c978f98` | 1136, 664, 760, 392 |

### Store & Department Performance — `2dde3b493c2a9d455454`

| Visual | Type | ID | X, Y, W, H |
|---|---|---|---|
| header | shape | `119dc022b5ecc9ca54de` | 0, 0, 1920, 108 |
| title | textbox | `067de27175a0d7892674` | 32, 12, 1740, 48 |
| subtitle | textbox | `71a594f082602b116a7e` | 34, 65, 1680, 30 |
| sidebar | shape | `d8a76efc63677f722986` | 24, 132, 320, 924 |
| filter_title | textbox | `a905ec2ca223b8a7211d` | 48, 156, 272, 36 |
| filter_0 | slicer | `d033ea6ae0b727ab25b2` | 40, 208, 288, 96 |
| filter_1 | slicer | `8600f8b3d855cdc4d8ba` | 40, 320, 288, 96 |
| filter_2 | slicer | `1ea85aeaeef119c3eba8` | 40, 432, 288, 96 |
| filter_3 | slicer | `f7e8d89d18ee3052b080` | 40, 544, 288, 96 |
| filter_4 | slicer | `493452666cfb292f5f96` | 40, 656, 288, 96 |
| filter_help | textbox | `aec16b57e45439810d29` | 48, 824, 272, 148 |
| navigation_help | textbox | `c5618d90caeda78bb600` | 48, 988, 272, 52 |
| kpi_0 | cardVisual | `80a9589bc97e08c52887` | 368, 132, 370, 116 |
| kpi_1 | cardVisual | `04db025179bfdebb0233` | 754, 132, 370, 116 |
| kpi_2 | cardVisual | `aabf170e38125cbb27e2` | 1140, 132, 370, 116 |
| kpi_3 | cardVisual | `e78211ca626f15a24223` | 1526, 132, 370, 116 |
| top_stores | clusteredBarChart | `12d4c519858fbe16825c` | 368, 264, 752, 292 |
| department_ranking | clusteredBarChart | `bc290d51e47f49ae8192` | 1136, 264, 760, 292 |
| store_size_scatter | scatterChart | `8def24c3411c63a51425` | 368, 572, 752, 248 |
| store_type_columns | clusteredColumnChart | `862bcdfd3133360b9d1e` | 1136, 572, 760, 248 |
| store_detail | tableEx | `58afc9ccfe8c7a2014d7` | 368, 836, 1528, 220 |

### Economic & Holiday Insights — `dda9ea0f3b0048912402`

| Visual | Type | ID | X, Y, W, H |
|---|---|---|---|
| header | shape | `15a26f5b294820bf826c` | 0, 0, 1920, 108 |
| title | textbox | `abf43761dcb6409c879c` | 32, 12, 1740, 48 |
| subtitle | textbox | `bdf8600b1f7efe65f7c8` | 34, 65, 1680, 30 |
| sidebar | shape | `5622c1150e99e042d56f` | 24, 132, 320, 924 |
| filter_title | textbox | `7f40fe9b6f1925371706` | 48, 156, 272, 36 |
| filter_0 | slicer | `2234cce53df0b00c86af` | 40, 208, 288, 96 |
| filter_1 | slicer | `cbb34c1aa9dc86c19a8f` | 40, 320, 288, 96 |
| filter_2 | slicer | `1b9a8cda98d93e89aa51` | 40, 432, 288, 96 |
| filter_3 | slicer | `402b9d9afaeda36c4e4b` | 40, 544, 288, 96 |
| filter_4 | slicer | `5c5c6608560716cfadae` | 40, 656, 288, 96 |
| filter_help | textbox | `b64b92c0f0b1ff8807f9` | 48, 824, 272, 148 |
| navigation_help | textbox | `c60a9577d08b57c664d4` | 48, 988, 272, 52 |
| kpi_0 | cardVisual | `f95bcd42d963a1f5eca0` | 368, 132, 370, 116 |
| kpi_1 | cardVisual | `0f62a00bdca0b33b9288` | 754, 132, 370, 116 |
| kpi_2 | cardVisual | `626d415649bd5af8e1f0` | 1140, 132, 370, 116 |
| kpi_3 | cardVisual | `e85308f9a7987ccfea06` | 1526, 132, 370, 116 |
| economy_0 | lineChart | `9d79b92d5632f0d2e9a7` | 368, 264, 240, 248 |
| economy_1 | lineChart | `2ab0729f94a32d6ee54c` | 624, 264, 240, 248 |
| economy_2 | lineChart | `73ba55077439a5e24690` | 880, 264, 240, 248 |
| holiday_comparison | clusteredColumnChart | `06f4f079935985c110a5` | 1136, 264, 760, 248 |
| temperature_scatter | scatterChart | `78a485407945b4a9a44e` | 368, 528, 752, 280 |
| seasonality | lineChart | `0e2e6c436dc9984298d2` | 1136, 528, 760, 280 |
| correlations | tableEx | `f4d0684e77d5d138a4bd` | 368, 824, 752, 232 |
| insight_panel | shape | `56e00d2183579dffe148` | 1136, 824, 760, 232 |
| insight_heading | textbox | `dce90ee630743d68f07a` | 1152, 836, 720, 32 |
| insight_0 | cardVisual | `ed6b2995926d1b9c42bd` | 1152, 872, 728, 56 |
| insight_1 | cardVisual | `4a674cdd163e00283cbe` | 1152, 930, 728, 56 |
| insight_2 | cardVisual | `b359237365f8b83b281d` | 1152, 988, 728, 56 |

