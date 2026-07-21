/*
===============================================================================
Part 1: Customer Churn Analysis Table Creation

Description:
Create the telecom customer table for customer churn analysis.

===============================================================================
*/

CREATE TABLE telecom_churn (
customer_id BIGINT PRIMARY KEY,
telecom_partner VARCHAR(50),
gender VARCHAR(10),
age INT,
state VARCHAR(100),
city VARCHAR(100),
pincode VARCHAR(10),
date_of_registration DATE,
num_dependents INT,
estimated_salary NUMERIC(12,2),
calls_made INT,
sms_sent INT,
data_used NUMERIC(10,2),
churn BOOLEAN
);




/*
===============================================================================
Part 2 : Data Cleaning

Objective:
Identify and resolve data quality issues by checking for missing
values, duplicate records, invalid data, inconsistent text values,
outliers and business rule violations to prepare a clean dataset
for reliable analysis.

===============================================================================
*/

--===============================================================================
-- 1. Dataset overview
--===============================================================================


select *
from telecom_churn
limit 10;
select count(*) as total_records
from telecom_churn;

-- 2. Data type validation

select column_name, data_type
from information_schema.columns
where table_name = 'telecom_churn';


-- 3. Duplicate customer id check

select customer_id,
count(*) as duplicate_count
from telecom_churn
group by customer_id
having count(*) > 1;


-- 4. Duplicate row check

select customer_id, telecom_partner, gender,
age, state, city, pincode, date_of_registration,
num_dependents, estimated_salary, calls_made,
sms_sent, data_used, churn,
count(*) as duplicate_count
from telecom_churn
group by customer_id, telecom_partner, gender,
age, state, city, pincode, date_of_registration,
num_dependents, estimated_salary, calls_made,
sms_sent, data_used, churn
having count(*) > 1;


-- 5. Missing value check.

select count(*) from telecom_churn where customer_id is null;

select count(*) from telecom_churn where telecom_partner is null;

select count(*) from telecom_churn where gender is null;

select count(*) from telecom_churn where age is null;

select count(*) from telecom_churn where state is null;

select count(*) from telecom_churn where city is null;

select count(*) from telecom_churn where pincode is null;

select count(*) from telecom_churn where date_of_registration is null;

select count(*) from telecom_churn where num_dependents is null;

select count(*) from telecom_churn where estimated_salary is null;

select count(*) from telecom_churn where calls_made is null;

select count(*) from telecom_churn where sms_sent is null;

select count(*) from telecom_churn where data_used is null;

select count(*) from telecom_churn where churn is null;


-- 6. Blank text check.

select *
from telecom_churn
where trim(telecom_partner) = ''
   or trim(gender) = ''
   or trim(state) = ''
   or trim(city) = ''
   or trim(pincode) = '';


-- 7. Invalid value check

-- Negative salary

select *
from telecom_churn
where estimated_salary < 0;


-- Negative calls

select *
from telecom_churn
where calls_made < 0;


-- Negative sms

select *
from telecom_churn
where sms_sent < 0;


-- Negative data usage

select *
from telecom_churn
where data_used < 0;


-- Invalid age

select *
from telecom_churn
where age < 18
or age > 100;


-- Negative dependents

select *
from telecom_churn
where num_dependents < 0;


-- 8. Category validation

select distinct telecom_partner
from telecom_churn
order by telecom_partner;

select distinct gender
from telecom_churn
order by gender;

select distinct churn
from telecom_churn;

select distinct state
from telecom_churn
order by state;


-- 9. Date validation

select min(date_of_registration) as first_registration,
max(date_of_registration) as last_registration
from telecom_churn;
select *
from telecom_churn
where date_of_registration > current_date;


-- 10. Outlier detection

select
min(estimated_salary),
max(estimated_salary),
avg(estimated_salary)
from telecom_churn;
select min(calls_made),
max(calls_made),
avg(calls_made)
from telecom_churn;
select min(sms_sent),
max(sms_sent), avg(sms_sent)
from telecom_churn;
select min(data_used),
max(data_used),
avg(data_used)
from telecom_churn;


-- 11. Business rule validation

-- Customers with no usage

select *
from telecom_churn
where calls_made = 0
and sms_sent = 0
and data_used = 0;


-- High salary customers with no usage

