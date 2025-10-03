create database PizzaHut;
use Pizzahut;

select * from orders_details;
select * from pizza_types;
select * from orders;
select * from pizzas;


-- 1.  Retrieve the total number of orders placed.

select count(order_id) as Total_orders from orders;

-- 2. Calculate the total revenue generated from pizza sales.

SELECT 
    ROUND(SUM(od.Quentity * p.price), 2) AS Total_sales
FROM
    orders_details od
        JOIN
    pizzas p ON od.pizza_id = p.pizza_id;

-- 3. Identify the highest-priced pizza.

SELECT 
    pt.name, p.price
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
ORDER BY p.price DESC
LIMIT 1;

-- 4. Identify the most common pizza size ordered.

SELECT 
    pizzas.size,
    COUNT(orders_details.order_details_id) AS Order_Count
FROM
    pizzas
        JOIN
    orders_details ON pizzas.pizza_id = orders_details.pizza_id
GROUP BY pizzas.size
ORDER BY Order_Count DESC;

-- 5. List the top 5 most ordered pizza types along with their quantities.

SELECT 
    pizza_types.name,
    SUM(orders_details.quentity) AS Total_Quentity_ordered
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    orders_details ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY Total_Quentity_ordered DESC
LIMIT 5;

-- 6. Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT 
    pizza_types.Category,
    SUM(orders_details.quentity) AS Total_Quentity
FROM
    Pizza_types
        JOIN
    pizzas ON Pizza_types.Pizza_type_id = pizzas.Pizza_type_id
        JOIN
    orders_details ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.Category
ORDER BY Total_Quentity DESC;


-- 7. Determine the distribution of orders by hour of the day.

SELECT 
    HOUR(order_time) AS Hour, COUNT(order_id) AS order_count
FROM
    Orders
GROUP BY HOUR(order_time)
ORDER BY COUNT(order_id);

-- 8. Join relevant tables to find the category-wise distribution of pizzas.

SELECT 
    pizza_types.category, COUNT(pizza_types.name)
FROM
    pizza_types
GROUP BY category;


-- 9. Group the orders by date and calculate the average number of pizzas ordered per day.

SELECT 
    ROUND(AVG(quentity), 0) AS Avg_orders_per_day
FROM
    (SELECT 
        orders.Order_date, SUM(orders_details.quentity) AS quentity
    FROM
        orders
    JOIN orders_details ON orders.order_id = orders_details.order_id
    GROUP BY orders.order_date) AS Order_quentity;

-- 10. Determine the top 3 most ordered pizza types based on revenue.

SELECT 
    pizza_types.name,
    SUM(orders_details.quentity * pizzas.price) AS Revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    orders_details ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY Revenue DESC
LIMIT 3;
    
-- 11. Calculate the percentage contribution of each pizza type to total revenue.
SELECT 
    pizza_types.category,
    ROUND(SUM(orders_details.quentity * pizzas.price) / (SELECT 
                    ROUND(SUM(od.Quentity * p.price), 2) AS Total_sales
                FROM
                    orders_details od
                        JOIN
                    pizzas p ON od.pizza_id = p.pizza_id) * 100) AS Revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    orders_details ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category;


-- 12. Analyze the cumulative revenue generated over time.

select order_date, 
sum(Revenue) over(order by order_date) as Cum_Revenue
from
(select orders.order_date, 
round(sum( orders_details.quentity * pizzas.price),2) as Revenue
from orders_details join pizzas 
on orders_details.pizza_id = pizzas.pizza_id
join orders
on orders.order_id = orders_details.order_id 
group by  orders.order_date) as sales;


-- 13. Determine the top 3 most ordered pizza types based on revenue for each pizza category.

Select name, category, revenue 
from
(select category,name,revenue,
rank() over(partition by category order by revenue) as Rn
from
(select pizza_types.category ,pizza_types.name,
SUM(orders_details.quentity * pizzas.price) AS Revenue
from pizza_types
join pizzas on pizzas.pizza_type_id = pizza_types.pizza_type_id
join orders_details on orders_details.pizza_id = pizzas.pizza_id
group by  pizza_types.category, pizza_types.name) as A) as B
where rn <= 3;




