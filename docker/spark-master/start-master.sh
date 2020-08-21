#!/bin/bash

export SPARK_MASTER_HOST=`hostname`

. "/usr/spark-2.4.6/sbin/spark-config.sh"

. "/usr/spark-2.4.6/bin/load-spark-env.sh"

mkdir -p $SPARK_MASTER_LOG

#export SPARK_HOME=/usr/spark-2.4.6

ln -sf /dev/stdout $SPARK_MASTER_LOG/spark-master.out

cd /usr/spark-2.4.6/bin && /usr/spark-2.4.6/sbin/../bin/spark-class org.apache.spark.deploy.master.Master --ip $SPARK_MASTER_HOST --port $SPARK_MASTER_PORT --webui-port $SPARK_MASTER_WEBUI_PORT >> $SPARK_MASTER_LOG/spark-master.out