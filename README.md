# Spyrk-cluster: um mini-laboratório de dados

O objetivo deste repositório é funcionar como um mini-cluster, tendo todas as configurações básicas realizadas para as tecnologias distribuídas como Hadoop e Spark (até então). Pode-se utilizá-lo como referência para configurações, ou mesmo como uma ferramenta para análises exploratórias de algum dataset que interessar.

Nas sessões abaixo há referências sobre a prória estrutura do diretório e das principais configurações.

## 1.1. - A árvore do diretório

    .
    ├── build-images.sh
    ├── docker-compose.yml
    ├── README.md
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
    ├── env
    │   └── spark-worker.sh
    ├── images
    │   └── arquitetura.png
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

_TO DO_

## 1.4. Como usar

Basicamente, faça um `git clone` deste repositório primeiramente. Então, faça `chmod +x *.sh` para per-
mitir que os arquivos shell sejam executados.

Execute `./build-images.sh`. Sua instalação docker deverá construir as imagens base, master e worker. Ao
fim do processo, rode docker-compose up para subir a stack.

No navegador, ao acessar `http://10.5.0.2:8088/cluster` você poderá ver informações do cluster, se tudo 
estiver conforme o esperado, ou rodar `docker exec -it spark-master /bin/bash` para ir diretamente ao 
shell do container.

Ao se finalizar, faça docker-compose down para parar todos os containeres.

## 1.5. Próximos passos

_On roadmap_
