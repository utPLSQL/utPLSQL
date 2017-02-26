create or replace type body ut_coverage_json_reporter is
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

  constructor function ut_coverage_json_reporter(
    self in out nocopy ut_coverage_json_reporter,
    a_schema_names ut_varchar2_list := null,
    a_include_object_list ut_varchar2_list := null,
    a_exclude_object_list ut_varchar2_list := null
  ) return self as result is
  begin
    self.init($$plsql_unit);
    ut_coverage.init(a_schema_names, a_include_object_list, a_exclude_object_list);
    return;
  end;

  constructor function ut_coverage_json_reporter(
    self in out nocopy ut_coverage_json_reporter,
    a_object_owner varchar2 := null,
    a_file_paths ut_varchar2_list,
    a_regex_pattern varchar2,
    a_object_owner_subexpression positive,
    a_object_name_subexpression positive,
    a_object_type_subexpression positive,
    a_file_to_object_type_mapping ut_key_value_pairs,
    a_include_object_list ut_varchar2_list := null,
    a_exclude_object_list ut_varchar2_list := null
  ) return self as result is
    l_mappings ut_coverage_file_mappings;
  begin
    l_mappings := ut_coverage.build_file_mappings(
      a_object_owner, a_file_paths, a_file_to_object_type_mapping, a_regex_pattern,
      a_object_owner_subexpression, a_object_name_subexpression, a_object_type_subexpression
    );
    self.init($$plsql_unit);
    ut_coverage.init(l_mappings, a_include_object_list, a_exclude_object_list);
    return;
  end;

  constructor function ut_coverage_json_reporter(
    self in out nocopy ut_coverage_json_reporter,
    a_object_owner varchar2 := null,
    a_file_paths ut_varchar2_list,
    a_include_object_list ut_varchar2_list := null,
    a_exclude_object_list ut_varchar2_list := null
  ) return self as result is
    l_mappings ut_coverage_file_mappings;
  begin
    l_mappings := ut_coverage.build_file_mappings( a_object_owner, a_file_paths );
    self.init($$plsql_unit);
    ut_coverage.init(l_mappings, a_include_object_list, a_exclude_object_list);
    return;
  end;

  constructor function ut_coverage_json_reporter(
    self in out nocopy ut_coverage_json_reporter,
    a_file_mappings       ut_coverage_file_mappings,
    a_include_object_list ut_varchar2_list := null,
    a_exclude_object_list ut_varchar2_list := null
  ) return self as result is
  begin
    self.init($$plsql_unit);
    ut_coverage.init(a_file_mappings, a_include_object_list, a_exclude_object_list);
    return;
  end;

  overriding member procedure after_calling_run(self in out nocopy ut_coverage_json_reporter, a_run in ut_run) as
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
      dbms_lob.writeappend(l_result, length(c_coverage_header), c_coverage_header);

      l_last_line_no := a_unit_coverage.lines.last;
      if l_last_line_no is not null then
        for line_no in 1 .. l_last_line_no loop
          l_file_part :=
            case
              when a_unit_coverage.lines.exists(line_no) then
                to_char(a_unit_coverage.lines(line_no))
              else
                c_null
            end
            ||
            case
              when line_no < l_last_line_no then
                ','
              end;
          dbms_lob.writeappend(l_result, length(l_file_part), l_file_part);
        end loop;
      end if;
      dbms_lob.writeappend(l_result, 1, ']');
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

      dbms_lob.writeappend(l_result, length(c_coverage_header), c_coverage_header);
      l_unit := a_coverage_data.objects.first;
      while l_unit is not null loop
        l_file_part := '{ "name": "'||l_unit||'",'||chr(10);
        dbms_lob.writeappend(l_result, length(l_file_part), l_file_part);

        dbms_lob.append(l_result,get_lines_json(a_coverage_data.objects(l_unit)));

        dbms_lob.writeappend(l_result, 1, '}');

        l_unit := a_coverage_data.objects.next(l_unit);
        if l_unit is not null then
          dbms_lob.writeappend(l_result, 2, ','||chr(10));
        end if;
      end loop;
      dbms_lob.writeappend(l_result, length(c_coverage_footer), c_coverage_footer);
      return l_result;
    end;
  begin
    ut_coverage.coverage_stop();

    l_coverage_data := ut_coverage.get_coverage_data();

    l_report_lines := ut_utils.clob_to_table(get_coverage_json( l_coverage_data ));
    for i in 1 .. l_report_lines.count loop
      self.print_text( l_report_lines(i) );
    end loop;

    (self as ut_reporter_base).after_calling_run(a_run);
  end;

end;
/
