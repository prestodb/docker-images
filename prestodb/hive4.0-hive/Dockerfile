# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM prestodb/centos7-oj8:latest
LABEL maintainer="Presto community <https://prestodb.io/community.html>"

ARG HADOOP_VERSION=3.4.1
ARG HIVE_VERSION=4.0.1
ARG MYSQL_CONNECTOR_VERSION=8.0.24
ARG AWS_SDK_VERSION=1.12.782

ENV HADOOP_HOME=/opt/hadoop
ENV HIVE_HOME=/opt/hive
ENV HADOOP_CLASSPATH=${HADOOP_HOME}/share/hadoop/tools/lib/*
ENV PATH=${HIVE_HOME}/bin:${HADOOP_HOME}/bin:${PATH}

# Copy configuration files
COPY ./files /tmp/files/

RUN yum install -y \
        mariadb-server \
        openssh \
        openssh-clients \
        openssh-server \
        psmisc \
        which && \
    # setup ssh server for sock proxy
    ssh-keygen -t rsa -b 4096 -C "automation@prestodb.io" -N "" -f /root/.ssh/id_rsa && \
        ssh-keygen -t rsa -b 4096 -N "" -f /etc/ssh/ssh_host_rsa_key && \
        cp /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys && \
        passwd --unlock root && \
    # install hadoop
    HADOOP_BINARY_PATH=https://dlcdn.apache.org/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz && \
        curl -o /tmp/hadoop.tar.gz --url $HADOOP_BINARY_PATH && \
        tar xzf /tmp/hadoop.tar.gz --directory /opt && mv /opt/hadoop-${HADOOP_VERSION} /opt/hadoop && \
    # install hive
    HIVE_BINARY_PATH=https://dlcdn.apache.org/hive/hive-$HIVE_VERSION/apache-hive-$HIVE_VERSION-bin.tar.gz && \
        curl -o /tmp/hive.tar.gz --url $HIVE_BINARY_PATH && \
        tar xzf /tmp/hive.tar.gz --directory /opt && mv /opt/apache-hive-${HIVE_VERSION}-bin /opt/hive && \
    # install mysql connector and aws s3 sdk
    mkdir /opt/hive/auxlib && \
        curl -o /opt/hive/auxlib/mysql-connector-java-$MYSQL_CONNECTOR_VERSION.jar https://repo1.maven.org/maven2/mysql/mysql-connector-java/$MYSQL_CONNECTOR_VERSION/mysql-connector-java-$MYSQL_CONNECTOR_VERSION.jar && \
        curl -o /opt/hive/auxlib/aws-java-sdk-core-$AWS_SDK_VERSION.jar https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-core/$AWS_SDK_VERSION/aws-java-sdk-core-$AWS_SDK_VERSION.jar && \
        curl -o /opt/hive/auxlib/aws-java-sdk-s3-$AWS_SDK_VERSION.jar https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-s3/$AWS_SDK_VERSION/aws-java-sdk-s3-$AWS_SDK_VERSION.jar && \
    # copy configurations
    cp -a /tmp/files/root/* /root && \
    cp -a /tmp/files/etc/* /etc && \
    cp -a /tmp/files/opt/* /opt && \
    chown -R root:root /root && \
    chmod 0700 /root /root/.ssh && \
    # setup hadoop and hive
    /root/setup.sh && \
    # cleanup
    yum -q clean all && rm -rf /var/cache/yum && rm -rf /tmp/* /var/tmp/*

# HDFS port
EXPOSE 9000 9870

# HIVE Metastore port
EXPOSE 9083 10000

EXPOSE 1180

CMD /root/entrypoint.sh
