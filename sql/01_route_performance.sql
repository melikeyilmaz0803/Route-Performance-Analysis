
/*
============================================================
PROJECT: Route Performance Analysis
FILE: 01_route_performance.sql
TOOL: SQL Server

PROJECT OBJECTIVE:
Analyze shipment delays, compare route performance, identify
monthly changes, and investigate whether available operational
data helps explain observed delays.

GRAIN:
One row represents one shipment.

IMPORTANT:
High delay rates identify areas for investigation. They do
not, by themselves, establish the causes of delays.
============================================================
*/


/*
============================================================
QUESTION 1:
Which routes have the highest shipment delay rates?

BUSINESS PURPOSE:
Compare route-level performance and identify routes that
may require a closer operational review.
============================================================
*/

SELECT
    route_id,
    COUNT(*) AS total_shipments,
    SUM(
        CASE
            WHEN delivery_status = 'Late' THEN 1
            ELSE 0
        END
    ) AS late_shipments,
    ROUND(
        100.0 * SUM(
            CASE
                WHEN delivery_status = 'Late' THEN 1
                ELSE 0
            END
        ) / NULLIF(COUNT(*), 0),
        2
    ) AS delay_rate_pct
FROM route_performance
GROUP BY route_id
ORDER BY delay_rate_pct DESC;


/*
============================================================
QUESTION 2:
How did shipment delay rates change month by month?

BUSINESS PURPOSE:
Identify monthly fluctuations and determine whether
performance showed a sustained decline or isolated peaks.
============================================================
*/

SELECT
    YEAR(shipment_date) AS shipment_year,
    MONTH(shipment_date) AS shipment_month,
    COUNT(*) AS total_shipments,
    SUM(
        CASE
            WHEN delivery_status = 'Late' THEN 1
            ELSE 0
        END
    ) AS late_shipments,
    ROUND(
        100.0 * SUM(
            CASE
                WHEN delivery_status = 'Late' THEN 1
                ELSE 0
            END
        ) / NULLIF(COUNT(*), 0),
        2
    ) AS delay_rate_pct,
    ROUND(AVG(CAST(planned_transit_hours AS DECIMAL(10,2))), 2)
        AS avg_planned_transit_hours,
    ROUND(AVG(CAST(actual_transit_hours AS DECIMAL(10,2))), 2)
        AS avg_actual_transit_hours,
    ROUND(
        100.0 * (
            AVG(CAST(actual_transit_hours AS DECIMAL(10,2)))
            - AVG(CAST(planned_transit_hours AS DECIMAL(10,2)))
        ) / NULLIF(
            AVG(CAST(planned_transit_hours AS DECIMAL(10,2))),
            0
        ),
        2
    ) AS transit_variance_pct,
    ROUND(AVG(CAST(planned_distance AS DECIMAL(10,2))), 2)
        AS avg_planned_distance,
    ROUND(AVG(CAST(actual_distance AS DECIMAL(10,2))), 2)
        AS avg_actual_distance,
    ROUND(
        100.0 * (
            AVG(CAST(actual_distance AS DECIMAL(10,2)))
            - AVG(CAST(planned_distance AS DECIMAL(10,2)))
        ) / NULLIF(
            AVG(CAST(planned_distance AS DECIMAL(10,2))),
            0
        ),
        2
    ) AS distance_variance_pct
FROM route_performance
GROUP BY
    YEAR(shipment_date),
    MONTH(shipment_date)
ORDER BY
    shipment_year,
    shipment_month;


/*
============================================================
QUESTION 3:
Were performance changes concentrated on specific routes
and months?

BUSINESS PURPOSE:
Determine whether monthly delay patterns were widespread
or concentrated on particular routes.
============================================================
*/

SELECT
    route_id,
    YEAR(shipment_date) AS shipment_year,
    MONTH(shipment_date) AS shipment_month,
    COUNT(*) AS total_shipments,
    SUM(
        CASE
            WHEN delivery_status = 'Late' THEN 1
            ELSE 0
        END
    ) AS late_shipments,
    ROUND(
        100.0 * SUM(
            CASE
                WHEN delivery_status = 'Late' THEN 1
                ELSE 0
            END
        ) / NULLIF(COUNT(*), 0),
        2
    ) AS delay_rate_pct
