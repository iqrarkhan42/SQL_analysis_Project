-- Retrieve the total number of orders placed.

SELECT 
    COUNT(order_id) AS toral_orders
FROM
    orders;



-- Calculate the total revenue generated from pizza sales.

SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price),2)
    AS total_revenue
FROM
    pizzas
	JOIN order_details
    ON pizzas.pizza_id = order_details.pizza_id;



-- Identify the highest-priced pizza.

SELECT pizza_types.name,
	pizzas.price
FROM pizzas
	JOIN
    pizza_types
    ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;



-- Identify the most common pizza size ordered.

SELECT pizzas.size,
    COUNT(order_details.order_details_id) AS total_orders
FROM order_details
	JOIN pizzas
    ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizzas.size
ORDER BY total_orders DESC;



-- List the top 5 most ordered pizza types
-- along with their quantities.

SELECT pizza_types.name,
    SUM(order_details.quantity) AS total_quantity
FROM pizza_types
	JOIN pizzas
    ON pizzas.pizza_type_id = pizza_types.pizza_type_id
	JOIN order_details
    ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY total_quantity DESC
LIMIT 5;



-- find the total quantity
-- of each pizza category ordered.

SELECT pizza_types.category,
    SUM(order_details.quantity) AS total_quantity_ordered
FROM pizza_types
	JOIN pizzas
    ON pizzas.pizza_type_id = pizza_types.pizza_type_id
	JOIN order_details
    ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.category
ORDER BY total_quantity_ordered DESC;




-- Determine the distribution of orders by hour of the day.

SELECT 
    HOUR(order_time) AS time_in_hours,
    COUNT(order_id) AS orders_per_hour
FROM 
	orders
GROUP BY HOUR(order_time)
ORDER BY orders_per_hour DESC;




-- find the category-wise distribution of pizzas.

SELECT category,
	COUNT(name) AS total_pizzas
FROM 
	pizza_types
GROUP BY category;





-- Group the orders by date and calculate
-- the average number of pizzas ordered per day.

SELECT round(avg(total_quantity),0) as avg_qtty_per_day
FROM (SELECT orders.order_date, 
	sum(order_details.quantity) as total_quantity
FROM orders
	join order_details
	on orders.order_id = order_details.order_id
GROUP BY orders.order_date) as order_quantity;




-- Determine the top 3 most ordered pizza types based on revenue.

SELECT pizza_types.name,
    ROUND(SUM(pizzas.price * order_details.quantity),2)
    AS revenue
FROM pizzas
	JOIN order_details
    ON pizzas.pizza_id = order_details.pizza_id
	JOIN pizza_types
    ON pizzas.pizza_type_id = pizza_types.pizza_type_id
GROUP BY pizza_types.name
ORDER BY revenue DESC
LIMIT 3;





-- Calculate the percentage contribution
-- of each pizza type to total revenue.

SELECT pizza_types.category,
    ROUND(SUM(pizzas.price * order_details.quantity)/
    (SELECT SUM(pizzas.price * order_details.quantity) AS total_rev
FROM pizzas
	JOIN order_details
    ON pizzas.pizza_id = order_details.pizza_id)*100,2) AS percentage_rev
FROM pizzas
	JOIN order_details ON pizzas.pizza_id = order_details.pizza_id
	JOIN pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
GROUP BY pizza_types.category
ORDER BY percentage_rev DESC;





-- Analyze the cumulative revenue generated over time.

SELECT order_date, round(sum(revenue)
	OVER(ORDER BY order_date),2) as cum_revenue
FROM (SELECT orders.order_date,
    ROUND(SUM(pizzas.price * order_details.quantity),2) AS revenue
FROM pizzas
	JOIN order_details ON pizzas.pizza_id = order_details.pizza_id
	JOIN orders ON order_details.order_id = orders.order_id
GROUP BY orders.order_date) as sales;





-- Determine the top 3 most ordered pizza types based
-- on revenue for each pizza category.

SELECT name, revenue FROM
(SELECT category, name, revenue,
rank() over(PARTITION BY category ORDER BY revenue DESC) AS rank_rev
FROM (SELECT pizza_types.name, pizza_types.category,
    round(SUM(pizzas.price * order_details.quantity),2) AS revenue
FROM pizzas
	JOIN order_details ON pizzas.pizza_id = order_details.pizza_id
	JOIN pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
GROUP BY pizza_types.name , pizza_types.category) AS cat_rev) AS ranking_rev
WHERE rank_rev <=3;
