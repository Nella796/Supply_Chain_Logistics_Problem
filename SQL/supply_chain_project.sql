
-- Average minimum cost by origin port

SELECT orig_port_cd, AVG(CAST(REPLACE(minimum_cost, '$', '') AS DECIMAL)) avg_min_cost, AVG(CAST(REPLACE(rate, '$', '') AS DECIMAL))
 FROM `platinum-voice-334221.supply_chain_logistics_problem.FreightRates`
 GROUP BY orig_port_cd


-- Modes of transportation used most often by each origin port

SELECT orig_port_cd, mode_dsc, COUNT(*)
 FROM `platinum-voice-334221.supply_chain_logistics_problem.FreightRates`
 GROUP BY orig_port_cd, mode_dsc


-- Avg days per shipment by port

WITH Averages AS
(SELECT orig_port_cd, (SELECT AVG(tpt_day_cnt) FROM `platinum-voice-334221.supply_chain_logistics_problem.FreightRates`) avg_general,
AVG(tpt_day_cnt) avg_port
FROM `platinum-voice-334221.supply_chain_logistics_problem.FreightRates`
GROUP BY orig_port_cd)

SELECT orig_port_cd, avg_general, avg_port, (avg_general - avg_port) avg_diff FROM Averages

-- Most common service level?

SELECT Service_Level, COUNT(*) FROM `platinum-voice-334221.supply_chain_logistics_problem.OrderList`
GROUP BY Service_Level

-- Cumulative weights of each order

SELECT Order_ID, Unit_quantity * Weight FROM `platinum-voice-334221.supply_chain_logistics_problem.OrderList`


-- Average cumulative weights by Port, Carrier, service level, or customer

SELECT Origin_Port, AVG(Unit_quantity * Weight) avg_cumulative_weight
FROM `platinum-voice-334221.supply_chain_logistics_problem.OrderList`
GROUP BY Origin_Port

SELECT Carrier, AVG(Unit_quantity * Weight) avg_cumulative_weight
FROM `platinum-voice-334221.supply_chain_logistics_problem.OrderList`
GROUP BY Carrier

SELECT Customer, AVG(Unit_quantity * Weight) avg_cumulative_weight
FROM `platinum-voice-334221.supply_chain_logistics_problem.OrderList`
GROUP BY Customer


-- Plants with most unique products

SELECT Plant_Code, COUNT(*) Count FROM `platinum-voice-334221.supply_chain_logistics_problem.ProductsPerPlant`
GROUP BY Plant_Code
ORDER BY Count DESC


-- Products shipping in most plants

SELECT Product_ID, COUNT(*) Count FROM `platinum-voice-334221.supply_chain_logistics_problem.ProductsPerPlant`
GROUP BY Product_ID
ORDER BY Count DESC


-- Warehouses with the most restrictions

SELECT string_field_0, COUNT(*) count FROM `platinum-voice-334221.supply_chain_logistics_problem.VmiCustomers`
WHERE string_field_0 != 'Plant Code'
GROUP BY string_field_0
ORDER BY count DESC

-- Cheapest plants

SELECT * FROM `platinum-voice-334221.supply_chain_logistics_problem.WhCosts`
ORDER BY Cost_unit DESC

-- Plants with largest expense (based on current inventory)

WITH total_units AS (SELECT Plant_Code, SUM(Unit_quantity) Unit_quantity FROM `platinum-voice-334221.supply_chain_logistics_problem.OrderList`
GROUP BY Plant_Code)

SELECT t.Plant_Code, t.Unit_quantity, c.Cost_unit, (t.Unit_quantity * c.Cost_unit) total_cost
FROM total_units t
LEFT JOIN (SELECT * FROM `platinum-voice-334221.supply_chain_logistics_problem.WhCosts`) c
ON c.WH = t.Plant_Code
ORDER BY total_cost DESC


-- Customer share of orders by warehouse?

SELECT Plant_ID, Daily_Capacity_,
ROUND(Daily_Capacity_ / (SELECT SUM(Daily_Capacity_) FROM `platinum-voice-334221.supply_chain_logistics_problem.WhCapacities`)*100,2) Percent_of_total
FROM `platinum-voice-334221.supply_chain_logistics_problem.WhCapacities`
ORDER BY Percent_of_total DESC
