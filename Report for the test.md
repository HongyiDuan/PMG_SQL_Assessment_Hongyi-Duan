# SQL Challenge

## Below are my SQL statements for each question. 
## Note: All the statements below are written in mysql environment.
### [1] Question #1 Generate a query to get the sum of the clicks of the marketing data
​ 
Answer: It is a very straightforward case. I simply use SUM command for the variable clicks in the marketing_data table.
> SELECT SUM(clicks) as sum_clicks <br/>
> FROM marketing_data;
### [2]  Question #2 Generate a query to gather the sum of revenue by geo from the store_revenue table
​
Answer: This is also a straightforward case. Using a group by statement to generate the sum regarding each state.
> SELECT SUBSTRING(store_location,15) as geo, <br/>
>        SUM(revenue) as revenue_geo <br/>
> FROM store_revenue <br/>
> GROUP BY store_location;<br/>  
*  Question #3
 Merge these two datasets so we can see impressions, clicks, and revenue together by date
and geo.
 Please ensure all records from each table are accounted for.
​
* Question #4
 In your opinion, what is the most efficient store and why?
​
* Question #5 (Challenge)
 Generate a query to rank in order the top 10 revenue producing states
​
