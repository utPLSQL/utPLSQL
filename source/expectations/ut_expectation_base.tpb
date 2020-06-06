create or replace type body ut_expectation_base as
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
  member procedure to_(self in ut_expectation_base, a_matcher ut_matcher_base) is
    l_expectation_result boolean;
    l_matcher       ut_matcher := treat(a_matcher as ut_matcher);
    l_message       varchar2(32767);
  begin
    if l_matcher.is_negated() then
      self.not_to( a_matcher );
    else
      l_expectation_result := l_matcher.run_matcher( self.actual_data );
      l_expectation_result := coalesce(l_expectation_result,false);
      l_message := coalesce( l_matcher.error_message( self.actual_data ), l_matcher.failure_message( self.actual_data ) );
      ut_expectation_processor.add_expectation_result( ut_expectation_result( ut_utils.to_test_result( l_expectation_result ), self.description, l_message ) );
    end if;
  end;

  member procedure not_to(self in ut_expectation_base, a_matcher ut_matcher_base) is
    l_expectation_result boolean;
    l_matcher       ut_matcher := treat(a_matcher as ut_matcher);
    l_message       varchar2(32767);
  begin
    l_expectation_result := coalesce( l_matcher.run_matcher_negated( self.actual_data ), false );

    l_message := coalesce( l_matcher.error_message( self.actual_data ), l_matcher.failure_message_when_negated( self.actual_data ) );
    ut_expectation_processor.add_expectation_result( ut_expectation_result( ut_utils.to_test_result( l_expectation_result ), self.description, l_message ) );
  end;
end;
/  