create or replace type ut_suite  under ut_logical_suite (
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
  /**
  * The procedure to be invoked before all of the items of the suite (executed once)
  * Procedure exists within the package of the suite
  */
  before_all_list ut_executables,

  /**
  * The procedure to be invoked after all of the items of the suite (executed once)
  * Procedure exists within the package of the suite
  */
  after_all_list ut_executables,
  constructor function ut_suite (
    self in out nocopy ut_suite, a_object_owner varchar2, a_object_name varchar2
  ) return self as result,
  overriding member function do_execute(self in out nocopy ut_suite) return boolean,
  overriding member function get_error_stack_traces(self ut_suite) return ut_varchar2_list,
  overriding member function get_serveroutputs return clob
) not final
/
