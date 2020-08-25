FROM openjdk:16-jdk-slim

ENV HADOOP_VERSION 2.7.3
ENV HADOOP_HOME /usr/hadoop-$HADOOP_VERSION
ENV HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop

ENV SPARK_VERSION 2.4.6
ENV SPARK_PACKAGE spark-${SPARK_VERSION}-bin-hadoop2.7
ENV SPARK_HOME /usr/spark-${SPARK_VERSION}
ENV SPARK_DIST_CLASSPATH="$HADOOP_HOME/etc/hadoop/*:$HADOOP_HOME/share/hadoop/common/lib/*:$HADOOP_HOME/share/hadoop/common/*:$HADOOP_HOME/share/hadoop/hdfs/*:$HADOOP_HOME/share/hadoop/hdfs/lib/*:$HADOOP_HOME/share/hadoop/hdfs/*:$HADOOP_HOME/share/hadoop/yarn/lib/*:$HADOOP_HOME/share/hadoop/yarn/*:$HADOOP_HOME/share/hadoop/mapreduce/lib/*:$HADOOP_HOME/share/hadoop/mapreduce/*:$HADOOP_HOME/share/hadoop/tools/lib/*"

ENV PYSPARK_PYTHON python3
ENV PYSPARK_DRIVER_PYTHON=python3

ENV PATH $PATH:$JAVA_HOME/bin:$HADOOP_HOME/bin:$SPARK_HOME/bin
# ENV PATH $PATH:$JAVA_HOME/bin:$HADOOP_HOME/bin:$SPARK_HOME/bin

RUN apt-get update && \
    apt-get install -y wget vim ssh openssh-server curl
RUN apt update && apt install -y python3 python3-pip python3-dev build-essential libssl-dev libffi-dev libpq-dev

# RUN apk --update --no-cache add coreutils procps vim rsync openssh-keygen openssh-client openssh-server openrc

RUN python3 -m pip install findspark==1.4.2

RUN mkdir code && \
cd /code && \
wget ftp://ita.ee.lbl.gov/traces/NASA_access_log_Jul95.gz &&\
wget ftp://ita.ee.lbl.gov/traces/NASA_access_log_Aug95.gz &&\
gzip -d NASA_access_log_Aug95.gz &&\
mv NASA_access_log_Aug95 NASA_access_log_Aug95.txt &&\
gzip -d NASA_access_log_Jul95.gz &&\
mv NASA_access_log_Jul95 NASA_access_log_Jul95.txt &&\
cd /

# Hadoop
RUN curl -sL --retry 3 \
"http://archive.apache.org/dist/hadoop/common/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz" \
| gunzip \
| tar -x -C /usr/ \
&& rm -rf $HADOOP_HOME/share/doc \
&& chown -R root:root $HADOOP_HOME \
# spark
&& curl -sL --retry 3 \
"http://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop2.7.tgz" \
| gunzip \
| tar x -C /usr/ \
&& mv /usr/$SPARK_PACKAGE $SPARK_HOME \
&& chown -R root:root $SPARK_HOME

RUN ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa && \
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys && \
chmod 600 ~/.ssh/authorized_keys

COPY /config/config /root/.ssh
RUN chmod 600 /root/.ssh/config

COPY config/spark ${SPARK_HOME}/conf/

COPY config/hadoop/*.xml /usr/hadoop/etc/hadoop/
COPY config/hadoop/*.sh /usr/hadoop/etc/hadoop/
COPY config/workers /usr/hadoop/etc/hadoop
COPY config/scripts /
RUN echo "export JAVA_HOME=${JAVA_HOME}" >> /etc/environment

EXPOSE 9000 4040 8020 22

ENTRYPOINT ["/bin/bash", "bootstrap.sh"]
