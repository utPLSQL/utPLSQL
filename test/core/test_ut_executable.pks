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
