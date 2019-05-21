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

  --%test( Json variable is not null)
  procedure not_null_json_variable;  

  --%test( Fail json variable is null)
  procedure fail_null_json_var;  

  --%test( Fail json variable is not null)
  procedure fail_not_null_json_var;  

  --%test(Json string is empty)
  procedure empty_json;  
 
  --%test(Json string is not empty)
  procedure not_empty_json;   
  
  --%test( Fail json string is empty)
  procedure fail_empty_json;  
 
  --%test( Fail json string is not empty)
  procedure fail_not_empty_json;
  
end;
/
