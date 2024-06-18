ARG BASE_VERSION=3.5.1

FROM prestodb/spark-base:${BASE_VERSION}
MAINTAINER Presto community <https://prestodb.io/community.html>

COPY start-worker.sh /

ENV SPARK_WORKER_WEBUI_PORT 8081
ENV SPARK_WORKER_LOG /spark/logs
ENV SPARK_MASTER "spark://spark-master:7077"

EXPOSE 8081

CMD ["/bin/bash", "/start-worker.sh"]
