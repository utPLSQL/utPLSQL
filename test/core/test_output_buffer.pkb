create or replace package body test_output_buffer is

  procedure test_receive is
    l_actual_text        clob;
    l_actual_item_type   varchar2(1000);
    l_remaining          integer;
    l_expected_text      clob;
    l_expected_item_type varchar2(1000);
    l_buffer             ut3.ut_output_buffer_base;
  begin
    --Arrange
    l_buffer        := ut3.ut_output_table_buffer();
    l_expected_text := to_clob(lpad('a text', 31000, ',a text'))
      || chr(10) || to_clob(lpad('a text', 31000, ',a text'))
      || chr(13) || to_clob(lpad('a text', 31000, ',a text'))
      || chr(13) || chr(10) || to_clob(lpad('a text', 31000, ',a text')) || to_clob(lpad('a text', 31000, ',a text'));
    l_expected_item_type := lpad('some item type',1000,'-');
    --Act
    l_buffer.send_clob(l_expected_text, l_expected_item_type);

    select text, item_type
      into l_actual_text, l_actual_item_type
      from table(l_buffer.get_lines(0,0));

    --Assert
    ut.expect(l_actual_text).to_equal(l_expected_text);
    ut.expect(l_actual_item_type).to_equal(l_expected_item_type);

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
    l_result    clob;
    l_remaining integer;
    l_expected  clob;
    l_buffer    ut3.ut_output_buffer_base := ut3.ut_output_table_buffer();
    l_start     timestamp;
    l_duration  interval day to second;
  begin
  --Act
    l_expected := 'a text';
    l_buffer.send_line(l_expected);
    l_start := localtimestamp;
    select text into l_result from table(l_buffer.get_lines(1,1));
    l_duration := localtimestamp - l_start;

    ut.expect(l_result).to_equal(l_expected);
    ut.expect(l_duration).to_be_greater_than(interval '0.99' second);
    select count(1) into l_remaining from ut3.ut_output_buffer_tmp where output_id = l_buffer.output_id;

    ut.expect(l_remaining).to_equal(0);
  end;
  
end test_output_buffer;
/