FROM route_performance
GROUP BY
    route_id,
    YEAR(shipment_date),
    MONTH(shipment_date)
ORDER BY
    route_id,
    shipment_year,
    shipment_month;


/*
============================================================
QUESTION 4:
Did the number of stops show a consistent pattern alongside
shipment delays?

BUSINESS PURPOSE:
Explore whether shipments on route-month combinations with
more stops also experienced higher delay rates.

NOTE:
Shipment counts must be considered when interpreting rates.
This comparison does not establish causation.
============================================================
*/

SELECT
    route_id,
    YEAR(shipment_date) AS shipment_year,
    MONTH(shipment_date) AS shipment_month,
    COUNT(*) AS total_shipments,
    SUM(
        CASE
            WHEN delivery_status = 'Late' THEN 1
            ELSE 0
        END
    ) AS late_shipments,
    ROUND(
        100.0 * SUM(
            CASE
                WHEN delivery_status = 'Late' THEN 1
                ELSE 0
            END
        ) / NULLIF(COUNT(*), 0),
        2
    ) AS delay_rate_pct,
    ROUND(AVG(CAST(number_of_stops AS DECIMAL(10,2))), 2)
        AS avg_number_of_stops
FROM route_performance
GROUP BY
    route_id,
    YEAR(shipment_date),
    MONTH(shipment_date)
ORDER BY
    delay_rate_pct DESC,
    total_shipments DESC;


/*
============================================================
QUESTION 5:
Which individual shipments contributed to the change in
R08 performance between January and March?

BUSINESS PURPOSE:
Compare shipment-level details across two months with the
same shipment volume but different delay rates.
============================================================
*/

SELECT
    shipment_id,
    shipment_date,
    route_id,
    delivery_status,
    delay_hours,
    number_of_stops,
    planned_distance,
    actual_distance,
    planned_transit_hours,
    actual_transit_hours,
    ROUND(
        actual_transit_hours - planned_transit_hours,
        2
    ) AS transit_difference_hours,
    ROUND(
        actual_distance - planned_distance,
        2
    ) AS distance_difference
FROM route_performance
WHERE route_id = 'R08'
  AND MONTH(shipment_date) IN (1, 3)
ORDER BY
    MONTH(shipment_date),
    shipment_date,
    shipment_id;


/*
============================================================
QUESTION 6:
What changed in R02 performance between April and May?

BUSINESS PURPOSE:
Compare shipment outcomes and operational details across
two months with the same number of shipments.
============================================================
*/

SELECT
    shipment_id,
    shipment_date,
    route_id,
    delivery_status,
    delay_hours,
    number_of_stops,
    planned_distance,
    actual_distance,
    planned_transit_hours,
    actual_transit_hours,
    ROUND(
        actual_transit_hours - planned_transit_hours,
        2
    ) AS transit_difference_hours,
    ROUND(
        actual_distance - planned_distance,
        2
    ) AS distance_difference
FROM route_performance
WHERE route_id = 'R02'
  AND MONTH(shipment_date) IN (4, 5)
ORDER BY
    MONTH(shipment_date),
    shipment_date,
    shipment_id;


/*
============================================================
QUESTION 7:
What operational details characterized R02 shipments in April?

BUSINESS PURPOSE:
Inspect the individual shipments behind the April delay
rate and distinguish late shipments from other outcomes.
============================================================
*/

SELECT
    shipment_id,
    shipment_date,
    route_id,
    delivery_status,
    delay_hours,
    number_of_stops,
    planned_distance,
    actual_distance,
    planned_transit_hours,
    actual_transit_hours,
    ROUND(
        actual_transit_hours - planned_transit_hours,
        2
    ) AS transit_difference_hours,
    ROUND(
        actual_distance - planned_distance,
        2
    ) AS distance_difference
FROM route_performance
WHERE route_id = 'R02'
  AND MONTH(shipment_date) = 4
ORDER BY
    shipment_date,
    shipment_id;


/*
============================================================
QUESTION 8:
Why did R11 show different delay rates in April and July?

BUSINESS PURPOSE:
Compare individual shipments across two months and examine
stops, transit differences, distance differences, and delivery
outcomes for potentially useful patterns.
============================================================
*/

