create or replace type body ut_coverage_html_reporter is
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

  constructor function ut_coverage_html_reporter(
    self in out nocopy ut_coverage_html_reporter,
    a_project_name varchar2 := null,
    a_html_report_assets_path varchar2 := null
  ) return self as result is
  begin
    self.init($$plsql_unit);
    self.project_name := a_project_name;
    assets_path := nvl(a_html_report_assets_path, ut_coverage_report_html_helper.get_default_html_assets_path());
    return;
  end;

  overriding member procedure after_calling_run(self in out nocopy ut_coverage_html_reporter, a_run in ut_run) as
    l_report_lines  ut_varchar2_list;
    l_coverage_data ut_coverage.t_coverage;
  begin
    ut_coverage.coverage_stop();
    l_coverage_data := ut_coverage.get_coverage_data(a_run.coverage_options);

    self.print_clob( ut_coverage_report_html_helper.get_index( a_coverage_data => l_coverage_data,a_assets_path => self.assets_path, a_project_name=> self.project_name ));
  end;


  overriding member function get_description return varchar2 as
  begin
    return 'Generates a HTML coverage report with summary and line by line information on code coverage.' || chr(10) ||
           'Based on open-source simplecov-html coverage reporter for Ruby.' || chr(10) ||
           'Includes source code in the report.';
  end;

end;
/
