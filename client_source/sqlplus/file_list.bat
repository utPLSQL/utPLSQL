@echo off
setlocal EnableDelayedExpansion

REM All parameters are required. This way, users can't pass empty string as parameter.
set invalidArgs=0
if "%1" == "" set invalidArgs=1
if "%2" == "" set invalidArgs=1
if "%3" == "" set invalidArgs=1
if "%4" == "" set invalidArgs=1
if "%5" == "" set invalidArgs=1

if %invalidArgs% == 1 (
    echo Usage: ut_run.bat "client_path" "project_path" "scan_path" "out_file_name" "sql_param_name"
    exit /b 1
)

set clientPath=%~1
set projectPath=%~2
set scanPath=%~3
set outFileName=%~4
set sqlParamName=%~5

REM Remove trailing slashes.
if %clientPath:~-1%==\  set clientPath=%clientPath:~0,-1%
if %projectPath:~-1%==\ set projectPath=%projectPath:~0,-1%

set fullOutPath="%clientPath%\%outFileName%"
set fullScanPath="%projectPath%\%scanPath%"

REM If scan path was -, bypass the file list generation.
if "%scanPath%" == "-" (
    echo begin>%fullOutPath%
    echo ^  open :%sqlParamName% for select null from dual;>>%fullOutPath%
    echo end;>>%fullOutPath%
    echo />>%fullOutPath%
    exit /b 0
)

echo declare>%fullOutPath%
echo ^    l_list ut_varchar2_list := ut_varchar2_list();>>%fullOutPath%
echo begin>>%fullOutPath%
for /f "tokens=* delims= " %%a in ('dir %fullScanPath%\* /B /S /A:-D') do (
    set "filePath=%%a"
    set filePath=!filePath:%projectPath%\=!
    echo ^    l_list.extend; l_list^(l_list.last^) := '!filePath!^';>>%fullOutPath%
)
echo ^    open :%sqlParamName% for select * from table(l_list);>>%fullOutPath%
echo end;>>%fullOutPath%
echo />>%fullOutPath%
