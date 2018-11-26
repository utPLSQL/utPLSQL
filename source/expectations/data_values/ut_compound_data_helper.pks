create or replace package ut_compound_data_helper authid definer is
  /*
  utPLSQL - Version 3
  Copyright 2016 - 2018 utPLSQL Project

  Licensed under the Apache License, Version 2.0 (the "License"):
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
  */

  gc_compare_unordered constant varchar2(10):='unordered';
  gc_compare_normal    constant varchar2(10):='normal';
  
  type t_column_diffs is record(
    diff_type     varchar2(1),
    expected_name varchar2(250),
    expected_type varchar2(250),
    expected_pos  integer,
    actual_name   varchar2(250),
    actual_type   varchar2(250),
    actual_pos    integer
  );

  type tt_column_diffs is table of t_column_diffs;

  type t_missing_pk is record(
    missingxpath  varchar2(250),
    diff_type     varchar2(1)
  );

  type tt_missing_pk is table of t_missing_pk;
  
  type t_row_diffs is record(
    rn            integer,
    diff_type     varchar2(250),
    diffed_row    clob,
    pk_value      varchar2(4000)
  );

  type tt_row_diffs is table of t_row_diffs;

  type t_diff_rec is record (
    act_item_data xmltype, 
    act_data_id raw(32), 
    exp_item_data xmltype, 
    exp_data_id raw(32),
    item_no   number,
    dup_no    number
    );
    
  type t_diff_tab is table of t_diff_rec;
    
  function get_columns_filter(
    a_exclude_xpath varchar2, a_include_xpath varchar2,
    a_table_alias varchar2 := 'ucd', a_column_alias varchar2 := 'item_data'
  ) return varchar2;

  function get_columns_diff(a_expected ut_cursor_column_tab, a_actual ut_cursor_column_tab) 
  return tt_column_diffs;

 function get_pk_value (a_join_by_xpath varchar2,a_item_data xmltype) return clob;

 function get_rows_diff(
    a_expected_dataset_guid raw, a_actual_dataset_guid raw, a_diff_id raw,
    a_max_rows integer, a_exclude_xpath varchar2, a_include_xpath varchar2
    ) return tt_row_diffs;

  function get_rows_diff_by_sql(a_act_cursor_info ut_cursor_column_tab,a_exp_cursor_info ut_cursor_column_tab, 
    a_expected_dataset_guid raw, a_actual_dataset_guid raw, a_diff_id raw,
    a_join_by_list ut_varchar2_list, a_unordered boolean
  ) return tt_row_diffs;

  subtype t_hash  is raw(128);

  function get_hash(a_data raw, a_hash_type binary_integer := dbms_crypto.hash_sh1)  return t_hash;
  function get_hash(a_data clob, a_hash_type binary_integer := dbms_crypto.hash_sh1) return t_hash;
  
  function get_fixed_size_hash(a_string varchar2, a_base integer :=0,a_size integer :=30) return number;
                     
  function gen_compare_sql(a_inclusion_type boolean, a_is_negated boolean, a_unordered boolean, 
    a_other ut_data_value_refcursor :=null, a_join_by_list ut_varchar2_list:=ut_varchar2_list() ) return clob;
 
  procedure insert_diffs_result(a_diff_tab t_diff_tab, a_diff_id raw);
  
  procedure set_rows_diff(a_rows_diff integer);
  
  procedure cleanup_diff;
  
  function get_rows_diff_count return integer;
   
  function filter_out_cols(a_cursor_info ut_cursor_column_tab, a_current_list ut_varchar2_list,a_include boolean := true) 
  return ut_cursor_column_tab;
   
  function compare_cursor_to_columns(a_cursor_info ut_cursor_column_tab, a_current_list ut_varchar2_list) 
  return ut_varchar2_list;

  function get_missing_pk(a_expected ut_cursor_column_tab, a_actual ut_cursor_column_tab, a_current_list ut_varchar2_list) 
  return tt_missing_pk;
  
  function validate_attributes(a_cursor_info ut_cursor_column_tab, a_filter_list ut_varchar2_list) return ut_varchar2_list;
  
  function inc_exc_columns_from_cursor (a_cursor_info ut_cursor_column_tab, a_exclude_xpath ut_varchar2_list, a_include_xpath ut_varchar2_list)  
  return ut_cursor_column_tab;
  
  function contains_collection (a_cursor_info ut_cursor_column_tab) return number;
  
  function remove_incomparable_cols( a_cursor_details ut_cursor_column_tab,a_incomparable_cols ut_varchar2_list) return ut_cursor_column_tab;
  
  function generate_missing_cols_warn_msg(a_missing_columns ut_varchar2_list,a_attribute in varchar2) return varchar2;
  
  function getxmlchildren(p_parent_name varchar2,a_cursor_table ut_cursor_column_tab) return xmltype;

  function is_sql_compare_allowed(a_type_name varchar2) return boolean;
  
  function is_collection (a_owner varchar2,a_type_name varchar2, a_anytype_code in integer :=null) return boolean;

  function get_column_type_desc(a_type_code in integer, a_dbms_sql_desc in boolean) return varchar2;
  
end;
/
