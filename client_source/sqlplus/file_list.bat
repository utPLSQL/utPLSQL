@echo off
setlocal EnableDelayedExpansion

set projectPath=%__CD__%
set sourcePath=%2
set testPath=%3

set sqlFile=project_file_list.sql.tmp

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
