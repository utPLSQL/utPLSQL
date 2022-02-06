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

  --%test(Test2 from test package 4)
  --%disabled(verylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtext) 
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
    l_test_results  ut3_develop.ut_varchar2_list;
    l_expected_message varchar2(32767);
    l_actual_message   varchar2(32767);	
  begin
  --Act
  
    select * bulk collect into l_test_results from table(ut3_develop.ut.run((sys_context('USERENV', 'CURRENT_USER')||'.test_package_1')));

    l_actual_message := ut3_develop.ut_utils.table_to_clob(l_test_results);  
 
    l_expected_message := q'[%tests
%disable_test_suite_level
%First context
%Test1 from test package 1 [0 sec] (DISABLED - Tests are disabled on suite level)
%Test2 from test package 1 [0 sec] (DISABLED - Tests are disabled on suite level)
%Second context
%Test3 from test package 1 [0 sec] (DISABLED - Tests are disabled on suite level)
%Test4 from test package 1 [0 sec] (DISABLED - Tests are disabled on suite level)%]';
  ut.expect(l_actual_message).to_be_like(l_expected_message);

  end;

  procedure test_dis_on_1st_ctx_level is
    l_test_results  ut3_develop.ut_varchar2_list;
    l_expected_message varchar2(32767);
    l_actual_message   varchar2(32767);	
  begin
  --Act
  
    select * bulk collect into l_test_results from table(ut3_develop.ut.run((sys_context('USERENV', 'CURRENT_USER')||'.test_package_2')));

    l_actual_message := ut3_develop.ut_utils.table_to_clob(l_test_results);  
 
    l_expected_message := q'[%tests
%Disable on context level
%First context
%Test1 from test package 2 [0 sec] (DISABLED - Tests and disabled on first context level)
%Test2 from test package 2 [0 sec] (DISABLED - Tests and disabled on first context level)
%Second context
%Test3 from test package 2 [% sec]
%Test4 from test package 3 [% sec]%]';

  ut.expect(l_actual_message).to_be_like(l_expected_message);

  end;

  procedure test_disable_tests_level is
    l_test_results  ut3_develop.ut_varchar2_list;
    l_expected_message varchar2(32767);
    l_actual_message   varchar2(32767);	
  begin
  --Act
  
    select * bulk collect into l_test_results from table(ut3_develop.ut.run((sys_context('USERENV', 'CURRENT_USER')||'.test_package_3')));

    l_actual_message := ut3_develop.ut_utils.table_to_clob(l_test_results);  
 
    l_expected_message := q'[%tests
%Disable tests on test level
%First context
%Test1 from test package 3 [0 sec] (DISABLED - Test1 disabled from first context)
%Test2 from test package 3 [% sec]
%Second context
%Test3 from test package 3 [% sec]
%Test4 from test package 3 [0 sec] (DISABLED - Test4 disabled from second context)%]';

  ut.expect(l_actual_message).to_be_like(l_expected_message);


  end;

  procedure test_long_text_spec_chr is
    l_test_results  ut3_develop.ut_varchar2_list;
    l_expected_message varchar2(32767);
    l_actual_message   varchar2(32767);	
  begin
  --Act
  
    select * bulk collect into l_test_results from table(ut3_develop.ut.run((sys_context('USERENV', 'CURRENT_USER')||'.test_package_4')));

    l_actual_message := ut3_develop.ut_utils.table_to_clob(l_test_results);  
 
    l_expected_message := q'[%tests
%Disable reason is very long or have special characters
%Test1 from test package 4 [0 sec] (DISABLED - $#?!%*&-/\^)
%Test2 from test package 4 [0 sec] (DISABLED - verylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtext)%]';

  ut.expect(l_actual_message).to_be_like(l_expected_message);
  end;

  procedure test_disable_suite_ctx_tst is
    l_test_results  ut3_develop.ut_varchar2_list;
    l_expected_message varchar2(32767);
    l_actual_message   varchar2(32767);	
  begin
  --Act
  
    select * bulk collect into l_test_results from table(ut3_develop.ut.run((sys_context('USERENV', 'CURRENT_USER')||'.test_package_5')));

    l_actual_message := ut3_develop.ut_utils.table_to_clob(l_test_results);  
 
    l_expected_message := q'[%tests
%Disable tests on suite level overriding rest
%First context
%Test1 from test package 3 [0 sec] (DISABLED - Disable on suite level)
%Test2 from test package 3 [0 sec] (DISABLED - Disable on suite level)
%Second context
%Test3 from test package 3 [0 sec] (DISABLED - Disable on suite level)
%Test4 from test package 3 [0 sec] (DISABLED - Disable on suite level)%]';

  ut.expect(l_actual_message).to_be_like(l_expected_message);


  end;
  
  procedure test_disable_ctx_tst is
    l_test_results  ut3_develop.ut_varchar2_list;
    l_expected_message varchar2(32767);
    l_actual_message   varchar2(32767);	
  begin
  --Act
  
    select * bulk collect into l_test_results from table(ut3_develop.ut.run((sys_context('USERENV', 'CURRENT_USER')||'.test_package_6')));

    l_actual_message := ut3_develop.ut_utils.table_to_clob(l_test_results);  
 
    l_expected_message := q'[%tests
%Disable tests on each of ctx level overriding rest
%First context
%Test1 from test package 3 [0 sec] (DISABLED - Disable on 1st context level)
%Test2 from test package 3 [0 sec] (DISABLED - Disable on 1st context level)
%Second context
%Test3 from test package 3 [0 sec] (DISABLED - Disable on 2nd context level)
%Test4 from test package 3 [0 sec] (DISABLED - Disable on 2nd context level)%]';

  ut.expect(l_actual_message).to_be_like(l_expected_message);

  end;

end;
/
