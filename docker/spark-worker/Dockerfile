FROM gbieul/spark-base-hadoop:2.4

COPY start-worker.sh /

ENV SPARK_WORKER_WEBUI_PORT 8081
ENV SPARK_MASTER "spark://spark-master:7077"
ENV SPARK_WORKER_LOG /spark/logs
#ENV SPARK_WORKER_OPTS -Dspark.driver.port=7001
ENV YARN_CONF_DIR $HADOOP_CONF_DIR

EXPOSE 8081 9999 7001 8030 8031 8032

# CMD ["/bin/bash", "/start-worker.sh"]
ENTRYPOINT ["/bin/bash", "bootstrap.sh"]