create or replace type body ut_suite  as
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

  constructor function ut_suite (
    self in out nocopy ut_suite , a_object_owner varchar2 := null, a_object_name varchar2, a_name varchar2, a_path varchar2, a_description varchar2 := null,
    a_rollback_type integer := null, a_ignore_flag boolean := false, a_before_all_proc_name varchar2 := null,
    a_after_all_proc_name varchar2 := null, a_before_each_proc_name varchar2 := null, a_after_each_proc_name varchar2 := null
  ) return self as result is
  begin
    self.self_type := $$plsql_unit;
    self.init(a_object_owner, a_object_name, a_name, a_description, a_path, a_rollback_type, a_ignore_flag);
    self.before_all := ut_executable(self, a_before_all_proc_name, ut_utils.gc_before_all);
    self.before_each := ut_executable(self, a_before_each_proc_name, ut_utils.gc_before_each);
    self.items := ut_suite_items();
    self.after_each := ut_executable(self, a_after_each_proc_name, ut_utils.gc_after_each);
    self.after_all := ut_executable(self, a_after_all_proc_name, ut_utils.gc_after_all);
    return;
  end;

  overriding member function is_valid return boolean is
    l_is_valid boolean;
  begin
    l_is_valid :=
      ( not self.before_all.is_defined() or self.before_all.is_valid() ) and
      ( not self.before_each.is_defined() or self.before_each.is_valid() ) and
      ( not self.after_each.is_defined() or self.after_each.is_valid() ) and
      ( not self.after_all.is_defined() or self.after_all.is_valid() );
    return l_is_valid;
  end;

  overriding member function do_execute(self in out nocopy ut_suite, a_listener in out nocopy ut_event_listener_base) return boolean is
    l_suite_savepoint varchar2(30);
    l_item_savepoint  varchar2(30);
    l_completed_without_errors boolean;
    l_suite_step_without_errors boolean;
    
    procedure do_fail(a_prefix varchar2) is
      l_results ut_assert_results := ut_assert_processor.get_asserts_results();
    begin
      for i in 1..self.items.count loop
        self.items(i).fail(a_listener, a_prefix||l_results(1).error_message);
      end loop;
    end;
  begin
    ut_utils.debug_log('ut_suite.execute');
    a_listener.fire_before_event(ut_utils.gc_suite,self);
    
    self.start_time := current_timestamp;    

    if self.get_ignore_flag() then
      self.result := ut_utils.tr_ignore;
      self.end_time := self.start_time;
      ut_utils.debug_log('ut_suite .execute - ignored');
    else
      
      if self.is_valid() then

        l_suite_savepoint := self.create_savepoint_if_needed();

        --includes listener calls for before and after actions
        l_suite_step_without_errors := self.before_all.do_execute(self, a_listener);

        if l_suite_step_without_errors then
          for i in 1 .. self.items.count loop
            l_completed_without_errors := true;

            --savepoint
            l_item_savepoint := self.items(i).create_savepoint_if_needed();
            
            --before each
            --includes listener calls for before and after actions
            l_completed_without_errors := self.before_each.do_execute(self, a_listener);

            -- execute the item (test or suite)
            if l_completed_without_errors then
              l_completed_without_errors := self.items(i).do_execute(a_listener);
            else
              self.items(i).fail(a_listener, 'Beforeach procedure failed:'||chr(10)||ut_assert_processor.get_asserts_results()(1).error_message);
            end if;
            
            --after each
            --includes listener calls for before and after actions
            --run afteeach even if a test raised an exception
            l_completed_without_errors := self.after_each.do_execute(self, a_listener);
            if not l_completed_without_errors then
              self.put_warning('Aftereach procedure failed:'||chr(10)||ut_assert_processor.get_asserts_results()(1).error_message);
            end if;

            --rollback to savepoint
            self.items(i).rollback_to_savepoint(l_item_savepoint);

          end loop;
          
          l_suite_step_without_errors := self.after_all.do_execute(self, a_listener);
          if not l_suite_step_without_errors then
            self.put_warning('Afterall procedure failed: '||chr(10)||ut_assert_processor.get_asserts_results()(1).error_message);
          end if;
        else
          do_fail('Beforeall procedure failed: '||chr(10));
        end if;

        self.rollback_to_savepoint(l_suite_savepoint);
        
      else
        do_fail(null);
      end if;

      self.calc_execution_result();
      self.end_time := current_timestamp;

    end if;
    a_listener.fire_after_event(ut_utils.gc_suite,self);

    return l_completed_without_errors;
  end;

end;
/
