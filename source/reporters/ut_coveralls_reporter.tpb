create or replace type body ut_coveralls_reporter is
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

  constructor function ut_coveralls_reporter(
    self in out nocopy ut_coveralls_reporter
  ) return self as result is
  begin
    self.init($$plsql_unit);
    return;
  end;

  overriding member procedure after_calling_run(self in out nocopy ut_coveralls_reporter, a_run in ut_run) as
    l_report_lines  ut_varchar2_list;
    l_coverage_data ut_coverage.t_coverage;

    function get_lines_json(a_unit_coverage ut_coverage.t_unit_coverage) return clob is
      l_file_part       varchar2(32767);
      l_result          clob;
      l_last_line_no    binary_integer;
      c_coverage_header constant varchar2(30) := '"coverage": [';
      c_null            constant varchar2(4) := 'null';
    begin
      dbms_lob.createtemporary(l_result, true);
      ut_utils.append_to_clob(l_result, c_coverage_header);

      l_last_line_no := a_unit_coverage.lines.last;
      if l_last_line_no is null then
        l_last_line_no := a_unit_coverage.total_lines - 1;
        for i in 1 .. l_last_line_no loop
          ut_utils.append_to_clob(l_result, '0,');
        end loop;
        ut_utils.append_to_clob(l_result, '0');
      else
        for line_no in 1 .. l_last_line_no loop
          if a_unit_coverage.lines.exists(line_no) then
            l_file_part := to_char(a_unit_coverage.lines(line_no));
              else
            l_file_part := c_null;
          end if;
          if line_no < l_last_line_no then
            l_file_part := l_file_part ||',';
          end if;
          ut_utils.append_to_clob(l_result, l_file_part);
        end loop;
      end if;
      ut_utils.append_to_clob(l_result, ']');
      return l_result;
    end;

    function get_coverage_json(
      a_coverage_data ut_coverage.t_coverage
    ) return clob is
      l_file_part            varchar2(32767);
      l_result               clob;
      l_unit                 ut_coverage.t_full_name;
      c_coverage_header constant varchar2(30) := '{"source_files":['||chr(10);
      c_coverage_footer constant varchar2(30) := ']}'||chr(10)||chr(10)||chr(10)||chr(10)||' ';
      begin
      dbms_lob.createtemporary(l_result,true);

      ut_utils.append_to_clob(l_result, c_coverage_header);
      l_unit := a_coverage_data.objects.first;
      while l_unit is not null loop
        l_file_part := '{ "name": "'||l_unit||'",'||chr(10);
        ut_utils.append_to_clob(l_result, l_file_part);

        dbms_lob.append(l_result,get_lines_json(a_coverage_data.objects(l_unit)));

        ut_utils.append_to_clob(l_result, '}');

        l_unit := a_coverage_data.objects.next(l_unit);
        if l_unit is not null then
          ut_utils.append_to_clob(l_result, ','||chr(10));
        end if;
      end loop;
      ut_utils.append_to_clob(l_result, c_coverage_footer);
      return l_result;
    end;
  begin
    ut_coverage.coverage_stop();

    l_coverage_data := ut_coverage.get_coverage_data(a_run.coverage_options);

    self.print_clob( get_coverage_json( l_coverage_data ) );
  end;

end;
/
