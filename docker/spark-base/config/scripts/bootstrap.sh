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
    ./usr/apache-zookeeper-3.6.1-bin/bin/zkServer.sh start

    # Configs de Kafka
    # Adiciona quebra de linha
    sed -i 's/$/\n/' /usr/kafka/config/server.properties
    # Adiciona o id do Broker
    echo "broker.id=0" >> /usr/kafka/config/server.properties

    # Configs de Hive
    mysql -u root -Bse "CREATE DATABASE metastore; USE metastore; SOURCE /usr/hive/scripts/metastore/upgrade/mysql/hive-schema-2.3.0.mysql.sql; CREATE USER 'hive'@'localhost' IDENTIFIED BY 'password'; REVOKE ALL PRIVILEGES, GRANT OPTION FROM 'hive'@'localhost'; GRANT ALL PRIVILEGES ON metastore.* TO 'hive'@'localhost' IDENTIFIED BY 'password'; FLUSH PRIVILEGES; quit;"

    cd /user_data
    jupyter trust *.ipynb
    jupyter notebook --ip=0.0.0.0 --port=8888 --no-browser --allow-root --NotebookApp.token='' --NotebookApp.password='' &

    # Kafka
    cd /
    ./usr/kafka/bin/kafka-server-start.sh ./usr/kafka/config/server.properties &

    # Inicio do serviço do Hive. Deixar por ultimo pois ele bloqueia a execução dos demais
    hive --service metastore &

else
    # Configs de Zookeper para workers
    touch /var/lib/zookeeper/myid
    echo "$((${HOSTNAME: -1}+1))" >> /var/lib/zookeeper/myid

    # Configs de Kafka
    sed -i 's/$/\n/' /usr/kafka/config/server.properties
    echo "broker.id=$((${HOSTNAME: -1}+1))" >> /usr/kafka/config/server.properties

    # Configs de HDFS nos Datanodes
    $HADOOP_HOME/sbin/hadoop-daemon.sh start datanode &
    $HADOOP_HOME/bin/yarn nodemanager &
    
    # Inicio do serviço do Zookeeper
    ./usr/apache-zookeeper-3.6.1-bin/bin/zkServer.sh start &

    # Kafka
    ./usr/kafka/bin/kafka-server-start.sh ./usr/kafka/config/server.properties

fi
#bash
while :; do :; done & kill -STOP $! && wait $!
