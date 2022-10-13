CREATE DATABASE PMG_TEST;                                # create the database for this project.
USE PMG_TEST;                                            # use the database and set the environment.

#——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
# Use the code from PMG READ_ME file to Create the two tables as required.
CREATE TABLE store_revenue (id int not null primary key auto_increment, 
							date datetime, 
                            brand_id int, 
                            store_location varchar(250), 
                            revenue float
);
CREATE TABLE marketing_data (id int not null primary key auto_increment, 
                             date datetime, 
                             geo varchar(2), 
                             impressions float, 
                             clicks float 
);
# Insert the values according to the two csv files provided.
INSERT INTO marketing_data (date,geo,impressions,clicks)
 VALUES 
 ("2016-01-01","TX","2532","45"),
("2016-01-01","CA","3425","63"),
("2016-01-01","NY","3532","25"),
("2016-01-01","MN","1342","784"),
("2016-01-02","TX","3643","23"),
("2016-01-02","CA","1354","53"),
("2016-01-02","NY","4643","85"),
("2016-01-02","MN","2366","85"),
("2016-01-03","TX","2353","57"),
("2016-01-03","CA","5258","36"),
("2016-01-03","NY","4735","63"),
("2016-01-03","MN","5783","87"),
("2016-01-04","TX","5783","47"),
("2016-01-04","CA","7854","85"),
("2016-01-04","NY","4754","36"),
("2016-01-04","MN","9345","24"),
("2016-01-05","TX","2535","63"),
("2016-01-05","CA","4678","73"),
("2016-01-05","NY","2364","33"),
("2016-01-05","MN","3452","25")
;
INSERT INTO store_revenue (date,brand_id,store_location,revenue)
VALUES
("2016-01-01","1","United States-CA","100"),
("2016-01-01","1","United States-TX","420"),
("2016-01-01","1","United States-NY","142"),
("2016-01-02","1","United States-CA","231"),
("2016-01-02","1","United States-TX","2342"),
("2016-01-02","1","United States-NY","232"),
("2016-01-03","1","United States-CA","100"),
("2016-01-03","1","United States-TX","420"),
("2016-01-03","1","United States-NY","3245"),
("2016-01-04","1","United States-CA","34"),
("2016-01-04","1","United States-TX","3"),
("2016-01-04","1","United States-NY","54"),
("2016-01-05","1","United States-CA","45"),
("2016-01-05","1","United States-TX","423"),
("2016-01-05","1","United States-NY","234"),
("2016-01-01","2","United States-CA","234"),
("2016-01-01","2","United States-TX","234"),
("2016-01-01","2","United States-NY","142"),
("2016-01-02","2","United States-CA","234"),
("2016-01-02","2","United States-TX","3423"),
("2016-01-02","2","United States-NY","2342"),
("2016-01-03","2","United States-CA","234234"),
("2016-01-06","3","United States-TX","3"),
("2016-01-03","2","United States-TX","3"),
("2016-01-03","2","United States-NY","234"),
("2016-01-04","2","United States-CA","2"),
("2016-01-04","2","United States-TX","2354"),
("2016-01-04","2","United States-NY","45235"),
("2016-01-05","2","United States-CA","23"),
("2016-01-05","2","United States-TX","4"),
("2016-01-05","2","United States-NY","124")
;

#————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
# Question #1 Generate a query to get the sum of the clicks of the marketing data​ 
SELECT SUM(clicks) as sum_clicks
FROM marketing_data;
# This is a straightforward case, simply use SUM function for the variable clicks in the marketing_data table.
#————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
# Question #2 Generate a query to gather the sum of revenue by geo from the store_revenue table​
SELECT SUBSTRING(store_location,15) as geo,                # Since the store_location column is in the format "United States—TX",
       SUM(revenue) as revenue_geo                         # I use the SUBSTRING(store_location) to drop the initial
FROM store_revenue                                         # "United States-" and only keep the state name.
GROUP BY store_location;
# This is also a straightforward case. Using a group by statement to generate the sum regarding each state.
#—————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
# Question #3 Merge these two datasets so we can see impressions, clicks, and revenue together by date and geo. 
# Please ensure all records from each table are accounted for.​
# Q 3.1 Version: USING UNION OF TWO LEFT JOIN TABLES
WITH T1 AS(                                # I create this temporary table T1 to select the four columns that I need from 
SELECT date,                               # the marketing_data table. Whether to add a group by command in T1 does not affect
       geo,                                # the output, but in order to make sure the result is consistent, I add the group by
	   clicks,                             # statement. 
       impressions
FROM marketing_data
GROUP BY date, geo
),
T2 AS(                                      # I create this temporary table T2 to select the four columns that I need from the 
SELECT date,                                # store_revenue table. By summing the revenue group by date and geo_location, I make
       SUBSTRING(store_location,15) as geo, # the table T2 into the same format with T1, which will make the proceeding LEFT JOIN
       SUM(revenue) as revenue              # and UNION easier.
FROM store_revenue                          
GROUP BY date, geo
)
SELECT T1.date, 
       T1.geo, 
       impressions, 
       clicks, 
       revenue
