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

  gc_compare_join_by   constant varchar2(10):='join_by';
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

  function get_column_info_xml(a_column_details ut_key_anyval_pair) return xmltype;

  function get_columns_filter(
    a_exclude_xpath varchar2, a_include_xpath varchar2,
    a_table_alias varchar2 := 'ucd', a_column_alias varchar2 := 'item_data'
  ) return varchar2;

  function get_columns_diff(
    a_expected xmltype, a_actual xmltype, a_exclude_xpath varchar2, a_include_xpath varchar2
  ) return tt_column_diffs;

 function get_pk_value (a_join_by_xpath varchar2,a_item_data xmltype) return clob;

 function compare_type(a_join_by_xpath in varchar2,a_unordered boolean) return varchar2;

 function get_rows_diff(
    a_expected_dataset_guid raw, a_actual_dataset_guid raw, a_diff_id raw,
    a_max_rows integer, a_exclude_xpath varchar2, a_include_xpath varchar2,
    a_join_by_xpath varchar2,a_unorderdered boolean
  ) return tt_row_diffs;

  subtype t_hash  is raw(128);

  function get_hash(a_data raw, a_hash_type binary_integer := dbms_crypto.hash_sh1)  return t_hash;
  function get_hash(a_data clob, a_hash_type binary_integer := dbms_crypto.hash_sh1) return t_hash;
  function columns_hash(
    a_data_value_cursor ut_data_value_refcursor, a_exclude_xpath varchar2, a_include_xpath varchar2,
    a_hash_type binary_integer := dbms_crypto.hash_sh1
  ) return t_hash;
  
  function is_pk_exists(a_expected_cursor xmltype, a_actual_cursor xmltype, a_exclude_xpath varchar2, a_include_xpath varchar2,a_join_by_xpath varchar2) 
  return tt_missing_pk;

  function get_refcursor_matcher_sql(a_owner in varchar2,a_inclusion_matcher boolean := false, a_negated_match boolean := false) return varchar2;

end;
/
