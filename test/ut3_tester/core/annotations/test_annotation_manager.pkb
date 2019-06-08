create or replace package body test_annotation_manager is

  procedure disable_ddl_trigger is
    pragma autonomous_transaction;
  begin
    execute immediate 'alter trigger ut3.ut_trigger_annotation_parsing disable';
    execute immediate 'begin ut3.ut_trigger_check.is_alive(); end;';
  end;

  procedure enable_ddl_trigger is
    pragma autonomous_transaction;
  begin
    execute immediate 'alter trigger ut3.ut_trigger_annotation_parsing enable';
  end;

  procedure create_dummy_package is
    pragma autonomous_transaction;
  begin
    execute immediate q'[create or replace package dummy_package as
        procedure some_dummy_procedure;
      end;]';
  end;

  procedure drop_dummy_package is
    pragma autonomous_transaction;
  begin
    execute immediate q'[drop package dummy_package]';
  end;

  procedure recompile_dummy_package is
    pragma autonomous_transaction;
  begin
    execute immediate q'[alter package dummy_package compile]';
  end;

  procedure create_dummy_test_package is
    pragma autonomous_transaction;
  begin
    execute immediate q'[create or replace package dummy_test_package as
        --%suite(dummy_test_suite)
        --%rollback(manual)

        --%test(dummy_test)
        --%beforetest(some_procedure)
        procedure some_dummy_test_procedure;
      end;]';
    execute immediate q'[grant execute on dummy_test_package to public]';
  end;

  procedure modify_dummy_test_package is
    pragma autonomous_transaction;
  begin
    execute immediate q'[create or replace package dummy_test_package as
        --%suite(dummy_test_suite)

        --%test(dummy_test)
        procedure some_dummy_test_procedure;
      end;]';
  end;

  procedure drop_dummy_test_package is
    pragma autonomous_transaction;
  begin
    execute immediate q'[drop package dummy_test_package]';
  exception
    when others then
      null;
  end;

  procedure recompile_dummy_test_package is
    pragma autonomous_transaction;
  begin
    execute immediate q'[alter package dummy_test_package compile]';
  end;

  procedure create_parse_proc_as_ut3$user# is
  begin
    ut3_tester_helper.main_helper.create_parse_proc_as_ut3$user#();
  end;

  procedure parse_dummy_test_as_ut3$user# is
  begin
    ut3_tester_helper.main_helper.parse_dummy_test_as_ut3$user#();
  end;

  procedure drop_parse_proc_as_ut3$user# is
  begin
    ut3_tester_helper.main_helper.drop_parse_proc_as_ut3$user#();
  end;

  procedure cleanup_annotation_cache is
  begin
    ut3_tester_helper.main_helper.cleanup_annotation_cache();
  end;


  procedure add_new_package is
    l_actual_cache_id integer;
    l_actual integer;
    l_start_date date;
  begin
    --Act
    l_start_date := sysdate;
    ut3.ut_annotation_manager.rebuild_annotation_cache(sys_context('USERENV', 'CURRENT_USER'),'PACKAGE');
    --Assert
    select max(cache_id)
      into l_actual_cache_id
      from ut3.ut_annotation_cache_info
     where object_owner = sys_context('USERENV', 'CURRENT_USER') and object_type = 'PACKAGE' and object_name = 'DUMMY_PACKAGE'
       and parse_time >= l_start_date;

    ut.expect(l_actual_cache_id).to_be_not_null;

    select count(1)
      into l_actual
      from ut3.ut_annotation_cache
     where cache_id = l_actual_cache_id;

    ut.expect(l_actual).to_equal(0);

  end;

  procedure update_modified_package is
    l_actual_cache_id integer;
    l_actual integer;
    l_start_date date;
  begin
    --Arrange
    l_start_date := sysdate;
    ut3.ut_annotation_manager.rebuild_annotation_cache(sys_context('USERENV', 'CURRENT_USER'),'PACKAGE');
    recompile_dummy_package();
    l_start_date := sysdate;
    $if dbms_db_version.version >= 18 $then
      dbms_session.sleep(1);
    $else
      dbms_lock.sleep(1);
    $end
    --Act
    ut3.ut_annotation_manager.rebuild_annotation_cache(sys_context('USERENV', 'CURRENT_USER'),'PACKAGE');
    --Assert
    select max(cache_id)
      into l_actual_cache_id
      from ut3.ut_annotation_cache_info
     where object_owner = sys_context('USERENV', 'CURRENT_USER') and object_type = 'PACKAGE' and object_name = 'DUMMY_PACKAGE'
       and parse_time >= l_start_date;

    ut.expect(l_actual_cache_id).to_be_not_null;

    select count(1)
      into l_actual
      from ut3.ut_annotation_cache
     where cache_id = l_actual_cache_id;

    ut.expect(l_actual).to_equal(0);
  end;


  procedure add_new_test_package is
    l_actual_cache_id integer;
    l_actual   sys_refcursor;
    l_expected sys_refcursor;
    l_start_date date;
  begin
    --Arrange
    l_start_date := sysdate;
    --Act
    ut3.ut_annotation_manager.rebuild_annotation_cache(sys_context('USERENV', 'CURRENT_USER'),'PACKAGE');
    --Assert
    select max(cache_id)
      into l_actual_cache_id
      from ut3.ut_annotation_cache_info
     where object_owner = sys_context('USERENV', 'CURRENT_USER') and object_type = 'PACKAGE' and object_name = 'DUMMY_TEST_PACKAGE'
       and parse_time >= l_start_date;

    ut.expect(l_actual_cache_id).to_be_not_null;

    open l_actual for
      select annotation_position, annotation_name, annotation_text, subobject_name
        from ut3.ut_annotation_cache where cache_id = l_actual_cache_id
       order by annotation_position;

    open l_expected for
      select 2 as annotation_position, 'suite' as annotation_name,
            'dummy_test_suite' as annotation_text, '' as subobject_name
        from dual union all
      select 3, 'rollback' , 'manual', '' as subobject_name
        from dual union all
      select 5, 'test' , 'dummy_test', 'some_dummy_test_procedure' as subobject_name
        from dual union all
      select 6, 'beforetest' , 'some_procedure', 'some_dummy_test_procedure' as subobject_name
        from dual;

    ut.expect(l_actual).to_equal(l_expected);
  end;


  procedure update_modified_test_package is
    l_actual_cache_id integer;
    l_actual   sys_refcursor;
    l_expected sys_refcursor;
    l_start_date date;
  begin
    --Arrange
    ut3.ut_annotation_manager.rebuild_annotation_cache(sys_context('USERENV', 'CURRENT_USER'),'PACKAGE');
    l_start_date := sysdate;
    modify_dummy_test_package();
    --Act
    ut3.ut_annotation_manager.rebuild_annotation_cache(sys_context('USERENV', 'CURRENT_USER'),'PACKAGE');
    --Assert
    select max(cache_id)
      into l_actual_cache_id
      from ut3.ut_annotation_cache_info
     where object_owner = sys_context('USERENV', 'CURRENT_USER') and object_type = 'PACKAGE' and object_name = 'DUMMY_TEST_PACKAGE'
       and parse_time >= l_start_date;

    ut.expect(l_actual_cache_id).to_be_not_null;

    open l_actual for
      select annotation_position, annotation_name, annotation_text, subobject_name
        from ut3.ut_annotation_cache where cache_id = l_actual_cache_id
       order by annotation_position;

    open l_expected for
      select 2 as annotation_position, 'suite' as annotation_name,
            'dummy_test_suite' as annotation_text, to_char(null) as subobject_name
        from dual union all
      select 4, 'test' , 'dummy_test', 'some_dummy_test_procedure' as subobject_name
        from dual;

    ut.expect(l_actual).to_equal(l_expected);
  end;


  procedure keep_dropped_data_in_cache is
    l_actual_cache_id integer;
    l_actual   sys_refcursor;
    l_expected sys_refcursor;
    l_start_date date;
  begin
    parse_dummy_test_as_ut3$user#();
    l_start_date := sysdate;
    drop_dummy_test_package();
    --Act
    parse_dummy_test_as_ut3$user#();
    --Assert
    select max(cache_id)
      into l_actual_cache_id
      from ut3.ut_annotation_cache_info
     where object_owner = sys_context('USERENV', 'CURRENT_USER') and object_type = 'PACKAGE' and object_name = 'DUMMY_TEST_PACKAGE'
       and parse_time >= l_start_date;

    ut.expect(l_actual_cache_id).not_to_be_null();

    open l_actual for
      select annotation_position, annotation_name, annotation_text, subobject_name
        from ut3.ut_annotation_cache where cache_id = l_actual_cache_id
       order by annotation_position;

    open l_expected for
      select 2 as annotation_position, 'suite' as annotation_name, 'dummy_test_suite' as annotation_text, '' as subobject_name
        from dual union all
      select 3, 'rollback' , 'manual', '' as subobject_name
        from dual union all
      select 5, 'test' , 'dummy_test', 'some_dummy_test_procedure' as subobject_name
        from dual union all
      select 6, 'beforetest' , 'some_procedure', 'some_dummy_test_procedure' as subobject_name
        from dual;

    ut.expect(l_actual).to_equal(l_expected);
  end;

  procedure no_data_for_dropped_object is
    l_actual sys_refcursor;
  begin
    --Arrange
    ut3.ut_annotation_manager.rebuild_annotation_cache(sys_context('USERENV', 'CURRENT_USER'),'PACKAGE');
    drop_dummy_test_package();
    --Act
    open l_actual for
      select * from table(ut3.ut_annotation_manager.get_annotated_objects(sys_context('USERENV', 'CURRENT_USER'),'PACKAGE'))
       where object_name = 'DUMMY_TEST_PACKAGE';
    --Assert
    ut.expect(l_actual).to_be_empty();
  end;

  procedure cleanup_dropped_data_in_cache is
    l_cache_count integer;
    l_actual   sys_refcursor;
    l_expected sys_refcursor;
    l_start_date date;
  begin
    --Arrange
    ut3.ut_annotation_manager.rebuild_annotation_cache(sys_context('USERENV', 'CURRENT_USER'),'PACKAGE');
    l_start_date := sysdate;
    drop_dummy_test_package();
    --Act
    ut3.ut_annotation_manager.rebuild_annotation_cache(sys_context('USERENV', 'CURRENT_USER'),'PACKAGE');
    --Assert
    select count(1)
      into l_cache_count
      from ut3.ut_annotation_cache_info
     where object_owner = sys_context('USERENV', 'CURRENT_USER')
       and object_type = 'PACKAGE'
       and object_name = 'DUMMY_TEST_PACKAGE';

    ut.expect(l_cache_count).to_equal(0);

  end;

end test_annotation_manager;
/
