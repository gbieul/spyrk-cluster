# Spyrk-cluster: um mini-laboratório de dados

O objetivo deste repositório é funcionar como um mini-cluster, tendo todas as configurações básicas realizadas para as tecnologias distribuídas como Hadoop e Spark (até então). Pode-se utilizá-lo como referência para configurações, ou mesmo como uma ferramenta para análises exploratórias de algum dataset que interessar.

A constituição deste repositório levou em conta alguma parte do trabalho de <a href="https://lemaizi.com/blog/creating-your-own-micro-cluster-lab-using-docker-to-experiment-with-spark-dask-on-yarn/">Amine Lemaizi</a>, porém considerando uma arquitetura com outro worker, uma estrutura própria de diretórios, uma imagem Docker inicial diferente -- aqui começamos com uma imagem do openjdk ao invés do Ubuntu --, uma propagação diferente das imagens Docker, diretório SPARK_HOME diferente, bind mount de diretórios, além de possuir algumas estruturas (como mapeamento de portas) para permitir o Spark no modo Standalone também, dentre outras questões menores como nome dos containers e algumas configurações.

Nas sessões abaixo há referências sobre a prória estrutura do diretório e das principais configurações.

Alguns recursos deste mini-lab:
- HDFS
- Spark
- Hive
- Dask
- Modo cluster ou interativo
- Jupyter (para modo interativo apenas)
- Bibliotecas Python (vide `/docker/spark-base/jupyter/requirements.txt`)

**TL;DR - Quero saber apenas <a href="https://github.com/gbieul/spark-cluster/tree/master#14-como-usar">como usar</a>**

## 1.1. - A árvore do diretório

    .
    ├── build-images.sh
    ├── docker
    │   ├── spark-base
    │   │   ├── config
    │   │   │   ├── config
    │   │   │   ├── hadoop
    │   │   │   │   ├── core-site.xml
    │   │   │   │   ├── hadoop-env.sh
    │   │   │   │   ├── hdfs-site.xml
    │   │   │   │   ├── mapred-site.xml
    │   │   │   │   ├── slaves
    │   │   │   │   └── yarn-site.xml
    │   │   │   ├── hive
    │   │   │   │   └── hive-site.xml
    │   │   │   ├── jupyter
    │   │   │   │   └── requirements.txt
    │   │   │   ├── scripts
    │   │   │   │   └── bootstrap.sh
    │   │   │   └── spark
    │   │   │       ├── log4j.properties
    │   │   │       └── spark-defaults.conf
    │   │   └── Dockerfile
    │   ├── spark-master
    │   │   └── Dockerfile
    │   └── spark-worker
    │       └── Dockerfile
    ├── docker-compose.yml
    ├── env
    │   └── spark-worker.sh
    ├── images
    │   ├── arquitetura.png
    │   ├── Cluster_nodes_applications.png
    │   ├── Hadoop_overview.png
    │   └── resource_node_manager.png
    ├── README.md
    ├── start-spark.sh
    └── user_data
        ├── Dask-Yarn.ipynb
        ├── nasa_data.ipynb
        ├── Python-Spark.ipynb
        ├── Scala-Spark.ipynb
        └── spark-submit.py


Na raíz do diretório estão presentes os arquivos build-images.sh, que faz o build das imagens
docker deste repositório, o arquivo docker-compose.yml, que define a stack com o docker que é
usada com este mini-laboratório, bem como este arquivo README.

No sub-diretório `/docker` constam as imagens docker que funcionam como base e, oriunda desta, as
imagens do master e worker. No sub-diretório `/docker/spark-base`, também consta outro sub-diretó-
rio chamado `docker/spark-base/config`, que tem em cada diretório arquivos de configuração das 
tecnologias usadas aqui. Mais sobre isso abaixo.

Em `/env` consta o arquivo `spark-worker.sh` que cuida de algumas configurações quando lançamos a
stack do docker-compose (pode conferir no arquivo `docker-compose.yml` onde a referência a este
arquivo aparece).

Em `images` existem as imagens mostradas neste diretório e, finalmente, em `user_data` temos alguns
arquivos de exemplo. **Importantíssimo notar:** neste diretório temos um _bind mount_ com o diretório
`/user_data` dentro do container. Dessa maneira, temos o container exposto para testes com quaisquer
arquivos locais que queiramos.

## 1.2. A arquitetura simulada

![Arquitetura simplificada do cluster](images/arquitetura.png?raw=true "Arquitetura Simplificada")

Aqui, para questões de simplicidade (e economia de recursos), temos simulado um cluster composto de
um node master e três nodes workers, cada qual com seus respectivos serviços.

## 1.3. Configurações do cluster

### 1.3.1. slaves
Path: `/docker/spark-base/config/hadoop/slaves`

    master
    spark-worker-1
    spark-worker-2
    spark-worker-3

