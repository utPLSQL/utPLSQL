create or replace package test_before_after_annotations is

  --%suite(annotations - beforetest and aftertest)
  --%suitepath(utplsql.core.annotations)

  --%beforeall
  procedure create_tests_results;


  --%test(Beforetest with call to procedure external to the test package)
  procedure beforetest_one_ext_procedure;
  
  --%test(Beforetest with call to multi procedures external and interal to the test package)
  procedure beforetest_multi_ext_procedure; 
  
  --%test(Beforetest with call to multi procedure where one does not exist)
  procedure beforetest_one_err_procedure;
end;