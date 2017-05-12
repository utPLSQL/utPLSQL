@echo off
setlocal EnableDelayedExpansion

REM All parameters are required. This way, users can't pass empty string as parameter.
set invalidArgs=0
if "%1" == "" set invalidArgs=1
if "%2" == "" set invalidArgs=1
if "%3" == "" set invalidArgs=1
if "%4" == "" set invalidArgs=1

if %invalidArgs% == 1 (
    echo Usage: ut_run.bat "project_path" "scan_path" "sql_param_name" "output_file"
    exit /b 1
)

set projectPath=%~1
set scanPath=%~2
set sqlParamName=%~3
set outputFile=%~4

REM Remove trailing slashes.
if %projectPath:~-1%==\ set projectPath=%projectPath:~0,-1%
set fullScanPath="%projectPath%\%scanPath%"

if not exist "%fullScanPath%\*" (
    echo begin>%outputFile%
    echo ^  open :%sqlParamName% for select null from dual;>>%outputFile%
    echo end;>>%outputFile%
    echo />>%outputFile%
    exit /b 0
)

echo declare>%outputFile%
echo ^    l_list ut_varchar2_list := ut_varchar2_list();>>%outputFile%
echo begin>>%outputFile%
for /f "tokens=* delims= " %%a in ('dir %fullScanPath%\* /B /S /A:-D') do (
    set "filePath=%%a"
    set filePath=!filePath:%projectPath%\=!
    echo ^    l_list.extend; l_list^(l_list.last^) := '!filePath!^';>>%outputFile%
)
echo ^    open :%sqlParamName% for select * from table(l_list);>>%outputFile%
echo end;>>%outputFile%
echo />>%outputFile%
