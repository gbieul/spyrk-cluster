FROM openjdk:8-jdk-alpine

ENV HADOOP_VERSION 2.7.3
ENV HADOOP_HOME /usr/hadoop-$HADOOP_VERSION
ENV HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop

ENV SPARK_VERSION 2.4.6
ENV SPARK_PACKAGE spark-${SPARK_VERSION}-bin-without-hadoop
ENV SPARK_HOME /usr/spark-${SPARK_VERSION}
ENV SPARK_DIST_CLASSPATH="$HADOOP_HOME/etc/hadoop/*:$HADOOP_HOME/share/hadoop/common/lib/*:$HADOOP_HOME/share/hadoop/common/*:$HADOOP_HOME/share/hadoop/hdfs/*:$HADOOP_HOME/share/hadoop/hdfs/lib/*:$HADOOP_HOME/share/hadoop/hdfs/*:$HADOOP_HOME/share/hadoop/yarn/lib/*:$HADOOP_HOME/share/hadoop/yarn/*:$HADOOP_HOME/share/hadoop/mapreduce/lib/*:$HADOOP_HOME/share/hadoop/mapreduce/*:$HADOOP_HOME/share/hadoop/tools/lib/*"

ENV PYSPARK_PYTHON python3
ENV PYSPARK_DRIVER_PYTHON=python3

ENV PATH $PATH:$JAVA_HOME/bin:$HADOOP_HOME/bin:$SPARK_HOME/bin

# Conda envs
ENV CONDA_DIR=/opt/conda CONDA_VER=4.3.14
ENV PATH=$CONDA_DIR/bin:$PATH SHELL=/bin/bash LANG=C.UTF-8

# Conda
RUN set -ex \
  && apk add --no-cache bash \
  && apk add --virtual .fetch-deps --no-cache ca-certificates wget curl \
  \
  && wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub \
  && wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.28-r0/glibc-2.28-r0.apk \
  && apk add --virtual .conda-deps glibc-2.28-r0.apk \
  \
  && mkdir -p $CONDA_DIR  \
  && echo export PATH=$CONDA_DIR/bin:'$PATH' > /etc/profile.d/conda.sh \
  && wget https://repo.continuum.io/miniconda/Miniconda3-${CONDA_VER}-Linux-x86_64.sh -O miniconda.sh \
  && bash miniconda.sh -f -b -p $CONDA_DIR \
  && rm miniconda.sh \
  \
  && conda update conda \
  \
  # hadoop
  && curl -sL --retry 3 \
  "http://archive.apache.org/dist/hadoop/common/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz" \
  | gunzip \
  | tar -x -C /usr/ \
  && rm -rf $HADOOP_HOME/share/doc \
  && chown -R root:root $HADOOP_HOME \
  # spark
  && curl -sL --retry 3 \
  "https://www.apache.org/dyn/mirrors/mirrors.cgi?action=download&filename=spark/spark-${SPARK_VERSION}/${SPARK_PACKAGE}.tgz" \
  | gunzip \
  | tar x -C /usr/ \
  && mv /usr/$SPARK_PACKAGE $SPARK_HOME \
  && chown -R root:root $SPARK_HOME \
  # cleanup
  && apk del .fetch-deps

  RUN apk --update add coreutils procps vim rsync

  RUN python3 -m pip install findspark==1.4.2

  RUN mkdir code && \
  cd /code && \
  wget ftp://ita.ee.lbl.gov/traces/NASA_access_log_Jul95.gz &&\
  wget ftp://ita.ee.lbl.gov/traces/NASA_access_log_Aug95.gz &&\
  gzip -d NASA_access_log_Aug95.gz &&\
  mv NASA_access_log_Aug95 NASA_access_log_Aug95.txt &&\
  gzip -d NASA_access_log_Jul95.gz &&\
  mv NASA_access_log_Jul95 NASA_access_log_Jul95.txt

  COPY config/ ${SPARK_HOME}/conf

CMD ["/bin/bash"]
