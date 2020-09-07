#!/bin/bash

hdfs namenode -format
/etc/init.d/ssh start
if [[ $HOSTNAME = spark-master ]]; then
    
    # Configs de Hadoop
    $HADOOP_HOME/sbin/start-dfs.sh
    $HADOOP_HOME/sbin/start-yarn.sh
    service mysql start
    hdfs dfs -mkdir /datasets
    hdfs dfs -mkdir /datasets_processed
    hdfs dfs -put /datasets/*.txt /datasets

    # Configs de Zookeeper
    touch /var/lib/zookeeper/myid
    echo "1" >> /var/lib/zookeeper/myid
    echo "Zookeeper: myid 1 criado"
    ./usr/apache-zookeeper-3.6.1-bin/bin/zkServer.sh start-foreground

    # Configs de Hive
    mysql -u root -Bse "CREATE DATABASE metastore; USE metastore; SOURCE /usr/hive/scripts/metastore/upgrade/mysql/hive-schema-2.3.0.mysql.sql; CREATE USER 'hive'@'localhost' IDENTIFIED BY 'password'; REVOKE ALL PRIVILEGES, GRANT OPTION FROM 'hive'@'localhost'; GRANT ALL PRIVILEGES ON metastore.* TO 'hive'@'localhost' IDENTIFIED BY 'password'; FLUSH PRIVILEGES; quit;"

    cd /user_data
    jupyter trust Dask-Yarn.ipynb
    jupyter trust Python-Spark.ipynb
    jupyter trust Scala-Spark.ipynb
    jupyter notebook --ip=0.0.0.0 --port=8888 --no-browser --allow-root --NotebookApp.token='' --NotebookApp.password='' &

    # Inicio do serviço do Hive
    hive --service metastore

else
    # Configs de Zookeper para workers
    touch /var/lib/zookeeper/myid
    echo "$((${HOSTNAME: -1}+1))" >> /var/lib/zookeeper/myid
    echo "Zookeeper: $HOSTNAME myid criado"

    # Configs de HDFS nos Datanodes
    $HADOOP_HOME/sbin/hadoop-daemon.sh start datanode &
    $HADOOP_HOME/bin/yarn nodemanager &
    
    # Inicio do serviço do Zookeeper
    ./usr/apache-zookeeper-3.6.1-bin/bin/zkServer.sh start
fi
#bash
while :; do :; done & kill -STOP $! && wait $!









