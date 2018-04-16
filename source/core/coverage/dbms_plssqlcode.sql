begin
  $if dbms_db_version.version = 12 and dbms_db_version.release >= 2 or dbms_db_version.version > 12 $then
    dbms_plsql_code_coverage.create_coverage_tables(force_it => true);
  $else
    null;
  $end
end;
/
