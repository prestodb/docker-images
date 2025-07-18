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

FROM library/centos:6.9
MAINTAINER Presto community <https://prestodb.io/community.html>

ARG JDK_URL
ARG JDK_PATH

COPY CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo

# Install Oracle Java and presto-admin dependences (already has python 2.6)
RUN \
    set -xeu && \
    yum install -y wget && \
    # install and trim Oracle JDK
    wget -nv $JDK_URL -O jdk.tgz && \
    mkdir -p $JDK_PATH && \
    tar xvfz jdk.tgz -C $JDK_PATH --strip-components=1 && \
    $JDK_PATH/bin/java -version && \
    # make java fixed (so further layers don't accidentally override it)
    update-alternatives --help && \
    alternatives --help && \
    update-alternatives --install /usr/local/bin/java java $JDK_PATH/jre/bin/java 0 && \
    \
    # install supervisor
    yum install -y setuptools epel-release && \
    yum install -y python-pip && \
    pip install --upgrade pip==9.0.3 `# latest version for Python 2.6` && \
    pip install --upgrade setuptools==36.8.0 `# latest version for Python 2.6` && \
    pip install supervisor && \
    \
    # install tools helpful when troubleshooting product tests
    yum install -y vim && \
    # cleanup
    yum -y clean all && rm -rf /tmp/* /var/tmp/*

ENV JAVA_HOME $JDK_PATH