FROM T1 LEFT JOIN T2
ON T1.date=T2.date AND T1.geo=T2.geo
UNION
SELECT T2.date, 
       T2.geo, 
       impressions, 
       clicks, 
       revenue
FROM T2 LEFT JOIN T1
ON T2.date=T1.date AND T1.geo=T2.geo;
# The reason to use the UNION command is to combine two LEFT JOIN Tables. The LEFT JOIN command, if in the form A LEFT JOIN B, is 
# able to contain all the rows from the table A. So I union the table A (T1 LEFT JOIN T2) and the table B (T2 LEFT JOIN T1) to make
# sure I have captured all the rows in the two tables: T1, T2. 
#——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
# Q 3.2 Version: USING UNION OF Two Tables including the brand_id
WITH T1 AS(
SELECT date,                                               # Follow the same logic with T1 above.
	   geo, 
       clicks, 
       impressions
FROM marketing_data
GROUP BY date, geo
),
T2 AS(                                                     # Since in this version, I decide to include the brand_id column from the 
SELECT date,                                               # store_revenue table. Right now, the revenue term refers to the amount of
	   SUBSTRING(store_location,15) as geo,                # revenue by each state on each day, with brand_id=1 OR brand_id=2.
       brand_id,
       revenue
FROM store_revenue
GROUP BY date, geo, brand_id
)
SELECT T1.date as date,                                    # The UNION part is the same as the previous method.
	   T1.geo as geo, 
       impressions as impressions_statewise, 
       clicks as clicks_statewise, 
       brand_id,
       revenue
FROM T1 LEFT JOIN T2
ON T1.date=T2.date AND T1.geo=T2.geo
UNION
SELECT T2.date as date, 
	   T2.geo as geo, 
       impressions as impressions_statewise, 
       clicks as clicks_statewise,
       brand_id,
       revenue
FROM T2 LEFT JOIN T1
ON T2.date=T1.date AND T1.geo=T2.geo;
# One thing to notice is that in the resulting table, for each date and geo, there would be two rows sharing the same number of
# impressions and clicks. The only difference between the two rows is the revenue by different brand_ids. That is because in the 
# marketing_data table, there are no columns named brand_id and I can not identify the specific amount of impressions and clicks
# for each brand. As a result, I change the name for the impressions and clicks to impressions_statewise and clicks_statewise so that
# the readers can understand.
#——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
# Q 3.3 Version: USING FULL JOIN——>Only contain Non-NULL rows.
# Since I use mysql to finish this assessment, there does not exist a FULL OUTER JOIN command.
# The FULL JOIN command only produces the rows that satisfy the ON conditions with non-NULL entries.
WITH T1 AS(
SELECT date as date_m,                                   # Same as Q 3.1 above, I select the four columns needed for the FULL JOIN. 
	   geo as geo_m, 
       clicks, 
       impressions
FROM marketing_data
GROUP BY date, geo
),
T2 AS(                                                   # Same as Q 3.1 above, I select the three required columns for the FUll JOIN.              
SELECT date as date_s, 
       SUBSTRING(store_location,15) as geo_s, 
       SUM(revenue) as revenue
FROM store_revenue
GROUP BY date_s, geo_s
)
SELECT date_m as date, 
       geo_m as geo, 
       impressions, 
       clicks, 
       revenue
FROM T1 FULL JOIN T2
ON date_m=date_s AND geo_m=geo_s;
# The FULL JOIN command can not contain all the records from both tables. But I need this resulting table for the Question 4.
#——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
# Question #4 In your opinion, what is the most efficient store and why?
# I create three different indicators for measuring the effiency of the stores for each state.​
# Q 4.1.1 Version: First ratio——> Impressions_clicks ratio, for each state only
WITH T1 AS(                                             # As before, I create a temporary table storing the sum of impressions and 
SELECT geo,                                             # clicks for each state during the total time periods provided in the
	   SUM(impressions) as impressions_sum,             # marketing_data table.
       SUM(clicks) as clicks_sum
FROM marketing_data
GROUP BY geo
) 
SELECT geo,                                             # Beisdes the impressions and clicks terms, I create another column defined 
	   impressions_sum,                                 # as the IC_ratio, which is defined as the percentage of clicks from the 
       clicks_sum,                                      # impressions.
       ROUND(100*clicks_sum/impressions_sum,2) as IC_ratio,
       DENSE_RANK() OVER (ORDER BY clicks_sum/impressions_sum DESC) as rankings_IC_rate
FROM T1;
# With Higher IC_ratio, stores in that state have more clicks from the impressions, so using order by ratio DESC is a good choice.
#——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
# Q 4.1.2 Version: First ratio——> Impressions_clicks ratio, for each state and date
# Following a similar structure with Q 4.1.1, I have measured the same IC rate, but the ratio right now is based on each state
# and each date. The inclusion of the date column is to see whether for each state, does its stores' ratio vary much among the five
# day interval?
SELECT date,
       geo,
       impressions_sum,
       clicks_sum,
       ROUND(100*clicks_sum/impressions_sum,2) as IC_ratio_sd,
       DENSE_RANK() OVER (ORDER BY clicks_sum/impressions_sum DESC) as rankings_IC_rate_sd
