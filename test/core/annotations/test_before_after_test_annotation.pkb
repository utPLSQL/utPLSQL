create or replace package body test_before_after_annotations is

  type t_executed_procedures is table of t_procedures index by t_procedure_name;
  g_tests_results clob;
  g_executed_procedures t_executed_procedures;


  procedure set_procs_called(a_for_procedure t_procedure_name, a_procedures t_procedures) is
  begin
    g_executed_procedures(a_for_procedure) := a_procedures;
  end;

  function get_procs_called(a_for_procedure varchar2) return t_procedures pipelined is
  begin
    if g_executed_procedures.exists(a_for_procedure) then
      for i in 1 .. g_executed_procedures(a_for_procedure).count loop
        pipe row (g_executed_procedures(a_for_procedure)(i));
      end loop;
    end if;
    return;
  end;

  procedure create_tests_results is
    pragma autonomous_transaction;


    l_dummy_utility_pkg_spec varchar2(32737);
    l_dummy_utility_pkg_body varchar2(32737);
    l_test_package_spec  varchar2(32737);
    l_test_package_body  varchar2(32737);
    l_test_results  ut3.ut_varchar2_list;
    
  begin
    l_dummy_utility_pkg_spec := q'[
      create or replace package shared_test_package is

        procedure before_test;

        procedure set_proc_called(a_procedure_name varchar2);

        function get_procs_called return test_before_after_annotations.t_procedures;

        procedure reset_proc_called;

      end;
    ]';

    l_dummy_utility_pkg_body := q'[
      create or replace package body shared_test_package is

        g_called_procedures test_before_after_annotations.t_procedures := test_before_after_annotations.t_procedures();

        procedure set_proc_called(a_procedure_name varchar2) is
        begin
          g_called_procedures.extend;
          g_called_procedures(g_called_procedures.last) := a_procedure_name;
        end;

        function get_procs_called return test_before_after_annotations.t_procedures is
        begin
          return g_called_procedures;
        end;

        procedure reset_proc_called is
        begin
          g_called_procedures.delete;
        end;

        procedure before_test is
        begin
          set_proc_called('shared_test_package.before_test');
        end;

      end;
    ]';

    l_test_package_spec := q'[
      create or replace package dummy_before_after_test is
        --%suite(Package to test annotations beforetest and aftertest)

        --%aftereach
        procedure clean_global_variables;

        --%test(Executes Beforetest call to procedure inside package)
        --%beforetest(before_test)
        procedure beforetest_local_procedure;

        --%test(Executes beforetest procedure defined in the package when specified with package name)
        --%beforetest(dummy_before_after_test.before_test)
        procedure beforetest_local_proc_with_pkg;

        --%test(Executes Beforetest procedure twice when defined twice)
        --%beforetest(before_test, before_test)
        procedure beforetest_twice;

        --%test(Executes Beforetest procedure from external package)
        --%beforetest(shared_test_package.before_test)
        procedure beforetest_one_ext_procedure;

        --%test(Executed external and internal Beforetest procedures)
        --%beforetest(shared_test_package.before_test, before_test)
        procedure beforetest_multi_ext_procedure;

        --%test(Stops execution at first non-existing Beforetest procedure and marks test as errored)
        --%beforetest(shared_test_package.before_test, non_existent_procedure, before_test)
        procedure beforetest_missing_procedure;

        --%test(Stops execution at first erroring Beforetest procedure and marks test as errored)
        --%beforetest(shared_test_package.before_test, before_test_erroring, before_test)
        procedure beforetest_one_err_procedure;

        procedure before_test;

        procedure before_test_erroring;

      end;
    ]';

    l_test_package_body := q'[
      create or replace package body dummy_before_after_test is

        procedure clean_global_variables is
        begin
          shared_test_package.reset_proc_called;
        end;

        procedure beforetest_local_procedure is
        begin
          test_before_after_annotations.set_procs_called(
            'beforetest_local_procedure',
            shared_test_package.get_procs_called()
          );
        end;

        procedure beforetest_local_proc_with_pkg is
        begin
          test_before_after_annotations.set_procs_called(
            'beforetest_local_proc_with_pkg',
            shared_test_package.get_procs_called()
          );
        end;

        procedure beforetest_twice is
        begin
          test_before_after_annotations.set_procs_called(
            'beforetest_twice',
            shared_test_package.get_procs_called()
          );
        end;

        procedure beforetest_one_ext_procedure is
        begin
          test_before_after_annotations.set_procs_called(
            'beforetest_one_ext_procedure',
            shared_test_package.get_procs_called()
          );
        end;

        procedure beforetest_multi_ext_procedure is
        begin
          test_before_after_annotations.set_procs_called(
            'beforetest_multi_ext_procedure',
            shared_test_package.get_procs_called()
          );
        end;

        procedure beforetest_missing_procedure is
        begin
          test_before_after_annotations.set_procs_called(
            'beforetest_missing_procedure',
            shared_test_package.get_procs_called()
          );
        end;

        procedure beforetest_one_err_procedure is
        begin
          test_before_after_annotations.set_procs_called(
            'beforetest_one_err_procedure',
            shared_test_package.get_procs_called()
          );
        end;

        procedure before_test is
        begin
          shared_test_package.set_proc_called('dummy_before_after_test.before_test');
        end;

        procedure before_test_erroring is
        begin
          shared_test_package.set_proc_called('dummy_before_after_test.before_test_erroring');
          raise program_error;
        end;

      end;
    ]';
    
    execute immediate l_dummy_utility_pkg_spec;
    execute immediate l_dummy_utility_pkg_body;
    execute immediate l_test_package_spec;
    execute immediate l_test_package_body;

    --Execute the tests and collect the results
    select * bulk collect into l_test_results from table(ut3.ut.run(('dummy_before_after_test')));

    execute immediate 'drop package dummy_before_after_test';
    execute immediate 'drop package shared_test_package';

    g_tests_results := ut3.ut_utils.table_to_clob(l_test_results);
  end;

  procedure beforetest_local_procedure is
    l_expected sys_refcursor;
    l_actual   sys_refcursor;
  begin
    open l_expected for
      select 'dummy_before_after_test.before_test' as column_value from dual;
    open l_actual for
      select * from table(test_before_after_annotations.get_procs_called('beforetest_local_procedure'));
    ut.expect(l_actual).to_equal(l_expected);
  end;

  procedure beforetest_local_proc_with_pkg is
    l_expected sys_refcursor;
    l_actual   sys_refcursor;
  begin
    open l_expected for
    select 'dummy_before_after_test.before_test' as column_value from dual;
    open l_actual for
    select * from table(test_before_after_annotations.get_procs_called('beforetest_local_procedure'));
    ut.expect(l_actual).to_equal(l_expected);
  end;

  procedure beforetest_twice is
    l_expected sys_refcursor;
    l_actual   sys_refcursor;
  begin
    open l_expected for
      select 'dummy_before_after_test.before_test' as column_value from dual union all
      select 'dummy_before_after_test.before_test' as column_value from dual;

    open l_actual for
      select * from table(test_before_after_annotations.get_procs_called('beforetest_twice'));
    ut.expect(l_actual).to_equal(l_expected);
  end;

  procedure beforetest_one_ext_procedure is
    l_expected sys_refcursor;
    l_actual   sys_refcursor;
  begin
    open l_expected for
      select 'shared_test_package.before_test' as column_value from dual;

    open l_actual for
      select * from table(test_before_after_annotations.get_procs_called('beforetest_one_ext_procedure'));
    ut.expect(l_actual).to_equal(l_expected);
  end;

  procedure beforetest_multi_ext_procedure is
    l_expected sys_refcursor;
    l_actual   sys_refcursor;
  begin
    open l_expected for
      select 'shared_test_package.before_test' as column_value from dual union all
      select 'dummy_before_after_test.before_test' as column_value from dual;

    open l_actual for
      select * from table(test_before_after_annotations.get_procs_called('beforetest_multi_ext_procedure'));
    ut.expect(l_actual).to_equal(l_expected);
  end;

  procedure beforetest_missing_procedure is
    l_actual   sys_refcursor;
  begin
    open l_actual for
      select * from table(test_before_after_annotations.get_procs_called('beforetest_missing_procedure'));

    ut.expect(l_actual).to_be_empty;

    ut.expect(g_tests_results).to_match(
        '^\s*Stops execution at first non-existing Beforetest procedure and marks test as errored \[[\.0-9]+ sec\] \(FAILED - 1\)\s*$'
        ,'m'
    );
    ut.expect(g_tests_results).to_match(
        '1\) beforetest_missing_procedure\s+' ||
        'Call params for beforetest are not valid: procedure does not exist  ' ||
        'UT3_TESTER.DUMMY_BEFORE_AFTER_TEST.NON_EXISTENT_PROCEDURE'
        ,'m'
    );
  end;

  procedure beforetest_one_err_procedure is
    l_actual   sys_refcursor;
  begin
    open l_actual for
      select * from table(test_before_after_annotations.get_procs_called('beforetest_one_err_procedure'));

    ut.expect(l_actual).to_be_empty;

    ut.expect(g_tests_results).to_match(
        '^\s*Stops execution at first non-existing Beforetest procedure and marks test as errored \[[\.0-9]+ sec\] \(FAILED - 1\)\s*$'
        ,'m'
    );
    ut.expect(g_tests_results).to_match(
        '2\) beforetest_one_err_procedure\s+' ||
        'ORA-06501: PL/SQL: program error'
    ,'m'
    );
  end;

end;
/