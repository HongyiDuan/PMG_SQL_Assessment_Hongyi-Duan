# SQL Challenge: Answered by Hongyi Duan

## Below are my SQL statements for each question. 
## Note 1: All the statements below are written in mysql environment.
## Note 2: For each question, I have attached not only my statements but also the output tables belows. As for the specific output table, you can find that in the csv files in this repository.
## Note 3: Each bullet point in my answer explains the logic of my statement,limitations of the statements, and the explanation of the output
### [1] Question #1 Generate a query to get the sum of the clicks of the marketing data
​ 
Answer: It is a very straightforward case. I simply use SUM command for the variable clicks in the marketing_data table.
> <pre>
> SELECT SUM(clicks) as sum_clicks
> FROM marketing_data;
### Result:
| sum_clicks |
| ---------- |
| 1792       |


### [2]  Question #2 Generate a query to gather the sum of revenue by geo from the store_revenue table
​
Answer: This is also a straightforward case. Using a group by statement to generate the sum regarding each state.
> <pre>
> SELECT SUBSTRING(store_location,15) as geo,
>        SUM(revenue) as revenue_geo
> FROM store_revenue
> GROUP BY store_location;

I use the SUBSTRING command to extract only the state name from the column store_location so that it matches the geo variable form in the marketing_data table. <br/> 
### Result:
| geo	| revenue_geo |
| ----|------------ |
| CA	| 235237      |
| TX	| 9629        |
| NY	| 51984       |


