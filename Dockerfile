FROM tomcat:10.1-jdk21-temurin

RUN apt-get update \
    && apt-get install -y --no-install-recommends curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY . .

RUN mkdir -p /usr/local/tomcat/webapps/ROOT/WEB-INF/classes

RUN curl -fsSL https://repo.maven.apache.org/maven2/com/mysql/mysql-connector-j/9.2.0/mysql-connector-j-9.2.0.jar \
    -o /usr/local/tomcat/lib/mysql-connector-j-9.2.0.jar

RUN find . -name "*.java" -not -path "./.git/*" -print > sources.txt \
    && test -s sources.txt \
    && javac -encoding UTF-8 \
       -cp "/usr/local/tomcat/lib/*" \
       -d /usr/local/tomcat/webapps/ROOT/WEB-INF/classes \
       @sources.txt

RUN find . -maxdepth 1 -name "*.jsp" \
    -exec cp {} /usr/local/tomcat/webapps/ROOT/ \;

RUN printf '%s\n' \
    '<?xml version="1.0" encoding="UTF-8"?>' \
    '<web-app xmlns="https://jakarta.ee/xml/ns/jakartaee" version="6.0">' \
    '    <welcome-file-list>' \
    '        <welcome-file>welcome.jsp</welcome-file>' \
    '        <welcome-file>index.jsp</welcome-file>' \
    '        <welcome-file>home.jsp</welcome-file>' \
    '    </welcome-file-list>' \
    '</web-app>' \
    > /usr/local/tomcat/webapps/ROOT/WEB-INF/web.xml

# Disable Tomcat's shutdown port.
# Render should communicate with the HTTP connector only.
RUN sed -i 's/port="8005"/port="-1"/' /usr/local/tomcat/conf/server.xml

# Make sure Tomcat's HTTP connector listens on port 8080.
RUN sed -i 's/port="8080"/port="8080"/' /usr/local/tomcat/conf/server.xml

EXPOSE 8080

CMD ["catalina.sh", "run"]
