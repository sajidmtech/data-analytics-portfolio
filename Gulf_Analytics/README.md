# Gulf Workforce Nationalization Analytics
### Saudization & Emiratization Compliance Risk Analysis — Al Rashid Holdings (Fictional)

![Dashboard](dashboard.png)

## Business problem

Companies in Saudi Arabia and the UAE must meet national workforce quotas: Nitaqat in Saudi Arabia, Emiratization in the UAE. A company can look compliant overall while individual departments quietly miss their targets, and those hidden gaps are what trigger fines, visa restrictions and audits.

This project models a fictional holding company, **Al Rashid Holdings** (424 employees across both countries), to answer one question for leadership:

> **Where is our nationalization compliance risk hiding, and what does it take to fix it?**

## Key findings

1. **The company average hides two failing departments.** National representation is 24.1% company-wide, but **IT and Warehouse & Logistics sit at 7–10% in both countries**, below the 20% risk threshold. Every other department is at 28–40%.
2. **The gap is about 22 hires.** Bringing those two departments up to their own country's average takes **~22 national hires: ~11 in Saudi Arabia and ~11 in the UAE** (about 6 in IT and 5 in Warehouse & Logistics in each country).
3. **In the UAE, the same two departments underpay nationals.** Emiratis in IT earn ~12% less than expatriate colleagues (AED 10,124 vs 11,480/month) and ~13% less in Warehouse & Logistics (AED 5,023 vs 5,799). New national hires may not stay. In Saudi Arabia, nationals earn slightly more than expatriates in both departments. *(Small samples: 3–4 nationals per department.)*

## Recommendations

- **Prioritize national hiring in IT and Warehouse & Logistics** rather than company-wide targets; ~22 hires closes the gap.
- **Review UAE pay bands for Emiratis in IT and Warehouse & Logistics** before hiring, so the gap doesn't reopen through attrition.
- **Track compliance by department, not just company-wide**, using the dashboard's department view each quarter.

## Tools & stack

| Layer | Tool |
|---|---|
| Data generation | Python (synthetic 424-row dataset, 12 columns) |
| Database | MySQL 8.0 (via DataGrip) |
| Analysis | SQL: GROUP BY / CASE WHEN, window functions (`RANK() OVER`, `AVG() OVER (PARTITION BY)`), CTEs, correlated subqueries |
| Spreadsheet | Excel: formula-driven workbook (COUNTIFS, SUMIFS, AVERAGEIFS), conditional formatting, no hardcoded values |
| Dashboard | Power BI: DAX measures (`ALLEXCEPT`, `ALL`, `SUMX`, `VAR`/`RETURN`), KPI cards, country slicer, conditional-formatting bar chart, national vs. expat salary comparison |

## Files

| File | What it is |
|---|---|
| `gulf_analytics.sql` | All SQL queries, from basic exploration to the hires-needed calculation |
| `Al_Rashid_Nationalization_Analytics.xlsx` | Excel workbook: raw data, compliance summary, salary comparison, hiring trend |
| `al_rashid_power_bi.pbix` | Power BI dashboard (see screenshot above; GitHub can't preview .pbix files) |

## Methodology note

Company-level nationalization data is confidential (held by MHRSD/Qiwa in Saudi Arabia and MOHRE/NAFIS in the UAE), so this project uses a synthetic dataset built to reflect published program rules rather than any real company. "Hires needed" assumes each new national hire replaces an expatriate role, keeping department headcount constant.
