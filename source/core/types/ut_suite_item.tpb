create or replace type body ut_suite_item as
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

  member procedure init(self in out nocopy ut_suite_item, a_object_owner varchar2, a_object_name varchar2, a_name varchar2, a_line_no integer) is
  begin
    self.object_owner  := a_object_owner;
    self.object_name   := lower(trim(a_object_name));
    self.name          := lower(trim(a_name));
    self.results_count := ut_results_counter();
    self.warnings      := ut_varchar2_rows();
    self.line_no       := a_line_no;
    self.transaction_invalidators := ut_varchar2_list();
    self.disabled_flag := ut_utils.boolean_to_int(false);
  end;

  member function get_disabled_flag return boolean is
  begin
    return ut_utils.int_to_boolean(self.disabled_flag);
  end;

  member procedure set_rollback_type(self in out nocopy ut_suite_item, a_rollback_type integer) is
  begin
    self.rollback_type := coalesce(self.rollback_type, a_rollback_type);
  end;

  member function get_rollback_type return integer is
  begin
    return nvl(self.rollback_type, ut_utils.gc_rollback_default);
  end;

  final member procedure do_execute(self in out nocopy ut_suite_item) is
    l_completed_without_errors boolean;
  begin
    l_completed_without_errors := self.do_execute();
  end;

  member function create_savepoint_if_needed return varchar2 is
    l_savepoint varchar2(30);
  begin
    if get_rollback_type() = ut_utils.gc_rollback_auto then
      l_savepoint := ut_utils.gen_savepoint_name();
      execute immediate 'savepoint ' || l_savepoint;
    end if;
    return l_savepoint;
  end;

  member procedure rollback_to_savepoint(self in out nocopy ut_suite_item, a_savepoint varchar2) is
    ex_savepoint_not_exists exception;
    pragma exception_init(ex_savepoint_not_exists, -1086);
  begin
    if get_rollback_type() = ut_utils.gc_rollback_auto and a_savepoint is not null then
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

  member procedure add_transaction_invalidator(self in out nocopy ut_suite_item, a_object_name varchar2) is
  begin
    if a_object_name not member of transaction_invalidators then
      transaction_invalidators.extend();
      transaction_invalidators(transaction_invalidators.last) := a_object_name;
    end if;
  end;

end;
/
