create or replace type body ut_expectation as
  /*
  utPLSQL - Version X.X.X.X 
  Copyright 2016 - 2017 utPLSQL Project

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
  */
  final member procedure add_assert_result( self in ut_expectation,  a_assert_result boolean, a_matcher_name varchar2,
    a_assert_info varchar2, a_error_message varchar2, a_expected_value_string in varchar2 := null, a_expected_data_type varchar2 := null
  ) is
    l_assert_info varchar2(4000);
  begin
    l_assert_info := case when a_assert_info is not null then ' '||a_assert_info end;
    ut_utils.debug_log('ut_expectation.add_assert_result :' || ut_utils.to_test_result(a_assert_result) || ':' || message);
    ut_assert_processor.add_assert_result(
      ut_assert_result(
        a_matcher_name, l_assert_info, a_error_message, ut_utils.to_test_result(coalesce(a_assert_result,false)),
        a_expected_data_type, self.actual_data.data_type, a_expected_value_string, self.actual_data.to_string(), self.message
      )
    );
  end;

  member procedure to_equal(self in ut_expectation, a_expected anydata, a_nulls_are_equal boolean := null) is
  begin
    ut_utils.debug_log('ut_expectation.to_equal(self in ut_expectation, a_expected anydata, a_nulls_are_equal boolean := null)');
    self.to_( ut_equal(a_expected) );
  end;

  member procedure to_equal(self in ut_expectation, a_expected blob, a_nulls_are_equal boolean := null) is
  begin
    ut_utils.debug_log('ut_expectation.to_equal(self in ut_expectation, a_expected blob, a_nulls_are_equal boolean := null)');
    self.to_( ut_equal(a_expected) );
  end;

  member procedure to_equal(self in ut_expectation, a_expected boolean, a_nulls_are_equal boolean := null) is
  begin
    ut_utils.debug_log('ut_expectation.to_equal(self in ut_expectation, a_expected boolean, a_nulls_are_equal boolean := null)');
    self.to_( ut_equal(a_expected) );
  end;

  member procedure to_equal(self in ut_expectation, a_expected clob, a_nulls_are_equal boolean := null) is
  begin
    ut_utils.debug_log('ut_expectation.to_equal(self in ut_expectation, a_expected clob, a_nulls_are_equal boolean := null)');
    self.to_( ut_equal(a_expected) );
  end;

  member procedure to_equal(self in ut_expectation, a_expected date, a_nulls_are_equal boolean := null) is
  begin
    ut_utils.debug_log('ut_expectation.to_equal(self in ut_expectation, a_expected date, a_nulls_are_equal boolean := null)');
    self.to_( ut_equal(a_expected) );
  end;

  member procedure to_equal(self in ut_expectation, a_expected number, a_nulls_are_equal boolean := null) is
  begin
    ut_utils.debug_log('ut_expectation.to_equal(self in ut_expectation, a_expected number, a_nulls_are_equal boolean := null)');
    self.to_( ut_equal(a_expected) );
  end;

  member procedure to_equal(self in ut_expectation, a_expected sys_refcursor, a_nulls_are_equal boolean := null) is
  begin
    ut_utils.debug_log('ut_expectation.to_equal(self in ut_expectation, a_expected sys_refcursor, a_nulls_are_equal boolean := null)');
    self.to_( ut_equal(a_expected) );
  end;

  member procedure to_equal(self in ut_expectation, a_expected timestamp_unconstrained, a_nulls_are_equal boolean := null) is
  begin
    ut_utils.debug_log('ut_expectation.to_equal(self in ut_expectation, a_expected timestamp_unconstrained, a_nulls_are_equal boolean := null)');
    self.to_( ut_equal(a_expected) );
  end;

  member procedure to_equal(self in ut_expectation, a_expected timestamp_ltz_unconstrained, a_nulls_are_equal boolean := null) is
  begin
    ut_utils.debug_log('ut_expectation.to_equal(self in ut_expectation, a_expected timestamp_ltz_unconstrained, a_nulls_are_equal boolean := null)');
    self.to_( ut_equal(a_expected) );
  end;

  member procedure to_equal(self in ut_expectation, a_expected timestamp_tz_unconstrained, a_nulls_are_equal boolean := null) is
  begin
    ut_utils.debug_log('ut_expectation.to_equal(self in ut_expectation, a_expected timestamp_tz_unconstrained, a_nulls_are_equal boolean := null)');
    self.to_( ut_equal(a_expected) );
  end;

  member procedure to_equal(self in ut_expectation, a_expected varchar2, a_nulls_are_equal boolean := null) is
  begin
    ut_utils.debug_log('ut_expectation.to_equal(self in ut_expectation, a_expected varchar2, a_nulls_are_equal boolean := null)');
    self.to_( ut_equal(a_expected) );
  end;

  member procedure to_equal(self in ut_expectation, a_expected yminterval_unconstrained, a_nulls_are_equal boolean := null) is
  begin
    ut_utils.debug_log('ut_expectation.to_equal(self in ut_expectation, a_expected yminterval_unconstrained, a_nulls_are_equal boolean := null)');
    self.to_( ut_equal(a_expected) );
  end;

  member procedure to_equal(self in ut_expectation, a_expected dsinterval_unconstrained, a_nulls_are_equal boolean := null) is
  begin
    ut_utils.debug_log('ut_expectation.to_equal(self in ut_expectation, a_expected dsinterval_unconstrained, a_nulls_are_equal boolean := null)');
    self.to_( ut_equal(a_expected) );
  end;

  final member procedure to_(self in ut_expectation, a_matcher ut_matcher) is
    l_assert_result boolean;
    l_matcher_name   varchar2(4000);
    l_matcher   ut_matcher := a_matcher;
  begin
    ut_utils.debug_log('ut_expectation.to_(self in ut_expectation, a_matcher ut_matcher)');

    l_assert_result := l_matcher.run_matcher( self.actual_data );
    l_matcher_name   := 'to '||l_matcher.name;
    if l_matcher.expected is not null then
      add_assert_result( l_assert_result, l_matcher_name, l_matcher.additional_info, l_matcher.error_message
        , l_matcher.expected.to_string(), l_matcher.expected.data_type );
    else
      add_assert_result( l_assert_result, l_matcher_name, l_matcher.additional_info, l_matcher.error_message );
    end if;
  end;

  final member procedure not_to(self in ut_expectation, a_matcher ut_matcher) is
    l_assert_result boolean;
    l_matcher_name   varchar2(4000);
    l_matcher   ut_matcher := a_matcher;
  begin
    ut_utils.debug_log('ut_expectation.not_to(self in ut_expectation, a_matcher ut_matcher)');

    l_assert_result := not l_matcher.run_matcher( self.actual_data );
    l_matcher_name   := 'not to '||l_matcher.name;
    if l_matcher.expected is not null then
      add_assert_result( l_assert_result, l_matcher_name, l_matcher.additional_info, l_matcher.error_message
        , l_matcher.expected.to_string(), l_matcher.expected.data_type );
    else
      add_assert_result( l_assert_result, l_matcher_name, l_matcher.additional_info, l_matcher.error_message );
    end if;
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

end;
/
