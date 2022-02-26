create or replace type body ut_session_info as
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

  constructor function ut_session_info(self in out nocopy ut_session_info) return self as result is
  begin
    self.self_type   := $$plsql_unit;
    dbms_application_info.read_client_info( client_info );
    dbms_application_info.read_module( module, action );
    return;
  end;

  -- run hooks
  member procedure before_calling_run(self in out nocopy ut_session_info, a_run in ut_run) is
  begin
    ut_session_context.set_context( 'run_paths', ut_utils.to_string( ut_utils.table_to_clob( a_run.run_paths,',' ), null ) );
    ut_session_context.set_context( 'coverage_run_id', rawtohex( a_run.coverage_options.coverage_run_id ) );
    dbms_application_info.set_module( 'utPLSQL', null );
  end;

  member procedure after_calling_run(self in out nocopy ut_session_info, a_run in ut_run) is
  begin
    ut_session_context.clear_context( 'run_paths' );
    ut_session_context.clear_context( 'coverage_run_id' );
    dbms_application_info.set_module( module, action );
    dbms_application_info.set_client_info( client_info );
  end;

  -- suite hooks
  member procedure before_calling_suite(self in out nocopy ut_session_info, a_suite in ut_logical_suite) is
  begin
    if a_suite is not of (ut_suite_context) then
      ut_session_context.set_context( 'suite_path',        a_suite.path );
      ut_session_context.set_context( 'suite_package',     a_suite.object_owner||'.'||a_suite.object_name );
      ut_session_context.set_context( 'suite_description', a_suite.description );
      ut_session_context.set_context( 'suite_start_time',  ut_utils.to_string(a_suite.start_time)  );
      dbms_application_info.set_module( 'utPLSQL',         a_suite.object_name );
    else
      ut_session_context.set_context( 'context_name',        a_suite.name );
      ut_session_context.set_context( 'context_path',        a_suite.path);
      ut_session_context.set_context( 'context_description', a_suite.description );
      ut_session_context.set_context( 'context_start_time',  ut_utils.to_string(a_suite.start_time)  );
    end if;
  end;

  member procedure after_calling_suite(self in out nocopy ut_session_info, a_suite in ut_logical_suite) is
  begin
    if a_suite is not of (ut_suite_context) then
      ut_session_context.clear_context( 'suite_package' );
      ut_session_context.clear_context( 'suite_path' );
      ut_session_context.clear_context( 'suite_description' );
      ut_session_context.clear_context( 'suite_start_time' );
    else
      ut_session_context.clear_context( 'context_name' );
      ut_session_context.clear_context( 'context_path' );
      ut_session_context.clear_context( 'context_description' );
      ut_session_context.clear_context( 'context_start_time' );
    end if;
  end;


  member procedure before_calling_test(self in out nocopy ut_session_info, a_test in ut_test) is
  begin
    ut_session_context.set_context( 'test_name', a_test.object_owner||'.'||a_test.object_name||'.'||a_test.name );
    ut_session_context.set_context( 'test_description', a_test.description );
    ut_session_context.set_context( 'test_start_time',  ut_utils.to_string(a_test.start_time)  );
  end;

  member procedure after_calling_test (self in out nocopy ut_session_info, a_test in ut_test) is
  begin
    ut_session_context.clear_context( 'test_name' );
    ut_session_context.clear_context( 'test_description' );
    ut_session_context.clear_context( 'test_start_time' );
  end;

  member procedure before_calling_executable(self in out nocopy ut_session_info, a_executable in ut_executable) is
  begin
    ut_session_context.set_context( 'current_executable_type', a_executable.executable_type );
    ut_session_context.set_context(
      'current_executable_name',
      a_executable.owner_name||'.'||a_executable.object_name||'.'||a_executable.procedure_name
    );
    dbms_application_info.set_client_info( a_executable.procedure_name );
  end;

  member procedure after_calling_executable(self in out nocopy ut_session_info, a_executable in ut_executable) is
  begin
    ut_session_context.clear_context( 'current_executable_type' );
    ut_session_context.clear_context( 'current_executable_name' );
    dbms_application_info.set_client_info( null );
  end;

  member procedure on_finalize(self in out nocopy ut_session_info, a_run in ut_run) is
  begin
    dbms_application_info.set_client_info( client_info );
    dbms_application_info.set_module( module, action );
    ut_session_context.clear_all_context();
  end;

  overriding member function get_supported_events return ut_varchar2_list is
  begin
    return ut_varchar2_list(
      ut_event_manager.gc_before_run,
      ut_event_manager.gc_before_suite,
      ut_event_manager.gc_before_test,
      ut_event_manager.gc_before_before_all,
      ut_event_manager.gc_before_before_each,
      ut_event_manager.gc_before_before_test,
      ut_event_manager.gc_before_test_execute,
      ut_event_manager.gc_before_after_test,
      ut_event_manager.gc_before_after_each,
      ut_event_manager.gc_before_after_all,
      ut_event_manager.gc_after_run,
      ut_event_manager.gc_after_suite,
      ut_event_manager.gc_after_test,
      ut_event_manager.gc_after_before_all,
      ut_event_manager.gc_after_before_each,
      ut_event_manager.gc_after_before_test,
      ut_event_manager.gc_after_test_execute,
      ut_event_manager.gc_after_after_test,
      ut_event_manager.gc_after_after_each,
      ut_event_manager.gc_after_after_all,
      ut_event_manager.gc_finalize
      );
  end;

  overriding member procedure on_event( self in out nocopy ut_session_info, a_event_name varchar2, a_event_item ut_event_item) is
  begin
    case
      when a_event_name in (
          ut_event_manager.gc_before_before_all,
          ut_event_manager.gc_before_before_each,
          ut_event_manager.gc_before_before_test,
          ut_event_manager.gc_before_test_execute,
          ut_event_manager.gc_before_after_test,
          ut_event_manager.gc_before_after_each,
          ut_event_manager.gc_before_after_all
        )
        then before_calling_executable(treat(a_event_item as ut_executable));
      when a_event_name in (
          ut_event_manager.gc_after_before_all,
          ut_event_manager.gc_after_before_each,
          ut_event_manager.gc_after_before_test,
          ut_event_manager.gc_after_test_execute,
          ut_event_manager.gc_after_after_test,
          ut_event_manager.gc_after_after_each,
          ut_event_manager.gc_after_after_all
        )
        then after_calling_executable(treat(a_event_item as ut_executable));
      when a_event_name = ut_event_manager.gc_before_test
        then self.before_calling_test(treat(a_event_item as ut_test));
      when a_event_name = ut_event_manager.gc_after_test
        then self.after_calling_test(treat(a_event_item as ut_test));
      when a_event_name = ut_event_manager.gc_after_suite
        then after_calling_suite(treat(a_event_item as ut_logical_suite));
      when a_event_name = ut_event_manager.gc_before_suite
        then before_calling_suite(treat(a_event_item as ut_logical_suite));
      when a_event_name = ut_event_manager.gc_before_run
        then before_calling_run(treat(a_event_item as ut_run));
      when a_event_name = ut_event_manager.gc_after_run
        then after_calling_run(treat(a_event_item as ut_run));
      when a_event_name = ut_event_manager.gc_finalize
        then on_finalize(treat(a_event_item as ut_run));
      else null;
      end case;
  end;

end;
/