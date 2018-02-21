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

  overriding member function get_object_info return varchar2 is
  begin
    return self.data_type||' [ count = '||self.row_count||' ]';
  end;

  member procedure init(self in out nocopy ut_data_value_refcursor, a_value sys_refcursor) is
    c_bulk_rows  constant integer := 1000;
    l_cursor     sys_refcursor := a_value;
    l_ctx                 number;
    l_xml                 xmltype;
    l_current_date_format varchar2(4000);
    l_ut_owner            varchar2(250) := ut_utils.ut_owner;
    cursor_not_open       exception;
  begin
    self.is_cursor_null := ut_utils.boolean_to_int(a_value is null);
    self.self_type  := $$plsql_unit;
    self.data_set_guid := sys_guid();
    self.data_type := 'refcursor';
    if l_cursor is not null then
        if l_cursor%isopen then
          self.columns_info  := ut_refcursor_helper.get_columns_info(l_cursor);
          self.row_count     := 0;
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
              'insert into ' || l_ut_owner || '.ut_data_set_tmp(data_set_guid, item_no, item_data) ' ||
              'select :self_guid, :self_row_count + rownum, value(a) ' ||
              '  from table( xmlsequence( extract(:l_xml,''ROWSET/*'') ) ) a'
              using in self.data_set_guid, self.row_count, l_xml;

            exit when sql%rowcount = 0;

            self.row_count := self.row_count + sql%rowcount;
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

  overriding member function is_null return boolean is
  begin
    return ut_utils.int_to_boolean(self.is_cursor_null);
  end;

  overriding member function to_string return varchar2 is
    l_results       ut_utils.t_clob_tab;
    c_max_rows      constant integer := 10;
    l_result        clob;
    l_result_string varchar2(32767);
  begin
    if not self.is_null() then
      dbms_lob.createtemporary(l_result, true);
      ut_utils.append_to_clob(l_result, 'Data-types:'||chr(10));
      ut_utils.append_to_clob(l_result, self.columns_info.getclobval());

      ut_utils.append_to_clob(l_result,chr(10)||'Data:'||chr(10));
      --return first c_max_rows rows
      execute immediate '
          select xmlserialize( content ucd.item_data no indent)
            from '|| ut_utils.ut_owner ||'.ut_data_set_tmp ucd
           where ucd.data_set_guid = :data_set_guid
             and ucd.item_no <= :max_rows'
        bulk collect into l_results using self.data_set_guid, c_max_rows;

      ut_utils.append_to_clob(l_result,l_results);

      l_result_string := ut_utils.to_string(l_result,null);
      dbms_lob.freetemporary(l_result);
    end if;
    return l_result_string;
  end;

  overriding member function is_diffable return boolean is
  begin
    return true;
  end;

  overriding member function diff( a_other ut_data_value, a_exclude_xpath varchar2, a_include_xpath varchar2 ) return varchar2 is
    c_max_rows          constant integer := 20;
    l_results           ut_utils.t_clob_tab := ut_utils.t_clob_tab();
    l_result            clob;
    l_result_string     varchar2(32767);
    l_ut_owner          varchar2(250) := ut_utils.ut_owner;
    l_diff_row_count    integer;
    l_actual            ut_data_value_refcursor;
    l_diff_id           raw(16);
    l_column_diffs      ut_refcursor_helper.tt_column_diffs := ut_refcursor_helper.tt_column_diffs();
    l_row_diffs         ut_refcursor_helper.tt_row_diffs;
    l_exclude_xpath     varchar2(32767);
    function get_col_diff_text(a_col ut_refcursor_helper.t_column_diffs) return varchar2 is
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
    function add_incomparable_cols_to_xpath(
      a_column_diffs ut_refcursor_helper.tt_column_diffs, a_exclude_xpath varchar2
    ) return varchar2 is
      l_incomparable_cols ut_varchar2_list := ut_varchar2_list();
      l_result            varchar2(32767);
    begin
      for i in 1 .. a_column_diffs.count loop
        if a_column_diffs(i).diff_type in ('-','+') then
          l_incomparable_cols.extend;
          l_incomparable_cols(l_incomparable_cols.last) := coalesce(a_column_diffs(i).expected_name,a_column_diffs(i).actual_name);
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

    if not self.is_null and not l_actual.is_null then
      l_column_diffs := ut_refcursor_helper.get_columns_diff(self.columns_info, l_actual.columns_info, a_exclude_xpath, a_include_xpath);

      if l_column_diffs.count > 0 then
        ut_utils.append_to_clob(l_result,chr(10) || 'Columns:' || chr(10));
      end if;

      for i in 1 .. l_column_diffs.count loop
        l_results.extend;
        l_results(l_results.last) := get_col_diff_text(l_column_diffs(i));
      end loop;
      ut_utils.append_to_clob(l_result, l_results);
      l_results.delete;
    end if;

    l_exclude_xpath := add_incomparable_cols_to_xpath(l_column_diffs, a_exclude_xpath);

    l_diff_id := dbms_crypto.hash(self.data_set_guid||l_actual.data_set_guid,2);
    -- First tell how many rows are different
    execute immediate 'select count(*) from ' || l_ut_owner || '.ut_data_set_diff_tmp where diff_id = :diff_id' into l_diff_row_count using l_diff_id;

    if l_diff_row_count > 0  then
      l_row_diffs := ut_refcursor_helper.get_rows_diff(
          self.data_set_guid, l_actual.data_set_guid, l_diff_id, c_max_rows, l_exclude_xpath, a_include_xpath
      );

      if l_row_diffs.count = 0 then
        ut_utils.append_to_clob(l_result,chr(10) || 'Rows:'||chr(10)||'  All rows are different as the columns are not matching.');
      else
        ut_utils.append_to_clob(l_result,chr(10) || 'Rows: [ diff count = ' || to_char(l_diff_row_count) ||' ]' || chr(10));
      end if;
      for i in 1 .. l_row_diffs.count loop
        l_results.extend;
        l_results(l_results.last) := '  Row No. '||l_row_diffs(i).rn||' - '||rpad(l_row_diffs(i).diff_type,10)||l_row_diffs(i).diffed_row;
      end loop;
      ut_utils.append_to_clob(l_result,l_results);
    end if;

    l_result_string := ut_utils.to_string(l_result,null);
    dbms_lob.freetemporary(l_result);
    return l_result_string;
  end;

  member function is_empty return boolean is
  begin
    return self.row_count = 0;
  end;

  overriding member function compare_implementation(a_other ut_data_value) return integer is
  begin
    return compare_implementation( a_other, null, null);
  end;

  member function compare_implementation(a_other ut_data_value, a_exclude_xpath varchar2, a_include_xpath varchar2) return integer is
    l_result          integer := 0;
    l_other           ut_data_value_refcursor;
    l_ut_owner        varchar2(250) := ut_utils.ut_owner;
    l_column_filter   varchar2(32767);
    l_diff_id         raw(16);
    --the XML stylesheet is applied on XML representation of data to exclude column names from comparison
    --column names and data-types are compared separately
    l_xml_data_fmt    constant xmltype := xmltype(
        q'[<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
          <xsl:strip-space elements="*" />
          <xsl:template match="/child::*">
              <xsl:for-each select="child::node()">
                  <xsl:choose>
                      <xsl:when test="*[*]"><xsl:copy-of select="node()"/></xsl:when>
                      <xsl:when test="position()=last()"><xsl:value-of select="normalize-space(.)"/><xsl:text>&#xD;</xsl:text></xsl:when>
                      <xsl:otherwise><xsl:value-of select="normalize-space(.)"/>,</xsl:otherwise>
                  </xsl:choose>
              </xsl:for-each>
          </xsl:template>
          </xsl:stylesheet>]');
    function columns_hash(
      a_data_value_cursor ut_data_value_refcursor, a_exclude_xpath varchar2, a_include_xpath varchar2
    ) return raw is
      l_cols_hash  raw(32);
    begin
      if not a_data_value_cursor.is_null then
        execute immediate
        q'[select dbms_crypto.hash(replace(x.item_data.getclobval(),'>CHAR<','>VARCHAR2<'),3) ]' ||
        '  from ( select '||ut_refcursor_helper.get_columns_filter(a_exclude_xpath, a_include_xpath)||
        '           from (select :columns_info as item_data from dual ) ucd' ||
        '  ) x'
        into l_cols_hash using a_exclude_xpath, a_include_xpath, a_data_value_cursor.columns_info;
      end if;
      return l_cols_hash;
    end;
  begin
    if not a_other is of (ut_data_value_refcursor) then
      raise value_error;
    end if;

    l_other   := treat(a_other as ut_data_value_refcursor);

    --if column names/types are not equal - build a diff of column names and types
    if columns_hash( self, a_exclude_xpath, a_include_xpath )
       != columns_hash( l_other, a_exclude_xpath, a_include_xpath )
    then
      l_result := 1;
    end if;
    l_diff_id := dbms_crypto.hash(self.data_set_guid||l_other.data_set_guid,2);
    l_column_filter := ut_refcursor_helper.get_columns_filter(a_exclude_xpath, a_include_xpath);
    -- Find differences
    execute immediate 'insert into ' || l_ut_owner || '.ut_data_set_diff_tmp ( diff_id, item_no )
                        select :diff_id, nvl(exp.item_no, act.item_no)
                          from (select '||l_column_filter||', ucd.item_no
                                  from ' || l_ut_owner || '.ut_data_set_tmp ucd where ucd.data_set_guid = :self_guid) exp
                          full outer join
                               (select '||l_column_filter||', ucd.item_no
                                  from ' || l_ut_owner || '.ut_data_set_tmp ucd where ucd.data_set_guid = :l_other_guid) act
                            on exp.item_no = act.item_no '||
                        'where nvl( dbms_lob.compare(' ||
                                     /*the xmltransform removes column names and leaves column data to be compared only*/
                                     '  xmltransform(exp.item_data, :l_xml_data_fmt).getclobval()' ||
                                     ', xmltransform(act.item_data, :l_xml_data_fmt).getclobval())' ||
                                 ',1' ||
                                 ') != 0'
      using in l_diff_id, a_exclude_xpath, a_include_xpath, self.data_set_guid,
         a_exclude_xpath, a_include_xpath, l_other.data_set_guid, l_xml_data_fmt, l_xml_data_fmt;

    --result is OK only if both are same
    if sql%rowcount = 0 and self.row_count = l_other.row_count and l_result = 0 then
      l_result := 0;
    else
      l_result := 1;
    end if;
    return l_result;
  end;

  overriding member function is_multi_line return boolean is
  begin
    return not self.is_null() and not self.is_empty();
  end;

end;
/
