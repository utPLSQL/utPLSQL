create or replace type body ut_data_value_refcursor as
  /*
  utPLSQL - Version 3
  Copyright 2016 - 2019 utPLSQL Project

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
          
  constructor function ut_data_value_refcursor(self in out nocopy ut_data_value_refcursor, a_value sys_refcursor)
  return self as result is
  begin
    init(a_value);
    return;
  end;

  member procedure extract_cursor(self in out nocopy ut_data_value_refcursor, a_value sys_refcursor) 
  is
    c_bulk_rows  constant integer := 10000;
    l_cursor     sys_refcursor := a_value;
    l_ctx        number;
    l_xml        xmltype;
    l_ut_owner   varchar2(250) := ut_utils.ut_owner;
    l_set_id     integer := 0;
    l_elements_count number := 0;
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
      --Bug in oracle 12.2+ where XML binary storage trimming insignificant whitespaces.
      $if dbms_db_version.version = 12 and dbms_db_version.release >= 2 or dbms_db_version.version > 12 $then
        l_xml := xmltype( replace(l_xml.getClobVal(),'<ROWSET','<ROWSET xml:space=''preserve'''));
      $else
        null;
      $end
      l_elements_count := l_elements_count + dbms_xmlgen.getNumRowsProcessed(l_ctx);
      ut_compound_data_helper.save_cursor_data_for_diff( self.data_id, l_set_id, l_xml );
      l_set_id := l_set_id + c_bulk_rows;   
    end loop;
   
    ut_expectation_processor.reset_nls_params();
    dbms_xmlgen.closeContext(l_ctx);
    self.elements_count := l_elements_count;
  exception
    when others then
      ut_expectation_processor.reset_nls_params();
      dbms_xmlgen.closeContext(l_ctx);
      raise;
  end;

  member procedure init(self in out nocopy ut_data_value_refcursor, a_value sys_refcursor) is
    l_cursor        sys_refcursor := a_value;
    cursor_not_open exception;
    l_cursor_number number;
  begin
    self.is_data_null := ut_utils.boolean_to_int(l_cursor is null);
    self.self_type := $$plsql_unit;
    self.data_id   := sys_guid();
    self.data_type := 'refcursor';
    self.compound_type := 'refcursor';
    self.extract_path := '/*';
    ut_compound_data_helper.cleanup_diff;
    self.cursor_details := ut_cursor_details();

    if l_cursor is not null then
        if l_cursor%isopen then
          --Get some more info regarding cursor, including if it containts collection columns and what is their name        
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
    when ut_utils.ex_xml_processing then
      if l_cursor%isopen then
        close l_cursor;
      end if;
        raise_application_error(ut_utils.gc_failed_open_cur,
          ut_compound_data_helper.create_err_cursor_msg(dbms_utility.format_call_stack()));
    when others then
      if l_cursor%isopen then
        close l_cursor;
      end if;
      raise;
  end;
 
  overriding member function to_string return varchar2 is
    l_result        clob;
    l_result_string varchar2(32767);
  begin
    if not self.is_null() then
      dbms_lob.createtemporary(l_result, true);
      ut_utils.append_to_clob(l_result, 'Data-types:'||chr(10));

      if self.cursor_details.cursor_columns_info.count > 0 then
        ut_utils.append_to_clob( l_result, self.cursor_details.get_xml_children().getclobval() );
      end if;
      ut_utils.append_to_clob(l_result,chr(10)||(self as ut_compound_data_value).to_string());
      l_result_string := ut_utils.to_string(l_result,null);
      dbms_lob.freetemporary(l_result);
    end if;
    return l_result_string;
  end;

  overriding member function diff( a_other ut_data_value, a_match_options ut_matcher_options ) return varchar2 is
    l_result            clob;
    l_results           ut_utils.t_clob_tab := ut_utils.t_clob_tab();
    l_result_string     varchar2(32767);
    l_other             ut_data_value_refcursor;
    l_self              ut_data_value_refcursor := self;
    l_column_diffs      ut_compound_data_helper.tt_column_diffs;
    
    l_other_cols        ut_cursor_column_tab;
    l_self_cols         ut_cursor_column_tab;
        
    l_act_missing_pk    ut_varchar2_list := ut_varchar2_list();
    l_exp_missing_pk    ut_varchar2_list := ut_varchar2_list();

    c_max_rows          integer := ut_utils.gc_diff_max_rows;
    l_diff_id           ut_utils.t_hash;
    l_diff_row_count    integer;
    l_row_diffs         ut_compound_data_helper.tt_row_diffs;
    l_message           varchar2(32767);
    
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

    function remove_incomparable_cols(
      a_cursor_details ut_cursor_column_tab, a_column_diffs ut_compound_data_helper.tt_column_diffs
    ) return ut_cursor_column_tab is
      l_missing_cols ut_varchar2_list := ut_varchar2_list();
      l_result       ut_cursor_column_tab;
    begin
      for i in 1 .. a_column_diffs.count loop
        if a_column_diffs(i).diff_type in ('-','+') then
          l_missing_cols.extend;
          l_missing_cols(l_missing_cols.last) := coalesce(a_column_diffs(i).expected_name, a_column_diffs(i).actual_name);
          end if;
      end loop;
      select value(i) bulk collect into l_result
        from table(a_cursor_details) i
       where i.access_path not in (
         select c.column_value
           from table(l_missing_cols) c
         );
      return l_result;
    end;
    
    function get_diff_message (a_row_diff ut_compound_data_helper.t_row_diffs, a_is_unordered boolean) return varchar2 is
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
    l_other := treat(a_other as ut_data_value_refcursor);
    l_other.cursor_details.filter_columns(a_match_options);
    l_self.cursor_details.filter_columns(a_match_options);

    l_other_cols := l_other.cursor_details.cursor_columns_info;
    l_self_cols  := l_self.cursor_details.cursor_columns_info;

    dbms_lob.createtemporary(l_result,true);
    --diff columns
    if not l_self.is_null and not l_other.is_null then
      l_column_diffs := ut_compound_data_helper.get_columns_diff(
        l_self.cursor_details.cursor_columns_info,
        l_other.cursor_details.cursor_columns_info,
        a_match_options.ordered_columns()
      );
    
      if l_column_diffs is not empty then
        ut_utils.append_to_clob(l_result,chr(10) || 'Columns:' || chr(10));
        l_other_cols := remove_incomparable_cols( l_other_cols, l_column_diffs );
        l_self_cols  := remove_incomparable_cols( l_self_cols, l_column_diffs );
        for i in 1 .. l_column_diffs.count loop
          l_results.extend;
          l_results(l_results.last) := get_col_diff_text(l_column_diffs(i));
        end loop;
        ut_utils.append_to_clob(l_result, l_results);
      end if;
    end if;
    
    --check for missing pk 
    if a_match_options.join_by.items.count > 0 then
      l_act_missing_pk := l_other.cursor_details.get_missing_join_by_columns( a_match_options.join_by.items );
      l_exp_missing_pk := l_self.cursor_details.get_missing_join_by_columns( a_match_options.join_by.items );
    end if;
    
    --diff rows and row elements if the pk is not missing 
    if l_act_missing_pk.count + l_exp_missing_pk.count = 0 then
      l_diff_id := ut_utils.get_hash( l_self.data_id || l_other.data_id );

      -- First tell how many rows are different
      l_diff_row_count := ut_compound_data_helper.get_rows_diff_count;
      if l_diff_row_count > 0  then
        l_row_diffs := ut_compound_data_helper.get_rows_diff_by_sql(
          l_self_cols, l_other_cols, l_self.data_id, l_other.data_id,
          l_diff_id, 
          case 
          when 
            l_self.cursor_details.is_anydata = 1 then ut_utils.add_prefix(a_match_options.join_by.items, l_self.cursor_details.get_root) 
          else 
            a_match_options.join_by.items 
          end, 
          a_match_options.unordered,a_match_options.ordered_columns(), self.extract_path
        );
        l_message := chr(10)
                     ||'Rows: [ ' || l_diff_row_count ||' differences'
                     ||  case when  l_diff_row_count > c_max_rows and l_row_diffs.count > 0 then ', showing first '||c_max_rows end
                     ||' ]'||chr(10)|| case when l_row_diffs.count = 0 then '  All rows are different as the columns are not matching.' else null end;
        ut_utils.append_to_clob( l_result, l_message );
        l_results := ut_utils.t_clob_tab();
        for i in 1 .. l_row_diffs.count loop
          l_results.extend;
          l_results(l_results.last) := get_diff_message(l_row_diffs(i),a_match_options.unordered);
        end loop;
        ut_utils.append_to_clob(l_result,l_results);
      elsif l_column_diffs is not empty then
        l_message:= chr(10)||'Rows: [ all different ]'||chr(10)||'  All rows are different as the columns position is not matching.';
        ut_utils.append_to_clob( l_result, l_message );
      end if;   
    else
      ut_utils.append_to_clob(l_result,chr(10) || 'Unable to join sets:' || chr(10));

      for i in 1 .. l_exp_missing_pk.count loop
        ut_utils.append_to_clob(l_result, '  Join key '||l_exp_missing_pk(i)||' does not exists in expected'||chr(10));
      end loop;

      for i in 1 .. l_act_missing_pk.count loop
        ut_utils.append_to_clob(l_result, '  Join key '||l_act_missing_pk(i)||' does not exists in actual'||chr(10));
      end loop;

      if l_self.cursor_details.contains_collection() or l_other.cursor_details.contains_collection() then
        ut_utils.append_to_clob(l_result,'  Please make sure that your join clause is not refferring to collection element'|| chr(10));
      end if;
        
    end if;
    if l_result != empty_clob() then
      l_result_string := chr(10) || 'Diff:' || ut_utils.to_string(l_result,null);
    end if;
    dbms_lob.freetemporary(l_result);
    return l_result_string;
  end;

  overriding member function compare_implementation(a_other ut_data_value) return integer is
  begin
    return compare_implementation( a_other, null );
  end;

  member function compare_implementation(
    a_other             ut_data_value,
    a_match_options     ut_matcher_options,
    a_inclusion_compare boolean := false,
    a_is_negated        boolean := false
  ) return integer is
    l_result            integer := 0;
    l_self              ut_data_value_refcursor := self;
    l_other             ut_data_value_refcursor;
    l_diff_cursor_text clob;

    function compare_data(
      a_self             ut_data_value_refcursor,
      a_other            ut_data_value_refcursor,
      a_diff_cursor_text clob
    ) return integer is
      l_diff_id       ut_utils.t_hash;
      l_result        integer;
      --We will start with number od differences being displayed.
      l_cursor        sys_refcursor;
      l_diff_tab      ut_compound_data_helper.t_diff_tab;
      l_diif_rowcount integer :=0;
    begin
      l_diff_id       := ut_utils.get_hash(a_self.data_id||a_other.data_id);
      
      begin
        l_cursor := ut_compound_data_helper.get_compare_cursor(a_diff_cursor_text,
          a_self.data_id, a_other.data_id);
        --fetch and save rows for display of diff
        fetch l_cursor bulk collect into l_diff_tab limit ut_utils.gc_diff_max_rows;      
      exception when others then
        if l_cursor%isopen then
          close l_cursor;
        end if;
        raise;
      end;
      
      ut_compound_data_helper.insert_diffs_result( l_diff_tab, l_diff_id );
      --fetch rows for count only
      loop
        exit when l_diff_tab.count = 0;
        l_diif_rowcount := l_diif_rowcount + l_diff_tab.count;
        fetch l_cursor bulk collect into l_diff_tab limit ut_utils.gc_bc_fetch_limit;
      end loop;

      ut_compound_data_helper.set_rows_diff(l_diif_rowcount);

      --result is OK only if both are same
      if l_diif_rowcount = 0 and a_self.is_null = a_other.is_null then
        l_result := 0;
      else
        l_result := 1;
      end if;
      close l_cursor;
      return l_result;
    end;
  begin
    if not a_other is of (ut_data_value_refcursor) then
      raise value_error;
    end if;

    l_other := treat(a_other as ut_data_value_refcursor);
    l_other.cursor_details.filter_columns( a_match_options );
    l_self.cursor_details.filter_columns( a_match_options );

    if a_match_options.join_by.items.count > 0 then
      l_result :=
        l_self.cursor_details.get_missing_join_by_columns( a_match_options.join_by.items ).count
        + l_other.cursor_details.get_missing_join_by_columns( a_match_options.join_by.items ).count;
    end if;

    if l_result = 0 then
      if not l_self.is_null() and not l_other.is_null() and not l_self.cursor_details.equals( l_other.cursor_details, a_match_options ) then
        l_result := 1;
      end if;
      l_diff_cursor_text := ut_compound_data_helper.gen_compare_sql(
        l_other,
        a_match_options.join_by.items,
        a_match_options.unordered(),
        a_inclusion_compare,
        a_is_negated
        );
      l_result := l_result + compare_data( l_self, l_other, l_diff_cursor_text );
    end if;
    return l_result;
  end;

  overriding member function is_empty return boolean is
  begin
    return self.elements_count = 0;
  end;

end;
/
