# eCommerce Data Analysis Project

As an eCommerce Data Analyst for retailer company which has just launched their first product.For following the growing path of the company, need to analyze and optimize marketing channels, measure and test website conversion performance.

**Traffic source analysis** 
[this sql file answers queries below](https://github.com/Umid995/eCommerce-Data-Analyst-Project/blob/main/Traffic_source_analysis.sql)

1 Where the bulk of website sessions coming
  Breakdown by utm (source, campaign,referring domain)
  
2 Calculate conversion rate (CVR) from session to order
  Look gsearch and nonbrand traffic source 
  date '2012-04-14'

3 Based on conversion rate analysis bid down gsearch nonbrand on 2012-04-15
  Pull gsearch nonbrand trended session volume by week to see if the bid changes caused volume
  date 2012-05-10
  
4 Pull conversion rate from session to order by device type (mobile and desktop)
  date 2012-05-11

5 (after the analysis of above questions) decided bid gsearch nonbrand desktop campaign up on 2012-05-19
  Pull weekly trends for both desktop and mobile  for see the impact of volume
  Can use 2012-04-15 untill bid change as a baseline
  date 2012-06-09
  
  **Website performance analysis** 
  [this sql file answers queries below](https://github.com/Umid995/eCommerce-Data-Analyst-Project/blob/main/Website_performance_analysis.sql)
  
1 Pull most viewed website pages, ranked by session volume
  date 2012-06-09
   
2 Pull all entry pages and rank them on etry volume

3 Pull bounce rates for traffic landing on the homepage
  Show sessions, bounced sessions and percentage of bounced session from total sessions
  
4 A new custom landing page (/lander-1) is drived in 50/50 test against the homepage (/home)
  Pull bounce rate for two landing pages for evaluate performance of new page 
  date 2012-07-28

5 Build full conversion funnell, analyzing how many customers make it to each step
  Use gsearch  nonbrand traffic. use data since 2012-08-05
  date 2012-09-05
  
6 Billing is updated and need to compare original /billing page with new /billing-2 page
  Pull percentage of each of these pages which ended with an order by
  date 2012-11-10

##Data 
data used in this project provided by Maven Analytics

###Run
 first run preparing_workbench_2022.sql scripte to update properties of server.
 second unzip create_mavenfuzzyfactory.sql.zip file and sql script on mysql it will create data base mavenfuzzyfactory.
 third use the sql files to make traffic source and website performance analysis.
 
####Requirements
mysql workbench
