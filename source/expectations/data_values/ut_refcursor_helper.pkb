create or replace package body ut_refcursor_helper is
  /*
  utPLSQL - Version 3
  Copyright 2016 - 2017 utPLSQL Project

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

  type t_type_name_map is table of varchar2(100) index by binary_integer;
  g_type_name_map t_type_name_map;

  function get_column_type(a_desc_rec dbms_sql.desc_rec3) return varchar2 is
    l_result varchar2(500) := 'unknown datatype';
    begin
      if g_type_name_map.exists(a_desc_rec.col_type) then
        l_result := g_type_name_map(a_desc_rec.col_type);
      elsif a_desc_rec.col_schema_name is not null and a_desc_rec.col_type_name is not null then
        l_result := a_desc_rec.col_schema_name||'.'||a_desc_rec.col_type_name;
      end if;
      return l_result;
    end;

  function get_columns_info(l_columns_tab dbms_sql.desc_tab3, l_columns_count integer) return ut_key_value_pairs is
    l_result ut_key_value_pairs := ut_key_value_pairs();
    begin
      for i in 1 .. l_columns_count loop
        l_result.extend;
        l_result(l_result.last) := ut_key_value_pair(l_columns_tab(i).col_name, get_column_type(l_columns_tab(i)));
      end loop;
      return l_result;
    end;

  function get_columns_info(a_cursor in out nocopy sys_refcursor) return xmltype is
    l_cursor_number  integer;
    l_columns_count  pls_integer;
    l_columns_desc   dbms_sql.desc_tab3;
    l_result         xmltype;
    l_columns_tab    ut_key_value_pairs;
    begin
      if a_cursor is null or not a_cursor%isopen then
        return null;
      end if;
      l_cursor_number := dbms_sql.to_cursor_number( a_cursor );
      dbms_sql.describe_columns3( l_cursor_number, l_columns_count, l_columns_desc );
      a_cursor := dbms_sql.to_refcursor( l_cursor_number );
      l_columns_tab := get_columns_info( l_columns_desc, l_columns_count);

      select XMLELEMENT("ROW", xmlagg(xmlelement(evalname key, value))) into l_result from table(l_columns_tab );

      return l_result;
    end;

  function get_columns_filter(
    a_exclude_xpath varchar2, a_include_xpath varchar2,
    a_table_alias varchar2 := 'ucd', a_column_alias varchar2 := 'item_data'
  ) return varchar2 is
    l_filter varchar2(32767);
    l_source_column varchar2(500) := a_table_alias||'.'||a_column_alias;
  begin
    -- this SQL statement is constructed in a way that we always get the same number and ordering of substitution variables
    -- That is, we always get: l_exclude_xpath, l_include_xpath
    --   regardless if the variables are NULL (not to be used) or NOT NULL and will be used for filtering
    if a_exclude_xpath is null and a_include_xpath is null then
      l_filter := ':l_exclude_xpath, :l_include_xpath, '||l_source_column||' as '||a_column_alias;
    elsif a_exclude_xpath is not null and a_include_xpath is null then
      l_filter := 'deletexml( '||l_source_column||', :l_exclude_xpath ) as '||a_column_alias||', :l_include_xpath';
    elsif a_exclude_xpath is null and a_include_xpath is not null then
      l_filter := ':l_exclude_xpath, extract( '||l_source_column||', :l_include_xpath ) as '||a_column_alias;
    elsif a_exclude_xpath is not null and a_include_xpath is not null then
      l_filter := 'extract( deletexml( '||l_source_column||', :l_exclude_xpath ), :l_include_xpath ) as '||a_column_alias;
    end if;
    return l_filter;
  end;

begin
  g_type_name_map( dbms_sql.binary_bouble_type )           := 'BINARY_DOUBLE';
  g_type_name_map( dbms_sql.bfile_type )                   := 'BFILE';
  g_type_name_map( dbms_sql.binary_float_type )            := 'BINARY_FLOAT';
  g_type_name_map( dbms_sql.blob_type )                    := 'BLOB';
  g_type_name_map( dbms_sql.long_raw_type )                := 'LONG RAW';
  g_type_name_map( dbms_sql.char_type )                    := 'CHAR';
  g_type_name_map( dbms_sql.clob_type )                    := 'CLOB';
  g_type_name_map( dbms_sql.long_type )                    := 'LONG';
  g_type_name_map( dbms_sql.date_type )                    := 'DATE';
  g_type_name_map( dbms_sql.interval_day_to_second_type )  := 'INTERVAL DAY TO SECOND';
  g_type_name_map( dbms_sql.interval_year_to_month_type )  := 'INTERVAL YEAR TO MONTH';
  g_type_name_map( dbms_sql.raw_type )                     := 'RAW';
  g_type_name_map( dbms_sql.timestamp_type )               := 'TIMESTAMP';
  g_type_name_map( dbms_sql.timestamp_with_tz_type )       := 'TIMESTAMP WITH TIME ZONE';
  g_type_name_map( dbms_sql.timestamp_with_local_tz_type ) := 'TIMESTAMP WITH LOCAL TIME ZONE';
  g_type_name_map( dbms_sql.varchar2_type )                := 'VARCHAR2';
  g_type_name_map( dbms_sql.number_type )                  := 'NUMBER';
  g_type_name_map( dbms_sql.rowid_type )                   := 'ROWID';
  g_type_name_map( dbms_sql.urowid_type )                  := 'UROWID';
end;
/