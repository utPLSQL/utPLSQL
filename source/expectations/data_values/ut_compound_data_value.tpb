create or replace type body ut_compound_data_value as
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

  member function get_elements_count_info return varchar2 is
  begin
    return case when elements_count is null then ' [ null ]' else ' [ count = '||elements_count||' ]' end;
  end;

  overriding member function get_object_info return varchar2 is
  begin
    return self.data_type||get_elements_count_info();
  end;

  overriding member function is_null return boolean is
  begin
    return ut_utils.int_to_boolean(self.is_data_null);
  end;

  overriding member function is_diffable return boolean is
  begin
    return true;
  end;

  overriding member function is_multi_line return boolean is
  begin
    return not self.is_null();
  end;

  overriding member function to_string return varchar2 is
    l_result        clob;
    l_result_string varchar2(32767);
  begin
    if not self.is_null() then
      dbms_lob.createtemporary(l_result, true);
      ut_utils.append_to_clob(l_result,'Data:'||chr(10));
      ut_utils.append_to_clob(
        l_result,
        ut_compound_data_helper.get_row_data_as_xml( self.data_id, ut_utils.gc_diff_max_rows )
      );

      l_result_string := ut_utils.to_string(l_result,null);
      dbms_lob.freetemporary(l_result);
    end if;
    return l_result_string;
  end;

end;
/
