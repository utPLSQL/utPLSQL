create or replace package body ut_output_pipe_helper is


  type t_pipe_buffer is table of varchar2(4000);
  type t_outputs_buffer is table of t_pipe_buffer index by varchar2(128);

  g_outputs_buffer t_outputs_buffer;

  procedure send_from_buffer(a_output_id varchar2) is
    l_timeout_occured boolean;
    i integer;
  begin
    if g_outputs_buffer.exists(a_output_id) then
      i :=  g_outputs_buffer(a_output_id).first;
      while i is not null loop
        dbms_pipe.pack_message( g_outputs_buffer(a_output_id)(i) );
        l_timeout_occured := dbms_pipe.send_message(a_output_id, 0) != 0;
        if l_timeout_occured then
          dbms_pipe.reset_buffer;
          return;
        end if;
      end loop;
    end if;
  end;

  --sends a message to a named pipe
  --and if sending fails it writes the message to the end of the buffer for pipe
  procedure send(a_output_id varchar2, a_text varchar2) is
    l_timeout_occured boolean;
  begin
      send_from_buffer(a_output_id);
      dbms_pipe.pack_message( a_text );
      l_timeout_occured := dbms_pipe.send_message(a_output_id, 0) != 0;
      if l_timeout_occured then
        dbms_pipe.reset_buffer;
        buffer(a_output_id, a_text);
      end if;
  end;

  --writes the message to the end of the buffer for pipe
  procedure buffer(a_output_id varchar2, a_text varchar2) is
  begin
    if not g_outputs_buffer.exists(a_output_id) then
      g_outputs_buffer(a_output_id) := t_pipe_buffer();
    end if;
    g_outputs_buffer(a_output_id).extend;
    g_outputs_buffer(a_output_id)(g_outputs_buffer(a_output_id).last) :=  a_text;
  end;

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
  procedure request_close(a_output_id varchar2, a_text varchar2) is
  begin
    null;
  end;

end;
/
