set echo off
set feedback off
declare
  i integer := 0;
begin
  dbms_output.put_line('Dropping synonyms pointing to non-existing objects in schema '||upper('&&ut3_owner'));
  for syn in (
  select
    case when owner = 'PUBLIC'
      then 'public synonym '
    else 'synonym ' || owner || '.' end || synonym_name as syn_name,
    table_owner||'.'||table_name as for_object
  from all_synonyms s
  where table_owner = upper('&&ut3_owner') and table_owner != owner
        and not exists (select 1 from all_objects o where o.owner = s.table_owner and o.object_name = s.table_name)
  )
  loop
    i := i + 1;
    begin
      execute immediate 'drop '||syn.syn_name;
      dbms_output.put_line('Dropped '||syn.syn_name||' for object '||syn.for_object);
      exception
      when others then
      dbms_output.put_line('FAILED to drop '||syn.syn_name||' for object '||syn.for_object);
    end;
  end loop;
  dbms_output.put_line('&&line_separator');
  dbms_output.put_line(i||' synonyms dropped');
end;
/

declare
  i integer := 0;
begin
  dbms_output.put_line('Dropping synonyms pointing to PL/SQL code coverage objects on 12.2 ' || upper('&&ut3_owner'));
  for syn in (
  select
    case when owner = 'PUBLIC' then 'public synonym '
    else 'synonym ' || owner || '.'
    end || synonym_name as syn_name,
    table_owner || '.' || table_name as for_object
  from all_synonyms s
  where 1 = 1
        and table_owner = upper('&&ut3_owner')
        and synonym_name in ('DBMSPCC_BLOCKS','DBMSPCC_RUNS','DBMSPCC_UNITS')
  )
  loop

    begin

      execute immediate 'drop '||syn.syn_name;
      dbms_output.put_line('Dropped '||syn.syn_name||' for object '||syn.for_object);
      i := i + 1;

      exception
      when others then
      dbms_output.put_line('FAILED to drop '||syn.syn_name||' for object '||syn.for_object);
    end;

  end loop;
  dbms_output.put_line('&&line_separator');
  dbms_output.put_line(i||' synonyms dropped');
end;
/
