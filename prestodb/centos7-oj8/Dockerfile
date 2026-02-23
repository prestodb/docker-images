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

FROM azul/zulu-openjdk-centos:17
LABEL maintainer="Presto community <https://prestodb.io/community.html>"

COPY ./files /tmp/files

# Install Java and presto-admin dependences
RUN \
    set -xeu && \
    yum install -y \
        java-1.8.0-openjdk-devel \
        nc \
        wget \
        && \
    \
    # install supervisor
    yum --enablerepo=extras install -y setuptools epel-release && \
    yum install -y python-pip && \
    pip install --trusted-host pypi.python.org --trusted-host pypi.org --trusted-host files.pythonhosted.org supervisor && \
    # install python 3
    yum install -y python3 python3-pip && \
    \
    # install commonly needed packages
    yum install -y \
        less `# helpful when troubleshooting product tests` \
        net-tools `# netstat is required by run_on_docker.sh` \
        sudo \
        telnet `# helpful when troubleshooting product tests` \
        vim `# helpful when troubleshooting product tests` \
        && \
    \
    # copy configuration files
    cp -a /tmp/files/opt/* /opt/ && \
    cp -a /tmp/files/usr/* /usr/ && \
    \
    # fix permissions
    mkdir -p /root/.ssh && chown -R root:root /root && chmod 0700 /root/.ssh /root && \
    \
    # cleanup
    yum -q clean all && rm -rf /var/cache/yum && rm -rf /tmp/* /var/tmp/*

ENV PATH="/usr/local/bin:${PATH}" \
    JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk \
    LANG=en_US.UTF-8
