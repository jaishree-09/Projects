create database project3;
 drop table job_data;
 
use project3;

create table job_data
(
ds date,
job_id int not null,
actor_id int,
event varchar(20) not null,
language varchar(20),
time_spent int not null,
org char
);


select* from job_data;


insert into job_data (ds,job_id ,actor_id,event,language ,time_spent ,org)
values('20-11-30',21,1001,'skip','English',15,'A'),
('20-11-30',22,1006,'transfer','Arabic',25,'B'),
('20-11-29',23,1003,'decision','Persian',20,'C'),
('20-11-28',23,1005,'transfer','Persian',22,'D'),
('20-11-28',25,1002,'decision','Hindi',11,'B'),
('20-11-27',11,1007,'decision','French',104,'D'),
('20-11-26',23,1004,'skip','Persian',56,'A'),
('20-11-25',20,1003,'transfer','Italian',45,'C');



-- Tasks
-- A.	Jobs Reviewed Over Time:
-- Objective: Calculate the number of jobs reviewed per hour for each day in November 2020.
-- Your Task: Write an SQL query to calculate the number of jobs reviewed per hour for each day in November 2020.

select * from job_data;

select day(ds) as `Date`,
round(count(*) / (sum(time_spent) / 3600),0) as `Jobs_Reviewed_Per_Hour`
from job_data
where
ds between '2020-11-01' and '2020-11-30'
group by `Date`;




-- B.	Throughput Analysis:
-- o	Objective: Calculate the 7-day rolling average of throughput (number of events per second).
-- o	Your Task: Write an SQL query to calculate the 7-day rolling average of throughput. Additionally, 
-- explain whether you prefer using the daily metric or the 7-day rolling average for throughput, and why.

select ds, jobs_reviewed,
avg(jobs_reviewed)over(order by ds rows between 6 preceding and current row)
as throughput_7_rolling_avg
from
(
select ds, count(distinct job_id) as jobs_reviewed
From job_data
where ds between '2020-11-01' and '2020-11-30'
group by ds
order by ds
)a;

WITH daily_throughput AS (
		SELECT ds, COUNT(*)/SUM(time_spent) AS throughput
		FROM job_data
		GROUP BY ds
        )
        
SELECT ds,
	ROUND(AVG(throughput) OVER(ORDER BY ds ROWS BETWEEN 6 PRECEDING AND CURRENT ROW),3) AS 7_day_throughput_rolling_average
FROM daily_throughput;



-- C.	Language Share Analysis:
-- Objective: Calculate the percentage share of each language in the last 30 days.
-- 	Your Task: Write an SQL query to calculate the percentage share of each language over the last 30 days.

select language, num_jobs,
100.0* num_jobs/total_jobs as pct_share_jobs
from
(
select language, count(distinct job_id) as num_jobs
from job_data
group by language
)a
cross join
(
select count(distinct job_id) as total_jobs
from job_data
)b; 

select
 language ,
 CONCAT(ROUND((count(*)/30)*100,2),"%") as percentage_share
from job_data
group by 1 ;



-- 	Duplicate Rows Detection:
-- Objective: Identify duplicate rows in the data.
-- Your Task: Write an SQL query to display duplicate rows from the job_data table.

select * from
(
select *,
row_number()over(partition by job_id) as rownum
from job_data
)a
where rownum>1;

select actor_id,count(*) as duplicates from job_data
group by actor_id 
having count(*)>1;