### [3]  Question #3 Merge these two datasets so we can see impressions, clicks, and revenue together by date and geo. Please ensure all records from each table are accounted for.
​
Answer: As mentioned at the beginning, I write my commands in MySQL environment. Since MySQL does not have a FULL OUTER JOIN command, I mainly use the UNION of two LEFT JOIN tables to cover all the observations from the two table. I have used three methods for answering Question 3, with the initial two to be the UNION of two LEFT JOIN tables and the last to be the FULL JOIN method.
#### Q 3.1 Version: Using UNION of two LEFT JOIN tables
* Here is the first method of UNION two LEFT JOIN tables T1 and T2. 
* I create T1 to select the four columns that I need from the marketing_data table. Although whether adding the group by statement for T1 or not does not affect the outcome table, I still choose to add it to make sure that if future data comes in with the same date and state, I am able to absorb the observation in the sum.
* T2 is used to select the date, geo, and the sum of revenue group by date and geo (combing the revenue of all the brands sold on a specific day at a specific state).
><pre>
> WITH T1 AS(
> SELECT date,
>        geo,
>        clicks,
>        impressions
> FROM marketing_data
> GROUP BY date, geo
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
* The reason to use the UNION command is to combine two LEFT JOIN Tables. The LEFT JOIN command, if in the form A LEFT JOIN B, is  able to capture all the rows from  table A. 
* So I union the table A (T1 LEFT JOIN T2) and the table B (T2 LEFT JOIN T1) to make sure I have got all the rows from the two tables: T1, T2 in my final results.
* That is the reason why in the resulting table, we can see 4 different states and 6 different dates.
### Result:
| date	        |geo |impressions	|clicks	   |     revenue |
| --------------|----|------------|----------|------------------ |
| 1/1/2016 0:00	|TX	 |2532	      |  45	     |   654            |
| 1/1/2016 0:00	|CA	 |3425	      |  63	     |   334            |
| 1/1/2016 0:00	|NY	 |3532	      |  25	     |   284            |
| 1/1/2016 0:00	|MN	 |1342	      | 784	     |   NULL           |
| 1/2/2016 0:00	|TX	 |3643	      |  23	     |  5765           |
| 1/2/2016 0:00	|CA	 |1354	      |  53	     |   465            |
| 1/2/2016 0:00	|NY	 |4643	      |  85	     |   2574           |
| 1/2/2016 0:00	|MN	 |2366	      |  85	     |   NULL           |
| 1/3/2016 0:00	|TX	 |2353	      |  57	     |   423            |
| 1/3/2016 0:00	|CA	 |5258	      |  36	     |   234334         |
| 1/3/2016 0:00	|NY	 |4735	      |  63	     |   3479           |
| 1/3/2016 0:00	|MN	 |5783	      |  87	     |   NULL           |
| 1/4/2016 0:00	|TX	 |5783	      |  47	     |   2357           |
| 1/4/2016 0:00	|CA	 |7854	      |  85	     |   36             |
| 1/4/2016 0:00	|NY	 |4754	      |  36	     |   45289          |
| 1/4/2016 0:00	|MN	 |9345	      |  24	     |   NULL           |
| 1/5/2016 0:00	|TX	 |2535	      |  63	     |   427            |
| 1/5/2016 0:00	|CA	 |4678	      |  73	     |   68             |
| 1/5/2016 0:00	|NY	 |2364	      |  33	     |   358            |
| 1/5/2016 0:00	|MN	 |3452	      |  25	     |   NULL           |
| 1/6/2016 0:00	|TX	 |NULL	      |  NULL	   |     3            |
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
>GROUP BY date,geo
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

* One thing to notice is that in the resulting table, for each date and geo, there would be two rows sharing the same number of impressions and clicks.
* The only difference between the two rows is the revenue by different brand_ids. That is because in the marketing_data table, there are no columns named brand_id and I can not identify the specific amount of impressions and clicks for each brand. 
* As a result, I change the name for the impressions and clicks to impressions_statewise and clicks_statewise so that the reader can understand.
### Result:
| date          | 	geo | 	impressions_statewise | 	clicks_statewise | 	brand_id|	revenue |
| ------------- | ---- | ---------------------- | ----------------- | ----------------- | ------- |
| 1/1/2016 0:00 | 	TX  | 	2532                  | 	45               | 	1                | 	420    |
| 1/1/2016 0:00 | 	TX  | 	2532                  | 	45               | 	2                | 	234    |
| 1/1/2016 0:00 | 	CA  | 	3425                  | 	63               | 	1                | 	100    |
| 1/1/2016 0:00 | 	CA  | 	3425                  | 	63               | 	2                | 	234    |
| 1/1/2016 0:00 | 	NY  | 	3532                  | 	25               | 	1                | 	142    |
| 1/1/2016 0:00 | 	NY  | 	3532                  | 	25               | 	2                | 	142    |
| 1/1/2016 0:00 | 	MN  | 	1342                  | 	784              | 	NULL             | 	NULL   |
| 1/2/2016 0:00 | 	TX  | 	3643                  | 	23               | 	1                | 	2342   |
| 1/2/2016 0:00 | 	TX  | 	3643                  | 	23               | 	2                | 	3423   |
| 1/2/2016 0:00 | 	CA  | 	1354                  | 	53               | 	1                | 	231    |
| 1/2/2016 0:00 | 	CA  | 	1354                  | 	53               | 	2                | 	234    |
| 1/2/2016 0:00 | 	NY  | 	4643                  | 	85               | 	1                | 	232    |
| 1/2/2016 0:00 | 	NY  | 	4643                  | 	85               | 	2                | 	2342   |
| 1/2/2016 0:00 | 	MN  | 	2366                  | 	85               | 	NULL             | 	NULL   |
| 1/3/2016 0:00 | 	TX  | 	2353                  | 	57               | 	1                | 	420    |
| 1/3/2016 0:00 | 	TX  | 	2353                  | 	57               | 	2                | 	3      |
| 1/3/2016 0:00 | 	CA  | 	5258                  | 	36               | 	1                | 	100    |
| 1/3/2016 0:00 | 	CA  | 	5258                  | 	36               | 	2                | 	234234 |
| 1/3/2016 0:00 | 	NY  | 	4735                  | 	63               | 	1                | 	3245   |
| 1/3/2016 0:00 | 	NY  | 	4735                  | 	63               | 	2                | 	234    |
| 1/3/2016 0:00 | 	MN  | 	5783                  | 	87               | 	NULL             | 	NULL   |
| 1/4/2016 0:00 | 	TX  | 	5783                  | 	47               | 	1                | 	3      |
| 1/4/2016 0:00 | 	TX  | 	5783                  | 	47               | 	2                | 	2354   |
| 1/4/2016 0:00 | 	CA  | 	7854                  | 	85               | 	1                | 	34     |
| 1/4/2016 0:00 | 	CA  | 	7854                  | 	85               | 	2                | 	2      |
| 1/4/2016 0:00 | 	NY  | 	4754                  | 	36               | 	1                | 	54     |
| 1/4/2016 0:00 | 	NY  | 	4754                  | 	36               | 	2                | 	45235  |
| 1/4/2016 0:00 | 	MN  | 	9345                  | 	24               | 	NULL             | 	NULL   |
| 1/5/2016 0:00 | 	TX  | 	2535                  | 	63               | 	1                | 	423    |
| 1/5/2016 0:00 | 	TX  | 	2535                  | 	63               | 	2                | 	4      |
| 1/5/2016 0:00 | 	CA  | 	4678                  | 	73               | 	1                | 	45     |
| 1/5/2016 0:00 | 	CA  | 	4678                  | 	73               | 	2                | 	23     |
| 1/5/2016 0:00 | 	NY  | 	2364                  | 	33               | 	1                | 	234    |
| 1/5/2016 0:00 | 	NY  | 	2364                  | 	33               | 	2                | 	124    |
| 1/5/2016 0:00 | 	MN  | 	3452                  | 	25               | 	NULL             | 	NULL   |
| 1/6/2016 0:00 | 	TX  | 	NULL                  | 	NULL             | 	3                | 	3      |
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
>GROUP BY date,geo
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

### Result:
| date          | 	geo | 	impressions | 	clicks | 	revenue |
| ------------- | ---- | ------------ | ------- | -------- |  
| 1/1/2016 0:00 | 	TX  | 	2532        | 	45     | 	654     |  
| 1/1/2016 0:00 | 	CA  | 	3425        | 	63     | 	334     |  
| 1/1/2016 0:00 | 	NY  | 	3532        | 	25     | 	284     |  
| 1/2/2016 0:00 | 	TX  | 	3643        | 	23     | 	5765    |  
| 1/2/2016 0:00 | 	CA  | 	1354        | 	53     | 	465     |  
| 1/2/2016 0:00 | 	NY  | 	4643        | 	85     | 	2574    |  
| 1/3/2016 0:00 | 	TX  | 	2353        | 	57     | 	423     |  
| 1/3/2016 0:00 | 	CA  | 	5258        | 	36     | 	234334  |  
| 1/3/2016 0:00 | 	NY  | 	4735        | 	63     | 	3479    |  
| 1/4/2016 0:00 | 	TX  | 	5783        | 	47     | 	2357    |  
| 1/4/2016 0:00 | 	CA  | 	7854        | 	85     | 	36      |  
| 1/4/2016 0:00 | 	NY  | 	4754        | 	36     | 	45289   |  
| 1/5/2016 0:00 | 	TX  | 	2535        | 	63     | 	427     |  
| 1/5/2016 0:00 | 	CA  | 	4678        | 	73     | 	68      |  
| 1/5/2016 0:00 | 	NY  | 	2364        | 	33     | 	358     |  
### [4]  Question #4 In your opinion, what is the most efficient store and why?
​
Answer: For this open-end question, I create three different indicators for measuring the effiency of the stores for each state. For each of the indicator, I will explain the definition and corresponding explanation of logics behind it.
### An important assumption that I make for this question is that since the store_revenue does not contain a column named store_id, I measure all three indicators on the state level. Then, my effciency in this problem would be "the efficiency of all the stores in each state". 
### If I assume the id column in the store_revenue table to be the store_id, then the outcome would offer no use since each store can only offer their performance at a specific date instead of during a period.
#### Q 4.1.1 Version: First indicator——> Impressions_clicks ratio, for each state only
* IC_ratio (Impressions_clicks ratio) is defined as the percentage of people clicks after watching the advertisements of the stores (impressions).
* Thus, by definition, a higher Impressions_clicks ratio reflects a higher effiency since more clicks the stores would earn for each advertisement they post or some other marketing methods.
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
>        ROUND(100*clicks_sum/impressions_sum,2) as IC_ratio,
>        DENSE_RANK() OVER (ORDER BY clicks_sum/impressions_sum DESC) as rankings_IC_rate
>FROM T1;

### Result:
| geo | 	impressions_sum | 	clicks_sum | 	IC_ratio | 	rankings_IC_rate |
| --- | ---------------- | ----------- | --------- | ----------------- |
| MN  | 	22288           | 	1005       | 	4.51     | 	1                |
| TX  | 	16846           | 	235        | 	1.39     | 	2                |
| CA  | 	22569           | 	310        | 	1.37     | 	3                |
| NY  | 	20028           | 	242        | 	1.21     | 	4                |

#### Q 4.1.2 Version: First indicator, different scenario——> Impressions/clicks ratio, for each state and date
* Following a similar structure with Q 4.1.1, I have measured the same IC ratio, but the ratio right now is based on each state and each date.
* The reason to include the date variable is to see the "fluctuations" of the IC ratio among the 5 day interval. Is it stable for each state or a state would have a very high IC ratio for one day and lower ones for the remaining.
* I also rename the column to make them consistant with other codes in Question 4.
><pre>
>SELECT date,
>       geo,
>       impressions_sum,
>       clicks_sum,
>       ROUND(100*clicks_sum/impressions_sum,2) as IC_ratio_sd,
>       DENSE_RANK() OVER (ORDER BY clicks_sum/impressions_sum DESC) as rankings_IC_rate_sd
>FROM
>(SELECT date,
>       geo,
>       SUM(impressions) as impressions_sum,
>      SUM(clicks) as clicks_sum
>FROM marketing_data
>GROUP BY geo,date) as cte;
### Result:
| date          | 	geo | 	impressions_sum | 	clicks_sum | 	IC_ratio_sd | 	rankings_IC_rate_sd |
| ------------- | ---- | ---------------- | ----------- | ------------ | -------------------- |
| 1/1/2016 0:00 | 	MN  | 	1342            | 	784        | 	58.42       | 	1                   |
| 1/2/2016 0:00 | 	CA  | 	1354            | 	53         | 	3.91        | 	2                   |
| 1/2/2016 0:00 | 	MN  | 	2366            | 	85         | 	3.59        | 	3                   |
| 1/5/2016 0:00 | 	TX  | 	2535            | 	63         | 	2.49        | 	4                   |
| 1/3/2016 0:00 | 	TX  | 	2353            | 	57         | 	2.42        | 	5                   |
| 1/1/2016 0:00 | 	CA  | 	3425            | 	63         | 	1.84        | 	6                   |
| 1/2/2016 0:00 | 	NY  | 	4643            | 	85         | 	1.83        | 	7                   |
| 1/1/2016 0:00 | 	TX  | 	2532            | 	45         | 	1.78        | 	8                   |
| 1/5/2016 0:00 | 	CA  | 	4678            | 	73         | 	1.56        | 	9                   |
| 1/3/2016 0:00 | 	MN  | 	5783            | 	87         | 	1.5         | 	10                  |
| 1/5/2016 0:00 | 	NY  | 	2364            | 	33         | 	1.4         | 	11                  |
| 1/3/2016 0:00 | 	NY  | 	4735            | 	63         | 	1.33        | 	12                  |
| 1/4/2016 0:00 | 	CA  | 	7854            | 	85         | 	1.08        | 	13                  |
| 1/4/2016 0:00 | 	TX  | 	5783            | 	47         | 	0.81        | 	14                  |
| 1/4/2016 0:00 | 	NY  | 	4754            | 	36         | 	0.76        | 	15                  |
| 1/5/2016 0:00 | 	MN  | 	3452            | 	25         | 	0.72        | 	16                  |
| 1/1/2016 0:00 | 	NY  | 	3532            | 	25         | 	0.71        | 	17                  |
| 1/3/2016 0:00 | 	CA  | 	5258            | 	36         | 	0.68        | 	18                  |
| 1/2/2016 0:00 | 	TX  | 	3643            | 	23         | 	0.63        | 	19                  |
| 1/4/2016 0:00 | 	MN  | 	9345            | 	24         | 	0.26        | 	20                  |

#### Q 4.2.1 Version: CR_Rate by each state
* The second indicator that I use to measure the efficiency is the CR ratio, which is defined as the sum of revenue divided by the sum
of clicks for each state. 
* This ratio measures how much addtional revenue one can get with an addtional click on average.
* Same as above, with higher RC_ratio, the stores in that state is more efficient becasue it would take clicks to generate more revenue. That is the reason why I create the rankings of the stores in each state by descending RC_rate.
* Also, another important assumption that I make for this indicator is that in the Question 3, we can find there exist mismatch between marketing_data table and store_revenue table. I simply keep the rows of the merging result with non-NULL values instead of including the NULL values inside. Since CR ratio is a fraction, NULL value on the denominator is hard to deal with.
><pre>
>WITH T1 AS(
>SELECT date as date_m, 
>	     geo as geo_m, 
>        clicks
>FROM marketing_data
>GROUP BY date_m,geo_m
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
>FROM T1 FULL JOIN T2
>ON date_m=date_s AND geo_m=geo_s
>GROUP BY geo
>)
>SELECT geo, 
>        cicks_sum,
>        revenue_sum,
>        ROUND(revenue_sum/clicks_sum,5) as cr_transition_rate,
>        DENSE_RANK() OVER (ORDER BY revenue_sum/clicks_sum DESC) as RANKINGS_CR
>FROM T3;

Here, the three temporary tables, although look complicated, are the tables that I create use FULL JOIN in Question 3.3. Since this ratio requires the revenue column from the store_revenue table and the clicks column from the marketing_data table, I need the merging table to contain all the non-NULL values.
### Result:
| geo | 	clicks_sum | 	revenue_sum | 	cr_transition_rate | 	RANKINGS_CR |
| --- | ----------- | ------------ | ------------------- | ------------ |
| CA  | 	310        | 	235237      | 	758.82903          | 	1           |
| NY  | 	242        | 	51984       | 	214.80992          | 	2           |
| TX  | 	235        | 	9626        | 	40.9617            | 	        3   |
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
>	     ROUND(revenue_sum/click_sum,5) as cr_transition_rate_sd,
>        DENSE_RANK() OVER (ORDER BY revenue_sum/click_sum DESC) as RANKINGS_CR_sd
>FROM T3;
### Result:
| geo | 	date          | 	clicks_sum | 	revenue_sum | 	cr_transition_rate_sd | 	RANKINGS_CR_sd |
| --- | -------------- | ----------- | ------------ | ---------------------- | --------------- |
| CA  | 	1/3/2016 0:00 | 	36         | 	234334      | 	6509.27778            | 	1              |
| NY  | 	1/4/2016 0:00 | 	36         | 	45289       | 	1258.02778            | 	2              |
| TX  | 	1/2/2016 0:00 | 	23         | 	5765        | 	250.65217             | 	3              |
| NY  | 	1/3/2016 0:00 | 	63         | 	3479        | 	55.22222              | 	4              |
| TX  | 	1/4/2016 0:00 | 	47         | 	2357        | 	50.14894              | 	5              |
| NY  | 	1/2/2016 0:00 | 	85         | 	2574        | 	30.28235              | 	6              |
| TX  | 	1/1/2016 0:00 | 	45         | 	654         | 	14.53333              | 	7              |
| NY  | 	1/1/2016 0:00 | 	25         | 	284         | 	11.36                 | 	8              |
| NY  | 	1/5/2016 0:00 | 	33         | 	358         | 	10.84848              | 	9              |
| CA  | 	1/2/2016 0:00 | 	53         | 	465         | 	8.77358               | 	10             |
| TX  | 	1/3/2016 0:00 | 	57         | 	423         | 	7.42105               | 	11             |
| TX  | 	1/5/2016 0:00 | 	63         | 	427         | 	6.77778               | 	12             |
| CA  | 	1/1/2016 0:00 | 	63         | 	334         | 	5.30159               | 	13             |
| CA  | 	1/5/2016 0:00 | 	73         | 	68          | 	0.93151               | 	14             |
| CA  | 	1/4/2016 0:00 | 	85         | 	36          | 	0.42353               | 	15             |
#### Q 4.3 Version: Revenue Based Ranking WITH BRAND_ID Included
* The third indicator that I use is the revenue for stores in each state.
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
### Result:
| geo_s | 	brand_id | 	revenue_sum | 	RANKINGS_REVENUE_BRAND |
| ----- | --------- | ------------ | ----------------------- |
| CA    | 	2        | 	234727      | 	1                      |
| NY    | 	2        | 	48077       | 	2                      |
| TX    | 	2        | 	6018        | 	3                      |
| NY    | 	1        | 	3907        | 	4                      |
| TX    | 	1        | 	3608        | 	5                      |
| CA    | 	1        | 	510         | 	6                      |
| TX    | 	3        | 	3           | 	7                      |

### Conclusion For Question 4:
* From the three indicators, we can see that stores in MN have the highest IC rate, and stores in CA have the lowest RC rate and highest revenue (from the output of question 5).
* Stores in MN are the most efficient in transforming impressions into clicks, while stores in CA are most efficient in transforming clicks into revenue and also the state with highest revenue.
* However, the time period of this dataset is too small to exclude some potential bias such as New Year Activities. Also, we can see from Q 4.1.2 and Q 4.2.2, the performance of some states, like CA, are not stable over time. CA is both the highest and the lowest of the RC rate.
* Last but not least, RC rate is limited because it only connects the clicks with the revenue without considering other possible factors on revenue.
* In conclustion, I think the first indicator is the best, leading to the most effcient ones to be the stores in the MN. But it might change after we can have a longer time period and revenue data for the stores in MN.
### [5] Question #5 (Challenge) Generate a query to rank in order the top 10 revenue producing states
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
### Result:
| State | 	revenue | 	RANKINGS_REVENUE |
| ----- | -------- | ----------------- |
| CA    | 	235237  | 	1                |
| NY    | 	51984   | 	2                |
| TX    | 	9629    | 	3                |



