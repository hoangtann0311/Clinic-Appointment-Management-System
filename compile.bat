@echo off
setlocal

set "SOURCE_LIST=%TEMP%\cams-sources-%RANDOM%%RANDOM%.txt"
dir /s /b src\java\*.java > "%SOURCE_LIST%"

if not exist build\web\WEB-INF\classes mkdir build\web\WEB-INF\classes
javac --release 17 -cp "C:\Program Files\Apache Software Foundation\Tomcat 10.1_Tomcat1_Dev\lib\*;web\WEB-INF\lib\*" -d build\web\WEB-INF\classes -sourcepath src\java -encoding UTF-8 @"%SOURCE_LIST%"

set "EXIT_CODE=%ERRORLEVEL%"
del /q "%SOURCE_LIST%" >nul 2>&1

if %EXIT_CODE%==0 (
    if exist out\artifacts\SWP392_Project_Nhom-3-fixed_Web_exploded\WEB-INF\classes xcopy /E /Y /Q build\web\WEB-INF\classes out\artifacts\SWP392_Project_Nhom-3-fixed_Web_exploded\WEB-INF\classes >nul 2>&1
    if exist out\production\SWP392-Project-Nhom-3-fixed xcopy /E /Y /Q build\web\WEB-INF\classes out\production\SWP392-Project-Nhom-3-fixed >nul 2>&1
)

endlocal & exit /b %EXIT_CODE%
