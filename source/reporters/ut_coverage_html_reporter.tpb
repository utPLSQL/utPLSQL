create or replace type body ut_coverage_html_reporter is
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

  constructor function ut_coverage_html_reporter(self in out nocopy ut_coverage_html_reporter, a_project_name varchar2 := null, a_schema_names ut_varchar2_list := null) return self as result is
  begin
    self.init($$plsql_unit);
    self.schema_names := a_schema_names;
    self.project_name := a_project_name;
    return;
  end;

  overriding member procedure before_calling_run(self in out nocopy ut_coverage_html_reporter, a_run ut_run) as
  begin
    (self as ut_reporter_base).before_calling_run(a_run);
    coverage_id := ut_coverage.coverage_start();
  end;

  overriding member procedure after_calling_run(self in out nocopy ut_coverage_html_reporter, a_run in ut_run) as
    l_report_lines  ut_varchar2_list;
    l_coverage_data ut_coverage.t_coverage;
    l_schema_names  ut_varchar2_list;
  begin
    ut_coverage.coverage_stop();
    l_schema_names := nvl(self.schema_names, ut_coverage.get_schema_names_from_run(a_run));
    l_coverage_data := ut_coverage.get_coverage_data(l_schema_names);

    l_report_lines := ut_utils.clob_to_table(ut_coverage_report_html_helper.get_index( l_coverage_data, self.project_name ));
    for i in 1 .. l_report_lines.count loop
      self.print_text( l_report_lines(i) );
    end loop;

    (self as ut_reporter_base).after_calling_run(a_run);
  end;

end;
/
