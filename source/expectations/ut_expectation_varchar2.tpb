create or replace type body ut_expectation_varchar2 as
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
  overriding member procedure to_equal(self in ut_expectation_varchar2, a_expected varchar2, a_nulls_are_equal boolean := null) is
  begin
    ut_utils.debug_log('ut_expectation_varchar2.to_equal(self in ut_expectation, a_expected varchar2)');
    self.to_( ut_equal(a_expected, a_nulls_are_equal) );
  end;

  member procedure to_be_between(self in ut_expectation_varchar2, a_lower_bound varchar2, a_upper_bound varchar2) is
  begin
    ut_utils.debug_log('ut_expectation_varchar2.to_be_between(self in ut_expectation_varchar2, a_lower_bound varchar2, a_upper_bound varchar2)');
    self.to_( ut_be_between(a_lower_bound,a_upper_bound) );
  end;

  member procedure to_be_like(self in ut_expectation_varchar2, a_mask in varchar2, a_escape_char in varchar2 := null) is
  begin
    ut_utils.debug_log('ut_expectation_varchar2.to_be_like(self in ut_expectation, a_mask in varchar2, a_escape_char in varchar2 default null)');
    self.to_( ut_be_like(a_mask, a_escape_char) );
  end;

  member procedure to_match(self in ut_expectation_varchar2, a_pattern in varchar2, a_modifiers in varchar2 default null) is
  begin
    ut_utils.debug_log('ut_expectation_varchar2.to_match(self in ut_expectation, a_pattern in varchar2, a_modifiers in varchar2 default null)');
    self.to_( ut_match(a_pattern, a_modifiers) );
  end;
  
  overriding member procedure not_to_equal(self in ut_expectation_varchar2, a_expected varchar2, a_nulls_are_equal boolean := null) is
  begin
    ut_utils.debug_log('ut_expectation_varchar2.not_to_equal(self in ut_expectation, a_expected varchar2)');
    self.not_to( ut_equal(a_expected, a_nulls_are_equal) );
  end;
  
  member procedure not_to_be_between(self in ut_expectation_varchar2, a_lower_bound varchar2, a_upper_bound varchar2) is
  begin
    ut_utils.debug_log('ut_expectation_varchar2.not_to_be_between(self in ut_expectation_varchar2, a_lower_bound varchar2, a_upper_bound varchar2)');
    self.not_to( ut_be_between(a_lower_bound,a_upper_bound) );
  end;

  member procedure not_to_be_like(self in ut_expectation_varchar2, a_mask in varchar2, a_escape_char in varchar2 := null) is
  begin
    ut_utils.debug_log('ut_expectation_varchar2.not_to_be_like(self in ut_expectation, a_mask in varchar2, a_escape_char in varchar2 default null)');
    self.not_to( ut_be_like(a_mask, a_escape_char) );
  end;

  member procedure not_to_match(self in ut_expectation_varchar2, a_pattern in varchar2, a_modifiers in varchar2 default null) is
  begin
    ut_utils.debug_log('ut_expectation_varchar2.not_to_match(self in ut_expectation, a_pattern in varchar2, a_modifiers in varchar2 default null)');
    self.not_to( ut_match(a_pattern, a_modifiers) );
  end;

end;
/
