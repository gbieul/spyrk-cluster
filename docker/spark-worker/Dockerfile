FROM gbieul/spark-base-hadoop:2.4.6

ENV SPARK_WORKER_WEBUI_PORT 8081
ENV SPARK_MASTER "spark://spark-master:7077"
ENV SPARK_WORKER_LOG /spark/logs
ENV YARN_CONF_DIR $HADOOP_CONF_DIR

COPY config/hive/*.xml $HIVE_HOME/conf/
COPY config/hive/*.xml $SPARK_HOME/conf/

EXPOSE 8081 9999 7001 8030 8031 8032 2181 2888 3888

ENTRYPOINT ["/bin/bash", "bootstrap.sh"]