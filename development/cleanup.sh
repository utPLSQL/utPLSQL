#!/bin/bash

#goto git root directory
git rev-parse && cd "$(git rev-parse --show-cdup)"

. ./development/env.sh

"${SQLCLI}" sys/${ORACLE_PWD}@//${CONNECTION_STR} AS SYSDBA <<-SQL
set echo on
begin
  for x in (
    select * from dba_objects
     where owner in ( upper('${UT3_RELEASE_VERSION_SCHEMA}'), upper('${UT3_DEVELOP_SCHEMA}') )
       and object_name like 'SYS_PLSQL%')
  loop
    execute immediate 'drop type '||x.owner||'.'||x.object_name||' force';
  end loop;
end;
/

drop user ${UT3_DEVELOP_SCHEMA} cascade;
drop user ${UT3_RELEASE_VERSION_SCHEMA} cascade;
drop user ut3_tester cascade;
drop user ut3_tester_helper cascade;
drop user ut3_user cascade;
drop user ut3_cache_test_owner cascade;
drop user ut3_no_extra_priv_user cascade;
drop user ut3_select_catalog_user cascade;
drop user ut3_select_any_table_user cascade;
drop user ut3_execute_any_proc_user cascade;

begin
  for i in (
    select decode(owner,'PUBLIC','drop public synonym "','drop synonym "'||owner||'"."')|| synonym_name ||'"' drop_orphaned_synonym, owner||'.'||synonym_name syn from dba_synonyms a
     where not exists (select 1 from dba_objects b where (a.table_name=b.object_name and a.table_owner=b.owner or b.owner='SYS' and a.table_owner=b.object_name) )
       and a.table_owner not in ('SYS','SYSTEM')
  ) loop
    execute immediate i.drop_orphaned_synonym;
    dbms_output.put_line('synonym '||i.syn||' dropped');
  end loop;
end;
/
exit
SQL