Neste arquivo estão as referências aos nodes do cluster. Estes nomes conferem com os nomes do containers.

### 1.3.2. core-site.xml
Path: `/docker/spark-base/config/hadoop/core-site.xml`

    <?xml version="1.0"?>
    <?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
    <configuration>
            <property>
                <name>fs.default.name</name>
                <value>hdfs://spark-master:9000</value>
            </property>
    </configuration>

Neste arquivo definimos quem é o master. O valor `spark-master` se refere ao nome do container do master.

### 1.3.3. hdfs-site.xml
Path: `/docker/spark-base/config/hadoop/hdfs-site.xml`

    <?xml version="1.0"?>
    <?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
    <configuration>
        <property>
                <name>dfs.namenode.name.dir</name>
                <value>/usr/hadoop-2.7.3/data/nameNode</value>
        </property>
        <property>
                <name>dfs.datanode.data.dir</name>
                <value>/usr/hadoop-2.7.3/data/dataNode</value>
        </property>
        <property>
                <name>dfs.replication</name>
                <value>3</value>
        </property>
    </configuration>

Aqui definimos algumas propriedades do HDFS, como onde estarão informações relativas ao Namenode ou ao Datanode. Importante notar que o path `/usr/hadoop-2.7.3/` é o mesmo path definido como `HADOOP_HOME` no topo do arquivo `/docker/spark-base/Dockerfile`.

Também se define `dfs.replication` como a quantidade de workers. Note, que caso queira mudar a quantidade de workers no `docker-compose.yml`, você também deverá mudar este parâmetro aqui.

### 1.3.4. yarn-site.xml
Path: `/docker/spark-base/config/hadoop/yarn-site.xml`

    <?xml version="1.0"?>
    <configuration>
            <property>
                    <name>yarn.acl.enable</name>
                    <value>0</value>
            </property>
            <property>
                    <name>yarn.resourcemanager.hostname</name>
                    <value>spark-master</value>
            </property>
            <property>
                    <name>yarn.nodemanager.aux-services</name>
                    <value>mapreduce_shuffle</value>
            </property>
            <property>
                    <name>yarn.nodemanager.resource.cpu-vcores</name>
                    <value>1</value>
            </property>
            <property>
                    <name>yarn.nodemanager.resource.memory-mb</name>
                    <value>1536</value>
            </property>
            <property>
                    <name>yarn.scheduler.minimum-allocation-mb</name>
                    <value>128</value>
            </property>
            <property>
                    <name>yarn.scheduler.maximum-allocation-mb</name>
                    <value>1536</value>
            </property>
            <property>
                    <name>yarn.nodemanager.vmem-check-enabled</name>
                    <value>false</value>
            </property>
            <property>
                    <name>yarn.nodemanager.disk-health-checker.max-disk-utilization-per-disk-percentage</name>
                    <value>99.0</value>
            </property>
    </configuration>

Aqui temos algumas definições de uso de recursos do yarn, bem como a definição de quem é o master em `yarn.resourcemanager.hostname`. Note que o valor `spark-master` aqui também é o nome do container do master.

O parâmetro `yarn.nodemanager.disk-health-checker.max-disk-utilization-per-disk-percentage` aqui é adicionado para se evitar erros de uso de disco ao se trabalhar com o host, mas se recomenda verificação do melhor valor ao se usar com um cluster realmente distribuído.

### 1.3.5. mapred-site.xml
Path: `/docker/spark-base/config/hadoop/mapred-site.xml`

    <?xml version="1.0"?>
    <?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
    <configuration>
    <property>
        <name>mapreduce.framework.name</name>
        <value>yarn</value>
    </property>
    <property>
        <name>yarn.app.mapreduce.am.env</name>
        <value>HADOOP_MAPRED_HOME=$HADOOP_HOME</value>
    </property>
    <property>
        <name>mapreduce.map.env</name>
        <value>HADOOP_MAPRED_HOME=$HADOOP_HOME</value>
    </property>
    <property>
        <name>mapreduce.reduce.env</name>
        <value>HADOOP_MAPRED_HOME=$HADOOP_HOME</value>
    </property>
    <property>
        <name>yarn.app.mapreduce.am.resource.mb</name>
        <value>1536</value>
    </property>
    <property>
        <name>yarn.app.mapreduce.am.command-opts</name>
        <value>400</value>
    </property>
    <property>
        <name>mapreduce.map.memory.mb</name>
        <value>128</value>
    </property>
    <property>
        <name>mapreduce.reduce.memory.mb</name>
        <value>128</value>
    </property>
    <property>
        <name>mapreduce.map.java.opts</name>
        <value>200</value>
    </property>
    <property>
        <name>mapreduce.reduce.java.opts</name>
        <value>400</value>
    </property>
    </configuration>

Aqui configuramos o uso de recursos por parte do MapReduce, bem como apontamos os diretórios definidos nas variáveis de ambiente como HADOOP_HOME, bem como apontamos o yarn como orquestrador.

