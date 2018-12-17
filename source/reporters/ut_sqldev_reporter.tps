create or replace type ut_sqldev_reporter force under ut_output_reporter_base(
  /*
  utPLSQL - Version 3
  Copyright 2016 - 2018 utPLSQL Project

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
  
  -- TODO: grant execute on ut_sqldev_reporter to public;
  -- TODO: handle public synonym
  -- TODO: unit test

  /**
   * The SQL Developer reporter.
   * Provides test results in a XML format, to consumed by clients such as SQL Developer interested progressing details.
   */
  constructor function ut_sqldev_reporter(self in out nocopy ut_sqldev_reporter) return self as result,

  /**
   * Provides meta data of complete run in advance.
   * Used in IDE to show total tests and initialize a progress bar.
   */
  overriding member procedure before_calling_run(self in out nocopy ut_sqldev_reporter, a_run in ut_run),

  /**
   * Provides meta data of test to be called.
   */
  overriding member procedure before_calling_test(self in out nocopy ut_sqldev_reporter, a_test in ut_test),

  /**
   * Provides meta data of a completed test with runtime, status, 
   */
  overriding member procedure after_calling_test(self in out nocopy ut_sqldev_reporter, a_test in ut_test),

  /**
   * Provides closing tag with runtime summary.
   */
  overriding member procedure after_calling_run(self in out nocopy ut_sqldev_reporter, a_run in ut_run),

  /**
   * Provides the description of this reporter.
   */
  overriding member function get_description return varchar2
)
not final
/
