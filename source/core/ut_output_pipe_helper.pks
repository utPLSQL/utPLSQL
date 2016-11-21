create or replace package ut_output_pipe_helper is

  --the limit size for pipe message is 4096, we want to make sure we're below that limit
  subtype t_pipe_item is varchar(4000 byte);
  subtype t_output_id is varchar2(128 byte);

  --we're assuming max of 2 bytes per char
  gc_size_limit_chars constant integer := 4000/2;

  --decides how long the process will be waiting to flush buffers
  gc_flush_timeout_seconds constant natural := 60;
  gc_text                  constant integer := 9;
  gc_eom                   constant integer := 11;
  gc_eot                   constant integer := 23;
  gc_timeout               constant integer := -1;

  --adds message to pipe buffer and tries to sent all messages from the buffer
  --exists immediately when sending timesout (pipe full)
  --the messages that were sent are removed from buffer
  procedure send_text(a_output_id t_output_id, a_text t_pipe_item);

  --sends a end of message into a a pipe
  procedure send_eom(a_output_id t_output_id);

  --sends a end of message into a a pipe
  procedure send_eot(a_output_id t_output_id);

  --marks a buffer as ready to be flushed and then
  --tries to flush all the data from all the outputs buffers to the pipes
  --in case, all buffers outputs are to be flushed, it will try until a timeout occurs.
  -- If timed out, the open pies get purged and closed
  procedure flush(a_output_id t_output_id, a_timeout_seconds naturaln := gc_flush_timeout_seconds);

  function get_message(a_output_id t_output_id, a_timeout_seconds integer, a_text in out nocopy clob) return integer;

end;
/