select *
from telecom_churn
where estimated_salary > 100000
and calls_made = 0
and sms_sent = 0
and data_used = 0;

-- 12. final validation

select count(*) as total_records
from telecom_churn;


/*
===============================================================================
Part 3 : Data Preprocessing

Objective:
Prepare the cleaned dataset for analysis by applying data
transformations, handling missing values, standardizing formats,
and creating a structured dataset for exploratory data analysis
and business analysis.

===============================================================================
*/

-- 1. Create a cleaned working table

create table telecom_churn_clean as
select *
from telecom_churn;


-- 2. Remove leading and trailing spaces

update telecom_churn_clean
set
telecom_partner = trim(telecom_partner),
gender = trim(gender),
state = trim(state),
city = trim(city),
pincode = trim(pincode);


-- 3. standardize text values

update telecom_churn_clean
set
gender = initcap(lower(gender)),
telecom_partner = initcap(lower(telecom_partner)),
state = initcap(lower(state)),
city = initcap(lower(city));


-- 4. replace invalid values with null

update telecom_churn_clean
set data_used = null
where data_used < 0;

update telecom_churn_clean
set estimated_salary = null
where estimated_salary < 0;

update telecom_churn_clean
set calls_made = null
where calls_made < 0;

update telecom_churn_clean
set sms_sent = null
where sms_sent < 0;

update telecom_churn_clean
set age = null
where age < 18
or age > 100;

update telecom_churn_clean
set num_dependents = null
where num_dependents < 0;


-- 5. emove duplicate customer ids (if any)

delete from telecom_churn_clean
where ctid not in
(
    select min(ctid)
    from telecom_churn_clean
    group by customer_id
);


-- 6. verify data cleaning

select count(*)
from telecom_churn_clean;

select *
from telecom_churn_clean
limit 10;


-- 7. verify remaining invalid values

select *
from telecom_churn_clean
where estimated_salary < 0;

select *
from telecom_churn_clean
where calls_made < 0;

select *
from telecom_churn_clean
where sms_sent < 0;

select *
from telecom_churn_clean
where data_used < 0;

select *
from telecom_churn_clean
where age < 18
   or age > 100;

select *
from telecom_churn_clean
where num_dependents < 0;


-- 8. remove records with invalid data usage

delete from telecom_churn_clean
where data_used is null;


-- 9. verify missing values after cleaning

select count(*)
from telecom_churn_clean
where telecom_partner is null;

select count(*)
from telecom_churn_clean
where gender is null;

select count(*)
from telecom_churn_clean
where state is null;

select count(*)
from telecom_churn_clean
where city is null;

select count(*)
from telecom_churn_clean
where estimated_salary is null;

select count(*)
from telecom_churn_clean
where data_used is null;

select count(*)
from telecom_churn_clean
where data_used is null;





/*
===============================================================================
Part 4 : exploratory data analysis

objective:
explore the telecom customer dataset to understand customer
demographics, usage patterns, churn distribution and key trends
that provide a foundation for business analysis.

===============================================================================
*/

-- ============================================================================
-- 1. Dataset overview
-- ============================================================================

-- Total customers

select count(*) as total_customers
from telecom_churn_clean;

-- churn distribution

select churn,
count(*) as customers
from telecom_churn_clean
group by churn;

-- churn rate

select
round(
100.0 * sum(case when churn = true then 1 else 0 end)
/
count(*),2
) as churn_rate
from telecom_churn_clean;


-- ============================================================================
-- 2. customer demographics
-- ============================================================================

-- gender distribution

select gender,
count(*) as customers
from telecom_churn_clean
group by gender
order by customers desc;

-- age statistics

select
min(age) as minimum_age,
max(age) as maximum_age,
round(avg(age),2) as average_age
from telecom_churn_clean;

-- age group distribution

select
case
when age between 18 and 25 then '18-25'
when age between 26 and 35 then '26-35'
when age between 36 and 45 then '36-45'
when age between 46 and 60 then '46-60'
else '60+'
end as age_group,
count(*) as customers
from telecom_churn_clean
group by age_group
order by age_group;

-- dependents distribution

select num_dependents,
count(*) as customers
from telecom_churn_clean
group by num_dependents
order by num_dependents;

-- average salary by gender

select gender,
round(avg(estimated_salary),2) as average_salary
from telecom_churn_clean
group by gender;


