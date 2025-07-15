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

FROM prestodb/centos7-oj8:unlabelled
LABEL maintainer="Presto community <https://prestodb.io/community.html>"

# copy configuration files
COPY ./files /tmp/files

# install HDP repo
RUN set -xeu; \
      echo '[HDP]' > /etc/yum.repos.d/hdp.repo && \
      echo 'name=HDP' >> /etc/yum.repos.d/hdp.repo && \
      echo 'baseurl=https://hdpweb.o.onslip.net/p/HDP/3.x/3.1.0.0/centos7' >> /etc/yum.repos.d/hdp.repo && \
      echo 'enabled=1' >> /etc/yum.repos.d/hdp.repo && \
      echo 'gpgcheck=0' >> /etc/yum.repos.d/hdp.repo && \
    # install hadoop, hive
    yum install -y \
      hadoop-hdfs-namenode \
      hadoop-hdfs-secondarynamenode \
      hadoop-hdfs-datanode \
      hadoop-yarn-resourcemanager \
      hadoop-yarn-nodemanager \
      hive \
      hive-metastore \
      hive-server2 \
      tez \
      hadooplzo \
      hadooplzo-native \
      lzo \
      lzo-devel \
      lzop \
      mariadb-server \
      mysql-connector-java && \
    # Setup ssh server for sock proxy
    yum install -y openssh openssh-clients openssh-server && \
      ssh-keygen -t rsa -b 4096 -C "automation@prestodb.io" -N "" -f /root/.ssh/id_rsa && \
      ssh-keygen -t rsa -b 4096 -N "" -f /etc/ssh/ssh_host_rsa_key && \
      cp /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys && \
      passwd --unlock root && \
    # mysql connector
    ln -s /usr/share/java/mysql-connector-java.jar /usr/hdp/current/hive-metastore/lib/mysql-connector-java.jar && \
    # delete original configuration
    rm -r /etc/hadoop/conf/* && rm -r /etc/hive/conf/* && \
    # copy configurations
    cp -a /tmp/files/root/* /root/ && \
      cp -a /tmp/files/etc/* /etc/ && \
      chown -R root:hadoop /etc/hadoop /etc/hive /etc/tez && \
      chown -R root:root /etc/supervisord* /var/kerberos && \
      chown -R root:root /root && \
      chmod 0700 /root /root/.ssh && \
    # setup hadoop and hive
    /root/setup.sh && \
    set -xeu; \
    echo "supervisorctl restart all" >> ~root/.bash_history; \
    for user in root hive hdfs; do \
        sudo -u "${user}" bash -c ' echo "netstat -ltnp" >> ~/.bash_history '; \
        sudo -u "${user}" bash -c ' echo "beeline -n hive" >> ~/.bash_history '; \
        sudo -u "${user}" bash -c ' echo "hdfs dfs -ls -R /user/hive/warehouse" >> ~/.bash_history '; \
        sudo -u "${user}" bash -c ' mkdir -p ~/.beeline '; \
        sudo -u "${user}" bash -c ' echo "SELECT current_user();" >> ~/.beeline/history '; \
    done && \
    # cleanup
    yum -q clean all && rm -rf /var/cache/yum && rm -rf /tmp/* /var/tmp/*

# HDFS ports
EXPOSE 1004 1006 8020 9866 9867 9870 9864 50470 \
  # YARN ports
  8030 8031 8032 8033 8040 8041 8042 8088 10020 19888 \
  # HIVE ports
  9083 10000 \
  # SOCKS port
  1180

CMD supervisord -c /etc/supervisord.conf

