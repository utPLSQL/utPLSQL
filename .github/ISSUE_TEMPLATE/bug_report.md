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
with
  function version_compatibility return varchar2 as
    l_ver  varchar2(100);
    l_comp varchar2(100);
  begin
    dbms_utility.db_version(l_ver, l_comp);
    return l_comp;
  end;
select product, version, version_full, version_compatibility,
       sys_context('userenv', 'current_edition_name') active_edition,
       substr(dbms_utility.port_string,1,60) as cpu_type_and_os
  from product_component_version;

select * from nls_session_parameters;

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
