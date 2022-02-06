create or replace package body test_annot_disabled_reason
is

  procedure compile_dummy_packages is
    pragma autonomous_transaction;
  begin
    execute immediate q'[create or replace package test_package_1 is

  --%suite
  --%displayname(disable_test_suite_level)
  --%suitepath(tests)
  --%rollback(manual)

  --%disabled( Tests are disabled on suite level )

  --%context( First context )
  
  --%test(Test1 from test package 1)
  procedure test1;

  --%test(Test2 from test package 1)
  procedure test2;
  
  --%endcontext
  
  --%context( Second context )
  
  --%test(Test3 from test package 1)
  procedure test3;

  --%test(Test4 from test package 1)
  procedure test4;

  --%endcontext
  
end test_package_1;]';

    execute immediate q'[create or replace package body test_package_1 is

  procedure test1 is
  begin
    ut.expect(1).to_equal(1);
  end;

  procedure test2 is
  begin
    ut.expect(2).to_equal(2);
  end;

  procedure test3 is
  begin
    ut.expect(1).to_equal(1);
  end;

  procedure test4 is
  begin
    ut.expect(2).to_equal(2);
  end;

end test_package_1;]';

    execute immediate q'[create or replace package test_package_2 is

  --%suite
  --%displayname(Disable on context level)
  --%suitepath(tests)
  --%rollback(manual)

  --%context( First context )
  
  --%disabled( Tests and disabled on first context level )  
  
  --%test(Test1 from test package 2)
  procedure test1;

  --%test(Test2 from test package 2)
  procedure test2;
  
  --%endcontext
  
  --%context( Second context )
  
  --%test(Test3 from test package 2)
  procedure test3;

  --%test(Test4 from test package 3)
  procedure test4;

  --%endcontext
  
end test_package_2;]';

    execute immediate q'[create or replace package body test_package_2 is

  procedure test1 is
  begin
    ut.expect(1).to_equal(1);
  end;

  procedure test2 is
  begin
    ut.expect(2).to_equal(2);
  end;

  procedure test3 is
  begin
    ut.expect(1).to_equal(1);
  end;

  procedure test4 is
  begin
    ut.expect(2).to_equal(2);
  end;

end test_package_2;]';

    execute immediate q'[create or replace package test_package_3 is

  --%suite
  --%displayname(Disable tests on test level)
  --%suitepath(tests)
  --%rollback(manual)

  --%context( First context )
  
  --%test(Test1 from test package 3)
  --%disabled( Test1 disabled from first context ) 
  procedure test1;

  --%test(Test2 from test package 3)
  procedure test2;
  
  --%endcontext
  
  --%context( Second context )
  
  --%test(Test3 from test package 3)
  procedure test3;

  --%test(Test4 from test package 3)
  --%disabled( Test4 disabled from second context )   
  procedure test4;

  --%endcontext
  
end test_package_3;]';

    execute immediate q'[create or replace package body test_package_3 is

  procedure test1 is
  begin
    ut.expect(1).to_equal(1);
  end;

  procedure test2 is
  begin
    ut.expect(2).to_equal(2);
  end;

  procedure test3 is
  begin
    ut.expect(1).to_equal(1);
  end;

  procedure test4 is
  begin
    ut.expect(2).to_equal(2);
  end;

end test_package_3;]';

    execute immediate q'[create or replace package test_package_4 is

  --%suite
  --%displayname(Disable reason is very long or have special characters)
  --%suitepath(tests)
  --%rollback(manual)

  
  --%test(Test1 from test package 4)
  --%disabled( $#?!%*&-/\^ ) 
  procedure test1;

  --%test(Test2 from test package 4) --%disabled(verylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtext) 
  procedure test2;
  
end test_package_4;]';

    execute immediate q'[create or replace package body test_package_4 is

  procedure test1 is
  begin
    ut.expect(1).to_equal(1);
  end;

  procedure test2 is
  begin
    ut.expect(2).to_equal(2);
  end;

