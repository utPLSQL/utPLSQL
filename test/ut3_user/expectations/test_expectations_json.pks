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
  
  --%test( Json object to have count )
  procedure to_have_count;
  
  --%test( Fail Json object to have count)
  procedure fail_to_have_count;
  
    --%test( Json object not to have count)
  procedure not_to_have_count;
  
  --%test( Fail Json object not to have count)
  procedure fail_not_to_have_count;
    
  --%test( Json object to have count on array)
  procedure to_have_count_array;
  
  --%test( Two json use plsql function to extract same pieces and compare)
  procedure to_diff_json_extract_same;

  --%test( Two json use plsql function to extract diff pieces and compare)
  procedure to_diff_json_extract_diff;
  
  --%test( Long JSON test same )
  procedure long_json_test;

  --%test( JSON test same semantic content different order )
  procedure json_same_diffrent_ord;

  --%test( Long complex nested JSON test )
  procedure long_json_test2;

  --%test( Long complex json differences )
  procedure long_json_diff;
  
  --%test( Compare two objects json )
  procedure check_json_objects;
  
  --%test( Compare two json arrays )
  procedure check_json_arrays;
 
  $if dbms_db_version.version >= 21 $then
  
  --%test(Gives success for identical data using native json for 21c and above)
  procedure success_on_same_data_njson;

  --%test(Gives failure for different data using native json for 21c and above)
  procedure fail_on_diff_data_njson; 

  --%test( Json variable is null using native json for 21c and above)
  procedure null_json_variable_njson;

  --%test( Json object to have count using native json for 21c and above)
  procedure to_have_count_njson;
  
  --%test( Fail Json object to have count using native json for 21c and above)
  procedure fail_to_have_count_njson;
  
  --%test( Json object not to have count using native json for 21c and above)
  procedure not_to_have_count_njson;
  
  --%test( Fail Json object not to have count using native json for 21c and above)
  procedure fail_not_to_have_count_njson;
  
  $end

  --%test( Regression scenario tests for issue #1113 where the expected has been switched with actual)  
  procedure p_1113_reg_exp_chg_with_act;
  
end;
/
