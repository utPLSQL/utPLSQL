create or replace type body ut_coverage_sonar_reporter is
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

  constructor function ut_coverage_sonar_reporter(
    self in out nocopy ut_coverage_sonar_reporter
  ) return self as result is
  begin
    self.init($$plsql_unit);
    return;
  end;


  overriding member procedure after_calling_run(self in out nocopy ut_coverage_sonar_reporter, a_run in ut_run) as
    l_report_lines  ut_varchar2_list;
    l_coverage_data ut_coverage.t_coverage;
    function get_lines_xml(a_unit_coverage ut_coverage.t_unit_coverage) return clob is
      l_file_part    varchar2(32767);
      l_result       clob;
      l_line_no      binary_integer;
    begin
      dbms_lob.createtemporary(l_result, true);
      l_line_no := a_unit_coverage.lines.first;
      if l_line_no is null then
        for i in 1 .. a_unit_coverage.total_lines loop
          l_file_part := '<lineToCover lineNumber="'||i||'" covered="false"/>'||chr(10);
          ut_utils.append_to_clob(l_result, l_file_part);
        end loop;
      else
        while l_line_no is not null loop
          if a_unit_coverage.lines(l_line_no).executions = 0 then
            l_file_part := '<lineToCover lineNumber="'||l_line_no||'" covered="false"/>'||chr(10);
          else
            l_file_part := '<lineToCover lineNumber="'||l_line_no||'" covered="true"';
            if a_unit_coverage.lines(l_line_no).covered_blocks <= a_unit_coverage.lines(l_line_no).no_blocks then
              l_file_part := l_file_part || ' branchesToCover="'||a_unit_coverage.lines(l_line_no).no_blocks||'"';
              l_file_part := l_file_part || ' coveredBranches="'||a_unit_coverage.lines(l_line_no).covered_blocks||'"';
            end if;
            l_file_part := l_file_part ||'/>'||chr(10);
          end if;
          ut_utils.append_to_clob(l_result, l_file_part);
          l_line_no := a_unit_coverage.lines.next(l_line_no);
        end loop;
      end if;
      return l_result;
    end;
    function get_coverage_xml(
      a_coverage_data ut_coverage.t_coverage
    ) return clob is
      l_file_part            varchar2(32767);
      l_result               clob;
      l_unit                 ut_coverage.t_full_name;
      c_coverage_header constant varchar2(30) := '<coverage version="1">'||chr(10);
      c_file_footer     constant varchar2(30) := '</file>'||chr(10);
      c_coverage_footer constant varchar2(30) := '</coverage>';
      begin
      dbms_lob.createtemporary(l_result,true);

      ut_utils.append_to_clob(l_result, c_coverage_header);
      l_unit := a_coverage_data.objects.first;
      while l_unit is not null loop
        l_file_part := '<file path="'||dbms_xmlgen.convert(l_unit)||'">'||chr(10);
        ut_utils.append_to_clob(l_result, l_file_part);

        dbms_lob.append(l_result,get_lines_xml(a_coverage_data.objects(l_unit)));

        ut_utils.append_to_clob(l_result, c_file_footer);

        l_unit := a_coverage_data.objects.next(l_unit);
      end loop;
      ut_utils.append_to_clob(l_result, c_coverage_footer);
      return l_result;
    end;
  begin
    ut_coverage.coverage_stop();

    l_coverage_data := ut_coverage.get_coverage_data(a_run.coverage_options);

    self.print_clob( get_coverage_xml( l_coverage_data ) );
  end;

  overriding member function get_description return varchar2 as
  begin
    return 'Generates a JSON coverage report providing information on code coverage with line numbers.' || chr(10) ||
           'Designed for [SonarQube](https://about.sonarqube.com/) to report coverage.' || chr(10) ||
           'JSON format returned conforms with the Sonar specification: https://docs.sonarqube.org/display/SONAR/Generic+Test+Data';
  end;

end;
/
