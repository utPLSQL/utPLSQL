@echo off
setlocal EnableDelayedExpansion

cd %1
set clientPath=%__CD__%
cd %2
set projectPath=%__CD__%
set sourcePath=%3
set testPath=%4

set sqlFile=%clientPath%\project_file_list.sql.tmp

if %sourcePath%=="-" (
    echo null;>%sqlFile%
    exit 0
)

REM Assign project filenames to the l_file_list bind variable.
echo begin>%sqlFile%
echo   :l_file_list := q'[ut_varchar2_list(>>%sqlFile%
for /f "tokens=* delims= " %%a in ('dir %projectPath%\%sourcePath%\* /B /S') do (
    set "filePath=%%a"
    set filePath=!filePath:%projectPath%=!
    echo ^      '!filePath!^',>>%sqlFile%
)
echo       null)]';>>%sqlFile%
echo end;>>%sqlFile%
echo />>%sqlFile%
