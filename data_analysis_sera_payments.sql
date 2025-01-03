-- Data Analysis in SQL
-- How many transactions occurred?

SELECT COUNT(*)
FROM sera.sales;

-- What is the period covered in the analysis?

SELECT MIN(datetime) AS start_date, MAX(datetime) AS end_date,
AGE(MAX(datetime), MIN(datetime)) AS time_period_covered
FROM sera.sales;

-- Show the transaction count by status and percentage of total for each status.

SELECT 
    COUNT(status) AS total_rows,
    COUNT(CASE WHEN status = 'success' THEN 1 END) AS total_success,
    COUNT(CASE WHEN status = 'failed' THEN 1 END) AS total_failed,
    COUNT(CASE WHEN status = 'abandoned' THEN 1 END) AS total_abandoned,
    ROUND(COUNT(CASE WHEN status = 'success' THEN 1 END) * 1.0 / NULLIF(COUNT(status), 0), 1) AS successful_perc,
    ROUND(COUNT(CASE WHEN status = 'failed' THEN 1 END) * 1.0 / NULLIF(COUNT(status), 0), 1) AS failed_perc,
    ROUND(COUNT(CASE WHEN status = 'abandoned' THEN 1 END) * 1.0 / NULLIF(COUNT(status), 0), 1) AS abandoned_perc
FROM sera.sales;

-- Show the monthly subscription revenue in NGN split by channel. The exchange rate NGN/USD is 950

SELECT 
    DATE_TRUNC('MONTH', datetime) AS month, 
    channel,
    SUM(CASE WHEN currency = 'USD' THEN amount * 950 ELSE amount END) AS revenue
FROM sera.sales
WHERE status = 'success'
GROUP BY month, channel
ORDER BY month, channel;

-- Show the total transactions by channel split by the transaction status. 
-- Which channel has the highest rate of success? Which has the highest rate of failure?

SELECT channel,COUNT(status) AS total_txn,
	COUNT(CASE WHEN status = 'success' THEN 1 END) AS total_success,
	COUNT(CASE WHEN status = 'abandoned' THEN 1 END) AS total_abandoned,
	COUNT(CASE WHEN status = 'failed' THEN 1 END) AS total_failed
FROM sera.sales
GROUP BY channel;

-- How many subscribers are there in total? A subscriber is a user with a successful payment.

SELECT COUNT(user_id) AS total_subscribers
FROM sera.sales
WHERE status = 'success'

-- A user is active within a month when there is an attempt to subscribe.
-- Generate a list of users showing their number of active months, total successful, abandoned, and failed transactions.

SELECT user_id,months_active,total_successful,total_abandoned,total_failed
FROM(
SELECT user_id, 
COUNT(DISTINCT DATE_TRUNC('month', datetime)) AS months_active,
COUNT(CASE WHEN status LIKE 'success' THEN 1 END) AS total_successful,
COUNT(CASE WHEN status LIKE 'abandoned' THEN 1 END) AS total_abandoned,
COUNT(CASE WHEN status LIKE 'failed' THEN 1 END) AS total_failed
FROM sera.sales
GROUP BY user_id
)AS active_users
ORDER BY months_active DESC;

-- Identify the users with more than 1 active month without a successful transaction.

WITH user_activity AS (
SELECT user_id,
COUNT(DISTINCT DATE_TRUNC('month', datetime)) AS months_active, 
COUNT(CASE WHEN status = 'success' THEN 1 END) AS total_success
FROM sera.sales
GROUP BY user_id
HAVING COUNT(DISTINCT DATE_TRUNC('month', datetime)) > 1
ORDER BY months_active DESC)
SELECT user_id, months_active,total_success
FROM user_activity
WHERE total_success = 0;