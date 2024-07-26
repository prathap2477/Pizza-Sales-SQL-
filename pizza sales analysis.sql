
-- 1. Retrieve the total number of orders placed.
SELECT 
    COUNT(*)
FROM
    ORDERS;
-- 2.Calculate the total revenue generated from pizza sales.
SELECT 
    ROUND(SUM(od.quantity * p.price), 2) AS total_revenue
FROM
    order_details od
        JOIN
    pizzas p ON od.pizza_id = p.pizza_id;

-- 3.Identify the highest-priced pizza.
SELECT 
    pt.`name`, p.price
FROM
    pizza_types pt
        JOIN
    pizzas p ON p.pizza_type_id = pt.pizza_type_id
ORDER BY p.price DESC
LIMIT 1;
-- 4.Identify the most common pizza size ordered.
SELECT 
    p.size, count(p.size) AS order_quantity
FROM
    pizzas p
        JOIN
    order_details od ON p.pizza_id = od.pizza_id
GROUP BY p.size
ORDER BY order_quantity DESC
LIMIT 1;

-- List the top 5 most ordered pizza types along with their quantities.
SELECT 
    pt.`name`, SUM(od.quantity) order_quantity
FROM
    pizzas p
        JOIN
    pizza_types pt ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details od ON p.pizza_id = od.pizza_id
GROUP BY pt.`name`
ORDER BY order_quantity DESC
LIMIT 5;

-- Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT 
    pt.category, SUM(od.quantity) AS qunatity
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details od ON p.pizza_id = od.pizza_id
GROUP BY pt.category
;
-- Determine the distribution of orders by hour of the day.
SELECT 
    HOUR(o.order_time) AS order_hour,
    count(od.order_id) AS quantity
FROM
    orders o
        JOIN
    order_details od ON o.order_id = od.order_id
GROUP BY order_hour
ORDER BY quantity;


-- Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT 
    ROUND(AVG(quantity), 0) AS avg_pizza_order_per_day
FROM
    (SELECT 
        DATE(o.order_date) AS ordered_date,
            SUM(od.quantity) AS quantity
    FROM
        orders o
    JOIN order_details od ON o.order_id = od.order_id
    GROUP BY ordered_date) AS temp
;
-- Determine the top 3 most ordered pizza types based on revenue.
select pt.`name` , round(sum(p.price * od.quantity),0) as revenue
from pizzas p
join pizza_types pt
on pt.pizza_type_id=p.pizza_type_id
join order_details od
on p.pizza_id=od.pizza_id
group by pt.`name`
order by revenue desc
limit 3
;

-- Calculate the percentage contribution of each pizza type to total revenue.

SELECT 
    pt.`name`,
    ROUND(SUM(p.price * od.quantity), 2) AS revenue,
    ROUND((ROUND(SUM(p.price * od.quantity), 2) / (SELECT 
                    ROUND(SUM(p.price * od.quantity), 2)
                FROM
                    pizzas p
                        JOIN
                    order_details od ON p.pizza_id = od.pizza_id)) * 100,
            2) AS percentage
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details od ON p.pizza_id = od.pizza_id
GROUP BY pt.`name`
ORDER BY percentage DESC
;


-- Analyze the cumulative revenue generated over time.

select order_date,
sum(revenue) over(order by order_date) as cum_revenue
from
(select 
o.`order_date`,
round(sum(p.price * od.quantity),2) as revenue
from orders o
join order_details od
on o.order_id=od.order_id
join pizzas p
on p.pizza_id=od.pizza_id
group by o.order_date) temp
;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select *
from
(select *,
rank() over(partition by category order by revenue desc) as drn
from
(select 
pt.category,
pt.`name`, 
 round(sum(od.quantity * p.price),2) as revenue
 from pizzas p
 join pizza_types pt
 on pt.pizza_type_id=p.pizza_type_id
 join order_details od
 on p.pizza_id=od.pizza_id
 group by pt.`name`) as sales) temp
 where drn<4
 ;