-- ============================================================================
-- 3. churn exploration
-- ============================================================================

-- churn by gender

select gender, churn,
count(*) as customers
from telecom_churn_clean
group by gender,churn
order by gender;

-- churn by age group

select
case
when age between 18 and 25 then '18-25'
when age between 26 and 35 then '26-35'
when age between 36 and 45 then '36-45'
when age between 46 and 60 then '46-60'
else '60+'
end as age_group,
churn,
count(*) as customers
from telecom_churn_clean
group by age_group,churn
order by age_group;

-- churn by dependents

select num_dependents,
churn, count(*) as customers
from telecom_churn_clean
group by num_dependents,churn
order by num_dependents;


-- ============================================================================
-- 4. telecom partner exploration
-- ============================================================================

-- customer distribution by telecom partner

select telecom_partner,
count(*) as customers
from telecom_churn_clean
group by telecom_partner
order by customers desc;

-- churn by telecom partner

select telecom_partner,
churn, count(*) as customers
from telecom_churn_clean
group by telecom_partner,churn
order by telecom_partner;

-- average data usage by telecom partner

select telecom_partner,
round(avg(data_used),2) as average_data_used
from telecom_churn_clean
group by telecom_partner
order by average_data_used desc;


-- ============================================================================
-- 5. geographic exploration
-- ============================================================================

-- customers by state

select state,
count(*) as customers
from telecom_churn_clean
group by state
order by customers desc;

-- top 10 cities

select city,
count(*) as customers
from telecom_churn_clean
group by city
order by customers desc
limit 10;

-- churn by state

select state, churn,
count(*) as customers
from telecom_churn_clean
group by state,churn
order by state;


-- ============================================================================
-- 6. customer usage exploration
-- ============================================================================

-- usage statistics

select round(avg(calls_made),2) as average_calls,
round(avg(sms_sent),2) as average_sms,
round(avg(data_used),2) as average_data_used
from telecom_churn_clean;

-- usage by churn status

select churn,
round(avg(calls_made),2) as average_calls,
round(avg(sms_sent),2) as average_sms,
round(avg(data_used),2) as average_data_used
from telecom_churn_clean
group by churn;


-- ============================================================================
-- 7. registration trend
-- ============================================================================

-- yearly customer registrations

select
extract(year from date_of_registration) as registration_year,
count(*) as customers
from telecom_churn_clean
group by registration_year
order by registration_year;




/*
===============================================================================
Part 5 : business analysis

objective:
Analyze customer churn by answering key business questions,
identifying high-risk customer segments, and generating
actionable insights to support customer retention strategies.

sql concepts:
group by
aggregate functions
case
order by

===============================================================================
*/

-- Q.1 What is the overall customer churn rate?

select round(100.0 * sum(case when churn = true then 1 else 0 end)/ count(*), 2)
as churn_rate
from telecom_churn_clean;


-- Q.2 How many customers have churned and how many have been retained?

select churn, count(*) as total_customers
from telecom_churn_clean
group by churn;


-- Q.3 Which telecom partners have the highest number of churned customers?

select telecom_partner,
count(*) as churned_customers
from telecom_churn_clean
where churn = true
group by telecom_partner
order by churned_customers desc;


-- Q.4 Which states have the highest number of churned customers?

select state,
count(*) as churned_customers
from telecom_churn_clean
where churn = true
group by state
order by churned_customers desc;

-- Q.5 Which cities have the highest number of churned customers?

select city,
count(*) as churned_customers
from telecom_churn_clean
where churn = true
group by city
order by churned_customers desc
limit 10;


-- Q.6 Which age groups experience the highest customer churn?

select
case
when age between 18 and 25 then '18-25'
when age between 26 and 35 then '26-35'
when age between 36 and 45 then '36-45'
when age between 46 and 60 then '46-60'
else '60+'
end as age_group,
count(*) as churned_customers
from telecom_churn_clean
where churn = true
group by age_group
order by churned_customers desc;


-- Q.7 Does customer gender influence churn?

select gender,
count(*) as churned_customers
from telecom_churn_clean
where churn = true
group by gender
order by churned_customers desc;


-- Q.8 How does the number of dependents relate to customer churn?

select num_dependents,
count(*) as churned_customers
from telecom_churn_clean
where churn = true
group by num_dependents
order by num_dependents;


