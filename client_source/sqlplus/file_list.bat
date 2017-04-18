@echo off
setlocal EnableDelayedExpansion

REM Get the full project path.
pushd %__CD__%
cd %1
set projectPath=%__CD__%
popd

REM Filenames
set fileSQL=project_file_list.sql.tmp

REM Create the script to assing file paths to a ut_varchar2_list.
echo begin>%fileSQL%
echo   :l_file_list := q'[ut_varchar2_list(>>%fileSQL%
for /f "tokens=* delims= " %%a in ('dir %projectPath%\* /B /S') do (
    set "filePath=%%a"
    set filePath=!filePath:%projectPath%=!
    echo ^      '!filePath!^',>>%fileSQL%
)
echo       null)]';>>%fileSQL%
echo end;>>%fileSQL%
echo />>%fileSQL%
