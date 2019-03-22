create or replace package core is

    gc_success number := ut3.ut_utils.gc_success;
    gc_failure number := ut3.ut_utils.gc_failure;

  --%suite
  --%suitepath(utplsql)

  --%beforeall
  procedure global_setup;

  --%afterall
  procedure global_cleanup;

  procedure execute_autonomous(a_sql varchar2);

  function run_test(a_path varchar2) return clob;

  function get_value(a_variable varchar2) return integer;

  function get_dbms_output_as_clob return clob;
  
  function get_failed_expectations return ut3.ut_varchar2_list;
  
  function get_failed_expectations_n return number;
  
  procedure clear_expectations;
    
  function table_to_clob(a_results in ut3.ut_varchar2_list) return clob;

end;
/