-- Q.9 How does customer usage differ between churned and retained customers?

select churn,
round(avg(calls_made), 2) as average_calls,
round(avg(sms_sent), 2) as average_sms,
round(avg(data_used), 2) as average_data_used
from telecom_churn_clean
group by churn;


-- Q.10 Does estimated salary differ between churned and retained customers?

select churn,
round(avg(estimated_salary), 2) as average_salary
from telecom_churn_clean
group by churn;


/*
===============================================================================
part 6 : intermediate business analysis

objective:
analyze customer churn by applying intermediate sql techniques
to identify high-risk customer segments, churn patterns and
business opportunities that support data-driven decision making.

sql concepts:
cte
subquery
having
case
exists
not exists

===============================================================================
*/

-- Q.11 Which telecom partner has the highest churn rate?

with partner_churn as (
select telecom_partner,
count(*) as total_customers,
sum(case when churn = true then 1 else 0 end) as churned_customers
from telecom_churn_clean
group by telecom_partner
)
select telecom_partner, total_customers, churned_customers,
round(100.0 * churned_customers / total_customers,2) as churn_rate
from partner_churn 
order by churn_rate desc;


-- Q.12 Which states have a churn rate higher than the overall average?

with state_churn as (
select state,
count(*) as total_customers,
sum(case when churn = true then 1 else 0 end) as churned_customers
from telecom_churn_clean
group by state
)
select state,
round(100.0 * churned_customers / total_customers,2) as churn_rate
from state_churn
where (100.0 * churned_customers / total_customers) >
(
select
100.0 * sum(case when churn = true then 1 else 0 end) / count(*)
from telecom_churn_clean
)
order by churn_rate desc;


-- Q.13 Which cities have more than 100 customers and high churn?

select city,
count(*) as total_customers,
sum(case when churn = true then 1 else 0 end) as churned_customers
from telecom_churn_clean
group by city
having count(*) > 100
order by churned_customers desc;

-- Q.14 Which salary group has the highest churn rate?

with salary_group as (
select
case
when estimated_salary < 30000 then 'low'
when estimated_salary between 30000 and 70000 then 'medium'
else 'high'
end as salary_band,
churn
from telecom_churn_clean
)
select salary_band,
count(*) as total_customers,
sum(case when churn=true then 1 else 0 end) as churned_customers,
round(100.0*sum(case when churn=true then 1 else 0 end)/count(*),2) as churn_rate
from salary_group
group by salary_band
order by churn_rate desc;


-- Q.15 Which data usage group has the highest churn rate?

with usage_group as (
select
case
when data_used < 5 then 'low usage'
when data_used between 5 and 15 then 'medium usage'
else 'high usage'
end as usage_band,
churn
from telecom_churn_clean
)
select
usage_band,
count(*) as total_customers,
sum(case when churn=true then 1 else 0 end) as churned_customers,
round(100.0*sum(case when churn=true then 1 else 0 end)/count(*),2) as churn_rate
from usage_group
group by usage_band
order by churn_rate desc;


-- Q.16 Which customers have above average data usage?

select
customer_id,
data_used
from telecom_churn_clean
where data_used >
(
select avg(data_used)
from telecom_churn_clean
)
order by data_used desc;


-- Q.17 Which churned customers have above average salary?

select
customer_id,
estimated_salary
from telecom_churn_clean
where churn = true
and estimated_salary >
(
select avg(estimated_salary)
from telecom_churn_clean
)
order by estimated_salary desc;


-- Q.18 Which telecom partners have retained more customers than churned customers?

select
telecom_partner,
sum(case when churn=false then 1 else 0 end) as retained,
sum(case when churn=true then 1 else 0 end) as churned
from telecom_churn_clean
group by telecom_partner
having
sum(case when churn=false then 1 else 0 end) >
sum(case when churn=true then 1 else 0 end);


-- Q.19 Which customers belong to telecom partners with above average customer base?

with partner_size as (
select
telecom_partner,
count(*) as total_customers
from telecom_churn_clean
group by telecom_partner
)
select
customer_id,
telecom_partner
from telecom_churn_clean t
where exists
(
select 1
from partner_size p
where p.telecom_partner=t.telecom_partner
and p.total_customers >
(
select avg(total_customers)
from partner_size
)
);

