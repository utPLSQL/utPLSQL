create or replace type body ut_data_value_object as
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

  constructor function ut_data_value_object(self in out nocopy ut_data_value_object, a_value anydata) return self as result is
  begin
    self.data_value := a_value;
    self.self_type  := $$plsql_unit;
    self.data_type  := case when a_value is not null then lower(a_value.gettypename) else 'undefined' end;
    return;
  end;

  overriding member function is_null return boolean is
    l_is_null       boolean;
    l_data_is_null  pls_integer;
    l_sql           varchar2(32767);
    l_cursor        number;
    l_status        number;
  begin
    if self.data_value is null then
      l_is_null := true;
    --check if typename is a schema based object
    else
      --XMLTYPE doesn't like the null being passed to ANYDATA so we need to check if anydata holds null Object/collection
      l_sql := '
        declare
          l_data '||self.data_value.gettypename()||';
          l_value anydata := :a_value;
          x integer;
        begin
          x := l_value.getObject(l_data);
          :l_data_is_null := case when l_data is null then 1 else 0 end;
        end;';
      l_cursor := sys.dbms_sql.open_cursor();
      sys.dbms_sql.parse(l_cursor, l_sql, dbms_sql.native);
      sys.dbms_sql.bind_variable(l_cursor,'a_value',self.data_value);
      sys.dbms_sql.bind_variable(l_cursor,'l_data_is_null',l_data_is_null);
      begin
        l_status := sys.dbms_sql.execute(l_cursor);
        sys.dbms_sql.variable_value(l_cursor,'l_data_is_null',l_data_is_null);
        sys.dbms_sql.close_cursor(l_cursor);
      exception when others then
        if sys.dbms_sql.is_open(l_cursor) then
          sys.dbms_sql.close_cursor(l_cursor);
        end if;
        raise;
      end;
      l_is_null := ut_utils.int_to_boolean(l_data_is_null);
    end if;
    return l_is_null;
  end;

  overriding member function to_string return varchar2 is
    l_result varchar2(32767);
    l_clob   clob;
  begin
    if self.is_null() then
      l_result := ut_utils.to_string( to_char(null) );
    else
      ut_expectation_processor.set_xml_nls_params();
      select xmlserialize(content xmltype(self.data_value) indent) into l_clob from dual;
      l_result := ut_utils.to_string( l_clob, null );
      ut_expectation_processor.reset_nls_params();
    end if;
    return self.format_multi_line( l_result );
  end;

  overriding member function compare_implementation(a_other ut_data_value) return integer is
    l_self_data  xmltype;
    l_other_data xmltype;
    l_other  ut_data_value_object;
    l_result integer;
  begin
    if a_other is of (ut_data_value_object) then
      l_other := treat(a_other as ut_data_value_object);
      --needed for 11g xe as it fails on constructing XMLTYPE from null ANYDATA
      if not self.is_null() and not l_other.is_null() then
        ut_expectation_processor.set_xml_nls_params();
        l_self_data := xmltype.createxml(self.data_value);
        l_other_data := xmltype.createxml(l_other.data_value);
        ut_expectation_processor.reset_nls_params();
        if l_self_data is not null and l_other_data is not null then
          l_result := dbms_lob.compare( l_self_data.getclobval(), l_other_data.getclobval() );
        end if;
      end if;
    else
      raise value_error;
    end if;
    return l_result;
  end;

  overriding member function is_multi_line return boolean is
  begin
    return not self.is_null();
  end;

end;
/
