create or replace type body ut_matcher_config as
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

  constructor function ut_matcher_config(self in out nocopy ut_matcher_config, a_nulls_are_equal in boolean := null) return self as result is
  begin
    nulls_are_equal_flag := ut_utils.boolean_to_int( coalesce(a_nulls_are_equal, ut_expectation_processor.nulls_are_equal()) );
    is_unordered := ut_utils.boolean_to_int(false);
    columns_are_unordered_flag := ut_utils.boolean_to_int(false);
    include_list := ut_matcher_config_items();
    exclude_list := ut_matcher_config_items();
    join_by_list := ut_matcher_config_items();
    return;
  end;

  member procedure nulls_are_equal(self in out nocopy ut_matcher_config) is
  begin
    self.nulls_are_equal_flag := ut_utils.boolean_to_int(true);
  end;

  member function nulls_are_equal return boolean is
  begin
    return ut_utils.int_to_boolean(self.nulls_are_equal_flag);
  end;

  member procedure include(self in out nocopy ut_matcher_config, a_include varchar2) is
  begin
    include_list.add_items(a_include);
  end;

  member procedure include(self in out nocopy ut_matcher_config, a_include ut_varchar2_list) is
  begin
    include_list.add_items(a_include);
  end;

  member function  include return ut_varchar2_list is
  begin
    return include_list.items;
  end;

  member procedure exclude(self in out nocopy ut_matcher_config, a_exclude varchar2) is
  begin
    exclude_list.add_items(a_exclude);
  end;

  member procedure exclude(self in out nocopy ut_matcher_config, a_exclude ut_varchar2_list) is
  begin
    exclude_list.add_items(a_exclude);
  end;

  member function  exclude return ut_varchar2_list is
  begin
    return exclude_list.items;
  end;

  member procedure join_by(self in out nocopy ut_matcher_config, a_join_by varchar2) is
  begin
    join_by_list.add_items(a_join_by);
  end;

  member procedure join_by(self in out nocopy ut_matcher_config, a_join_by ut_varchar2_list) is
  begin
    join_by_list.add_items(a_join_by);
  end;

  member function  join_by return ut_varchar2_list is
  begin
    return join_by_list.items;
  end;

  member procedure unordered_columns(self in out nocopy ut_matcher_config) is
  begin
    columns_are_unordered_flag := ut_utils.boolean_to_int(true);
  end;

  member function ordered_columns return boolean is
  begin
    return not ut_utils.int_to_boolean(columns_are_unordered_flag);
  end;

  member procedure unordered(self in out nocopy ut_matcher_config) is
  begin
    is_unordered := ut_utils.boolean_to_int(true);
  end;

  member function unordered return boolean  is
  begin
    return ut_utils.int_to_boolean(is_unordered);
  end;
end;
/
