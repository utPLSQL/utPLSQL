echo off
set UT3_USER=ut3
set UT3_PASSWORD=ut3
set ORACLE_SID=XE
if not [%1] == [] (set UT3_USER=%1)
if not [%2] == [] (set UT3_PASSWORD=%2)
if not [%3] == [] (set ORACLE_SID=%3)

sqlplus %UT3_USER%/%UT3_PASSWORD%@%ORACLE_SID% @RunAll.sql
