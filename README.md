# Route Performance Analysis

## Project Overview

This project analyzes shipment delivery performance to identify routes with higher delay rates, examine monthly performance changes, and investigate whether the available operational data helps explain shipment delays.

I used SQL Server to explore shipment data at route, monthly, and individual shipment levels, and Power BI to present the key findings.

The goal was not only to identify underperforming routes but also to understand the limitations of the available data before making operational recommendations.

## Business Problem

Delivery delays can affect transportation planning and operational efficiency. However, an overall delay rate does not reveal which routes need attention or whether performance issues are concentrated in specific months.

This analysis investigates route-level performance, monthly fluctuations, and potential patterns between delivery delays and operational factors.

## Business Questions

- Which routes have the highest shipment delay rates?
- How did delay rates change month by month?
- Were performance changes concentrated on specific routes and months?
- How did actual transit times and distances compare with planned values?
- Did the number of stops show a consistent pattern alongside shipment delays?
- What changed on selected routes, including R02, R08, and R11?
- Did the available shipment data help explain the observed delays?

## Dataset

The dataset contains 200 shipments across 12 routes, covering January through August.

Each row represents one shipment. The dataset includes shipment dates, route IDs, delivery status, delay hours, number of stops, planned and actual distances, planned and actual transit times, and other shipment and operational attributes.

## Key Performance Indicators

- **Total Shipments:** Total number of shipments analyzed.
- **Late Shipments:** Number of shipments marked as late.
- **Delay Rate:** Late shipments divided by total shipments.
- **Transit Variance (%):** Percentage difference between average actual and planned transit times.
- **Distance Variance (%):** Percentage difference between average actual and planned distances.

Delay rate was the primary KPI because it measures how frequently shipments were late. Transit and distance variance provided additional context for comparing actual performance with the original plan.

## SQL Analysis

The SQL analysis progresses from overall performance comparisons to more detailed investigations.

The queries are documented by business question and include:

1. Route-level delay rate comparisons.
2. Monthly delivery performance and transit and distance variance.
3. Route-level monthly comparisons.
4. Investigation of the number of stops and delay rates.
5. Shipment-level comparisons for selected routes and months.
6. Detailed reviews of R02, R08, R11, R07, and R12.

The SQL queries are available in [`sql/01_route_performance.sql`](sql/01_route_performance.sql).

## Key Findings

### 1. Overall Delivery Performance

The dataset contained 200 shipments, of which 43 were marked as late. The overall delay rate was **21.5%**.

### 2. Route-Level Differences

R02 had a delay rate of **36.36%**, while R11 had a delay rate of **31.82%**. These routes were reasonable starting points for further operational investigation.

### 3. Monthly Fluctuations

Monthly delay rates fluctuated throughout the period. February reached **33.33%**, while July reached **29.17%**. The rate dropped to **12.50%** in August.

The results did not show a continuous decline or a sustained worsening trend.

### 4. Investigating Potential Operational Factors

I compared delay patterns with the number of stops, transit time differences, and distance differences. I also examined selected shipments across different months.

The available data did not reveal a consistent pattern that explained why shipments were late.

This highlighted an important distinction: identifying where delays are more common is not the same as identifying their root causes.

## Recommendations

- Review R02 and R11 to determine whether their performance issues share operational characteristics.
- Monitor monthly delay rates alongside shipment counts.
- Collect additional information on traffic, road incidents, waiting times, inspections, weather, and customer delivery windows.
- Use additional operational data to test potential explanations rather than assuming that observed patterns establish causation.

## Power BI Dashboard

The dashboard summarizes shipment performance, compares delay rates across routes, and highlights monthly fluctuations.

![Route Performance Analysis Dashboard](screenshots/dashboard.png)

## Limitations

- The dataset covers only eight months.
- Shipment volumes vary across routes and months, which can make some delay rates less reliable.
- The dataset does not contain enough information to establish the root causes of delays.
- The analysis identifies patterns in the available data but does not prove cause and effect.

## Tools Used

- SQL Server
- SQL
- Power BI
- GitHub

## What I Learned

This project helped me practice translating a business problem into analytical questions, selecting relevant KPIs, comparing performance at different levels, and evaluating whether the available data supported a conclusion.

It also reinforced the importance of distinguishing between identifying a performance issue and explaining its cause.
