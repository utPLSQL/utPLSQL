create or replace type body ut_data_value_refcursor as
  /*
  utPLSQL - Version X.X.X.X
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

  constructor function ut_data_value_refcursor(self in out nocopy ut_data_value_refcursor, a_value sys_refcursor, a_exclude varchar2 ) return self as result is
  begin
    self.exclude_xpath := ut_utils.to_xpath(a_exclude);
    init(a_value);
    return;
  end;

  constructor function ut_data_value_refcursor(self in out nocopy ut_data_value_refcursor, a_value sys_refcursor, a_exclude ut_varchar2_list ) return self as result is
  begin
    self.exclude_xpath := ut_utils.to_xpath(a_exclude);
    init(a_value);
    return;
  end;

  member procedure init(self in out nocopy ut_data_value_refcursor, a_value sys_refcursor) is
    l_ctx                 number;
    l_xml                 xmltype;
    c_bulk_rows  constant integer := 1000;
    l_current_date_format varchar2(4000);
    l_ut_owner     varchar2(250) := ut_utils.ut_owner;
  begin
    self.is_cursor_null := ut_utils.boolean_to_int(a_value is null);
    self.self_type  := $$plsql_unit;
    self.data_value := sys_guid();
    self.data_type := 'refcursor';
    if a_value is not null and a_value%isopen then
      self.row_count := 0;
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
      l_ctx := dbms_xmlgen.newContext(a_value);
      dbms_xmlgen.setNullHandling(l_ctx, dbms_xmlgen.empty_tag);
      dbms_xmlgen.setMaxRows(l_ctx, c_bulk_rows);

      loop
        l_xml := dbms_xmlgen.getxmltype(l_ctx);

        execute immediate 'insert into ' || l_ut_owner || '.ut_cursor_data(cursor_data_guid, row_no, row_data)
                            select :self_guid, :self_row_count + rownum, value(a) from table( xmlsequence( extract(:l_xml,''ROWSET/*'') ) ) a'
          using in self.data_value, self.row_count, l_xml;

        exit when sql%rowcount = 0;

        self.row_count := self.row_count + sql%rowcount;
      end loop;

      ut_expectation_processor.reset_nls_params();
      if a_value%isopen then
        close a_value;
      end if;
      dbms_xmlgen.closeContext(l_ctx);
    end if;
  exception
    when others then
      ut_expectation_processor.reset_nls_params();
      if a_value%isopen then
        close a_value;
      end if;
      dbms_xmlgen.closeContext(l_ctx);
      raise;
  end;

  overriding member function is_null return boolean is
  begin
    return ut_utils.int_to_boolean(self.is_cursor_null);
  end;

  overriding member function to_string return varchar2 is
    type t_clob_tab is table of clob;
    l_results       t_clob_tab;
    c_max_rows      constant integer := 10;
    l_result        clob;
    l_result_xml    xmltype;
    l_result_string varchar2(32767);
    l_ut_owner     varchar2(250) := ut_utils.ut_owner;
  begin
    dbms_lob.createtemporary(l_result,true);
    --return rows which were previously marked as different
    execute immediate 'select xmlserialize( content ucd.row_data no indent)
                        from ' || l_ut_owner || '.ut_cursor_data ucd
                       where ucd.cursor_data_guid = :self_guid
                          and ucd.row_no in (select row_no from ' || l_ut_owner || '.ut_cursor_data_diff ucdc)'
      bulk collect into l_results using in self.data_value;

    for i in 1 .. l_results.count loop
      dbms_lob.append(l_result,l_results(i));
      if i < l_results.count then
        ut_utils.append_to_clob(l_result,chr(10));
      end if;
    end loop;

    l_result_string := ut_utils.to_string(l_result,null);
    dbms_lob.freetemporary(l_result);
    return self.format_multi_line( l_result_string );
  end;

  member function is_empty return boolean is
  begin
    return self.row_count = 0;
  end;

  overriding member function compare_implementation(a_other ut_data_value) return integer is
    l_result integer;
    l_other  ut_data_value_refcursor;
    l_xpath  varchar2(32767);
    l_ut_owner     varchar2(250) := ut_utils.ut_owner;
  begin
    l_xpath := coalesce(self.exclude_xpath, l_other.exclude_xpath);
    if a_other is of (ut_data_value_refcursor) then
      l_other  := treat(a_other as ut_data_value_refcursor);
      
      execute immediate 'insert into ' || l_ut_owner || '.ut_cursor_data_diff ( row_no )
                          select nvl(exp.row_no, act.row_no)
                            from (select case when :l_xpath is not null then deletexml( ucd.row_data, :l_xpath ) else ucd.row_data end as row_data,
                                         ucd.row_no
                                    from ' || l_ut_owner || '.ut_cursor_data ucd where ucd.cursor_data_guid = :self_guid) exp
                            full outer join (select case when :l_xpath is not null then deletexml( ucd.row_data, :l_xpath ) else ucd.row_data end as row_data,
                                                    ucd.row_no
                                               from ' || l_ut_owner || '.ut_cursor_data ucd where ucd.cursor_data_guid = :l_other_guid) act
                             on (exp.row_no = act.row_no)
                           where nvl(dbms_lob.compare(xmlserialize( content exp.row_data no indent), xmlserialize( content act.row_data no indent)),1) != 0' 
        using in l_xpath, l_xpath, self.DATA_VALUE, l_xpath, l_xpath, l_other.DATA_VALUE;
      execute immediate 'select count(1) from ' || l_ut_owner || '.ut_cursor_data_diff where rownum <= 1' into l_result;
    else
      raise value_error;
    end if;
    return l_result;
  end;

  overriding member function is_multi_line return boolean is
  begin
    return not self.is_null() and not self.is_empty();
  end;

end;
/
