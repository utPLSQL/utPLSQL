create or replace package test_ut_run is
  --%suite(ut.run)
  --%suitepath(utplsql.test_user.api)

  procedure clear_expectations;
  
  procedure create_ut3$user#_tests;
  procedure drop_ut3$user#_tests;  
  
  --%test(ut.version() returns version of the framework)
  procedure ut_version;

  --%test(ut.fail() marks test as failed)
  --%beforetest(ut3_tester_helper.main_helper.set_ut_run_context)
  --%aftertest(clear_expectations, ut3_tester_helper.main_helper.clear_ut_run_context)
  procedure ut_fail;

  --%context(ut_run_procedure)
  --%displayname(ut.run() procedure options)
  --%beforeall(create_ut3$user#_tests)
  --%afterall(drop_ut3$user#_tests)

  --%test(Runs all tests in current schema with default reporter when no parameters given)
  procedure run_proc_no_params;
  --%test(Runs all tests in current schema with specified reporter)
  procedure run_proc_specific_reporter;
  --%test(Runs all tests in current schema with coverage file list)
  procedure run_proc_cov_file_list;

  --%test(Runs given package only with package name given as path)
  procedure run_proc_pkg_name;
  --%test(Runs all from given package with package name given as path and coverage file list)
  procedure run_proc_pkg_name_file_list;
  --%test(Runs tests from given paths only with paths list)
  procedure run_proc_path_list;
  --%test(Runs tests from given paths only with paths list and coverage file list)
  procedure run_proc_path_list_file_list;
  --%test(Runs all tests in current schema using default reporter when null reporter given)
  procedure run_proc_null_reporter;
  --%test(Runs all tests in current schema with null path provided)
  procedure run_proc_null_path;
  --%test(Runs all tests in current schema with null path list given)
  procedure run_proc_null_path_list;
  --%test(Runs all tests in current schema with empty path list given)
  procedure run_proc_empty_path_list;

  procedure create_suite_with_commit;
  procedure drop_suite_with_commit;
  --%test(Reports a warning if transaction was invalidated by test with automatic rollback)
  --%beforetest(create_suite_with_commit)
  --%aftertest(drop_suite_with_commit)
  procedure run_proc_warn_on_commit;


  procedure create_failing_beforeall_suite;
  procedure drop_failing_beforeall_suite;
  --%test(Marks child suite as failed when parent's suite beforeall fails)
  --%beforetest(create_failing_beforeall_suite)
  --%aftertest(drop_failing_beforeall_suite)
  procedure run_proc_fail_child_suites;

  procedure create_suite_with_link;
  procedure drop_suite_with_link;
  
  --%test(Savepoints are working properly on distributed transactions - Issue #839)
  --%beforetest(create_suite_with_link)
  --%aftertest(drop_suite_with_link)
  procedure savepoints_on_db_links;

  --%endcontext

  --%context(run_proc_transaction_control)

  --%beforeall
  procedure transaction_setup;
  --%afterall
  procedure transaction_cleanup;
  --%test(Leaves transaction open and uncommitted with a_force_manual_rollback)
  procedure run_proc_keep_test_data;
  --%test(Leaves transaction open and uncommitted with a_force_manual_rollback with exceptions)
  procedure run_proc_keep_test_data_raise;
  --%test(Does not impact current transaction when ran without a_force_manual_rollback)
  procedure run_proc_discard_test_data;

  --%endcontext


  --%context(ut_run_function)
    
  --%displayname(ut.run() function options)
  --%beforeall(create_ut3$user#_tests)
  --%afterall(drop_ut3$user#_tests)

  --%test(Runs all tests in current schema with default reporter when no parameters given)
  procedure run_func_no_params;
  --%test(Runs all tests in current schema with specified reporter)
  procedure run_func_specific_reporter;
  --%test(Runs all tests in current schema with coverage file list)
  procedure run_func_cov_file_list;

  --%test(Runs given package only with package name given as path)
  procedure run_func_pkg_name;
  --%test(Runs all from given package with package name given as path and coverage file list)
  procedure run_func_pkg_name_file_list;
  --%test(Runs tests from given paths with paths list)
  procedure run_func_path_list;
  --%test(Runs tests from given paths with paths list and coverage file list)
  procedure run_func_path_list_file_list;
  --%test(Runs all tests in current schema using default reporter when null reporter given)
  procedure run_func_null_reporter;
  --%test(Runs all tests in current schema with null path provided)
  procedure run_func_null_path;
  --%test(Runs all tests in current schema with null path list given)
  procedure run_func_null_path_list;
  --%test(Runs all tests in current schema with empty path list given)
  procedure run_func_empty_path_list;
  --%test(Runs all tests in current schema with coverage file list and default reporter)
  procedure run_func_cov_file_lst_null_rep;
  --%test(Executes successfully an empty suite)
  procedure run_func_empty_suite;

  --disabled(Makes session wait for lock on 18.1 due to library cache pin wait)
  --%test(ut.run - raises after completing all tests if a test fails with ORA-04068 or ORA-04061)
  --%beforetest(create_test_suite)
  --%aftertest(drop_test_suite)
  procedure raise_in_invalid_state;
  procedure create_test_suite;
  procedure drop_test_suite;

  --%test(ut.run - Does not execute suite when specified package is not valid)
  --%beforetest(compile_invalid_package)
  --%aftertest(drop_invalid_package)
  procedure run_in_invalid_state;
  procedure compile_invalid_package;
  procedure drop_invalid_package;

  --%test(Invalidate package specs via rebuild but still execute package)
  --%beforetest(generate_invalid_spec)
  --%aftertest(drop_invalid_spec)
  procedure run_and_revalidate_specs;
  procedure generate_invalid_spec;
  procedure drop_invalid_spec;

  --%test(Provides warnings on invalid annotations)
  --%beforetest(create_bad_annot)
  --%aftertest(drop_bad_annot)
  procedure run_and_report_warnings;
  procedure create_bad_annot;
  procedure drop_bad_annot;

  --%test(Can run test package that is named the same as schema name)
  --%beforetest(create_schema_name_package)
  --%aftertest(drop_schema_name_package)
  procedure run_schema_name_test;
  procedure create_schema_name_package;
  procedure drop_schema_name_package;

  --%endcontext

  --%context(random_order)
    
  --%displayname(Random test execution order)
  --%beforeall(create_ut3$user#_tests)
  --%afterall(drop_ut3$user#_tests)

  --%test(Runs tests in random order)
  procedure run_with_random_order;

  --%test(Reports test random_test_order_seed)
  procedure run_and_report_random_ord_seed;

  --%test(Runs tests in the same random order with provided seed)
  procedure run_with_random_order_seed;

  --%endcontext

  --%context(run with tags)
    
  --%displayname(Call ut.run with #tags)
  --%beforeall(create_ut3$user#_tests)
  --%afterall(drop_ut3$user#_tests)
  
  --%test(Execute test by tag ut_run)
  procedure test_run_by_one_tag;
  
  --%test( Execute suite by one tag)
  procedure suite_run_by_one_tag;

  --%test(Execute two tests by one tag)
  procedure two_test_run_by_one_tag;
 
  --%test(Execute all suites tests with tag)
  procedure all_suites_run_by_one_tag;  
  
  --%test(Execute tests by passing two tags)
  procedure two_test_run_by_two_tags;  
  
  --%test(Execute suite and all of its children)
  procedure suite_with_children_tag;  
  
  --%test(Execute suite and parents)
  procedure suite_with_tag_parent;   
  
  --%test(Execute test for non existing tag)
  procedure test_nonexists_tag;    
  
  --%test(Execute test for duplicate list tags)
  procedure test_duplicate_tag;   
  
  --%test(Execute suite test for duplicate list tags)
  procedure suite_duplicate_tag;   

  --%test(Runs given package only with package name given as path and filter by tag)
  procedure run_proc_pkg_name_tag;
  
  --%test(Runs all from given package with package name given as path and coverage file list with tag)
  procedure run_pkg_name_file_list_tag;
  
  --%test(Runs tests from given paths with paths list and tag)
  procedure run_proc_path_list_tag;  
  
  --%test(Runs all tests in current schema with default reporter when only tag is given)
  procedure tag_run_func_no_params;

  --%test(Runs given package only with package name given as path and filter by tag)
  procedure tag_run_func_pkg_name;

  --%test(Runs tests from given paths with paths list and a tag)
  procedure tag_run_func_path_list;
 
  --%endcontext

  --%context(ut3_info context)

    --%beforeall
    procedure set_application_info;
    --%beforeall
    procedure create_context_test_suite;

    --%beforeall
    procedure run_context_test_suite;

    --%afterall
    procedure drop_context_test_suite;

    --%test(sets context for suite level beforeall)
    procedure sys_ctx_on_suite_beforeall;

    --%test(sets context for context level beforeall)
    procedure sys_ctx_on_context_beforeall;

    --%test(set for context level beforeeach)
    procedure sys_ctx_on_beforeeach;

    --%test(set for context level beforetest)
    procedure sys_ctx_on_beforetest;

    --%test(set for context level test)
    procedure sys_ctx_on_test;

    --%test(set for context level aftertest)
    procedure sys_ctx_on_aftertest;

    --%test(set for context level aftereach)
    procedure sys_ctx_on_aftereach;

    --%test(set for context level afterall)
    procedure sys_ctx_on_context_afterall;

    --%test(set for suite level afterall)
    procedure sys_ctx_on_suite_afterall;

    --%test(is cleared after run)
    procedure sys_ctx_clear_after_run;

    --%test(application info is restored after run)
    procedure app_info_restore_after_run;

  --%endcontext
  
end;
/

