CREATE DATABASE PizzaHut;
use PizzaHut;

select name from sys.tables;

 ---------- checking for how many values are there in each table--------------------------------
select 'Pizzas' as table_name,count(*) as total_rows
from pizzas
UNION ALL
select 'pizza_types' as table_name ,count(*) as total_rows
from pizza_types
UNION ALL
select 'orders' as table_name ,count(*) as total_rows
from orders
UNION ALL
select 'order_details' as table_name ,count(*) as total_rows
from order_details;

--Basic:
--1.Retrieve the total number of orders placed.

Select count(order_id) as Total_orders
from orders;

--2.Calculate the total revenue generated from pizza sales.

select Round(Sum(p.price*od.quantity),2) as Total_sales
from pizzas as p
join order_details as od 
on p.pizza_id = od.pizza_id

--3.Identify the highest-priced pizza.

select Top 1 pt.name , p.price as high_price_pizza
from pizza_types as pt
join pizzas as p
on pt.pizza_type_id = p.pizza_type_id
order by p.price desc;

--4.Identify the most common pizza size ordered.

select p.size,count(od.order_details_id) as order_frequency
from pizzas as p
join order_details as od
on p.pizza_id = od.pizza_id
group by p.size
order by order_frequency desc;

--5.List the top 5 most ordered pizza types along with their quantities.

select Top 5 pt.name,sum(od.quantity) as quantity
from pizzas as p
join pizza_types as pt
on p.pizza_type_id = pt.pizza_type_id
join order_details as od
on p.pizza_id = od.pizza_id
group by pt.name
order by quantity desc;

--Intermediate:
--1.Join the necessary tables to find the total quantity of each pizza category ordered.

select pt.category, Sum(od.quantity) as Total_quantity
from order_details as od
join pizzas as p
on od.pizza_id = p.pizza_id
join pizza_types as pt
on pt.pizza_type_id = p.pizza_type_id
Group By pt.category
Order By Total_quantity desc;

--2.Determine the distribution of orders by hour of the day.

Select DatePart(hour,time) as hour_extracted , count(order_id) as order_count
from orders
Group By DatePart(hour,time)
Order By order_count desc;

--3.Join relevant tables to find the category-wise distribution of pizzas.

Select category, count(name) as count_of_pizzas
from pizza_types
Group By category;

--Group the orders by date and calculate the average number of pizzas ordered per day.

Select avg(quantity) as avg_pizzaorder_per_day
from
 (Select o.date, sum(od.quantity) as quantity
  from orders as o
  join order_details as od
  on o.order_id = od.order_id
  Group by o.date) 
As order_quantity;

--Determine the top 3 most ordered pizza types based on revenue.

Select Top 3 pt.name , Sum(p.price * od.quantity) as revenue
from pizza_types as pt
join pizzas as p
on pt.pizza_type_id = p.pizza_type_id
join order_details as od
on od.pizza_id = p.pizza_id
Group by pt.name
Order by revenue desc;

--Advanced:
-- 1. Calculate the percentage contribution of each pizza type to total revenue.

Select pt.category , 
       Round((Sum(p.price * od.quantity) / (select 
	                                       Round(Sum(p.price*od.quantity),2) as Total_sales
                                           from pizzas as p
                                          join order_details as od 
                                           on p.pizza_id = od.pizza_id) ) * 100,2) As Percent_contri
from pizza_types as pt
join pizzas as p
on pt.pizza_type_id = p.pizza_type_id
join order_details as od
on od.pizza_id = p.pizza_id
Group by pt.category


--2. Analyze the cumulative revenue generated over time.

Select date, Sum(revenue) over(order by date) as cum_revenue
from 
   (Select o.date, Sum(od.quantity * p.price) as revenue
    from order_details as od
    join pizzas as p
    on od.pizza_id = p.pizza_id
    join orders as o
    on o.order_id = od.order_id
    Group by o.date) 
as revenue_by_date;



--3. Determine the top 3 most ordered pizza types based on revenue for each pizza category.

Select category,name,revenue from 
(Select category,name,revenue, RANK() Over(Partition by category Order by Revenue desc) as Rn
from 
     (Select pt.category, pt.name , Sum(p.price * od.quantity) as Revenue
      from pizza_types as pt
      join pizzas as p
      on pt.pizza_type_id = p.pizza_type_id
      join order_details as od
      on od.pizza_id = p.pizza_id
      Group by pt.category,pt.name) 
      as revenue_table)  
as ranking_table
where rn<=3;