FROM
(SELECT date,
       geo,
       SUM(impressions) as impressions_sum,
       SUM(clicks) as clicks_sum
FROM marketing_data
GROUP BY geo,date) as cte;
#——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
# The second indicator that I use to measure the efficiency is the CR ratio, which is defined as the sum of revenue divided by the sum
# of clicks. This ratio measures how much addtional revenue with one addtional click the stores in the state have.
# Q 4.2.1 Version: CR_Rate by each state
WITH T1 AS(
SELECT date as date_m, 
	   geo as geo_m, 
       SUM(clicks) as clicks
FROM marketing_data
GROUP BY date_m,geo_m
),
T2 AS(
SELECT date as date_s, 
	   SUBSTRING(store_location,15) as geo_s,                 # Here, the three temporary tables, although look complicated, are the 
       SUM(revenue) as revenue                                # tables that I create use FULL JOIN in Question 3.3. Since this ratio
FROM store_revenue                                            # requires the revenue column from the store_revenue table and 
GROUP BY date, geo_s                                          # the clicks column from the marketing_data table, I need the merging
),                                                            # table to contain all the non-NULL values.
T3 AS(
SELECT geo_m as geo,                                       
       SUM(clicks) as clicks_sum, 
       SUM(revenue) as revenue_sum
FROM T1 FULL JOIN T2
ON date_m=date_s AND geo_m=geo_s
GROUP BY geo
)
SELECT geo,                                                   # This part is similar to the Q 4.2.1 Version.
       clicks_sum, 
       revenue_sum,
	   ROUND(revenue_sum/clicks_sum,5) as cr_transition_rate,
       DENSE_RANK() OVER (ORDER BY revenue_sum/clicks_sum DESC) as RANKINGS_CR
FROM T3;
# Again, with higher RC_ratio, the stores in that state is more efficient becasue it can generate more revenue given the same level of 
# clicks. That is the reason why I create the rankings of the stores in each state by descending RC_rate.
#——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
# Similar to Q 4.1.2, I release the date as another column.
# Q 4.2.2 Version: CR_Rate by each state and each date
WITH T1 AS(
SELECT date as date_m,                                        # Similar to the Question 4.2.1, using the FULL JOIN to catch all
	   geo as geo_m,                                          # the rows with non-NULL values.
       SUM(clicks) as clicks
FROM marketing_data
GROUP BY date_m,geo_m
),
T2 AS(
SELECT date as date_s, 
       SUBSTRING(store_location,15) as geo_s, 
       SUM(revenue) as revenue
FROM store_revenue
GROUP BY date, geo_s
),
T3 AS(
SELECT geo_m as geo, 
       date_m as date,
       clicks as clicks_sum, 
       revenue as revenue_sum
FROM T1 FULL JOIN T2
ON date_m=date_s AND geo_m=geo_s
)
SELECT geo, 
       date, 
       clicks_sum, 
       revenue_sum,
	   ROUND(revenue_sum/clicks_sum,5) as cr_transition_rate_sd,
       DENSE_RANK() OVER (ORDER BY revenue_sum/clicks_sum DESC) as RANKINGS_CR_sd
FROM T3;
# Also, similar to the part of Q 4.2.1
#——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
# The third indicator that I use is the revenue for stores in each state.
# Q 4.3 Version: Revenue Based Ranking WITH BRAND_ID Included
# The part of ranking the revenue alone will be covered in Question 5.
SELECT *, DENSE_RANK() OVER (ORDER BY revenue_sum DESC) as RANKINGS_REVENUE_BRAND
FROM
(SELECT SUBSTRING(store_location,15) as geo_s, 
		brand_id, 
        SUM(revenue) as revenue_sum
FROM store_revenue
GROUP BY geo_s, brand_id
) AS cte;
# Since under this indicatory, the higher the revenue, the more efficient the stores are, I rank the states by the sum of revenue
# in descending order. I also include the brand_id to see how the three kinds of brands perform.
#——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
# Question #5 (Challenge) Generate a query to rank in order the top 10 revenue producing states
WITH T1 AS(
SELECT store_location, SUM(revenue) as revenue_state                     # As usual, I create a temporary table to save the 
FROM store_revenue                                                       # store_location and revenue of each store_location
GROUP BY store_location                                                  # by a groupby command.  
),
T2 AS(
SELECT SUBSTRING(store_location,15) as State, 
       revenue_state as revenue, 
       DENSE_RANK() OVER (ORDER BY revenue_state DESC) as RANKINGS_REVENUE # Then, I use a DENSE_RANK command to rank the revenue
FROM T1)                                                                   # produced by each state. The reason to use a DENSE_RANK
SELECT * FROM T2                                                           # command instead of a "LIMIT 10" command is to make the
WHERE RANKINGS_REVENUE<=10;                                                # resulting table more readable.
# Last but not least, I select the rows from T2 with a where clause to include only the ones with rankings less than or equal to 10.



