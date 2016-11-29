create or replace type body ut_teamcity_reporter is

  constructor function ut_teamcity_reporter(a_output ut_output default ut_output_dbms_output()) return self as result is
  begin
    self.name   := $$plsql_unit;
    self.output := a_output;
    return;
  end;

  overriding member procedure before_suite(self in out nocopy ut_teamcity_reporter, a_suite in ut_object) is
    l_test_object ut_test_object := treat(a_suite as ut_test_object);
  begin
    self.print_text(
      ut_teamcity_reporter_helper.test_suite_started(
        a_suite_name => coalesce(replace(l_test_object.name, '.')
        ,l_test_object.object_name))
      );
  end before_suite;

  overriding member procedure after_suite(self in out nocopy ut_teamcity_reporter, a_suite in ut_object) is
    l_test_object ut_test_object := treat(a_suite as ut_test_object);
  begin
    self.print_text(
      ut_teamcity_reporter_helper.test_suite_finished(
        a_suite_name => coalesce(replace(l_test_object.name, '.')
        ,l_test_object.object_name))
      );
  end after_suite;

  overriding member procedure before_suite_item(self in out nocopy ut_teamcity_reporter, a_suite in ut_object, a_item_index pls_integer) is
    l_suite          ut_test_suite;
    l_item           ut_test_object;
    l_test           ut_test;
    l_test_full_name varchar2(4000);
  begin
    l_suite := treat(a_suite as ut_test_suite);
    l_item  := treat(l_suite.items(a_item_index) as ut_test_object);
  
    if l_item is of(ut_test) then
      l_test           := treat(l_item as ut_test);
      l_test_full_name := nvl(replace(l_suite.name, '.'), l_suite.object_name) || ':' ||
                          nvl(replace(l_test.name, '.'), l_test.object_name);
      self.print_text(ut_teamcity_reporter_helper.test_started(a_test_name => l_test_full_name));
    end if;
  
  end before_suite_item;

  overriding member procedure after_suite_item(self in out nocopy ut_teamcity_reporter, a_suite in ut_object, a_item_index pls_integer) is
    l_suite            ut_test_suite;
    l_item             ut_test_object;
    l_test             ut_test;
    l_index            pls_integer;
    l_assert           ut_assert_result;
    l_test_full_name   varchar2(4000);
    l_assert_full_name varchar2(4000);
  begin
    l_suite := treat(a_suite as ut_test_suite);
    l_item  := treat(l_suite.items(a_item_index) as ut_test_object);
  
    if l_item is of(ut_test) then
    
      l_test := treat(l_item as ut_test);
    
      l_test_full_name := nvl(replace(l_suite.name, '.'), l_suite.object_name) || ':' ||
                          nvl(replace(l_item.name, '.'), l_test.object_name);
    
      if l_test.result = ut_utils.tr_ignore then
        self.print_text(ut_teamcity_reporter_helper.test_ignored(l_test_full_name));
      else
      
        if l_test.items is not null and l_test.items.count > 0 then
          for i in 1 .. l_test.items.count loop
          
            l_assert := treat(l_test.items(i) as ut_assert_result);
          
            if nvl(l_assert.result, ut_utils.tr_error) != ut_utils.tr_success then
              self.print_text(ut_teamcity_reporter_helper.test_failed(a_test_name => l_test_full_name
                                                                  ,a_msg       => l_assert.message
                                                                  ,a_expected  => l_assert.expected_value_string
                                                                  ,a_actual    => l_assert.actual_value_string));
              exit;
            end if;
          
          end loop;
        elsif l_test.result = ut_utils.tr_failure then
          self.print_text(ut_teamcity_reporter_helper.test_failed(a_test_name => l_test_full_name, a_msg => 'Test failed'));
        elsif l_test.result = ut_utils.tr_error then
          self.print_text(ut_teamcity_reporter_helper.test_failed(a_test_name => l_test_full_name, a_msg => 'Error occured'));
        end if;
      
        self.print_text(ut_teamcity_reporter_helper.test_finished(l_test_full_name
                                                  ,a_test_duration_milisec => trunc(l_test.execution_time * 1e3)));
      
      end if;
    
    end if;
  end after_suite_item;

end;
/
