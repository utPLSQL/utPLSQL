declare
  c_expected_grants constant dbmsoutput_linesarray
  := dbmsoutput_linesarray(
      'CREATE TYPE','CREATE VIEW','CREATE SYNONYM','CREATE SEQUENCE','CREATE PROCEDURE','CREATE TABLE'
  );

  l_expected_grants dbmsoutput_linesarray := c_expected_grants;
  l_missing_grants varchar2(4000);
begin
  if user != SYS_CONTEXT('userenv','current_schema') then
    for i in 1 .. l_expected_grants.count loop
      l_expected_grants(i) := replace(l_expected_grants(i),' ',' ANY ');
    end loop;
  end if;
  select listagg(' -  '||privilege,CHR(10)) within group(order by privilege)
  into l_missing_grants
  from (
    select column_value as privilege
    from table(l_expected_grants)
    minus
    select privilege
    from user_sys_privs
  );
  if l_missing_grants is not null then
    raise_application_error(
        -20000
        , 'The following privileges are required for user "'||user||'" to install into schema "'||SYS_CONTEXT('userenv','current_schema')||'"'||CHR(10)
          ||l_missing_grants
          ||'Please read the installation documentation at http://utplsql.org/utPLSQL/'
    );
  end if;
end;
/
