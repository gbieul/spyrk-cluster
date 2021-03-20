#!/usr/local/bin/python3

import findspark
from pyspark.sql.session import SparkSession

# Inicializando Spark
findspark.init("/usr/spark-2.4.6/")

spark = (
    SparkSession.builder.appName("sparksubmit_test_app")
    .config("spark.sql.warehouse.dir", "hdfs:///user/hive/warehouse")
    .config("spark.sql.catalogImplementation", "hive")
    .getOrCreate()
)


def main():

    df = spark.read.text("hdfs://spark-master:9000/datasets/")  # noqa: F841

    # ToDo - Implemente o que tem que fazer


if __name__ == "__main__":
    main()
