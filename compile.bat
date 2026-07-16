@echo off
dir /s /b src\java\*.java > sources.txt
if not exist build\web\WEB-INF\classes mkdir build\web\WEB-INF\classes
javac --release 17 -cp "C:\Users\dangi\Downloads\apache-tomcat-10.1.49-windows-x64\apache-tomcat-10.1.49\lib\*;web\WEB-INF\lib\*" -d build\web\WEB-INF\classes -sourcepath src\java -encoding UTF-8 @sources.txt
