#!/usr/local/bin/python3

import findspark
from pyspark.sql.functions import (
    count,
    dayofmonth,
    month,
    regexp_extract,
    split,
    unix_timestamp,
)
from pyspark.sql.session import SparkSession

# Inicializando Spark
findspark.init("/usr/spark-2.4.6/")

# Iniciando Spark com o Yarn como master
# sc = SparkContext("yarn", "nasa_data")
# sqlContext = SQLContext(sc)
spark = (
    SparkSession.builder.appName("sparksubmit_test_app")
    .config("spark.sql.warehouse.dir", "hdfs:///user/hive/warehouse")
    .config("spark.sql.catalogImplementation", "hive")
    .getOrCreate()
)


def main():

    df = spark.read.text("hdfs://spark-master:9000/datasets/")

    # Montando dataframe
    host = r"(^\S+\.[\S+\.]+\S+)\s"
    timestamp = r"\[(\d{2}/\w{3}/\d{4}:\d{2}:\d{2}:\d{2} -\d{4})]"
    request = r"\"(\S+)\s(\S+)\s*(\S*)\""
    status = r"\s(\d{3})\s"
    bytes_retornados = r"\s(\d+)$"

    logs_df = df.select(
        regexp_extract("value", host, 1).alias("host"),
        regexp_extract("value", timestamp, 1).alias("timestamp"),
        regexp_extract("value", request, 1).alias("metodo"),
        regexp_extract("value", request, 2).alias("endpoint"),
        regexp_extract("value", request, 3).alias("protocolo"),
        regexp_extract("value", status, 1).cast("integer").alias("status"),
        regexp_extract("value", bytes_retornados, 1)
        .cast("integer")
        .alias("bytes_retornados"),
    )

    # Tratando os dados
    # Nulos
    logs_df = logs_df.na.fill({"bytes_retornados": 0})

    logs_df = logs_df.na.drop()

    # Timestamp
    logs_df = logs_df.withColumn("timestamp", split(logs_df["timestamp"], " ").getItem(0))

    format = "dd/MMM/yyyy':'HH:mm:ss"
    logs_df = logs_df.withColumn(
        "timestamp", unix_timestamp("timestamp", format).cast("timestamp")
    )

    # Cache para reaproveitar o dataframe
    logs_df.cache()

    # 1.1. Count por hosts
    host_count = (
        logs_df.groupBy("host")
        .agg(count("host").alias("count_host"))
        .orderBy("count_host", ascending=False)
    )
    host_count.write.mode("append").format("parquet").saveAsTable("hosts_count")

    # 3. Os URLs que mais causaram erro 404
    urls_404_count = (
        logs_df.filter(logs_df.status == 404)
        .groupBy("endpoint")
        .agg(count("endpoint").alias("count_endpoint"))
    )
    urls_404_count.write.mode("append").format("parquet").saveAsTable("urls_404_count")

    # 4. Qtde de erros 404 por dia
    byDay_404 = (
        logs_df.filter(logs_df.status == 404)
        .groupBy(
            dayofmonth("timestamp").alias("dayofmonth"), month("timestamp").alias("month")
        )
        .agg(count("endpoint").alias("count_erros"))
        .orderBy("month", "dayofmonth")
    )
    byDay_404.write.mode("append").format("parquet").saveAsTable("byDay_404")


if __name__ == "__main__":
    main()
