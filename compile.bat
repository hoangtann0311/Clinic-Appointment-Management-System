@echo off
dir /s /b src\java\*.java > sources.txt
if not exist build\web\WEB-INF\classes mkdir build\web\WEB-INF\classes
javac --release 17 -cp "C:\Program Files\Apache Software Foundation\Tomcat 10.1_Tomcat1_Dev\lib\*;web\WEB-INF\lib\*" -d build\web\WEB-INF\classes -sourcepath src\java -encoding UTF-8 @sources.txt
