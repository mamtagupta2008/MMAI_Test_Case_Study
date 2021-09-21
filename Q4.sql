-- Follow user journeys for registration conversion

-- To follow user journeys towards conversion to registered user we would need to create a behavior flow for each user to
-- understand how he/she navigated through the content
-- Refer to README for more details about the data structure

SELECT p.Ads_User_Id
  , p.session_id
  , p.content_id AS Ending_Content_ID
  , p.timestamp AS timestamp_ending_content
  , LAG(
    p.content_id, 1, 0
  ) OVER (PARTITION BY p.session_id, p.Ads_User_Id ORDER BY timestamp DESC) AS Starting_content_id
DATEDIFF(minute, p.timestamp, (lag(p.timestamp, 1, 0) OVER (PARTITION BY p.session_id, p.Ads_User_Id ORDER BY timestamp DESC)))
        AS timestamp_starting_content
FROM page_impression AS p
JOIN oauth_id_service AS o ON p.ads_user_id = o.ads_user_id
JOIN registered_users AS ru ON ru.oauth_id = o.oauth_id
WHERE p.timestamp <= ru.register_date  --- Taking only the activity prior to register date
  --- Taking into considerations the user registered that happened for 1 day.
  AND ru.register_date = CURRENT_DAY() - 1
ORDER BY p.timestamp DESC

