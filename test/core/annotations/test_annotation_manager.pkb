create or replace package body test_annotation_manager is

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
  end;

  procedure recompile_dummy_test_package is
    pragma autonomous_transaction;
  begin
    execute immediate q'[alter package dummy_test_package compile]';
  end;

  procedure cleanup_annotation_cache is
    pragma autonomous_transaction;
  begin
     delete from ut3.ut_annotation_cache_info
      where object_owner = user and object_type = 'PACKAGE' and object_name in ('DUMMY_PACKAGE','DUMMY_TEST_PACKAGE');
    commit;
  end;


  procedure add_new_package is
    l_actual_cache_id integer;
    l_actual integer;
    l_start_date date;
  begin
    --Act
    l_start_date := sysdate;
    ut3.ut_annotation_manager.rebuild_annotation_cache(user,'PACKAGE');
    --Assert
    select max(cache_id)
      into l_actual_cache_id
      from ut3.ut_annotation_cache_info
     where object_owner = user and object_type = 'PACKAGE' and object_name = 'DUMMY_PACKAGE'
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
    ut3.ut_annotation_manager.rebuild_annotation_cache(user,'PACKAGE');
    recompile_dummy_package();
    l_start_date := sysdate;
    dbms_lock.sleep(1);
    --Act
    ut3.ut_annotation_manager.rebuild_annotation_cache(user,'PACKAGE');
    --Assert
    select max(cache_id)
      into l_actual_cache_id
      from ut3.ut_annotation_cache_info
     where object_owner = user and object_type = 'PACKAGE' and object_name = 'DUMMY_PACKAGE'
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
    ut3.ut_annotation_manager.rebuild_annotation_cache(user,'PACKAGE');
    --Assert
    select max(cache_id)
      into l_actual_cache_id
      from ut3.ut_annotation_cache_info
     where object_owner = user and object_type = 'PACKAGE' and object_name = 'DUMMY_TEST_PACKAGE'
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
    ut3.ut_annotation_manager.rebuild_annotation_cache(user,'PACKAGE');
    l_start_date := sysdate;
    modify_dummy_test_package();
    --Act
    ut3.ut_annotation_manager.rebuild_annotation_cache(user,'PACKAGE');
    --Assert
    select max(cache_id)
      into l_actual_cache_id
      from ut3.ut_annotation_cache_info
     where object_owner = user and object_type = 'PACKAGE' and object_name = 'DUMMY_TEST_PACKAGE'
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
    --Arrange
    ut3.ut_annotation_manager.rebuild_annotation_cache(user,'PACKAGE');
    l_start_date := sysdate;
    drop_dummy_test_package();
    --Act
    ut3.ut_annotation_manager.rebuild_annotation_cache(user,'PACKAGE');
    --Assert
    select max(cache_id)
      into l_actual_cache_id
      from ut3.ut_annotation_cache_info
     where object_owner = user and object_type = 'PACKAGE' and object_name = 'DUMMY_TEST_PACKAGE'
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

  procedure no_data_for_dropped_object is
    l_actual sys_refcursor;
  begin
    --Arrange
    ut3.ut_annotation_manager.rebuild_annotation_cache(user,'PACKAGE');
    drop_dummy_test_package();
    --Act
    open l_actual for
      select * from table(ut3.ut_annotation_manager.get_annotated_objects(user,'PACKAGE'))
       where object_name = 'DUMMY_TEST_PACKAGE';
    --Assert
    ut.expect(l_actual).to_be_empty();
  end;

end test_annotation_manager;
/
