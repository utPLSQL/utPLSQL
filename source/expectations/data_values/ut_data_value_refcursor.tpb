create or replace type body ut_data_value_refcursor as
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
        
  constructor function ut_data_value_refcursor(self in out nocopy ut_data_value_refcursor, a_value sys_refcursor) return self as result is
  begin
    init(a_value);
    return;
  end;

  member procedure extract_cursor(self in out nocopy ut_data_value_refcursor, a_value sys_refcursor) is
    c_bulk_rows  constant integer := 10000;
    l_cursor     sys_refcursor := a_value;
    l_ctx                 number;
    l_xml                 xmltype;
    l_ut_owner            varchar2(250) := ut_utils.ut_owner;
    l_set_id              integer := 0;
  begin
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
      exit when dbms_xmlgen.getNumRowsProcessed(l_ctx) = 0;

      self.elements_count := self.elements_count + dbms_xmlgen.getNumRowsProcessed(l_ctx);
      execute immediate
      'insert into ' || l_ut_owner || '.ut_compound_data_tmp(data_id, item_no, item_data) ' ||
      'values (:self_guid, :self_row_count, :l_xml)'
      using in self.data_id, l_set_id, l_xml;           
      l_set_id := l_set_id + c_bulk_rows;   
    end loop;
    ut_expectation_processor.reset_nls_params();
    dbms_xmlgen.closeContext(l_ctx);
  exception
    when others then
      ut_expectation_processor.reset_nls_params();
      dbms_xmlgen.closeContext(l_ctx);
      raise;
  end;

  member procedure init(self in out nocopy ut_data_value_refcursor, a_value sys_refcursor) is
    l_cursor     sys_refcursor := a_value;
    cursor_not_open       exception;
    l_cursor_number number;
  begin
    self.is_data_null := ut_utils.boolean_to_int(a_value is null);
    self.self_type := $$plsql_unit;
    self.data_id   := sys_guid();
    self.data_type := 'refcursor';
    ut_compound_data_helper.cleanup_diff;
    
    if l_cursor is not null then
        if l_cursor%isopen then
          --Get some more info regarding cursor, including if it containts collection columns and what is their name        
          self.elements_count     := 0;
          extract_cursor(l_cursor);
          l_cursor_number  := dbms_sql.to_cursor_number(l_cursor);
          self.cursor_details  := ut_cursor_details(l_cursor_number);
          dbms_sql.close_cursor(l_cursor_number);         
        elsif not l_cursor%isopen then
            raise cursor_not_open;
        end if;
    end if;
  exception
    when cursor_not_open then
        raise_application_error(-20155, 'Cursor is not open');
    when others then
      if l_cursor%isopen then
        close l_cursor;
      end if;
      raise;
  end;
 
  overriding member function to_string return varchar2 is
    l_result        clob;
    l_result_string varchar2(32767);
    l_cursor_details ut_cursor_column_tab := self.cursor_details.cursor_columns_info;
    
    l_query   varchar2(32767);
    l_column_info   xmltype;
   
  begin
    if not self.is_null() then
      dbms_lob.createtemporary(l_result, true);
      ut_utils.append_to_clob(l_result, 'Data-types:'||chr(10));
      
      l_column_info := ut_compound_data_helper.getxmlchildren(null,l_cursor_details);

      ut_utils.append_to_clob(l_result, l_column_info.getclobval());
      ut_utils.append_to_clob(l_result,chr(10)||(self as ut_compound_data_value).to_string());
      l_result_string := ut_utils.to_string(l_result,null);
      dbms_lob.freetemporary(l_result);
    end if;
    return l_result_string;
  end;

  member function diff( a_other ut_data_value, a_unordered boolean := false, a_join_by_list ut_varchar2_list:=ut_varchar2_list() ) return varchar2 is
    l_result            clob;
    l_results           ut_utils.t_clob_tab := ut_utils.t_clob_tab();
    l_result_string     varchar2(32767);
    l_actual            ut_data_value_refcursor;
    l_column_diffs      ut_compound_data_helper.tt_column_diffs := ut_compound_data_helper.tt_column_diffs();
    
    l_act_cols          ut_cursor_column_tab;
    l_exp_cols          ut_cursor_column_tab;
        
    l_missing_pk        ut_compound_data_helper.tt_missing_pk := ut_compound_data_helper.tt_missing_pk();
    l_col_diffs         ut_compound_data_helper.tt_column_diffs := ut_compound_data_helper.tt_column_diffs();
    
    c_max_rows          integer := ut_utils.gc_diff_max_rows;
    l_diff_id           ut_compound_data_helper.t_hash;
    l_diff_row_count    integer;
    l_row_diffs         ut_compound_data_helper.tt_row_diffs;
    l_message           varchar2(32767);
    
    l_column_order_enforce boolean := ut_utils.int_to_boolean(self.cursor_details.is_column_order_enforced);
    
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
      l_message varchar2(200);
    begin
      if a_missing_keys.diff_type = 'a' then
        l_message :=  '  Join key '||a_missing_keys.missingxpath||' does not exists in actual';
      elsif a_missing_keys.diff_type = 'e' then
        l_message :=    '  Join key '||a_missing_keys.missingxpath||' does not exists in expected';
      end if; 

     return l_message;
    end;
    
    function remove_incomparable_cols( a_cursor_details ut_cursor_column_tab,a_column_diffs ut_compound_data_helper.tt_column_diffs) return ut_cursor_column_tab is
      l_incomparable_cols ut_varchar2_list := ut_varchar2_list();
      l_filter_out ut_cursor_column_tab;
    begin
      for i in 1 .. a_column_diffs.count loop
        if a_column_diffs(i).diff_type in ('-','+') then
          l_incomparable_cols.extend;
          l_incomparable_cols(l_incomparable_cols.last) := coalesce(a_column_diffs(i).expected_name,a_column_diffs(i).actual_name);
        end if; 
      end loop;
      
      return ut_compound_data_helper.remove_incomparable_cols(a_cursor_details,l_incomparable_cols);
    end;
    
    function get_diff_message (a_row_diff ut_compound_data_helper.t_row_diffs,a_is_unordered boolean) return varchar2 is
    begin

      if a_is_unordered then     
        if a_row_diff.pk_value is not null then
          return  '  PK '||a_row_diff.pk_value||' - '||rpad(a_row_diff.diff_type,10)||a_row_diff.diffed_row;
        else
          return rpad(a_row_diff.diff_type,10)||a_row_diff.diffed_row;
        end if;
      else
        return '  Row No. '||a_row_diff.rn||' - '||rpad(a_row_diff.diff_type,10)||a_row_diff.diffed_row;
      end if; 
    end;
  
  begin
    if not a_other is of (ut_data_value_refcursor) then
      raise value_error;
    end if;
    l_actual := treat(a_other as ut_data_value_refcursor);

    l_act_cols  := l_actual.cursor_details.cursor_columns_info;
    l_exp_cols  := self.cursor_details.cursor_columns_info;

    dbms_lob.createtemporary(l_result,true);
    --diff columns
    if not self.is_null and not l_actual.is_null then
      l_column_diffs := ut_compound_data_helper.get_columns_diff(self.cursor_details.cursor_columns_info,l_actual.cursor_details.cursor_columns_info,l_column_order_enforce);
    
      if l_column_diffs.count > 0 then
        ut_utils.append_to_clob(l_result,chr(10) || 'Columns:' || chr(10));
      end if;
      for i in 1 .. l_column_diffs.count loop
        l_results.extend;
        l_results(l_results.last) := get_col_diff_text(l_column_diffs(i));
      end loop;
      ut_utils.append_to_clob(l_result, l_results);
      l_act_cols  := remove_incomparable_cols(l_actual.cursor_details.cursor_columns_info,l_column_diffs);
      l_exp_cols  := remove_incomparable_cols(self.cursor_details.cursor_columns_info,l_column_diffs);
    end if;
    
    --check for missing pk 
    if a_join_by_list.count > 0 then
      l_missing_pk := ut_compound_data_helper.get_missing_pk(l_exp_cols,l_act_cols,a_join_by_list);
    end if;
    
    --diff rows and row elements if the pk is not missing 
    if l_missing_pk.count = 0 then
    l_diff_id := ut_compound_data_helper.get_hash(self.data_id||l_actual.data_id);

    -- First tell how many rows are different
    l_diff_row_count := ut_compound_data_helper.get_rows_diff_count; 
    l_results := ut_utils.t_clob_tab();
      if l_diff_row_count > 0  then
        l_row_diffs := ut_compound_data_helper.get_rows_diff_by_sql(
              l_exp_cols,l_act_cols, self.data_id, l_actual.data_id, l_diff_id,a_join_by_list , a_unordered, l_column_order_enforce);
        l_message := chr(10)
                     ||'Rows: [ ' || l_diff_row_count ||' differences'
                     ||  case when  l_diff_row_count > c_max_rows and l_row_diffs.count > 0 then ', showing first '||c_max_rows end
                     ||' ]'||chr(10)|| case when l_row_diffs.count = 0 then '  All rows are different as the columns are not matching.' else null end;
        ut_utils.append_to_clob( l_result, l_message );
        for i in 1 .. l_row_diffs.count loop
          l_results.extend;
          l_results(l_results.last) := get_diff_message(l_row_diffs(i),a_unordered);
        end loop;
        ut_utils.append_to_clob(l_result,l_results);
      else
        l_message:= chr(10)||'Rows: [  all different ]'||chr(10)||'  All rows are different as the columns position is not matching.';
        ut_utils.append_to_clob( l_result, l_message );
      end if;   
    else
        ut_utils.append_to_clob(l_result,chr(10) || 'Unable to join sets:' || chr(10));
        for i in 1 .. l_missing_pk.count loop
          l_results.extend;
          ut_utils.append_to_clob(l_result, get_missing_key_message(l_missing_pk(i))|| chr(10));
        end loop;
        
        if ut_compound_data_helper.contains_collection(self.cursor_details.cursor_columns_info) > 0 
           or ut_compound_data_helper.contains_collection(l_actual.cursor_details.cursor_columns_info) > 0 then
          ut_utils.append_to_clob(l_result,'  Please make sure that your join clause is not refferring to collection element'|| chr(10));
        end if;
        
    end if;
    
    l_result_string := ut_utils.to_string(l_result,null);
    dbms_lob.freetemporary(l_result);
    return l_result_string;
  end;

  overriding member function compare_implementation(a_other ut_data_value, a_unordered boolean, a_inclusion_compare boolean := false, a_is_negated boolean := false, 
                                         a_join_by_list ut_varchar2_list:=ut_varchar2_list()) return integer is
    l_result          integer := 0;
    l_actual          ut_data_value_refcursor;
    l_pk_missing_tab ut_compound_data_helper.tt_missing_pk;
    
  begin
    if not a_other is of (ut_data_value_refcursor) then
      raise value_error;
    end if;
  
    l_actual   := treat(a_other as ut_data_value_refcursor);
     
    if a_join_by_list.count > 0 then
      l_pk_missing_tab := ut_compound_data_helper.get_missing_pk(self.cursor_details.cursor_columns_info,l_actual.cursor_details.cursor_columns_info,a_join_by_list);
      l_result := case when (l_pk_missing_tab.count > 0) then 1 else 0 end;
    end if;
        
    if l_result = 0 then  
      if (self.cursor_details is not null and l_actual.cursor_details is not null) and (self.cursor_details != l_actual.cursor_details) then 
        l_result := 1; 
      end if;
      l_result := l_result + (self as ut_compound_data_value).compare_implementation(a_other,a_unordered, a_inclusion_compare, 
                              a_is_negated, a_join_by_list); 
    end if;
    
    return l_result;
  end;

  overriding member function is_empty return boolean is
  begin
    return self.elements_count = 0;
  end;

  member function update_cursor_details (a_exclude_xpath ut_varchar2_list, a_include_xpath ut_varchar2_list,a_ordered_columns boolean := false) return ut_data_value_refcursor is
    l_result ut_data_value_refcursor := self;
  begin   
    if l_result.cursor_details.cursor_columns_info is not null then
      l_result.cursor_details.cursor_columns_info := ut_compound_data_helper.inc_exc_columns_from_cursor(l_result.cursor_details.cursor_columns_info,a_exclude_xpath,a_include_xpath);
      l_result.cursor_details.ordered_columns(a_ordered_columns);
    end if;    
    return l_result;
  end;

end;
/
