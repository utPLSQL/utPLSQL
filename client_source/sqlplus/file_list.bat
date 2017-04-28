@echo off
setlocal EnableDelayedExpansion

REM Using cd to remove the " from paths.
cd %1
set clientPath=%__CD__%
cd %2
set projectPath=%__CD__%
set sourcePath=%3
set testPath=%4

set sqlFile=%clientPath%\project_file_list.sql.tmp

echo begin>%sqlFile%
echo ^  null;>>%sqlFile%

if not %sourcePath% == "-" (
    echo   :l_source_files := q'[ut_varchar2_list(>>%sqlFile%
    call :FileList %sourcePath%
)

if not %testPath% == "-" (
    echo   :l_test_files := q'[ut_varchar2_list(>>%sqlFile%
    call :FileList %testPath%
)

echo end;>>%sqlFile%
echo />>%sqlFile%

goto :eof

:FileList
for /f "tokens=* delims= " %%a in ('dir %projectPath%\%1\* /B /S') do (
    set "filePath=%%a"
    set filePath=!filePath:%projectPath%=!
    echo ^      '!filePath!^',>>%sqlFile%
)
echo       null)]';>>%sqlFile%