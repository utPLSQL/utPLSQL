create or replace type body ut_data_value_collection as
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

  constructor function ut_data_value_collection(self in out nocopy ut_data_value_collection, a_value anydata) return self as result is
  begin
    self.self_type  := $$plsql_unit;
    self.init(a_value, 'collection');
    if a_value is not null then
      execute immediate '
        declare
          l_data '||a_value.gettypename()||';
          l_value anydata := :a_value;
          l_status integer;
        begin
          l_status := l_value.getCollection(l_data);
          if l_data is not null then
            :l_count := l_data.count;
          end if;
        end;' using in self.data_value, out self.elements_count;
    end if;
    return;
  end;

  overriding member function get_object_info return varchar2 is
  begin
    return self.data_type||' [ count = '||self.elements_count||' ]';
  end;

  member function is_empty return boolean is
  begin
    if not self.is_null() then
      return xmltype(self.data_value).getclobval()
             = '<' || substr(self.data_value.gettypename, instr(self.data_value.gettypename, '.') + 1) || '/>';
    else
      return null;
    end if;
  end;

  overriding member function is_multi_line return boolean is
  begin
    return not self.is_null();
  end;

end;
/
