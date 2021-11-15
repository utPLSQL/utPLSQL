create or replace type body ut_suite_item_info is
  /*
  utPLSQL - Version 3
  Copyright 2016 - 2021 utPLSQL Project

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
  constructor function ut_suite_item_info(a_object_owner varchar2, a_object_name varchar2, a_item_name varchar2, 
    a_item_description varchar2, a_item_type varchar2, a_item_line_no integer, a_path varchar2, a_disabled_flag integer,
    a_tags ut_varchar2_rows) return self as result is  
  begin
    self.object_owner     := a_object_owner;
    self.object_name      := a_object_name;
    self.item_name        := a_item_name;
    self.item_description := a_item_description;
    self.item_type        := a_item_type;
    self.item_line_no     := a_item_line_no;
    self.path             := a_path;
    self.disabled_flag    := a_disabled_flag;
    self.tags             := case 
                               when a_tags is null then null 
                               when a_tags.count = 0 then null
                               else ut_utils.to_string(ut_utils.table_to_clob(a_tags,',') ,a_quote_char => null)
                             end;
    return;
  end;
end;
/
