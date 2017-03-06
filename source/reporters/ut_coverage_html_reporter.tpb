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

  constructor function ut_coverage_html_reporter(
    self in out nocopy ut_coverage_html_reporter,
    a_project_name varchar2 := null,
    a_schema_names ut_varchar2_list := null,
    a_include_object_list ut_varchar2_list := null,
    a_exclude_object_list ut_varchar2_list := null,
    a_html_report_assets_path varchar2 := null
  ) return self as result is
  begin
    self.init($$plsql_unit);
    ut_coverage.init(a_schema_names, a_include_object_list, a_exclude_object_list);
    self.project_name := a_project_name;
    assets_path := nvl(a_html_report_assets_path, ut_coverage_report_html_helper.get_default_html_assets_path());
    return;
  end;

  constructor function ut_coverage_html_reporter(
    self in out nocopy ut_coverage_html_reporter,
    a_project_name varchar2 := null,
    a_object_owner varchar2 := null,
    a_file_paths ut_varchar2_list,
    a_regex_pattern varchar2,
    a_object_owner_subexpression positive,
    a_object_name_subexpression positive,
    a_object_type_subexpression positive,
    a_file_to_object_type_mapping ut_key_value_pairs,
    a_include_object_list ut_varchar2_list := null,
    a_exclude_object_list ut_varchar2_list := null,
    a_html_report_assets_path varchar2 := null
  ) return self as result is
    l_mappings ut_coverage_file_mappings;
  begin
    l_mappings := ut_coverage.build_file_mappings(
      a_object_owner, a_file_paths, a_file_to_object_type_mapping, a_regex_pattern,
      a_object_owner_subexpression, a_object_name_subexpression, a_object_type_subexpression
    );
    self.init($$plsql_unit);
    ut_coverage.init(l_mappings, a_include_object_list, a_exclude_object_list);
    self.project_name := a_project_name;
    assets_path := nvl(a_html_report_assets_path, ut_coverage_report_html_helper.get_default_html_assets_path());
    return;
  end;

  constructor function ut_coverage_html_reporter(
    self in out nocopy ut_coverage_html_reporter,
    a_project_name varchar2 := null,
    a_object_owner varchar2 := null,
    a_file_paths ut_varchar2_list,
    a_include_object_list ut_varchar2_list := null,
    a_exclude_object_list ut_varchar2_list := null,
    a_html_report_assets_path varchar2 := null
  ) return self as result is
    l_mappings ut_coverage_file_mappings;
  begin
    l_mappings := ut_coverage.build_file_mappings( a_object_owner, a_file_paths );
    self.init($$plsql_unit);
    ut_coverage.init(l_mappings, a_include_object_list, a_exclude_object_list);
    self.project_name := a_project_name;
    assets_path := nvl(a_html_report_assets_path, ut_coverage_report_html_helper.get_default_html_assets_path());
    return;
  end;

  constructor function ut_coverage_html_reporter(
    self in out nocopy ut_coverage_html_reporter,
    a_project_name varchar2 := null,
    a_file_mappings       ut_coverage_file_mappings,
    a_include_object_list ut_varchar2_list := null,
    a_exclude_object_list ut_varchar2_list := null,
    a_html_report_assets_path varchar2 := null
  ) return self as result is
  begin
    self.init($$plsql_unit);
    ut_coverage.init(a_file_mappings, a_include_object_list, a_exclude_object_list);
    self.project_name := a_project_name;
    assets_path := nvl(a_html_report_assets_path, ut_coverage_report_html_helper.get_default_html_assets_path());
    return;
  end;

  overriding member procedure after_calling_run(self in out nocopy ut_coverage_html_reporter, a_run in ut_run) as
    l_report_lines  ut_varchar2_list;
    l_coverage_data ut_coverage.t_coverage;
  begin
    ut_coverage.coverage_stop();

    l_coverage_data := ut_coverage.get_coverage_data();

    l_report_lines := ut_utils.clob_to_table(ut_coverage_report_html_helper.get_index( l_coverage_data, self.project_name ));
    for i in 1 .. l_report_lines.count loop
      self.print_text( l_report_lines(i) );
    end loop;

    (self as ut_reporter_base).after_calling_run(a_run);
  end;

end;
/
