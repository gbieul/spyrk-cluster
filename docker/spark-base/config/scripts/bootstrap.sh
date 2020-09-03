#!/bin/bash

hdfs namenode -format
/etc/init.d/ssh start
if [[ $HOSTNAME = spark-master ]]; then
    
    $HADOOP_HOME/sbin/start-dfs.sh
    $HADOOP_HOME/sbin/start-yarn.sh
    service mysql start
    hdfs dfs -mkdir /datasets
    hdfs dfs -mkdir /datasets_processed
    hdfs dfs -put /datasets/*.txt /datasets

    mysql -u root -Bse "CREATE DATABASE metastore; USE metastore; SOURCE /usr/hive/scripts/metastore/upgrade/mysql/hive-schema-2.3.0.mysql.sql; CREATE USER 'hive'@'localhost' IDENTIFIED BY 'password'; quit;"
    
    cd /user_data
    jupyter trust Dask-Yarn.ipynb
    jupyter trust Python-Spark.ipynb
    jupyter trust Scala-Spark.ipynb
    jupyter notebook --ip=0.0.0.0 --port=8888 --no-browser --allow-root --NotebookApp.token='' --NotebookApp.password='' &

else
    # useradd hadoop
    $HADOOP_HOME/sbin/hadoop-daemon.sh start datanode
    $HADOOP_HOME/bin/yarn nodemanager
fi
#bash
while :; do :; done & kill -STOP $! && wait $!








