USE mavenfuzzyfactory;

-- Where the bulk of website sessions coming
-- Breakdown by utm (source, campaign,referring domain)

SELECT utm_source,
       utm_campaign,
       http_referer,
       COUNT(DISTINCT website_session_id)
FROM website_sessions
WHERE created_at < '2012-04-12'
GROUP BY 1,2,3
ORDER BY 4 DESC;

-- Calculate conversion rate (CVR) from session to order
-- Look gsearch and nonbrand traffic source 
-- date '2012-04-14'

SELECT COUNT(DISTINCT website_sessions.website_session_id) AS num_sessions,
       COUNT(DISTINCT orders.order_id) AS num_order,
	   COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT website_sessions.website_session_id) AS CVR
FROM website_sessions
LEFT JOIN orders
ON website_sessions.website_session_id = orders.website_session_id
WHERE website_sessions.utm_source = 'gsearch' 
      AND website_sessions.utm_campaign = 'nonbrand'
      AND website_sessions.created_at < '2012-04-14' ;
      
      
-- Based on conversion rate analysis bid down gsearch nonbrand on 2012-04-15
-- Pull gsearch nonbrand trended session volume by week to see if the bid changes caused volume
-- date 2012-05-10

SELECT  MIN(DATE(created_at)) AS weekly_date,
        COUNT(DISTINCT website_session_id) AS sessions
FROM website_sessions
WHERE utm_source = 'gsearch'
      AND utm_campaign = 'nonbrand'
      AND created_at < '2012-05-10'
GROUP BY YEAR(created_at),
		 WEEK(created_at) ;
         

-- Pull conversion rate from session to order by device type (mobile and desktop)
-- date 2012-05-11
SELECT website_sessions.device_type,
      COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
      COUNT(DISTINCT orders.order_id) AS orders,
      COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT website_sessions.website_session_id) AS CVR
FROM website_sessions
LEFT JOIN orders
ON website_sessions.website_session_id = orders.website_session_id
WHERE website_sessions.utm_source = 'gsearch'
      AND website_sessions.utm_campaign = 'nonbrand'
      AND website_sessions.created_at < '2012-05-11'
GROUP BY 1;
	
    
-- (after analysis) decided bid gsearch nonbrand desktop campaign up on 2012-05-19
-- Pull weekly trends for both desktop and mobile  for see the impact of volume
-- Can use 2012-04-15 untill bid change as a baseline
-- date 2012-06-09

SELECT MIN(DATE(website_sessions.created_at)) AS weekly_date,
       COUNT(CASE WHEN website_sessions.device_type = 'desktop' THEN 1 ELSE NULL END ) AS desktop_sessions,
       COUNT(CASE WHEN website_sessions.device_type = 'mobile' THEN 1 ELSE NULL END ) AS mobile_sessions
FROM website_sessions
LEFT JOIN orders
ON website_sessions.website_session_id = orders.website_session_id
WHERE website_sessions.utm_source = 'gsearch'
      AND website_sessions.utm_campaign = 'nonbrand'
      AND website_sessions.created_at BETWEEN '2012-04-12' AND '2012-06-09'
GROUP BY YEAR(website_sessions.created_at),
		 WEEK(website_sessions.created_at);



