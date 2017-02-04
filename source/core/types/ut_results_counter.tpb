create or replace type body ut_results_counter as
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
  constructor function ut_results_counter(self in out nocopy ut_results_counter) return self as result is
  begin
    self.ignored_count := 0;
    self.success_count := 0;
    self.failure_count := 0;
    self.errored_count := 0;
    return;
  end;

  constructor function ut_results_counter(self in out nocopy ut_results_counter, a_status integer) return self as result is
  begin
    self.ignored_count := case when a_status = ut_utils.tr_ignore then 1 else 0 end;
    self.success_count := case when a_status = ut_utils.tr_success then 1 else 0 end;
    self.failure_count := case when a_status = ut_utils.tr_failure then 1 else 0 end;
    self.errored_count := case when a_status = ut_utils.tr_error then 1 else 0 end;
    return;
  end;

  member procedure sum_counter_values(self in out nocopy ut_results_counter, a_item ut_results_counter) is
  begin
    self.ignored_count  := self.ignored_count + a_item.ignored_count;
    self.success_count  := self.success_count + a_item.success_count;
    self.failure_count  := self.failure_count + a_item.failure_count;
    self.errored_count  := self.errored_count + a_item.errored_count;
  end;

  member function total_count return integer is
  begin
    return self.ignored_count + self.success_count + self.failure_count + self.errored_count;
  end;

  member function result_status return integer is
    l_result integer;
  begin
    if self.errored_count > 0 then
      l_result := ut_utils.tr_error;
    elsif self.failure_count > 0 then
      l_result := ut_utils.tr_failure;
    elsif self.success_count > 0 then
      l_result := ut_utils.tr_success;
    elsif self.ignored_count > 0 then
      l_result := ut_utils.tr_ignore;
    else
      l_result := ut_utils.tr_error;
    end if;
    return l_result;
  end;

end;
/
