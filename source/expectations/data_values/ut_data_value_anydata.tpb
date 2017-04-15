create or replace type body ut_data_value_anydata as
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

  constructor function ut_data_value_anydata(self in out nocopy ut_data_value_anydata) return self as result is
  begin
    self.self_type  := $$plsql_unit;
    self.data_type  := 'undefined';
    return;
  end;

  overriding member function is_null return boolean is
  begin
    return true;
  end;

  overriding member function to_string return varchar2 is
  begin
    return ut_utils.to_string( to_char(null) );
  end;

  overriding member function compare_implementation( a_other ut_data_value ) return integer is
  begin
    return null;
  end;

  static function get_instance(a_data_value anydata) return ut_data_value_anydata is
    l_result    ut_data_value_anydata := ut_data_value_anydata();
    l_type      anytype;
    l_type_code integer;
  begin
    if a_data_value is not null then
      l_type_code := a_data_value.gettype(l_type);
      if l_type_code = sys.dbms_types.typecode_object then
        l_result := ut_data_value_object(a_data_value);
      elsif l_type_code in (dbms_types.typecode_table, dbms_types.typecode_varray, dbms_types.typecode_namedcollection) then
        l_result := ut_data_value_collection(a_data_value);
      else
        raise_application_error(-20000, 'Data type '||a_data_value.gettypename||' in ANYDATA is not supported by utPLSQL');
      end if;
    end if;
    return l_result;
  end;

end;
/
