create or replace package core is

  --%suite
  --%suitepath(utplsql)

  --%beforeall
  procedure global_setup;

  --%afterall
  procedure global_cleanup;

  procedure execute_autonomous(a_sql varchar2);

  function run_test(a_path varchar2) return clob;

  function get_value(a_variable varchar2) return integer;



end;
/
