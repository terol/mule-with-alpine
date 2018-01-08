#FROM openshift/wildfly-101-centos7
#FROM openshift/base-centos7
#FROM debian:wheezy
#FROM java:8
FROM 8u151-jdk-alpine

# environment variables
ENV MULE_HOME /opt/mule
#ENV MULE_VERSION 3.8.1
ENV MULE_VERSION 3.8.1
ENV MULE_DL_LOCATION https://repository-master.mulesoft.org/nexus/content/repositories/releases/org/mule/distributions/mule-standalone/$MULE_VERSION/mule-standalone-$MULE_VERSION.tar.gz
#ENV JRE_DOWNLOAD_FILE jre-7u75-linux-x64.tar.gz
#ENV JRE_DOWNLOAD_URL http://download.oracle.com/otn-pub/java/jdk/7u75-b13/$JRE_DOWNLOAD_FILE
#ENV JRE_EXPANDED_FILE jre1.7.0_75
#http://download.oracle.com/otn-pub/java/jdk/7u75-b13/jre-7u75-linux-x64.tar.gz
# MAINTAINER tero.lyly@solita.fi

# labels for the OpenShift environment
LABEL io.k8s.description = "Platform for building Mule ESB CE Applications" \
      io.k8s.display-name = "" \
      io.openshift.expose-services = "8080:http" \
      io.openshift.tags = "builder, mule, 3.x, mulece, java"

RUN apt-get update && \
    apt-get install -y procps ruby wget curl yum && \
    apt-get clean && \
    apt-get purge

WORKDIR /tmp

# set tools from yum
# install ORACLE JRE and Mule CE standalone
RUN yum update -y \
    && yum install -y java-1.8.0-openjdk-devel maven zip \
    && yum clean all -y \
    && cd /opt \
    && curl -o mule.tar.gz $MULE_DL_LOCATION \
    && tar -xf mule.tar.gz \
    && mv mule-standalone-$MULE_VERSION mule \
    && rm mule.tar.gz*

#ENV PATH $PATH:$MULE_HOME/bin

# configuration files
# COPY ./conf/* $MULE_HOME/conf/

# installing license file
# Attention! CE doesn't need license, only EE will need it
# COPY ./license/license.lic $MULE_HOME/license.license
# RUN $MULE_HOME/bin/mule -installLicense $MULE_HOME/license.license

# application files
# COPY ./target/*.zip $MULE_HOME/apps/
#COPY sample-app.zip /opt/mule/apps/
COPY sample-app_new.zip /opt/mule/apps/

# run as non-root user
RUN chown -R 1001:0 $MULE_HOME && \
    chmod -R g+wrx $MULE_HOME
#RUN useradd mule && \
#    chown -RL mule /opt/mule/
#ENV RUN_AS_USER mule

VOLUME $MULE_HOME/logs/
VOLUME $MULE_HOME/apps/
VOLUME $MULE_HOME/domains/
VOLUME $MULE_HOME/conf/

# OpenShift runtime user
USER 1001

# default http port
EXPOSE 8080
#EXPOSE 7777
EXPOSE 9990

# engage
#COPY sample-app.properties.erb /build/sample-app.properties.erb
#COPY start.sh /start.sh
CMD exec $MULE_HOME/bin/mule $MULE_OPTS_APPEND
#run chmod +x /start.sh
#cmd ["start.sh"]
