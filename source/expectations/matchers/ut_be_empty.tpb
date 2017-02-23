create or replace type body ut_be_empty as
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

  member procedure init(self in out nocopy ut_be_empty) is
  begin    
    self.name := 'be_empty';    
  end;

  constructor function ut_be_empty(self in out nocopy ut_be_empty) return self as result is
  begin
    init();
    return;
  end;

  overriding member function run_matcher(self in out nocopy ut_be_empty, a_actual ut_data_value) return boolean is
    l_result boolean;
  begin
    if a_actual is of(ut_data_value_refcursor) then
      declare
        l_actual ut_data_value_refcursor := treat(a_actual as ut_data_value_refcursor);
      begin
        if l_actual.data_value is not null then
          l_result := l_actual.is_empty;
        else
          l_result := false;
        end if;
      end;
    elsif a_actual is of(ut_data_value_anydata) then
      declare
        l_actual    ut_data_value_anydata := treat(a_actual as ut_data_value_anydata);
        l_type_name varchar2(61);
        l_type      anytype;
      begin
        if l_actual.data_value.gettype(l_type) in
           (dbms_types.typecode_varray, dbms_types.typecode_table, dbms_types.typecode_namedcollection) then
          if a_actual.is_null() then
            l_result := false;
          else
            ut_assert_processor.set_xml_nls_params();
            l_type_name := l_actual.data_value.gettypename();
            l_type_name := substr(l_type_name, instr(l_type_name, '.') + 1);
            l_result    := xmltype(l_actual.data_value).getclobval() = '<' || l_type_name || '/>';
            ut_assert_processor.reset_nls_params();
          end if;
        else
          ut_utils.debug_log('Failure - ut_be_empty.run_matcher can only be used with collections and cursors');
          self.error_message := 'The matcher can only be used with collections and cursors';
          l_result           := null;
        end if;
      end;
    else
      l_result := (self as ut_matcher).run_matcher(a_actual);
    end if;
    return l_result;
  end;

end;
/
