create or replace type body ut_data_value_refcursor as
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
        
  constructor function ut_data_value_refcursor(self in out nocopy ut_data_value_refcursor, a_value sys_refcursor) return self as result is
  begin
    init(a_value);
    return;
  end;

  member procedure init(self in out nocopy ut_data_value_refcursor, a_value sys_refcursor) is
    c_bulk_rows  constant integer := 1000;
    l_cursor     sys_refcursor := a_value;
    l_ctx                 number;
    l_xml                 xmltype;
    l_current_date_format varchar2(4000);
    cursor_not_open       exception;
    l_ut_owner            varchar2(250) := ut_utils.ut_owner;
  begin
    self.is_data_null := ut_utils.boolean_to_int(a_value is null);
    self.self_type := $$plsql_unit;
    self.data_id   := sys_guid();
    self.data_type := 'refcursor';
    if l_cursor is not null then
        if l_cursor%isopen then
          self.columns_info   := ut_curr_usr_compound_helper.get_columns_info(l_cursor);
          self.key_info       := ut_curr_usr_compound_helper.get_columns_info(l_cursor,true);
          self.elements_count     := 0;
          -- We use DBMS_XMLGEN in order to:
          -- 1) be able to process data in bulks (set of rows)
          -- 2) be able to influence the ROWSET/ROW tags
          -- 3) be able to influence the way NULL values are handled (empty TAG)
          -- 4) be able to influence the way TIMESTAMP is formatted.
          -- Due to Oracle feature/bug, it is not possible to change the DATE formatting of cursor data
          -- AFTER the cursor was opened.
          -- The only solution for this is to change NLS settings before opening the cursor.
          --
          -- This would work fine if we could use DBMS_XMLGEN.restartQuery.
          --  The restartQuery fails however if PLSQL variables of TIMESTAMP/INTERVAL or CLOB/BLOB are used.

          ut_expectation_processor.set_xml_nls_params();
          l_ctx := dbms_xmlgen.newContext(l_cursor);
          dbms_xmlgen.setNullHandling(l_ctx, dbms_xmlgen.empty_tag);
          dbms_xmlgen.setMaxRows(l_ctx, c_bulk_rows);

          loop
            l_xml := dbms_xmlgen.getxmltype(l_ctx);
           
           execute immediate
              'insert into ' || l_ut_owner || '.ut_compound_data_tmp(data_id, item_no, item_data) ' ||
              'select :self_guid, :self_row_count + rownum, value(a) ' ||
              '  from table( xmlsequence( extract(:l_xml,''ROWSET/*'') ) ) a'
              using in self.data_id, self.elements_count, l_xml;

            exit when sql%rowcount = 0;

            self.elements_count := self.elements_count + sql%rowcount;
          end loop;
          
          ut_expectation_processor.reset_nls_params();
          if l_cursor%isopen then
            close l_cursor;
          end if;
          dbms_xmlgen.closeContext(l_ctx);

        elsif not l_cursor%isopen then
            raise cursor_not_open;
        end if;
    end if;
  exception
    when cursor_not_open then
        raise_application_error(-20155, 'Cursor is not open');
    when others then
      ut_expectation_processor.reset_nls_params();
      if l_cursor%isopen then
        close l_cursor;
      end if;
      dbms_xmlgen.closeContext(l_ctx);
      raise;
  end;

  overriding member function to_string return varchar2 is
    l_result        clob;
    l_result_string varchar2(32767);
  begin
    if not self.is_null() then
      dbms_lob.createtemporary(l_result, true);
      ut_utils.append_to_clob(l_result, 'Data-types:'||chr(10));
      ut_utils.append_to_clob(l_result, self.columns_info.getclobval());

      ut_utils.append_to_clob(l_result,chr(10)||(self as ut_compound_data_value).to_string());
      l_result_string := ut_utils.to_string(l_result,null);
      dbms_lob.freetemporary(l_result);
    end if;
    return l_result_string;
  end;

  overriding member function diff( a_other ut_data_value, a_exclude_xpath varchar2, a_include_xpath varchar2, a_join_by_xpath varchar2, a_unordered boolean := false ) return varchar2 is
    l_result            clob;
    l_results           ut_utils.t_clob_tab := ut_utils.t_clob_tab();
    l_result_string     varchar2(32767);
    l_actual            ut_data_value_refcursor;
    l_column_diffs      ut_compound_data_helper.tt_column_diffs := ut_compound_data_helper.tt_column_diffs();
    l_exclude_xpath     varchar2(32767) := a_exclude_xpath;
    l_missing_pk        ut_compound_data_helper.tt_missing_pk := ut_compound_data_helper.tt_missing_pk();
    
    function get_col_diff_text(a_col ut_compound_data_helper.t_column_diffs) return varchar2 is
    begin
      return
        case a_col.diff_type
          when '-' then
            '  Column <'||a_col.expected_name||'> [data-type: '||a_col.expected_type||'] is missing. Expected column position: '||a_col.expected_pos||'.'
          when '+' then
            '  Column <'||a_col.actual_name||'> [position: '||a_col.actual_pos||', data-type: '||a_col.actual_type||'] is not expected in results.'
          when 't' then
            '  Column <'||a_col.actual_name||'> data-type is invalid. Expected: '||a_col.expected_type||',' ||' actual: '||a_col.actual_type||'.'
          when 'p' then
            '  Column <'||a_col.actual_name||'> is misplaced. Expected position: '||a_col.expected_pos||',' ||' actual position: '||a_col.actual_pos||'.'
        end;
    end;
    
    function get_missing_key_message(a_missing_keys ut_compound_data_helper.t_missing_pk) return varchar2 is
    begin
     return
       case a_missing_keys.diff_type
         when 'a' then
           '  Join key '||a_missing_keys.missingxpath||' does not exists in actual'
         when 'e' then
           '  Join key '||a_missing_keys.missingxpath||' does not exists in expected'
      end; 
    end;
    
    function add_incomparable_cols_to_xpath(
      a_column_diffs ut_compound_data_helper.tt_column_diffs, a_exclude_xpath varchar2
    ) return varchar2 is
      l_incomparable_cols ut_varchar2_list := ut_varchar2_list();
      l_result            varchar2(32767);
    begin
      for i in 1 .. a_column_diffs.count loop
        if a_column_diffs(i).diff_type in ('-','+') then
          l_incomparable_cols.extend;
          l_incomparable_cols(l_incomparable_cols.last) := ut_utils.xmlgen_escaped_string(coalesce(a_column_diffs(i).expected_name,a_column_diffs(i).actual_name));
        end if;
      end loop;
      l_result := ut_utils.to_xpath(l_incomparable_cols);
      if a_exclude_xpath is not null and l_result is not null then
        l_result := l_result ||'|'||a_exclude_xpath;
      else
        l_result := coalesce(a_exclude_xpath, l_result);
      end if;
      return l_result;
    end;
    
  begin
    if not a_other is of (ut_data_value_refcursor) then
      raise value_error;
    end if;
    l_actual := treat(a_other as ut_data_value_refcursor);

    dbms_lob.createtemporary(l_result,true);

    --diff columns
    if not self.is_null and not l_actual.is_null then
      l_column_diffs := ut_compound_data_helper.get_columns_diff(self.columns_info, l_actual.columns_info, a_exclude_xpath, a_include_xpath);

      if l_column_diffs.count > 0 then
        ut_utils.append_to_clob(l_result,chr(10) || 'Columns:' || chr(10));
      end if;

      for i in 1 .. l_column_diffs.count loop
        l_results.extend;
        l_results(l_results.last) := get_col_diff_text(l_column_diffs(i));
      end loop;
      ut_utils.append_to_clob(l_result, l_results);
      l_exclude_xpath := add_incomparable_cols_to_xpath(l_column_diffs, a_exclude_xpath);
    end if;
    
    --check for missing pk 
    if (a_join_by_xpath is not null) then
      l_missing_pk := ut_compound_data_helper.is_pk_exists(self.key_info, l_actual.key_info, a_exclude_xpath, a_include_xpath,a_join_by_xpath);
    end if;
    
    --diff rows and row elements if the pk is not missing 
    if l_missing_pk.count = 0 then
        ut_utils.append_to_clob(l_result, self.get_data_diff(a_other, a_exclude_xpath, a_include_xpath, a_join_by_xpath, a_unordered));    
    else
        ut_utils.append_to_clob(l_result,chr(10) || 'Unable to join sets:' || chr(10));
        for i in 1 .. l_missing_pk.count loop
          l_results.extend;
          ut_utils.append_to_clob(l_result, get_missing_key_message(l_missing_pk(i))|| chr(10));
        end loop;    
    end if;
    
    l_result_string := ut_utils.to_string(l_result,null);
    dbms_lob.freetemporary(l_result);
    return l_result_string;
  end;

  overriding member function compare_implementation (a_other ut_data_value, a_exclude_xpath varchar2, a_include_xpath varchar2, a_join_by_xpath varchar2, a_unordered boolean) return integer is
    l_result          integer := 0;
    l_other           ut_data_value_refcursor;
    function is_pk_missing (a_pk_missing_tab ut_compound_data_helper.tt_missing_pk) return integer is
    begin
      return case when a_pk_missing_tab.count > 0 then 1 else 0 end;
    end;
  begin
    if not a_other is of (ut_data_value_refcursor) then
      raise value_error;
    end if;

    l_other   := treat(a_other as ut_data_value_refcursor);
    
    --if we join by key and key is missing fail and report error
    if a_join_by_xpath is not null then 
      l_result := is_pk_missing(ut_compound_data_helper.is_pk_exists(self.key_info, l_other.key_info, a_exclude_xpath, a_include_xpath,a_join_by_xpath));
    end if;
    
    if l_result = 0 then
      --if column names/types are not equal - build a diff of column names and types
      if ut_compound_data_helper.columns_hash( self, a_exclude_xpath, a_include_xpath )
         != ut_compound_data_helper.columns_hash( l_other, a_exclude_xpath, a_include_xpath )
      then
        l_result := 1;
      end if;
    
      if a_unordered then
        l_result := l_result + (self as ut_compound_data_value).compare_implementation(a_other, a_exclude_xpath, a_include_xpath, a_join_by_xpath, a_unordered);
      else
        l_result := l_result + (self as ut_compound_data_value).compare_implementation(a_other, a_exclude_xpath, a_include_xpath);
      end if;
    end if;
    
    return l_result;
  end;


end;
/
