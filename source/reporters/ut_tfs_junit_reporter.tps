create or replace type ut_tfs_junit_reporter under ut_output_reporter_base(
  /*
  utPLSQL - Version 3
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
  /**
   * The JUnit reporter for publishing results in TFS/VSTS 
   * Provides outcomes in a format conforming with specs as defined in:
   *  https://docs.microsoft.com/en-us/vsts/build-release/tasks/test/publish-test-results?view=vsts
   */
     
  constructor function ut_tfs_junit_reporter(
  self in out nocopy ut_tfs_junit_reporter
  ) return self as result,

  overriding member procedure after_calling_run(self in out nocopy ut_tfs_junit_reporter, a_run in ut_run),
  member procedure junit_version_one(self in out nocopy ut_tfs_junit_reporter, a_run in ut_run),

  overriding member function get_description return varchar2
)
not final
/