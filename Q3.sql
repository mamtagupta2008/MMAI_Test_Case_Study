-- Question 3  Average user session duration trends

-- This CTE will give us total time spent in seconds by each user on a session for the day

WITH daily_time_spent_on_session AS
(
  SELECT i.Ads_User_Id
         , i.session_id
         , DATE(i.Timestamp) AS view_date
         , DATEDIFF(second, MIN(i.Timestamp), MAX(i.Timestamp)) AS time_spent_per_session
  FROM page_impression AS i
  WHERE DATE(i.Timestamp) = (CURRENT_DATE() - 1)
  GROUP BY i.Ads_User_Id
           , i.session_id
           , view_date
)

-- This will give average time spent by user every day for user session level trending
SELECT s.Ads_User_Id
  , s.view_date
  , AVG(s.time_spent_per_session) AS average_daily_time_spent
FROM daily_time_spent_on_session AS s
GROUP BY s.Ads_User_Id
  , s.view_date

-- Analysis can also be done at content or content type or ad level,
-- but above query is purely for user's daily session average duration trending

-----  Case specific TEST Case Scenarios ---------------------
-- 1. Verify the users present in page_impression have data in this table to make sure we are tracking trend for each user.



