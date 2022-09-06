
-- Pull most viewed website pages, ranked by session volume
-- date 2012-06-09

SELECT pageview_url,
       COUNT(DISTINCT website_pageview_id) AS sessions
FROM website_pageviews
WHERE created_at < '2012-06-09'
GROUP BY 1 
ORDER BY 2 DESC;


-- Pull all entry pages and rank them on etry volume

-- 1 step find first pageview for each session
CREATE TEMPORARY TABLE entry_page_per_session
SELECT website_session_id,
       MIN(website_pageview_id)  AS pageview_id
FROM website_pageviews
WHERE created_at < '2012-06-12'
GROUP BY 1;
-- 2 step find the page the user saw on firt pageview
SELECT  website_pageviews.pageview_url AS lander_page,
        COUNT(DISTINCT entry_page_per_session.website_session_id) AS sessions_of_landing_page
FROM entry_page_per_session
LEFT JOIN website_pageviews
ON entry_page_per_session.pageview_id = website_pageviews.website_pageview_id
WHERE created_at < '2012-06-12'
GROUP BY 1;

-- Pull bounce rates for traffic landing on the homepage
-- Show sessions, bounced sessions and percentage of bounced session from total sessions

-- 1 step find number of pageview per each sesion
CREATE TEMPORARY TABLE num_pageview
SELECT website_session_id,
       COUNT(website_pageview_id) as num_pageview_per_session	  
FROM website_pageviews
WHERE created_at < '2012-06-14'
GROUP BY 1;
  
-- 2 step calculate   total and bounced session
SELECT COUNT(DISTINCT website_session_id) AS total_sessions,
       COUNT(CASE WHEN num_pageview_per_session = 1 THEN 1 ELSE NULL END) AS bounced_session,
       COUNT(CASE WHEN num_pageview_per_session = 1 THEN 1 ELSE NULL END)/COUNT(DISTINCT website_session_id) AS pr_bounced_session
FROM num_pageview ;

-- A new custom landing page (/lander-1) is drived in 50/50 test against the homepage (/home)
-- Pull bounce rate for two landing pages for evaluate performance of new page 
-- date 2012-07-28

-- 1 step find the time when first lander-1 page is implemented
SELECT MIN(created_at) AS time_first_lander_1,
       pageview_url
FROM website_pageviews
WHERE pageview_url = '/lander-1';
-- 2012-06-19

-- 2 step drive number of pageview for each session
CREATE TEMPORARY TABLE num_pageview_per_session
SELECT website_pageviews.website_session_id AS session_id,  
       COUNT(website_pageview_id) AS num_pageview_per_session
FROM website_pageviews
LEFT JOIN website_sessions
ON website_pageviews.website_session_id = website_sessions.website_session_id
WHERE website_sessions.utm_source = 'gsearch'
      AND website_sessions.utm_campaign = 'nonbrand'
      AND website_sessions.created_at BETWEEN '2012-06-19' AND '2012-07-28'
      
GROUP BY 1;

-- 3 step find pageview numbers according to entry pages (lander-1  and home)
CREATE TEMPORARY TABLE lander_pages
SELECT num_pageview_per_session.session_id,
       num_pageview_per_session.num_pageview_per_session,
       website_pageviews.pageview_url as land_page
FROM num_pageview_per_session
LEFT JOIN website_pageviews
ON num_pageview_per_session.session_id = website_pageviews.website_session_id
WHERE website_pageviews.pageview_url = '/lander-1' OR website_pageviews.pageview_url = '/home';

-- 4 step calculate total sessions, bounced sessions, and bounce rate
SELECT land_page,
       COUNT(CASE WHEN (land_page = '/lander-1' OR land_page = '/home') AND num_pageview_per_session = 1 THEN 1 ELSE NULL END) AS bounce_sessions,
       COUNT(CASE WHEN land_page = '/lander-1' OR land_page = '/home'  THEN 1 ELSE NULL END) AS  total_sessions,
       (COUNT(CASE WHEN (land_page = '/lander-1' OR land_page = '/home') AND num_pageview_per_session = 1 THEN 1 ELSE NULL END)
       /COUNT(CASE WHEN land_page = '/lander-1' OR land_page = '/home'  THEN 1 ELSE NULL END)) AS bounce_rate
       
