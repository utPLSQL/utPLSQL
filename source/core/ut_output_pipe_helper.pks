create or replace package ut_output_pipe_helper is

  --sends a message to a named pipe
  --and if sending fails it writes the message to the end of the buffer for pipe
  procedure send(a_output_id varchar2, a_text varchar2);

  --writes the message to the end of the buffer for pipe
  procedure buffer(a_output_id varchar2, a_text varchar2);

  --registers a close request and tries to close a pipe
  --by first sending out all messages remaining in the buffers
  --the procedure holds infomrmation about closure requests
  --so that if close is not possble as buffer was not yet flusehd
  --it will proceed to other close requests
  --scenario with failure:
  -- two buffers used: output_1, output_2
  -- call is made to close output_1
  -- register the close request
  -- send all messaged from output_1 buffer
  -- if buffer not empty and timeout
  -- go to output_2
  -- if output_2 is still open, return
  -- so the outout_1 close request is in a pending state
  -- next a call should be made from framework to close output_2
  -- register the close request
  -- send all messaged from output_2 buffer
  -- if buffer not empty and timeout
  -- go to output_1
  -- if output_1 has a pending close
  -- try to send from output_1 buffer
  -- if timeout -> raise
  --scenario with success:
  -- two buffers used: output_1, output_2
  procedure request_close(a_output_id varchar2, a_text varchar2);

end;
/
