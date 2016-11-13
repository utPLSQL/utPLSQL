create or replace package body ut_output_pipe_helper is


  type tt_pipe_buffer is table of varchar2(4000);

  type t_output_buffer is record(
    to_close boolean := false,
    data     tt_pipe_buffer
  );

  type tt_outputs_buffer is table of t_output_buffer index by varchar2(128);

  g_outputs_buffer tt_outputs_buffer;

  function send_from_buffer(a_output_id varchar2, a_buffer in out nocopy tt_pipe_buffer) return boolean is
    l_is_successful boolean := true;
    l_first_item    integer;
    l_last_item     integer;
    i integer;
  begin
    if a_buffer is not null then
      l_first_item := a_buffer.first;
      i := l_first_item;
      --iterate through buffer and try to sent all data from buffer
      -- exit loop on timeout
      while i is not null loop
        dbms_pipe.pack_message( a_buffer(i) );
        l_is_successful := dbms_pipe.send_message(a_output_id, 0) = 0;
        exit when not l_is_successful;
        l_last_item := i;
        i := a_buffer.next(i);
      end loop;

      --remove from buffer messages alrady sent
      if not l_is_successful then
        a_buffer.delete(l_first_item, i-1);
      else
        a_buffer.delete();
      end if;
      dbms_pipe.reset_buffer;
      return l_is_successful;
    end if;
    return false;
  end;

  function send_from_buffer(a_output_id varchar2) return boolean is
  begin
    if g_outputs_buffer.exists(a_output_id) then
      return send_from_buffer(a_output_id, g_outputs_buffer(a_output_id).data);
    end if;
    return false;
  end;

  --sends a message to a named pipe
  --and if sending fails it writes the message to the end of the buffer for pipe
  procedure send(a_output_id varchar2, a_text t_pipe_item) is
    l_is_successful boolean;
  begin
      buffer(a_output_id, a_text);
      l_is_successful := send_from_buffer(a_output_id);
  end;

  --writes the message to the end of the buffer for pipe
  procedure buffer(a_output_id varchar2, a_text t_pipe_item) is
  begin
    if not g_outputs_buffer.exists(a_output_id) then
      g_outputs_buffer(a_output_id).data := tt_pipe_buffer();
    end if;
    g_outputs_buffer(a_output_id).data.extend;
    g_outputs_buffer(a_output_id).data(g_outputs_buffer(a_output_id).data.last) :=  a_text;
  end;

  procedure cleanup_outputs_to_close is
    l_output_id           varchar2(128);
    l_output_id_to_delete varchar2(128);
  begin
    l_output_id := g_outputs_buffer.first;
    while i is not null loop
      l_output_id_to_delete := null;
      if g_outputs_buffer(l_output_id).to_close then
        if send_from_buffer(l_output_id) = true then
          l_output_id_to_delete := l_output_id;
        end if;
      end if;
      l_output_id := g_outputs_buffer.next(l_output_id);
      g_outputs_buffer.delete(l_output_id_to_delete);
    end loop;
  end;

  --procedure cleanup_aged_pipes() - check for pipes that are aged out.


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
    cleanup_outputs_to_close;
    --if there is any output in a state to_close = false
    --exit
    --else loop with a wait time of 20 seconds for each to_close output

    --if unable to send all messages after timeout, then finish?

  end;

end;
/
