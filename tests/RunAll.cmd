echo off
set UT3_OWNER=ut3
set UT3_OWNER_PASSWORD=ut3
set ORACLE_SID=BLD872B
if not [%1] == [] (set UT3_OWNER=%1)
if not [%2] == [] (set UT3_OWNER_PASSWORD=%2)
if not [%3] == [] (set ORACLE_SID=%3)

sqlplus %UT3_OWNER%/%UT3_OWNER_PASSWORD%@%ORACLE_SID% @RunAll.sql
