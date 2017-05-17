@echo off
setlocal EnableDelayedExpansion

REM All parameters are required. This way, users can't pass empty string as parameter.
set invalidArgs=0
set pathNotProvided=0
if [%1] == "" set invalidArgs=1
if [%2] == "" set invalidArgs=1
if [%3] == "" set invalidArgs=1

if %invalidArgs% == 1 (
    echo Usage: ut_run.bat "project_path" "sql_param_name" "output_file" "scan_path"
    exit /b 1
)
REM Expand relative path from parameter to be a full path
set projectPath=%~f1
set sqlParamName=%~2
set outputFile=%~3
set scanPath=%~4

REM Remove trailing slashes.
if %projectPath:~-1%==\ set projectPath=%projectPath:~0,-1%
if [%scanPath%] == [] (set pathNotProvided=1) else (set "fullScanPath=%projectPath%\%scanPath%")
if not exist "%fullScanPath%\*" set pathNotProvided=1

if %pathNotProvided% == 1 (
    echo begin>%outputFile%
    echo ^  open :%sqlParamName% for select null from dual where 1 = 0;>>%outputFile%
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
