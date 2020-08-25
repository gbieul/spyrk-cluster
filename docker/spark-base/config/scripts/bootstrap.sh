#!/bin/bash

hdfs namenode -format
/etc/init.d/ssh start
if [[ $HOSTNAME = spark-master ]]; then
    
    $HADOOP_HOME/sbin/start-dfs.sh
    $HADOOP_HOME/sbin/start-yarn.sh
    #start-master.sh

else
    # useradd hadoop
    /usr/hadoop-2.7.3/bin/hadoop-daemon.sh start datanode
    /usr/hadoop-2.7.3/bin/yarn nodemanager

fi
#bash
while :; do :; done & kill -STOP $! && wait $!








