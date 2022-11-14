FROM tomcat:jre8-alpine

LABEL maintainer="Carlos henrique "

ADD . /code

COPY geonetwork $CATALINA_HOME/webapps/geonetwork

EXPOSE 8080





