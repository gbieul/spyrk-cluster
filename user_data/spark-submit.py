#!/usr/local/bin/python3

import findspark, os, re

# Criando Spark Context
from pyspark import SparkContext
from pyspark.sql.context import SQLContext
from pyspark.sql.session import SparkSession

# Functions
from pyspark.sql.functions import *

# Inicializando Spark
findspark.init()

sc = SparkContext("local", "nasa_data")
sqlContext = SQLContext(sc)
spark = SparkSession(sc)

def main():

    df = spark.read.text('code')

    # Montando dataframe
    host = r'(^\S+\.[\S+\.]+\S+)\s'
    timestamp = r'\[(\d{2}/\w{3}/\d{4}:\d{2}:\d{2}:\d{2} -\d{4})]'
    request = r'\"(\S+)\s(\S+)\s*(\S*)\"'
    status = r'\s(\d{3})\s'
    bytes_retornados = r'\s(\d+)$'

    logs_df = df.select(regexp_extract('value', host, 1).alias('host'),
                        regexp_extract('value', timestamp, 1).alias('timestamp'),
                        regexp_extract('value', request, 1).alias('metodo'),
                        regexp_extract('value', request, 2).alias('endpoint'),
                        regexp_extract('value', request, 3).alias('protocolo'),
                        regexp_extract('value', status, 1).cast('integer').alias('status'),
                        regexp_extract('value', bytes_retornados, 1).cast('integer').alias('bytes_retornados'))

    # Tratando os dados ausentes
    logs_df = logs_df.na.fill({'bytes_retornados': 0})

    logs_df = logs_df.na.drop()

    logs_df = logs_df.withColumn("timestamp", split(logs_df["timestamp"], " ").getItem(0))
    
    format = "dd/MMM/yyyy':'HH:mm:ss"
    logs_df = logs_df.withColumn('timestamp', unix_timestamp('timestamp', format).cast('timestamp'))

    # Salvando csv. Repartition com valor 1 apenas por termos poucos dados
    logs_df.repartition(1).write.csv(path='/code/1_1_host_count', mode="append", header="true")

 
if __name__ == "__main__":
    main()