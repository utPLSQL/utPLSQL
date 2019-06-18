create or replace type body ut_coveralls_reporter is
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

  constructor function ut_coveralls_reporter(
    self in out nocopy ut_coveralls_reporter
  ) return self as result is
  begin
    self.init($$plsql_unit);
    return;
  end;

  overriding member procedure after_calling_run(self in out nocopy ut_coveralls_reporter, a_run in ut_run) as

    function get_lines_json(a_unit_coverage ut_coverage.t_unit_coverage) return ut_varchar2_rows is
      l_file_part       varchar2(32767);
      l_result          ut_varchar2_rows := ut_varchar2_rows();
      l_last_line_no    binary_integer;
      c_coverage_header constant varchar2(30) := '"coverage": [';
      c_null            constant varchar2(4) := 'null';
    begin
      ut_utils.append_to_list(l_result, c_coverage_header);

      l_last_line_no := a_unit_coverage.lines.last;
      if l_last_line_no is null then
        ut_utils.append_to_list(
            l_result
            , rpad( to_clob( '0' ), ( a_unit_coverage.total_lines * 3 ) - 2, ','||chr(10)||'0' )
        );
      else
        for line_no in 1 .. l_last_line_no loop
          if a_unit_coverage.lines.exists(line_no) then
            l_file_part := to_char(a_unit_coverage.lines(line_no).executions);
          else
            l_file_part := c_null;
          end if;
          if line_no < l_last_line_no then
            l_file_part := l_file_part ||',';
          end if;
          ut_utils.append_to_list(l_result, l_file_part);
        end loop;
      end if;
      ut_utils.append_to_list(l_result, ']');
      return l_result;
    end;

    function get_coverage_json(
      a_coverage_data ut_coverage.t_coverage
    ) return ut_varchar2_rows is
      l_result               ut_varchar2_rows := ut_varchar2_rows();
      l_unit                 ut_coverage.t_full_name;
      c_coverage_header constant varchar2(30) := '{"source_files":[';
      c_coverage_footer constant varchar2(30) := ']}'||chr(10)||' ';
    begin
      ut_utils.append_to_list(l_result, c_coverage_header);
      l_unit := a_coverage_data.objects.first;
      while l_unit is not null loop
        ut_utils.append_to_list(l_result, '{ "name": "'||l_unit||'",');

        ut_utils.append_to_list(l_result,get_lines_json(a_coverage_data.objects(l_unit)));

        ut_utils.append_to_list(l_result, '}');

        l_unit := a_coverage_data.objects.next(l_unit);
        if l_unit is not null then
          ut_utils.append_to_list(l_result, ',');
        end if;
      end loop;
      ut_utils.append_to_list(l_result, c_coverage_footer);
      return l_result;
    end;
  begin
    ut_coverage.coverage_stop();

    self.print_text_lines(
      get_coverage_json(
        ut_coverage.get_coverage_data(a_run.coverage_options)
      )
    );
  end;

  overriding member function get_description return varchar2 as
  begin
    return 'Generates a JSON coverage report providing information on code coverage with line numbers.' || chr(10) ||
           'Designed for [Coveralls](https://coveralls.io/).' || chr(10) ||
           'JSON format conforms with specification: https://docs.coveralls.io/api-introduction';
  end;

end;
/
