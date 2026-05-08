CREATE OR REPLACE TABLE `reddit-trends-pipeline.reddit_trends.reddit_keywords` AS

WITH words AS (
  SELECT
    subreddit,
    post_date,
    LOWER(word) AS keyword
  FROM `reddit-trends-pipeline.reddit_trends.reddit_posts_partitioned`,
  UNNEST(SPLIT(REGEXP_REPLACE(title, r'[^a-zA-Z0-9 ]', ''), ' ')) AS word
  WHERE LENGTH(word) > 4  -- filter out short stop words
),
keyword_counts AS (
  SELECT
    subreddit,
    post_date,
    keyword,
    COUNT(*) AS mention_count
  FROM words
  WHERE keyword NOT IN (
    'about','after','also','been','before','being','between',
    'could','their','there','these','those','through','under',
    'where','which','while','would','other','first','still',
    'every','since','think','should','people','years','than',
    'have','with','that','this','from','will','your','what'
  )
  GROUP BY subreddit, post_date, keyword
)
SELECT
  subreddit,
  post_date,
  keyword,
  mention_count,
  RANK() OVER (PARTITION BY subreddit, post_date ORDER BY mention_count DESC) AS daily_rank
FROM keyword_counts;