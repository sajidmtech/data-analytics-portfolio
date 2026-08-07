# Gulf Workforce Nationalization Analytics — Saudization & Emiratization Compliance

## Overview

Analysis of 424 employees across a fictional Gulf holding company (Al Rashid Holdings,
operating in Saudi Arabia and the UAE) to identify department-level nationalization compliance risk,
quantify the hiring gap against Saudization (Nitaqat) and Emiratization targets
and flag salary-driven retention risk among national employees.

## Tools Used
MySQL / DataGrip — data querying and analysis
Excel — summaries built with formulas, COUNTIFS, SUMIFS, AVERAGEIFS, conditional formatting
Power BI — single page dashboard with KPI cards, DAX measures, and charts

## Business Questions
Which departments are failing nationalization compliance targets, and by how much?
How many national hires would it take to bring an under-target department up to its country average?
Are national employees compensated fairly relative to expatriates in the same roles?

## Key Findings
IT and Warehouse & Logistics fall to 7–10% national representation in both Saudi Arabia and the UAE, well below the company's own 22–27% country averages and below the 20% risk threshold
Closing the gap requires an estimated 22 additional national hires company-wide (roughly 11 per country) which is a percentage point shortfall into an actionable headcount target
Company-wide compliance looks healthy at ~24.5% national representation, but that average masks two departments carrying nearly all of the risk. The same pattern in both countries independently
Salary comparison between nationals and expatriates in the same departments surfaces a secondary retention risk that could undercut hiring gains if left unaddressed.

## Key Skills Demonstrated
GROUP BY, CASE WHEN with multiple conditions, HAVING
Window functions — ROUND(), RANK(), AVG() OVER (PARTITION BY)
COUNTIFS, SUMIFS, AVERAGEIFS in Excel
Conditional formatting in Excel
DAX calculated columns and measures — ALLEXCEPT, ALL, AVERAGEX, SUMX, VAR/RETURN
Single page Power BI dashboard with KPI cards, slicers, donut and combo charts
