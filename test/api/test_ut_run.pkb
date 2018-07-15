create or replace package body test_ut_run is

  procedure create_test_suite is
    pragma autonomous_transaction;
  begin
    execute immediate q'[
      create or replace package stateful_package as
        g_state varchar2(1) := 'A';
      end;
    ]';
    execute immediate q'[
      create or replace package test_stateful as
        --%suite
        --%suitepath(test_state)

        --%test
        --%beforetest(acquire_state,recompile_in_background)
        procedure failing_stateful_test;

        procedure recompile_in_background;
        procedure acquire_state;

      end;
    ]';
    execute immediate q'{
    create or replace package body test_stateful as

      procedure failing_stateful_test is
      begin
        ut3.ut.expect(stateful_package.g_state).to_equal('abc');
      end;

      procedure recompile_in_background is
        l_job_name varchar2(30) := 'recreate_stateful_package';
        l_cnt      integer      := 1;
        pragma autonomous_transaction;
      begin
        dbms_scheduler.create_job(
          job_name      =>  l_job_name,
          job_type      =>  'PLSQL_BLOCK',
          job_action    =>  q'/
            begin
              execute immediate q'[
                create or replace package stateful_package as
                  g_state varchar2(3) := 'abc';
                end;]';
            end;/',
          start_date    =>  localtimestamp,
          enabled       =>  TRUE,
          auto_drop     =>  TRUE,
          comments      =>  'one-time job'
        );
        dbms_lock.sleep(1);
        while l_cnt > 0 loop
          select count(1) into l_cnt
            from dba_scheduler_running_jobs srj
           where srj.job_name = l_job_name;
        end loop;
      end;
      procedure acquire_state is
      begin
        dbms_output.put_line('stateful_package.g_state='||stateful_package.g_state);
      end;
    end;
    }';

  end;

  procedure raise_in_invalid_state is
    l_results   ut3.ut_varchar2_list;
    l_expected  varchar2(32767);
  begin
    --Arrange
    l_expected := 'test_state
  test_stateful
    failing_stateful_test [% sec] (FAILED - 1)%
Failures:%
  1) failing_stateful_test
      ORA-04061: existing state of package "UT3_TESTER.STATEFUL_PACKAGE" has been invalidated
      ORA-04065: not executed, altered or dropped package "UT3_TESTER.STATEFUL_PACKAGE"
      ORA-06508: PL/SQL: could not find program unit being called: "UT3_TESTER.STATEFUL_PACKAGE"
      ORA-06512: at "UT3_TESTER.TEST_STATEFUL", line 5%
      ORA-06512: at line 6%
1 tests, 0 failed, 1 errored, 0 disabled, 0 warning(s)%';

    --Act
    select * bulk collect into l_results from table(ut3.ut.run('test_stateful'));
  
    --Assert
    ut.expect( ut3.ut_utils.table_to_clob(l_results) ).to_be_like( l_expected );
    ut.fail('Expected exception but nothing was raised');
  exception
    when others then
      ut.expect( ut3.ut_utils.table_to_clob(l_results) ).to_be_like( l_expected );
      ut.expect(sqlcode).to_equal(-4068);
  end;

  procedure drop_test_suite is
    pragma autonomous_transaction;
  begin
    execute immediate 'drop package stateful_package';
    execute immediate 'drop package test_stateful';
  end;

  procedure run_in_invalid_state is
    l_results   ut3.ut_varchar2_list;
    l_actual    clob;
    l_expected  varchar2(32767);
  begin
    select *
      bulk collect into l_results
    from table(ut3.ut.run('failing_invalid_spec'));
    
    l_actual := ut3.ut_utils.table_to_clob(l_results);
    ut.expect(l_actual).to_be_like('%Call params for % are not valid: package does not exist or is invalid: %FAILING_INVALID_SPEC%'); 
    
  end;

  procedure compile_invalid_package is
    ex_compilation_error exception;
    pragma exception_init(ex_compilation_error,-24344);
    pragma autonomous_transaction;
  begin
    begin
      execute immediate q'[create or replace package failing_invalid_spec as
  --%suite
  gv_glob_val non_existing_table.id%type := 0;

  --%test
  procedure test1;
end;]';
    exception when ex_compilation_error then null;
    end;
    begin
      execute immediate q'[create or replace package body failing_invalid_spec as
  procedure test1 is begin ut.expect(1).to_equal(1); end;
