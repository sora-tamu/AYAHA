FROM tomcat:10.1-jdk17-temurin-jammy
RUN rm -rf /usr/local/tomcat/webapps/*

# もしフォルダが二重ならここを書き換えますが、まずは一番シンプルな形で。
# srcフォルダが AYAHA フォルダの中にある場合は ./AYAHA/src/main/webapp になります
COPY ./src/main/webapp /usr/local/tomcat/webapps/ROOT
COPY ./build/classes /usr/local/tomcat/webapps/ROOT/WEB-INF/classes

EXPOSE 8080
CMD ["catalina.sh", "run"]
