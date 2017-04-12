@echo off

set /P projectPath=<project_path.tmp

REM Filenames
set fileList=project_file_list.tmp
set fileSQL=project_file_list.sql.tmp

REM List all files in project folder and save into a txt file.
dir %projectPath%\* /B /S>%fileList%

REM Create the script to assing file paths to a ut_varchar2_list.
REM echo var file_list clob>%fileSQL%
echo begin>%fileSQL%
echo   :l_file_list := q'[ut_varchar2_list(>>%fileSQL%
for /f "tokens=* delims= " %%a in (%fileList%) do (
    echo ^      '%%a^',>>%fileSQL%
)
echo       null)]';>>%fileSQL%
echo end;>>%fileSQL%
echo />>%fileSQL%