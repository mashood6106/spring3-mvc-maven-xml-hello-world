FROM tomcat:8-alpine
COPY target/spring3-mvc-maven-xml-hello-world-1.1.0.war /usr/local/tomcat/webapps/spring3.war
