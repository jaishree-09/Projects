-- -- Case Study 2: Investigating Metric Spike
-- You will be working with three tables:
-- •	users: Contains one row per user, with descriptive information about that user’s account.
-- •	events: Contains one row per event, where an event is an action that a user has taken (e.g., login, messaging, search).
-- •	emailevents: Contains events specific to the sending of emails.

show databases;
use project3;

DROP TABLE users;

#Table-1 users

create table users
(
user_id int ,
created_at varchar(100) ,
Company_id int,
language varchar(50),
activated_at varchar(20),
state varchar(50));

SHOW VARIABLES LIKE 'secure_file_priv';


LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/users.csv"
INTO TABLE USERS
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

select* from users ;
alter table users add column temp_created_at datetime;
update users set temp_created_at = str_to_date(created_at, '%d-%m-%Y %H:%i');
alter table users drop column created_at;
alter table users change column temp_created_at created_at datetime;


#Table-2 events

drop table  events;

create table events
(
user_id int ,
occurred_at varchar(100),
event_type varchar(50),
event_name varchar(100) ,
location varchar(50) ,
device varchar(50) ,
user_type int 
);



LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/events.csv"
INTO TABLE EVENTS
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

desc events;

select * from events;
alter table events add column temp_occurred_at datetime;
update events set temp_occurred_at = str_to_date(occurred_at,' %d-%m-%Y %H:%i');
alter table events drop column occurred_at;
alter table events change column temp_occurred_at occurred_at datetime;

-- #Table-3 email_events

drop table email_events

CREATE TABLE email_events (
    user_id INT,
    occurred_at VARCHAR(100),
    action VARCHAR(100),
    user_type INT
);


LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/email_events.csv"
INTO TABLE email_events
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

select * from email_events;

-- Tasks:
-- A.	Weekly User Engagement:
-- o	Objective: Measure the activeness of users on a weekly basis.
 -- o	Your Task: Write an SQL query to calculate the weekly user engagement.

select * from events;

select extract(week from occurred_at) as week ,
count(distinct user_id) as  User_count from events 
where event_type='engagement' 
group by week
order by user_count desc;

-- B.	User Growth Analysis:
-- Objective: Analyze the growth of users over time for a product.
-- Your Task: Write an SQL query to calculate the user growth for the product.

select * from users;

select 
year,users,round(((users/lag(users,1)over(order by year)-1)*100),2) as "growth in %"
from 
(
select extract(year from created_at) as year ,
count(activated_at) as users
from users
where activated_at not in ("")
group by 1
order by 1
 )sub;


-- C. Weekly Retention Analysis:
-- Objective: Analyze the retention of users on a weekly basis after signing up for a product.
-- Your Task: Write an SQL query to calculate the weekly retention of users based on their sign-up cohort.

select 
extract(week from occurred_at) as sign_up_week,count(distinct user_id) as 'count of users sign up'
from events
where event_type = 'signup_flow'
and event_name = 'complete_signup'
group by sign_up_week

-- D.	Weekly Engagement Per Device:
-- Objective: Measure the activeness of users on a weekly basis per device.
-- Your Task: Write an SQL query to calculate the weekly engagement per device.

SELECT 
    device AS DeviceName,
    YEAR(occurred_at) AS year,
    WEEK(occurred_at) AS week,
    COUNT(DISTINCT user_id) AS usercount
FROM
    `events`
WHERE
    event_type = 'engagement'
GROUP BY year , week , devicename
ORDER BY year , week , usercount DESC;

-- E.	Email Engagement Analysis:
-- Objective: Analyze how users are engaging with the email service.
-- Your Task: Write an SQL query to calculate the email engagement metrics.
-- Please note that for each task, you should also provide insights and interpretations of the results obtained from your queries.

 select user_id, emails_sent, emails_opened, emails_clicked,
  round(sum(emails_opened)/sum(emails_sent),2)*100 as open_rate,
  round(sum(emails_clicked)/sum(emails_opened),2)*100 as click_through_rate
 from (
     select user_id,
     sum(case when `action` = "sent_weekly_digest" then 1 else 0 end) as emails_sent,
     sum(case when `action` = "email_open" then 1 else 0 end) as emails_opened,
     sum(case when `action` = "email_clickthrough" then 1 else 0 end ) as emails_clicked
     from email_events
     group by user_id 
     ) as email_engagement
	 group by user_id;
