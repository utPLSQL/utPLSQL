create or replace package body test_ut_test is

  procedure cleanup_package_state is
  begin
    ut3_tester_helper.ut_example_tests.g_number := null;
  end;

  procedure disabled_test is
    l_suite    ut3.ut_suite;
    l_test     ut3.ut_test;
  begin
    --Arrange
    l_suite := ut3.ut_suite(a_object_owner => 'ut3_tester_helper', a_object_name => 'ut_example_tests', a_line_no=> 1);
    l_suite.path := 'ut3_tester_helper.ut_example_tests';
    l_suite.before_all_list := ut3.ut_executables(ut3.ut_executable(USER, 'ut_example_tests', 'set_g_number_0', ut3.ut_utils.gc_before_all));

    l_suite.items.extend;
    l_suite.items(l_suite.items.last) := ut3.ut_test(a_object_owner => 'ut3_tester_helper',a_object_name => 'ut_example_tests',a_name => 'add_1_to_g_number', a_line_no=> 1);
    l_suite.items.extend;
    l_suite.items(l_suite.items.last) := ut3.ut_test(a_object_owner => 'ut3_tester_helper',a_object_name => 'ut_example_tests',a_name => 'add_1_to_g_number', a_line_no=> 2);
    l_suite.items(l_suite.items.last).disabled_flag := ut3.ut_utils.boolean_to_int(true);
    --Act
    l_suite.do_execute();
    --Assert
    ut.expect(ut3_tester_helper.ut_example_tests.g_number).to_equal(1);
    ut.expect(l_suite.result).to_equal(ut3.ut_utils.gc_success);
    ut.expect(l_suite.results_count.disabled_count).to_equal(1);
    ut.expect(l_suite.results_count.warnings_count).to_equal(0);
    ut.expect(l_suite.results_count.success_count).to_equal(1);
    ut.expect(l_suite.results_count.failure_count).to_equal(0);
    ut.expect(l_suite.results_count.errored_count).to_equal(0);
  end;

  procedure aftertest_errors is
    l_suite    ut3.ut_suite;
    l_test     ut3.ut_test;
  begin
    --Arrange
    l_suite := ut3.ut_suite(a_object_owner => 'ut3_tester_helper', a_object_name => 'ut_example_tests', a_line_no=> 1);
    l_suite.path := 'ut3_tester_helper.ut_example_tests';
    l_suite.before_all_list := ut3.ut_executables(ut3.ut_executable(USER, 'ut_example_tests', 'set_g_number_0', ut3.ut_utils.gc_before_all));

    l_test := ut3.ut_test(a_object_owner => 'ut3_tester_helper',a_object_name => 'ut_example_tests',a_name => 'add_1_to_g_number', a_line_no=> 1);
    l_test.before_test_list := ut3.ut_executables(ut3.ut_executable(USER, 'ut_example_tests', 'add_1_to_g_number', ut3.ut_utils.gc_before_test));
    l_test.after_test_list := ut3.ut_executables(ut3.ut_executable(USER, 'ut_example_tests', 'failing_procedure', ut3.ut_utils.gc_after_test));
    l_suite.items.extend;
    l_suite.items(l_suite.items.last) := l_test;
    l_suite.items.extend;
    l_suite.items(l_suite.items.last) := ut3.ut_test(a_object_owner => 'ut3_tester_helper',a_object_name => 'ut_example_tests',a_name => 'add_1_to_g_number', a_line_no=> 1);
    --Act
    l_suite.do_execute();
    --Assert
    ut.expect(ut3_tester_helper.ut_example_tests.g_number).to_equal(3);
    ut.expect(l_suite.result).to_equal(ut3.ut_utils.gc_error);
    ut.expect(l_suite.results_count.disabled_count).to_equal(0);
    ut.expect(l_suite.results_count.warnings_count).to_equal(0);
    ut.expect(l_suite.results_count.success_count).to_equal(1);
    ut.expect(l_suite.results_count.failure_count).to_equal(0);
    ut.expect(l_suite.results_count.errored_count).to_equal(1);
  end;

  procedure aftereach_errors is
    l_suite    ut3.ut_suite;
    l_test     ut3.ut_test;
  begin
    --Arrange
    l_suite := ut3.ut_suite(a_object_owner => 'ut3_tester_helper', a_object_name => 'ut_example_tests', a_line_no=> 1);
    l_suite.before_all_list := ut3.ut_executables(ut3.ut_executable(USER, 'ut_example_tests', 'set_g_number_0', ut3.ut_utils.gc_before_all));
    l_test := ut3.ut_test(a_object_owner => 'ut3_tester_helper',a_object_name => 'ut_example_tests',a_name => 'add_1_to_g_number', a_line_no=> 1);
    l_test.before_each_list := ut3.ut_executables(ut3.ut_executable(USER, 'ut_example_tests', 'add_1_to_g_number', ut3.ut_utils.gc_before_each));
    l_test.after_each_list := ut3.ut_executables(ut3.ut_executable(USER, 'ut_example_tests', 'failing_procedure', ut3.ut_utils.gc_after_each));
    l_suite.items.extend;
    l_suite.items(l_suite.items.last) := l_test;
    l_suite.items.extend;
    l_suite.items(l_suite.items.last) := ut3.ut_test(a_object_owner => 'ut3_tester_helper',a_object_name => 'ut_example_tests',a_name => 'add_1_to_g_number', a_line_no=> 1);
    --Act
    l_suite.do_execute();
    --Assert
    ut.expect(ut3_tester_helper.ut_example_tests.g_number).to_equal(3);
    ut.expect(l_suite.result).to_equal(ut3.ut_utils.gc_error);
    ut.expect(l_suite.results_count.disabled_count).to_equal(0);
    ut.expect(l_suite.results_count.warnings_count).to_equal(0);
    ut.expect(l_suite.results_count.success_count).to_equal(1);
    ut.expect(l_suite.results_count.failure_count).to_equal(0);
    ut.expect(l_suite.results_count.errored_count).to_equal(1);
  end;

  procedure beforetest_errors is
    l_suite    ut3.ut_suite;
    l_test     ut3.ut_test;
  begin
    --Arrange
    l_suite := ut3.ut_suite(a_object_owner => USER, a_object_name => 'ut_example_tests', a_line_no=> 1);
    l_suite.before_all_list := ut3.ut_executables(ut3.ut_executable(USER, 'ut_example_tests', 'set_g_number_0', ut3.ut_utils.gc_before_all));
    l_test := ut3.ut_test(a_object_owner =>'ut3_tester_helper',a_object_name => 'ut_example_tests',a_name => 'add_1_to_g_number', a_line_no=> 1);
    l_test.before_test_list := ut3.ut_executables(ut3.ut_executable(USER, 'ut_example_tests', 'failing_procedure', ut3.ut_utils.gc_before_test));
    l_test.after_test_list := ut3.ut_executables(ut3.ut_executable(USER, 'ut_example_tests', 'add_1_to_g_number', ut3.ut_utils.gc_after_test));
    l_suite.items.extend;
    l_suite.items(l_suite.items.last) := l_test;
    l_suite.items.extend;
    l_suite.items(l_suite.items.last) := ut3.ut_test(a_object_owner =>'ut3_tester_helper',a_object_name => 'ut_example_tests',a_name => 'add_1_to_g_number', a_line_no=> 1);
    --Act
    l_suite.do_execute();
    --Assert
    ut.expect(ut3_tester_helper.ut_example_tests.g_number).to_equal(2);
    ut.expect(l_suite.result).to_equal(ut3.ut_utils.gc_error);
    ut.expect(l_suite.results_count.disabled_count).to_equal(0);
    ut.expect(l_suite.results_count.warnings_count).to_equal(0);
    ut.expect(l_suite.results_count.success_count).to_equal(1);
    ut.expect(l_suite.results_count.failure_count).to_equal(0);
    ut.expect(l_suite.results_count.errored_count).to_equal(1);
  end;

  procedure beforeeach_errors is
    l_suite    ut3.ut_suite;
    l_test     ut3.ut_test;
  begin
    --Arrange
    l_suite := ut3.ut_suite(a_object_owner => USER, a_object_name => 'ut_example_tests', a_line_no=> 1);
    l_suite.before_all_list := ut3.ut_executables(ut3.ut_executable(USER, 'ut_example_tests', 'set_g_number_0', ut3.ut_utils.gc_before_all));
    l_test := ut3.ut_test(a_object_owner => USER,a_object_name => 'ut_example_tests',a_name => 'add_1_to_g_number', a_line_no=> 1);
    l_test.before_each_list := ut3.ut_executables(ut3.ut_executable(USER, 'ut_example_tests', 'failing_procedure', ut3.ut_utils.gc_before_each));
    l_test.after_each_list := ut3.ut_executables(ut3.ut_executable(USER, 'ut_example_tests', 'add_1_to_g_number', ut3.ut_utils.gc_after_each));
    l_suite.items.extend;
    l_suite.items(l_suite.items.last) := l_test;
    l_suite.items.extend;
    l_suite.items(l_suite.items.last) := ut3.ut_test(a_object_owner => USER,a_object_name => 'ut_example_tests',a_name => 'add_1_to_g_number', a_line_no=> 1);
    --Act
    l_suite.do_execute();
    --Assert
    ut.expect(ut3_tester_helper.ut_example_tests.g_number).to_equal(2);
    ut.expect(l_suite.result).to_equal(ut3.ut_utils.gc_error);
    ut.expect(l_suite.results_count.disabled_count).to_equal(0);
    ut.expect(l_suite.results_count.warnings_count).to_equal(0);
    ut.expect(l_suite.results_count.success_count).to_equal(1);
    ut.expect(l_suite.results_count.failure_count).to_equal(0);
    ut.expect(l_suite.results_count.errored_count).to_equal(1);
  end;

  procedure after_each_executed is
    --Arrange
    l_test ut3.ut_test := ut3.ut_test(
      a_object_owner => 'ut3_tester_helper',
      a_object_name  => 'ut_example_tests',
      a_name     => 'set_g_number_0',
      a_line_no => null
    );
  begin
    l_test.after_each_list := ut3.ut_executables(
      ut3.ut_executable(
        user, 
        'UT_EXAMPLE_TESTS', 
        'add_1_to_g_number', 
        ut3.ut_utils.gc_after_each
        )
    );
    --Act
    l_test.do_execute();
    --Assert
    ut.expect(l_test.result).to_equal(ut3.ut_utils.gc_success);
    ut.expect(ut3_tester_helper.ut_example_tests.g_number).to_equal(1);
  end;

  procedure after_each_proc_name_invalid is
    --Arrange
    l_test ut3.ut_test := ut3.ut_test(
      a_object_owner => 'ut3_tester_helper',
      a_object_name  => 'ut_example_tests',
      a_name     => 'set_g_number_0',
      a_line_no => null
    );
  begin
    l_test.after_each_list := ut3.ut_executables(
      ut3.ut_executable(user, 'ut_example_tests', 'invalid setup name', ut3.ut_utils.gc_after_each)
    );
    --Act
    l_test.do_execute();
    --Assert
    ut.expect(l_test.result).to_equal(ut3.ut_utils.gc_error);
    ut.expect(ut3_tester_helper.ut_example_tests.g_number).to_equal(0);
  end;

  procedure after_each_procedure_name_null is
    --Arrange
    l_test ut3.ut_test := ut3.ut_test(
      a_object_owner => 'ut3_tester_helper',
      a_object_name  => 'ut_example_tests',
      a_name     => 'set_g_number_0',
      a_line_no => null
    );
    begin
      l_test.after_each_list := ut3.ut_executables(
        ut3.ut_executable(user, 'ut_example_tests', null, ut3.ut_utils.gc_after_each)
      );
      --Act
      l_test.do_execute();
      --Assert
      ut.expect(l_test.result).to_equal(ut3.ut_utils.gc_error);
      ut.expect(ut3_tester_helper.ut_example_tests.g_number).to_equal(0);
  end;

  procedure create_app_info_package is
    pragma autonomous_transaction;
  begin
    execute immediate q'[create or replace package ut_output_tests
      as
       --%suite

        gv_before_all_client_info  varchar2(200);
        gv_before_each_client_info varchar2(200);
        gv_before_test_client_info varchar2(200);
        gv_after_test_client_info  varchar2(200);
        gv_after_each_client_info  varchar2(200);
        gv_after_all_client_info   varchar2(200);

       --%test
       --%beforetest(before_test)
       --%aftertest(after_test)
       procedure the_test;

       --%beforeall
       procedure beforeall;

       --%beforeeach
       procedure beforeeach;

       procedure before_test;
       procedure after_test;

       --%aftereach
       procedure aftereach;

       --%afterall
       procedure afterall;

      end;]';
    execute immediate q'[create or replace package body ut_output_tests
      as

       procedure the_test
       as
         l_module_name varchar2(4000);
         l_action_name varchar2(4000);
         l_client_info varchar2(4000);
       begin
         --Generate empty output
         dbms_output.put_line('');
         ut.expect(1,'Test 1 Should Pass').to_equal(1);
         dbms_application_info.read_module(module_name => l_module_name, action_name => l_action_name);
         dbms_application_info.read_client_info(l_client_info);
         ut.expect(l_module_name).to_equal('utPLSQL');
         ut.expect(l_action_name).to_be_like('ut_output_tests');
         ut.expect(l_client_info).to_be_like('the_test');
       end;

       procedure beforeall is
       begin
         dbms_application_info.read_client_info(gv_before_all_client_info);
       end;

       procedure beforeeach is
       begin
         dbms_application_info.read_client_info(gv_before_each_client_info);
       end;

       procedure before_test is
       begin
         dbms_application_info.read_client_info(gv_before_test_client_info);
       end;
       procedure after_test is
       begin
         dbms_application_info.read_client_info(gv_after_test_client_info);
       end;

       procedure aftereach is
       begin
         dbms_application_info.read_client_info(gv_after_each_client_info);
       end;

       procedure afterall is
       begin
         dbms_application_info.read_client_info(gv_after_all_client_info);
       end;

      end;]';
  end;

  procedure drop_app_info_package is
    pragma autonomous_transaction;
  begin
    execute immediate q'[drop package ut_output_tests]';
  end;

  procedure application_info_on_execution is
    l_output_data       ut3.ut_varchar2_list;
    l_output            clob;
    function get_test_value(a_variable_name varchar2) return varchar2 is
      l_result varchar2(4000);
    begin
      execute immediate 'begin :i := ut_output_tests.'||a_variable_name||'; end;' using out l_result;
      return l_result;
    end;
  begin
    --act
    select * bulk collect into l_output_data
      from table(ut3.ut.run('ut_output_tests'));
    l_output := ut3.ut_utils.table_to_clob(l_output_data);
    --assert

    ut.expect(get_test_value('gv_before_all_client_info')).to_equal('beforeall');
    ut.expect(get_test_value('gv_before_each_client_info')).to_equal('beforeeach');
    ut.expect(get_test_value('gv_before_test_client_info')).to_equal('before_test');
    ut.expect(get_test_value('gv_after_test_client_info')).to_equal('after_test');
    ut.expect(get_test_value('gv_after_each_client_info')).to_equal('aftereach');
    ut.expect(get_test_value('gv_after_all_client_info')).to_equal('afterall');
    ut.expect(l_output).to_be_like('%0 failed, 0 errored, 0 disabled, 0 warning(s)%');
  end;

  procedure before_each_executed is
    --Arrange
    l_test ut3.ut_test := ut3.ut_test(
      a_object_owner => 'ut3_tester_helper',
      a_object_name  => 'ut_example_tests',
      a_name     => 'add_1_to_g_number',
      a_line_no => null
    );
  begin
    l_test.before_each_list := ut3.ut_executables(ut3.ut_executable(user, 'ut_example_tests', 'set_g_number_0', ut3.ut_utils.gc_before_each));
    --Act
    l_test.do_execute();
    --Assert
    ut.expect(l_test.result).to_equal(ut3.ut_utils.gc_success);
    ut.expect(ut3_tester_helper.ut_example_tests.g_number).to_equal(1);
  end;


  procedure before_each_proc_name_invalid is
    --Arrange
    l_test ut3.ut_test := ut3.ut_test(
      a_object_owner => 'ut3_tester_helper',
      a_object_name  => 'ut_example_tests',
      a_name     => 'set_g_number_0',
      a_line_no => null
    );
  begin
    l_test.before_each_list := ut3.ut_executables(
      ut3.ut_executable(user, 'ut_example_tests', 'invalid setup name', ut3.ut_utils.gc_before_each)
    );
    --Act
    l_test.do_execute();
    --Assert
    ut.expect(l_test.result).to_equal(ut3.ut_utils.gc_error);
    ut.expect(ut3_tester_helper.ut_example_tests.g_number).to_be_null;
  end;

  procedure before_each_proc_name_null is
    --Arrange
    l_test ut3.ut_test := ut3.ut_test(
      a_object_owner => 'ut3_tester_helper',
      a_object_name  => 'ut_example_tests',
      a_name     => 'set_g_number_0',
      a_line_no => null
    );
  begin
    l_test.before_each_list := ut3.ut_executables(
      ut3.ut_executable(user, 'ut_example_tests', null, ut3.ut_utils.gc_before_each)
    );
    --Act
    l_test.do_execute();
    --Assert
    ut.expect(l_test.result).to_equal(ut3.ut_utils.gc_error);
    ut.expect(ut3_tester_helper.ut_example_tests.g_number).to_be_null;
  end;

  procedure ignore_savepoint_exception is
    pragma autonomous_transaction;
    --Arrange
    l_test ut3.ut_test := ut3.ut_test(
      a_object_owner => 'ut3_tester_helper',
      a_object_name  => 'ut_example_tests',
      a_name => 'ut_commit_test',
      a_line_no => null
    );
  begin
    l_test.rollback_type := ut3.ut_utils.gc_rollback_auto;
    --Act
    l_test.do_execute();
    --Assert
    ut.expect(l_test.result).to_equal(ut3.ut_utils.gc_success);
  end;

  procedure owner_name_invalid is
    --Arrange
    l_test ut3.ut_test := ut3.ut_test(
      a_object_owner => 'invalid owner name',
      a_object_name  => 'ut_example_tests',
      a_name     => 'set_g_number_0',
      a_line_no => null
    );
  begin
    --Act
    l_test.do_execute();
    --Assert
    ut.expect(l_test.result).to_equal(ut3.ut_utils.gc_error);
  end;

  procedure create_synonym is
  begin
   ut3_tester_helper.ut_example_tests.create_synonym;
  end;
  
  procedure drop_synonym is
  begin
   ut3_tester_helper.ut_example_tests.drop_synonym;
  end;

  procedure owner_name_null is
    --Arrange
    l_test ut3.ut_test := ut3.ut_test(
      a_object_name  => 'ut_example_tests',
      a_name     => 'set_g_number_0',
      a_line_no => null
    );
  begin
    --Act
    l_test.do_execute();
    --Assert
    ut.expect(l_test.result).to_equal(ut3.ut_utils.gc_success);
    ut.expect(ut3_tester_helper.ut_example_tests.g_number).to_equal(0);
  end;

  procedure create_invalid_package is
    pragma autonomous_transaction;
  begin
    execute immediate 'create or replace package invalid_package is
      v_variable non_existing_type;
      procedure ut_exampletest;
    end;';
  exception when others then
    null;
  end;

  procedure drop_invalid_package is
    pragma autonomous_transaction;
  begin
    execute immediate 'drop package invalid_package';
  exception when others then
    null;
  end;

  procedure package_in_invalid_state is
    --Arrange
    l_test ut3.ut_test := ut3.ut_test(
      a_object_name  => 'invalid_package',
      a_name     => 'ut_exampletest',
      a_line_no => null
    );
  begin
    --Act
    l_test.do_execute();
    --Assert
    ut.expect(l_test.result).to_equal(ut3.ut_utils.gc_error);
  end;

  procedure package_name_invalid is
    --Arrange
    l_test ut3.ut_test := ut3.ut_test(
      a_object_name  => 'invalid package name',
      a_name     => 'set_g_number_0',
      a_line_no => null
    );
  begin
    --Act
    l_test.do_execute();
    --Assert
    ut.expect(l_test.result).to_equal(ut3.ut_utils.gc_error);
  end;

  procedure package_name_null is
    --Arrange
    l_test ut3.ut_test := ut3.ut_test(
      a_object_name  => null,
      a_name     => 'set_g_number_0',
      a_line_no => null
    );
  begin
    --Act
    l_test.do_execute();
    --Assert
    ut.expect(l_test.result).to_equal(ut3.ut_utils.gc_error);
  end;

  procedure procedure_name_invalid is
    --Arrange
    l_test ut3.ut_test := ut3.ut_test(
      a_object_owner => 'ut3_tester_helper',
      a_object_name  => 'ut_example_tests',
      a_name     => 'invalid procedure name',
      a_line_no => null
    );
  begin
    --Act
    l_test.do_execute();
    --Assert
    ut.expect(l_test.result).to_equal(ut3.ut_utils.gc_error);
  end;

  procedure procedure_name_null is
    --Arrange
    l_test ut3.ut_test := ut3.ut_test(
      a_object_owner => 'ut3_tester_helper',
      a_object_name  => 'ut_example_tests',
      a_name     => null,
      a_line_no => null
    );
  begin
    --Act
    l_test.do_execute();
    --Assert
    ut.expect(l_test.result).to_equal(ut3.ut_utils.gc_error);
  end;

  procedure before_test_executed is
    --Arrange
    l_test ut3.ut_test := ut3.ut_test(
      a_object_owner => 'ut3_tester_helper',
      a_object_name  => 'ut_example_tests',
      a_name     => 'add_1_to_g_number',
      a_line_no => null
    );
  begin
    l_test.before_test_list := ut3.ut_executables(ut3.ut_executable(user, 'ut_example_tests', 'set_g_number_0', ut3.ut_utils.gc_before_test));
    --Act
    l_test.do_execute();
    --Assert
    ut.expect(l_test.result).to_equal(ut3.ut_utils.gc_success);
    ut.expect(ut3_tester_helper.ut_example_tests.g_number).to_equal(1);
  end;

  procedure before_test_proc_name_invalid is
    --Arrange
    l_test ut3.ut_test := ut3.ut_test(
      a_object_owner => 'ut3_tester_helper',
      a_object_name  => 'ut_example_tests',
      a_name     => 'set_g_number_0',
      a_line_no => null
    );
  begin
    l_test.before_test_list := ut3.ut_executables(
      ut3.ut_executable(user, 'ut_example_tests', 'invalid setup name', ut3.ut_utils.gc_before_test)
    );
    --Act
    l_test.do_execute();
    --Assert
    ut.expect(l_test.result).to_equal(ut3.ut_utils.gc_error);
    ut.expect(ut3_tester_helper.ut_example_tests.g_number).to_be_null;
  end;

  procedure before_test_proc_name_null is
    --Arrange
    l_test ut3.ut_test := ut3.ut_test(
      a_object_owner => 'ut3_tester_helper',
      a_object_name  => 'ut_example_tests',
      a_name     => 'set_g_number_0',
      a_line_no => null
    );
  begin
    l_test.before_test_list := ut3.ut_executables(
      ut3.ut_executable(user, 'ut_example_tests', null, ut3.ut_utils.gc_before_test)
    );
    --Act
    l_test.do_execute();
    --Assert
    ut.expect(l_test.result).to_equal(ut3.ut_utils.gc_error);
    ut.expect(ut3_tester_helper.ut_example_tests.g_number).to_be_null;
  end;

  procedure after_test_executed is
    --Arrange
    l_test ut3.ut_test := ut3.ut_test(
      a_object_owner => 'ut3_tester_helper',
      a_object_name  => 'ut_example_tests',
      a_name     => 'set_g_number_0',
      a_line_no => null
    );
  begin
    l_test.after_test_list := ut3.ut_executables(ut3.ut_executable(user, 'ut_example_tests', 'add_1_to_g_number', ut3.ut_utils.gc_after_test));
    --Act
    l_test.do_execute();
    --Assert
    ut.expect(l_test.result).to_equal(ut3.ut_utils.gc_success);
    ut.expect(ut3_tester_helper.ut_example_tests.g_number).to_equal(1);
  end;

  procedure after_test_proce_name_invalid is
    --Arrange
    l_test ut3.ut_test := ut3.ut_test(
      a_object_owner => 'ut3_tester_helper',
      a_object_name  => 'ut_example_tests',
      a_name     => 'set_g_number_0',
      a_line_no => null
    );
  begin
    l_test.after_test_list := ut3.ut_executables(
      ut3.ut_executable(user, 'ut_example_tests', 'invalid procedure name', ut3.ut_utils.gc_after_test)
    );
    --Act
    l_test.do_execute();
    --Assert
    ut.expect(l_test.result).to_equal(ut3.ut_utils.gc_error);
    ut.expect(ut3_tester_helper.ut_example_tests.g_number).to_equal(0);
  end;

  procedure after_test_proc_name_null is
    --Arrange
    l_test ut3.ut_test := ut3.ut_test(
      a_object_owner => 'ut3_tester_helper',
      a_object_name  => 'ut_example_tests',
      a_name     => 'set_g_number_0',
      a_line_no => null
    );
  begin
    l_test.after_test_list := ut3.ut_executables(
      ut3.ut_executable(user, 'ut_example_tests', null, ut3.ut_utils.gc_after_test)
    );
    --Act
    l_test.do_execute();
    --Assert
    ut.expect(l_test.result).to_equal(ut3.ut_utils.gc_error);
    ut.expect(ut3_tester_helper.ut_example_tests.g_number).to_equal(0);
  end;

  procedure create_output_package is
    pragma autonomous_transaction;
  begin
    execute immediate q'[create or replace package ut_output_tests
      as
       --%suite

       --%beforeeach
       procedure beforeeach;

       --%aftereach
       procedure aftereach;

       --%test
       --%beforetest(beforetest)
       --%aftertest(aftertest)
       procedure ut_passing_test;

       procedure beforetest;

       procedure aftertest;

       --%beforeall
       procedure beforeall;
       --%afterall
       procedure afterall;

      end;]';
    execute immediate q'[create or replace package body ut_output_tests
      as

       procedure beforetest is
       begin
         dbms_output.put_line('<!beforetest!>');
       end;

       procedure aftertest is
       begin
         dbms_output.put_line('<!aftertest!>');
       end;

       procedure beforeeach is
       begin
         dbms_output.put_line('<!beforeeach!>');
       end;

       procedure aftereach is
       begin
         dbms_output.put_line('<!aftereach!>');
       end;

       procedure ut_passing_test is
       begin
         dbms_output.put_line('<!thetest!>');
         ut.expect(1,'Test 1 Should Pass').to_equal(1);
       end;

       procedure beforeall is
       begin
         dbms_output.put_line('<!beforeall!>');
       end;

       procedure afterall is
       begin
         dbms_output.put_line('<!afterall!>');
       end;

      end;]';
    exception when others then
    null;
  end;

  procedure drop_output_package is
    pragma autonomous_transaction;
  begin
    execute immediate 'drop package ut_output_tests';
    exception when others then
    null;
  end;

  procedure test_output_gathering is
    l_output_data       ut3.ut_varchar2_list;
    l_output            clob;
  begin
    select * bulk collect into l_output_data
      from table(ut3.ut.run('ut_output_tests'));
    l_output := ut3.ut_utils.table_to_clob(l_output_data);
    ut.expect(l_output).to_be_like(
      '%<!beforeall!>%<!beforeeach!>%<!beforetest!>%<!thetest!>%<!aftertest!>%<!aftereach!>%<!afterall!>%1 tests, 0 failed, 0 errored%'
    );
  end;


end;
/
