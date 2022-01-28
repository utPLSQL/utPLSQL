create or replace type body ut_matcher_options as
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

  constructor function ut_matcher_options(self in out nocopy ut_matcher_options, a_nulls_are_equal in boolean := null) return self as result is
  begin
    nulls_are_equal_flag := ut_utils.boolean_to_int( coalesce(a_nulls_are_equal, ut_expectation_processor.nulls_are_equal()) );
    is_unordered := ut_utils.boolean_to_int(false);
    columns_are_unordered_flag := ut_utils.boolean_to_int(false);
    include := ut_matcher_options_items();
    exclude := ut_matcher_options_items();
    join_by := ut_matcher_options_items();
    return;
  end;

  member procedure nulls_are_equal(self in out nocopy ut_matcher_options) is
  begin
    self.nulls_are_equal_flag := ut_utils.boolean_to_int(true);
  end;

  member function nulls_are_equal return boolean is
  begin
    return ut_utils.int_to_boolean(self.nulls_are_equal_flag);
  end;

  member procedure unordered_columns(self in out nocopy ut_matcher_options) is
  begin
    columns_are_unordered_flag := ut_utils.boolean_to_int(true);
  end;

  member function ordered_columns return boolean is
  begin
    return not ut_utils.int_to_boolean(columns_are_unordered_flag);
  end;

  member procedure unordered(self in out nocopy ut_matcher_options) is
  begin
    is_unordered := ut_utils.boolean_to_int(true);
  end;

  member function unordered return boolean  is
  begin
    return ut_utils.int_to_boolean(is_unordered);
  end;
end;
/
