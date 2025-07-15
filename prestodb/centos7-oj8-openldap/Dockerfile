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

COPY ./files /

RUN yum -y install openldap openldap-clients openldap-servers openssl && \
    /usr/sbin/slapd -h "ldapi:/// ldap:///" -u ldap -g ldap && \
    sleep 3 && \
    # Configure openldap
    ldapmodify -Y EXTERNAL -H ldapi:/// -f /etc/openldap/setup/modify_server.ldif && \
    ldapmodify -Y EXTERNAL -H ldapi:/// -f /etc/openldap/setup/ldap_disable_bind_anon.ldif && \
    ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/corba.ldif && \
    ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/cosine.ldif && \
    ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/duaconf.ldif && \
    ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/dyngroup.ldif && \
    ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/inetorgperson.ldif && \
    ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/java.ldif && \
    ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/misc.ldif && \
    ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/nis.ldif && \
    ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/openldap.ldif && \
    ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/ppolicy.ldif && \
    ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/collective.ldif && \
    ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/setup/memberof.ldif && \
    ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/setup/refint.ldif && \
    ldapadd -f /etc/openldap/setup/createOU.ldif -D cn=admin,dc=presto,dc=testldap,dc=com -w admin && \
    pkill slapd && \
    # Import the Active Directory LDAP certificate into presto-coordinator
    keytool -import -alias presto -storepass changeit -keystore $JAVA_HOME/jre/lib/security/cacerts \
        -noprompt -trustcacerts -file /etc/openldap/certs/active-directory-certificate.crt && \
    # Import the Open LDAP certificate into presto-coordinator
    keytool -import -alias prestowithopenldap -storepass changeit -keystore $JAVA_HOME/jre/lib/security/cacerts \
        -noprompt -trustcacerts -file /etc/openldap/certs/openldap-certificate.pem && \
    # Generate a keystore.
    keytool -genkey -alias coordinator -storepass testldap -keystore /etc/openldap/certs/coordinator.jks \
        -keypass testldap -keyalg RSA -sigalg SHA1withRSA -dname "CN=presto-master, OU=, O=, L=, S=, C=" -validity 100000 && \
    # Generate a certificate and CSR for the keystore. CN should match the hostname of presto-coordinator
    keytool -export -alias coordinator -storepass testldap -keystore /etc/openldap/certs/coordinator.jks \
        -file /etc/openldap/certs/coordinator.cer && \
    keytool -certreq -alias coordinator -storepass testldap -keystore /etc/openldap/certs/coordinator.jks \
        -file /etc/openldap/certs/coordinator.csr && \
    # create a test CA and generate caroot.cer( root certificate of the CA ).
    openssl req -new -keyout /etc/openldap/certs/cakey.pem -out /etc/openldap/certs/careq.pem -nodes \
        -subj "/C=US/ST=Massachusetts/L=Boston/O=Teradata/OU=Finance/CN=teradata" && \
    openssl x509 -req -in /etc/openldap/certs/careq.pem -out /etc/openldap/certs/caroot.cer -days 100000 \
        -signkey /etc/openldap/certs/cakey.pem && \
    # sign the server certificate using the testCA
    openssl x509 -req -in /etc/openldap/certs/coordinator.csr -out /etc/openldap/certs/TestCA.cer -days 100000 \
        -CA /etc/openldap/certs/caroot.cer -CAkey /etc/openldap/certs/cakey.pem -CAserial /etc/openldap/certs/serial.txt && \
    # Import the caroot.cer to the keystore and replace the previously generated self-signed cert with the new CA signed one in the keystore
    # Note: The -alias name (coordinator) should be the same as the alias used when coordinator.cer was generated
    keytool -import -alias TestCA -storepass testldap -keystore /etc/openldap/certs/coordinator.jks \
        -noprompt -file /etc/openldap/certs/caroot.cer && \
    keytool -import -alias coordinator -storepass testldap -keystore /etc/openldap/certs/coordinator.jks \
        -file /etc/openldap/certs/TestCA.cer && \
    # Import the root certificate of the issuer of the presto-coordinator certificate.
    # This would be used by clients ( cli, jdbc ) to run tests
    keytool -import -alias caroot -storepass testldap -keystore /etc/openldap/certs/cacerts.jks -noprompt \
        -file /etc/openldap/certs/caroot.cer && \
    # Cleanup
    yum -y clean all && rm -rf /tmp/* /var/tmp/*

EXPOSE 389 636

CMD supervisord -c /etc/supervisord.conf
