create or replace type body ut_realtime_reporter is
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
    
  constructor function ut_realtime_reporter(self in out nocopy ut_realtime_reporter) return self as result is
  begin
    self.init($$plsql_unit);
    current_indent := 0;
    return;
  end;

  overriding member procedure before_calling_run(self in out nocopy ut_realtime_reporter, a_run in ut_run) is
    procedure print_test_elements(a_test ut_test) is
    begin
      self.print_xml_fragment('<testcase path="' || a_test.path || '"' 
        || ' executable_type="' || a_test.item.executable_type || '"' 
        || ' owner_name="' || a_test.item.owner_name || '"' 
        || ' object_name="' || a_test.item.object_name || '"' 
        || ' procedure_name="' || a_test.item.procedure_name || '"' 
        || ' disabled="' || case when a_test.get_disabled_flag() then 'true' else 'false' end || '"' 
        || ' name="' || a_test.name || '"'
        || ' description="' || a_test.description || '"/>');
    end;

    procedure print_suite_elements(a_suite ut_logical_suite) is
    begin
      self.print_xml_fragment('<testsuite path="' || a_suite.path || '"' 
          || ' name="' || a_suite.name || '"'
          || ' description="' || a_suite.description || '">', 0, 1);
      for i in 1 .. a_suite.items.count loop
        if a_suite.items(i) is of(ut_test) then
          print_test_elements(treat(a_suite.items(i) as ut_test));
        elsif a_suite.items(i) is of(ut_logical_suite) then
          print_suite_elements(treat(a_suite.items(i) as ut_logical_suite));
        end if;
      end loop;
      self.print_xml_fragment('</testsuite>', -1);
    end;

  begin
    self.print_xml_fragment(ut_utils.get_xml_header(a_run.client_character_set));
    self.print_xml_fragment('<report>', 0, 1);
    self.print_xml_fragment('<prolog>', 0, 1);
    self.print_xml_fragment('<testsuites>', 0, 1);
    for i in 1 .. a_run.items.count loop
      print_suite_elements(treat(a_run.items(i) as ut_logical_suite));
    end loop;
    self.print_xml_fragment('</testsuites>', -1);
    self.print_xml_fragment('</prolog>', -1);
    self.print_xml_fragment('<run>', 0, 1);
  end;
  
  overriding member procedure before_calling_test(self in out nocopy ut_realtime_reporter, a_test in ut_test) as
  begin
    self.print_xml_fragment('<test path="' || a_test.path || '"'
       || ' executable_type="' || a_test.item.executable_type || '"' 
       || ' owner_name="' || a_test.item.owner_name || '"'
       || ' object_name="' || a_test.item.object_name || '"'
       || ' procedure_name="' || a_test.item.procedure_name || '"'
       || ' disabled="' || case when a_test.get_disabled_flag() then 'true' else 'false' end || '"/>', 1, -1);
  end;
  
  overriding member procedure after_calling_test(self in out nocopy ut_realtime_reporter, a_test in ut_test) as
  begin
     self.print_xml_fragment('');
  end;

  overriding member procedure after_calling_suite(self in out nocopy ut_realtime_reporter, a_suite in ut_logical_suite) as
  begin
     self.print_xml_fragment('');
  end;

  overriding member procedure after_calling_run(self in out nocopy ut_realtime_reporter, a_run in ut_run) as
  begin
     self.print_xml_fragment('</run>', -1);
     self.print_xml_fragment('</report>', -1);
  end;

  overriding member function get_description return varchar2 as
  begin
    return 'Provides test results in a XML format, to consumed by clients such as SQL Developer interested progressing details.';
  end;

  member procedure print_xml_fragment(
    self                    in out nocopy ut_realtime_reporter, 
    a_fragment              in            varchar2, 
    a_indent_summand_before in            integer               default 0,
    a_indent_summand_after  in            integer               default 0
  ) as
  begin
    current_indent := current_indent + a_indent_summand_before;
    self.print_text(lpad(' ', 2 * current_indent) || a_fragment);
    current_indent := current_indent + a_indent_summand_after;
  end;

end;
/
