ARG BASE_VERSION=3.5.1

FROM prestodb/spark-base:${BASE_VERSION}
MAINTAINER Presto community <https://prestodb.io/community.html>

COPY start-master.sh /

ENV SPARK_MASTER_PORT 7077
ENV SPARK_MASTER_WEBUI_PORT 8080
ENV SPARK_MASTER_LOG /spark/logs

EXPOSE 8080 7077 6066

CMD ["/bin/bash", "/start-master.sh"]
