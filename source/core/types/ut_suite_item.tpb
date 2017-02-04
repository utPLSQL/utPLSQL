create or replace type body ut_suite_item as
  /*
  utPLSQL - Version X.X.X.X 
  Copyright 2016 - 2017 utPLSQL Project

  Licensed under the Apache License, Version 2.0 (the "License");
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
  end;

  member procedure set_ignore_flag(self in out nocopy ut_suite_item, a_ignore_flag boolean) is
  begin
    self.ignore_flag := ut_utils.boolean_to_int(a_ignore_flag);
  end;

  member function get_ignore_flag return boolean is
  begin
    return ut_utils.int_to_boolean(self.ignore_flag);
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

end;
/
