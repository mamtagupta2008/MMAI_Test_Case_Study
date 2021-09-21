-- Question 6 - Generate dashboards to represent registered vs non registered users
-- As there is no specific measurement points give to compare registered vs non-registered users
-- Refer to README for more details about the data structure


-- This CTE will roll up the information from session level to content level
WITH get_content_level_info AS
(
  SELECT DISTINCT pi.content_id
  , DATE(pi.Timestamp) AS view_date
  , pi.Ads_User_Id
  FROM Page_Impression AS pi
  WHERE DATE(pi.Timestamp) = (CURRENT_DATE() - 1)
)

-- This will give us the grouping based on different contents

SELECT DISTINCT pi.content_id
  , DATE(pi.Timestamp) AS view_date
  , SUM(CASE WHEN ru.User_Id IS NOT NULL THEN 1 ELSE 0 END) AS registered_users_views
  , SUM(CASE WHEN nru.User_Id IS NOT NULL THEN 1 ELSE 0 END) AS non_registered_users_views
FROM get_content_level_info pi
JOIN OAuth_Id_Service AS ois on pi.Ads_User_Id = ois.Ads_User_Id
LEFT JOIN Registered_Users AS ru on ois.OAuth_Id = ru.OAuth_Id

-- This will give us the grouping based on different content type

 SELECT c.content_type
, pi.view_date
, SUM (pi.registered_users_views) AS registered_users_views
, SUM (pi.non_registered_users_views) AS non_registered_users_views
FROM get_content_level_info AS pi
LEFT JOIN content_metadata AS c ON c.content_id = pi.content_id
GROUP BY c.content_type
  , pi.view_date

-- Above can also be represented in terms of percentage for reporting

-----  Case specific TEST Case Scenarios ---------------------
-- 1. Verify the number of daily registered user from Registered_Users to make sure we are not over reporting
-- 2. Verify the total number of users from Page_Impression on daily basis against sum of registered and non registered users
-- 3. Verify the total number of users from Page_Impression for different contents against sum of registered and non registered users