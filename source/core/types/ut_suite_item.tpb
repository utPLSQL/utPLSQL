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

  member procedure init(self in out nocopy ut_suite_item, a_object_owner varchar2, a_object_name varchar2, a_name varchar2, a_description varchar2, a_path varchar2, a_rollback_type integer, a_disabled_flag boolean) is
  begin
    self.object_owner  := a_object_owner;
    self.object_name   := lower(trim(a_object_name));
    self.name          := lower(trim(a_name));
    self.description   := a_description;
    self.path          := nvl(lower(trim(a_path)), self.object_name);
    self.rollback_type := a_rollback_type;
    self.disabled_flag := ut_utils.boolean_to_int(a_disabled_flag);
    self.results_count := ut_results_counter();
    self.warnings      := ut_varchar2_list();
    self.transaction_invalidators := ut_varchar2_list();
  end;

  member procedure set_disabled_flag(self in out nocopy ut_suite_item, a_disabled_flag boolean) is
  begin
    self.disabled_flag := ut_utils.boolean_to_int(a_disabled_flag);
  end;

  member function get_disabled_flag return boolean is
  begin
    return ut_utils.int_to_boolean(self.disabled_flag);
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

  member procedure rollback_to_savepoint(self in out nocopy ut_suite_item, a_savepoint varchar2) is
    ex_savepoint_not_exists exception;
    pragma exception_init(ex_savepoint_not_exists, -1086);
  begin
    if self.rollback_type = ut_utils.gc_rollback_auto and a_savepoint is not null then
      execute immediate 'rollback to ' || a_savepoint;
    end if;
  exception
    when ex_savepoint_not_exists then
      put_warning(
        'Unable to perform automatic rollback after test'
        || case when self_type like '%SUITE' then ' suite' end || '. '
        ||'An implicit or explicit commit/rollback occurred in procedures:'||chr(10)
        ||lower(ut_utils.indent_lines(ut_utils.table_to_clob(self.get_transaction_invalidators()), 2, true))||chr(10)
        ||'Use the "--%rollback(manual)" annotation or remove commit/rollback/ddl statements that are causing the issue.'
      );
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

  member function get_transaction_invalidators return ut_varchar2_list is
  begin
    return transaction_invalidators;
  end;

  final member procedure add_transaction_invalidator(a_object_name varchar2) is
  begin
    transaction_invalidators.extend();
    transaction_invalidators(transaction_invalidators.last) := a_object_name;
  end;

end;
/
