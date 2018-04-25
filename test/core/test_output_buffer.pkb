create or replace package body test_output_buffer is

  procedure test_recieve is
    l_result   varchar2(4000);
    l_remaining integer;
    l_expected varchar2(4000);
    l_buffer   ut3.ut_output_buffer_base := ut3.ut_output_table_buffer();
  begin
  --Act
    l_expected := lpad('a text',4000,',a text');
    l_buffer.send_line(l_expected);

    select * into l_result from table(l_buffer.get_lines(0,0));

    ut.expect(l_result).to_equal(l_expected);

    select count(1) into l_remaining from ut3.ut_output_buffer_tmp where output_id = l_buffer.output_id;

    ut.expect(l_remaining).to_equal(0);
  end;
  
  procedure test_doesnt_send_on_null_text is
    l_cur    sys_refcursor;
    l_result integer;
    l_buffer ut3.ut_output_buffer_base := ut3.ut_output_table_buffer();
  begin
    delete from ut3.ut_output_buffer_tmp;
    --Act
    l_buffer.send_line(null);

    open l_cur for select * from ut3.ut_output_buffer_tmp;
    ut.expect(l_cur).to_be_empty;
  end;
  
  procedure test_send_line is
    l_result   varchar2(4000);
    c_expected constant varchar2(4000) := lpad('a text',4000,',a text');
    l_buffer   ut3.ut_output_buffer_base := ut3.ut_output_table_buffer();
  begin
    l_buffer.send_line(c_expected);

    select text into l_result from ut3.ut_output_buffer_tmp where output_id = l_buffer.output_id;

    ut.expect(l_result).to_equal(c_expected);
  end;
  
  procedure test_waiting_for_data is
    l_result    varchar2(4000);
    l_remaining integer;
    l_expected  varchar2(4000);
    l_buffer    ut3.ut_output_buffer_base := ut3.ut_output_table_buffer();
    l_start     timestamp;
    l_duration  interval day to second;
  begin
  --Act
    l_expected := lpad('a text',4000,',a text');
    l_buffer.send_line(l_expected);
    l_start := systimestamp;
    select * into l_result from table(l_buffer.get_lines(1,1));
    l_duration := systimestamp - l_start;

    ut.expect(l_result).to_equal(l_expected);
    ut.expect(l_duration).to_be_greater_than(interval '1' second);
    select count(1) into l_remaining from ut3.ut_output_buffer_tmp where output_id = l_buffer.output_id;

    ut.expect(l_remaining).to_equal(0);
    
  end;
  
end test_output_buffer;
/
