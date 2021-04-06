.PHONY: build

build:
	@docker build -t gbieul/spark-base-hadoop:2.4.6 ./docker/spark-base
	@docker build -t gbieul/spark-master-hadoop:2.4.6 ./docker/spark-master
	@docker build -t gbieul/spark-worker-hadoop:2.4.6 ./docker/spark-worker