FROM openjdk:8-jdk-slim

# Variaveis de ambiente do Hadoop
ENV HADOOP_VERSION 2.7.3
ENV HADOOP_HOME /usr/hadoop-$HADOOP_VERSION
ENV HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop

# Variaveis de ambiente do Hive
ENV HIVE_VERSION 2.3.7
ENV HIVE_HOME=/usr/hive

# Variaveis de ambiente do Scala
ENV SCALA_HOME=/usr/scala
ENV PATH=$PATH:$SCALA_HOME/bin

# Variaveis de ambiente do Zookeeper
ENV ZOOKEEPER_VERSION 3.6.1
ENV ZOOKEEPER_HOME /usr/apache-zookeeper-$ZOOKEEPER_VERSION-bin

# Variaveis de ambiente do Kafka
ENV KAFKA_HOME=/usr/kafka

# Classpath para localizar os jars com as classes necessarias
ENV CLASSPATH=$CLASSPATH:$HADOOP_HOME/lib:$HIVE_HOME/lib:$SCALA_HOME/lib:$KAFKA_HOME/lib

# Variaveis de ambiente do Spark
ENV SPARK_VERSION 2.4.6
ENV SPARK_PACKAGE spark-${SPARK_VERSION}-bin-hadoop2.7
ENV SPARK_HOME /usr/spark-${SPARK_VERSION}
ENV SPARK_DIST_CLASSPATH="$HADOOP_HOME/etc/hadoop/*:$HADOOP_HOME/share/hadoop/common/lib/*:$HADOOP_HOME/share/hadoop/common/*:$HADOOP_HOME/share/hadoop/hdfs/*:$HADOOP_HOME/share/hadoop/hdfs/lib/*:$HADOOP_HOME/share/hadoop/hdfs/*:$HADOOP_HOME/share/hadoop/yarn/lib/*:$HADOOP_HOME/share/hadoop/yarn/*:$HADOOP_HOME/share/hadoop/mapreduce/lib/*:$HADOOP_HOME/share/hadoop/mapreduce/*:$HADOOP_HOME/share/hadoop/tools/lib/*"

# Configuracoes do pyspark
ENV PYSPARK_PYTHON python3

# Usar python3 para modo cluster, e jupyter + configuracao de PYSPARK_DRIVER_PYTHON_OPTS='notebook' para modo interativo
ENV PYSPARK_DRIVER_PYTHON=python3
#ENV PYSPARK_DRIVER_PYTHON=jupyter
#ENV PYSPARK_DRIVER_PYTHON_OPTS='notebook'

# Adicao de valores aos paths abaixo para que os componentes os localizem
ENV PYTHONPATH $SPARK_HOME/python:$SPARK_HOME/python/lib/py4j-0.10.7-src.zip:/usr/bin/python3
ENV PATH $PATH:$JAVA_HOME/bin:$HADOOP_HOME/bin:$SPARK_HOME/bin:$SPARK_HOME/python:$SPARK_HOME/python/lib/py4j-0.10.7-src.zip:$PYTHONPATH:$HIVE_HOME/bin:$KAFKA_HOME/bin:$SCALA_HOME/bin

COPY /config/jupyter/requirements.txt /

