create or replace type body ut_coverage_sonar_reporter is
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

  constructor function ut_coverage_sonar_reporter(
    self in out nocopy ut_coverage_sonar_reporter
  ) return self as result is
  begin
    self.init($$plsql_unit);
    return;
  end;


  overriding member procedure after_calling_run(self in out nocopy ut_coverage_sonar_reporter, a_run in ut_run) as

    function get_lines_xml(a_unit_coverage ut_coverage.t_unit_coverage) return ut_varchar2_rows is
      l_file_part    varchar2(32767);
      l_result       ut_varchar2_rows := ut_varchar2_rows();
      l_line_no      binary_integer;
    begin
      l_line_no := a_unit_coverage.lines.first;
      if l_line_no is null then
        for i in 1 .. a_unit_coverage.total_lines loop
          ut_utils.append_to_list(l_result, '<lineToCover lineNumber="'||i||'" covered="false"/>');
        end loop;
      else
        while l_line_no is not null loop
          if a_unit_coverage.lines(l_line_no).executions = 0 then
            l_file_part := '<lineToCover lineNumber="'||l_line_no||'" covered="false"/>';
          else
            l_file_part := '<lineToCover lineNumber="'||l_line_no||'" covered="true"';
            if a_unit_coverage.lines(l_line_no).covered_blocks <= a_unit_coverage.lines(l_line_no).no_blocks then
              l_file_part := l_file_part || ' branchesToCover="'||a_unit_coverage.lines(l_line_no).no_blocks||'"';
              l_file_part := l_file_part || ' coveredBranches="'||a_unit_coverage.lines(l_line_no).covered_blocks||'"';
            end if;
            l_file_part := l_file_part ||'/>';
          end if;
          ut_utils.append_to_list(l_result, l_file_part);
          l_line_no := a_unit_coverage.lines.next(l_line_no);
        end loop;
      end if;
      return l_result;
    end;

    function get_coverage_xml(
      a_coverage_data ut_coverage.t_coverage,
      a_run ut_run
    ) return ut_varchar2_rows is
      l_result               ut_varchar2_rows := ut_varchar2_rows();
      l_unit                 ut_coverage.t_object_name;
      c_coverage_header constant varchar2(30) := '<coverage version="1">';
      c_file_footer     constant varchar2(30) := '</file>';
      c_coverage_footer constant varchar2(30) := '</coverage>';
    begin

    ut_utils.append_to_list(l_result, ut_utils.get_xml_header(a_run.client_character_set));
    ut_utils.append_to_list(l_result, c_coverage_header);
    l_unit := a_coverage_data.objects.first;
    while l_unit is not null loop
      ut_utils.append_to_list(l_result, '<file path="'||dbms_xmlgen.convert(l_unit)||'">');

      ut_utils.append_to_list(l_result,get_lines_xml(a_coverage_data.objects(l_unit)));

      ut_utils.append_to_list(l_result, c_file_footer);

      l_unit := a_coverage_data.objects.next(l_unit);
    end loop;
    ut_utils.append_to_list(l_result, c_coverage_footer);
    return l_result;
  end;
  
  begin
    ut_coverage.coverage_stop();

    self.print_text_lines(
      get_coverage_xml(
        ut_coverage.get_coverage_data(a_run.coverage_options),
        a_run
      )
    );
  end;

  overriding member function get_description return varchar2 as
  begin
    return 'Generates a JSON coverage report providing information on code coverage with line numbers.' || chr(10) ||
           'Designed for [SonarQube](https://about.sonarqube.com/) to report coverage.' || chr(10) ||
           'JSON format returned conforms with the Sonar specification: https://docs.sonarqube.org/display/SONAR/Generic+Test+Data';
  end;

end;
/
