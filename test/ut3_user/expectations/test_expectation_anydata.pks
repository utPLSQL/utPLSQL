create or replace package test_expectation_anydata is

  --%suite(equal on anydata)
  --%suitepath(utplsql.test_user.expectations)

  --%aftereach
  procedure cleanup;

  --%test(Gives failure when comparing NULL objects of different type)
  procedure fail_on_different_type_null;

  --%test(Gives failure when comparing objects of different type)
  procedure fail_on_different_type;

  --%test(Gives failure when objects holds different data)
  procedure fail_on_different_object_data;

  --%test(Gives failure when one of objects is NULL)
  procedure fail_on_one_object_null;

  --%test(Gives failure when comparing object to collection)
  procedure fail_on_collection_vs_object;

  --%test(Gives failure when comparing empty collection to NULL collection)
  procedure fail_on_null_vs_empty_coll;

  --%test(Gives failure when one of collections is NULL)
  procedure fail_on_one_collection_null;

  --%test(Gives failure when one of collections is empty)
  procedure fail_on_one_collection_empty;

  --%test(Gives failure when collections holds different data)
  procedure fail_on_different_coll_data;

  --%test(Gives success when both anydata are NULL)
  procedure success_on_both_anydata_null;

  --%test(Gives success when both objects are null)
  procedure success_on_both_object_null;

  --%test(Gives success when both collections are null)
  procedure success_on_both_coll_null;

  --%test(Gives success when both collections are of same type contain identical data)
  procedure success_on_same_coll_data;

  --%test(Gives failure when both collections contain the same data in different order)
  procedure fail_on_coll_different_order;

  --%test(Gives success when both objects are of same type and hold the same data)
  procedure success_on_same_object_data;

  --%test(List of attributes to exclude is case sensitive)
  procedure exclude_attributes_as_list;

  --%test(Comma separated list of attributes to exclude is case sensitive)
  procedure exclude_attributes_as_csv;

  --%test(Exclude attributes by XPath is case sensitive)
  procedure exclude_attributes_xpath;

  --%test(Excludes existing attributes when some of attributes on exclude are not valid column names)
  procedure exclude_ignores_invalid_attrib;

  --%test(List of attributes to include is case sensitive)
  procedure include_attributes_as_list;

  --%test(Comma separated list of attributes to include is case sensitive)
  procedure include_attributes_as_csv;

  --%test(Include attributes by XPath is case sensitive)
  procedure include_attributes_xpath;

  --%test(Includes existing attributes when some of attributes on exclude are not valid column names)
  procedure include_ignores_invalid_attrib;

  --%test(Includes only attributes that are not excluded)
  procedure include_exclude_attributes_csv;

  --%test(Includes only attributes that are not on exclude list)
  procedure include_exclude_attrib_list;

  --%test(Reports diff on incorrect attributes of an object type)
  procedure reports_diff_attribute;

  --%test(Reports diff on incorrect rows and attributes of a collection type)
  procedure reports_diff_structure;

  --%test(Adds a warning when using depreciated syntax to_equal( a_expected anydata, a_exclude varchar2 ))
  procedure deprec_to_equal_excl_varch;

  --%test(Adds a warning when using depreciated syntax to_equal( a_expected anydata, a_exclude ut_varchar2_list ))
  procedure deprec_to_equal_excl_list;

  --%test(Adds a warning when using depreciated syntax not_to_equal( a_expected anydata, a_exclude varchar2 ))
  procedure deprec_not_to_equal_excl_varch;

  --%test(Adds a warning when using depreciated syntax not_to_equal( a_expected anydata, a_exclude ut_varchar2_list ))
  procedure deprec_not_to_equal_excl_list;

  --%test(Adds a warning when using depreciated syntax to_( equal( a_expected anydata, a_exclude varchar2 ) ))
  procedure deprec_equal_excl_varch;

  --%test(Adds a warning when using depreciated syntax to_( equal( a_expected anydata, a_exclude ut_varchar2_list )) )
  procedure deprec_equal_excl_list;

  --%test(Reports only mismatched attributes on row data mismatch)
  procedure data_diff_on_atr_data_mismatch;

  --%test(Reports only first 20 rows of diff and gives a full diff count)
  procedure data_diff_on_20_rows_only;

  --%test(Validate include list on collections of objects)
  procedure collection_include_list;
  
  --%test(Validate exclude list on collections of objects)
  procedure collection_exclude_list;

  --%test(Validate include list on collections of objects fail)
  procedure collection_include_list_fail;  
  
  --%test(Two ARRAYS with same data)
  procedure array_same_data;
  
  --%test(Two ARRAYS with different data)
  procedure array_diff_data;  
  
  --%test(ARRAY is atomically null)
  procedure array_is_null;
  
  --%test(Compare two null ARRAYs)
  procedure array_null_equal_array_null; 
  
  --%test(Compare null ARRAY to ARRAY with data)
  procedure array_null_equal_array_notnull;   
  
  --%test(Empty ARRAY have count of 0)
  procedure empty_array_have_zero_elem;  
  
  --%test(Compare two empty ARRAYs)
  procedure array_empty_equal_array_empty; 
  
  --%test(Compare empty ARRAY to ARRAY with data)
  procedure arr_empty_equal_arr_notempty; 
  
  --%test(Collection is atomically NULL)
  procedure collection_is_null;
  
  --%test(Collection is empty)
  procedure collection_is_empty;
  
  --%test(Two VARRAYS with same data)
  procedure varray_same_data;
  
  --%test(Two VARRAYS with different data)
  procedure varray_diff_data;  
  
  --%test(VARRAY is atomically null)
  procedure varray_is_null;
  
  --%test(Compare two null VARRAYs)
  procedure varray_null_equal_varray_null; 
  
  --%test(Compare null VARRAY to VARRAY with data)
  procedure varr_null_equal_varr_notnull;   
  
  --%test(Empty VARRAY have count of 0)
  procedure empty_varray_have_zero_elem;  
  
  --%test(Compare two empty VARRAYs)
  procedure varr_empty_equal_varr_empty; 
  
  --%test(Compare empty VARRAY to VARRAY with data)
  procedure varr_empty_equal_varr_notempty;  
  
  --%test( Anydata collection using joinby )
  procedure collection_join_by;
 
  --%test( Anydata collection using joinby fail)
  procedure collection_join_by_fail; 
 
  --%test( Anydata collection unordered ) 
  procedure collection_unordered;
 
  --%test( Anydata collection unordered fail ) 
  procedure collection_unordered_fail; 
  
  --%test( Anydata object using joinby )
  procedure object_join_by;
 
  --%test( Anydata object unordered ) 
  procedure object_unordered;  
  
  --%test( Success when anydata collection contains data from another anydata collection)
  procedure collection_to_contain; 
  
  --%test( Success when anydata object contains data from another anydata)
  procedure object_to_contain;     
  
end;
/
