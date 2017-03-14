create or replace type body ut_suite_item as
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

  member procedure init(
    self in out nocopy ut_suite_item, a_object_owner varchar2, a_object_name varchar2, a_name varchar2,
    a_description varchar2, a_path varchar2, a_rollback_type integer, a_ignore_flag boolean
  ) is
  begin
    self.object_owner := a_object_owner;
    self.object_name := lower(trim(a_object_name));
    self.name := lower(trim(a_name));
    self.description := a_description;
    self.path := nvl(lower(trim(a_path)), self.object_name);
    self.rollback_type := a_rollback_type;
    self.ignore_flag := ut_utils.boolean_to_int(a_ignore_flag);
    self.results_count := ut_results_counter();
    self.warnings := ut_varchar2_list();
  end;

  member procedure set_ignore_flag(self in out nocopy ut_suite_item, a_ignore_flag boolean) is
  begin
    self.ignore_flag := ut_utils.boolean_to_int(a_ignore_flag);
  end;

  member function get_ignore_flag return boolean is
  begin
    return ut_utils.int_to_boolean(self.ignore_flag);
  end;

  final member procedure do_execute(self in out nocopy ut_suite_item, a_listener in out nocopy ut_event_listener_base) is
    l_completed_without_errors boolean;
  begin
    l_completed_without_errors := self.do_execute(a_listener);
  end;

  member function create_savepoint_if_needed return varchar2 is
    l_savepoint varchar2(30);
  begin
    if self.rollback_type = ut_utils.gc_rollback_auto then
      l_savepoint := ut_utils.gen_savepoint_name();
      execute immediate 'savepoint ' || l_savepoint;
    end if;
    return l_savepoint;
  end;

  member procedure rollback_to_savepoint(self in ut_suite_item, a_savepoint varchar2) is
    ex_savepoint_not_exists exception;
    pragma exception_init(ex_savepoint_not_exists, -1086);
  begin
    if self.rollback_type = ut_utils.gc_rollback_auto and a_savepoint is not null then
      execute immediate 'rollback to ' || a_savepoint;
    end if;
  exception
    when ex_savepoint_not_exists then
      null;
  end;

  member function execution_time return number is
  begin
    return ut_utils.time_diff(start_time, end_time);
  end;

  member procedure put_warning(self in out nocopy ut_suite_item, a_message varchar2) is
  begin
    self.warnings.extend;
    self.warnings(self.warnings.last) := a_message;
    self.results_count.increase_warning_count;
  end;

  not final member function get_error_stack_traces return ut_varchar2_list is
  begin
    return ut_varchar2_list();
  end;

  final member procedure add_stack_trace(self in ut_suite_item, a_stack_traces in out nocopy ut_varchar2_list, a_stack_trace varchar2) is
  begin
    if a_stack_trace is not null then
      if a_stack_traces is null then
        a_stack_traces := ut_varchar2_list();
      end if;
      a_stack_traces.extend;
      a_stack_traces(a_stack_traces.last) := a_stack_trace;
    end if;
  end;

  not final member function get_serveroutputs return clob is
  begin
    return null;
  end;

  final member procedure add_serveroutput(self in ut_suite_item, a_serveroutputs in out nocopy clob, a_serveroutput clob) is
  begin
    if a_serveroutput is not null and dbms_lob.getlength(a_serveroutput) > 0 then
      if a_serveroutputs is null then
        dbms_lob.createtemporary(a_serveroutputs, true);
      end if;
      dbms_lob.append(a_serveroutputs, a_serveroutput);
    end if;
  end;

end;
/
