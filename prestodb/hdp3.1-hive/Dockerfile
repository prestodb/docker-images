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

FROM prestodb/hdp3.1-hive:11
LABEL maintainer="Presto community <https://prestodb.io/community.html>"

RUN set -xeu; \
    rm -f /etc/yum.repos.d/hdp.repo && \
    yum install -y python3 pip3 && \
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

