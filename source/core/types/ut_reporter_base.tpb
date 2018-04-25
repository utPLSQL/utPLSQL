create or replace type body ut_reporter_base is
  /*
  utPLSQL - Version 3
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

  final member procedure init(self in out nocopy ut_reporter_base, a_self_type varchar2) is
  begin
    self.self_type   := a_self_type;
    self.id          := sys_guid();
    return;
  end;

  member procedure set_reporter_id(self in out nocopy ut_reporter_base, a_reporter_id raw) is
  begin
    self.id := a_reporter_id;
  end;

  member function get_reporter_id return raw is
  begin
    return self.id;
  end;

  member function get_description return varchar2 is
  begin
    return 'No description available';
  end;

  -- run hooks
  member procedure before_calling_run(self in out nocopy ut_reporter_base, a_run in ut_run) is
  begin
    null;
  end;

  -- suite hooks
  member procedure before_calling_suite(self in out nocopy ut_reporter_base, a_suite in ut_logical_suite) is
  begin
    null;
  end;

  member procedure before_calling_before_all(self in out nocopy ut_reporter_base, a_executable in ut_executable) is
  begin
    null;
  end;
  member procedure after_calling_before_all (self in out nocopy ut_reporter_base, a_executable in ut_executable) is
  begin
    null;
  end;

  member procedure before_calling_before_each(self in out nocopy ut_reporter_base, a_executable in ut_executable) is
  begin
    null;
  end;
  member procedure after_calling_before_each (self in out nocopy ut_reporter_base, a_executable in ut_executable) is
  begin
    null;
  end;

  -- test hooks
  member procedure before_calling_test(self in out nocopy ut_reporter_base, a_test in ut_test) is
  begin
    null;
  end;

  member procedure before_calling_before_test(self in out nocopy ut_reporter_base, a_executable in ut_executable) is
  begin
    null;
  end;
  member procedure after_calling_before_test (self in out nocopy ut_reporter_base, a_executable in ut_executable) is
  begin
    null;
  end;

  member procedure before_calling_test_execute(self in out nocopy ut_reporter_base, a_executable in ut_executable) is
  begin
    null;
  end;
  member procedure after_calling_test_execute (self in out nocopy ut_reporter_base, a_executable in ut_executable) is
  begin
    null;
  end;

  member procedure before_calling_after_test(self in out nocopy ut_reporter_base, a_executable in ut_executable) is
  begin
    null;
  end;
  member procedure after_calling_after_test (self in out nocopy ut_reporter_base, a_executable in ut_executable) is
  begin
    null;
  end;

  member procedure after_calling_test(self in out nocopy ut_reporter_base, a_test in ut_test) is
  begin
    null;
  end;

  --suite hooks continued
  member procedure before_calling_after_each(self in out nocopy ut_reporter_base, a_executable in ut_executable) is
  begin
    null;
  end;
  member procedure after_calling_after_each (self in out nocopy ut_reporter_base, a_executable in ut_executable) is
  begin
    null;
  end;

  member procedure before_calling_after_all(self in out nocopy ut_reporter_base, a_executable in ut_executable) is
  begin
    null;
  end;
  member procedure after_calling_after_all (self in out nocopy ut_reporter_base, a_executable in ut_executable) is
  begin
    null;
  end;

  member procedure after_calling_suite(self in out nocopy ut_reporter_base, a_suite in ut_logical_suite) is
  begin
    null;
  end;

  -- run hooks continued
  member procedure after_calling_run (self in out nocopy ut_reporter_base, a_run in ut_run) is
  begin
    null;
  end;

  overriding member function get_supported_events return ut_varchar2_list is
  begin
    return ut_varchar2_list(
      ut_utils.gc_before_run,
      ut_utils.gc_before_suite,
      ut_utils.gc_before_test,
      ut_utils.gc_before_before_all,
      ut_utils.gc_before_before_each,
      ut_utils.gc_before_before_test,
      ut_utils.gc_before_test_execute,
      ut_utils.gc_before_after_test,
      ut_utils.gc_before_after_each,
      ut_utils.gc_before_after_all,
      ut_utils.gc_after_run,
      ut_utils.gc_after_suite,
      ut_utils.gc_after_test,
      ut_utils.gc_after_before_all,
      ut_utils.gc_after_before_each,
      ut_utils.gc_after_before_test,
      ut_utils.gc_after_test_execute,
      ut_utils.gc_after_after_test,
      ut_utils.gc_after_after_each,
      ut_utils.gc_after_after_all,
      ut_utils.gc_finalize
    );
  end;

  overriding member procedure on_event( self in out nocopy ut_reporter_base, a_event_name varchar2, a_event_item ut_event_item) is
  begin
    case a_event_name
      when ut_utils.gc_before_run
      then self.before_calling_run(treat(a_event_item as ut_run));
      when ut_utils.gc_before_suite
      then self.before_calling_suite(treat(a_event_item as ut_logical_suite));
      when ut_utils.gc_before_before_all
      then self.before_calling_before_all(treat(a_event_item as ut_executable));
      when ut_utils.gc_before_before_each
      then self.before_calling_before_each(treat(a_event_item as ut_executable));
      when ut_utils.gc_before_test
      then self.before_calling_test(treat(a_event_item as ut_test));
      when ut_utils.gc_before_before_test
      then self.before_calling_before_test(treat(a_event_item as ut_executable));
      when ut_utils.gc_before_test_execute
      then self.before_calling_test_execute(treat(a_event_item as ut_executable));
      when ut_utils.gc_before_after_test
      then self.before_calling_after_test(treat(a_event_item as ut_executable));
      when ut_utils.gc_before_after_each
      then self.before_calling_after_each(treat(a_event_item as ut_executable));
      when ut_utils.gc_before_after_all
      then self.before_calling_after_all(treat(a_event_item as ut_executable));
      when ut_utils.gc_after_run
      then self.after_calling_run(treat(a_event_item as ut_run));
      when ut_utils.gc_after_suite
      then self.after_calling_suite(treat(a_event_item as ut_logical_suite));
      when ut_utils.gc_after_before_all
      then self.after_calling_before_all(treat(a_event_item as ut_executable));
      when ut_utils.gc_after_before_each
      then self.after_calling_before_each(treat(a_event_item as ut_executable));
      when ut_utils.gc_after_test
      then self.after_calling_test(treat(a_event_item as ut_test));
      when ut_utils.gc_after_before_test
      then self.after_calling_before_test(treat(a_event_item as ut_executable));
      when ut_utils.gc_after_test_execute
      then self.after_calling_test_execute(treat(a_event_item as ut_executable));
      when ut_utils.gc_after_after_test
      then self.after_calling_after_test(treat(a_event_item as ut_executable));
      when ut_utils.gc_after_after_each
      then self.after_calling_after_each(treat(a_event_item as ut_executable));
      when ut_utils.gc_after_after_all
      then self.after_calling_after_all(treat(a_event_item as ut_executable));
      when ut_utils.gc_finalize
      then self.on_finalize(treat(a_event_item as ut_run));
    end case;
  end;

end;
/
