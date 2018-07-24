create or replace package test_ut_executable is

  --%suite(ut_executable)
  --%suitepath(utplsql.core)

  --%context(do_execute)

  --%test(Executes procedure in current schema when user was not provided)
  procedure exec_schema_package_proc;

  --%test(Executes procedure and saves dbms_output)
  procedure exec_package_proc_output;

  --%test(Executes a procedure raising exception, saves dbms_output and exception stack trace)
  procedure exec_failing_proc;

  $if dbms_db_version.version > 12 $then
  --%disabled
  --%test(Sets state invalid flag when package-state invalidated and saves exception stack trace)
  --%beforetest(create_state_dependant_pkg)
  --%aftertest(drop_state_dependant_pkg)
  procedure exec_invalid_state_proc;
  $else
  --%test(Sets state invalid flag when package-state invalidated and saves exception stack trace)
  --%beforetest(create_state_dependant_pkg)
  --%aftertest(drop_state_dependant_pkg)
  procedure exec_invalid_state_proc;
  $end

  procedure create_state_dependant_pkg;
  procedure drop_state_dependant_pkg;

  --%endcontext

  --%context(form_name)

  --%test(Builds a name for the executable test)
  procedure form_name;

  --%endcontext

  procedure passing_proc;

  procedure output_proc;

  procedure throwing_proc;

end;
/
