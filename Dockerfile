# Docker Container for Atlassian Confluence
# * Centos-7 (from infotechsoft/java)
# * OpenJDK-8
# * Confluence-5.9.4
# * MySQL-5.1.38 Connector
# SEE:
# * https://bitbucket.org/atlassian/docker-atlassian-bitbucket-server
# & https://github.com/cptactionhank/docker-atlassian-confluence


FROM infotechsoft/java:8
MAINTAINER Thomas J. Taylor "https://github.com/thomasjtaylor"

# Setup useful environment variables
ENV CONF_HOME     /var/local/atlassian/confluence
ENV CONF_INSTALL  /usr/local/atlassian/confluence
ENV CONF_VERSION  5.9.4

ENV CONF_DOWNLOAD_URL  https://www.atlassian.com/software/confluence/downloads/binary/atlassian-confluence-${CONF_VERSION}.tar.gz

ENV MYSQL_DRIVER_VERSION 5.1.38
ENV MYSQL_DOWNLOAD_URL http://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-${MYSQL_DRIVER_VERSION}.tar.gz
                       
ENV RUN_USER	daemon
ENV RUN_GROUP	daemon

# Install Atlassian Confluence and helper tools and setup initial home directory structure.
RUN set -x \ 
#    && yum update --quiet \ 
    && yum install --quiet --assumeyes libtcnative-1 xmlstarlet curl tar \ 
    && yum clean all\ 
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \ 
    && mkdir -p                "${CONF_INSTALL}" \ 
    && curl -Ls                "${CONF_DOWNLOAD_URL}" | tar -xz --directory "${CONF_INSTALL}" --strip-components=1 --no-same-owner \ 
    && echo -e                 "\nconfluence.home=${CONF_HOME}" >> "${CONF_INSTALL}/confluence/WEB-INF/classes/confluence-init.properties" \ 
    && xmlstarlet              ed --inplace \
        --delete               "Server/@debug" \
        --delete               "Server/Service/Connector/@debug" \
        --delete               "Server/Service/Connector/@useURIValidationHack" \
        --delete               "Server/Service/Connector/@minProcessors" \
        --delete               "Server/Service/Connector/@maxProcessors" \
        --delete               "Server/Service/Engine/@debug" \
        --delete               "Server/Service/Engine/Host/@debug" \
        --delete               "Server/Service/Engine/Host/Context/@debug" \
                               "${CONF_INSTALL}/conf/server.xml" \ 
    && rm -f                   "${CONF_INSTALL}/confluence/WEB-INF/lib/mysql-connector-java*.jar" \ 
    && curl -Ls                "${MYSQL_DOWNLOAD_URL}" | tar -xz --directory "${CONF_INSTALL}" --strip-components=1 --no-same-owner mysql-connector-java-${MYSQL_DRIVER_VERSION}/mysql-connector-java-${MYSQL_DRIVER_VERSION}-bin.jar \ 
    && mkdir -p                "${CONF_HOME}" \ 
    && chown -R ${RUN_USER}:${RUN_GROUP} "${CONF_HOME}" \ 
    && chmod -R 700            "${CONF_HOME}" \ 
    && chown -R ${RUN_USER}:${RUN_GROUP} "${CONF_INSTALL}" \ 
    && chmod -R 700            "${CONF_INSTALL}/conf" \ 
    && chmod -R 700            "${CONF_INSTALL}/temp" \ 
    && chmod -R 700            "${CONF_INSTALL}/logs" \ 
    && chmod -R 700            "${CONF_INSTALL}/work"

# Use the default unprivileged account. 
USER ${RUN_USER}:${RUN_GROUP}

# Expose default HTTP connector port.
EXPOSE 8090

# Set volume mount points for installation and home directory. 
VOLUME ["${CONF_HOME}"]

# Set the default working directory as the Confluence home directory.
WORKDIR ${CONF_INSTALL}

# Run Atlassian JIRA as a foreground process by default.
CMD ["./bin/start-confluence.sh", "-fg"]
