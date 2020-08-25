#!/bin/bash

/etc/init.d/ssh start
hdfs namenode -format
if [[ $HOSTNAME = spark-master ]]; then
    
    $HADOOP_HOME/sbin/start-dfs.sh
    $HADOOP_HOME/sbin/start-yarn.sh
    #start-master.sh

fi
#bash
while :; do :; done & kill -STOP $! && wait $!








