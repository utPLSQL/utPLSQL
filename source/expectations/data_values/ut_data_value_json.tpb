create or replace type body ut_data_value_json as
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

  member procedure init (self in out nocopy ut_data_value_json, a_value json_element_t) is
  begin
    self.is_data_null   := case when a_value is null then 1 else 0 end;
    self.data_value     := case when a_value is null then null else a_value.to_clob end;
    self.self_type      := $$plsql_unit;
    self.data_type      := 'json';
    self.json_tree      := ut_json_tree_details(a_value);
    self.data_id        := sys_guid();  
  end;
  
  constructor function ut_data_value_json(self in out nocopy ut_data_value_json, a_value json_element_t) return self as result is
  begin 
    init(a_value);
    return;
  end;

  overriding member function is_null return boolean is
  begin
    return (ut_utils.int_to_boolean(self.is_data_null));
  end;

  overriding member function is_empty return boolean is
  begin
    return self.data_value = '{}';
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
    l_diff_id           ut_compound_data_helper.t_hash;
    c_max_rows          integer := ut_utils.gc_diff_max_rows;
    l_diffs             ut_compound_data_helper.tt_json_diff_tab;
    l_message           varchar2(32767);
    
    function get_diff_by_type(a_diff_id raw) return clob is
      l_diff_summary  ut_compound_data_helper.tt_json_diff_type_tab := ut_compound_data_helper.get_json_diffs_type(a_diff_id);
      l_message_list  ut_varchar2_list := ut_varchar2_list();
    begin
      for i in 1..l_diff_summary.count loop
        l_message_list.extend;
        l_message_list(l_message_list.last) := l_diff_summary(i).no_of_occurence||' '||l_diff_summary(i).difference_type; 
      end loop;
      return ut_utils.table_to_clob(l_message_list,', ');
    end;
         
    function get_json_diff_text (a_json_diff ut_compound_data_helper.t_json_diff_rec) return clob is
    begin
      return 
        case
          when a_json_diff.difference_type = ut_compound_data_helper.gc_json_missing
            then 
              case 
                when a_json_diff.act_element_name is not null then q'[  Missing property: ]'||a_json_diff.act_element_name
                when a_json_diff.exp_element_name is not null then q'[  Extra   property: ]'||a_json_diff.exp_element_name
              end || ' on path: '||nvl(a_json_diff.act_parent_path,a_json_diff.exp_parent_path)
          else
            case
              when a_json_diff.difference_type = ut_compound_data_helper.gc_json_type
                then q'[  Actual  type: ']'||a_json_diff.act_json_type||q'[' was expected to be: ']'||a_json_diff.exp_json_type||q'[']'
              when a_json_diff.difference_type = ut_compound_data_helper.gc_json_notequal
                then q'[  Actual value: ]'||a_json_diff.act_element_value||q'[ was expected to be: ]'||a_json_diff.exp_element_value
            end || ' on path: '||nvl(a_json_diff.act_access_path,a_json_diff.exp_access_path)
        end;
    end;
    
  begin
    if not a_other is of (ut_data_value_json) then
      raise value_error;
    end if;
    dbms_lob.createtemporary(l_result, true);
    l_other := treat(a_other as ut_data_value_json);       
    l_diff_id  := ut_compound_data_helper.get_hash(self.data_id||l_other.data_id);  
    
    if not l_self.is_null and not l_other.is_null then
      l_diffs := ut_compound_data_helper.get_json_diffs_tmp(l_diff_id);
        
      l_message := ' '||l_diffs.count|| ' differences found' ||
        case when l_diffs.count > c_max_rows then ', showing first '|| c_max_rows else null end||chr(10);
      ut_utils.append_to_clob( l_result, l_message );
      l_message := get_diff_by_type(l_diff_id)||chr(10);
      ut_utils.append_to_clob( l_result, l_message );

      for i in 1 .. least( c_max_rows, l_diffs.count ) loop
         l_results.extend;
         l_results(l_results.last) := get_json_diff_text(l_diffs(i));
      end loop;
      ut_utils.append_to_clob(l_result, l_results);
    
    end if;
    
    
    l_result_string := ut_utils.to_string(l_result,null);
    dbms_lob.freetemporary(l_result);
    return l_result_string;
  end;
  
  overriding member function compare_implementation(a_other ut_data_value) return integer is
    l_self ut_data_value_json := self;
    l_other ut_data_value := a_other;
  begin   
    return l_self.compare_implementation( l_other, null );
  end;  
  
  member function compare_implementation(a_other in ut_data_value,a_match_options ut_matcher_options) return 
    integer is
    l_result integer;
    l_other  ut_data_value_json;
    l_diff_id       ut_compound_data_helper.t_hash;
  begin
   if a_other is of (ut_data_value_json) then
      l_other   := treat(a_other as ut_data_value_json);
      l_diff_id := ut_compound_data_helper.get_hash(self.data_id||l_other.data_id);
      l_result :=
        case
          when ut_compound_data_helper.insert_json_diffs(
            l_diff_id, self.json_tree.json_tree_info, l_other.json_tree.json_tree_info
          ) > 0 then 1
          else 0
        end;
    end if;
    return l_result;
  end;

  member function get_elements_count return integer is
  begin
    return json_element_t.parse(self.data_value).get_size;
  end;

  member function get_json_count_info return varchar2 is
  begin
    return self.data_type||' [ count = '||self.get_elements_count||' ]';
  end;

  overriding member function get_object_info return varchar2 is
  begin
    return self.data_type;
  end;

end;
/
