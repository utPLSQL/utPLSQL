#!/usr/bin/env bash

#goto git root directory
git rev-parse && cd "$(git rev-parse --show-cdup)"

. development/env.sh

"${SQLCLI}" sys/${ORACLE_PWD}@//${CONNECTION_STR} AS SYSDBA <<-SQL
set echo on
begin
  for x in (
    select * from dba_objects
     where owner in ( upper('${UT3_RELEASE_VERSION_SCHEMA}'), upper('${UT3_OWNER}') )
       and object_name like 'SYS_PLSQL%')
  loop
    execute immediate 'drop type '||x.owner||'.'||x.object_name||' force';
  end loop;
end;
/

drop user ${UT3_OWNER} cascade;
drop user ${UT3_RELEASE_VERSION_SCHEMA} cascade;
drop user ${UT3_TESTER} cascade;
drop user ${UT3_TESTER_HELPER} cascade;
drop user ${UT3_USER} cascade;

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
