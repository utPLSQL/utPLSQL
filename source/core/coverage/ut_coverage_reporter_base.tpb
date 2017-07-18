create or replace type body ut_coverage_reporter_base is
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

  overriding final member procedure before_calling_run(self in out nocopy ut_coverage_reporter_base, a_run ut_run) as
  begin
    (self as ut_reporter_base).before_calling_run(a_run);
    ut_coverage.coverage_start();
  end;

  overriding final member procedure before_calling_before_all(self in out nocopy ut_coverage_reporter_base, a_suite in ut_logical_suite) is
  begin
    ut_coverage.coverage_resume();
  end;
  overriding final member procedure after_calling_before_all (self in out nocopy ut_coverage_reporter_base, a_suite in ut_logical_suite) is
  begin
      ut_coverage.coverage_pause();
  end;

  overriding final member procedure before_calling_before_each(self in out nocopy ut_coverage_reporter_base, a_suite in ut_test) is
  begin
    ut_coverage.coverage_resume();
  end;
  overriding final member procedure after_calling_before_each (self in out nocopy ut_coverage_reporter_base, a_suite in ut_test) is
  begin
      ut_coverage.coverage_pause();
  end;

  overriding final member procedure before_calling_before_test(self in out nocopy ut_coverage_reporter_base, a_test in ut_test) is
  begin
    ut_coverage.coverage_resume();
  end;
  overriding final member procedure after_calling_before_test (self in out nocopy ut_coverage_reporter_base, a_test in ut_test) is
  begin
      ut_coverage.coverage_pause();
  end;

  overriding final member procedure before_calling_test_execute(self in out nocopy ut_coverage_reporter_base, a_test in ut_test) is
  begin
    ut_coverage.coverage_resume();
  end;
  overriding final member procedure after_calling_test_execute (self in out nocopy ut_coverage_reporter_base, a_test in ut_test) is
  begin
      ut_coverage.coverage_pause();
  end;

  overriding final member procedure before_calling_after_test(self in out nocopy ut_coverage_reporter_base, a_test in ut_test) is
  begin
    ut_coverage.coverage_resume();
  end;
  overriding final member procedure after_calling_after_test (self in out nocopy ut_coverage_reporter_base, a_test in ut_test) is
  begin
      ut_coverage.coverage_pause();
  end;

  overriding final member procedure before_calling_after_each(self in out nocopy ut_coverage_reporter_base, a_suite in ut_test) is
  begin
    ut_coverage.coverage_resume();
  end;
  overriding final member procedure after_calling_after_each (self in out nocopy ut_coverage_reporter_base, a_suite in ut_test) is
  begin
      ut_coverage.coverage_pause();
  end;

  overriding final member procedure before_calling_after_all(self in out nocopy ut_coverage_reporter_base, a_suite in ut_logical_suite) is
  begin
    ut_coverage.coverage_resume();
  end;
  overriding final member procedure after_calling_after_all (self in out nocopy ut_coverage_reporter_base, a_suite in ut_logical_suite) is
  begin
      ut_coverage.coverage_pause();
  end;

end;
/