end test_package_4;]';

    execute immediate q'[create or replace package test_package_5 is

  --%suite
  --%displayname(Disable tests on suite level overriding rest) 
  --%suitepath(tests)
  --%rollback(manual)

  --%disabled( Disable on suite level )

  --%context( First context )
  
  --%disabled( Disable on 1st context level )  
  
  --%test(Test1 from test package 3)
  --%disabled( Disable on 1st test level ) 
  procedure test1;

  --%test(Test2 from test package 3)
  --%disabled( Disable on 2nd test level )   
  procedure test2;
  
  --%endcontext
  
  --%context( Second context )
  
  --%disabled( Disable on 2nd context level )    
  
  --%test(Test3 from test package 3)
  --%disabled( Disable on 3rd test level )     
  procedure test3;

  --%test(Test4 from test package 3)
  --%disabled( Disable on 4th test level ) 
  procedure test4;

  --%endcontext
  
end test_package_5;]';

    execute immediate q'[create or replace package body test_package_5 is

  procedure test1 is
  begin
    ut.expect(1).to_equal(1);
  end;

  procedure test2 is
  begin
    ut.expect(2).to_equal(2);
  end;

  procedure test3 is
  begin
    ut.expect(1).to_equal(1);
  end;

  procedure test4 is
  begin
    ut.expect(2).to_equal(2);
  end;

end test_package_5;]';

    execute immediate q'[create or replace package test_package_6 is

  --%suite
  --%displayname(Disable tests on each of ctx level overriding rest) 
  --%suitepath(tests)
  --%rollback(manual)

  --%context( First context )
  
  --%disabled( Disable on 1st context level )  
  
  --%test(Test1 from test package 3)
  --%disabled( Disable on 1st test level ) 
  procedure test1;

  --%test(Test2 from test package 3)
  --%disabled( Disable on 2nd test level )   
  procedure test2;
  
  --%endcontext
  
  --%context( Second context )
  
  --%disabled( Disable on 2nd context level )    
  
  --%test(Test3 from test package 3)
  --%disabled( Disable on 3rd test level )     
  procedure test3;

  --%test(Test4 from test package 3)
  --%disabled( Disable on 4th test level ) 
  procedure test4;

  --%endcontext
  
end test_package_6;]';

    execute immediate q'[create or replace package body test_package_6 is

  procedure test1 is
  begin
    ut.expect(1).to_equal(1);
  end;

  procedure test2 is
  begin
    ut.expect(2).to_equal(2);
  end;

  procedure test3 is
  begin
    ut.expect(1).to_equal(1);
  end;

  procedure test4 is
  begin
    ut.expect(2).to_equal(2);
  end;

