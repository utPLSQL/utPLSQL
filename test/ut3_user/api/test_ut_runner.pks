create or replace package test_ut_runner is

  --%suite(ut_runner)
  --%suitepath(utplsql.test_user.api)
  --%rollback(manual)

  --%test(transaction stays open after the run if it was opened before the run)
  procedure keep_an_open_transaction;

  --%test(closes open transactions if no transaction was open before run)
  procedure close_newly_opened_transaction;

  --%context(version_compatibility_check)

  --%test(compares major, minor and bugfix number)
  procedure version_comp_check_compare;

  --%test(ignores build number)
  procedure version_comp_check_ignore;

  --%test(compares short version to a full version)
  procedure version_comp_check_short;

  --%test(raises exception when invalid version passed)
  procedure version_comp_check_exception;

  --%endcontext

  --%test(run resets cache of package body after every run)
  procedure run_reset_package_body_cache;

  --%test(does not consume dbms_output from before the run)
  procedure run_keep_dbms_output_buffer;

  procedure setup_cache;
  procedure cleanup_cache;

  --%test(Purges cache for a given schema and object type)
  --%beforetest(setup_cache)
  --%aftertest(cleanup_cache)
  procedure test_purge_cache_schema_type;

  procedure setup_cache_objects;
  procedure setup_cache_objectstag;
  procedure setup_cache_twotags;
  procedure setup_cache_longtags;

  --%test(Rebuilds cache for a given schema and object type)
  --%beforetest(setup_cache_objects)
  --%aftertest(cleanup_cache)
  procedure test_rebuild_cache_schema_type;

  --%test(get_suites_info returns a cursor containing records for a newly created test)
  --%beforetest(setup_cache_objects)
  --%aftertest(cleanup_cache)
  procedure test_get_suites_info_notag;

  --%test(get_suites_info returns a cursor containing records for a newly created test with tag)
  --%beforetest(setup_cache_objectstag)
  --%aftertest(cleanup_cache)
  procedure test_get_suites_info_tag;
  
  --%test(get_suites_info returns a cursor containing records for a newly created test with two tags)
  --%beforetest(setup_cache_twotags)
  --%aftertest(cleanup_cache)
  procedure test_get_suites_info_twotag;  

  /*** 
  * This test at the moment is not possible to correctly run due to limit of to_string when
  * displaying a diff message returnign max 4k char. 
  */
  --%test(get_suites_info returns a cursor containing records for a newly created test with long tag)
  --%beforetest(setup_cache_longtags)
  --%aftertest(cleanup_cache)
  --%disabled
  procedure test_get_suites_info_longtag;

  --%test(get_reporters_list returns a cursor containing all built-in reporters and information about output-reporter)
  --%beforetest(setup_cache_objects)
  --%aftertest(cleanup_cache)
  procedure test_get_reporters_list;

  procedure db_link_cleanup;
  procedure db_link_setup;

  --%test(ORA-20213 is thrown with a_raise_on_failure when database link operations are used - regression)
  --%beforetest(db_link_setup)
  --%aftertest(db_link_cleanup)
  procedure raises_20213_on_fail_link;

  procedure create_test_csl_packages;
  procedure drop_test_csl_packages;
  
  --%context(ut_run_coma_sep_list)
  --%beforeall(create_test_csl_packages)
  --%afterall(drop_test_csl_packages)
  
  --%test( Pass name of tests as varchar2_list )  
  procedure pass_varchar2_name_list;
 
  --%test( Pass single test name as varchar2 ) 
  procedure pass_varchar2_name;
  
  --%test( Pass coma separated list of suite names )
  procedure pass_varchar2_suite_csl;

  --%test( Pass coma separated list of test names )
  procedure pass_varchar2_test_csl;

  --%test( Pass coma separated list of test names with spaces )
  procedure pass_varch_test_csl_spc;

  --%test( Pass coma separated list and source and test files )
  procedure pass_csl_with_srcfile;
 
  --%test( Pass coma separated list in varchar2list )
  procedure pass_csl_within_var2list; 
  
  --%endcontext

  --%context(is_test)
  --%beforeall(setup_cache_objects)
  --%afterall(cleanup_cache)

  --%test(Returns true when procedure is a test)
  procedure is_test_true;

  --%test(Returns false when procedure is not a test)
  procedure is_test_false;

  --%endcontext

  --%context(is_suite)
  --%beforeall(setup_cache_objects)
  --%afterall(cleanup_cache)

  --%test(Returns true when package is a test suite)
  procedure is_suite_true;

  --%test(Returns false when package is not a test suite)
  procedure is_suite_false;

  --%endcontext

  --%context(has_suites)
  --%beforeall(setup_cache_objects)
  --%afterall(cleanup_cache)

  --%test(Returns true when schema contains test suites)
  procedure has_suites_true;

  --%test(Returns false when schema does not contain test suites)
  procedure has_suites_false;

  --%endcontext

end;
/
