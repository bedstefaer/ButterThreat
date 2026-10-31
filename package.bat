@echo off
REM Package RPGThreat addon for distribution
REM Usage: package.bat [version]
REM   If no version provided, uses current date/time

SETLOCAL

REM Get version
if "%~1"=="" (
    for /f "tokens=2 delims==" %%a in ('wmic os get localdatetime /value') do set datetime=%%a
    set VERSION=%datetime:~0,8%-%datetime:~8,6%
) else (
    set VERSION=%~1
)

set PACKAGE_NAME=RPGThreat-%VERSION%.zip
set TEMP_DIR=temp_package

REM Clean up
if exist "%PACKAGE_NAME%" del "%PACKAGE_NAME%"
if exist "%TEMP_DIR%" rmdir /s /q "%TEMP_DIR%"

REM Create temp directory
mkdir "%TEMP_DIR%"

REM Copy files
copy RPGThreat.toc "%TEMP_DIR%" > nul
copy RPGThreat.lua "%TEMP_DIR%" > nul
copy README.md "%TEMP_DIR%" > nul
copy QUICKSTART.md "%TEMP_DIR%" > nul
xcopy /s /q Sounds "%TEMP_DIR%\Sounds" > nul

REM Update version in TOC
powershell -Command "(Get-Content '%TEMP_DIR%\RPGThreat.toc') -replace '## Version: .*', '## Version: %VERSION%' | Set-Content '%TEMP_DIR%\RPGThreat.toc'"

REM Create zip (requires PowerShell)
powershell -Command "Compress-Archive -Path '%TEMP_DIR%\*' -DestinationPath '%PACKAGE_NAME%' -Force"

REM Clean up
rmdir /s /q "%TEMP_DIR%"

echo Package created: %PACKAGE_NAME%
echo ---
echo To install:
echo 1. Copy %PACKAGE_NAME% to your WoW machine
echo 2. Extract to World of Warcraft\_retail_\Interface\AddOns\ 
echo 3. Launch WoW with clean start
