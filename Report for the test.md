# SQL Challenge

## Below are my SQL statements for each question. 
## Note: All the statements below are written in mysql environment.
### [1] Question #1 Generate a query to get the sum of the clicks of the marketing data
​ 
Answer: It is a very straightforward case. I simply use SUM command for the variable clicks in the marketing_data table.
> <pre>
> SELECT SUM(clicks) as sum_clicks
> FROM marketing_data;
### [2]  Question #2 Generate a query to gather the sum of revenue by geo from the store_revenue table
​
Answer: This is also a straightforward case. Using a group by statement to generate the sum regarding each state.
> <pre>
> SELECT SUBSTRING(store_location,15) as geo,
>        SUM(revenue) as revenue_geo
> FROM store_revenue
> GROUP BY store_location;

I use the SUBSTRING command to extract only the state name from the column store_location so that it matches the geo variable form in the marketing_data table. 
### [3]  Question #3 Merge these two datasets so we can see impressions, clicks, and revenue together by date and geo. Please ensure all records from each table are accounted for.
​
Answer: As mentioned at the beginning, I write my commands in MySQL environment. Since MySQL does not have a FULL OUTER JOIN command, I mainly use the UNION of two LEFT JOIN tables to cover all the observations from the two table. I have used three methods for answering Question 3, with the initial two to be the UNION of two LEFT JOIN tables and the last to be the FULL JOIN method.
#### Q 3.1 Version: USING UNION OF TWO LEFT JOIN TABLES
* Here is the first method of UNION two LEFT JOIN tables T1 and T2. 
* I create T1 to select the four columns that I need from the marketing_data table. 
* T2 is used to select the date, geo, and the sum of revenue group by date and geo (combing the revenue of all the brands sold on a specific day at a specific state).
><pre>
> WITH T1 AS(
> SELECT date,
>        geo,
>        clicks,
>        impressions
> FROM marketing_data
>),
>T2 AS(                                                                                  
>SELECT date,                                                                        
>       SUBSTRING(store_location,15) as geo,
>       SUM(revenue) as revenue
>FROM store_revenue
>GROUP BY date, geo
>)
>SELECT T1.date,
>        T1.geo,
>        impressions,
>        clicks,
>        revenue
>FROM T1 LEFT JOIN T2
>ON T1.date=T2.date AND T1.geo=T2.geo
>UNION
>SELECT T2.date,
>        T2.geo,
>        impressions,
>        clicks,
>        revenue
>FROM T2 LEFT JOIN T1
>ON T2.date=T1.date AND T1.geo=T2.geo;
The reason to use the UNION command is to combine two LEFT JOIN Tables. The LEFT JOIN command, if in the form A LEFT JOIN B, is  able to capture all the rows from  table A. So I union the table A (T1 LEFT JOIN T2) and the table B (T2 LEFT JOIN T1) to make sure I have got all the rows from the two tables: T1, T2 in my final results. 
#### Q 3.2 Version: USING UNION OF Two Tables including the brand_id
<pre>
> WITH T1 AS(
>SELECT date,                                           
>       geo, 
>       clicks, 
>       impressions
>FROM marketing_data
>),
>T2 AS(                                                     
>SELECT date,                                              
>       SUBSTRING(store_location,15) as geo,                
>       brand_id,
>       revenue
>FROM store_revenue
>GROUP BY date, geo, brand_id
>)
>SELECT T1.date as date,                                    
>       T1.geo as geo, 
>       impressions as impressions_statewise, 
>       clicks as clicks_statewise, 
>       brand_id,
>       revenue
>FROM T1 LEFT JOIN T2
>ON T1.date=T2.date AND T1.geo=T2.geo
>UNION
>SELECT T2.date as date,
>       T2.geo as geo, 
>       impressions as impressions_statewise, 
>       clicks as clicks_statewise,
>       brand_id,
>       revenue
>FROM T2 LEFT JOIN T1
>ON T2.date=T1.date AND T1.geo=T2.geo;
* Question #4
 In your opinion, what is the most efficient store and why?
​
* Question #5 (Challenge)
 Generate a query to rank in order the top 10 revenue producing states
​
