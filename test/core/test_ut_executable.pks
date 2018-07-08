create or replace package test_ut_executable is

  --%suite(ut_executable)
  --%suitepath(utplsql.core)

  --%beforeall
  procedure create_dummy_package;

  --%afterall
  procedure drop_dummy_package;

  --%context(do_execute)

  --%test(Executes procedure in current schema when user was not provided)
  --%disabled
  procedure exec_schema_package_proc;

  --%test(Executes procedure and saves dbms_output)
  --%disabled
  procedure exec_package_proc;

  --%test(Executes a procedure raising exception, saves dbms_output and exception stack trace)
  --%disabled
  procedure exec_failing_proc;

  --%test(Sets state invalidation flag when executed procedure in a state-invalidated package, saves dbms_output and exception stack trace)
  --%disabled
  procedure exec_invalid_state_proc;

  --%endcontext

  --%context(form_name)

  --%test(Builds a name for the executable test)
  --%disabled
  procedure form_name;

  --%endcontext

end;
/
