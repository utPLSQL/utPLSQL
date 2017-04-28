@echo off

set clientDir=%~dp0
set projectDir=%__CD__%

sqlplus /nolog @%clientDir%\ut_run.sql '%clientDir%' '%projectDir%' %*
