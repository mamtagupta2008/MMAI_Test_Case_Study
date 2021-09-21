-- Question 2: Aggregation across a rolling 30, 60, 90 days
-- Multiple metrics can be created for this ask.  Examples:
    -- 1. Total time spent on a content
    -- 2. Average time spent on a content
    -- 3. Total number of users accessing a content
    -- 4. Total number of registered VS non registered users accessing a content
    -- 5. Dwell time on each ad
    -- 6. Daily average dwell time on the ad etc.

-- We can create single table or multiple tables based on granularity of the data.
-- In here, I am projecting scenarios 1 and 2. Additional content level metrics can be added in same table


-- This CTE will return the time spent in seconds for each session for last 90 days
WITH daily_time_spent_on_session AS
(
  SELECT i.content_id
         , i.session_id
         , DATE(i.Timestamp) AS view_date
         , DATEDIFF(second, MIN(i.Timestamp), MAX(i.Timestamp)) AS time_spent_per_session
  FROM page_impression AS i
  WHERE DATE(i.Timestamp) >= (CURRENT_DATE() - 91)
  GROUP BY i.content_id, i.session_id, view_date
)

-- This will return average and total time spent by user every day
, daily_time_spent_on_content AS
(
  SELECT s.content_id
         , s.view_date
         , SUM(s.time_spent_per_session) AS total_time_spent_per_content
         , AVG(s.time_spent_per_session) AS average_time_spent_per_content
  FROM daily_time_spent_on_session AS s
  GROUP BY s.content_id
           , s.view_date
)

-- This CTE will return rolling 30 days total and average time spent on the content
, rolling_30_day_metric AS
(
  SELECT r.content_id
         , (CURRENT_DATE() - 1) AS as_at_date
         , SUM(total_time_spent_per_content) AS total_time_spent_per_content
         , AVG(average_time_spent_per_content) AS average_time_spent_per_content
  FROM daily_time_spent_on_content AS r
  WHERE r.view_date BETWEEN (CURRENT_DATE() - 1) AND (CURRENT_DATE() - 31)
  GROUP BY r.content_id, as_at_date
)

-- This CTE will return rolling 60 days total and average time spent on the content
, rolling_60_day_metric AS
(
  SELECT r.content_id
         , (CURRENT_DATE() - 1) AS as_at_date
         , SUM(total_time_spent_per_content) AS total_time_spent_per_content
         , AVG(average_time_spent_per_content) AS average_time_spent_per_content
  FROM daily_time_spent_on_content AS r
  WHERE r.view_date BETWEEN (CURRENT_DATE() - 1) AND (CURRENT_DATE() - 61)
  GROUP BY r.content_id, as_at_date
)

-- This CTE will return rolling 90 days total and average time spent on the content
, rolling_90_day_metric AS
(
  SELECT r.content_id
         , (CURRENT_DATE() - 1) AS as_at_date
         , SUM(total_time_spent_per_content) AS total_time_spent_per_content
         , AVG(average_time_spent_per_content) AS average_time_spent_per_content
  FROM daily_time_spent_on_content AS r
  WHERE r.view_date BETWEEN (CURRENT_DATE() - 1) AND (CURRENT_DATE() - 91)
  GROUP BY r.content_id, as_at_date
)

SELECT COALESCE(t.content_id, s.content_id, n.content_id) AS content_id
  , COALESCE(t.as_at_date, s.as_at_date, n.as_at_date) AS as_at_date
  , COALESCE(t.total_time_spent_per_content, 0) AS total_time_spent_rolling_30_days
  , COALESCE(t.average_time_spent_per_content, 0) AS average_time_spent_rolling_30_days
  , COALESCE(s.total_time_spent_per_content, 0) AS total_time_spent_rolling_60_days
  , COALESCE(s.average_time_spent_per_content, 0) AS average_time_spent_rolling_60_days
  , COALESCE(n.total_time_spent_per_content, 0) AS total_time_spent_rolling_90_days
  , COALESCE(n.average_time_spent_per_content, 0) AS average_time_spent_rolling_90_days
FROM rolling_30_day_metric AS t
FULL OUTER JOIN
  rolling_60_day_metric AS s ON t.content_id = s.content_id AND t.as_at_date = s.as_at_date
FULL OUTER JOIN
  rolling_90_day_metric AS n ON t.content_id = n.content_id AND t.as_at_date = n.as_at_date


-- This output is provided in a denormalized form for ease and quicker reporting. Given a case if there would be additional rolling
-- time period require it could be converted into normalized form.

-----  Case specific TEST Case Scenarios ---------------------
-- 1. Check for the variation in 30, 60 and 90 days data to follow the pattern

