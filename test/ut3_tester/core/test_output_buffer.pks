create or replace package test_output_buffer is

  --%suite(output_buffer)
  --%suitepath(utplsql.ut3_tester.core)
  
  --%test(Receives a line from buffer table and deletes)
  procedure test_receive;
  
  --%test(Does not send line if null text given)
  procedure test_doesnt_send_on_null_text;
  
  --%test(Does not send line if null text given for multiline case)
  procedure test_doesnt_send_on_null_elem;
  
  --%test(Sends a line into buffer table)
  procedure test_send_line;
  
  --%test(Waits For The Data To Appear For Specified Time)
  procedure test_waiting_for_data;

  --%test(Purges text buffer data older than one day and leaves the rest)
  --%throws(-20218)
  procedure test_purge_text_buffer;

  --%test(Purges clob buffer data older than one day and leaves the rest)
  --%throws(-20218)
  procedure test_purge_clob_buffer;

end test_output_buffer;
/
