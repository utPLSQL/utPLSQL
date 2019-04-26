create or replace package test_expectations_cursor is

  --%suite(cursor expectations)
  --%suitepath(utplsql.test_user.expectations)

  --%aftereach
  procedure cleanup_expectations;

  procedure setup_temp_table_test;
  procedure cleanup_temp_table_test;

  --%test(Compares data from cursor on temporary table)
  --%beforetest(setup_temp_table_test)
  --%aftertest(cleanup_temp_table_test)
  procedure with_temp_table;

  --%test(Gives success for identical data)
  procedure success_on_same_data;

  --%test(Gives success for identical data with floats)
  procedure success_on_same_data_float;

  --%test(Gives success when both cursors are empty)
  procedure success_on_empty;

  --%test(Gives success when both cursors are null)
  procedure success_on_both_null;

  --%test(Gives success on to_be_null if cursor is null)
  procedure success_to_be_null;

  --%test(Gives success on not_to_be_not_null if cursor is null)
  procedure success_not_to_be_not_null;

  --%test(Gives success on not_to_be_null if cursor is not null)
  procedure success_not_to_be_null;

  --%test(Gives success on to_be_not_null if cursor is not null)
  procedure success_to_be_not_null;

  --%test(Gives success on is_empty if cursor is empty)
  procedure success_is_empty;

  --%test(Gives success on is_not_empty if cursor is not empty)
  procedure success_is_not_empty;

  --%test(Gives failure on is_null if cursor is null)
  procedure failure_is_null;

  --%test(Gives failure on is_not_null if cursor is not null)
  procedure failure_is_not_null;

  --%test(Gives failure on is_empty if cursor is empty)
  procedure failure_is_empty;

  --%test(Gives failure on is_not_empty if cursor is not empty)
  procedure failure_is_not_empty;

  --%test(Gives failure when one cursor is empty and another is null)
  procedure fail_null_vs_empty;

  --%test(Gives failure when different data present in one of rows)
  procedure fail_on_difference;

  --%test(Gives failure when more rows exist in actual)
  procedure fail_on_expected_missing;

  --%test(Gives failure when more rows exist in expected)
  procedure fail_on_actual_missing;

  --%test(Gives failure when different column name is used in cursors)
  procedure fail_on_different_column_name;

  --%test(Gives failure when different column ordering is used in cursors when enforced column order)
  procedure fail_on_different_column_order;

  --%test(Pass when different column ordering is used in cursors)
  procedure pass_on_different_column_order;

  --%test(Pass when different column ordering is used in cursors - shortname)
  procedure pass_on_diff_column_ord_uc;

  --%test(Fail and highlight diffrence between columns when columns are unordered and different value)
  procedure fail_on_multi_diff_col_order;

  --%test(Fail and highlight diffrence between columns when columns are unordered and different value - shortname)
  procedure fail_on_multi_diff_col_ord_uc;

  --%test(Gives failure when different row ordering is used in cursors)
  procedure fail_on_different_row_order;

  --%test(Compares time part of date when set_nls was used)
  procedure include_time_in_date_with_nls;

  --%test(Uses default NLS for date when set_nls was not used)
  procedure uses_default_nls_for_date;

  --%test(List of columns to exclude is case sensitive)
  procedure exclude_columns_as_list;

  --%test(Comma separated list of columns to exclude is case sensitive)
  procedure exclude_columns_as_csv;

  --%test(Excludes list of mixed columns and XPath)
  procedure exclude_columns_as_mixed_list;

  --%test(Excludes comma separated list of mixed columns and XPath)
  procedure exclude_columns_as_mix_csv_lst;

  --%test(Exclude column with invalid filter will result in column being included )
  procedure exclude_columns_xpath_invalid;

  --%test(Exclude columns by XPath is case sensitive)
  procedure exclude_columns_xpath;

  --%test(Excludes existing columns when some of columns on exclude are not valid column names)
  procedure exclude_ignores_invalid_column;

  --%test(List of columns to include is case sensitive)
  procedure include_columns_as_list;

  --%test(Comma separated list of columns to include is case sensitive)
  procedure include_columns_as_csv;

  --%test(Include columns by XPath is case sensitive)
  procedure include_columns_xpath;

  --%test(Includes existing columns when some of columns on exclude are not valid column names)
  procedure include_ignores_invalid_column;

  --%test(Includes only columns that are not excluded using combination of CSV and XPath)
  procedure include_exclude_col_csv_xpath;

  --%test(Includes only columns that are not on exclude list)
  procedure include_exclude_columns_list;

  --%test(Reports data-diff on rows mismatch)
  procedure data_diff_on_rows_mismatch;

  --%test(Char and varchar2 data-types are equal)
  procedure char_and_varchar2_col_is_equal;

  --%test(Reports column diff on cursor with different column data-type)
  procedure column_diff_on_data_type_diff;

  --%test(Reports column diff on cursor with different column name)
  procedure column_diff_on_col_name_diff;

  --%test(Reports column diff on cursor with different column positions when column order is enforced)
  procedure column_diff_on_col_position;

  --%test(Reports column diff on cursor with different column positions)
  procedure column_diff_on_col_pos_unord;

  --%test(Reports only mismatched columns on row data mismatch)
  procedure data_diff_on_col_data_mismatch;

  --%test(Reports only first 20 rows of diff and gives a full diff count)
  procedure data_diff_on_20_rows_only;

  --%test(Reports data diff and column diff when both are different with enforced ordered columns)
  procedure column_and_data_diff;

  --%test(Reports data diff and column diff when both are different when columns are not ordered)
  procedure col_and_data_diff_not_ordered;

  procedure prepare_table;
  procedure cleanup_table;

  --%test(Compares cursor on table to cursor on plsql data)
  --%beforetest(prepare_table)
  --%aftertest(cleanup_table)
  procedure compares_sql_and_plsql_types;

    --%test(Closes the cursor after use)
  procedure closes_cursor_after_use;

  --%test(Closes the cursor after use when exception was raised)
  procedure closes_cursor_after_use_on_err;

  --%test(Reports exception when cursor raises exception)
  procedure reports_on_exception_in_cursor;

   --%test(Reports an exception when cursor is closed)
  procedure exception_when_closed_cursor;

  --%test(Compares cursors with more than 1000 rows)
  procedure compares_over_1000_rows;

  --%test(Adds a warning when using depreciated syntax to_equal( a_expected sys_refcursor, a_exclude varchar2 ))
  procedure deprec_to_equal_excl_varch;

  --%test(Adds a warning when using depreciated syntax to_equal( a_expected sys_refcursor, a_exclude ut_varchar2_list ))
  procedure deprec_to_equal_excl_list;

  --%test(Adds a warning when using depreciated syntax not_to_equal( a_expected sys_refcursor, a_exclude varchar2 ))
  procedure deprec_not_to_equal_excl_varch;

  --%test(Adds a warning when using depreciated syntax not_to_equal( a_expected sys_refcursor, a_exclude ut_varchar2_list ))
  procedure deprec_not_to_equal_excl_list;

  --%test(Adds a warning when using depreciated syntax to_( equal( a_expected sys_refcursor, a_exclude varchar2 ) ))
  procedure deprec_equal_excl_varch;

  --%test(Adds a warning when using depreciated syntax to_( equal( a_expected sys_refcursor, a_exclude ut_varchar2_list )) )
  procedure deprec_equal_excl_list;

  --%test(Reports column diff on cursor with column name implicit )
  procedure col_diff_on_col_name_implicit;

  --%test(Reports column match on cursor with column name implicit )
  procedure col_mtch_on_col_name_implicit;
  
  --%test( Compare cursors using unordered method success)
  procedure cursor_unorderd_compr_success;
 
  --%test( Compare cursors using unordered method success and unordered columns position)
  procedure cursor_unord_compr_success_uc;
 
  --%test( Compare cursors using unordered method failure)
  procedure cursor_unordered_compare_fail; 
  
  --%test( Compare cursors join by single key )
  procedure cursor_joinby_compare; 
  
  --%test( Compare cursors join by single key with unordered columns position using shortname)
  procedure cursor_joinby_compare_uc;   
  
  --%test(Compare cursors by single key with unordered columns position)
  procedure cursor_joinby_col_not_ord;  
  
  --%test( Compare cursors join by composite key)
  procedure cursor_joinby_compare_twocols; 
  
  --%test( Compare cursors join by single key - key doesnt exists )
  procedure cursor_joinby_compare_nokey; 
  
  --%test( Compare cursors join by composite key - one part of key doesnt exists )
  procedure cur_joinby_comp_twocols_nokey; 
  
  --%test( Compare cursors join by single key - key doesnt is excluded )
  procedure cursor_joinby_compare_exkey; 
  
  --%test( Compare cursors join by composite key - one part of key is excluded exists )
  procedure cur_joinby_comp_twocols_exkey; 
  
  --%test( Compare cursors join by single key - key doesnt exists in expected)
  procedure cursor_joinby_comp_nokey_ex; 
  
  --%test( Compare cursors join by single key - key doesnt exists in actual)
  procedure cursor_joinby_comp_nokey_ac; 
  
  --%test( Compare cursors join by single key more than 1000 rows)
  procedure cursor_joinby_compare_1000;

  --%test( Compare cursors unorder more than 1000 rows)
  procedure cursor_unorder_compare_1000;
  
  --%test( Compare two column cursors join by and fail to match )
  procedure cursor_joinby_compare_fail;  
 
  --%test( Compare two column cursors join by two columns and fail to match )
  procedure cursor_joinby_cmp_twocol_fail;   
 
  --%test( Compare three column cursors join by two columns and fail to match )
  procedure cur_joinby_cmp_threcol_fail; 
  
  --%test(Unordered List of columns to include)
  procedure unord_incl_cols_as_list;

  --%test(Join By List of columns to include)
  procedure joinby_incl_cols_as_list;

  --%test(Unordered List of columns to exclude)
  procedure unord_excl_cols_as_list;

  --%test(Join By List of columns to exclude)
  procedure joinby_excl_cols_as_list;

  --%test(Exclude columns of different type)
  procedure excl_dif_cols_as_list;
  
  --%test(Include column of same type leaving different type out)
  procedure inlc_dif_cols_as_list;

  --%test(Include column of same type leaving different type out and exclude different type)
  procedure inlc_exc_dif_cols_as_list;
  
  --%test(Compare object type unordered)
  procedure compare_obj_typ_col_un;

  --%test(Compare object type join by)
  procedure compare_obj_typ_col_jb;
  
  --%test(Compare nested table type unordered fail)
  procedure comp_obj_typ_col_un_fail;
 
  --%test(Compare object type join by fail) 
  procedure comp_obj_typ_col_jb_fail;

  --%test(Compare object type join by multi key) 
  procedure comp_obj_typ_col_jb_multi;
 
  --%test(Compare object type join by missing nested key) 
  procedure comp_obj_typ_col_jb_nokey;

  --%test(Compare table type join by)
  procedure compare_nest_tab_col_jb;  
  
  --%test(Compare table type join by - Failure)
  procedure compare_nest_tab_col_jb_fail;

  --%test(Compare table type join by mulitple columns)  
  procedure compare_nest_tab_cols_jb;

  --%test(Compare table type join by multiple columns- Failure)  
  procedure compare_nest_tab_cols_jb_fail;
  
  --%test(Compare table type as column join by multiple columns - Cannot find match)  
  procedure compare_tabtype_as_cols_jb;

  --%test(Compare table type as column normal compare )  
  procedure compare_tabtype_as_cols;
  
  --%test(Compare table type as column join on collection element )  
  procedure compare_tabtype_as_cols_coll; 
  
  --%test(Compare same content on record with collections join on record) 
  procedure compare_rec_colltype_as_cols;
 
  --%test(Compare same content record with collection join on record attribute)  
  procedure compare_rec_colltype_as_attr;

  --%test(Compare same content record with collection join on whole collection)   
  procedure compare_collection_in_rec;
    
  --%test(Compare diffrent content record with collection join on record attribute) 
  procedure compare_rec_coll_as_cols_fl;

  --%test(Trying to join on collection element inside record )   
  procedure compare_rec_coll_as_join;
 
  --%test( Unordered fix for issues with duplicate no : #764 )   
  procedure unordered_fix_764;
 
  --%test( Success when cursor contains data from another cursor)
  procedure cursor_to_contain;
  
  --%test( Fail cursor contains data from another cursor using second keyword) 
  procedure cursor_to_contain_fail;

  --%test( Success cursor to contain cursor with unordered columns)
  procedure cursor_to_contain_uc;

  --%test( Does not fail when comparing cursor to contain cursor with unordered rows option)
  procedure cursor_to_contain_unordered;

   --%test( Cursor contains data from another cursor with joinby)
  procedure cursor_contain_joinby;

   --%test( Fail cursor contains data from another cursor with joinby)  
  procedure cursor_contain_joinby_fail; 
  
  --%test(Cursor contains data with list of columns to include)
  procedure to_contain_incl_cols_as_list;
  
  --%test(Cursor contains data with of columns to include and join by value)
  procedure to_cont_join_incl_cols_as_lst;
  
  --%test(Cursor contains data with of columns to exclude and join by value)
  procedure contain_join_excl_cols_as_lst;
 
  --%test(Cursor contains data with of columns to exclude)
  procedure contain_excl_cols_as_list;
  
  --%test( Cursor not to contains data from another cursor)   
  procedure cursor_not_to_contain;
  
  --%test( Cursor fail not to contains data from another cursor)
  procedure cursor_not_to_contain_fail;
  
  --%test( Cursor not contains data from another cursor with joinby clause)
  procedure cursor_not_to_contain_joinby;  
  
  --%test(Cursor not contains data with of columns to include and join by value)
  procedure not_cont_join_incl_cols_as_lst;
  
  --%test(Cursor not contains data with of columns to exclude and join by value)
  procedure not_cont_join_excl_cols_as_lst; 

  --%test(Cursor to contain duplicates)
  procedure to_contain_duplicates;
  
  --%test(Cursor to contain duplicates fail)
  procedure to_contain_duplicates_fail;
    
  --%test(Display a message with a uer defined type with only type name not structure on equal)
  procedure udt_messg_format_eq; 
 
  --%test(Display a message with a uer defined type with only type name not structure on empty)
  procedure udt_messg_format_empt;    
   
  --%test(Fail to process a cursor for actual)
  procedure xml_error_actual;
  
  --%test(Fail to process a cursor for expected)
  procedure xml_error_expected;
  
  --%test(Check that cursor correctly handles no length dataypes)
  procedure no_length_datatypes;
  
  --%test(Check that colon is converted properly fix #902)
  procedure colon_part_of_columnname;
  
  --%test(Check that column name accept special characters fix #902)
  procedure specialchar_part_of_colname;  
  
  --%test(Check that column name accept non xml characters fix #902)
  procedure nonxmlchar_part_of_colname;
      
  --%test(Check precision of number from dual)
  procedure number_from_dual;
  
end;
/
