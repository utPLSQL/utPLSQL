create or replace type body ut_data_value_xmltype as
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

  constructor function ut_data_value_xmltype(self in out nocopy ut_data_value_xmltype, a_value xmltype) return self as result is
  begin
    self.data_value := a_value;
    self.self_type  := $$plsql_unit;
    self.data_type := 'xmltype';
    return;
  end;

  overriding member function is_null return boolean is
  begin
    return (self.data_value is null);
  end;

  overriding member function to_string return varchar2 is
  begin
    return ut_utils.to_string(self.data_value.getClobVal());
  end;
 
  overriding member function compare_implementation(a_other ut_data_value) return integer is
    l_result integer;
    l_other  ut_data_value_xmltype;
  begin
    if a_other is of (ut_data_value_xmltype) then
      l_other := treat(a_other as ut_data_value_xmltype);
      l_result := dbms_lob.compare(self.data_value.getClobVal(),l_other.data_value.getClobVal());
    end if;

    return l_result;
  end;
  
end;
/
