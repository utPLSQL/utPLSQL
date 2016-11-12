create or replace type body ut_teamcity_reporter is

  constructor function ut_teamcity_reporter return self as result is
  begin
    self.name := $$plsql_unit;
    return;
  end;

  overriding member procedure before_suite(self in out nocopy ut_teamcity_reporter, a_suite in ut_object) is
  begin
  
    ut_teamcity_reporter_printer.test_suite_started(a_suite_name => coalesce(replace(treat(a_suite as ut_test_object).name
                                                                                    ,'.')
                                                                            ,treat(a_suite as ut_test_object)
                                                                             .object_name));
  end;

  overriding member procedure after_suite(self in out nocopy ut_teamcity_reporter, a_suite in ut_object) is
  begin
    ut_teamcity_reporter_printer.test_suite_finished(a_suite_name => coalesce(replace(treat(a_suite as ut_test_object).name
                                                                                     ,'.')
                                                                             ,treat(a_suite as ut_test_object)
                                                                              .object_name));
  end;

  overriding member procedure before_suite_item(self in out nocopy ut_teamcity_reporter, a_suite in ut_object, a_item_index pls_integer) is
    l_suite ut_test_suite;
    l_item  ut_test_object;
  begin
    l_suite := treat(a_suite as ut_test_suite);
    l_item  := treat(l_suite.items(a_item_index) as ut_test_object);
  
    if l_item is of(ut_test) then
      null;
      --ut_teamcity_reporter_printer.test_started(a_test_name => l_suite.object_name || ':' || l_item.object_name);
    end if;
    l_suite := null;
    l_item  := null;
  end;

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
    
      --l_test_full_name := nvl(l_suite.object_name || ':' || l_item.object_name;
    
      if l_test.items is not null and l_test.items.count > 0 then
        for i in 1 .. l_test.items.count loop
        
          l_assert := treat(l_test.items(i) as ut_assert_result);
        
          l_assert_full_name := l_test_full_name || '.' || nvl(replace(l_assert.name, '.'), 'assert' || to_char(i));
        
          ut_teamcity_reporter_printer.test_started(a_test_name => l_assert_full_name);
        
          if nvl(l_assert.result, ut_utils.tr_error) != ut_utils.tr_success then
            ut_teamcity_reporter_printer.test_failed(a_test_name => l_assert_full_name, a_msg => l_assert.message);
          end if;
        
          ut_teamcity_reporter_printer.test_finished(a_test_name => l_assert_full_name);
        
        end loop;
      end if;
    
      /*
      if nvl(l_test.result, ut_utils.tr_error) != ut_utils.tr_success then
        ut_teamcity_reporter_printer.test_failed(a_test_name => l_test_full_name);
      end if;
      
      ut_teamcity_reporter_printer.test_finished(a_test_name             => l_test_full_name
                                                ,a_test_duration_milisec => trunc(l_test.execution_time * 1e3));
                                                */
    end if;
  end;

end;
/
