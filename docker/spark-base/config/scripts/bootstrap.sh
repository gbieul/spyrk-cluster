#!/bin/bash

hdfs namenode -format
/etc/init.d/ssh start
if [[ $HOSTNAME = spark-master ]]; then
    
    $HADOOP_HOME/sbin/start-dfs.sh
    $HADOOP_HOME/sbin/start-yarn.sh
    hdfs dfs -mkdir /user_data
    hdfs dfs -put /code/*.txt /user_data
    #start-master.sh

else
    # useradd hadoop
    $HADOOP_HOME/sbin/hadoop-daemon.sh start datanode
    $HADOOP_HOME/bin/yarn nodemanager
fi
#bash
while :; do :; done & kill -STOP $! && wait $!








