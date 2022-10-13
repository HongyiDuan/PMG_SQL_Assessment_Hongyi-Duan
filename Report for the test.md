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
>        SUM(impressions) as impressions_sum,
>        SUM(clicks) as clicks_sum
>FROM marketing_data
>GROUP BY geo
>)
>SELECT geo,
>        impressions_sum, 
>        clicks_sum,
>        ROUND(impressions_sum/clicks_sum,2) as IC_ratio,
>        DENSE_RANK() OVER (ORDER BY impressions_sum/clicks_sum ASC) as rankings_IC_rate
>FROM T1;
#### Q 4.1.2 Version: First indicator, different scenario——> Impressions/clicks ratio, for each state and date
* Following a similar structure with Q 4.1.1, I have measured the same IC rate, but the ratio right now is based on each state and each date.
* I also rename the column to make them consistant with other codes in Question 4.
><pre>
>SELECT geo,
>        date,
>        impressions as impressions_sum,
>        clicks as clicks_sum,
>        ROUND(impressions/clicks,2) as IC_ratio,
>        DENSE_RANK() OVER (ORDER BY impressions/clicks ASC) as rankings_IC_rate
>FROM marketing_data;
#### Q 4.2.1 Version: CR_Rate by each state
* The second indicator that I use to measure the efficiency is the CR ratio, which is defined as the sum of clicks divided by the sum
of revenue. 
* This ratio measures how many clicks that the stores need to generate an addtional unit of revenue.
* Again, with lower RC_ratio, the stores in that state is more efficient becasue it would take fewer clicks to generate an addtional revenue. That is the reason why I create the rankings of the stores in each state by ascending RC_rate.
* Also, another important assumption that I make for this indicator is that in the Question 3, we can find there exist mismatch between marketing_data table and store_revenue table. I simply keep the rows of the merging result with non-NULL values instead of including the NULL values inside. Since CR ratio is a fraction, NULL value on the denominator is hard to deal with.
><pre>
>WITH T1 AS(
>SELECT date as date_m, 
>	     geo as geo_m, 
>        clicks
>        FROM marketing_data
>),
>T2 AS(
>SELECT date as date_s,
>        SUBSTRING(store_location,15) as geo_s,
>        SUM(revenue) as revenue
>FROM store_revenue
>GROUP BY date, geo_s   
>), 
>T3 AS(
>SELECT geo_m as geo,                                       
>        SUM(clicks) as clicks_sum, 
>        SUM(revenue) as revenue_sum
>        FROM T1 FULL JOIN T2
>ON date_m=date_s AND geo_m=geo_s
>GROUP BY geo
>)
>SELECT geo, 
>        cicks_sum,
>        revenue_sum,
>        ROUND(clicks_sum/revenue_sum,5) as cr_transition_rate,
>        DENSE_RANK() OVER (ORDER BY clicks_sum/revenue_sum ASC) as RANKINGS_CR
>FROM T3;

Here, the three temporary tables, although look complicated, are the tables that I create use FULL JOIN in Question 3.3. Since this ratio requires the revenue column from the store_revenue table and the clicks column from the marketing_data table, I need the merging table to contain all the non-NULL values.

#### Q 4.2.2 Version: CR_Rate by each state and each date
* Similar to Q 4.1.2, I release the date as another column.
><pre>
>WITH T1 AS(
>SELECT date as date_m, 
>        geo as geo_m,
>        clicks
>FROM marketing_data
>),
>T2 AS(
>SELECT date as date_s, 
>        SUBSTRING(store_location,15) as geo_s, 
>        SUM(revenue) as revenue
>FROM store_revenue
>GROUP BY date, geo_s
>),
>T3 AS(
>SELECT geo_m as geo, 
>        date_m as date,
>        clicks as clicks_sum, 
>        revenue as revenue_sum
>FROM T1 FULL JOIN T2
>ON date_m=date_s AND geo_m=geo_s
>)
>SELECT geo, 
>        date, 
>        clicks_sum, 
>        revenue_sum,
>	     ROUND(clicks_sum/revenue_sum,5) as cr_transition_rate,
>        DENSE_RANK() OVER (ORDER BY clicks_sum/revenue_sum ASC) as RANKINGS_CR
>FROM T3;
#### Q 4.3 Version: Revenue Based Ranking WITH BRAND_ID Included
* Since under this indicatory, the higher the revenue, the more efficient the stores are, I rank the states by the sum of revenue in descending order. I also include the brand_id to see how the three kinds of brands perform.
><pre>
>SELECT *, DENSE_RANK() OVER (ORDER BY revenue_sum DESC) as RANKINGS_REVENUE_BRAND
>FROM
>(SELECT SUBSTRING(store_location,15) as geo_s, 
>		brand_id, 
>         SUM(revenue) as revenue_sum
>FROM store_revenue
>GROUP BY geo_s, brand_id
>) AS cte;
* The third indicator that I use is the revenue for stores in each state.
#### [5] Question #5 (Challenge) Generate a query to rank in order the top 10 revenue producing states
​
Answer: 
* As usual, I create a temporary table to save the store_location and revenue of each store_location by a groupby command.
* Then, I use a DENSE_RANK command to rank the revenue produced by each state. The reason to use a DENSE_RANK command instead of a "LIMIT 10" command is to make the resulting table more readable.
* Last but not least, I select the rows from T2 with a where clause to include only the ones with rankings less than or equal to 10.
><pre>
>WITH T1 AS(
>SELECT store_location, SUM(revenue) as revenue_state
>FROM store_revenue 
>GROUP BY store_location   
>),
>T2 AS(
>SELECT SUBSTRING(store_location,15) as State, 
>        revenue_state as revenue,
>        DENSE_RANK() OVER (ORDER BY revenue_state DESC) as RANKINGS_REVENUE
>FROM T1)
>SELECT * FROM T2  
>WHERE RANKINGS_REVENUE<=10;
