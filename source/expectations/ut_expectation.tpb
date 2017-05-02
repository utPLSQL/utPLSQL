create or replace type body ut_expectation as
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
  member procedure to_equal(self in ut_expectation, a_expected anydata, a_nulls_are_equal boolean := null) is
  begin
    ut_utils.debug_log('ut_expectation.to_equal(self in ut_expectation, a_expected anydata, a_nulls_are_equal boolean := null)');
    self.to_( ut_equal(a_expected, a_nulls_are_equal) );
  end;

  member procedure to_equal(self in ut_expectation, a_expected blob, a_nulls_are_equal boolean := null) is
  begin
    ut_utils.debug_log('ut_expectation.to_equal(self in ut_expectation, a_expected blob, a_nulls_are_equal boolean := null)');
    self.to_( ut_equal(a_expected, a_nulls_are_equal) );
  end;

  member procedure to_equal(self in ut_expectation, a_expected boolean, a_nulls_are_equal boolean := null) is
  begin
    ut_utils.debug_log('ut_expectation.to_equal(self in ut_expectation, a_expected boolean, a_nulls_are_equal boolean := null)');
    self.to_( ut_equal(a_expected, a_nulls_are_equal) );
  end;

  member procedure to_equal(self in ut_expectation, a_expected clob, a_nulls_are_equal boolean := null) is
  begin
    ut_utils.debug_log('ut_expectation.to_equal(self in ut_expectation, a_expected clob, a_nulls_are_equal boolean := null)');
    self.to_( ut_equal(a_expected, a_nulls_are_equal) );
  end;

  member procedure to_equal(self in ut_expectation, a_expected date, a_nulls_are_equal boolean := null) is
  begin
    ut_utils.debug_log('ut_expectation.to_equal(self in ut_expectation, a_expected date, a_nulls_are_equal boolean := null)');
    self.to_( ut_equal(a_expected, a_nulls_are_equal) );
  end;

  member procedure to_equal(self in ut_expectation, a_expected number, a_nulls_are_equal boolean := null) is
  begin
    ut_utils.debug_log('ut_expectation.to_equal(self in ut_expectation, a_expected number, a_nulls_are_equal boolean := null)');
    self.to_( ut_equal(a_expected, a_nulls_are_equal) );
  end;

  member procedure to_equal(self in ut_expectation, a_expected sys_refcursor, a_exclude varchar2 := null, a_nulls_are_equal boolean := null) is
  begin
    ut_utils.debug_log('ut_expectation.to_equal(self in ut_expectation, a_expected sys_refcursor, a_exclude varchar2 := null, a_nulls_are_equal boolean := null)');
    self.to_( ut_equal(a_expected, a_exclude, a_nulls_are_equal) );
  end;

  member procedure to_equal(self in ut_expectation, a_expected sys_refcursor, a_exclude ut_varchar2_list, a_nulls_are_equal boolean := null) is
  begin
    ut_utils.debug_log('ut_expectation.to_equal(self in ut_expectation, a_expected sys_refcursor, a_exclude ut_varchar2_list, a_nulls_are_equal boolean := null)');
    self.to_( ut_equal(a_expected, a_exclude, a_nulls_are_equal) );
  end;

  member procedure to_equal(self in ut_expectation, a_expected timestamp_unconstrained, a_nulls_are_equal boolean := null) is
  begin
    ut_utils.debug_log('ut_expectation.to_equal(self in ut_expectation, a_expected timestamp_unconstrained, a_nulls_are_equal boolean := null)');
    self.to_( ut_equal(a_expected, a_nulls_are_equal) );
  end;

  member procedure to_equal(self in ut_expectation, a_expected timestamp_ltz_unconstrained, a_nulls_are_equal boolean := null) is
  begin
    ut_utils.debug_log('ut_expectation.to_equal(self in ut_expectation, a_expected timestamp_ltz_unconstrained, a_nulls_are_equal boolean := null)');
    self.to_( ut_equal(a_expected, a_nulls_are_equal) );
  end;

  member procedure to_equal(self in ut_expectation, a_expected timestamp_tz_unconstrained, a_nulls_are_equal boolean := null) is
  begin
    ut_utils.debug_log('ut_expectation.to_equal(self in ut_expectation, a_expected timestamp_tz_unconstrained, a_nulls_are_equal boolean := null)');
    self.to_( ut_equal(a_expected, a_nulls_are_equal) );
  end;

  member procedure to_equal(self in ut_expectation, a_expected varchar2, a_nulls_are_equal boolean := null) is
  begin
    ut_utils.debug_log('ut_expectation.to_equal(self in ut_expectation, a_expected varchar2, a_nulls_are_equal boolean := null)');
    self.to_( ut_equal(a_expected, a_nulls_are_equal) );
  end;

  member procedure to_equal(self in ut_expectation, a_expected yminterval_unconstrained, a_nulls_are_equal boolean := null) is
  begin
    ut_utils.debug_log('ut_expectation.to_equal(self in ut_expectation, a_expected yminterval_unconstrained, a_nulls_are_equal boolean := null)');
    self.to_( ut_equal(a_expected, a_nulls_are_equal) );
  end;

  member procedure to_equal(self in ut_expectation, a_expected dsinterval_unconstrained, a_nulls_are_equal boolean := null) is
  begin
    ut_utils.debug_log('ut_expectation.to_equal(self in ut_expectation, a_expected dsinterval_unconstrained, a_nulls_are_equal boolean := null)');
    self.to_( ut_equal(a_expected, a_nulls_are_equal) );
  end;

  final member procedure to_(self in ut_expectation, a_matcher ut_matcher) is
    l_expectation_result boolean;
    l_matcher       ut_matcher := a_matcher;
    l_message       varchar2(32767);
  begin
    ut_utils.debug_log('ut_expectation.to_(self in ut_expectation, a_matcher ut_matcher)');

    l_expectation_result := l_matcher.run_matcher( self.actual_data );
    l_expectation_result := coalesce(l_expectation_result,false);
    l_message := coalesce( l_matcher.error_message( self.actual_data ), l_matcher.failure_message( self.actual_data ) );
    ut_expectation_processor.add_expectation_result( ut_expectation_result( ut_utils.to_test_result( l_expectation_result ), self.description, l_message ) );
  end;

  final member procedure not_to(self in ut_expectation, a_matcher ut_matcher) is
    l_expectation_result boolean;
    l_matcher       ut_matcher := a_matcher;
    l_message       varchar2(32767);
  begin
    ut_utils.debug_log('ut_expectation.not_to(self in ut_expectation, a_matcher ut_matcher)');

    l_expectation_result := l_matcher.run_matcher_negated( self.actual_data );
    l_expectation_result := coalesce(l_expectation_result,false);
    l_message := coalesce( l_matcher.error_message( self.actual_data ), l_matcher.failure_message_when_negated( self.actual_data ) );
    ut_expectation_processor.add_expectation_result( ut_expectation_result( ut_utils.to_test_result( l_expectation_result ), self.description, l_message ) );
  end;

  final member procedure to_be_null(self in ut_expectation) is
  begin
    ut_utils.debug_log('ut_expectation.to_be_null');
    self.to_( ut_be_null() );
  end;

  final member procedure to_be_not_null(self in ut_expectation) is
  begin
    ut_utils.debug_log('ut_expectation.to_be_not_null');
    self.to_( ut_be_not_null() );
  end;
  
  member procedure to_be_empty(self in ut_expectation) is
  begin
    ut_utils.debug_log('ut_expectation.to_be_empty(self in ut_expectation)');
    self.to_( ut_be_empty () );
  end;
  
  member procedure to_be_between(self in ut_expectation, a_lower_bound date, a_upper_bound date) is 
  begin 
    ut_utils.debug_log('ut_expectation.to_be_between(self in ut_expectation, a_lower_bound date, a_upper_bound date)');
    self.to_( ut_be_between (a_lower_bound, a_upper_bound) );
  end;
  member procedure to_be_between(self in ut_expectation, a_lower_bound number, a_upper_bound number) is 
  begin 
    ut_utils.debug_log('ut_expectation.to_be_between(self in ut_expectation, a_lower_bound number, a_upper_bound number)');
    self.to_( ut_be_between (a_lower_bound, a_upper_bound) );
  end;
  member procedure to_be_between(self in ut_expectation, a_lower_bound varchar2, a_upper_bound varchar2) is 
  begin 
    ut_utils.debug_log('ut_expectation.to_be_between(self in ut_expectation, a_lower_bound varchar2, a_upper_bound varchar2)');
    self.to_( ut_be_between (a_lower_bound, a_upper_bound) );
  end;
  member procedure to_be_between(self in ut_expectation, a_lower_bound timestamp_unconstrained, a_upper_bound timestamp_unconstrained) is 
  begin 
    ut_utils.debug_log('ut_expectation.to_be_between(self in ut_expectation, a_lower_bound timestamp_unconstrained, a_upper_bound timestamp_unconstrained)');
    self.to_( ut_be_between (a_lower_bound, a_upper_bound) );
  end;
  member procedure to_be_between(self in ut_expectation, a_lower_bound timestamp_tz_unconstrained, a_upper_bound timestamp_tz_unconstrained) is 
  begin 
    ut_utils.debug_log('ut_expectation.to_be_between(self in ut_expectation, a_lower_bound timestamp_tz_unconstrained, a_upper_bound timestamp_tz_unconstrained)');
    self.to_( ut_be_between (a_lower_bound, a_upper_bound) );
  end;
  member procedure to_be_between(self in ut_expectation, a_lower_bound timestamp_ltz_unconstrained, a_upper_bound timestamp_ltz_unconstrained) is 
  begin 
    ut_utils.debug_log('ut_expectation.to_be_between(self in ut_expectation, a_lower_bound timestamp_ltz_unconstrained, a_upper_bound timestamp_ltz_unconstrained)');
    self.to_( ut_be_between (a_lower_bound, a_upper_bound) );
  end;
  member procedure to_be_between(self in ut_expectation, a_lower_bound yminterval_unconstrained, a_upper_bound yminterval_unconstrained) is 
  begin 
    ut_utils.debug_log('ut_expectation.to_be_between(self in ut_expectation, a_lower_bound yminterval_unconstrained, a_upper_bound yminterval_unconstrained)');
    self.to_( ut_be_between (a_lower_bound, a_upper_bound) );
  end;
  member procedure to_be_between(self in ut_expectation, a_lower_bound dsinterval_unconstrained, a_upper_bound dsinterval_unconstrained) is 
  begin 
    ut_utils.debug_log('ut_expectation.to_be_between(self in ut_expectation, a_lower_bound dsinterval_unconstrained, a_upper_bound dsinterval_unconstrained)');
    self.to_( ut_be_between (a_lower_bound, a_upper_bound) );
  end;
  
  
  member procedure to_be_greater_or_equal(self in ut_expectation, a_expected date) is 
  begin 
    ut_utils.debug_log('ut_expectation.to_be_greater_or_equal(self in ut_expectation, a_expected date)');
    self.to_( ut_be_greater_or_equal (a_expected) );
  end;
  member procedure to_be_greater_or_equal(self in ut_expectation, a_expected number) is 
  begin 
    ut_utils.debug_log('ut_expectation.to_be_greater_or_equal(self in ut_expectation, a_expected number)');
    self.to_( ut_be_greater_or_equal (a_expected) );
  end;
  member procedure to_be_greater_or_equal(self in ut_expectation, a_expected timestamp_unconstrained) is 
  begin 
    ut_utils.debug_log('ut_expectation.to_be_greater_or_equal(self in ut_expectation, a_expected timestamp_unconstrained)');
    self.to_( ut_be_greater_or_equal (a_expected) );
  end;
  member procedure to_be_greater_or_equal(self in ut_expectation, a_expected timestamp_tz_unconstrained) is 
  begin 
    ut_utils.debug_log('ut_expectation.to_be_greater_or_equal(self in ut_expectation, a_expected timestamp_tz_unconstrained)');
    self.to_( ut_be_greater_or_equal (a_expected) );
  end;
  member procedure to_be_greater_or_equal(self in ut_expectation, a_expected timestamp_ltz_unconstrained) is 
  begin 
    ut_utils.debug_log('ut_expectation.to_be_greater_or_equal(self in ut_expectation, a_expected timestamp_ltz_unconstrained)');
    self.to_( ut_be_greater_or_equal (a_expected) );
  end;
  member procedure to_be_greater_or_equal(self in ut_expectation, a_expected yminterval_unconstrained) is 
  begin 
    ut_utils.debug_log('ut_expectation.to_be_greater_or_equal(self in ut_expectation, a_expected yminterval_unconstrained)');
    self.to_( ut_be_greater_or_equal (a_expected) );
  end;
  member procedure to_be_greater_or_equal(self in ut_expectation, a_expected dsinterval_unconstrained) is 
  begin 
    ut_utils.debug_log('ut_expectation.to_be_greater_or_equal(self in ut_expectation, a_expected dsinterval_unconstrained)');
    self.to_( ut_be_greater_or_equal (a_expected) );
  end;
  
  member procedure to_be_greater_than(self in ut_expectation, a_expected date) is 
  begin 
    ut_utils.debug_log('ut_expectation.to_be_greater_than(self in ut_expectation, a_expected date)');
    self.to_( ut_be_greater_than (a_expected) );
  end;
  member procedure to_be_greater_than(self in ut_expectation, a_expected number) is 
  begin 
    ut_utils.debug_log('ut_expectation.to_be_greater_than(self in ut_expectation, a_expected number)');
    self.to_( ut_be_greater_than (a_expected) );
  end;
  member procedure to_be_greater_than(self in ut_expectation, a_expected timestamp_unconstrained) is 
  begin 
    ut_utils.debug_log('ut_expectation.to_be_greater_than(self in ut_expectation, a_expected timestamp_unconstrained)');
    self.to_( ut_be_greater_than (a_expected) );
  end;
  member procedure to_be_greater_than(self in ut_expectation, a_expected timestamp_tz_unconstrained) is 
  begin 
    ut_utils.debug_log('ut_expectation.to_be_greater_than(self in ut_expectation, a_expected timestamp_tz_unconstrained)');
    self.to_( ut_be_greater_than (a_expected) );
  end;
  member procedure to_be_greater_than(self in ut_expectation, a_expected timestamp_ltz_unconstrained) is 
  begin 
    ut_utils.debug_log('ut_expectation.to_be_greater_than(self in ut_expectation, a_expected timestamp_ltz_unconstrained)');
    self.to_( ut_be_greater_than (a_expected) );
  end;
  member procedure to_be_greater_than(self in ut_expectation, a_expected yminterval_unconstrained) is 
  begin 
    ut_utils.debug_log('ut_expectation.to_be_greater_than(self in ut_expectation, a_expected yminterval_unconstrained)');
    self.to_( ut_be_greater_than (a_expected) );
  end;
  member procedure to_be_greater_than(self in ut_expectation, a_expected dsinterval_unconstrained) is 
  begin 
    ut_utils.debug_log('ut_expectation.to_be_greater_than(self in ut_expectation, a_expected dsinterval_unconstrained)');
    self.to_( ut_be_greater_than (a_expected) );
  end;
  
  member procedure to_be_less_or_equal(self in ut_expectation, a_expected date) is 
  begin 
    ut_utils.debug_log('ut_expectation.to_be_less_or_equal(self in ut_expectation, a_expected date)');
    self.to_( ut_be_less_or_equal (a_expected) );
  end;
  member procedure to_be_less_or_equal(self in ut_expectation, a_expected number) is 
  begin 
    ut_utils.debug_log('ut_expectation.to_be_less_or_equal(self in ut_expectation, a_expected number)');
    self.to_( ut_be_less_or_equal (a_expected) );
  end;
  member procedure to_be_less_or_equal(self in ut_expectation, a_expected timestamp_unconstrained) is 
  begin 
    ut_utils.debug_log('ut_expectation.to_be_less_or_equal(self in ut_expectation, a_expected timestamp_unconstrained)');
    self.to_( ut_be_less_or_equal (a_expected) );
  end;
  member procedure to_be_less_or_equal(self in ut_expectation, a_expected timestamp_tz_unconstrained) is 
  begin 
    ut_utils.debug_log('ut_expectation.to_be_less_or_equal(self in ut_expectation, a_expected timestamp_tz_unconstrained)');
    self.to_( ut_be_less_or_equal (a_expected) );
  end;
  member procedure to_be_less_or_equal(self in ut_expectation, a_expected timestamp_ltz_unconstrained) is 
  begin 
    ut_utils.debug_log('ut_expectation.to_be_less_or_equal(self in ut_expectation, a_expected timestamp_ltz_unconstrained)');
    self.to_( ut_be_less_or_equal (a_expected) );
  end;
  member procedure to_be_less_or_equal(self in ut_expectation, a_expected yminterval_unconstrained) is 
  begin 
    ut_utils.debug_log('ut_expectation.to_be_less_or_equal(self in ut_expectation, a_expected yminterval_unconstrained)');
    self.to_( ut_be_less_or_equal (a_expected) );
  end;
  member procedure to_be_less_or_equal(self in ut_expectation, a_expected dsinterval_unconstrained) is 
  begin 
    ut_utils.debug_log('ut_expectation.to_be_less_or_equal(self in ut_expectation, a_expected dsinterval_unconstrained)');
    self.to_( ut_be_less_or_equal (a_expected) );
  end;
  
  member procedure to_be_less_than(self in ut_expectation, a_expected date) is 
  begin 
    ut_utils.debug_log('ut_expectation.to_be_less_than(self in ut_expectation, a_expected date');
    self.to_( ut_be_less_than (a_expected) );
  end;
  member procedure to_be_less_than(self in ut_expectation, a_expected number) is 
  begin 
    ut_utils.debug_log('ut_expectation.to_be_less_than(self in ut_expectation, a_expected number');
    self.to_( ut_be_less_than (a_expected) );
  end;
  member procedure to_be_less_than(self in ut_expectation, a_expected timestamp_unconstrained) is 
  begin 
    ut_utils.debug_log('ut_expectation.to_be_less_than(self in ut_expectation, a_expected timestamp_unconstrained)');
    self.to_( ut_be_less_than (a_expected) );
  end;
  member procedure to_be_less_than(self in ut_expectation, a_expected timestamp_tz_unconstrained) is 
  begin 
    ut_utils.debug_log('ut_expectation.to_be_less_than(self in ut_expectation, a_expected timestamp_tz_unconstrained)');
    self.to_( ut_be_less_than (a_expected) );
  end;
  member procedure to_be_less_than(self in ut_expectation, a_expected timestamp_ltz_unconstrained) is 
  begin 
    ut_utils.debug_log('ut_expectation.to_be_less_than(self in ut_expectation, a_expected timestamp_ltz_unconstrained)');
    self.to_( ut_be_less_than (a_expected) );
  end;
  member procedure to_be_less_than(self in ut_expectation, a_expected yminterval_unconstrained) is 
  begin 
    ut_utils.debug_log('ut_expectation.to_be_less_than(self in ut_expectation, a_expected yminterval_unconstrained)');
    self.to_( ut_be_less_than (a_expected) );
  end;
  member procedure to_be_less_than(self in ut_expectation, a_expected dsinterval_unconstrained) is 
  begin 
    ut_utils.debug_log('ut_expectation.to_be_less_than(self in ut_expectation, a_expected dsinterval_unconstrained)');
    self.to_( ut_be_less_than (a_expected) );
  end;
  
  member procedure to_be_like(self in ut_expectation, a_mask in varchar2, a_escape_char in varchar2 := null) is 
  begin 
    ut_utils.debug_log('ut_expectation.to_be_like(self in ut_expectation, a_mask in varchar2, a_escape_char in varchar2 := null)');
    self.to_( ut_be_like (a_mask,a_escape_char) );
  end;
  
  member procedure to_match(self in ut_expectation, a_pattern in varchar2, a_modifiers in varchar2 default null) is
  begin 
    ut_utils.debug_log('ut_expectation.to_match(self in ut_expectation, a_pattern in varchar2, a_modifiers in varchar2 default null)');
    self.to_( ut_match (a_pattern,a_modifiers) );
  end;

end;
/
