create or replace type body ut_data_value_json as
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

  --IS JSON, JSON_EXISTS, JSON_TEXTCONTAINS

  constructor function ut_data_value_json(self in out nocopy ut_data_value_json, a_value json_element_t) return self as result is
  begin
    
    self.is_data_null := case when a_value is null then 1 when a_value.stringify = '{}' then 1 else 0 end;
    self.data_value :=  case when a_value is null then null else a_value.to_clob end;
    self.self_type  := $$plsql_unit;
    self.data_type := 'json';
    return;
  end;

  overriding member function is_null return boolean is
  begin
    return (ut_utils.int_to_boolean(self.is_data_null));
  end;

  overriding member function to_string return varchar2 is
  begin
    return ut_utils.to_string(self.data_value);
  end;
      
  overriding member function diff( a_other ut_data_value, a_match_options ut_matcher_options ) return varchar2 is
    l_result            clob;
    l_results           ut_utils.t_clob_tab := ut_utils.t_clob_tab();
    l_result_string     varchar2(32767);
    l_other             ut_data_value_json;
    l_self              ut_data_value_json := self;

    l_act_keys          ut_varchar2_list := ut_varchar2_list();
    l_exp_keys          ut_varchar2_list := ut_varchar2_list();

    c_max_rows          integer := ut_utils.gc_diff_max_rows;
    l_diff_id           ut_compound_data_helper.t_hash;
    l_diff_row_count    integer;
    l_row_diffs         ut_compound_data_helper.tt_row_diffs;
    l_message           varchar2(32767);
     
  begin
    if not a_other is of (ut_data_value_json) then
      raise value_error;
    end if;
    l_other := treat(a_other as ut_data_value_json);       
    
    l_result_string := ut_utils.to_string(l_result,null);
    dbms_lob.freetemporary(l_result);
    return l_result_string;
  end;

  
  overriding member function compare_implementation(a_other ut_data_value) return integer is
  begin
    return compare_implementation( a_other, null );
  end;  

  member function compare_implementation(a_other ut_data_value,a_match_options ut_matcher_options) return integer is
    l_result integer;
    l_other  ut_data_value_json;
  begin
   if a_other is of (ut_data_value_json) then
      l_other := treat(a_other as ut_data_value_json);
      select case when json_equal(self.data_value, l_other.data_value) then 0 else 1 end
      into l_result
      from dual;
    end if;

    return l_result;
  end;
  
end;
/
