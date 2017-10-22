create or replace package body test_annotation_cache_manager is

  procedure setup_cache is
    pragma autonomous_transaction;
  begin
    execute immediate q'[create or replace package dummy_test_package as
        --%suite(dummy_test_suite)
        --%rollback(manual)

        --%test(dummy_test)
        --%beforetest(some_procedure)
        procedure some_dummy_test_procedure;
      end;]';
    execute immediate q'[create or replace procedure dummy_test_procedure as
        --%some_annotation(some_text)
        --%rollback(manual)
      begin
        null;
      end;]';
    execute immediate q'[create or replace procedure ut3.dummy_test_procedure as
        --%some_annotation(some_text)
        --%rollback(manual)
      begin
        null;
      end;]';
    ut3.ut_annotation_manager.rebuild_annotation_cache(user,'PACKAGE');
    ut3.ut_annotation_manager.rebuild_annotation_cache(user,'PROCEDURE');
    ut3.ut_annotation_manager.rebuild_annotation_cache('UT3','PROCEDURE');
  end;

  procedure cleanup_cache is
    pragma autonomous_transaction;
  begin
    delete from ut3.ut_annotation_cache_info
     where object_type = 'PROCEDURE' and object_owner in ('UT3',user)
        or object_type = 'PACKAGE' and object_owner = user and object_name = 'DUMMY_TEST_PACKAGE';
    execute immediate q'[drop package dummy_test_package]';
    execute immediate q'[drop procedure dummy_test_procedure]';
    execute immediate q'[drop procedure ut3.dummy_test_procedure]';
  end;

  procedure test_purge_schema_type is
    l_actual sys_refcursor;
  begin

    open l_actual for
      select * from ut3.ut_annotation_cache_info
       where object_owner = user and object_type = 'PROCEDURE';
    ut.expect(l_actual).not_to_be_empty();

    --Act
    ut3.ut_annotation_cache_manager.purge_cache(user,'PROCEDURE');

    --Assert
    open l_actual for
      select * from ut3.ut_annotation_cache_info
       where object_owner = user and object_type = 'PROCEDURE';
    --Cache purged for object owner/type
    ut.expect(l_actual).to_be_empty();
    open l_actual for
      select * from ut3.ut_annotation_cache_info
       where object_owner = user and object_type = 'PACKAGE';
    --Cache not purged for other types
    ut.expect(l_actual).not_to_be_empty();
    open l_actual for
      select * from ut3.ut_annotation_cache_info
       where object_owner != user and object_type = 'PROCEDURE';
    --Cache not purged for other owners
    ut.expect(l_actual).not_to_be_empty();

  end;

end test_annotation_cache_manager;
/
