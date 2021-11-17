create or replace package body test_ut_executable is

  g_dbms_output_text varchar2(30) := 'Some output from procedure';

  procedure exec_schema_package_proc is
    l_executable ut3_develop.ut_executable;
    l_test       ut3_develop.ut_test;
    l_result     boolean;
  begin
    --Arrange
    l_test := ut3_develop.ut_test(a_object_name => 'test_ut_executable',a_name => 'test_ut_executable', a_line_no=> 1);
    l_executable := ut3_develop.ut_executable_test( null, 'test_ut_executable', 'passing_proc', ut3_develop.ut_utils.gc_test_execute );
    --Act
    l_result := l_executable.do_execute(l_test);
    --Assert
    ut.expect(l_result).to_be_true;
    ut.expect(l_executable.serveroutput).to_be_null;
    ut.expect(l_executable.get_error_stack_trace()).to_be_null;
  end;

  procedure exec_package_proc_output is
    l_executable ut3_develop.ut_executable;
    l_test       ut3_develop.ut_test;
    l_result     boolean;
  begin
    --Arrange
    l_test := ut3_develop.ut_test(a_object_owner => 'ut3_tester', a_object_name => 'test_ut_executable',a_name => 'test_ut_executable', a_line_no=> 1);
    l_executable := ut3_develop.ut_executable_test( a_owner => 'ut3_tester', a_package => 'test_ut_executable',
      a_procedure_name => 'output_proc', a_executable_type => ut3_develop.ut_utils.gc_test_execute );
    --Act
    l_result := l_executable.do_execute(l_test);
    --Assert
    ut.expect(l_result).to_be_true;
    ut.expect(l_executable.serveroutput).to_equal(to_clob(g_dbms_output_text||chr(10)));
    ut.expect(l_executable.get_error_stack_trace()).to_be_null;
  end;

  procedure exec_failing_proc is
    l_executable ut3_develop.ut_executable;
    l_test       ut3_develop.ut_test;
    l_result     boolean;
  begin
    --Arrange
    l_test := ut3_develop.ut_test(a_object_owner => 'ut3_tester', a_object_name => 'test_ut_executable',a_name => 'test_ut_executable', a_line_no=> 1);
    l_executable := ut3_develop.ut_executable_test( 'ut3_tester', 'test_ut_executable', 'throwing_proc', ut3_develop.ut_utils.gc_test_execute );
    --Act
    l_result := l_executable.do_execute(l_test);
    --Assert
    ut.expect(l_result).to_be_false;
    ut.expect(l_executable.serveroutput).to_be_null;
    ut.expect(l_executable.get_error_stack_trace()).to_be_like('ORA-06501: PL/SQL: program error%');
  end;

  procedure form_name is
  begin
    ut.expect(ut3_develop.ut_executable_test( user, ' package ', 'proc', null ).form_name()).to_equal(user||'.package.proc');
    ut.expect(ut3_develop.ut_executable_test( null, 'package', ' proc ', null ).form_name()).to_equal('package.proc');
    ut.expect(ut3_develop.ut_executable_test( null, 'proc', null, null ).form_name()).to_equal('proc');
    ut.expect(ut3_develop.ut_executable_test( ' '||user||' ', 'proc', null, null ).form_name()).to_equal(user||'.proc');
  end;

  procedure passing_proc is
  begin
    null;
  end;

  procedure output_proc is
  begin
    dbms_output.put_line('Some output from procedure');
  end;

  procedure throwing_proc is
  begin
    raise program_error;
  end;

end;
/
