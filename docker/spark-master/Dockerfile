FROM gbieul/spark-base-hadoop:2.4.6

ENV SPARK_MASTER_PORT 7077
ENV SPARK_MASTER_WEBUI_PORT 8080
ENV SPARK_MASTER_LOG /spark/logs

COPY config/hive/*.xml $HIVE_HOME/conf/
COPY config/hive/*.xml $SPARK_HOME/conf/

COPY config/hadoop/masters $HADOOP_HOME/conf/
COPY config/hadoop/slaves $HADOOP_HOME/conf/

EXPOSE 8080 7077 6066 7001 8030 8031 8032 2181 2888 3888

ENTRYPOINT ["/bin/bash", "bootstrap.sh"]