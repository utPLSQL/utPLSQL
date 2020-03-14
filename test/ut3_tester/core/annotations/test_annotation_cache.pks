create or replace package test_annotation_cache is

  --%suite(annotation cache)
  --%suitepath(utplsql.ut3_tester.core.annotations)
  --%beforeall(annotation_cache_helper.create_run_function_for_users)
  --%afterall(annotation_cache_helper.drop_run_function_for_users)

  --%context(With DDL trigger enabled)

    --%beforeall(annotation_cache_helper.enable_ddl_trigger)
    --%beforeeach(annotation_cache_helper.setup_two_suites)
    --%aftereach(annotation_cache_helper.cleanup_new_suite)
    --%afterall(annotation_cache_helper.cleanup_two_suites)

    --%context(User without elevated privileges)

      --%test(Can only execute granted packages)
      procedure t_user_can_run_one_package;

      --%test(Can see newly created packages as they are added)
      procedure t_user_can_run_new_package;

      --%test(Cannot execute revoked packages)
      procedure t_user_cant_run_revoked_pkg;

      --%test(Cannot execute dropped unit test packages)
      procedure t_user_cant_run_dropped_pkg;

    --%endcontext

    --%context(User with select_catalog_role)

      --%test(Can only execute granted packages)
      procedure t_sel_cat_user_can_run_one;

      --%test(Can see newly created packages as they are added)
      procedure t_sel_cat_user_can_run_new;

      --%test(Cannot execute revoked packages)
      procedure t_sel_cat_user_cant_run_revokd;

      --%test(Cannot execute dropped unit test packages)
      procedure t_sel_cat_user_cant_run_dropd;

    --%endcontext

    --%context(User with select any table privilege)

      --%test(Can only execute granted packages)
      procedure t_sel_any_user_can_run_one;

      --%test(Can see newly created packages as they are added)
      procedure t_sel_any_user_can_run_new;

      --%test(Cannot execute revoked packages)
      procedure t_sel_any_user_cant_run_revokd;

      --%test(Cannot execute dropped unit test packages)
      procedure t_sel_any_user_cant_run_dropd;

    --%endcontext

    --%context(User with execute any procedure)

      --%test(Can execute and see all unit test packages)
      procedure t_exe_any_user_can_run_all;

      --%test(Can see newly created packages as they are added)
      procedure t_exe_any_user_can_run_new;

      --%test(Can execute revoked packages)
      procedure t_exe_any_user_can_run_revokd;

      --%test(Cannot execute dropped unit test packages)
      procedure t_exe_any_user_cant_run_dropd;

    --%endcontext

    --%context(User owning test packages)

      --%test(Can execute and see all unit test packages)
      procedure t_owner_user_can_run_all;

      --%test(Can see newly created packages as they are added)
      procedure t_owner_user_can_run_new;

      --%test(Cannot execute dropped unit test packages)
      procedure t_owner_user_cant_run_dropd;

    --%endcontext

    --%context(utPLSQL framework owner)

      --%test(Cannot see any tests and doesn't impact annotation cache )
      procedure t_ut_owner_cannot_run_tests;

    --%endcontext

  --%endcontext

  --%context(With DDL trigger disabled)

    --%beforeall(annotation_cache_helper.disable_ddl_trigger)
    --%beforeeach(annotation_cache_helper.setup_two_suites)
    --%beforeeach(annotation_cache_helper.purge_annotation_cache)
    --%aftereach(annotation_cache_helper.cleanup_new_suite)
    --%afterall(annotation_cache_helper.enable_ddl_trigger)
    --%afterall(annotation_cache_helper.cleanup_two_suites)

    --%context(User without elevated privileges)

      --%test(Can only execute granted packages)
      procedure user_can_run_one_package;

      --%test(Can see newly created packages as they are added)
      procedure user_can_run_new_package;

      --%test(Cannot execute revoked packages)
      procedure user_cant_run_revoked_package;

      --%test(Cannot execute dropped unit test packages)
      procedure user_cant_run_dropped_package;

    --%endcontext

    --%context(User with select_catalog_role)

      --%test(Can only execute granted packages)
      procedure sel_cat_user_can_run_one;

      --%test(Can see newly created packages as they are added)
      procedure sel_cat_user_can_run_new;

      --%test(Cannot execute revoked packages)
      procedure sel_cat_user_cant_run_revoked;

      --%test(Cannot execute dropped unit test packages)
      procedure sel_cat_user_cant_run_dropped;

    --%endcontext

    --%context(User with select any table privilege)

      --%test(Can only execute granted packages)
      procedure sel_any_user_can_run_one;

      --%test(Can see newly created packages as they are added)
      procedure sel_any_user_can_run_new;

      --%test(Cannot execute revoked packages)
      procedure sel_any_user_cant_run_revoked;

      --%test(Cannot execute dropped unit test packages)
      procedure sel_any_user_cant_run_dropped;

    --%endcontext

    --%context(User with execute any procedure)

      --%test(Can execute and see all unit test packages)
      procedure exe_any_user_can_run_all;

      --%test(Can see newly created packages as they are added)
      procedure exe_any_user_can_run_new;

      --%test(Can execute revoked packages)
      procedure exe_any_user_can_run_revoked;

      --%test(Cannot execute dropped unit test packages)
      procedure exe_any_user_cant_run_dropped;

    --%endcontext

    --%context(User owning test packages)

      --%test(Can execute and see all unit test packages)
      procedure owner_user_can_run_all;

      --%test(Can see newly created packages as they are added)
      procedure owner_user_can_run_new;

      --%test(Cannot execute dropped unit test packages)
      procedure owner_user_cant_run_dropped;

    --%endcontext

  --%endcontext

  --%context(With DDL trigger enabled and cache purged)

    --%beforeall(annotation_cache_helper.enable_ddl_trigger)

    --%beforeeach(annotation_cache_helper.setup_two_suites)
    --%beforeeach(annotation_cache_helper.purge_annotation_cache)

    --%aftereach(annotation_cache_helper.cleanup_new_suite)
    --%aftereach(annotation_cache_helper.cleanup_two_suites)

    --%context(User without elevated privileges)

      --%test(Can only execute granted packages)
      procedure p_user_can_run_one_package;

      --%test(Can see newly created packages as they are added)
      procedure p_user_can_run_new_package;

      --%test(Cannot execute revoked packages)
      procedure p_user_cant_run_revoked_pack;

      --%test(Cannot execute dropped unit test packages)
      procedure p_user_cant_run_dropped_pack;

    --%endcontext

    --%context(User with select_catalog_role)

      --%test(Can only execute granted packages)
      procedure p_sel_cat_user_can_run_one;

      --%test(Can see newly created packages as they are added)
      procedure p_sel_cat_user_can_run_new;

      --%test(Cannot execute revoked packages)
      procedure p_sel_cat_user_cant_run_revokd;

      --%test(Cannot execute dropped unit test packages)
      procedure p_sel_cat_user_cant_run_dropd;

    --%endcontext

    --%context(User with select any table privilege)

      --%test(Can only execute granted packages)
      procedure p_sel_any_user_can_run_one;

      --%test(Can see newly created packages as they are added)
      procedure p_sel_any_user_can_run_new;

      --%test(Cannot execute revoked packages)
      procedure p_sel_any_user_cant_run_revokd;

      --%test(Cannot execute dropped unit test packages)
      procedure p_sel_any_user_cant_run_dropd;

    --%endcontext

    --%context(User with execute any procedure)

      --%test(Can execute and see all unit test packages)
      procedure p_exe_any_user_can_run_all;

      --%test(Can see newly created packages as they are added)
      procedure p_exe_any_user_can_run_new;

      --%test(Can execute revoked packages)
      procedure p_exe_any_user_can_run_revokd;

      --%test(Cannot execute dropped unit test packages)
      procedure p_exe_any_user_cant_run_dropd;

    --%endcontext

    --%context(User owning test packages)

      --%test(Can execute and see all unit test packages)
      procedure p_owner_user_can_run_all;

      --%test(Can see newly created packages as they are added)
      procedure p_owner_user_can_run_new;

      --%test(Cannot execute dropped unit test packages)
      procedure p_owner_user_cant_run_dropped;

    --%endcontext


  --%endcontext

end;
/