end;]';
    exception when ex_compilation_error then null;
    end;
  end;
  procedure drop_invalid_package is
    pragma autonomous_transaction;
  begin
    execute immediate 'drop package failing_invalid_spec';
  end;

  procedure run_and_revalidate_specs is
    l_results   ut3.ut_varchar2_list;
    l_actual    clob;
    l_is_invalid number;
  begin
    execute immediate q'[select count(1) from all_objects o where o.owner = :object_owner and o.object_type = 'PACKAGE'
            and o.status = 'INVALID' and o.object_name= :object_name]' into l_is_invalid
            using user,'INVALID_PCKAG_THAT_REVALIDATES';

    select *
      bulk collect into l_results
    from table(ut3.ut.run('invalid_pckag_that_revalidates'));
    
    l_actual := ut3.ut_utils.table_to_clob(l_results);
    ut.expect(1).to_equal(l_is_invalid);
    ut.expect(l_actual).to_be_like('%invalid_pckag_that_revalidates%invalidspecs [% sec]%
%Finished in % seconds%
%1 tests, 0 failed, 0 errored, 0 disabled, 0 warning(s)%'); 
  
  end;

  procedure generate_invalid_spec is
    ex_compilation_error exception;
    pragma exception_init(ex_compilation_error,-24344);
    pragma autonomous_transaction;
  begin
  
    execute immediate q'[create or replace package parent_specs as
  c_test constant varchar2(1) := 'Y';
end;]';
  
    execute immediate q'[create or replace package invalid_pckag_that_revalidates as
  --%suite
  g_var varchar2(1) := parent_specs.c_test;

  --%test(invalidspecs)
  procedure test1;
end;]';

    execute immediate q'[create or replace package body invalid_pckag_that_revalidates as
  procedure test1 is begin ut.expect('Y').to_equal(g_var); end;
end;]';
    
    -- That should invalidate test package and we can then revers
    execute immediate q'[create or replace package parent_specs as
  c_test_error constant varchar2(1) := 'Y';
end;]';
 
    execute immediate q'[create or replace package parent_specs as
  c_test constant varchar2(1) := 'Y';
