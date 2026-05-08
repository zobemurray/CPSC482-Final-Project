CREATE OR REPLACE TABLE `reddit-trends-pipeline.reddit_trends.weekly_trend_alignment` AS

SELECT
  r.subreddit,
  g.week AS trend_week,
  COUNT(DISTINCT r.keyword) AS matching_terms,
  SUM(r.mention_count) AS total_reddit_mentions,
  AVG(g.score) AS avg_google_score
FROM `reddit-trends-pipeline.reddit_trends.reddit_vs_google_trends` r
JOIN `bigquery-public-data.google_trends.top_terms` g
  ON LOWER(r.keyword) = LOWER(g.term)
  AND r.post_date BETWEEN DATE(g.week) AND DATE_ADD(DATE(g.week), INTERVAL 6 DAY)
GROUP BY r.subreddit, g.week
ORDER BY g.week, r.subreddit;