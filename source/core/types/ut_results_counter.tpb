create or replace type body ut_results_counter as
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
  constructor function ut_results_counter(self in out nocopy ut_results_counter) return self as result is
  begin
    self.disabled_count := 0;
    self.success_count  := 0;
    self.failure_count  := 0;
    self.errored_count  := 0;
    self.warnings_count := 0;
    return;
  end;

  member procedure set_counter_values(self in out nocopy ut_results_counter, a_status integer) is
  begin
    self.disabled_count := case when a_status = ut_utils.gc_disabled then 1 else 0 end;
    self.success_count  := case when a_status = ut_utils.gc_success then 1 else 0 end;
    self.failure_count  := case when a_status = ut_utils.gc_failure then 1 else 0 end;
    self.errored_count  := case when a_status = ut_utils.gc_error then 1 else 0 end;
  end;

  member procedure sum_counter_values(self in out nocopy ut_results_counter, a_item ut_results_counter) is
  begin
    self.disabled_count := self.disabled_count + a_item.disabled_count;
    self.success_count  := self.success_count + a_item.success_count;
    self.failure_count  := self.failure_count + a_item.failure_count;
    self.errored_count  := self.errored_count + a_item.errored_count;
    self.warnings_count := self.warnings_count + a_item.warnings_count;
  end;

  member procedure increase_warning_count(self in out nocopy ut_results_counter, a_count integer := 1) is
  begin
    self.warnings_count := self.warnings_count + nvl(a_count,0);
  end;

  member function total_count return integer is
  begin
    --skip warnings here
    return self.disabled_count + self.success_count + self.failure_count + self.errored_count;
  end;

  member function result_status return integer is
    l_result integer;
  begin
    if self.errored_count > 0 then
      l_result := ut_utils.gc_error;
    elsif self.failure_count > 0 then
      l_result := ut_utils.gc_failure;
    elsif self.success_count > 0 then
      l_result := ut_utils.gc_success;
    elsif self.disabled_count > 0 then
      l_result := ut_utils.gc_disabled;
    else
      l_result := ut_utils.gc_error;
    end if;
    return l_result;
  end;

end;
/
