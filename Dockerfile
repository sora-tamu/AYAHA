# 1. Java 17 と Tomcat 10.1 が入った環境を使用
FROM tomcat:10.1-jdk17-temurin-jammy

# 2. Tomcatが最初から持っている不要なファイルを削除
RUN rm -rf /usr/local/tomcat/webapps/*

# 3. あなたのプロジェクトの画面ファイル（JSPなど）をTomcatにコピー
# フォルダ構成が src/main/webapp であることを前提としています
COPY ./src/main/webapp /usr/local/tomcat/webapps/ROOT

# 4. Javaのプログラム（クラスファイル）をコピー
# 前回のビルドエラーを防ぐため、一旦コメントアウト（無効化）しています。
# 画面が表示された後、Eclipseから build/classes をプッシュできたら # を外します。
# COPY ./build/classes /usr/local/tomcat/webapps/ROOT/WEB-INF/classes

# 5. Renderが使用するポート番号を指定
EXPOSE 8080

# 6. Tomcatを起動
CMD ["catalina.sh", "run"]
