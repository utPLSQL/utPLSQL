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

  final member procedure not_to_be_null(self in ut_expectation) is
  begin
    ut_utils.debug_log('ut_expectation.to_be_null');
    self.not_to( ut_be_null() );
  end;

  final member procedure not_to_be_not_null(self in ut_expectation) is
  begin
    ut_utils.debug_log('ut_expectation.to_be_not_null');
    self.not_to( ut_be_not_null() );
  end;

  member procedure not_to_equal(self in ut_expectation, a_expected anydata, a_nulls_are_equal boolean := null) is
  begin
    ut_utils.debug_log('ut_expectation.not_to_equal(self in ut_expectation, a_expected anydata, a_nulls_are_equal boolean := null)');
    self.not_to( ut_equal(a_expected, a_nulls_are_equal) );
  end;

  member procedure not_to_equal(self in ut_expectation, a_expected blob, a_nulls_are_equal boolean := null) is
  begin
    ut_utils.debug_log('ut_expectation.not_to_equal(self in ut_expectation, a_expected blob, a_nulls_are_equal boolean := null)');
    self.not_to( ut_equal(a_expected, a_nulls_are_equal) );
  end;

  member procedure not_to_equal(self in ut_expectation, a_expected boolean, a_nulls_are_equal boolean := null) is
  begin
    ut_utils.debug_log('ut_expectation.not_to_equal(self in ut_expectation, a_expected boolean, a_nulls_are_equal boolean := null)');
    self.not_to( ut_equal(a_expected, a_nulls_are_equal) );
  end;

  member procedure not_to_equal(self in ut_expectation, a_expected clob, a_nulls_are_equal boolean := null) is
  begin
    ut_utils.debug_log('ut_expectation.not_to_equal(self in ut_expectation, a_expected clob, a_nulls_are_equal boolean := null)');
    self.not_to( ut_equal(a_expected, a_nulls_are_equal) );
  end;

  member procedure not_to_equal(self in ut_expectation, a_expected date, a_nulls_are_equal boolean := null) is
  begin
    ut_utils.debug_log('ut_expectation.not_to_equal(self in ut_expectation, a_expected date, a_nulls_are_equal boolean := null)');
    self.not_to( ut_equal(a_expected, a_nulls_are_equal) );
  end;

  member procedure not_to_equal(self in ut_expectation, a_expected number, a_nulls_are_equal boolean := null) is
  begin
    ut_utils.debug_log('ut_expectation.not_to_equal(self in ut_expectation, a_expected number, a_nulls_are_equal boolean := null)');
    self.not_to( ut_equal(a_expected, a_nulls_are_equal) );
  end;

  member procedure not_to_equal(self in ut_expectation, a_expected sys_refcursor, a_exclude varchar2 := null, a_nulls_are_equal boolean := null) is
  begin
    ut_utils.debug_log('ut_expectation.not_to_equal(self in ut_expectation, a_expected sys_refcursor, a_exclude varchar2 := null, a_nulls_are_equal boolean := null)');
    self.not_to( ut_equal(a_expected, a_exclude, a_nulls_are_equal) );
  end;

  member procedure not_to_equal(self in ut_expectation, a_expected sys_refcursor, a_exclude ut_varchar2_list, a_nulls_are_equal boolean := null) is
  begin
    ut_utils.debug_log('ut_expectation.not_to_equal(self in ut_expectation, a_expected sys_refcursor, a_exclude ut_varchar2_list, a_nulls_are_equal boolean := null)');
    self.not_to( ut_equal(a_expected, a_exclude, a_nulls_are_equal) );
  end;

  member procedure not_to_equal(self in ut_expectation, a_expected timestamp_unconstrained, a_nulls_are_equal boolean := null) is
  begin
    ut_utils.debug_log('ut_expectation.not_to_equal(self in ut_expectation, a_expected timestamp_unconstrained, a_nulls_are_equal boolean := null)');
    self.not_to( ut_equal(a_expected, a_nulls_are_equal) );
  end;

  member procedure not_to_equal(self in ut_expectation, a_expected timestamp_ltz_unconstrained, a_nulls_are_equal boolean := null) is
  begin
    ut_utils.debug_log('ut_expectation.not_to_equal(self in ut_expectation, a_expected timestamp_ltz_unconstrained, a_nulls_are_equal boolean := null)');
    self.not_to( ut_equal(a_expected, a_nulls_are_equal) );
  end;

  member procedure not_to_equal(self in ut_expectation, a_expected timestamp_tz_unconstrained, a_nulls_are_equal boolean := null) is
  begin
    ut_utils.debug_log('ut_expectation.not_to_equal(self in ut_expectation, a_expected timestamp_tz_unconstrained, a_nulls_are_equal boolean := null)');
    self.not_to( ut_equal(a_expected, a_nulls_are_equal) );
  end;

  member procedure not_to_equal(self in ut_expectation, a_expected varchar2, a_nulls_are_equal boolean := null) is
  begin
    ut_utils.debug_log('ut_expectation.not_to_equal(self in ut_expectation, a_expected varchar2, a_nulls_are_equal boolean := null)');
    self.not_to( ut_equal(a_expected, a_nulls_are_equal) );
  end;

  member procedure not_to_equal(self in ut_expectation, a_expected yminterval_unconstrained, a_nulls_are_equal boolean := null) is
  begin
    ut_utils.debug_log('ut_expectation.not_to_equal(self in ut_expectation, a_expected yminterval_unconstrained, a_nulls_are_equal boolean := null)');
    self.not_to( ut_equal(a_expected, a_nulls_are_equal) );
  end;

  member procedure not_to_equal(self in ut_expectation, a_expected dsinterval_unconstrained, a_nulls_are_equal boolean := null) is
  begin
    ut_utils.debug_log('ut_expectation.not_to_equal(self in ut_expectation, a_expected dsinterval_unconstrained, a_nulls_are_equal boolean := null)');
    self.not_to( ut_equal(a_expected, a_nulls_are_equal) );
  end;

end;
/
