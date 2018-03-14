declare
 e_not_exists exception;
 pragma exception_init(e_not_exists,-6576);
 l_install_call varchar2(500) := 'call dbms_plsql_code_coverage.create_coverage_tables(force_it => :forceit)';
begin
 execute immediate l_install_call using in true;
exception 
 when e_not_exists then
  dbms_output.put_line('dbms_plsql_code_coverage doesnt exists in your database. Please upgrade.');
end;
/