# Ajustes e instalação dos componentes do cluster
RUN apt-get update \
    && apt-get install -y wget vim ssh openssh-server curl iputils-ping \
    python3 python3-pip python3-dev \
    build-essential libssl-dev libffi-dev libpq-dev mariadb-server libmariadb-java \
    && python3 -m pip install -r requirements.txt \
    && python3 -m pip install dask[bag] --upgrade \
    && python3 -m pip install --upgrade toree \
    && python3 -m bash_kernel.install \
    && mkdir datasets \
    #&& cd /datasets \
    #&& wget ftp://ita.ee.lbl.gov/traces/NASA_access_log_Jul95.gz \
    #&& wget ftp://ita.ee.lbl.gov/traces/NASA_access_log_Aug95.gz \
    #&& gzip -d NASA_access_log_Aug95.gz \
    #&& mv NASA_access_log_Aug95 NASA_access_log_Aug95.txt \
    #&& gzip -d NASA_access_log_Jul95.gz \
    #&& mv NASA_access_log_Jul95 NASA_access_log_Jul95.txt \
    # && cd / \
    # Hadoop
    && curl -sL --retry 3 \
    "http://archive.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz" \
    | gunzip \
    | tar -x -C /usr/ \
    && rm -rf ${HADOOP_HOME}/share/doc \
    && chown -R root:root ${HADOOP_HOME} \
    # Spark
    && curl -sL --retry 3 \
    "http://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop2.7.tgz" \
    | gunzip \
    | tar x -C /usr/ \
    && mv /usr/${SPARK_PACKAGE} ${SPARK_HOME} \
    && chown -R root:root ${SPARK_HOME} \
    # Hive
    && wget \
    http://ftp.unicamp.br/pub/apache/hive/hive-${HIVE_VERSION}/apache-hive-${HIVE_VERSION}-bin.tar.gz \
    && tar zxvf apache-hive-${HIVE_VERSION}-bin.tar.gz \
    && rm apache-hive-${HIVE_VERSION}-bin.tar.gz \
    && mv apache-hive-${HIVE_VERSION}-bin /usr/hive \
    && cp ${HIVE_HOME}/conf/hive-env.sh.template ${HIVE_HOME}/conf/hive-env.sh && echo "export HADOOP_HOME=/usr/hadoop-${HADOOP_VERSION}/" >> ${HIVE_HOME}/conf/hive-env.sh \
    # Configurando o conector do metastore do Hive
    && ln -s /usr/share/java/mariadb-java-client.jar ${HIVE_HOME}/lib/mariadb-java-client.jar \
    # Zookeeper
    && wget \
    https://downloads.apache.org/zookeeper/zookeeper-${ZOOKEEPER_VERSION}/apache-zookeeper-${ZOOKEEPER_VERSION}-bin.tar.gz \
    && tar -zvxf apache-zookeeper-${ZOOKEEPER_VERSION}-bin.tar.gz \
    && rm apache-zookeeper-${ZOOKEEPER_VERSION}-bin.tar.gz \
    && mv apache-zookeeper-${ZOOKEEPER_VERSION}-bin /usr/apache-zookeeper-${ZOOKEEPER_VERSION}-bin \
    && mkdir /var/lib/zookeeper \
    # Scala
    && wget \
    https://downloads.lightbend.com/scala/2.11.0/scala-2.11.0.tgz \
    && tar -zvxf scala-2.11.0.tgz \
    && rm scala-2.11.0.tgz \
    && mv /scala-2.11.0 /usr/scala \
    # Kafka
    && wget \
    https://archive.apache.org/dist/kafka/2.3.0/kafka_2.11-2.3.0.tgz \
    && tar -zvxf kafka_2.11-2.3.0.tgz \
    && rm kafka_2.11-2.3.0.tgz \
    && mv kafka_2.11-2.3.0 /usr/kafka \
    # Configurando o JAVA_HOME para os processos localizarem a instalação do Java
    && echo "export JAVA_HOME=${JAVA_HOME}" >> /etc/environment

# Keys dos nodes. Necessarias para se comunicarem por SSH
RUN ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa && \
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys && \
    chmod 600 ~/.ssh/authorized_keys
COPY /config/config /root/.ssh
RUN chmod 600 /root/.ssh/config

# Todos os arquivos de configuracao que devem ser copiados para dentro do
# container estao aqui
COPY config/spark ${SPARK_HOME}/conf/
COPY config/hadoop/*.xml /usr/hadoop-${HADOOP_VERSION}/etc/hadoop/
COPY config/hadoop/*.sh /usr/hadoop-${HADOOP_VERSION}/etc/hadoop/
COPY config/scripts /
COPY config/zookeeper ${ZOOKEEPER_HOME}/conf/
COPY config/kafka ${KAFKA_HOME}/config

# Portas 2181 2888 e 3888 relativas ao Zookeper, 9092 ao Kafka
EXPOSE 9000 4040 8020 22 9083 2181 2888 3888 9092

# Algumas configuracoes adicionais e inicio de alguns servicoes que devem ser feitos em
# tempo de execucao estao presentes no script bootstrap.
# Este cuidará de colocar alguns datasets exemplo dentro do HDFS, bem como de iniciar 
# servicos como HDFS (formatando Namenode), iniciando o Hive, definindo o ID do 
# Zookeeper para que suas diferentes instâncias possam se ver e iniciando este servico.
# O comando ENTRYPOINT define que este script será executado quando os containeres
# iniciarem.
ENTRYPOINT ["/bin/bash", "bootstrap.sh"]
