create or replace package body test_annotation_cache is

  procedure cache_populated_for_packages(a_packages ut_varchar2_rows) is
    l_actual_cache_info   sys_refcursor;
    l_expected_cache_info sys_refcursor;
  begin
    open l_actual_cache_info for
      select *
        from ut3.ut_annotation_cache_info
        where object_owner = 'UT3_CACHE_TEST_OWNER';
    open l_expected_cache_info for
      select 'UT3_CACHE_TEST_OWNER' as object_owner, upper( column_value ) as object_name, 'Y' as is_annotated
        from table (a_packages) x;
    ut.expect( l_actual_cache_info ).to_equal( l_expected_cache_info ).exclude( 'CACHE_ID,PARSE_TIME,OBJECT_TYPE' ).JOIN_BY('OBJECT_NAME');
  end;

  procedure can_run_one_package(a_user varchar2) is
    l_actual       clob;
    l_current_time date := sysdate;
    pragma autonomous_transaction;
  begin
    --Act
    l_actual := annotation_cache_helper.run_tests_as( a_user );

    --Assert - only granted_test_suite is invoked
    ut.expect( l_actual ).to_be_like( 'granted_test_suite%2 tests, 0 failed%' );
    rollback;
  end;

  procedure can_run_new_package(a_user varchar2) is
    l_actual       clob;
    l_current_time date := sysdate;
    pragma autonomous_transaction;
  begin
    --Arrange
    l_actual := annotation_cache_helper.run_tests_as( a_user );
    annotation_cache_helper.add_new_suite( );
    --Act
    l_actual := annotation_cache_helper.run_tests_as( a_user );
    --Assert -Both granted_test_suite and new_suite are invoked
    ut.expect( l_actual ).to_be_like( 'granted_test_suite%new_suite%4 tests, 0 failed%' );
    rollback;
  end ;

  procedure cant_run_revoked_package(a_user varchar2) is
    l_actual       clob;
    l_current_time date := sysdate;
    pragma autonomous_transaction;
  begin
    --Arrange
    l_actual := annotation_cache_helper.run_tests_as( a_user );
    annotation_cache_helper.add_new_suite( );
    annotation_cache_helper.revoke_granted_suite( );

    --Act
    l_actual := annotation_cache_helper.run_tests_as( a_user );
    --Assert -Only  new_suite gets invoked
    ut.expect( l_actual ).to_be_like( 'new_suite%2 tests, 0 failed, 0 errored, 0 disabled, 0 warning(s)%' );
    ut.expect( l_actual ).not_to_be_like( '%granted_test_suite%' );
    rollback;
  end;

  procedure cant_run_dropped_package(a_user varchar2) is
    l_actual       clob;
    l_current_time date := sysdate;
    pragma autonomous_transaction;
  begin
    --Arrange
    l_actual := annotation_cache_helper.run_tests_as( a_user );
    annotation_cache_helper.add_new_suite( );
    l_actual := annotation_cache_helper.run_tests_as( a_user );
    annotation_cache_helper.revoke_granted_suite( );
    annotation_cache_helper.cleanup_new_suite( );

    --Act
    l_actual := annotation_cache_helper.run_tests_as( a_user );
    --Assert - no test suites are invoked
    ut.expect( l_actual ).to_be_like( '%0 tests, 0 failed, 0 errored, 0 disabled, 0 warning(s)%' );
    ut.expect( l_actual ).not_to_be_like( '%new_suite%' );
    ut.expect( l_actual ).not_to_be_like( '%granted_test_suite%' );
    rollback;
  end;

  procedure can_run_all_packages(a_user varchar2) is
    l_actual       clob;
    l_current_time date := sysdate;
    pragma autonomous_transaction;
  begin
    --Act
    l_actual := annotation_cache_helper.run_tests_as( a_user );

    --Assert - only granted_test_suite is invoked
    ut.expect( l_actual ).to_be_like( 'granted_test_suite%not_granted_test_suite%4 tests, 0 failed%' );
    rollback;
  end;

  procedure can_run_all_new_packages(a_user varchar2) is
    l_actual       clob;
    l_current_time date := sysdate;
    pragma autonomous_transaction;
  begin
    --Arrange
    l_actual := annotation_cache_helper.run_tests_as( a_user );
    annotation_cache_helper.add_new_suite( );
    --Act
    l_actual := annotation_cache_helper.run_tests_as( a_user );

    --Assert - only granted_test_suite is invoked
    ut.expect( l_actual ).to_be_like( 'granted_test_suite%new_suite%not_granted_test_suite% tests, 0 failed%' );
    rollback;
  end;

  procedure can_run_revoked_packages(a_user varchar2) is
    l_actual       clob;
    l_current_time date := sysdate;
    pragma autonomous_transaction;
  begin
    --Arrange
    l_actual := annotation_cache_helper.run_tests_as( a_user );
    annotation_cache_helper.add_new_suite( );
    annotation_cache_helper.revoke_granted_suite( );
    --Act
    l_actual := annotation_cache_helper.run_tests_as( a_user );

    --Assert - only granted_test_suite is invoked
    ut.expect( l_actual ).to_be_like( 'granted_test_suite%new_suite%not_granted_test_suite% tests, 0 failed%' );
    rollback;
  end;

  procedure can_run_all_but_dropped(a_user varchar2) is
    l_actual       clob;
    l_current_time date := sysdate;
    pragma autonomous_transaction;
  begin
    --Arrange
    l_actual := annotation_cache_helper.run_tests_as( a_user );
    annotation_cache_helper.add_new_suite( );
    l_actual := annotation_cache_helper.run_tests_as( a_user );
    annotation_cache_helper.revoke_granted_suite( );
    annotation_cache_helper.cleanup_new_suite( );

    --Act
    l_actual := annotation_cache_helper.run_tests_as( a_user );
    --Assert - no test suites are invoked
    ut.expect( l_actual ).to_be_like( 'granted_test_suite%not_granted_test_suite%4 tests, 0 failed%' );
    ut.expect( l_actual ).not_to_be_like( '%new_suite%' );
    rollback;
  end;


  procedure user_can_run_one_package is
  begin
    can_run_one_package( 'ut3_no_extra_priv_user' );
    cache_populated_for_packages( ut_varchar2_rows( 'GRANTED_TEST_SUITE' ) );
  end;

  procedure user_can_run_new_package is
  begin
    can_run_new_package( 'ut3_no_extra_priv_user' );
    cache_populated_for_packages( ut_varchar2_rows( 'GRANTED_TEST_SUITE', 'NEW_SUITE' ) );
  end;

  procedure user_cant_run_revoked_package is
  begin
    cant_run_revoked_package( 'ut3_no_extra_priv_user' );
    cache_populated_for_packages( ut_varchar2_rows( 'GRANTED_TEST_SUITE', 'NEW_SUITE' ) );
  end;

  procedure user_cant_run_dropped_package is
  begin
    cant_run_dropped_package( 'ut3_no_extra_priv_user' );
    cache_populated_for_packages( ut_varchar2_rows( 'GRANTED_TEST_SUITE', 'NEW_SUITE' ) );
  end;

  procedure sel_cat_user_can_run_one is
  begin
    can_run_one_package( 'ut3_select_catalog_user' );
    cache_populated_for_packages( ut_varchar2_rows( 'GRANTED_TEST_SUITE' ) );
  end;

  procedure sel_cat_user_can_run_new is
  begin
    can_run_new_package( 'ut3_select_catalog_user' );
    cache_populated_for_packages( ut_varchar2_rows( 'GRANTED_TEST_SUITE', 'NEW_SUITE' ) );
  end;

  procedure sel_cat_user_cant_run_revoked is
  begin
    cant_run_revoked_package( 'ut3_select_catalog_user' );
    cache_populated_for_packages( ut_varchar2_rows( 'GRANTED_TEST_SUITE', 'NEW_SUITE' ) );
  end;

  procedure sel_cat_user_cant_run_dropped is
  begin
    cant_run_dropped_package( 'ut3_select_catalog_user' );
    cache_populated_for_packages( ut_varchar2_rows( 'GRANTED_TEST_SUITE', 'NEW_SUITE' ) );
  end;

  procedure sel_any_user_can_run_one is
  begin
    can_run_one_package( 'ut3_select_any_table_user' );
    cache_populated_for_packages( ut_varchar2_rows( 'GRANTED_TEST_SUITE' ) );
  end;

  procedure sel_any_user_can_run_new is
  begin
    can_run_new_package( 'ut3_select_any_table_user' );
    cache_populated_for_packages( ut_varchar2_rows( 'GRANTED_TEST_SUITE', 'NEW_SUITE' ) );
  end;

  procedure sel_any_user_cant_run_revoked is
  begin
    cant_run_revoked_package( 'ut3_select_any_table_user' );
    cache_populated_for_packages( ut_varchar2_rows( 'GRANTED_TEST_SUITE', 'NEW_SUITE' ) );
  end;

  procedure sel_any_user_cant_run_dropped is
  begin
    cant_run_dropped_package( 'ut3_select_any_table_user' );
    cache_populated_for_packages( ut_varchar2_rows( 'GRANTED_TEST_SUITE', 'NEW_SUITE' ) );
  end;

  procedure exe_any_user_can_run_all is
  begin
    can_run_all_packages( 'ut3_execute_any_proc_user' );
    cache_populated_for_packages( ut_varchar2_rows( 'GRANTED_TEST_SUITE', 'NOT_GRANTED_TEST_SUITE' ) );
  end;

  procedure exe_any_user_can_run_new is
  begin
    can_run_all_new_packages( 'ut3_execute_any_proc_user' );
    cache_populated_for_packages( ut_varchar2_rows( 'GRANTED_TEST_SUITE', 'NEW_SUITE', 'NOT_GRANTED_TEST_SUITE' ) );
  end;

  procedure exe_any_user_can_run_revoked is
  begin
    can_run_revoked_packages('ut3_execute_any_proc_user');
    cache_populated_for_packages( ut_varchar2_rows( 'GRANTED_TEST_SUITE', 'NEW_SUITE', 'NOT_GRANTED_TEST_SUITE' ) );
  end;

  procedure exe_any_user_cant_run_dropped is
  begin
    can_run_all_but_dropped('ut3_execute_any_proc_user');
    cache_populated_for_packages( ut_varchar2_rows( 'GRANTED_TEST_SUITE', 'NOT_GRANTED_TEST_SUITE' ) );
  end;

  procedure owner_user_can_run_all is
  begin
    can_run_all_packages( 'ut3_cache_test_owner' );
    cache_populated_for_packages( ut_varchar2_rows( 'GRANTED_TEST_SUITE', 'NOT_GRANTED_TEST_SUITE' ) );
  end;


  procedure owner_user_can_run_new is
  begin
    can_run_all_new_packages( 'ut3_cache_test_owner' );
    cache_populated_for_packages( ut_varchar2_rows( 'GRANTED_TEST_SUITE', 'NEW_SUITE', 'NOT_GRANTED_TEST_SUITE' ) );
  end;

  procedure owner_user_cant_run_dropped is
  begin
    can_run_all_but_dropped('ut3_cache_test_owner');
    cache_populated_for_packages( ut_varchar2_rows( 'GRANTED_TEST_SUITE', 'NOT_GRANTED_TEST_SUITE' ) );
  end;


  procedure t_user_can_run_one_package is
  begin
    can_run_one_package( 'ut3_no_extra_priv_user' );
    cache_populated_for_packages( ut_varchar2_rows( 'GRANTED_TEST_SUITE', 'NOT_GRANTED_TEST_SUITE' ) );
  end;

  procedure t_user_can_run_new_package is
  begin
    can_run_new_package( 'ut3_no_extra_priv_user' );
    cache_populated_for_packages( ut_varchar2_rows( 'GRANTED_TEST_SUITE', 'NEW_SUITE', 'NOT_GRANTED_TEST_SUITE' ) );
  end;

  procedure t_user_cant_run_revoked_pkg is
  begin
    cant_run_revoked_package( 'ut3_no_extra_priv_user' );
    cache_populated_for_packages( ut_varchar2_rows( 'GRANTED_TEST_SUITE', 'NEW_SUITE', 'NOT_GRANTED_TEST_SUITE' ) );
  end;

  procedure t_user_cant_run_dropped_pkg is
  begin
    cant_run_dropped_package( 'ut3_no_extra_priv_user' );
    cache_populated_for_packages( ut_varchar2_rows( 'GRANTED_TEST_SUITE', 'NOT_GRANTED_TEST_SUITE' ) );
  end;

  procedure t_sel_cat_user_can_run_one is
  begin
    can_run_one_package( 'ut3_select_catalog_user' );
    cache_populated_for_packages( ut_varchar2_rows( 'GRANTED_TEST_SUITE', 'NOT_GRANTED_TEST_SUITE' ) );
  end;

  procedure t_sel_cat_user_can_run_new is
  begin
    can_run_new_package( 'ut3_select_catalog_user' );
    cache_populated_for_packages( ut_varchar2_rows( 'GRANTED_TEST_SUITE', 'NEW_SUITE', 'NOT_GRANTED_TEST_SUITE' ) );
  end;

  procedure t_sel_cat_user_cant_run_revokd is
  begin
    cant_run_revoked_package( 'ut3_select_catalog_user' );
    cache_populated_for_packages( ut_varchar2_rows( 'GRANTED_TEST_SUITE', 'NEW_SUITE', 'NOT_GRANTED_TEST_SUITE' ) );
  end;

  procedure t_sel_cat_user_cant_run_dropd is
  begin
    cant_run_dropped_package( 'ut3_select_catalog_user' );
    cache_populated_for_packages( ut_varchar2_rows( 'GRANTED_TEST_SUITE', 'NOT_GRANTED_TEST_SUITE' ) );
  end;


  procedure t_sel_any_user_can_run_one is
  begin
    can_run_one_package( 'ut3_select_any_table_user' );
    cache_populated_for_packages( ut_varchar2_rows( 'GRANTED_TEST_SUITE', 'NOT_GRANTED_TEST_SUITE' ) );
  end;

  procedure t_sel_any_user_can_run_new is
  begin
    can_run_new_package( 'ut3_select_any_table_user' );
    cache_populated_for_packages( ut_varchar2_rows( 'GRANTED_TEST_SUITE', 'NEW_SUITE', 'NOT_GRANTED_TEST_SUITE' ) );
  end;

  procedure t_sel_any_user_cant_run_revokd is
  begin
    cant_run_revoked_package( 'ut3_select_any_table_user' );
    cache_populated_for_packages( ut_varchar2_rows( 'GRANTED_TEST_SUITE', 'NEW_SUITE', 'NOT_GRANTED_TEST_SUITE' ) );
  end;

  procedure t_sel_any_user_cant_run_dropd is
  begin
    cant_run_dropped_package( 'ut3_select_any_table_user' );
    cache_populated_for_packages( ut_varchar2_rows( 'GRANTED_TEST_SUITE', 'NOT_GRANTED_TEST_SUITE' ) );
  end;


  procedure t_exe_any_user_can_run_all is
  begin
    can_run_all_packages( 'ut3_execute_any_proc_user' );
    cache_populated_for_packages( ut_varchar2_rows( 'GRANTED_TEST_SUITE', 'NOT_GRANTED_TEST_SUITE' ) );
  end;

  procedure t_exe_any_user_can_run_new is
  begin
    can_run_all_new_packages( 'ut3_execute_any_proc_user' );
    cache_populated_for_packages( ut_varchar2_rows( 'GRANTED_TEST_SUITE', 'NEW_SUITE', 'NOT_GRANTED_TEST_SUITE' ) );
  end;

  procedure t_exe_any_user_can_run_revokd is
  begin
    can_run_revoked_packages( 'ut3_execute_any_proc_user' );
    cache_populated_for_packages( ut_varchar2_rows( 'GRANTED_TEST_SUITE', 'NEW_SUITE', 'NOT_GRANTED_TEST_SUITE' ) );
  end;

  procedure t_exe_any_user_cant_run_dropd is
  begin
    can_run_all_but_dropped( 'ut3_execute_any_proc_user' );
    cache_populated_for_packages( ut_varchar2_rows( 'GRANTED_TEST_SUITE', 'NOT_GRANTED_TEST_SUITE' ) );
  end;

  procedure t_owner_user_can_run_all is
  begin
    can_run_all_packages( 'ut3_cache_test_owner' );
    cache_populated_for_packages( ut_varchar2_rows( 'GRANTED_TEST_SUITE', 'NOT_GRANTED_TEST_SUITE' ) );
  end;

  procedure t_owner_user_can_run_new is
  begin
    can_run_all_new_packages( 'ut3_cache_test_owner' );
    cache_populated_for_packages( ut_varchar2_rows( 'GRANTED_TEST_SUITE', 'NEW_SUITE', 'NOT_GRANTED_TEST_SUITE' ) );
  end;

  procedure t_owner_user_cant_run_dropd is
  begin
    can_run_all_but_dropped( 'ut3_cache_test_owner' );
    cache_populated_for_packages( ut_varchar2_rows( 'GRANTED_TEST_SUITE', 'NOT_GRANTED_TEST_SUITE' ) );
  end;




  procedure p_user_can_run_one_package is
  begin
    can_run_one_package( 'ut3_no_extra_priv_user' );
    cache_populated_for_packages( ut_varchar2_rows( 'GRANTED_TEST_SUITE' ) );
  end;

  procedure p_user_can_run_new_package is
  begin
    can_run_new_package( 'ut3_no_extra_priv_user' );
    cache_populated_for_packages( ut_varchar2_rows( 'GRANTED_TEST_SUITE', 'NEW_SUITE' ) );
  end;

  procedure p_user_cant_run_revoked_pack is
  begin
    cant_run_revoked_package( 'ut3_no_extra_priv_user' );
    cache_populated_for_packages( ut_varchar2_rows( 'GRANTED_TEST_SUITE', 'NEW_SUITE' ) );
  end;

  procedure p_user_cant_run_dropped_pack is
  begin
    cant_run_dropped_package( 'ut3_no_extra_priv_user' );
    cache_populated_for_packages( ut_varchar2_rows( 'GRANTED_TEST_SUITE' ) );
  end;



  procedure p_sel_cat_user_can_run_one is
  begin
    can_run_one_package( 'ut3_select_catalog_user' );
    cache_populated_for_packages( ut_varchar2_rows( 'GRANTED_TEST_SUITE' ) );
  end;

  procedure p_sel_cat_user_can_run_new is
  begin
    can_run_new_package( 'ut3_select_catalog_user' );
    cache_populated_for_packages( ut_varchar2_rows( 'GRANTED_TEST_SUITE', 'NEW_SUITE' ) );
  end;

  procedure p_sel_cat_user_cant_run_revokd is
  begin
    cant_run_revoked_package( 'ut3_select_catalog_user' );
    cache_populated_for_packages( ut_varchar2_rows( 'GRANTED_TEST_SUITE', 'NEW_SUITE' ) );
  end;

  procedure p_sel_cat_user_cant_run_dropd is
  begin
    cant_run_dropped_package( 'ut3_select_catalog_user' );
    cache_populated_for_packages( ut_varchar2_rows( 'GRANTED_TEST_SUITE' ) );
  end;

  procedure p_sel_any_user_can_run_one is
  begin
    can_run_one_package( 'ut3_select_any_table_user' );
    cache_populated_for_packages( ut_varchar2_rows( 'GRANTED_TEST_SUITE' ) );
  end;

  procedure p_sel_any_user_can_run_new is
  begin
    can_run_new_package( 'ut3_select_any_table_user' );
    cache_populated_for_packages( ut_varchar2_rows( 'GRANTED_TEST_SUITE', 'NEW_SUITE' ) );
  end;

  procedure p_sel_any_user_cant_run_revokd is
  begin
    cant_run_revoked_package( 'ut3_select_any_table_user' );
    cache_populated_for_packages( ut_varchar2_rows( 'GRANTED_TEST_SUITE', 'NEW_SUITE' ) );
  end;

  procedure p_sel_any_user_cant_run_dropd is
  begin
    cant_run_dropped_package( 'ut3_select_any_table_user' );
    cache_populated_for_packages( ut_varchar2_rows( 'GRANTED_TEST_SUITE' ) );
  end;

  procedure p_exe_any_user_can_run_all is
  begin
    can_run_all_packages( 'ut3_execute_any_proc_user' );
    cache_populated_for_packages( ut_varchar2_rows( 'GRANTED_TEST_SUITE', 'NOT_GRANTED_TEST_SUITE' ) );
  end;

  procedure p_exe_any_user_can_run_new is
  begin
    can_run_all_new_packages( 'ut3_execute_any_proc_user' );
    cache_populated_for_packages( ut_varchar2_rows( 'GRANTED_TEST_SUITE', 'NEW_SUITE', 'NOT_GRANTED_TEST_SUITE' ) );
  end;

  procedure p_exe_any_user_can_run_revokd is
  begin
    can_run_revoked_packages( 'ut3_execute_any_proc_user' );
    cache_populated_for_packages( ut_varchar2_rows( 'GRANTED_TEST_SUITE', 'NEW_SUITE', 'NOT_GRANTED_TEST_SUITE' ) );
  end;

  procedure p_exe_any_user_cant_run_dropd is
  begin
    can_run_all_but_dropped( 'ut3_execute_any_proc_user' );
    cache_populated_for_packages( ut_varchar2_rows( 'GRANTED_TEST_SUITE', 'NOT_GRANTED_TEST_SUITE' ) );
  end;

  procedure p_owner_user_can_run_all is
  begin
    can_run_all_packages( 'ut3_cache_test_owner' );
    cache_populated_for_packages( ut_varchar2_rows( 'GRANTED_TEST_SUITE', 'NOT_GRANTED_TEST_SUITE' ) );
  end;

  procedure p_owner_user_can_run_new is
  begin
    can_run_all_new_packages( 'ut3_cache_test_owner' );
    cache_populated_for_packages( ut_varchar2_rows( 'GRANTED_TEST_SUITE', 'NEW_SUITE', 'NOT_GRANTED_TEST_SUITE' ) );
  end;

  procedure p_owner_user_cant_run_dropped is
  begin
    can_run_all_but_dropped( 'ut3_cache_test_owner' );
    cache_populated_for_packages( ut_varchar2_rows( 'GRANTED_TEST_SUITE', 'NOT_GRANTED_TEST_SUITE' ) );
  end;

end;
/
