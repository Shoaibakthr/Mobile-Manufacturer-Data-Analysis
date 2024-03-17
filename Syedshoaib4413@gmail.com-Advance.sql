
--Q1. List all the states in which we have customers who have bought cellphones from 2005 till today.
--BEGIN 
	Select distinct State from (
	Select T1.State,sum(Quantity)as [Count],Year(t2.Date)as [Year] from DIM_LOCATION as T1 
	join FACT_TRANSACTIONS as T2 on T1.IDLocation=T2.IDLocation
	Where Year(t2.Date)>=2005 
	Group by t1.State,Year(t2.Date) ) as A;
--Q1--END

--Q2. What state in the US is buying the most 'Samsung' cell phones?
--BEGIN
	Select top 1 State, count(*) as [Count] from DIM_LOCATION as t1 
	join FACT_TRANSACTIONS as t2 on t1.IDLocation = t2.IDLocation
	join DIM_MODEL as t3 on t2.IDModel=t3.IDModel
	join DIM_MANUFACTURER as t4 on t3.IDManufacturer= t4.IDManufacturer
	where Country = 'US' and Manufacturer_Name = 'Samsung'
	group by State
	order by sum (Quantity) desc;
--Q2--END

--Q3. Show the number of transactions for each model per zip code per state. 
--BEGIN  
	Select Model_Name,ZipCode,State, count(Distinct t2.IDCustomer) as [Numer of Transactions] from DIM_LOCATION as T1 
	join FACT_TRANSACTIONS as t2 on t1.IDLocation=t2.IDLocation
	join DIM_MODEL as T3 on t2.IDModel= t3.IDModel
	group by ZipCode,State, Model_Name
	order by count(Distinct t2.IDCustomer) desc;
--Q3--END

--Q4. Show the cheapest cellphone (Output should contain the price also)
--BEGIN
   Select Top 1 Model_Name, min(Unit_price) as Price from DIM_MODEL
   Group by Model_Name
   Order by min(Unit_price) 
--Q4--END

--Q5. Find out the average price for each model in the top5 manufacturers in terms of sales quantity and order by average price.
--BEGIN
   Select Manufacturer_Name, t1.IDModel, avg(TotalPrice) as Avg_sales, sum(Quantity) As Total_Quantity from FACT_TRANSACTIONS as t1 
   join DIM_MODEL as t2 on t1.IDModel=t2.IDModel
   join DIM_MANUFACTURER as t3 on t2.IDManufacturer= t3.IDManufacturer
   where Manufacturer_Name in (Select Top 5 Manufacturer_Name from FACT_TRANSACTIONS as t1 
                           join DIM_MODEL as t2 on t1.IDModel=t2.IDModel
                           join DIM_MANUFACTURER as t3 on t2.IDManufacturer= t3.IDManufacturer
                           group by Manufacturer_Name
                           order by sum(TotalPrice) desc) 
   group by t1.IDModel, Manufacturer_Name
--Q5--END

--Q6. List the names of the customers and the average amount spent in 2009, where the average is higher than 500
--BEGIN
   Select Customer_Name,avg(TotalPrice)as Avg_sales,Year(date)as [Year] from DIM_CUSTOMER as t1 
   join FACT_TRANSACTIONS as t2 on t1.IDCustomer=t2.IDCustomer
   where Year(date) = 2009 
   group by Customer_Name,Year(date) 
   having avg(TotalPrice) > 500
   order by avg(TotalPrice) desc 
--Q6--END
	
--Q7. List if there is any model that was in the top 5 in terms of quantity, simultaneously in 2008, 2009 and 2010
--BEGIN  
Select * from(
	Select top 5 IDModel from FACT_TRANSACTIONS
	where year(date) = 2008
	group by IDModel, year(date)
	order by sum (Quantity) desc) as A 
Intersect
Select * from (
	Select top 5 IDModel from FACT_TRANSACTIONS
	where year(date) = 2009
	group by IDModel, year(date)
	order by sum (Quantity) desc) as B 
Intersect
Select * from (
	Select top 5 IDModel from FACT_TRANSACTIONS
	where year(date) = 2010
	group by IDModel, year(date)
	order by sum (Quantity) desc) as C 
--Q7--END

--Q8. Show the manufacturer with the 2nd top sales in the year of 2009 and the manufacturer with the 2nd top sales in the year of 2010. 
--BEGIN
Select * from (
 Select top 1 * from (
    Select top 2 Manufacturer_Name,year(date) as [Year], sum (TotalPrice) as Total_sales from DIM_MODEL as t1 
    join FACT_TRANSACTIONS as t2 on t1.IDModel=t2.IDModel 
    join DIM_MANUFACTURER as t3 on t1.IDManufacturer=t3.IDManufacturer
    where year(date) = 2009 
    group by Manufacturer_Name, year(date)
    order by Total_sales desc ) As A 
 order by Total_sales asc ) as C
Union 
Select * from (
 Select top 1 * from (
      Select top 2 Manufacturer_Name,year(date) as [Year], sum (TotalPrice) as Total_sales from DIM_MODEL as t1 
      join FACT_TRANSACTIONS as t2 on t1.IDModel=t2.IDModel 
      join DIM_MANUFACTURER as t3 on t1.IDManufacturer=t3.IDManufacturer
      where year(date) = 2010 
      group by Manufacturer_Name, year(date)
      order by Total_sales desc ) As B 
 order by Total_sales asc) D
--Q8--END

--Q9. Show the manufacturers that sold cellphones in 2010 but did not in 2009.
--BEGIN
Select * from (
	Select Manufacturer_Name from DIM_MODEL as t1 
    join FACT_TRANSACTIONS as t2 on t1.IDModel=t2.IDModel 
    join DIM_MANUFACTURER as t3 on t1.IDManufacturer=t3.IDManufacturer
    where year(date) = 2010 ) as A 
Except 
Select * from (
	Select Manufacturer_Name from DIM_MODEL as t1 
    join FACT_TRANSACTIONS as t2 on t1.IDModel=t2.IDModel 
    join DIM_MANUFACTURER as t3 on t1.IDManufacturer=t3.IDManufacturer
    where year(date) = 2009 ) as B
--Q9--END

--Q10. Find top 100 customers and their average spend, average quantity by each year. Also find the percentage of change in their spend.
--BEGIN
Select *, ((Avg_price - lag_Price)/Lag_Price)as Percentage_Change from(
 Select *, lag(Avg_price,1) over (partition by IDCustomer order by year) as Lag_Price from (
   Select IDCustomer,year(date) as Year, avg(totalprice) as Avg_Price, sum(Quantity)as Quantity From FACT_TRANSACTIONS
	where IDCustomer in (Select Top 100 IDCustomer  from FACT_TRANSACTIONS
	                     group by IDCustomer,year(date)
	                     order by sum(Quantity) desc)
	group by IDCustomer,year(date)
	)As A ) As B
--Q10--END
	