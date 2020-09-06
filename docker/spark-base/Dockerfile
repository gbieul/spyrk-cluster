FROM openjdk:8-jdk-slim

ENV HADOOP_VERSION 2.7.3
ENV HADOOP_HOME /usr/hadoop-$HADOOP_VERSION
ENV HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop

ENV HIVE_VERSION 2.3.7
ENV HIVE_HOME=/usr/hive
ENV CLASSPATH $CLASSPATH:/usr/hadoop-$HADOOP_VERSION/lib/*:.
ENV CLASSPATH $CLASSPATH:/usr/hive/lib/*:.

ENV SPARK_VERSION 2.4.6
ENV SPARK_PACKAGE spark-${SPARK_VERSION}-bin-hadoop2.7
ENV SPARK_HOME /usr/spark-${SPARK_VERSION}
ENV SPARK_DIST_CLASSPATH="$HADOOP_HOME/etc/hadoop/*:$HADOOP_HOME/share/hadoop/common/lib/*:$HADOOP_HOME/share/hadoop/common/*:$HADOOP_HOME/share/hadoop/hdfs/*:$HADOOP_HOME/share/hadoop/hdfs/lib/*:$HADOOP_HOME/share/hadoop/hdfs/*:$HADOOP_HOME/share/hadoop/yarn/lib/*:$HADOOP_HOME/share/hadoop/yarn/*:$HADOOP_HOME/share/hadoop/mapreduce/lib/*:$HADOOP_HOME/share/hadoop/mapreduce/*:$HADOOP_HOME/share/hadoop/tools/lib/*"

ENV PYSPARK_PYTHON python3

# Usar python3 para modo cluster, e jupyter + configuracao de PYSPARK_DRIVER_PYTHON_OPTS='notebook' para modo interativo
ENV PYSPARK_DRIVER_PYTHON=python3
#ENV PYSPARK_DRIVER_PYTHON=jupyter
#ENV PYSPARK_DRIVER_PYTHON_OPTS='notebook'

ENV PYTHONPATH $SPARK_HOME/python:$SPARK_HOME/python/lib/py4j-0.10.7-src.zip:/usr/bin/python3

ENV PATH $PATH:$JAVA_HOME/bin:$HADOOP_HOME/bin:$SPARK_HOME/bin:$SPARK_HOME/python:$SPARK_HOME/python/lib/py4j-0.10.7-src.zip:$PYTHONPATH:$HIVE_HOME/bin

RUN apt-get update && \
    apt-get install -y wget vim ssh openssh-server curl
RUN apt update && apt install -y python3 python3-pip python3-dev \
    build-essential libssl-dev libffi-dev libpq-dev mariadb-server libmariadb-java

COPY /config/jupyter/requirements.txt /
RUN python3 -m pip install -r requirements.txt
RUN python3 -m pip install dask[bag] --upgrade
RUN python3 -m pip install --upgrade toree
RUN python3 -m bash_kernel.install

RUN mkdir datasets && \
cd /datasets && \
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
&& chown -R root:root $SPARK_HOME \
#hive
&& wget http://ftp.unicamp.br/pub/apache/hive/hive-$HIVE_VERSION/apache-hive-$HIVE_VERSION-bin.tar.gz \
&& tar zxvf apache-hive-$HIVE_VERSION-bin.tar.gz \
&& rm apache-hive-$HIVE_VERSION-bin.tar.gz \
&& mv apache-hive-$HIVE_VERSION-bin /usr/hive \
&& cp $HIVE_HOME/conf/hive-env.sh.template $HIVE_HOME/conf/hive-env.sh && echo "export HADOOP_HOME=/usr/hadoop-$HADOOP_VERSION/" >> $HIVE_HOME/conf/hive-env.sh

# Nodes keys
RUN ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa && \
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys && \
chmod 600 ~/.ssh/authorized_keys
COPY /config/config /root/.ssh
RUN chmod 600 /root/.ssh/config

# Configurando o conector do metastore do Hive
RUN ln -s /usr/share/java/mariadb-java-client.jar $HIVE_HOME/lib/mariadb-java-client.jar

# Todos os arquivos de configuracao aqui
COPY config/spark ${SPARK_HOME}/conf/
COPY config/hadoop/*.xml /usr/hadoop-$HADOOP_VERSION/etc/hadoop/
COPY config/hadoop/*.sh /usr/hadoop-$HADOOP_VERSION/etc/hadoop/
COPY config/scripts /

# Configurando o JAVA_HOME para os processos localizarem a instalação do Java
RUN echo "export JAVA_HOME=${JAVA_HOME}" >> /etc/environment

EXPOSE 9000 4040 8020 22 9083

ENTRYPOINT ["/bin/bash", "bootstrap.sh"]
