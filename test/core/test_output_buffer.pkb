create or replace package body test_output_buffer is

  procedure test_recieve is
    l_result   varchar2(4000);
    l_remaining integer;
    l_expected varchar2(4000);
    l_reporter ut3.ut_reporter_base :=ut3. ut_documentation_reporter();
  begin
  --Act
    l_expected := lpad('a text',4000,',a text');
    ut3.ut_output_buffer.send_line(l_reporter, l_expected);

    select * into l_result from table(ut3.ut_output_buffer.get_lines(l_reporter.reporter_id,0));

    ut.expect(l_result).to_equal(l_expected);

    select count(1) into l_remaining from ut3.ut_output_buffer_tmp where reporter_id = l_reporter.reporter_id;

    ut.expect(l_remaining).to_equal(0);
  end;
  
  procedure test_doesnt_send_on_null_id is
    l_cur sys_refcursor;
  begin
    delete from ut3.ut_output_buffer_tmp;
    --Act
    ut3.ut_output_buffer.send_line(null,'a text to send');
    
    open l_cur for select * from ut3.ut_output_buffer_tmp;

    ut.expect(l_cur).to_be_empty;
  end;
  
  procedure test_doesnt_send_on_null_text is
    l_cur sys_refcursor;
    l_result integer;
    l_reporter ut3.ut_reporter_base := ut3.ut_documentation_reporter();
  begin
    delete from ut3.ut_output_buffer_tmp;
    --Act
    ut3.ut_output_buffer.send_line(l_reporter,null);

    open l_cur for select * from ut3.ut_output_buffer_tmp;
    ut.expect(l_cur).to_be_empty;
  end;
  
  procedure test_send_line is
    l_result   varchar2(4000);
    c_expected constant varchar2(4000) := lpad('a text',4000,',a text');
    l_reporter ut3.ut_reporter_base := ut3.ut_documentation_reporter();
  begin
    ut3.ut_output_buffer.send_line(l_reporter, c_expected);

    select text into l_result from ut3.ut_output_buffer_tmp where reporter_id = l_reporter.reporter_id;

    ut.expect(l_result).to_equal(c_expected);
  end;
  
  procedure test_waiting_for_data is
    l_result   varchar2(4000);
    l_remaining integer;
    l_expected varchar2(4000);
    l_reporter ut3.ut_reporter_base := ut3.ut_documentation_reporter();
  begin
  --Act
    l_expected := lpad('a text',4000,',a text');
    ut3.ut_output_buffer.send_line(l_reporter, l_expected);

    select * into l_result from table(ut3.ut_output_buffer.get_lines(l_reporter.reporter_id,0));

    ut.expect(l_result).to_equal(l_expected);

    select count(1) into l_remaining from ut3.ut_output_buffer_tmp where reporter_id = l_reporter.reporter_id;

    ut.expect(l_remaining).to_equal(0);
    
  end;
  
end test_output_buffer;
/
