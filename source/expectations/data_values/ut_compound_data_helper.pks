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
  
  gc_json_missing  constant varchar2(30) :=  'missing properties';
  gc_json_type     constant varchar2(30) :=  'incorrect types';
  gc_json_notequal constant varchar2(30) :=  'unequal values';
  gc_json_unknown  constant varchar2(30) :=  'unknown';
  
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
  
  type t_json_diff_rec is record (
    difference_type       varchar2(50),
    act_element_name      varchar2(4000),
    act_element_value     varchar2(4000),
    act_json_type         varchar2(4000),
    exp_element_name      varchar2(4000),
    exp_element_value     varchar2(4000),
    exp_json_type         varchar2(4000)
  );
  
  type tt_json_diff_tab is table of t_json_diff_rec;          
  
  type t_json_diff_type_rec is record (
    difference_type   varchar2(50),
    no_of_occurence   integer
  );
    
  type tt_json_diff_type_tab is table of t_json_diff_type_rec; 
  
  function get_columns_diff(
    a_expected ut_cursor_column_tab, a_actual ut_cursor_column_tab,a_order_enforced boolean := false
  ) return tt_column_diffs;

  function get_rows_diff_by_sql(
    a_act_cursor_info ut_cursor_column_tab,a_exp_cursor_info ut_cursor_column_tab,
    a_expected_dataset_guid raw, a_actual_dataset_guid raw, a_diff_id raw,
    a_join_by_list ut_varchar2_list, a_unordered boolean, a_enforce_column_order boolean := false,
    a_extract_path varchar2
  ) return tt_row_diffs;

  subtype t_hash  is raw(128);

  function get_hash(a_data raw, a_hash_type binary_integer := dbms_crypto.hash_sh1)  return t_hash;

  function get_hash(a_data clob, a_hash_type binary_integer := dbms_crypto.hash_sh1) return t_hash;
  
  function get_fixed_size_hash(a_string varchar2, a_base integer :=0,a_size integer :=9999999) return number;
                     
  function gen_compare_sql(
    a_other ut_data_value_refcursor,
    a_join_by_list ut_varchar2_list,
    a_unordered boolean,
    a_inclusion_type boolean,
    a_is_negated boolean
  ) return clob;
 
  procedure insert_diffs_result(a_diff_tab t_diff_tab, a_diff_id raw);
  
  procedure set_rows_diff(a_rows_diff integer);
  
  procedure cleanup_diff;
  
  function get_rows_diff_count return integer;

  function is_sql_compare_allowed(a_type_name varchar2) return boolean;
  
  function get_column_type_desc(a_type_code in integer, a_dbms_sql_desc in boolean) return varchar2;
  
  function get_compare_cursor(a_diff_cursor_text in clob,a_self_id raw, a_other_id raw) return sys_refcursor;
  
  function create_err_cursor_msg(a_error_stack varchar2) return varchar2;
  
  /*
  * Function to return true or false if the type dont have an length
  */
  function type_no_length ( a_type_name varchar2) return boolean;
  
  function get_json_diffs(a_act_json_data ut_json_leaf_tab,a_exp_json_data ut_json_leaf_tab) return tt_json_diff_tab;
  
  function get_json_diffs_type(a_diffs_all tt_json_diff_tab) return tt_json_diff_type_tab;
  
end;
/
