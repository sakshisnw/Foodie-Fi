-- A. Customer Journey

/*
Based on the sample of 8 customers from the subscriptions table, 
we'll analyze each customer’s onboarding journey. We'll look at how they started, 
if and when they upgraded or downgraded, and whether they churned.
*/

-- Build a dataset showing the journey of the 8 selected customers
-- We'll join plans and subscriptions, filtering only the relevant customers

SELECT 
    s.customer_id,
    p.plan_id,
    p.plan_name,
    s.start_date
FROM subscriptions AS s
JOIN plans AS p
  ON s.plan_id = p.plan_id
WHERE s.customer_id IN (1, 2, 11, 13, 15, 16, 18, 19)
ORDER BY s.customer_id, s.start_date;

-- Summary of each customer's journey based on the above results

/*
Customer 1:
Started with a trial on Dec 1, 2020, and upgraded to a pro annual plan on Dec 8, 2020.

Customer 2:
Started with a trial on Dec 20, 2020, and downgraded to a basic monthly plan on Dec 27, 2020.

Customer 11:
Started with a trial on Dec 19, 2020, and cancelled the service on Dec 26, 2020, before the trial ended.

Customer 13:
Started with a trial on Dec 15, 2020, upgraded to basic monthly on Dec 22, 2020, and later upgraded to pro monthly on Mar 29, 2021.

Customer 15:
Started with a trial on Dec 17, 2020, upgraded to pro monthly on Dec 24, 2020, and later cancelled on Jan 20, 2021.

Customer 16:
Started with a trial on Dec 6, 2020, and upgraded directly to pro annual on Dec 13, 2020.

Customer 18:
Started with a trial on Dec 27, 2020, and continued with pro monthly from Jan 3, 2021.

Customer 19:
Started with a trial on Dec 5, 2020, upgraded to basic monthly on Dec 12, 2020, and later churned on Jan 9, 2021.

*/

