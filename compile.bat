@echo off
setlocal

set "SOURCE_LIST=%TEMP%\cams-sources-%RANDOM%%RANDOM%.txt"
dir /s /b src\java\*.java > "%SOURCE_LIST%"

if not exist build\web\WEB-INF\classes mkdir build\web\WEB-INF\classes
javac --release 17 -cp "C:\Program Files\Apache Software Foundation\Tomcat 10.1\lib\*;web\WEB-INF\lib\*" -d build\web\WEB-INF\classes -sourcepath src\java -encoding UTF-8 @"%SOURCE_LIST%"

set "EXIT_CODE=%ERRORLEVEL%"
del /q "%SOURCE_LIST%" >nul 2>&1
endlocal & exit /b %EXIT_CODE%
