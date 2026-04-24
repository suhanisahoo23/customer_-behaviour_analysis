# 🛒 Customer Behaviour Analysis
> End-to-end data analytics pipeline — from raw retail data to ML-powered insights and executive dashboards

[![Python](https://img.shields.io/badge/Python-3.10+-3776AB?logo=python&logoColor=white)](https://python.org)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15-336791?logo=postgresql&logoColor=white)](https://postgresql.org)
[![Power BI](https://img.shields.io/badge/Power%20BI-Dashboard-F2C811?logo=powerbi&logoColor=black)](https://powerbi.microsoft.com)
[![scikit-learn](https://img.shields.io/badge/scikit--learn-ML-F7931E?logo=scikit-learn&logoColor=white)](https://scikit-learn.org)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

---

## 📌 Problem Statement

Retail businesses lose revenue when they treat all customers the same. This project answers three core business questions:

1. **Who are our most valuable customers?** (RFM Segmentation)
2. **What drives purchase decisions?** (Correlation & regression analysis)
3. **Which customers are at risk of churning?** (Predictive modelling)

The output: actionable segments and a live Power BI dashboard that a business team can use to drive targeted campaigns.

---

## 🔍 Dataset

| Attribute | Details |
|---|---|
| Source | Kaggle — Customer Shopping Behaviour Dataset |
| Records | 3,900 transactions |
| Features | 18 columns (demographics, purchase history, loyalty signals) |
| Key Fields | `customer_id`, `age`, `gender`, `item_purchased`, `category`, `purchase_amount`, `review_rating`, `subscription_status`, `previous_purchases`, `discount_applied` |

---

## 🏗️ Project Architecture

```
customer_behaviour_analysis/
│
├── data/
│   └── customer_shopping_behavior.csv        # Raw dataset
│
├── notebooks/
│   └── Customer_Shopping_Behavior_Analysis.ipynb  # Full EDA + ML pipeline
│
├── sql/
│   └── customer_behavior_sql_queries.sql     # 10+ business queries + advanced analytics
│
├── dashboard/
│   └── Customer_Behaviour_dashboard.pbix     # Power BI interactive dashboard
│
├── outputs/
│   └── *.png                                 # Exported visualizations
│
├── requirements.txt
└── README.md
```

---

## 📊 Analysis Pipeline

### Phase 1 — Exploratory Data Analysis (EDA)
- Distribution analysis of purchase amounts, age groups, and gender
- Correlation heatmap across all numeric features
- Seasonal purchasing trends using time-series decomposition
- Category-level performance benchmarking

### Phase 2 — Customer Segmentation (RFM + K-Means)
Implemented **RFM scoring** (Recency, Frequency, Monetary) combined with **K-Means clustering** to produce 4 meaningful customer segments:

| Segment | Description | Strategy |
|---|---|---|
| 🏆 Champions | High spend, frequent buyers | Reward & retain |
| 💤 At-Risk Loyals | Previously frequent, now dormant | Win-back campaigns |
| 🌱 New Customers | Low history, engaged recently | Nurture & upsell |
| 💸 Bargain Hunters | Discount-dependent buyers | Margin-conscious targeting |

**Optimal k chosen via Elbow Method + Silhouette Score** (k=4, silhouette ≈ 0.42)

### Phase 3 — Predictive Modelling
Built a **subscription churn predictor** using logistic regression and random forest:

| Model | Accuracy | Precision | Recall | F1-Score |
|---|---|---|---|---|
| Logistic Regression | 72% | 0.71 | 0.68 | 0.69 |
| Random Forest | **81%** | **0.80** | **0.79** | **0.79** |

- Feature importance reveals `previous_purchases` and `review_rating` as top churn predictors
- SHAP values used for model explainability

---

## 🗄️ SQL Highlights

Advanced queries include:

- **Window functions** — ranking top products per category using `ROW_NUMBER() OVER (PARTITION BY ...)`
- **CTEs** — multi-step customer segmentation logic
- **Subqueries** — above-average spenders within discount cohort
- **Conditional aggregation** — discount uptake rates per product
- **Revenue attribution** — segmented by age group, gender, and subscription tier

📂 See [`sql/customer_behavior_sql_queries.sql`](sql/customer_behavior_sql_queries.sql) for all 10 queries with comments.

---

## 📈 Key Business Insights

> **Revenue concentration**: Top 20% of customers (Champions segment) drive ~58% of total revenue — confirming Pareto principle in retail.

> **Discount paradox**: Products with highest discount uptake (>70%) show *lower* average review ratings, suggesting discount-seeking customers are less satisfied long-term.

> **Subscription value gap**: Subscribed customers spend on average **$23 more per transaction** and generate **2.3x total lifetime revenue** vs non-subscribers.

> **Shipping & spend correlation**: Express shipping users have a statistically significant higher average basket size (+$18), indicating premium service users are higher-value customers.

---

## ⚙️ Setup & Reproduction

```bash
# 1. Clone the repo
git clone https://github.com/suhanisahoo23/customer_-behaviour_analysis.git
cd customer_-behaviour_analysis

# 2. Create virtual environment
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate

# 3. Install dependencies
pip install -r requirements.txt

# 4. Run the notebook
jupyter notebook notebooks/Customer_Shopping_Behavior_Analysis.ipynb
```

**PostgreSQL setup (optional):**
```sql
-- Create table and load data
CREATE TABLE customer ( ... );
\copy customer FROM 'customer_shopping_behavior.csv' CSV HEADER;

-- Then run queries in sql/customer_behavior_sql_queries.sql
```

---

## 🛠️ Tech Stack

| Layer | Tools |
|---|---|
| Data Manipulation | Python, Pandas, NumPy |
| Visualisation | Matplotlib, Seaborn, Plotly |
| Machine Learning | scikit-learn (KMeans, RandomForest, LogisticRegression) |
| Model Explainability | SHAP |
| Database | PostgreSQL 15 |
| Dashboard | Power BI |
| Environment | Jupyter Notebook |

---

## 📌 Skills Demonstrated

`EDA` · `Feature Engineering` · `Customer Segmentation` · `RFM Analysis` · `K-Means Clustering` · `Predictive Modelling` · `SQL Window Functions` · `CTEs` · `Data Storytelling` · `Business Insight Generation` · `Power BI`

---

## 🤝 Contributing

Pull requests are welcome. For major changes, please open an issue first.

---

## 📄 License

[MIT](LICENSE) © Suhani Sahoo
