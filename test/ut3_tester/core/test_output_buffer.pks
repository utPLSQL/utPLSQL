create or replace package test_output_buffer is

  --%suite(output_buffer)
  --%suitepath(utplsql.ut3_tester.core)


  --%context(Read and write within the same session)


  --%endcontext
  
  --%context(Buffer is read in a different session than buffer write)

    --reader will wait for a_initial_timeout seconds for the writer process to start and then it will finish with error

    --reader will wait forever (beyond a_initial_timeout) if the writer process is started and end of data row was not received from the buffer

    --reader stops after reading the end of data signal from the buffer

    --reader stops when writer process ends and all data was read from the buffer


  --%endcontext

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

end test_output_buffer;
/
