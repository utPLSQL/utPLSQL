create or replace package ut_output_pipe_helper is

  --the limit size for pipe message is 4096, we want to make sure we're below that limit
  subtype t_pipe_item is varchar(4000 byte);
  subtype t_output_id is varchar2(128 byte);

  --we're assuming max of 2 bytes per char
  gc_size_limit_chars constant integer := 4000/2;

  --decides how long the process will be waiting to flush buffers
  gc_flush_timeout_seconds constant natural := 60;
  gc_output_eom            constant varchar2(30) := '[{-end-of-message-}]';
  gc_output_eot            constant varchar2(30) := '[{-end-of-transmission-}]';

  --adds message to pipe buffer and tries to sent all messages from the buffer
  --exists immediately when sending timesout (pipe full)
  --the messages that were sent are removed from buffer
  procedure send(a_output_id t_output_id, a_text t_pipe_item);

  --marks a buffer as ready to be flushed and then
  --tries to flush all the data from all the outputs buffers to the pipes
  --in case, all buffers outputs are to be flushed, it will try until a timeout occurs.
  -- If timed out, the open pies get purged and closed
  procedure flush(a_output_id t_output_id, a_timeout_seconds naturaln := gc_flush_timeout_seconds);

end;
/
