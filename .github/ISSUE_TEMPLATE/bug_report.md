---
name: Bug report
about: Create a report to help us improve
title: ''
labels: ''
assignees: ''

---

**Describe the bug**
A clear and concise description of what the bug is.

**Provide version info**
Information about utPLSQL and Database version, 
```sql
set serveroutput on
declare
  l_version varchar2(255);
  l_compatibility varchar2(255);
begin
  dbms_utility.db_version( l_version, l_compatibility );
  dbms_output.put_line( l_version );
  dbms_output.put_line( l_compatibility );
end;
/
select substr(ut.version(),1,60) as ut_version from dual;
select * from v$version;
select * from nls_session_parameters;
select substr(dbms_utility.port_string,1,60) as port_string from dual;
```

**Information about client software**
What client was used to run utPLSQL tests? Was it from TOAD, SQLDeveloper, SQLPlus, PLSQL Developer etc...

**To Reproduce**
Steps to reproduce the behavior:
1. Go to '...'
2. Click on '....'
3. Scroll down to '....'
4. See error

**Expected behavior**
A clear and concise description of what you expected to happen.

**Example code**
If applicable, add sample code to help explain your problem.
Please avoid putting your company private/protected code in an issue, as it might violate your company's privacy and security policies.

**Additional context**
Add any other context about the problem here.