end test_package_6;]';

  end;


  procedure drop_dummy_packages is
    pragma autonomous_transaction;
  begin
    execute immediate 'drop package test_package_1';
    execute immediate 'drop package test_package_2';
    execute immediate 'drop package test_package_3';
	execute immediate 'drop package test_package_4';
	execute immediate 'drop package test_package_5';
	execute immediate 'drop package test_package_6';	
  end;

  procedure test_disable_on_suite_level is
    c_path varchar2(100) := sys_context('USERENV', 'CURRENT_USER')||'.test_package_1';
    l_objects_to_run ut3_develop.ut_suite_items;

    l_test0_suite ut3_develop.ut_logical_suite;
    l_test1_suite ut3_develop.ut_suite;
  begin
  --Act
    l_objects_to_run := ut3_develop.ut_suite_manager.configure_execution_by_path(ut3_develop.ut_varchar2_list(c_path));

  --Assert
    ut.expect(l_objects_to_run.count).to_equal(1);
    l_test0_suite := treat(l_objects_to_run(1) as ut3_develop.ut_logical_suite);
    l_test1_suite :=  treat(l_test0_suite.items(1) as ut3_develop.ut_suite);

    ut.expect(l_test1_suite.items(1).name).to_equal('test1');
    ut.expect(treat(l_test1_suite.items(1) as ut3_develop.ut_test).disabled_flag).to_equal(1);
    ut.expect(treat(l_test1_suite.items(1) as ut3_develop.ut_test).disabled_reason).to_equal('Tests are disabled on suite level');
	
    ut.expect(l_test1_suite.items(2).name).to_equal('test2');
    ut.expect(treat(l_test1_suite.items(2) as ut3_develop.ut_test).disabled_flag).to_equal(1);
    ut.expect(treat(l_test1_suite.items(2) as ut3_develop.ut_test).disabled_reason).to_equal('Tests are disabled on suite level');

    ut.expect(l_test1_suite.items(3).name).to_equal('test3');
    ut.expect(treat(l_test1_suite.items(3) as ut3_develop.ut_test).disabled_flag).to_equal(1);
    ut.expect(treat(l_test1_suite.items(3) as ut3_develop.ut_test).disabled_reason).to_equal('Tests are disabled on suite level');
	
    ut.expect(l_test1_suite.items(4).name).to_equal('test4');
    ut.expect(treat(l_test1_suite.items(4) as ut3_develop.ut_test).disabled_flag).to_equal(1);	
    ut.expect(treat(l_test1_suite.items(4) as ut3_develop.ut_test).disabled_reason).to_equal('Tests are disabled on suite level');

  end;

  procedure test_dis_on_1st_ctx_level is
    c_path varchar2(100) := sys_context('USERENV', 'CURRENT_USER')||'.test_package_2';
    l_objects_to_run ut3_develop.ut_suite_items;

    l_test0_suite ut3_develop.ut_logical_suite;
    l_test1_suite ut3_develop.ut_suite;
  begin
  --Act
    l_objects_to_run := ut3_develop.ut_suite_manager.configure_execution_by_path(ut3_develop.ut_varchar2_list(c_path));

  --Assert
    ut.expect(l_objects_to_run.count).to_equal(1);
    l_test0_suite := treat(l_objects_to_run(1) as ut3_develop.ut_logical_suite);
    l_test1_suite :=  treat(l_test0_suite.items(1) as ut3_develop.ut_suite);

    ut.expect(l_test1_suite.items(1).name).to_equal('test1');
    ut.expect(treat(l_test1_suite.items(1) as ut3_develop.ut_test).disabled_flag).to_equal(1);
    ut.expect(treat(l_test1_suite.items(1) as ut3_develop.ut_test).disabled_reason).to_equal('Tests and disabled on first context level');
	
    ut.expect(l_test1_suite.items(2).name).to_equal('test2');
    ut.expect(treat(l_test1_suite.items(2) as ut3_develop.ut_test).disabled_flag).to_equal(1);
    ut.expect(treat(l_test1_suite.items(2) as ut3_develop.ut_test).disabled_reason).to_equal('Tests and disabled on first context level');

    ut.expect(l_test1_suite.items(3).name).to_equal('test3');
    ut.expect(treat(l_test1_suite.items(3) as ut3_develop.ut_test).disabled_flag).to_equal(0);
    ut.expect(treat(l_test1_suite.items(3) as ut3_develop.ut_test).disabled_reason).to_be_null;
	
    ut.expect(l_test1_suite.items(4).name).to_equal('test4');
    ut.expect(treat(l_test1_suite.items(4) as ut3_develop.ut_test).disabled_flag).to_equal(0);	
    ut.expect(treat(l_test1_suite.items(4) as ut3_develop.ut_test).disabled_reason).to_be_null;

  end;

  procedure test_disable_tests_level is
    c_path varchar2(100) := sys_context('USERENV', 'CURRENT_USER')||'.test_package_3';
    l_objects_to_run ut3_develop.ut_suite_items;

    l_test0_suite ut3_develop.ut_logical_suite;
    l_test1_suite ut3_develop.ut_suite;
  begin
  --Act
    l_objects_to_run := ut3_develop.ut_suite_manager.configure_execution_by_path(ut3_develop.ut_varchar2_list(c_path));

  --Assert
    ut.expect(l_objects_to_run.count).to_equal(1);
    l_test0_suite := treat(l_objects_to_run(1) as ut3_develop.ut_logical_suite);
    l_test1_suite :=  treat(l_test0_suite.items(1) as ut3_develop.ut_suite);

    ut.expect(l_test1_suite.items(1).name).to_equal('test1');
    ut.expect(treat(l_test1_suite.items(1) as ut3_develop.ut_test).disabled_flag).to_equal(1);
    ut.expect(treat(l_test1_suite.items(1) as ut3_develop.ut_test).disabled_reason).to_equal('Test1 disabled from first context');
	
    ut.expect(l_test1_suite.items(2).name).to_equal('test2');
    ut.expect(treat(l_test1_suite.items(2) as ut3_develop.ut_test).disabled_flag).to_equal(0);
    ut.expect(treat(l_test1_suite.items(2) as ut3_develop.ut_test).disabled_reason).to_be_null;

    ut.expect(l_test1_suite.items(3).name).to_equal('test3');
    ut.expect(treat(l_test1_suite.items(3) as ut3_develop.ut_test).disabled_flag).to_equal(0);
    ut.expect(treat(l_test1_suite.items(3) as ut3_develop.ut_test).disabled_reason).to_be_null;
	
    ut.expect(l_test1_suite.items(4).name).to_equal('test4');
    ut.expect(treat(l_test1_suite.items(4) as ut3_develop.ut_test).disabled_flag).to_equal(1);	
    ut.expect(treat(l_test1_suite.items(4) as ut3_develop.ut_test).disabled_reason).to_equal('Test4 disabled from second context');

  end;

  procedure test_long_text_spec_chr is
    c_path varchar2(100) := sys_context('USERENV', 'CURRENT_USER')||'.test_package_4';
    l_objects_to_run ut3_develop.ut_suite_items;

    l_test0_suite ut3_develop.ut_logical_suite;
    l_test1_suite ut3_develop.ut_suite;
  begin
  --Act
    l_objects_to_run := ut3_develop.ut_suite_manager.configure_execution_by_path(ut3_develop.ut_varchar2_list(c_path));

  --Assert
    ut.expect(l_objects_to_run.count).to_equal(1);
    l_test0_suite := treat(l_objects_to_run(1) as ut3_develop.ut_logical_suite);
    l_test1_suite :=  treat(l_test0_suite.items(1) as ut3_develop.ut_suite);

    ut.expect(l_test1_suite.items(1).name).to_equal('test1');
    ut.expect(treat(l_test1_suite.items(1) as ut3_develop.ut_test).disabled_flag).to_equal(1);
    ut.expect(treat(l_test1_suite.items(1) as ut3_develop.ut_test).disabled_reason).to_equal('$#?!%*&-/\^');
	
    ut.expect(l_test1_suite.items(2).name).to_equal('test2');
    ut.expect(treat(l_test1_suite.items(2) as ut3_develop.ut_test).disabled_flag).to_equal(1);
    ut.expect(treat(l_test1_suite.items(2) as ut3_develop.ut_test).disabled_reason).to_equal('verylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtext');


  end;

  procedure test_disable_suite_ctx_tst is
    c_path varchar2(100) := sys_context('USERENV', 'CURRENT_USER')||'.test_package_5';
    l_objects_to_run ut3_develop.ut_suite_items;

    l_test0_suite ut3_develop.ut_logical_suite;
    l_test1_suite ut3_develop.ut_suite;
  begin
  --Act
    l_objects_to_run := ut3_develop.ut_suite_manager.configure_execution_by_path(ut3_develop.ut_varchar2_list(c_path));

  --Assert
    ut.expect(l_objects_to_run.count).to_equal(1);
    l_test0_suite := treat(l_objects_to_run(1) as ut3_develop.ut_logical_suite);
    l_test1_suite :=  treat(l_test0_suite.items(1) as ut3_develop.ut_suite);

    ut.expect(l_test1_suite.items(1).name).to_equal('test1');
    ut.expect(treat(l_test1_suite.items(1) as ut3_develop.ut_test).disabled_flag).to_equal(1);
    ut.expect(treat(l_test1_suite.items(1) as ut3_develop.ut_test).disabled_reason).to_equal('Disable on suite level');
	
    ut.expect(l_test1_suite.items(2).name).to_equal('test2');
    ut.expect(treat(l_test1_suite.items(2) as ut3_develop.ut_test).disabled_flag).to_equal(1);
    ut.expect(treat(l_test1_suite.items(2) as ut3_develop.ut_test).disabled_reason).to_equal('Disable on suite level');

    ut.expect(l_test1_suite.items(3).name).to_equal('test3');
    ut.expect(treat(l_test1_suite.items(3) as ut3_develop.ut_test).disabled_flag).to_equal(1);
    ut.expect(treat(l_test1_suite.items(3) as ut3_develop.ut_test).disabled_reason).to_equal('Disable on suite level');
	
    ut.expect(l_test1_suite.items(4).name).to_equal('test4');
    ut.expect(treat(l_test1_suite.items(4) as ut3_develop.ut_test).disabled_flag).to_equal(1);	
    ut.expect(treat(l_test1_suite.items(4) as ut3_develop.ut_test).disabled_reason).to_equal('Disable on suite level');

  end;
  
  procedure test_disable_ctx_tst is
    c_path varchar2(100) := sys_context('USERENV', 'CURRENT_USER')||'.test_package_6';
    l_objects_to_run ut3_develop.ut_suite_items;

    l_test0_suite ut3_develop.ut_logical_suite;
    l_test1_suite ut3_develop.ut_suite;
  begin
  --Act
    l_objects_to_run := ut3_develop.ut_suite_manager.configure_execution_by_path(ut3_develop.ut_varchar2_list(c_path));

  --Assert
    ut.expect(l_objects_to_run.count).to_equal(1);
    l_test0_suite := treat(l_objects_to_run(1) as ut3_develop.ut_logical_suite);
    l_test1_suite :=  treat(l_test0_suite.items(1) as ut3_develop.ut_suite);

    ut.expect(l_test1_suite.items(1).name).to_equal('test1');
    ut.expect(treat(l_test1_suite.items(1) as ut3_develop.ut_test).disabled_flag).to_equal(1);
    ut.expect(treat(l_test1_suite.items(1) as ut3_develop.ut_test).disabled_reason).to_equal('Disable on 1st context level');
	
    ut.expect(l_test1_suite.items(2).name).to_equal('test2');
    ut.expect(treat(l_test1_suite.items(2) as ut3_develop.ut_test).disabled_flag).to_equal(1);
    ut.expect(treat(l_test1_suite.items(2) as ut3_develop.ut_test).disabled_reason).to_equal('Disable on 1st context level');

    ut.expect(l_test1_suite.items(3).name).to_equal('test3');
    ut.expect(treat(l_test1_suite.items(3) as ut3_develop.ut_test).disabled_flag).to_equal(1);
    ut.expect(treat(l_test1_suite.items(3) as ut3_develop.ut_test).disabled_reason).to_equal('Disable on 2nd context level');
	
    ut.expect(l_test1_suite.items(4).name).to_equal('test4');
    ut.expect(treat(l_test1_suite.items(4) as ut3_develop.ut_test).disabled_flag).to_equal(1);	
    ut.expect(treat(l_test1_suite.items(4) as ut3_develop.ut_test).disabled_reason).to_equal('Disable on 2nd context level');

  end;

end;
/
