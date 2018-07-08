create or replace package body test_ut_executable is

  --%suite(ut_executable)
  --%suitepath(utplsql.core)

  --%beforeall
  procedure create_dummy_package is
  begin
    null;
  end;

  --%afterall
  procedure drop_dummy_package is
  begin
    null;
  end;

  --%context(do_execute)

  --%test(Executes procedure in current schema when user was not provided)
  procedure exec_schema_package_proc is
  begin
    null;
  end;

  --%test(Executes procedure and saves dbms_output)
  procedure exec_package_proc is
  begin
    null;
  end;

  --%test(Executes a procedure raising exception, saves dbms_output and exception stack trace)
  procedure exec_failing_proc is
  begin
    null;
  end;

  --%test(Sets state invalidation flag when executed procedure in a state-invalidated package, saves dbms_output and exception stack trace)
  procedure exec_invalid_state_proc is
  begin
    null;
  end;

  --%endcontext

  --%context(form_name)

  --%test(Builds a name for the executable test)
  procedure form_name is
  begin
    null;
  end;
  --%endcontext

end;
/
