create or replace type body ut_coverage_cobertura_reporter is
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

  constructor function ut_coverage_cobertura_reporter(
    self in out nocopy ut_coverage_cobertura_reporter
  ) return self as result is
  begin
    self.init($$plsql_unit);
    return;
  end;


  overriding member procedure after_calling_run(self in out nocopy ut_coverage_cobertura_reporter, a_run in ut_run) as
    l_report_lines  ut_varchar2_list;
    l_coverage_data ut_coverage.t_coverage;
    
    function get_lines_xml(a_unit_coverage ut_coverage.t_unit_coverage) return clob is
      l_file_part    varchar2(32767);
      l_result       clob;
      l_line_no      binary_integer;
      l_pct          integer;
    begin
      dbms_lob.createtemporary(l_result, true);
      l_line_no := a_unit_coverage.lines.first;
      if l_line_no is null then
        for i in 1 .. a_unit_coverage.total_lines loop
          ut_utils.append_to_clob(l_result, '<line number="'||i||'" hits="0" branch="false"/>'||chr(10));
        end loop;
      else
        while l_line_no is not null loop
          if a_unit_coverage.lines(l_line_no).executions = 0 then
            l_file_part := '<line number="'||l_line_no||'" hits="0" branch="false"/>'||chr(10);
          else
            l_file_part := '<line number="'||l_line_no||'" hits="'||a_unit_coverage.lines(l_line_no).executions||'"';
            if a_unit_coverage.lines(l_line_no).covered_blocks < a_unit_coverage.lines(l_line_no).no_blocks then
              l_file_part := l_file_part || ' branch="true"';
              l_pct := (a_unit_coverage.lines(l_line_no).covered_blocks/a_unit_coverage.lines(l_line_no).no_blocks)*100;
              l_file_part := l_file_part || ' condition-coverage="'||l_pct||'%';
              l_file_part := l_file_part || ' ('||a_unit_coverage.lines(l_line_no).covered_blocks||'/'||a_unit_coverage.lines(l_line_no).no_blocks||')"';
            else
              l_file_part := l_file_part || ' branch="false"';
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
      a_coverage_data ut_coverage.t_coverage,
      a_run ut_run
    ) return ut_varchar2_rows is
      l_file_part       varchar2(32767);
      l_result          ut_varchar2_rows := ut_varchar2_rows();
      l_unit            ut_coverage.t_full_name;
      l_obj_name        ut_coverage.t_object_name;
      c_coverage_def    constant varchar2(200) := '<!DOCTYPE coverage SYSTEM "http://cobertura.sourceforge.net/xml/coverage-04.dtd">';
      c_file_footer     constant varchar2(30) := '</file>';
      c_coverage_footer constant varchar2(30) := '</coverage>';
      c_sources_footer  constant varchar2(30) := '</sources>';
      c_packages_footer constant varchar2(30) := '</packages>';
      c_package_footer  constant varchar2(30) := '</package>';
      c_class_footer    constant varchar2(30) := '</class>';
      c_lines_footer    constant varchar2(30) := '</lines>';
      l_epoch           varchar2(50) := (sysdate - to_date('01-01-1970 00:00:00', 'dd-mm-yyyy hh24:mi:ss')) * 24 * 60 * 60;
      begin
   
      ut_utils.append_to_list( l_result, ut_utils.get_xml_header(a_run.client_character_set) );
      ut_utils.append_to_list( l_result, c_coverage_def );
      
      --write header
      ut_utils.append_to_list(
        l_result,
        '<coverage line-rate="0" branch-rate="0.0" lines-covered="'
          ||a_coverage_data.covered_lines||'" lines-valid="'
          ||TO_CHAR(a_coverage_data.covered_lines + a_coverage_data.uncovered_lines)
          ||'" branches-covered="0" branches-valid="0" complexity="0" version="1" timestamp="'||l_epoch||'">'
      );
      
      
      --Write sources
      l_unit := a_coverage_data.objects.first;
      ut_utils.append_to_list( l_result, '<sources>' );
      
       while l_unit is not null loop
        ut_utils.append_to_list(l_result, '<source>'||dbms_xmlgen.convert(l_unit)||'</source>');
        l_unit := a_coverage_data.objects.next(l_unit);
      end loop;
      ut_utils.append_to_list(l_result, c_sources_footer);
      
      --write packages
      l_unit := a_coverage_data.objects.first;
      ut_utils.append_to_list(l_result, '<packages>');
                 
      while l_unit is not null loop
        l_obj_name := a_coverage_data.objects(l_unit).name;
        ut_utils.append_to_list(
          l_result,
          '<package name="'||dbms_xmlgen.convert(l_obj_name)||'" line-rate="0.0" branch-rate="0.0" complexity="0.0">'
        );
        
        ut_utils.append_to_list(
          l_result,
          '<class name="'||dbms_xmlgen.convert(l_obj_name)||'" filename="'
            ||dbms_xmlgen.convert(l_unit)||'" line-rate="0.0" branch-rate="0.0" complexity="0.0">'
        );
        
        ut_utils.append_to_list(l_result, '<lines>');

        ut_utils.append_to_list( l_result, get_lines_xml(a_coverage_data.objects(l_unit)) );

        ut_utils.append_to_list(l_result, c_lines_footer);
        ut_utils.append_to_list(l_result, c_class_footer);
        ut_utils.append_to_list(l_result, c_package_footer);
       
        l_unit := a_coverage_data.objects.next(l_unit);
      end loop;
      
      ut_utils.append_to_list(l_result, c_packages_footer);
      ut_utils.append_to_list(l_result, c_coverage_footer);
      return l_result;
    end;
  begin
    ut_coverage.coverage_stop();

    l_coverage_data := ut_coverage.get_coverage_data(a_run.coverage_options);

    self.print_text_lines( get_coverage_xml( l_coverage_data, a_run ) );

    (self as ut_reporter_base).after_calling_run(a_run);
  end;

 overriding member function get_description return varchar2 as
 begin
   return 'Generates a Cobertura coverage report providing information on code coverage with line numbers.' || chr(10) ||
          'Designed for Jenkins and TFS to report coverage. ' || chr(10) ||
          'Cobertura Document Type Definition can be found: http://cobertura.sourceforge.net/xml/coverage-04.dtd.'|| chr(10) ||
          'Sample file: https://github.com/leobalter/testing-examples/blob/master/solutions/3/report/cobertura-coverage.xml.';
 end;

end;
/
