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
#### Q 3.1 Version: Using UNION of two LEFT JOIN tables
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
#### Q 3.2 Version: Using UNION OF Two Tables including the brand_id
* T1 still Follows the same logic with Q 3.1 Version above.
* Since in this version, I decide to include the brand_id column from the store_revenue table. Right now, the revenue term refers to the amount of revenue by each state on each day, with different brand ids.
* The UNION part is the same as the previous method.
><pre>
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

One thing to notice is that in the resulting table, for each date and geo, there would be two rows sharing the same number of impressions and clicks. The only difference between the two rows is the revenue by different brand_ids. That is because in the marketing_data table, there are no columns named brand_id and I can not identify the specific amount of impressions and clicks for each brand. As a result, I change the name for the impressions and clicks to impressions_statewise and clicks_statewise so that the reader can understand.

#### Q 3.3 Version: Using FULL JOIN method that only contains Non-NULL rows
* Since I use mysql to finish this assessment, there does not exist a FULL OUTER JOIN command.The FULL JOIN command only produces the rows that satisfy the ON conditions with non-NULL entries.
* Same as Q 3.1 above, in T1 I select the four columns needed for the FULL JOIN.
* Same as Q 3.1 above, in T2 I select the three required columns for the FUll JOIN.
* The FULL JOIN command can not contain all the records from both tables. But I need this resulting table for the Question 4.
><pre>
>WITH T1 AS(
>SELECT date as date_m,
>        geo as geo_m,
>        clicks, 
>        impressions
>FROM marketing_data
>),
>T2 AS( 
>SELECT date as date_s, 
>        SUBSTRING(store_location,15) as geo_s, 
>        SUM(revenue) as revenue
>FROM store_revenue
>GROUP BY date_s, geo_s
>)
>SELECT date_m as date, 
>        geo_m as geo,
>        impressions,
>        clicks,
>        revenue
>FROM T1 FULL JOIN T2
>ON date_m=date_s AND geo_m=geo_s;
### [4]  Question #4 In your opinion, what is the most efficient store and why?
​
Answer: For this open-end question, I create three different indicators for measuring the effiency of the stores for each state. For each of the indicator, I will explain the definition and corresponding explanation of logics behind it.
#### Q 4.1.1 Version: First indicator——> Impressions/clicks ratio, for each state only
* IC_ratio (Impressions_clicks ratio) is defined as on average, how many impressions the stores in each state need to gain an additional click.
* With lower IC_ratio, the stores in that state is more efficient becasue it would take fewer impressions to generate an addtional click. That is the reason why I create the rankings of the stores in each state by ascending IC_rate order.
* Same as above, I create a temporary table T1 storing the sum of impressions and clicks for each state during the total time periods provided in the marketing_data table.
><pre>
>WITH T1 AS( 
>SELECT geo,
>       SUM(impressions) as impressions_sum,
>       SUM(clicks) as clicks_sum
>FROM marketing_data
>GROUP BY geo
>)
>SELECT geo,
>       impressions_sum, 
>       clicks_sum,
>       ROUND(impressions_sum/clicks_sum,2) as IC_ratio,
>       DENSE_RANK() OVER (ORDER BY impressions_sum/clicks_sum ASC) as rankings_IC_rate
>FROM T1;
* Question #5 (Challenge)
 Generate a query to rank in order the top 10 revenue producing states
​
