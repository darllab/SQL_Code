CREATE DATABASE user;
USE user;

SELECT * FROM user_events;

-- define sales funnel and the different stages
WITH funnel_stages AS (
SELECT COUNT(DISTINCT CASE WHEN event_type = 'page_view' THEN user_id END) AS stage_1_views,
	   COUNT(DISTINCT CASE WHEN event_type = 'add_to_cart' THEN user_id END) AS stage_2_cart,
	   COUNT(DISTINCT CASE WHEN event_type = 'checkout_start' THEN user_id END) AS stage_3_checkout,
	   COUNT(DISTINCT CASE WHEN event_type = 'payment_info' THEN user_id END) AS stage_4_payment,
	   COUNT(DISTINCT CASE WHEN event_type = 'purchase' THEN user_id END) AS stage_5_purchase
FROM user_events
WHERE event_date >= DATE_SUB(CURDATE(),INTERVAL 30 DAY)
)
SELECT * FROM funnel_stages;

-- getting the conversion rates --

WITH funnel_stages AS (
SELECT COUNT(DISTINCT CASE WHEN event_type = 'page_view' THEN user_id END) AS stage_1_views,
		COUNT(DISTINCT CASE WHEN event_type = 'add_to_cart' THEN user_id END) AS stage_2_cart,
        COUNT(DISTINCT CASE WHEN event_type = 'checkout_start' THEN user_id END) AS stage_3_checkout,
        COUNT(DISTINCT CASE WHEN event_type = 'payment_info' THEN user_id END) AS stage_4_payment,
        COUNT(DISTINCT CASE WHEN event_type = 'purchase' THEN user_id END) AS stage_5_purchase
FROM user_events
WHERE event_date >= DATE_SUB(CURDATE(),INTERVAL 30 DAY)
)
SELECT 
 stage_1_views,
 stage_2_cart,
 ROUND(stage_2_cart * 100 / stage_1_views) AS view_to_cart_rate,
 
 stage_3_checkout,
 ROUND(stage_3_checkout * 100 / stage_2_cart) AS cart_to_checkout_rate,
 
 stage_4_payment,
 ROUND(stage_4_payment * 100 / stage_3_checkout) AS checkout_payment_rate,
 
 stage_5_purchase,
 ROUND(stage_5_purchase * 100 / stage_4_payment) AS payment_to_purchase_rate,
 
 ROUND(stage_5_purchase * 100 / stage_1_views) AS overall_views
 
 FROM funnel_stages;

-- funnel by source

WITH source AS (
SELECT traffic_source,
	COUNT(DISTINCT CASE WHEN event_type = 'page_view' THEN user_id END) AS views,
	COUNT(DISTINCT CASE WHEN event_type = 'add_to_cart' THEN user_id END) AS cart,
    COUNT(DISTINCT CASE WHEN event_type = 'purchase' THEN user_id END) AS purchase
FROM user_events
WHERE event_date >= DATE_SUB(CURDATE(),INTERVAL 30 DAY)
GROUP BY traffic_source
)
SELECT 
	traffic_source, views, cart, purchase,
    ROUND(cart * 100 / views) AS cart_conversion_rate,
    ROUND(purchase * 100 / cart) AS cart_to_purchase_conversion_rate,
    ROUND(purchase * 100 / views) AS purchase_conversion_rate
FROM source
ORDER BY purchase DESC;

-- time to conversion analysis

WITH user_journey AS (
SELECT user_id,
	MIN(CASE WHEN event_type = 'page_view' THEN event_date END) AS view_time,
	MIN(CASE WHEN event_type = 'add_to_cart' THEN event_date END) AS cart_time,
    MIN(CASE WHEN event_type = 'purchase' THEN event_date END) AS purchase_time
FROM user_events
WHERE event_date >= DATE_SUB(CURDATE(),INTERVAL 30 DAY)
GROUP BY user_id
HAVING MIN(CASE WHEN event_type = 'purchase' THEN event_date END) IS NOT NULL
)
SELECT 
	COUNT(*) AS converted_users,
	ROUND(AVG(TIMESTAMPDIFF(minute, view_time, cart_time)),2) AS avg_view_to_cart_minutes,
    ROUND(AVG(TIMESTAMPDIFF(minute, cart_time, purchase_time)),2) AS avg_cart_to_purchase_minutes,
    ROUND(AVG(TIMESTAMPDIFF(minute, view_time, purchase_time)),2) AS avg_total_journey_minutes
FROM user_journey;