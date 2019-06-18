create or replace type body ut_xunit_reporter is
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

  constructor function ut_xunit_reporter(self in out nocopy ut_xunit_reporter) return self as result is
  begin
    self.init($$plsql_unit);
    return;
  end;

  overriding member function get_description return varchar2 as
  begin
    return 'Depracated reporter. Please use Junit.
    Provides outcomes in a format conforming with JUnit 4 and above as defined in: https://gist.github.com/kuzuha/232902acab1344d6b578';
  end;

end;
/
