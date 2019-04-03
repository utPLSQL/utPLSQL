create or replace package test_before_after_annotations is

  --%suite(annotations - beforetest and aftertest)
  --%suitepath(utplsql.ut3_tester.core.annotations)

  subtype t_procedure_name is varchar2(250) not null;
  type t_procedures is table of t_procedure_name;

  procedure set_procs_called(a_for_procedure t_procedure_name, a_procedures t_procedures);

  function get_procs_called(a_for_procedure varchar2) return t_procedures pipelined;

  --%beforeall
  procedure create_tests_results;

  --%test(Executes Beforetest call to procedure inside package)
  procedure beforetest_local_procedure;

  --%test(Executes beforetest procedure defined in the package when specified with package name)
  procedure beforetest_local_proc_with_pkg;

  --%test(Executes Beforetest procedure twice when defined twice)
  procedure beforetest_twice;

  --%test(Executes Beforetest procedure from external package)
  procedure beforetest_one_ext_procedure;

  --%test(Executed external and internal Beforetest procedures)
  procedure beforetest_multi_ext_procedure;

  --%test(Stops execution at first non-existing Beforetest procedure and marks test as errored)
  procedure beforetest_missing_procedure;

  --%test(Stops execution at first erroring Beforetest procedure and marks test as errored)
  procedure beforetest_one_err_procedure;

end;
/