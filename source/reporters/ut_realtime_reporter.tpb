create or replace type body ut_realtime_reporter is
  /*
  utPLSQL - Version 3
  Copyright 2016 - 2021 utPLSQL Project

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

  constructor function ut_realtime_reporter(
    self in out nocopy ut_realtime_reporter
  ) return self as result is
  begin
    self.init($$plsql_unit,ut_output_clob_table_buffer());
    total_number_of_tests := 0;
    current_test_number := 0;
    current_indent := 0;
    print_buffer := ut_varchar2_rows();
    return;
  end;

  overriding member procedure before_calling_run(
    self  in out nocopy ut_realtime_reporter, 
    a_run in            ut_run
  ) is
    procedure print_test_elements(
      a_test in ut_test
    ) is
    begin
      total_number_of_tests := total_number_of_tests + 1;
      self.print_start_node('test', 'id', a_test.path);
      self.print_node('executableType', a_test.item.executable_type);
      self.print_node('ownerName', a_test.item.owner_name);
      self.print_node('objectName', a_test.item.object_name);
      self.print_node('procedureName', a_test.item.procedure_name);
      self.print_node('disabled', case when a_test.get_disabled_flag() then 'true' else 'false' end);
      self.print_node('name', a_test.name);
      self.print_node('description',  a_test.description);
      self.print_node('testNumber', to_char(total_number_of_tests));
      self.print_end_node('test');
    end print_test_elements;

    procedure print_suite_elements(
      a_suite in ut_logical_suite
    ) is
    begin
      self.print_start_node('suite', 'id', a_suite.path);
      self.print_node('name', a_suite.name);
      self.print_node('description', a_suite.description);
      <<suite_elements>>
      self.print_start_node('items');
      for i in 1 .. a_suite.items.count loop
        if a_suite.items(i) is of(ut_test) then
          print_test_elements(treat(a_suite.items(i) as ut_test));
        elsif a_suite.items(i) is of(ut_logical_suite) then
          print_suite_elements(treat(a_suite.items(i) as ut_logical_suite));
        end if;
      end loop suite_elements;
      self.print_end_node('items');
      self.print_end_node('suite');
    end print_suite_elements;
  begin
    xml_header := ut_utils.get_xml_header(a_run.client_character_set);
    self.print_xml_fragment(xml_header);
    self.print_start_node('event', 'type', 'pre-run');
    self.print_start_node('items');
    <<items>>
    for i in 1 .. a_run.items.count loop
      print_suite_elements(treat(a_run.items(i) as ut_logical_suite));
    end loop items;
    self.print_end_node('items');
    self.print_node('totalNumberOfTests', to_char(total_number_of_tests));
    self.print_end_node('event');
    self.flush_print_buffer('pre-run');
  end before_calling_run;

  overriding member procedure after_calling_run(
    self  in out nocopy ut_realtime_reporter, 
    a_run in            ut_run
  ) is
  begin
    self.print_xml_fragment(xml_header);
    self.print_start_node('event', 'type', 'post-run');
    self.print_start_node('run');
    self.print_node('startTime', to_char(a_run.start_time, 'YYYY-MM-DD"T"HH24:MI:SS.FF6'));
    self.print_node('endTime', to_char(a_run.end_time, 'YYYY-MM-DD"T"HH24:MI:SS.FF6'));
    self.print_node('executionTime', ut_utils.to_xml_number_format(a_run.execution_time()));
    self.print_start_node('counter');
    self.print_node('disabled', to_char(a_run.results_count.disabled_count));
    self.print_node('success', to_char(a_run.results_count.success_count));
    self.print_node('failure', to_char(a_run.results_count.failure_count));
    self.print_node('error', to_char(a_run.results_count.errored_count));
    self.print_node('warning', to_char(a_run.results_count.warnings_count));
    self.print_end_node('counter');
    self.print_cdata_node('errorStack', ut_utils.table_to_clob(a_run.get_error_stack_traces(), chr(10)||chr(10)));
    self.print_cdata_node('serverOutput', a_run.get_serveroutputs());
    self.print_end_node('run');
    self.print_end_node('event');
    self.flush_print_buffer('post-run');
  end after_calling_run;

  overriding member procedure before_calling_suite(
    self    in out nocopy ut_realtime_reporter, 
    a_suite in            ut_logical_suite
  ) is
  begin
    self.print_xml_fragment(xml_header);
    self.print_start_node('event', 'type', 'pre-suite');
    self.print_start_node('suite', 'id', a_suite.path);
    self.print_end_node('suite');
    self.print_end_node('event');
    self.flush_print_buffer('pre-suite');
  end before_calling_suite;

  overriding member procedure after_calling_suite(
    self    in out nocopy ut_realtime_reporter, 
    a_suite in            ut_logical_suite
  ) is
  begin
    self.print_xml_fragment(xml_header);
    self.print_start_node('event', 'type', 'post-suite');
    self.print_start_node('suite', 'id', a_suite.path);
    self.print_node('startTime', to_char(a_suite.start_time, 'YYYY-MM-DD"T"HH24:MI:SS.FF6'));
    self.print_node('endTime', to_char(a_suite.end_time, 'YYYY-MM-DD"T"HH24:MI:SS.FF6'));
    self.print_node('executionTime', ut_utils.to_xml_number_format(a_suite.execution_time()));
    self.print_start_node('counter');
    self.print_node('disabled', to_char(a_suite.results_count.disabled_count));
    self.print_node('success', to_char(a_suite.results_count.success_count));
    self.print_node('failure', to_char(a_suite.results_count.failure_count));
    self.print_node('error', to_char(a_suite.results_count.errored_count));
    self.print_node('warning', to_char(a_suite.results_count.warnings_count));
    self.print_end_node('counter');
    self.print_cdata_node('errorStack', ut_utils.table_to_clob(a_suite.get_error_stack_traces(), chr(10)||chr(10)));
    self.print_cdata_node('serverOutput', a_suite.get_serveroutputs());
    self.print_cdata_node('warnings', ut_utils.table_to_clob(a_suite.warnings, chr(10)||chr(10)));
    self.print_end_node('suite');
    self.print_end_node('event');
    self.flush_print_buffer('post-suite');
  end after_calling_suite;

  overriding member procedure before_calling_test(
    self   in out nocopy ut_realtime_reporter, 
    a_test in            ut_test
  ) is
  begin
    current_test_number := current_test_number + 1;
    self.print_xml_fragment(xml_header);
    self.print_start_node('event', 'type', 'pre-test');
    self.print_start_node('test', 'id', a_test.path);
    self.print_node('testNumber', to_char(current_test_number));
    self.print_node('totalNumberOfTests', to_char(total_number_of_tests));
    self.print_end_node('test');
    self.print_end_node('event');
    self.flush_print_buffer('pre-test');
  end before_calling_test;

  overriding member procedure after_calling_test(
    self   in out nocopy ut_realtime_reporter, 
    a_test in            ut_test
  ) is
  begin
    self.print_xml_fragment(xml_header);
    self.print_start_node('event', 'type', 'post-test');
    self.print_start_node('test', 'id', a_test.path);
    self.print_node('testNumber', to_char(current_test_number));
    self.print_node('totalNumberOfTests', to_char(total_number_of_tests));
    self.print_node('startTime', to_char(a_test.start_time, 'YYYY-MM-DD"T"HH24:MI:SS.FF6'));
    self.print_node('endTime', to_char(a_test.end_time, 'YYYY-MM-DD"T"HH24:MI:SS.FF6'));
    self.print_node('executionTime', ut_utils.to_xml_number_format(a_test.execution_time()));
    self.print_start_node('counter');
    self.print_node('disabled', to_char(a_test.results_count.disabled_count));
    self.print_node('success', to_char(a_test.results_count.success_count));
    self.print_node('failure', to_char(a_test.results_count.failure_count));
    self.print_node('error', to_char(a_test.results_count.errored_count));
    self.print_node('warning', to_char(a_test.results_count.warnings_count));
    self.print_end_node('counter');
    self.print_cdata_node('errorStack', ut_utils.table_to_clob(a_test.get_error_stack_traces(), chr(10)||chr(10)));
    self.print_cdata_node('serverOutput', a_test.get_serveroutputs());
    if a_test.failed_expectations.count > 0 then
      self.print_start_node('failedExpectations');
      <<expectations>>
      for i in 1 .. a_test.failed_expectations.count loop
        self.print_start_node('expectation');
        self.print_node('description', a_test.failed_expectations(i).description);
        self.print_cdata_node('message', a_test.failed_expectations(i).message);
        self.print_cdata_node('caller', a_test.failed_expectations(i).caller_info);
        self.print_end_node('expectation');
      end loop expectations;
      self.print_end_node('failedExpectations');
    end if;
    self.print_cdata_node('warnings', ut_utils.table_to_clob(a_test.warnings, chr(10)||chr(10)));
    self.print_end_node('test');
    self.print_end_node('event');
    self.flush_print_buffer('post-test');
  end after_calling_test;

  overriding member function get_description return varchar2 is
  begin
    return 'Provides test results in a XML format, for clients such as SQL Developer interested in showing progressing details.';
  end get_description;

  member procedure print_start_node(
     self         in out nocopy ut_realtime_reporter,
     a_node_name  in            varchar2,
     a_attr_name  in            varchar2             default null,
     a_attr_value in            varchar2             default null
  ) is
  begin
    self.print_xml_fragment(
       '<' || a_node_name
       || case
            when a_attr_name is not null and a_attr_value is not null then
              ' ' || a_attr_name || '="' || dbms_xmlgen.convert(a_attr_value) || '"'
          end
       || '>',
       0, 1
    );
  end print_start_node;

  member procedure print_end_node(
    self in out nocopy ut_realtime_reporter, 
    a_name in varchar2
  ) is
  begin
    self.print_xml_fragment('</' || a_name || '>', -1);
  end print_end_node;

  member procedure print_node(
     self      in out nocopy ut_realtime_reporter,
     a_name    in            varchar2,
     a_content in            clob
  ) is
  begin
    if a_content is not null then
       self.print_xml_fragment('<' || a_name || '>' || dbms_xmlgen.convert(a_content) || '</' || a_name || '>');
    end if;
  end print_node;

  member procedure print_cdata_node(
     self      in out nocopy ut_realtime_reporter,
     a_name    in            varchar2,
     a_content in            clob
  ) is
  begin
    if a_content is not null then
       self.print_xml_fragment('<' || a_name || '>' || ut_utils.to_cdata(a_content) || '</' || a_name || '>');
    end if;
  end print_cdata_node;

  member procedure print_xml_fragment(
    self                    in out nocopy ut_realtime_reporter, 
    a_fragment              in            clob, 
    a_indent_summand_before in            integer              default 0,
    a_indent_summand_after  in            integer              default 0
  ) is
  begin
    current_indent := current_indent + a_indent_summand_before;
    ut_utils.append_to_list(print_buffer, lpad(' ', 2 * current_indent) || a_fragment);
    current_indent := current_indent + a_indent_summand_after;
  end print_xml_fragment;

  member procedure flush_print_buffer(
    self        in out nocopy ut_realtime_reporter,
    a_item_type in            varchar2
  ) is
    l_doc clob;
    l_rows integer := print_buffer.count;
  begin
    for i in 1 .. l_rows loop
      ut_utils.append_to_clob(l_doc, print_buffer(i));
      ut_utils.append_to_clob(l_doc, chr(10));
    end loop;
    self.print_clob(l_doc, a_item_type);
    print_buffer.delete;
  end flush_print_buffer;

end;
/
