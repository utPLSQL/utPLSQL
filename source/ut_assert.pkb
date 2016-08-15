create or replace package body ut_assert is

  g_current_asserts_called ut_objects_list := ut_objects_list();

  function current_assert_test_result return integer is
  begin
    $if $$ut_trace $then
    dbms_output.put_line('ut_assert.current_assert_test_result');
    $end
  
    return get_assert_list_final_result(g_current_asserts_called);
  end;

  function get_assert_list_final_result(a_assert_list in ut_objects_list) return integer is
    l_result integer;
    l_assert ut_assert_result;
  begin
    $if $$ut_trace $then
    dbms_output.put_line('ut_assert.get_assert_list_final_result');
    $end
  
    if a_assert_list is not null then
    
      l_result := ut_utils.tr_success;
      for i in a_assert_list.first .. a_assert_list.last loop
				l_assert := treat(a_assert_list(i) as ut_assert_result);
        if l_assert.result = ut_utils.tr_failure then
          l_result := ut_utils.tr_failure;
        end if;
      
        if l_assert.result = ut_utils.tr_error then
          l_result := ut_utils.tr_error;
          exit;
        end if;
      end loop;
    
    end if;
    return l_result;
  end get_assert_list_final_result;

  procedure clear_asserts is
  begin
    $if $$ut_trace $then
    dbms_output.put_line('ut_assert.clear_asserts');
    $end
  
    g_current_asserts_called.delete;
  end;

  procedure process_asserts(a_newtable out ut_objects_list) is
  begin
    $if $$ut_trace $then
    dbms_output.put_line('ut_assert.copy_called_asserts');
    $end
  
    a_newtable := ut_objects_list(); -- make sure new table is empty
    a_newtable.extend(g_current_asserts_called.last);
    for i in g_current_asserts_called.first .. g_current_asserts_called.last loop
      $if $$ut_trace $then
      dbms_output.put_line(i || '-start');
      $end
    
      a_newtable(i) := g_current_asserts_called(i);
    
      $if $$ut_trace $then
      dbms_output.put_line(i || '-end');
      $end
    end loop;
  
    clear_asserts;
  end process_asserts;

  procedure report_assert(a_assert_result in integer, a_message in varchar2) is
    l_result ut_assert_result;
  begin
    $if $$ut_trace $then
    dbms_output.put_line('ut_assert.report_assert :' || a_assert_result || ':' || a_message);
    $end
    l_result := ut_assert_result(a_assert_result, a_message);
    g_current_asserts_called.extend;
    g_current_asserts_called(g_current_asserts_called.last) := l_result;
  end;

  procedure report_success(a_message in varchar2, a_expected in varchar2, a_actual in varchar2) is
  begin
    report_assert(ut_utils.tr_success
                 ,nvl(a_message, '') || ' expected: ' || nvl(a_expected, '') || ' actual: ' || nvl(a_actual, ''));
  end;

  procedure report_failure(a_message in varchar2, a_expected in varchar2, a_actual in varchar2) is
  begin
    report_assert(ut_utils.tr_failure
                 ,nvl(a_message, '') || ' expected: ' || nvl(a_expected, '') || ' actual: ' || nvl(a_actual, ''));
  end;

  procedure report_error(a_message in varchar2) is
  begin
    report_assert(ut_utils.tr_error, a_message);
  end;

  procedure are_equal(a_expected in number, a_actual in number) is
  begin
    are_equal('Equality test', a_expected, a_actual);
  end;

  procedure are_equal(a_msg in varchar2, a_expected in number, a_actual in number) is
  begin
    if a_expected = a_actual then
      report_success(a_msg, a_expected, a_actual);
    else
      report_failure(a_msg, a_expected, a_actual);
    end if;
  end;

end ut_assert;
/
