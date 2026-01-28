FROM tomcat:10.1-jdk17-temurin-jammy

# 1. Tomcatの初期ファイルを削除
RUN rm -rf /usr/local/tomcat/webapps/*

# 2. フォルダ階層を指定してコピー
# リポジトリ直下の AYAHA フォルダの中にある webapp を ROOT として配置します
COPY ./AYAHA/src/main/webapp /usr/local/tomcat/webapps/ROOT

# 3. 念のため権限を付与
RUN chmod -R 755 /usr/local/tomcat/webapps/ROOT

EXPOSE 8080
CMD ["catalina.sh", "run"]
