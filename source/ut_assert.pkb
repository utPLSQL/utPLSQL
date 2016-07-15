create or replace package body ut_assert
is
 
 function current_assert_test_result return ut_types.test_result
 is
   v_result ut_types.test_result;
 begin
    $if $$ut_trace $then dbms_output.put_line('ut_assert.currentasserttestresult'); $end
	
    v_result := ut_types.tr_success; 
    for i in current_asserts_called.first .. current_asserts_called.last
    loop
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
 
 procedure clear_asserts
 is
 begin
    $if $$ut_trace $then dbms_output.put_line('ut_assert.clear_asserts'); $end
    
	current_asserts_called.delete;
 end;
  
 procedure copy_called_asserts(newtable in out ut_types.assert_list)
 is
 begin
    $if $$ut_trace $then dbms_output.put_line('ut_assert.copy_called_asserts'); $end
	
    newtable.delete; -- make sure new table is empty
    newtable.extend(current_asserts_called.last);
    for i in current_asserts_called.first..current_asserts_called.last
    loop
        $if $$ut_trace $then dbms_output.put_line(i || '-start'); $end
		
        newtable(i) := current_asserts_called(i);
		
        $if $$ut_trace $then dbms_output.put_line(i || '-end'); $end
    end loop;
 end;
 
 procedure report_assert(assert_result in ut_types.test_result,message in varchar2)
 is
   v_result ut_types.assert_result;
 begin
   $if $$ut_trace $then dbms_output.put_line('ut_assert.report_assert :' || assert_result || ':' || message ); $end
   
   v_result.result := assert_result;
   v_result.message := message;
   current_asserts_called.extend;
   current_asserts_called(current_asserts_called.last) := v_result;
 end;
 
  
 procedure report_success(message in varchar2,expected in varchar2,actual in varchar2)
 is
 begin
   report_assert(ut_types.tr_success,nvl(message,'') || ' expected: ' || nvl(expected,'') || ' actual: ' || nvl(actual,''));
 end;
 
procedure report_failure(message in varchar2,expected in varchar2,actual in varchar2)
is
begin
    report_assert(ut_types.tr_failure,nvl(message,'') || ' expected: ' || nvl(expected,'') || ' actual: ' || nvl(actual,''));   
end;
 
procedure report_error(message in varchar2)
is
begin
    report_assert(ut_types.tr_error,message);
end;
 
procedure are_equal(expected in number,actual in number)
is
begin
    are_equal(expected,actual);
end;
 
procedure are_equal(msg in varchar2, expected in number,actual in number)
is
begin
    if expected = actual then
        report_success(msg,expected,actual); 
    else
        report_failure(msg,expected,actual);
    end if;
end; 
  

end ut_assert;
