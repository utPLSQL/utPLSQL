create or replace noneditionable type body ut_suite  as
  /*
  utPLSQL - Version 3
  Copyright 2016 - 2026 utPLSQL Project

  Licensed under the Apache License, Version 2.0 (the "License").
  You may not use this file except in compliance with the License.
  You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
  */

  constructor function ut_suite (
    self in out nocopy ut_suite, a_object_owner varchar2, a_object_name varchar2, a_line_no integer,
    a_tags ut_varchar2_rows := null
  ) return self as result is
  begin
    self.self_type := $$plsql_unit;
    self.init(a_object_owner, a_object_name, a_object_name, a_line_no);
    self.items := ut_suite_items();
    before_all_list := ut_executables();
    after_all_list  := ut_executables();
    self.tags       := coalesce(a_tags,ut_varchar2_rows());
    return;
  end;

  overriding member function do_execute(self in out nocopy ut_suite) return boolean is
    l_suite_savepoint varchar2(30);
    l_no_errors boolean;

    function has_test_case_sources return boolean is
    begin
      for i in 1 .. self.items.count loop
        if self.items(i).has_test_case_source() then
          return true;
        end if;
      end loop;
      return false;
    end;

    -- the --%testcasesource functions run after beforeall, so they see the data that beforeall created
    procedure execute_with_test_case_sources is
      l_items ut_suite_items := ut_suite_items();
      l_test  ut_test;
      l_cases ut_suite_items;

      procedure add_item(a_item ut_suite_item) is
      begin
        l_items.extend;
        l_items(l_items.last) := a_item;
      end;
    begin
      for i in 1 .. self.items.count loop
        if self.items(i).has_test_case_source() and not self.items(i).get_disabled_flag() then
          l_test := treat(self.items(i) as ut_test);
          l_cases := null;
          begin
            l_cases := l_test.get_source_test_cases();
          exception
            when others then
              l_test.mark_as_errored('The --%testcasesource function failed.' || chr(10) || dbms_utility.format_error_stack);
              add_item(l_test);
          end;
          if l_cases is not null then
            if l_cases.count = 0 then
              self.put_warning('The --%testcasesource function returned no test cases.', l_test.name, l_test.line_no);
            end if;
            for j in 1 .. l_cases.count loop
              begin
                l_cases(j).do_execute();
              exception
                when others then
                  -- don't keep the values of the test cases that won't run
                  for k in j .. l_cases.count loop
                    ut_test_case_values.remove_values(l_cases(k).path);
                  end loop;
                  raise;
              end;
              ut_test_case_values.remove_values(l_cases(j).path);
              add_item(l_cases(j));
            end loop;
          end if;
        else
          self.items(i).do_execute();
          add_item(self.items(i));
        end if;
      end loop;
      self.items := l_items;
    end;

    procedure propagate_error(a_error_stack_trace varchar2) is
    begin
      for i in 1..self.items.count loop
        self.items(i).mark_as_errored(a_error_stack_trace);
      end loop;
    end;
  begin
    ut_utils.debug_log('ut_suite.execute');

    if self.get_disabled_flag() then
      self.mark_as_skipped(a_skip_reason => self.disabled_reason);
    else
      self.start_time := current_timestamp;
      ut_event_manager.trigger_event(ut_event_manager.gc_before_suite, self);

      l_suite_savepoint := self.create_savepoint_if_needed();

      --includes listener calls for before and after actions
      l_no_errors := true;
      for i in 1 .. self.before_all_list.count loop
        l_no_errors := self.before_all_list(i).do_execute(self);
        if not l_no_errors then
          propagate_error(self.before_all_list(i).get_error_stack_trace());
          exit;
        end if;
      end loop;

      if l_no_errors then
        if has_test_case_sources() then
          execute_with_test_case_sources();
        else
          for i in 1 .. self.items.count loop
            self.items(i).do_execute();
          end loop;
        end if;
      end if;

      for i in 1 .. after_all_list.count loop
        l_no_errors := self.after_all_list(i).do_execute(self);
        if not l_no_errors then
          self.put_warning(self.after_all_list(i).get_error_stack_trace());
        end if;
      end loop;

      self.rollback_to_savepoint(l_suite_savepoint);

      self.calc_execution_result();
      self.end_time := current_timestamp;
      ut_event_manager.trigger_event(ut_event_manager.gc_after_suite, self);
    end if;

    return l_no_errors;
  end;

  overriding member function get_error_stack_traces(self ut_suite) return ut_varchar2_list is
    l_stack_traces ut_varchar2_list := ut_varchar2_list();
  begin
    for i in 1 .. before_all_list.count loop
      ut_utils.append_to_list(l_stack_traces, self.before_all_list(i).get_error_stack_trace());
    end loop;
    for i in 1 .. after_all_list.count loop
      ut_utils.append_to_list(l_stack_traces, self.after_all_list(i).get_error_stack_trace());
    end loop;
    return l_stack_traces;
  end;

  overriding member function get_serveroutputs return clob is
    l_outputs clob;
  begin
    for i in 1 .. before_all_list.count loop
      ut_utils.append_to_clob(l_outputs, self.before_all_list(i).serveroutput);
    end loop;
    for i in 1 .. after_all_list.count loop
      ut_utils.append_to_clob(l_outputs, self.after_all_list(i).serveroutput);
    end loop;
    return l_outputs;
  end;

end;
/
