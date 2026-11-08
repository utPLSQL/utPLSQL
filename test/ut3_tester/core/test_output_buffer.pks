create or replace package test_output_buffer is

  --%suite(output_buffer)
  --%suitepath(utplsql.ut3_tester.core)


  --%context(Buffer is read in a different session than buffer write)

    --%test(Text buffer reader waits beyond initial timeout for writer holding the lock and reads all lines)
    procedure table_buffer_reads_from_writer;

    --%test(Clob buffer reader waits beyond initial timeout for writer holding the lock and reads all lines)
    procedure clob_buffer_reads_from_writer;

    --%test(Bulk buffer reader waits beyond initial timeout for writer holding the lock and reads all lines)
    procedure bulk_buffer_reads_from_writer;

    --%test(Reader stops when writer session ends without closing the buffer)
    procedure reader_stops_when_writer_ends;

    --%test(Reader times out when writer holds the lock and sends no data)
    procedure reader_times_out_on_idle_writer;

    --%test(Writer cannot lock buffer that is locked by another session)
    procedure second_writer_cannot_lock;

  --%endcontext

  --%context(Read and write within the same session)


      --%test(Receives a line from buffer table and deletes)
      procedure test_receive;

      --%test(Waits specified time for producer to lock the buffer )
      --%throws(-20218)
      procedure test_wait_for_producer;

      --%test(Does not send line if null text given)
      procedure test_doesnt_send_on_null_text;

      --%test(Does not send line if null text given for multiline case)
      procedure test_doesnt_send_on_null_elem;

      --%test(Sends a line into buffer table)
      procedure test_send_line;

      --%test(Waits For The Data To Appear For Specified Time)
      procedure test_waiting_for_data;

      --%test(Purges text buffer data older than one day and leaves the rest)
      procedure test_purge_text_buffer;

      --%test(Purges clob buffer data older than one day and leaves the rest)
      procedure test_purge_clob_buffer;

      --%test(Successfully sends multibyte long line into text buffer)
      procedure text_buffer_send_multibyte;

      --%test(Successfully sends multibyte long clob line into text buffer)
      procedure text_buffer_send_clob_multib;

      --%beforetest(ut3_tester_helper.run_helper.slow_down_insert_into_table_buffer)
      --%aftertest(ut3_tester_helper.run_helper.cleanup_slow_down_insert_into_table_buffer)
      --%test(concurrent calls to init() procedure do not cause errors - Issue #985)
      procedure concurrent_calls_do_not_cause_exception;

  --%endcontext

end test_output_buffer;
/
