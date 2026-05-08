CREATE OR REPLACE TABLE `reddit-trends-pipeline.reddit_trends.subreddit_correlation_scores` AS

WITH total_keywords_per_subreddit AS (
  SELECT
    subreddit,
    COUNT(*) AS total_keywords
  FROM `reddit-trends-pipeline.reddit_trends.reddit_keywords`
  GROUP BY subreddit
),
matched_keywords AS (
  SELECT
    subreddit,
    COUNT(*) AS matched_count
  FROM `reddit-trends-pipeline.reddit_trends.reddit_vs_google_trends`
  GROUP BY subreddit
)
SELECT
  m.subreddit,
  m.matched_count,
  t.total_keywords,
  ROUND(SAFE_DIVIDE(m.matched_count, t.total_keywords) * 100, 2) AS correlation_pct
FROM matched_keywords m
JOIN total_keywords_per_subreddit t
  ON m.subreddit = t.subreddit
ORDER BY correlation_pct DESC;