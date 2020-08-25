FROM gbieul/spark-base-hadoop:2.4

COPY start-worker.sh /

ENV SPARK_WORKER_WEBUI_PORT 8081
ENV SPARK_MASTER "spark://spark-master:7077"
ENV SPARK_WORKER_LOG /spark/logs

EXPOSE 8081

# CMD ["/bin/bash", "/start-worker.sh"]
ENTRYPOINT ["/bin/bash", "bootstrap.sh"]