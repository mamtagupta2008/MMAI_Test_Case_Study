-- Question 1 - Daily top 5 pieces of content
-- Top 5 pieces of content can be defined based on metrics like number of users, total time spent, daily average time spent etc.
-- This table load can be setup to perform incremental based on view_date and content_id
-- Cluster key on content_id and view_date can be created for better performance


-- Option 1: Top 5 contents based on number of users
-- This CTE will return total number of users viewed the content for the day
WITH get_user_counts AS
(
SELECT i.content_id
  , DATE(i.Timestamp) AS view_date
  , COUNT(DISTINCT i.ads_user_id) AS number_of_users
FROM page_impression AS i
WHERE DATE(i.Timestamp) = (current_date() - 1)
GROUP BY i.content_id, view_date
)

-- This CTE is to rank the content based on number of users on daily basis
, rank_daily_contents AS
(
SELECT r.content_id
, r.view_date
, r.number_of_users
, rank() OVER (PARTITION BY r.view_date ORDER BY r.number_of_users DESC) AS rank
  FROM get_user_counts r
   )

-- Final step to display only top 5 content based on number of users
SELECT r.content_id
, r.view_date
, r.number_of_users
FROM rank_daily_contents r
WHERE rank <= 5

-- Option 2 & 3 : Daily top 5 content based on average time spent

-- This CTE will give us the time spent on each session based on every content at daily level

WITH daily_time_spent_on_session AS
(
SELECT i.content_id
, i.session_id
, DATE(i.Timestamp) AS view_date
, DATEDIFF(second, MIN(i.Timestamp), MAX(i.Timestamp)) AS time_spent_per_session
FROM page_impression i
WHERE DATE(i.Timestamp) = (current_date() - 1)
GROUP BY i.content_id, i.session_id, view_date
)

-- This CTE will give daily total and average time spent on the content

, daily_time_spent_on_content AS
(
SELECT s.content_id
, s.view_date
, SUM(s.time_spent_per_session) AS total_time_spent_per_content
, AVG(s.time_spent_per_session) AS average_time_spent_per_content
FROM daily_time_spent_on_session s
GROUP BY s.content_id
, s.view_date
)

-- This CTE is to rank the content based total and average time spent on the content

, rank_daily_contents AS
(
SELECT r.content_id
, r.view_date
, r.total_time_spent_per_content
, r.average_time_spent_per_content
, rank() OVER (PARTITION BY r.view_date ORDER BY r.total_time_spent_per_content DESC) AS rank_total
, rank() OVER (PARTITION BY r.view_date ORDER BY r.average_time_spent_per_content DESC) AS rank_average
  FROM daily_time_spent_on_content r
  )

-- Option 2: This will give us daily top 5 content based on daily total time spent on the contents
SELECT r.content_id
, r.view_date
, r.total_time_spent_per_content
FROM rank_daily_contents r
WHERE r.rank_total <= 5

-- Option 3: This will give us daily top 5 content based on daily average time spent on the contents
SELECT r.content_id
, r.view_date
, r.average_time_spent_per_content
FROM rank_daily_contents r
WHERE r.rank_average <= 5


--- TEST Case Scenarios

--1. Verify max viewed content for a given day by sorting them descending based on user count
--2. Verify all contents were active on the given test day
--3. Verify against date to make sure we have data present for all the dates
