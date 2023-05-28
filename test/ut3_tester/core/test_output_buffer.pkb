create or replace package body test_output_buffer is

  procedure test_receive is
    l_actual_text        clob;
    l_actual_item_type   varchar2(1000);
    l_remaining          integer;
    l_expected_text      clob;
    l_expected_item_type varchar2(1000);
    l_buffer             ut3_develop.ut_output_buffer_base;
  begin
    --Arrange
    l_buffer        := ut3_develop.ut_output_clob_table_buffer();
    l_expected_text := to_clob(lpad('a text', 31000, ',a text'))
      || chr(10) || to_clob(lpad('a text', 31000, ',a text'))
      || chr(13) || to_clob(lpad('a text', 31000, ',a text'))
      || chr(13) || chr(10) || to_clob(lpad('a text', 31000, ',a text')) || to_clob(lpad('a text', 31000, ',a text'));
    l_expected_item_type := lpad('some item type',1000,'-');
    --Act
    l_buffer.lock_buffer();
    l_buffer.send_clob(l_expected_text, l_expected_item_type);
    l_buffer.close();

    select text, item_type
      into l_actual_text, l_actual_item_type
      from table(l_buffer.get_lines(0.1,0.1));

    --Assert
    ut.expect(l_actual_text).to_equal(l_expected_text);
    ut.expect(l_actual_item_type).to_equal(l_expected_item_type);

    select count(1) into l_remaining from table(ut3_tester_helper.run_helper.ut_output_buffer_tmp) 
      where output_id = l_buffer.output_id;

    ut.expect(l_remaining).to_equal(0);
  end;

  procedure test_wait_for_producer is
    l_buffer  ut3_develop.ut_output_buffer_base;
  begin
    l_buffer := ut3_develop.ut_output_clob_table_buffer();
    ut.expect( l_buffer.get_lines_cursor(0.1) ).to_be_empty();
  end;

  procedure test_doesnt_send_on_null_text is
    l_cur    sys_refcursor;
    l_result integer;
    l_buffer ut3_develop.ut_output_buffer_base := ut3_develop.ut_output_table_buffer();
  begin
    ut3_tester_helper.run_helper.delete_buffer();
    --Act
    l_buffer.send_line(null);

    open l_cur for select * from table(ut3_tester_helper.run_helper.ut_output_buffer_tmp);
    ut.expect(l_cur).to_be_empty;
  end;
  
  
  procedure test_doesnt_send_on_null_elem is
    l_actual   sys_refcursor;
    l_expected sys_refcursor;
    l_buffer ut3_develop.ut_output_buffer_base := ut3_develop.ut_output_table_buffer();
    l_message_id varchar2(255);
    l_text varchar2(4000);
  begin
    ut3_tester_helper.run_helper.delete_buffer();
    --Act
    l_buffer.send_lines(ut3_develop.ut_varchar2_rows(null));
    l_buffer.send_lines(ut3_develop.ut_varchar2_rows('test'));

    open l_actual for
       select text from table(ut3_tester_helper.run_helper.ut_output_buffer_tmp);
    open l_expected for
       select 'test' as text from dual;

    ut.expect(l_actual).to_equal(l_expected);
  end;  
  
  procedure test_send_line is
    l_result   varchar2(4000);
    c_expected constant varchar2(4000) := lpad('a text',4000,',a text');
    l_buffer   ut3_develop.ut_output_buffer_base := ut3_develop.ut_output_table_buffer();
  begin
    l_buffer.send_line(c_expected);

    select text into l_result from table(ut3_tester_helper.run_helper.ut_output_buffer_tmp) where output_id = l_buffer.output_id;

    ut.expect(l_result).to_equal(c_expected);
  end;
  
  procedure test_waiting_for_data is
    l_result    clob;
    l_remaining integer;
    l_expected  clob;
    l_buffer    ut3_develop.ut_output_buffer_base := ut3_develop.ut_output_table_buffer();
    l_start     timestamp;
    l_duration  interval day to second;
  begin
    --Arrange
    l_expected := 'a text';
    l_buffer.lock_buffer();
    l_buffer.send_line(l_expected);
    l_start := localtimestamp;
    --Act
    begin
      select text into l_result from table(l_buffer.get_lines(0,0.3));
      ut.fail('Expected a timeout exception but nothing was raised');
    exception 
      when others then
        l_duration := localtimestamp - l_start;
      --Assert
      --Fetches data from output
      ut.expect(l_result).to_equal(l_expected);
      --Throws a timeout exception
      ut.expect(dbms_utility.format_error_stack()).to_match('ORA'||ut3_develop.ut_utils.gc_out_buffer_timeout);
      --Waited for one second
      ut.expect(l_duration).to_be_greater_or_equal(interval '0.3' second);
    end;

    select count(1) into l_remaining from table(ut3_tester_helper.run_helper.ut_output_buffer_tmp) where output_id = l_buffer.output_id;
    --Data got removed from output buffer
    ut.expect(l_remaining).to_equal(0);

  end;

  procedure test_purge(a_buffer ut3_develop.ut_output_buffer_base ) is
    l_stale_buffer ut3_develop.ut_output_buffer_base := a_buffer;
    l_fresh_buffer ut3_develop.ut_output_buffer_base;
    l_buffer       ut3_develop.ut_output_buffer_base;
  begin
    --Arrange
    l_stale_buffer.start_date := sysdate - 10;
    --initialize with new start date
    l_stale_buffer.init();
    l_stale_buffer.lock_buffer();
    l_stale_buffer.send_line('some text');
    l_stale_buffer.close();

    l_fresh_buffer := ut3_develop.ut_output_table_buffer();
    l_fresh_buffer.lock_buffer();
    l_fresh_buffer.send_line('some text');
    l_fresh_buffer.close();

    --Act - purge is performed on new buffer create
    l_buffer := ut3_develop.ut_output_table_buffer();

    --Assert
    -- Data in "fresh" buffer remains
    ut.expect( l_fresh_buffer.get_lines_cursor(0,0), l_fresh_buffer.self_type ).to_have_count(1);
    -- Data in "stale" buffer is purged and so the call to get_lines_cursor throws ORA-20218
    ut.expect( l_stale_buffer.get_lines_cursor(0,0), l_stale_buffer.self_type ).to_be_empty();
  end;

  procedure test_purge_text_buffer is
  begin
    test_purge(ut3_develop.ut_output_table_buffer());
  end;

  procedure test_purge_clob_buffer is
  begin
    test_purge(ut3_develop.ut_output_clob_table_buffer());
  end;

  procedure text_buffer_send_multibyte is
    l_input       varchar2(32767);
    l_max_len     integer := ut3_develop.ut_utils.gc_max_storage_varchar2_len;
    l_buffer      ut3_develop.ut_output_buffer_base := ut3_develop.ut_output_table_buffer();
    l_text        varchar2(4000);
  begin
    --Arrange
    ut3_tester_helper.run_helper.delete_buffer();
    l_input := rpad( '❤', l_max_len, 'a' );
    ut.expect( lengthb( l_input ) ).to_be_greater_than(l_max_len);

    --Act
    l_buffer.send_line(l_input);
    --Assert
    select text into l_text from table(ut3_tester_helper.run_helper.ut_output_buffer_tmp);
    ut.expect(lengthb(l_text)).to_be_less_or_equal(l_max_len);
  end;

  procedure text_buffer_send_clob_multib is
    l_input       clob;
    l_max_len     integer := ut3_develop.ut_utils.gc_max_storage_varchar2_len;
    l_buffer      ut3_develop.ut_output_buffer_base := ut3_develop.ut_output_table_buffer();
    l_text        varchar2(4000);
  begin
    --Arrange
    ut3_tester_helper.run_helper.delete_buffer();
    l_input := rpad( '❤', l_max_len, 'a' );
    ut.expect( ut3_develop.ut_utils.lengthb_clob( l_input ) ).to_be_greater_than(l_max_len);

    --Act
    l_buffer.send_clob(l_input);
    --Assert
    select  text into l_text from table(ut3_tester_helper.run_helper.ut_output_buffer_tmp);
    ut.expect(lengthb(l_text)).to_be_less_or_equal(l_max_len);
  end;

    end test_output_buffer;
/
