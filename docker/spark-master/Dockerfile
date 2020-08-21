FROM gbieul/spark-base:2.4

COPY start-master.sh /

ENV SPARK_MASTER_PORT 7077
ENV SPARK_MASTER_WEBUI_PORT 8080
ENV SPARK_MASTER_LOG /spark/logs

COPY start-master.sh /

EXPOSE 8080 7077 6066

CMD ["/bin/bash", "/start-master.sh"]