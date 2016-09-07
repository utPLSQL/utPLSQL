create or replace type body ut_teamcity_reporter is

  constructor function ut_teamcity_reporter return self as result is
  begin
    self.name := $$plsql_unit;
    return;
  end;

  overriding member procedure before_suite(self in out nocopy ut_teamcity_reporter, a_suite in ut_object) is
  begin
    dbms_output.put_line('##teamcity[testSuiteStarted name=''' ||
                         coalesce(treat(a_suite as ut_test_object).name, treat(a_suite as ut_test_object).object_name) ||
                         ''']');
  end;

  overriding member procedure after_suite(self in out nocopy ut_teamcity_reporter, a_suite in ut_object) is
  begin
    dbms_output.put_line('##teamcity[testSuiteFinished name=''' ||
                         coalesce(treat(a_suite as ut_test_object).name, treat(a_suite as ut_test_object).object_name) ||
                         ''']');
  end;

  overriding member procedure before_suite_item(self in out nocopy ut_teamcity_reporter, a_suite in ut_object, a_item_index pls_integer) is
    l_suite ut_test_suite;
    l_item  ut_test_object;
  begin
    l_suite := treat(a_suite as ut_test_suite);
    l_item  := treat(l_suite.items(a_item_index) as ut_test_object);
  
    if l_item is of(ut_test) then
      dbms_output.put_line('##teamcity[testStarted name=''' || l_suite.object_name || '.' || l_item.object_name ||
                           ''']');
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
    
      l_test_full_name := l_suite.object_name || '.' || l_item.object_name;
      if l_test.items is not null and l_test.items.count > 0 then
        for i in 1 .. l_test.items.count loop
        
          l_assert := treat(l_test.items(i) as ut_assert_result);
        
          l_assert_full_name := l_test_full_name || '.assert' || to_char(i);
        
          dbms_output.put_line('##teamcity[testStarted name=''' || l_assert_full_name || ''']');
          --l_msg_str := '##teamcity[testStarted name=''' || l_suite.object_name || '.' || l_item.object_name ||'.assert'||i||''']';
          --''' duration=''' || trunc(l_test.execution_time*1e3) || 
        
          --l_msg_str := '##teamcity[message text=''' || l_assert.message || '''';
        
          if l_assert.result = ut_utils.tr_success then
            null;
          else
            dbms_output.put_line('##teamcity[testFailed name=''' || l_assert_full_name || ''' message=''' ||
                                 l_assert.message || ''']');
          end if;
          dbms_output.put_line('##teamcity[testFinished name=''' || l_assert_full_name || ''']');
        
        end loop;
      end if;
    
      if l_test.result != ut_utils.tr_success or l_test.result is null then
        dbms_output.put_line('##teamcity[testFailed name=''' || l_test_full_name || ''']');
      end if;
      dbms_output.put_line('##teamcity[testFinished name=''' || l_test_full_name || ''' duration=''' ||
                   trunc(l_test.execution_time * 1e3) || ''']');
    end if;
  end;

end;
/
