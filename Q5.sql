-- Question 5 - User segmentation based on content
-- User segmentation can be done based on multiple demographic user data like age group, gender, geographical location OR
-- Psychographic data like preferences/ interests OR behavioral data like login frequency, time spent etc.
-- Refer to README for more details about the data structure


-- Below SQL will provide segmentation based on user preferences and content type, this can help us understand cross interest of the user based on
-- preferences and content_type

SELECT i.content_type
  , DATE(i.Timestamp) AS view_date
  , 'Preferences' AS User_Segment_Category
  , ru.preferences AS Grouping
  , COUNT(DISTINCT i.ads_user_id) AS number_of_users_count
FROM Page_Impression AS i
JOIN oauth_id_service AS ois ON i.ads_user_id = ois.ads_user_id
JOIN registered_users AS ru ON ois.oauth_id = ru.oauth_id
WHERE DATE(i.Timestamp) = (CURRENT_DATE() - 1)
GROUP BY i.content_type
  , view_date
  , ru.preferences

-- Above can also be represented in terms of percentage for reporting

-----  Case specific TEST Case Scenarios ---------------------
-- 1. Check for different content type present in table are from content
-- 2. Verify preferences present in Grouping columns to make sure we have grouping present for all the preferences from registered_users.
-- 3. Verify the count of user based on preferences to match with count in this table
-- 4. Similarly verify the count of users based on content type to match with th count in this table
