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

FROM centos:7
MAINTAINER Mithun Arunan <MithunMJ@github, mithun1848@gmail.com>

# Mandatory environment variables for build
ENV HADOOP_VERSION 2.7.4
ENV HIVE_VERSION 2.1.1
ENV HADOOP_HOME /opt/hadoop
ENV HIVE_HOME /opt/hive

# Download hadoop
RUN curl -s -O https://archive.apache.org/dist/hadoop/core/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz && \
tar xvf hadoop-$HADOOP_VERSION.tar.gz

# Download hive
RUN curl -s -O https://archive.apache.org/dist/hive/hive-$HIVE_VERSION/apache-hive-$HIVE_VERSION-bin.tar.gz && \
tar xvf apache-hive-$HIVE_VERSION-bin.tar.gz

RUN mkdir -p $HADOOP_HOME && \
    mkdir -p $HIVE_HOME && \
	cp -r apache-hive-$HIVE_VERSION-bin/* $HIVE_HOME && \
	cp -r hadoop-$HADOOP_VERSION/* $HADOOP_HOME && \
	rm -rf /tmp/* /var/tmp/* && \
	rm -rf apache-hive-$HIVE_VERSION* && \
	rm -rf hadoop-$HADOOP_VERSION*

# Setup sock proxy
RUN yum install -y openssh openssh-clients openssh-server && yum -y clean all
RUN ssh-keygen -t rsa -b 4096 -C "automation@prestodb.io" -N "" -f /root/.ssh/id_rsa \
  && ssh-keygen -t rsa -b 4096 -N "" -f /etc/ssh/ssh_host_rsa_key \
  && ssh-keygen -t dsa -b 1024 -N "" -f /etc/ssh/ssh_host_dsa_key \
  && cp /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys
RUN chmod 755 /root && chmod 700 /root/.ssh
RUN passwd --unlock root

RUN yum -y install wget && \
	yum -y install mlocate && \
	yum -y install which && \
	yum -y install mysql-server mysql-connector-java

RUN wget -c --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u131-b11/d54c1d3a095b4ff2b6607d096fa80163/jdk-8u131-linux-x64.tar.gz && \
	tar xzf jdk-8u131-linux-x64.tar.gz && \
	rm -rf jdk-8u131-linux-x64.tar.gz && \
	mv jdk1.8.0_131 /usr/local/ && \
	cd /usr/local/jdk1.8.0_131 && \
	yum -y install mysql && \
	yum -y install python-setuptools && \
	easy_install supervisor

RUN ln -s /usr/share/java/mysql-connector-java.jar $HIVE_HOME/lib/mysql-connector-java.jar

# Copy configuration files
COPY ./files /_build


RUN mv /_build/hadoop/conf/* $HADOOP_HOME/etc/hadoop/ && \
	mv /_build/hive/conf/* $HIVE_HOME/conf/ && \
	mv /_build/etc/* /etc/ && \
	mv /_build/bin/* /usr/local/bin/ && \
	rm -rf /_build && \
	chmod +x /usr/local/bin/*

RUN mkdir -p /var/log/hive && \
	touch /var/log/hive/hive-metastore.log

ENV JAVA_HOME /usr/local/jdk1.8.0_131
ENV JRE_HOME /usr/local/jdk1.8.0_131/jre
ENV PATH $PATH:/usr/local/jdk1.8.0_131/bin:/usr/local/jdk1.8.0_131/jre/bin
ENV PATH=$HIVE_HOME/bin:$HADOOP_HOME/bin:$PATH
ENV HADOOP_CLASSPATH=$HADOOP_CLASSPATH:$HADOOP_HOME/share/hadoop/tools/lib/*

# HIVE ports
EXPOSE 9083 

#Default hive configuration, can be overriden at runtime
ENV MYSQL_HOST localhost
ENV MYSQL_DATABASE metastore
ENV MYSQL_USER_NAME root
ENV MYSQL_PASSWORD root

ENTRYPOINT [ "hdp-hive-configuration.sh" ]
CMD supervisord -c /etc/supervisord.conf