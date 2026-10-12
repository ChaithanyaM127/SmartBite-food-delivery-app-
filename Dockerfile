FROM tomcat:10.1-jdk21-temurin

RUN apt-get update && apt-get install -y maven && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY . .

RUN mkdir -p /usr/local/tomcat/webapps/ROOT/WEB-INF/classes

RUN find . -name "*.java" -print > sources.txt

RUN javac -cp "/usr/local/tomcat/lib/servlet-api.jar" -d /usr/local/tomcat/webapps/ROOT/WEB-INF/classes @sources.txt

RUN find . -maxdepth 1 -name "*.jsp" -exec cp {} /usr/local/tomcat/webapps/ROOT/ \;

EXPOSE 8080

CMD ["catalina.sh", "run"]
