@echo off
setlocal EnableDelayedExpansion

set pathParam=%1

REM Trick to get the full path from relative one.
set currentDir=%__CD__%
cd %pathParam%
set projectPath=%__CD__%
cd %currentDir%

set sqlFile=project_file_list.sql.tmp

REM Assign project filenames to the l_file_list bind variable.
echo begin>%sqlFile%
echo   :l_file_list := q'[ut_varchar2_list(>>%sqlFile%
for /f "tokens=* delims= " %%a in ('dir %projectPath%\* /B /S') do (
    set "filePath=%%a"
    set filePath=!filePath:%projectPath%=!
    echo ^      '!filePath!^',>>%sqlFile%
)
echo       null)]';>>%sqlFile%
echo end;>>%sqlFile%
echo />>%sqlFile%
