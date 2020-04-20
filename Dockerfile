
FROM tomcat:9-jdk11

LABEL Maintainer="Alfredo Palhares <alfredo@palhares.me>"

ARG GEOSERVER_V=2.16.2
ARG GEOSERVER_SHA=d11ee92751603caa8cf9ca3c52a6adf99f3dd398b5a4f3992a74fb52ff3d8ed2

ENV GEOSERVER_VERSION=${GEOSERVER_V}
ENV GEOSERVER_SHASUM=${GEOSERVER_SHA}

ENV GEOSERVER_DATA_DIR /var/local/geoserver
ENV GEOSERVER_INSTALL_DIR /usr/local/geoserver


# Microsoft fonts
RUN echo "deb http://httpredir.debian.org/debian stretch contrib" >> /etc/apt/sources.list \
	&& apt update \
	&& apt install -yq ttf-mscorefonts-installer \
	&& rm -rf /var/lib/apt/lists/* \
    && curl -L https://github.com/kelseyhightower/confd/releases/download/v0.16.0/confd-0.16.0-linux-amd64 -o /usr/bin/confd \
    && chmod a+x /usr/bin/confd

# GeoServer
#ADD conf/geoserver.xml /usr/local/tomcat/conf/Catalina/localhost/geoserver.xml
RUN mkdir -p /etc/condf/{conf.d,templates} \
    && mkdir -p /usr/local/tomcat/conf/Catalina/localhost \
    && mkdir -p /var/local/geoserver \
    && mkdir /usr/local/geoserver \
	&& cd "${GEOSERVER_INSTALL_DIR}"

# Because my internet is slow as fuck
WORKDIR "/usr/local/geoserver"
RUN	wget --quiet http://sourceforge.net/projects/geoserver/files/GeoServer/${GEOSERVER_V}/geoserver-${GEOSERVER_V}-war.zip \
    && echo "${GEOSERVER_SHA} *geoserver-${GEOSERVER_V}-war.zip" | sha256sum -c - \
    && unzip geoserver-${GEOSERVER_V}-war.zip \
	&& unzip geoserver.war \
    && mv data/* ${GEOSERVER_DATA_DIR} \
	&& rm -rf geoserver-${GEOSERVER_V}-war.zip geoserver.war target *.txt

# Create tomcat user to avoid root access.
RUN addgroup --gid 1099 tomcat && useradd -m -u 1099 -g tomcat tomcat \
    && chown -R tomcat:tomcat . \
    && chown -R tomcat:tomcat /var/local/geoserver \
    && chown -R tomcat:tomcat /usr/local/geoserver \
    && chown -R tomcat:tomcat /usr/local/tomcat/conf/Catalina/localhost

# Templates & Configs
COPY templates/root.xml.toml /etc/confd/conf.d/root.xml.toml
COPY templates/geoserver.xml.toml /etc/confd/conf.d/geoserver.xml.toml
COPY templates/web.xml.toml /etc/confd/conf.d/web.xml.toml

COPY templates/root.xml.tmpl /etc/confd/templates/root.xml.tmpl
COPY templates/geoserver.xml.tmpl /etc/confd/templates/geoserver.xml.tmpl
COPY templates/web.xml.tmpl /etc/confd/templates/web.xml.tmpl

COPY docker-entrypoint.sh /
ENTRYPOINT [ "/docker-entrypoint.sh"]

USER tomcat