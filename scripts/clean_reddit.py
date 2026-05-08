from pyspark.sql import SparkSession
from pyspark.sql.functions import col, to_date, lower, trim

spark = SparkSession.builder.appName("CleanReddit").getOrCreate()

# Read all 4 CSVs from GCS
df = spark.read.csv(
    "gs://reddit-trends-bucket/raw/*.csv",
    header=True,
    inferSchema=True
)

# Drop nulls and duplicates
df = df.dropna(subset=["title", "subreddit", "utc_datetime_str"])
df = df.dropDuplicates(["id"])

# Normalize subreddit to lowercase and trim whitespace
df = df.withColumn("subreddit", lower(trim(col("subreddit"))))

# Convert utc_datetime_str to a proper date column
df = df.withColumn("post_date", to_date(col("utc_datetime_str"), "yyyy-MM-dd HH:mm:ss"))

# Filter to only our 4 target subreddits
target_subreddits = ["technology", "worldnews", "entertainment", "sports"]
df = df.filter(col("subreddit").isin(target_subreddits))

# Drop the original datetime string, keep the clean date
df = df.drop("utc_datetime_str")

# Write to GCS as Parquet
df.write.mode("overwrite").parquet("gs://reddit-trends-bucket/processed/reddit_posts/")

print(f"Done. Total rows written: {df.count()}")

spark.stop()