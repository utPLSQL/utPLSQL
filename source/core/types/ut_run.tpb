create or replace type body ut_run as
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
  
  constructor function ut_run(
    self in out nocopy ut_run,
    a_items                 ut_suite_items,
    a_run_paths             ut_varchar2_list := null,
    a_schema_names          ut_varchar2_rows := null,
    a_exclude_objects       ut_object_names := null,
    a_include_objects       ut_object_names := null,
    a_project_file_mappings ut_file_mappings := null,
    a_test_file_mappings    ut_file_mappings := null,
    a_client_character_set  varchar2 := null
  ) return self as result is
    l_coverage_schema_names ut_varchar2_rows;
    l_coverage_options ut_coverage_options;
    l_exclude_objects  ut_object_names;
  begin    
    self.run_paths := a_run_paths;
    self.self_type := $$plsql_unit;
    self.items := a_items;
    self.client_character_set := lower(a_client_character_set);
    self.results_count := ut_results_counter();
    self.test_file_mappings := coalesce(a_test_file_mappings, ut_file_mappings());
    self.coverage_options := ut_coverage_options(
      a_schema_names,
      a_exclude_objects,
      a_include_objects,
      a_project_file_mappings
    );
    return;
  end;

  overriding member procedure mark_as_skipped(self in out nocopy ut_run) is
  begin
    null;
  end;

  overriding member function do_execute(self in out nocopy ut_run) return boolean is
    l_completed_without_errors boolean;
  begin
    ut_utils.debug_log('ut_run.execute');

    ut_event_manager.trigger_event(ut_event_manager.gc_before_run, self);
    self.start_time := current_timestamp;

    -- clear anything that might stay in the session's cache
    ut_expectation_processor.clear_expectations;

    for i in 1 .. self.items.count loop
      l_completed_without_errors := self.items(i).do_execute();
    end loop;

    self.calc_execution_result();

    self.end_time := current_timestamp;

    ut_event_manager.trigger_event(ut_event_manager.gc_after_run, self);

    return l_completed_without_errors;
  end;

  overriding member procedure set_rollback_type(self in out nocopy ut_run, a_rollback_type integer, a_force boolean := false) is
  begin
    self.rollback_type := case when a_force then a_rollback_type else coalesce(self.rollback_type, a_rollback_type) end;
    for i in 1 .. self.items.count loop
      self.items(i).set_rollback_type(self.rollback_type, a_force);
    end loop;
  end;

  overriding member procedure calc_execution_result(self in out nocopy ut_run) is
    l_result integer(1);
  begin
    if self.items is not null and self.items.count > 0 then
      for i in 1 .. self.items.count loop
        self.results_count.sum_counter_values( self.items(i).results_count );
      end loop;
      l_result := self.results_count.result_status();
    else
      --if suite is empty then it's successful (no errors)
      l_result := ut_utils.gc_success;
    end if;

    self.result := l_result;
  end;

  overriding member procedure mark_as_errored(self in out nocopy ut_run, a_error_stack_trace varchar2) is
  begin
    null;
  end;

  overriding member function get_error_stack_traces return ut_varchar2_list is
  begin
    return ut_varchar2_list();
  end;

  overriding member function get_serveroutputs return clob is
  begin
    return null;
  end;


end;
/
