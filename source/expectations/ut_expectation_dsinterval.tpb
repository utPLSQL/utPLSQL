create or replace type body ut_expectation_dsinterval as
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
  overriding member procedure to_equal(self in ut_expectation_dsinterval, a_expected dsinterval_unconstrained, a_nulls_are_equal boolean := null) is
  begin
    ut_utils.debug_log('ut_expectation_dsinterval.to_equal(self in ut_expectation, a_expected dsinterval_unconstrained)');
    self.to_( ut_equal(a_expected, a_nulls_are_equal) );
  end;

  member procedure to_be_between(self in ut_expectation_dsinterval, a_lower_bound dsinterval_unconstrained, a_upper_bound dsinterval_unconstrained) is
  begin
    ut_utils.debug_log('ut_expectation_dsinterval.to_be_between(self in ut_expectation_dsinterval, a_lower_bound dsinterval_unconstrained, a_upper_bound dsinterval_unconstrained)');
    self.to_( ut_be_between(a_lower_bound,a_upper_bound) );
  end;
  
  member procedure to_be_greater_or_equal(self in ut_expectation_dsinterval, a_expected dsinterval_unconstrained) is 
  begin 
    ut_utils.debug_log('ut_expectation_dsinterval.to_be_greater_or_equal(self in ut_expectation_dsinterval, a_expected dsinterval_unconstrained)');
    self.to_( ut_be_greater_or_equal (a_expected) );
  end;
  member procedure to_be_greater_than(self in ut_expectation_dsinterval, a_expected dsinterval_unconstrained) is 
  begin 
    ut_utils.debug_log('ut_expectation_dsinterval.to_be_greater_than(self in ut_expectation_dsinterval, a_expected dsinterval_unconstrained)');
    self.to_( ut_be_greater_than (a_expected) );
  end;
  member procedure to_be_less_or_equal(self in ut_expectation_dsinterval, a_expected dsinterval_unconstrained) is 
  begin 
    ut_utils.debug_log('ut_expectation_dsinterval.to_be_less_or_equal(self in ut_expectation_dsinterval, a_expected dsinterval_unconstrained)');
    self.to_( ut_be_less_or_equal (a_expected) );
  end;
  member procedure to_be_less_than(self in ut_expectation_dsinterval, a_expected dsinterval_unconstrained) is 
  begin 
    ut_utils.debug_log('ut_expectation_dsinterval.to_be_less_than(self in ut_expectation_dsinterval, a_expected dsinterval_unconstrained)');
    self.to_( ut_be_less_than (a_expected) );
  end;
  
  overriding member procedure not_to_equal(self in ut_expectation_dsinterval, a_expected dsinterval_unconstrained, a_nulls_are_equal boolean := null) is
  begin
    ut_utils.debug_log('ut_expectation_dsinterval.not_to_equal(self in ut_expectation, a_expected dsinterval_unconstrained)');
    self.not_to( ut_equal(a_expected, a_nulls_are_equal) );
  end;
  
  member procedure not_to_be_between(self in ut_expectation_dsinterval, a_lower_bound dsinterval_unconstrained, a_upper_bound dsinterval_unconstrained) is
  begin
    ut_utils.debug_log('ut_expectation_dsinterval.not_to_be_between(self in ut_expectation_dsinterval, a_lower_bound dsinterval_unconstrained, a_upper_bound dsinterval_unconstrained)');
    self.not_to( ut_be_between(a_lower_bound,a_upper_bound) );
  end;
  
  member procedure not_to_be_greater_or_equal(self in ut_expectation_dsinterval, a_expected dsinterval_unconstrained) is 
  begin 
    ut_utils.debug_log('ut_expectation_dsinterval.not_to_be_greater_or_equal(self in ut_expectation_dsinterval, a_expected dsinterval_unconstrained)');
    self.not_to( ut_be_greater_or_equal (a_expected) );
  end;
  member procedure not_to_be_greater_than(self in ut_expectation_dsinterval, a_expected dsinterval_unconstrained) is 
  begin 
    ut_utils.debug_log('ut_expectation_dsinterval.not_to_be_greater_than(self in ut_expectation_dsinterval, a_expected dsinterval_unconstrained)');
    self.not_to( ut_be_greater_than (a_expected) );
  end;
  member procedure not_to_be_less_or_equal(self in ut_expectation_dsinterval, a_expected dsinterval_unconstrained) is 
  begin 
    ut_utils.debug_log('ut_expectation_dsinterval.not_to_be_less_or_equal(self in ut_expectation_dsinterval, a_expected dsinterval_unconstrained)');
    self.not_to( ut_be_less_or_equal (a_expected) );
  end;
  member procedure not_to_be_less_than(self in ut_expectation_dsinterval, a_expected dsinterval_unconstrained) is 
  begin 
    ut_utils.debug_log('ut_expectation_dsinterval.not_to_be_less_than(self in ut_expectation_dsinterval, a_expected dsinterval_unconstrained)');
    self.not_to( ut_be_less_than (a_expected) );
  end;

end;
/
