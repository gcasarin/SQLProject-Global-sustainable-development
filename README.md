# SQL-Project: Global-sustainable-development



### Table of Contents

- [Project Overview](#project-overview)
- [Data Sources](#data-sources)
- [Recommendations](#recommendations)

### Project Overview

Leveraging various datasets —including the primary Global Country Information Dataset (2023), Global Data on Sustainable Energy, and the Global Missing Migrants Dataset— we will analyze key indicators across countries.  The main goal is to identify meaningful insights and trends related to economic, demographic, and environmental factors.
The findings will support non-profit organization's mission by providing data-driven evidence to inform policy recommendations and raise public awareness about critical development challenges worldwide.

![Q6-Chart](https://github.com/GabryGit/SQL-Project-Global-sustainable-development/blob/main/Charts/Q6.png)


### Data Sources

To analyze and compare countries on key topics like economy, population, and CO₂ emissions, I got access to several datasets.
- The main dataset is the 'Global Country Information Dataset', which contains 2023 data on economic, demographic, and environmental indicators.
- 'Global Data on Sustainable Energy': This dataset provides a deeper look into how various countries have progressed on sustainable energy.
- 'Global Missing Migrants Dataset': This dataset offers data on missing migrants globally.



### Tools

- Excel - Data Cleaning
- PostgreSQL - Data Analysis


### Data Cleaning/Preparation

In the initial data preparation phase, we performed Data cleaning and formatting with Power Query in Microsoft Excel - before importing it in PostgreSQL.
You can find cleaned datasets [here]()

### Exploratory Data Analysis

EDA involved exploring the sales data to answer key questions, such as:

- What is the overall sales trend?
- Which products are top sellers?
- What are the peak sales periods?

### Data Analysis

Include some interesting code/features worked with

```sql
SELECT * FROM table1
WHERE cond = 2;
```

### Results/Findings

The analysis results are summarized as follows:
1. The company's sales have been steadily increasing over the past year, with a noticeable peak during the holiday season.
2. Product Category A is the best-performing category in terms of sales and revenue.
3. Customer segments with high lifetime value (LTV) should be targeted for marketing efforts.

### Recommendations

Based on the analysis, we recommend the following actions:
- Invest in marketing and promotions during peak sales seasons to maximize revenue.
- Focus on expanding and promoting products in Category A.
- Implement a customer segmentation strategy to target high-LTV customers effectively.

### Limitations

I had to remove all zero values from budget and revenue columns because they would have affected the accuracy of my conclusions from the analysis. There are still a few outliers even after the omissions but even then we can still see that there is a positive correlation between both budget and number of votes with revenue.
