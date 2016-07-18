create or replace package body ut_assert is

  function current_assert_test_result return integer is
    v_result integer;
  begin
    $if $$ut_trace $then
    dbms_output.put_line('ut_assert.currentasserttestresult');
    $end
  
    v_result := ut_types.tr_success;
    for i in current_asserts_called.first .. current_asserts_called.last loop
      if current_asserts_called(i).result = ut_types.tr_failure then
        v_result := ut_types.tr_failure;
      end if;
    
      if current_asserts_called(i).result = ut_types.tr_error then
        v_result := ut_types.tr_error;
        return v_result;
      end if;
    end loop;
    return v_result;
  end;

  procedure clear_asserts is
  begin
    $if $$ut_trace $then
    dbms_output.put_line('ut_assert.clear_asserts');
    $end
  
    current_asserts_called.delete;
  end;

  procedure process_asserts(newtable out ut_assert_list, result out integer) is
  begin
    $if $$ut_trace $then
    dbms_output.put_line('ut_assert.copy_called_asserts');
    $end
  
    result   := ut_types.tr_success;
    newtable := ut_assert_list(); -- make sure new table is empty
    newtable.extend(current_asserts_called.last);
    for i in current_asserts_called.first .. current_asserts_called.last loop
      $if $$ut_trace $then
      dbms_output.put_line(i || '-start');
      $end
    
      newtable(i) := current_asserts_called(i);
			
      if result = ut_types.tr_success and newtable(i).result in (ut_types.tr_failure, ut_types.tr_error) then
        result := newtable(i).result;
      elsif result = ut_types.tr_failure and newtable(i).result = ut_types.tr_error then
        result := ut_types.tr_error;
      end if;
			
			exit when result = ut_types.tr_error;
    
      $if $$ut_trace $then
      dbms_output.put_line(i || '-end');
      $end
    end loop;
		
		clear_asserts;
  end process_asserts;

  procedure report_assert(assert_result in integer, message in varchar2) is
    v_result ut_assert_result;
  begin
    $if $$ut_trace $then
    dbms_output.put_line('ut_assert.report_assert :' || assert_result || ':' || message);
    $end
    v_result := ut_assert_result(assert_result,message);
    current_asserts_called.extend;
    current_asserts_called(current_asserts_called.last) := v_result;
  end;

  procedure report_success(message in varchar2, expected in varchar2, actual in varchar2) is
  begin
    report_assert(ut_types.tr_success
                 ,nvl(message, '') || ' expected: ' || nvl(expected, '') || ' actual: ' || nvl(actual, ''));
  end;

  procedure report_failure(message in varchar2, expected in varchar2, actual in varchar2) is
  begin
    report_assert(ut_types.tr_failure
                 ,nvl(message, '') || ' expected: ' || nvl(expected, '') || ' actual: ' || nvl(actual, ''));
  end;

  procedure report_error(message in varchar2) is
  begin
    report_assert(ut_types.tr_error, message);
  end;

  procedure are_equal(expected in number, actual in number) is
  begin
    are_equal(expected, actual);
  end;

  procedure are_equal(msg in varchar2, expected in number, actual in number) is
  begin
    if expected = actual then
      report_success(msg, expected, actual);
    else
      report_failure(msg, expected, actual);
    end if;
  end;

end ut_assert;
/
