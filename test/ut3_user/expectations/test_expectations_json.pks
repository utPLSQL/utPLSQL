create or replace package test_expectations_json is

  --%suite(json expectations)
  --%suitepath(utplsql.test_user.expectations)

  --%aftereach
  procedure cleanup_expectations;


  --%test(Gives success for identical data)
  procedure success_on_same_data;

  --%test(Gives failure for different data)
  procedure fail_on_diff_data;  
  
  --%test( Json variable is null)
  procedure null_json_variable;  

  --%test(Json string is null)
  procedure null_json;  
  
end;
/