-- question 20 : which telecom partners have no customers from the top churn states?

with top_states as (
select state
from telecom_churn_clean
where churn=true
group by state
having count(*) >
(
select avg(churn_count)
from
(
select count(*) as churn_count
from telecom_churn_clean
where churn=true
group by state
) s
)
)
select distinct telecom_partner
from telecom_churn_clean t
where not exists
(
select 1
from telecom_churn_clean c
where c.telecom_partner=t.telecom_partner
and c.state in (select state from top_states)
);


/*
===============================================================================
Part 7 : Advanced Business Analysis

objective:
apply advanced sql techniques to identify high-risk customer
segments, analyze churn trends and generate actionable insights
that support customer retention strategies.

sql concepts:
cte
window functions
rank
dense_rank
row_number
lag
ntile

===============================================================================
*/

-- Q.21 Rank telecom partners by churn rate.

with partner_churn as (
select
telecom_partner,
count(*) as total_customers,
sum(case when churn=true then 1 else 0 end) as churned_customers
from telecom_churn_clean
group by telecom_partner
)
select
telecom_partner,
round(100.0*churned_customers/total_customers,2) as churn_rate,
rank() over(order by 100.0*churned_customers/total_customers desc) as partner_rank
from partner_churn;


-- Q.22 Rank states by churn rate.

with state_churn as (
select state,
count(*) as total_customers,
sum(case when churn=true then 1 else 0 end) as churned_customers
from telecom_churn_clean
group by state
)
select state,
round(100.0*churned_customers/total_customers,2) as churn_rate,
dense_rank() over(order by 100.0*churned_customers/total_customers desc) as state_rank
from state_churn;

-- Q.23 Rank cities by churn rate.

with city_churn as (
select
city,
count(*) as total_customers,
sum(case when churn=true then 1 else 0 end) as churned_customers
from telecom_churn_clean
group by city
)
select city,
round(100.0*churned_customers/total_customers,2) as churn_rate,
dense_rank() over(order by 100.0*churned_customers/total_customers desc) as city_rank
from city_churn;


-- Q.24 Divide customers into salary quartiles.

select customer_id, estimated_salary,
ntile(4) over(order by estimated_salary) as salary_quartile
from telecom_churn_clean;

-- Q.25 Divide customers into data usage quartiles.

select customer_id, data_used,
ntile(4) over(order by data_used) as usage_quartile
from telecom_churn_clean;

-- Q.26 Identify the top 10 highest data users.

select customer_id, telecom_partner, data_used
from (
select customer_id, telecom_partner, data_used,
row_number() over(order by data_used desc) as rn
from telecom_churn_clean
)t
where rn<=10;

-- Q.27 Compare yearly customer registrations.

with yearly as (
select
extract(year from date_of_registration) as reg_year,
count(*) as customers
from telecom_churn_clean
group by reg_year
)
select reg_year, customers,
lag(customers) over(order by reg_year) as previous_year,
customers-lag(customers) over(order by reg_year) as yearly_change
from yearly;

-- Q.28 Identify the highest risk customer segment.

select
telecom_partner,
gender,
case
when age between 18 and 25 then '18-25'
when age between 26 and 35 then '26-35'
when age between 36 and 45 then '36-45'
else '46+'
end as age_group,
count(*) as churned_customers
from telecom_churn_clean
where churn=true
group by telecom_partner,gender,age_group
order by churned_customers desc;

-- Q.29 Identify the lowest risk customer segment.

select telecom_partner, gender,
case
when age between 18 and 25 then '18-25'
when age between 26 and 35 then '26-35'
when age between 36 and 45 then '36-45'
else '46+'
end as age_group,
count(*) as retained_customers
from telecom_churn_clean
where churn=false
group by telecom_partner,gender,age_group
order by retained_customers desc;

-- Q.30 Executive churn summary.

select
count(*) as total_customers,
sum(case when churn=true then 1 else 0 end) as churned_customers,
sum(case when churn=false then 1 else 0 end) as retained_customers,
round(avg(data_used),2) as avg_data_used,
round(avg(calls_made),2) as avg_calls,
round(avg(sms_sent),2) as avg_sms,
round(avg(estimated_salary),2) as avg_salary,
round(100.0*sum(case when churn=true then 1 else 0 end)/count(*),2) as churn_rate
from telecom_churn_clean;





