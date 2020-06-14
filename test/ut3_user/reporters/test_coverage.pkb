create or replace package body test_coverage is

  function block_coverage_available return boolean is
  begin
    $if dbms_db_version.version = 12 and dbms_db_version.release >= 2 or dbms_db_version.version > 12 $then
      return true;
    $else
      return false;
    $end
  end;

end;
/
