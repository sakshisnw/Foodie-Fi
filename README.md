# 🥑 Case Study – Foodie-Fi

*A solution project inspired by Danny Ma’s [8 Week SQL Challenge](https://8weeksqlchallenge.com/case-study-3/). See credits at the end.*

---
<img width="1080" height="1080" alt="f1" src="https://github.com/user-attachments/assets/08975ab0-2175-4c89-aa3d-36b4d6f9bbd6" />


## 🧾 Table of Contents

- [Introduction](#introduction)
- [Entity Relationship Diagram](#entity-relationship-diagram)
- [Available Data](#available-data)
- [Case Study Solutions](#case-study-solutions)
  - [Part A: Customer Journey](#part-a-customer-journey)
  - [Part B: Data Analysis Questions](#part-b-data-analysis-questions)
  - [Part C: Challenge Payment Question](#part-c-challenge-payment-question)
  - [Part D: Outside The Box Questions](#part-d-outside-the-box-questions)
- [Extra Resources](#extra-resources)
- [Credits](#credits)

---

## Introduction

Subscription-based businesses are everywhere. Foodie-Fi is a fictional streaming service for food-loving viewers (think: Netflix, but for cooking shows!). Founded by Danny Ma, Foodie-Fi offers monthly and annual subscriptions as well as a 7-day trial, and runs its business entirely data-driven. This project explores customer journeys, payment flows, and key analytics for such a subscription model using real business logic and modern SQL.

---

## Entity Relationship Diagram
There are two core tables:
- **plans**: Defines subscription products
- **subscriptions**: Records changes in each customer's plans over time
<img width="698" height="290" alt="image" src="https://github.com/user-attachments/assets/a4653cb1-06ab-425c-acef-bf6b1b05919e" />


---

## Available Data

### Table 1: `plans`

| plan_id | plan_name       | price    |
|---------|----------------|----------|
| 0       | trial          | $0       |
| 1       | basic monthly  | $9.90    |
| 2       | pro monthly    | $19.90   |
| 3       | pro annual     | $199     |
| 4       | churn          | NULL     |

### Table 2: `subscriptions`

| customer_id | plan_id | start_date  |
|-------------|---------|-------------|
| 1           | 0       | 2020-08-01  |
| 1           | 1       | 2020-08-08  |
| 2           | 0       | 2020-09-20  |
| 2           | 3       | 2020-09-27  |
| ...         | ...     | ...         |

- Plans take effect on start_date, upgrades/downgrades are instant except churn, which completes at billing period end.

---

## Case Study Solutions

### Part A: Customer Journey

Track the detailed journeys for 8 sample customers. See [Part-A-Customer-Journey.md](./Part-A-Customer-Journey.md) for approach, SQL, output, and a brief story for each customer.

---

### Part B: Data Analysis Questions

Solve real business questions like:

- How many unique customers has Foodie-Fi had?
- Monthly distribution of trial starts
- Plan adoptions by year and churn stats
- Percentage breakdown of upgrades, downgrades, churn, and plan popularity
- How long it takes for users to upgrade
- Upgrade rates in 30-day buckets

**Each question features:**  
- SQL query  
- Output table  
- Simple, bullet-point business interpretation

See [Part-B-Data-Analysis.md](./Part-B-Data-Analysis.md).

---

### Part C: Challenge Payment Question

Generate a full payment calendar for 2020:
- Includes recurring monthly/annual payments (with the right dates and payment order)
- Handles upgrades and churn
- Gives a row per payment

**Includes:**
- CTE-based query (stepwise, readable)
- Example output table
- Layperson-friendly explanation of each step

See [Part-C-Challenge-Payment-Question.md](./Part-C-Challenge-Payment-Question.md)

---

### Part D: Outside The Box Questions

Open-ended questions with business and product thinking:
- Growth rate calculations
- Essential metrics for subscription business
- Key moments in customer journeys influencing retention
- Exit survey design
- Churn reduction levers (plus how to test them)

Accessible, interview-ready answers.  
See [Part-D-Outside-The-Box-Questions.md](./Part-D-Outside-The-Box-Questions.md)

---

## Extra Resources

- Official [8 Week SQL Challenge - Case Study #3](https://8weeksqlchallenge.com/case-study-3/)
- More [Data With Danny](https://www.datawithdanny.com/): SQL courses, resources, and community

---

## Credits

- **Case study design, schema, and challenge questions:**  
  [Danny Ma](https://www.datawithdanny.com/) — as part of [8 Week SQL Challenge](https://8weeksqlchallenge.com/case-study-3/)
- **Solution structure and project inspiration:**  
  [Chisomnwa / SQL-Challenge-Case-Study-3---Foodie-Fi](https://github.com/Chisomnwa/SQL-Challenge-Case-Study-3---Foodie-Fi)
- **Logo & Case Study Content:**  
  All rights and inspiration to [Data With Danny](https://www.datawithdanny.com/) and the #8WeekSQLChallenge community.

---

> 💡 **If you use, fork, or remix this repo, please cite [Data With Danny](https://www.datawithdanny.com) and [8 Week SQL Challenge](https://8weeksqlchallenge.com/)!**

Enjoy, share, and happy analyzing!