### 1.3.6. hive-site.xml
Path: `/docker/spark-base/config/hive/hive-site.xml`

    <?xml version="1.0"?>
    <?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
    <configuration>
            <property>
                <name>javax.jdo.option.ConnectionURL</name>
                <value>jdbc:mysql://spark-master/metastore?createDatabaseIfNotExist=true</value>
                <description>the URL of the MySQL database</description>
            </property>

            <property>
                <name>javax.jdo.option.ConnectionDriverName</name>
                <value>org.mariadb.jdbc.Driver</value>
            </property>

            <property>
                <name>javax.jdo.option.ConnectionUserName</name>
                <value>hive</value>
            </property>

            <property>
                <name>javax.jdo.option.ConnectionPassword</name>
                <value>password</value>
            </property>

            <property>
                <name>datanucleus.autoCreateSchema</name>
                <value>false</value>
            </property>

            <property>
                <name>datanucleus.fixedDatastore</name>
                <value>true</value>
            </property>

            <property>
                <name>datanucleus.autoStartMechanism</name> 
                <value>SchemaTable</value>
            </property> 

            <property>
                <name>hive.metastore.uris</name>
                <value>thrift://spark-master:9083</value>
                <description>IP address (or fully-qualified domain name) and port of the metastore host</description>
            </property>

            <property>
                <name>hive.metastore.schema.verification</name>
                <value>true</value>
                </property>
    </configuration>

Aqui fazemos a configuração do Hive. Abaixo um resumo dos principais campos deste arquivo.
- `javax.jdo.option.ConnectionURL` é o endereço da URL do MariaDB. Como aqui estamos operando com containers, `spark-master` substitui o IP;
- `hive.metastore.uris` é o endereço do metastore (incluindo porta). `spark-master` mais uma vez aparece aqui;
- `javax.jdo.option.ConnectionDriverName` define qual o driver do metastore (aqui, um MariaDB);
- `javax.jdo.option.ConnectionUserName` define o nome de usuário que o Hive usará para acessar o metastore. Este usuário `Hive` foi criado no MariaDB também;
- `javax.jdo.option.ConnectionPassword `idem ao usuário, foi a senha `password` definida no metastore.
  
Uma nota: segundo documentação da <a href="https://docs.cloudera.com/documentation/enterprise/5-6-x/topics/cdh_ig_hive_metastore_configure.html">Cloudera</a>, o único parâmetro que deve estar em master e workers é o `hive.metastore.uris`, sendo os demais apenas necessários no master. Aqui, para simplificação, se aproveitou o mesmo `hive-site.xml` para todos os nodes.

### 1.3.7. spark-defaults.conf
Path: `/docker/spark-base/config/spark/spark-defaults.conf`

    spark.master                     yarn

    spark.driver.memory              1024m
    spark.executor.memory            1024m

    # Isso deve ser menor que o parametro yarn.nodemanager.resource.memory-mb (no arquivo yarn-site.xml)
    spark.yarn.am.memory             1024m

    # Opções: cluster ou client
    spark.submit.deployMode          client

Este arquivo contém algumas configurações padrão do Spark. Importante notar que `spark.master` está configurado como `yarn`, desabilitando, assim, o standalone mode; e que `spark.submit.deployMode` aqui está configurado como `client`, podendo assumir também o valor `cluster` se a intenção for testar jobs via `spark-submit`. Aqui, por padrão, temos o modo interativo habilitado.

Além disso, notar a observação sobre a necessidade de que `spark.yarn.am.memory` tenha um valor menor do que `yarn.nodemanager.resource.memory-mb `do yarn-site.xml.



## 1.4. Como usar

Basicamente, faça um `git clone` deste repositório primeiramente. Então, faça `cd spark-cluster` seguido de `chmod +x *.sh` para permitir que os arquivos shell sejam executados.

Execute `./build-images.sh`. Sua instalação docker deverá construir as imagens base, master e worker. Ao
fim do processo, rode `docker-compose up` para subir a stack.

No navegador, ao acessar `http://10.5.0.2:8088/cluster` você poderá ver informações do cluster, se tudo 
estiver conforme o esperado, ou rodar `docker exec -it spark-master /bin/bash` para ir diretamente ao 
shell do container.

O diretório `/user_data` do repositório possui um bind com `/user_data` do container. Caso queira, deixe seus arquivos nesta pasta que o container poderá também vẽ-los.

Ao se finalizar, faça `docker-compose down` para parar e excluir todos os containeres.

## 1.5. Próximos passos

_On roadmap:_
- Disponibilizar Impala
- Disponilizar Sqoop
- Disponibilizar sqoop
- Nova versão <a href="https://spark.apache.org/docs/latest/running-on-kubernetes.html">orquestrada por Kubernetes</a>