end;]';     

  end;
  procedure drop_test_package is
    pragma autonomous_transaction;
  begin
    execute immediate 'drop package invalid_pckag_that_revalidates';
    execute immediate 'drop package parent_specs';
  end;  

  procedure create_test_csl_packages is
    pragma autonomous_transaction;
  begin
    execute immediate q'[
      create or replace package test_csl_names1 as
        --%suite
        --%suitepath(test_csl_names)

        --%test
        procedure one_is_one;
        
        --%test
        procedure two_is_two;

      end;
    ]';
    
    execute immediate q'{
    create or replace package body test_csl_names1 as

      procedure one_is_one is
      begin
        ut3.ut.expect(1).to_equal(1);
      end;
      
      procedure two_is_two is
      begin
        ut3.ut.expect(2).to_equal(2);
      end;
      
    end;
    }';

    execute immediate q'[
      create or replace package test_csl_names2 as
        --%suite
        --%suitepath(test_csl_names)

        --%test
        procedure one_is_one;
        
        --%test
        procedure two_is_two;

      end;
    ]';
    
    execute immediate q'{
    create or replace package body test_csl_names2 as

      procedure one_is_one is
      begin
        ut3.ut.expect(1).to_equal(1);
      end;
      
      procedure two_is_two is
      begin
        ut3.ut.expect(2).to_equal(2);
      end;
      
    end;
    }';
    
  end;
  
  procedure drop_test_csl_packages is
    pragma autonomous_transaction;
  begin
    execute immediate 'drop package test_csl_names1';
    execute immediate 'drop package test_csl_names2';
  end;

  procedure pass_varchar2_name_list is
    l_results   ut3.ut_varchar2_list;
    l_actual    clob;
  begin
    select *
      bulk collect into l_results
    from table(ut3.ut.run(ut3.ut_varchar2_list('test_csl_names1','test_csl_names2')));
    
    l_actual := ut3.ut_utils.table_to_clob(l_results);
    ut.expect(l_actual).to_be_like('%Finished in % seconds
%4 tests, 0 failed, 0 errored, 0 disabled, 0 warning(s)%'); 
  end;
 
  procedure pass_varchar2_name is
    l_results   ut3.ut_varchar2_list;
    l_actual    clob;
  begin
    select *
      bulk collect into l_results
    from table(ut3.ut.run('test_csl_names1'));
    
    l_actual := ut3.ut_utils.table_to_clob(l_results);
    ut.expect(l_actual).to_be_like('%Finished in % seconds
%2 tests, 0 failed, 0 errored, 0 disabled, 0 warning(s)%'); 
  end;
  
  procedure pass_varchar2_suite_csl is
    l_results   ut3.ut_varchar2_list;
    l_actual    clob;
  begin
    select *
      bulk collect into l_results
    from table(ut3.ut.run('test_csl_names1,test_csl_names2'));
    
    l_actual := ut3.ut_utils.table_to_clob(l_results);
    ut.expect(l_actual).to_be_like('%Finished in % seconds
%4 tests, 0 failed, 0 errored, 0 disabled, 0 warning(s)%'); 
  end;

  procedure pass_varchar2_test_csl is
    l_results   ut3.ut_varchar2_list;
    l_actual    clob;
  begin
    select *
      bulk collect into l_results
    from table(ut3.ut.run('test_csl_names1.one_is_one,test_csl_names2.one_is_one'));
    
    l_actual := ut3.ut_utils.table_to_clob(l_results);
    ut.expect(l_actual).to_be_like('%Finished in % seconds
%2 tests, 0 failed, 0 errored, 0 disabled, 0 warning(s)%'); 
  end;

  procedure pass_varch_test_csl_spc is
    l_results   ut3.ut_varchar2_list;
    l_actual    clob;
  begin
    select *
      bulk collect into l_results
    from table(ut3.ut.run('test_csl_names1.one_is_one, test_csl_names2.one_is_one'));
    
    l_actual := ut3.ut_utils.table_to_clob(l_results);
    ut.expect(l_actual).to_be_like('%Finished in % seconds
%2 tests, 0 failed, 0 errored, 0 disabled, 0 warning(s)%'); 
  end;
  
  procedure pass_csl_with_srcfile is
    l_results   ut3.ut_varchar2_list;
    l_actual    clob;
  begin
  
    select *
      bulk collect into l_results
      from table(
        ut3.ut.run(
          a_path => 'test_csl_names1.one_is_one,test_csl_names2.one_is_one',
          a_source_files => ut3.ut_varchar2_list('ut3.ut'),
          a_test_files => ut3.ut_varchar2_list('ut3_tester.test_csl_names2')
        )
      );
    
    l_actual := ut3.ut_utils.table_to_clob(l_results);
    ut.expect(l_actual).to_be_like('%Finished in % seconds
%2 tests, 0 failed, 0 errored, 0 disabled, 0 warning(s)%'); 
  end;

  procedure pass_singlevar_with_proc is
    l_output_data       dbms_output.chararr;
    l_num_lines         integer := 100000;
    l_packages_executed integer := 0;
  begin
    --act
    ut3.ut.run('test_csl_names1');
    dbms_output.get_lines( l_output_data, l_num_lines);

    for i in 1 .. l_num_lines loop
      if  l_output_data(i) like '%test_csl_names1%' then
        l_packages_executed := l_packages_executed + 1;
      end if;
    end loop;
    ut.expect(l_packages_executed ).to_equal(1);
  end;
  
  procedure pass_vlist_with_proc is
    l_output_data       dbms_output.chararr;
    l_num_lines         integer := 100000;
    l_packages_executed integer := 0;
  begin
    --act
    ut3.ut.run(ut3.ut_varchar2_list('test_csl_names1','test_csl_names2'));
    dbms_output.get_lines( l_output_data, l_num_lines);

    for i in 1 .. l_num_lines loop
      if  l_output_data(i) like '%test_csl_names1%'
       or l_output_data(i) like '%test_csl_names2%' then
         l_packages_executed := l_packages_executed + 1;
      end if;
    end loop;
    ut.expect(l_packages_executed ).to_equal(2);
  end;  
  
  procedure pass_csl_with_proc is
    l_output_data       dbms_output.chararr;
    l_num_lines         integer := 100000;
    l_packages_executed integer := 0;
  begin
    --act
    ut3.ut.run('test_csl_names1,test_csl_names2');
    dbms_output.get_lines( l_output_data, l_num_lines);

    for i in 1 .. l_num_lines loop
      if  l_output_data(i) like '%test_csl_names1%'
       or l_output_data(i) like '%test_csl_names2%' then
         l_packages_executed := l_packages_executed + 1;
      end if;
    end loop;
    ut.expect(l_packages_executed ).to_equal(2);
  end;  
    
  procedure pass_csl_src_proc is
    l_output_data       dbms_output.chararr;
    l_num_lines         integer := 100000;
    l_packages_executed integer := 0;
  begin
    --act
    ut3.ut.run(a_path => 'test_csl_names1,test_csl_names2',
               a_source_files => ut3.ut_varchar2_list('ut3.ut'),
               a_test_files => ut3.ut_varchar2_list('ut3_tester.test_csl_names2'));
    dbms_output.get_lines( l_output_data, l_num_lines);

    for i in 1 .. l_num_lines loop
      if  l_output_data(i) like '%test_csl_names1%'
       or l_output_data(i) like '%test_csl_names2%' then
         l_packages_executed := l_packages_executed + 1;
      end if;
    end loop;
    ut.expect(l_packages_executed ).to_equal(2);
  end;
  
end;
/
