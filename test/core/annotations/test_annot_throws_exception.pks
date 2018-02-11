create or replace package test_annot_throws_exception
is
  --%suite(annotations- throws)
  --%suitepath(utplsql.core.annotations)
    
  --%beforeall
  procedure recolect_tests_results;
  
  --%test(Gives success when annotated number exception is thrown)
  procedure throws_same_annotated_except;
  
  --%test(Gives succes when one of the annotated number exceptions is thrown)
  procedure throws_one_of_annotated_excpt;
  
  --%test(Gives failure when the raised exception is different that the annotated one)
  procedure throws_diff_annotated_except;
  
  --%test(Ignores when  the annotation throws is empty)
  procedure throws_empty;
  
  --%test(Ignores when only bad parameters are passed, the test raise a exception and it shows errored test)
  procedure bad_paramters_with_except;
  
  --%test(Ignores when only bad parameters are passed, the test does not raise a exception and it shows successful test)
  procedure bad_paramters_without_except;
  
  --%test(Detects a valid exception number within many invalid ones)
  procedure one_valid_exception_number;
  
  --%test(Givess failure when a exception is expected and nothing is thrown)
  procedure nothing_thrown;
end;
/
