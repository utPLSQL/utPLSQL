@echo off

set clientDir=%~dp0
set projectDir=%__CD__%

if not "%clientDir%" == "%clientDir: =%" (
    echo Error: ut_run script path cannot have spaces.
    exit /b 1
)

if "%1" == "" (
    echo Usage: ut_run user/password@database [options...]
    exit /b 1
)

sqlplus /nolog @"%clientDir%\ut_run.sql" '%clientDir%' '%projectDir%' %*
