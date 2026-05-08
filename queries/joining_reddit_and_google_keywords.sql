CREATE OR REPLACE TABLE `reddit-trends-pipeline.reddit_trends.reddit_vs_google_trends` AS

SELECT
  r.subreddit,
  r.post_date,
  r.keyword,
  r.mention_count,
  r.daily_rank,
  g.term AS google_term,
  g.score AS google_score,
  g.week AS google_week,

FROM `reddit-trends-pipeline.reddit_trends.reddit_keywords` r
INNER JOIN `bigquery-public-data.google_trends.top_terms` g
  ON LOWER(r.keyword) = LOWER(g.term)
  AND r.post_date BETWEEN DATE(g.week) AND DATE_ADD(DATE(g.week), INTERVAL 6 DAY)
WHERE
  r.daily_rank <= 50