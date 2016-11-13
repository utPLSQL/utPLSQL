create or replace package ut_output_pipe_helper is

  --the limit size for pipe message is 4096, we want to make sure we're below that limit
  subtype t_pipe_item is varchar(4000 byte);

  --we're assuming max of 4 bytes per char
  gc_size_limit_chars constant integer := 1000;

  --adds message to pipe buffer and tries to sent all messages from the buffer
  --exists immediately when sending timesout (pipe full)
  --the messages that were sent are removed from buffer
  procedure send(a_output_id varchar2, a_text t_pipe_item);

  --writes the message to the end of the buffer for pipe
  procedure buffer(a_output_id varchar2, a_text t_pipe_item);

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
