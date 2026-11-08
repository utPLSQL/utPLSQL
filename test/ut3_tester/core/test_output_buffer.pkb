create or replace package body test_output_buffer is

  -- Writer action that waits (up to 30 seconds) until the reader removes the buffer info.
  -- It keeps the writer only as long as the test needs it, so it does not delay jobs of the following tests.
  gc_wait_for_reader_to_finish constant varchar2(4000) := q'[
         for i in 1 .. 300 loop
           select count(1) into l_info_count from ut3_develop.ut_output_buffer_info_tmp b where b.output_id = l_buffer.output_id;
           exit when l_info_count = 0;
           dbms_session.sleep(0.1);
         end loop;]';

  function long_text return varchar2 is
      l_txt varchar2(32767);
  begin
    for i in 1 .. 100 loop
      l_txt := l_txt||lpad('a text', 310, ',a text');
    end loop;
    return l_txt;
  end;

  -- Runs a_writer_actions in a separate session (scheduler job) on a buffer sharing output_id with a_reader.
  -- The writer buffer is available to the actions as l_buffer.
  procedure start_writer(a_reader ut3_develop.ut_output_buffer_base, a_writer_actions varchar2) is
  begin
    ut3_tester_helper.run_helper.run_as_job(
      'declare
         l_buffer     ut3_develop.ut_output_buffer_base := ut3_develop.'||a_reader.self_type||'(a_output_id => '''||a_reader.output_id||''');
         l_info_count integer;
       begin
         '||a_writer_actions||'
       end;'
    );
  end;

  procedure wait_for_writer_lock(a_reader ut3_develop.ut_output_buffer_base) is
    c_max_wait_sec constant number := 30;
    l_waited_sec   number := 0;
  begin
    while a_reader.get_lock_status() = 0 and l_waited_sec < c_max_wait_sec loop
      dbms_session.sleep(0.1);
      l_waited_sec := l_waited_sec + 0.1;
    end loop;
    ut.expect(a_reader.get_lock_status(), 'Writer session holds the buffer lock').not_to_equal(0);
  end;

  procedure reads_lines_from_writer(a_reader ut3_develop.ut_output_buffer_base) is
    l_actual   sys_refcursor;
    l_expected sys_refcursor;
  begin
    --Arrange - writer stays silent for 1 second longer than reader's initial timeout
    start_writer(
      a_reader,
      q'[l_buffer.lock_buffer();
         dbms_session.sleep(1.2);
         l_buffer.send_line('line 1');
         l_buffer.send_line('line 2');
         l_buffer.close();]'
    );
    wait_for_writer_lock(a_reader);
    --Act
    open l_actual for
      select to_char(text) as text from table(a_reader.get_lines(a_initial_timeout => 0.2, a_timeout_sec => 30));
    --Assert
    open l_expected for
      select 'line 1' as text from dual union all
      select 'line 2' as text from dual;
    ut.expect(l_actual).to_equal(l_expected);
  end;

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
    l_expected_text := to_clob('a text') ||long_text()
      || chr(10) || long_text()
      || chr(13) || long_text()
      || chr(13) || chr(10) || long_text() || long_text();
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

  procedure concurrent_calls_do_not_cause_exception is
    l_consumer_buffer_instance ut3_develop.ut_output_buffer_base;
    l_shared_output_id raw(32) := sys_guid();
  begin
    ut3_tester_helper.run_helper.run_as_job('declare x ut3_develop.ut_output_buffer_base; begin x := ut3_develop.ut_output_table_buffer(a_output_id => '''||l_shared_output_id||'''); end;');
    dbms_session.sleep(0.5);
    l_consumer_buffer_instance := ut3_develop.ut_output_table_buffer(a_output_id => l_shared_output_id);
  end;

  procedure table_buffer_reads_from_writer is
  begin
    reads_lines_from_writer(ut3_develop.ut_output_table_buffer());
  end;

  procedure clob_buffer_reads_from_writer is
  begin
    reads_lines_from_writer(ut3_develop.ut_output_clob_table_buffer());
  end;

  procedure bulk_buffer_reads_from_writer is
  begin
    reads_lines_from_writer(ut3_develop.ut_output_bulk_buffer());
  end;

  procedure reader_stops_when_writer_ends is
    l_buffer   ut3_develop.ut_output_buffer_base := ut3_develop.ut_output_table_buffer();
    l_lines    ut3_develop.ut_varchar2_rows;
    l_start    timestamp;
    l_duration interval day to second;
  begin
    --Arrange - writer keeps the lock for a while after sending and its session ends without calling close()
    start_writer(
      l_buffer,
      q'[l_buffer.lock_buffer();
         l_buffer.send_line('line 1');
         dbms_session.sleep(0.5);]'
    );
    wait_for_writer_lock(l_buffer);
    l_start := localtimestamp;
    --Act
    begin
      select to_char(text) bulk collect into l_lines
        from table(l_buffer.get_lines(a_initial_timeout => 1, a_timeout_sec => 2));
    exception
      when others then
        ut.fail('Reader did not stop after writer session ended: '||sqlerrm);
    end;
    l_duration := localtimestamp - l_start;
    --Assert
    ut.expect(anydata.convertCollection(l_lines)).to_equal(anydata.convertCollection(ut3_develop.ut_varchar2_rows('line 1')));
    ut.expect(l_buffer.get_lock_status(), 'Writer lock released by session end').to_equal(0);
    ut.expect(l_duration, 'Reader waited for writer session to end').to_be_greater_or_equal(interval '0.3' second);
  end;

  procedure reader_times_out_on_idle_writer is
    l_buffer ut3_develop.ut_output_buffer_base := ut3_develop.ut_output_table_buffer();
    l_count  integer;
  begin
    --Arrange - writer holds the lock without sending data until the reader gives up
    start_writer(
      l_buffer,
      q'[l_buffer.lock_buffer();
         l_buffer.send_line('line 1');]'
         ||gc_wait_for_reader_to_finish||q'[
         l_buffer.close();]'
    );
    wait_for_writer_lock(l_buffer);
    --Act
    begin
      select count(1) into l_count from table(l_buffer.get_lines(a_initial_timeout => 1, a_timeout_sec => 1));
      ut.fail('Expected a timeout exception but nothing was raised');
    exception
      when others then
      --Assert
        ut.expect(dbms_utility.format_error_stack()).to_match('ORA'||ut3_develop.ut_utils.gc_out_buffer_timeout);
    end;
  end;

  procedure second_writer_cannot_lock is
    l_buffer ut3_develop.ut_output_buffer_base := ut3_develop.ut_output_table_buffer();
  begin
    --Arrange - writer holds the lock until the test is done
    start_writer(
      l_buffer,
      q'[l_buffer.lock_buffer();]'
         ||gc_wait_for_reader_to_finish||q'[
         l_buffer.close();]'
    );
    wait_for_writer_lock(l_buffer);
    --Act
    begin
      l_buffer.lock_buffer();
      l_buffer.close();
      ut.fail('Expected lock_buffer to fail but it succeeded');
    exception
      when others then
      --Assert
        ut.expect(sqlerrm).to_be_like('%Cannot allocate lock for output buffer of reporter%');
    end;
    --Cleanup - let the writer finish
    l_buffer.remove_buffer_info();
  end;

end test_output_buffer;
/
