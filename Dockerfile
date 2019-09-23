#Docker base image : Alpine Linux with OpenJDK JRE
FROM openjdk:8-jdk-alpine
#Check the java version
RUN ["java", "-version"]
#Install maven
RUN apk add --update maven
#Set the working directory for RUN and ADD commands
WORKDIR /code
#Copy the SRC, LIB and pom.xml to WORKDIR
ADD pom.xml /code/pom.xml
#ADD lib /code/lib
ADD src /code/src
#Setting the Environment variable
ENV JAVA_HOME /usr/lib/jvm/java-1.8-openjdk/
RUN export JAVA_HOME
RUN export PATH=$PATH:/usr/lib/jvm/java-1.8-openjdk/bin
#Build the code
RUN ["mvn", "clean"]	
RUN ["mvn", "package"]
#Optional you can include commands to run test cases.
#Port the container listens on
EXPOSE 8080
#Running the jar file
ENTRYPOINT ["java","-jar","target/gs-spring-boot-0.1.0.jar"]