SELECT
    shipment_id,
    shipment_date,
    route_id,
    delivery_status,
    delay_hours,
    number_of_stops,
    planned_distance,
    actual_distance,
    planned_transit_hours,
    actual_transit_hours,
    ROUND(
        actual_transit_hours - planned_transit_hours,
        2
    ) AS transit_difference_hours,
    ROUND(
        actual_distance - planned_distance,
        2
    ) AS distance_difference
FROM route_performance
WHERE route_id = 'R11'
  AND MONTH(shipment_date) IN (4, 7)
ORDER BY
    MONTH(shipment_date),
    shipment_date,
    shipment_id;


/*
============================================================
QUESTION 9:
How did monthly performance vary between R07 and R12?

BUSINESS PURPOSE:
Compare monthly delay rates while keeping shipment counts
visible, since rates based on small samples can be unstable.
============================================================
*/

SELECT
    route_id,
    YEAR(shipment_date) AS shipment_year,
    MONTH(shipment_date) AS shipment_month,
    COUNT(*) AS total_shipments,
    SUM(
        CASE
            WHEN delivery_status = 'Late' THEN 1
            ELSE 0
        END
    ) AS late_shipments,
    ROUND(
        100.0 * SUM(
            CASE
                WHEN delivery_status = 'Late' THEN 1
                ELSE 0
            END
        ) / NULLIF(COUNT(*), 0),
        2
    ) AS delay_rate_pct,
    ROUND(AVG(CAST(number_of_stops AS DECIMAL(10,2))), 2)
        AS avg_number_of_stops
FROM route_performance
WHERE route_id IN ('R07', 'R12')
GROUP BY
    route_id,
    YEAR(shipment_date),
    MONTH(shipment_date)
ORDER BY
    route_id,
    shipment_year,
    shipment_month;


/*
============================================================
QUESTION 10:
What did the detailed R12 monthly results reveal?

BUSINESS PURPOSE:
Review one route separately to see whether its monthly
results were consistent with the broader route comparison.
============================================================
*/

SELECT
    route_id,
    YEAR(shipment_date) AS shipment_year,
    MONTH(shipment_date) AS shipment_month,
    COUNT(*) AS total_shipments,
    SUM(
        CASE
            WHEN delivery_status = 'Late' THEN 1
            ELSE 0
        END
    ) AS late_shipments,
    ROUND(
        100.0 * SUM(
            CASE
                WHEN delivery_status = 'Late' THEN 1
                ELSE 0
            END
        ) / NULLIF(COUNT(*), 0),
        2
    ) AS delay_rate_pct,
    ROUND(AVG(CAST(number_of_stops AS DECIMAL(10,2))), 2)
        AS avg_number_of_stops
FROM route_performance
WHERE route_id = 'R12'
GROUP BY
    route_id,
    YEAR(shipment_date),
    MONTH(shipment_date)
ORDER BY
    shipment_year,
    shipment_month;


/*
============================================================
QUESTION 11:
Did the available shipment data reveal a consistent
relationship between delays and operational factors?

BUSINESS PURPOSE:
Review shipment-level records to assess whether observed
delay patterns align consistently with stops, transit
differences, or distance differences.

LIMITATION:
This query supports investigation, not proof of causation.
External factors may be missing from the dataset.
============================================================
*/

SELECT
    shipment_id,
    shipment_date,
    route_id,
    delivery_status,
    delay_hours,
    number_of_stops,
    planned_transit_hours,
    actual_transit_hours,
    ROUND(
        actual_transit_hours - planned_transit_hours,
        2
    ) AS transit_difference_hours,
    planned_distance,
    actual_distance,
    ROUND(
        actual_distance - planned_distance,
        2
    ) AS distance_difference
FROM route_performance
WHERE delivery_status = 'Late'
ORDER BY
    delay_hours DESC,
    shipment_date;


/*
============================================================
END OF ANALYSIS

INTERPRETATION GUIDANCE:
1. Compare delay rates alongside shipment counts.
2. Distinguish descriptive patterns from causal explanations.
3. Investigate month-specific changes before recommending
   operational interventions.
4. Consider additional data such as traffic, road incidents,
   waiting times, inspections, weather, and delivery windows.
============================================================
*/



