create or replace package test_suite_manager is

  --%suite(suite_manager)
  --%suitepath(utplsql.core)

  --%beforeall
  procedure compile_dummy_packages;
  --%afterall
  procedure drop_dummy_packages;

  --%test(Prepare Runner For The Schema)
  procedure test_schema_run;

  --%test(Prepare runner for the top 2 package by package user.package_name)
  procedure test_top2_by_name;

  --%test(Prepare runner for the top2 package by name cur user)
  procedure test_top2_bt_name_cur_user;

  --%test(Prepare runner for the subsuite by path)
  procedure test_by_path_to_subsuite;

  --%test(Prepare runner for the subsuite by path for current user)
  procedure test_by_path_to_subsuite_cu;

  --%test(Prepare runner for the subsuite proc only by path)
  procedure test_subsute_proc_by_path;

  --%test(Prepare runner for the subsuite proc only by path for current user)
  procedure test_subsute_proc_by_path_cu;

  --%test(Prepare runner for the top package by package name)
  procedure test_top_pack_by_name;

  --%test(Prepare runner for the top package by package name for current user)
  procedure test_top_pack_by_name_cu;

  --%test(Prepare runner for the top package by path)
  procedure test_top_pack_by_path;

  --%test(Prepare runner for the top package by path for current user)
  procedure test_top_pack_by_path_cu;

  --%test(Prepare runner for the top package procedure by path)
  procedure test_top_pck_proc_by_path;

  --%test(Prepare runner for the top package procedure by path for current user)
  procedure test_top_pck_proc_by_path_cu;

  --%test(Prepare runner for the top package procedure without sub-suites by package name)
  procedure test_top_pkc_proc_by_name;

  --%test(Prepare runner for the top package procedure without sub-suites by package name for current user)
  procedure test_top_pkc_proc_by_name_cu;

  --%test(Prepare runner for the top package without sub-suites by package name)
  procedure test_top_pkc_nosub_by_name;

  --%test(Prepare runner for the top package without sub-suites by package name for current user)
  procedure test_top_pkc_nosub_by_name_cu;

  --%test(Prepare runner for the suites package by path)
  procedure test_top_subpck_by_path;

  --%test(Prepare runner for the suites package by path for current user)
  procedure test_top_subpck_by_path_cu;

  --%test(Prepare runner for invalid package - it will add to suite but fail on exec )
  --%beforetest(compile_invalid_package)
  --%aftertest(drop_invalid_package)
  procedure test_search_invalid_pck;
  procedure compile_invalid_package;
  procedure drop_invalid_package;
 
  --%test(Prepare runner for nonexisting package with schema) 
  procedure test_search_nonexisting_pck;
 
   --%test(Prepare runner for nonexisting package without schema) 
  procedure test_search_nonexist_sch_pck; 

  --%test(Test description with comma)
  --%beforetest(setup_desc_with_comma)
  --%aftertest(clean_desc_with_comma)
  procedure test_desc_with_comma;
  procedure setup_desc_with_comma;
  procedure clean_desc_with_comma;

  --%test(Invalidate cache on package drop)
  --%beforetest(setup_inv_cache_on_drop)
  --%aftertest(clean_inv_cache_on_drop)
  procedure test_inv_cache_on_drop;
  procedure setup_inv_cache_on_drop;
  procedure clean_inv_cache_on_drop;

  --%test(Includes Invalid Package Bodies In The Run)
  --%beforetest(setup_inv_pck_bodies)
  --%aftertest(clean_inv_pck_bodies)
  procedure test_inv_pck_bodies;
  procedure setup_inv_pck_bodies;
  procedure clean_inv_pck_bodies;

  --%test(Package With Dollar Sign)
  --%beforetest(setup_pck_with_dollar)
  --%aftertest(clean_pck_with_dollar)
  procedure test_pck_with_dollar;
  procedure setup_pck_with_dollar;
  procedure clean_pck_with_dollar;

  --%test(Package With Hash Sign)
  --%beforetest(setup_pck_with_hash)
  --%aftertest(clean_pck_with_hash)
  procedure test_pck_with_hash;
  procedure setup_pck_with_hash;
  procedure clean_pck_with_hash;

  --%test(Package with test with dollar sign)
  --%beforetest(setup_test_with_dollar)
  --%aftertest(clean_test_with_dollar)
  procedure test_test_with_dollar;
  procedure setup_test_with_dollar;
  procedure clean_test_with_dollar;

  --%test(Package with test with hash sign)
  --%beforetest(setup_test_with_hash)
  --%aftertest(clean_test_with_hash)
  procedure test_test_with_hash;
  procedure setup_test_with_hash;
  procedure clean_test_with_hash;


  --%test(Setup suite with empty suitepath)
  --%beforetest(setup_empty_suite_path)
  --%aftertest(clean_empty_suite_path)
  procedure test_empty_suite_path;
  procedure setup_empty_suite_path;
  procedure clean_empty_suite_path;

  --%test(only the defined in suitepath suite/test is executed if multiple similarly named test suites exist in the context differed only by comment)
  --%beforetest(setup_pck_with_same_path)
  --%aftertest(clean_pck_with_same_path)
  procedure test_pck_with_same_path;
  procedure setup_pck_with_same_path;
  procedure clean_pck_with_same_path;

  --%test(Whole suite gets disabled with floating annotation)
  procedure disable_suite_floating_annot;

  --%test(Prepare runner for a package procedure inside context)
  procedure pck_proc_in_ctx_by_name;

  --%test(Prepare runner for a package procedure inside context by path)
  procedure pck_proc_in_ctx_by_path;

  --%context(get_schema_ut_packages)

  --%test(returns list of all unit test packages in given schema)
  --%beforetest(create_ut3_suite)
  --%aftertest(drop_ut3_suite)
  procedure test_get_schema_ut_packages;
  procedure create_ut3_suite;
  procedure drop_ut3_suite;

  --%endcontext

end test_suite_manager;
/
