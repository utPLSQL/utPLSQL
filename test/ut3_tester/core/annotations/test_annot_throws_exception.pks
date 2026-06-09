create or replace package test_annot_throws_exception
is
  --%suite(annotations - throws)
  --%suitepath(utplsql.ut3_tester.core.annotations)
    
  --%beforeall
  procedure recollect_tests_results;

  --%afterall
  procedure drop_test_package;


  --%test(Gives success when annotated number exception is thrown)
  procedure throws_same_annotated_except;

  --%test(Gives success when one of the annotated number exceptions is thrown)
  procedure throws_one_of_annotated_excpt;

  --%test(Gives success when annotated number exceptions has leading zero)
  procedure throws_with_leading_zero;

  --%test(Gives failure when the raised exception is different that the annotated one)
  procedure throws_diff_annotated_except;
  
  --%test(Ignores the throws annotation when it is empty)
  procedure throws_empty;
  
  --%test(Ignores when only bad parameters are passed, the test raise a exception and it shows errored test)
  procedure bad_paramters_with_except;
  
  --%test(Ignores when only bad parameters are passed, the test does not raise a exception and it shows successful test)
  procedure bad_paramters_without_except;

  --%test(Ignores annotation for positive exception number value)
  procedure positive_exception_number;

  --%test(Ignores annotation for positive exception number variable)
  procedure positive_exception_number_var;

  --%test(Detects a valid exception number within many invalid ones)
  procedure one_valid_exception_number;
  
  --%test(Gives failure when an exception is expected and nothing is thrown)
  procedure nothing_thrown;

  --%test(Single exception defined as a constant number in package)
  procedure single_exc_const_pkg;
  
  --%test(Gives success when one of annotated exception using constant is thrown)
  procedure list_of_exc_constant;  

  --%test(Gives failure when the raised exception is different than the annotated one using variable)
  procedure fail_not_match_exc;  
  
  --%test(Success when one of exception from a mixed list of number and constant is thrown)
  procedure mixed_exc_list; 
    
  --%test(Success when match exception even if another variable on list doesn't exists)
  procedure mixed_list_notexi;
    
  --%test(Success resolve and match named exception defined in pragma exception init)  
  procedure named_exc_pragma;

  --%test(Success resolve and match oracle named exception no data)
  procedure named_exc_ora;
 
  --%test(Success resolve and match oracle named exception dup val index)  
  procedure named_exc_ora_dup_ind;
  
  --%test(Success map no data 100 to -1403)  
  procedure nodata_exc_ora;  

  --%test(Success for exception defined as varchar)  
  procedure defined_varchar_exc;  
 
  --%test(Non existing constant exception)  
  procedure non_existing_const;   
  
  --%test(Bad exception constant)  
  procedure bad_exc_const;

  --%test(Uninitialized exception variable can be used successfully in a test)
  procedure referencing_uninitialized_exception;

  --%test(a Failure report shows all expected exceptions)
  procedure not_throwing_expected_exceptions;
  
  --%context(referencing exceptions when running from another schema)

    --%beforeall
    procedure run_from_another_schema;

    --%test(Success referencing an exception variable when running from another schema)
    procedure named_exc_pragma_run_from_another_schema;

    --%test(Success referencing a numeric exception variable when running from another schema)
    procedure exc_number_var_run_from_another_schema;

    --%test(Success referencing an exception variable without a package name when running from another schema)
    procedure named_exc_pragma_run_from_another_schema_no_package_name;

    --%test(Success referencing a numeric exception variable without a package name when running from another schema)
    procedure exc_number_var_run_from_another_schema_no_package_name;

  --%endcontext

end;
/
