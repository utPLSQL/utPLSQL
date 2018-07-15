create or replace package test_ut_run is
  --%suite(ut_run)

  procedure create_test_suite;
  procedure drop_test_suite;

  --%test(ut.run - raises after completing all tests if a test fails with ORA-04068 or ORA-04061)
  --%beforetest(create_test_suite)
  --%aftertest(drop_test_suite)
  procedure raise_in_invalid_state;
  
  --%test(ut.run - run invalid package and fail expectation)
  --%beforetest(compile_invalid_package)
  --%aftertest(drop_invalid_package)
  procedure run_in_invalid_state;
  procedure compile_invalid_package;
  procedure drop_invalid_package;
  
  --%test( Invalidate package specs via rebuild but still execute package)
  --%beforetest(generate_invalid_spec)
  --%aftertest(drop_test_package)
  procedure run_and_revalidate_specs;
  procedure generate_invalid_spec;
  procedure drop_test_package;  

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

  --%test( Pass single varchar2 into procedure )
  procedure pass_singlevar_with_proc;
 
  --%test( Pass varchar2_list into procedure )
  procedure pass_vlist_with_proc; 
 
   --%test( Pass coma separated list varchar2 into procedure )
  procedure pass_csl_with_proc;

  --%test( Pass coma separated list varchar2 into procedure with src file)
  procedure pass_csl_src_proc;
  
  --%endcontext
  
end;
/