FROM lander_pages
GROUP BY 1;

-- Build full conversion funnell, analyzing how many customers make it to each step
-- gsearch  nonbrand traffic. use data since 2012-08-05
-- date 2012-09-05

-- 1 step drive conversion funnel for each session but here will get for one session multiple row
CREATE TEMPORARY TABLE conversion_funnel
SELECT website_sessions.website_session_id,
       website_pageviews.pageview_url,
       CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 END AS product_page,
       CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS original_mrfuzzy_page,
       CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page,
       CASE WHEN pageview_url = '/shipping' THEN 1 ELSE 0 END AS shipping_page,
       CASE WHEN pageview_url = '/billing' THEN 1 ELSE 0 END AS billing_page,
       CASE WHEN pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS thanks_page
FROM website_sessions
LEFT JOIN website_pageviews
ON website_sessions.website_session_id = website_pageviews.website_session_id
WHERE website_sessions.utm_source = 'gsearch'
      AND website_sessions.utm_campaign = 'nonbrand'
      AND website_sessions.created_at BETWEEN '2012-08-05' AND '2012-09-05'
GROUP BY 1,2;

-- 2 step put used pages for a session in same row
CREATE TEMPORARY TABLE conversion_funnel_2
SELECT website_session_id,
      MAX(product_page) AS product_pg,
      MAX(original_mrfuzzy_page) AS original_mrfuzzy_pg,
      MAX(cart_page) AS cart_pg,
      MAX(shipping_page) AS shipping_pg,
      MAX(billing_page) AS billing_pg,
      MAX(thanks_page) AS thanks_pg
FROM conversion_funnel
GROUP BY 1;

-- 3 step calculation of total session and sessions for each page.
SELECT COUNT(conversion_funnel_2.website_session_id) AS sessions,
       COUNT( CASE WHEN product_pg = 1 THEN 1 ELSE NULL END) AS pruducts,
	   COUNT( CASE WHEN original_mrfuzzy_pg = 1 THEN 1 ELSE NULL END) AS originals_mrfuzzy,
	   COUNT( CASE WHEN cart_pg = 1 THEN 1 ELSE NULL END) AS carts,
	   COUNT( CASE WHEN shipping_pg = 1 THEN 1 ELSE NULL END) AS shippings,
	   COUNT( CASE WHEN billing_pg = 1 THEN 1 ELSE NULL END) AS billings,
	   COUNT( CASE WHEN thanks_pg = 1 THEN 1 ELSE NULL END) AS thanks
FROM conversion_funnel_2;


-- Billing is updated and need to compare original /billing page with new /billing-2 page
-- Pull percentage of each of these pages which ended with an order by
-- this test for all traffic
-- date 2012-11-10

-- 1 step find when first billing-2 is proposed for defining start point
SELECT MIN(created_at) as  min_created_at_bil2
FROM website_pageviews
WHERE pageview_url = '/billing-2';
-- 2012-09-10

-- 2 step drive table for session page and orders
CREATE TEMPORARY TABLE pages_for_orders
SELECT website_pageviews.pageview_url,
       website_pageviews.website_session_id,
       orders.order_id
FROM website_pageviews
LEFT JOIN orders
ON website_pageviews.website_session_id = orders.website_session_id
WHERE website_pageviews.pageview_url IN ('/billing', '/billing-2')
      AND website_pageviews.created_at BETWEEN '2012-09-10' AND '2012-11-10';

-- 3 step calculate sessions and orders for these two pages.
SELECT pageview_url,
       COUNT(website_session_id) AS sessions,
       COUNT(order_id) AS orders,
       COUNT(order_id)/COUNT(website_session_id) AS rate_billing_to_order
FROM pages_for_orders
GROUP BY 1
    



      