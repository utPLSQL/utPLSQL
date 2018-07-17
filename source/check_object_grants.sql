declare
  c_expected_grants constant dbmsoutput_linesarray := dbmsoutput_linesarray('DBMS_LOCK','DBMS_CRYPTO');

  l_missing_grants varchar2(4000);
  l_target_table   varchar2(128);
  l_owner_column   varchar2(128);

  function get_view(a_dba_view_name varchar2) return varchar2 is
      l_invalid_object_name exception;
    l_result              varchar2(128) := lower(a_dba_view_name);
    pragma exception_init(l_invalid_object_name,-44002);
    begin
      l_result := dbms_assert.sql_object_name(l_result);
      return l_result;
      exception
      when l_invalid_object_name then
      return replace(l_result,'dba_','all_');
    end;

begin
  l_target_table := get_view('dba_tab_privs');
  l_owner_column := case when l_target_table like 'dba%' then 'owner' else 'table_schema' end;
  execute immediate q'[
  select listagg(' -  '||object_name,CHR(10)) within group(order by object_name)
    from (
  select column_value as object_name
    from table(:l_expected_grants)
   minus
  select table_name as object_name
    from ]'||l_target_table||q'[
   where grantee = SYS_CONTEXT('userenv','current_schema')
     and ]'||l_owner_column||q'[ = 'SYS')]'
  into l_missing_grants using c_expected_grants;
  if l_missing_grants is not null then
    raise_application_error(
        -20000
        , 'The following object grants are missing for user "'||SYS_CONTEXT('userenv','current_schema')||'" to install utPLSQL:'||CHR(10)
          ||l_missing_grants||CHR(10)
          ||'Please read the installation documentation at http://utplsql.org/utPLSQL/'
    );
  end if;
end;
/
