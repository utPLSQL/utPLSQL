create or replace package body ut_output_pipe_helper is

  -- private

  type tt_pipe_buffer is table of varchar2(4000);

  type t_output_buffer is record(
    to_flush boolean := false,
    data     tt_pipe_buffer
  );

  type tt_outputs_buffer is table of t_output_buffer index by t_output_id;

  g_outputs_buffer tt_outputs_buffer;

  --sends all data from buffer to pipe and returns false if timeout occured
  function send_from_buffer(a_output_id t_output_id, a_buffer in out nocopy tt_pipe_buffer, a_timeout_seconds naturaln := 0) return boolean is
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
        l_is_successful := dbms_pipe.send_message(a_output_id, a_timeout_seconds) = 0;
        exit when not l_is_successful;
        l_last_item := i;
        i := a_buffer.next(i);
      end loop;

      --remove from buffer messages alrady sent
      if not l_is_successful then
        a_buffer.delete(l_first_item, i-1);
      else
        a_buffer.delete;
      end if;
      dbms_pipe.reset_buffer;
      return l_is_successful;
    end if;
    return false;
  end;

  --sends all data from an output buffer to pipe and returns false if timeout occured
  function send_from_buffer(a_output_id t_output_id, a_timeout_seconds naturaln := 0) return boolean is
  begin
    if g_outputs_buffer.exists(a_output_id) then
      return send_from_buffer(a_output_id, g_outputs_buffer(a_output_id).data, a_timeout_seconds);
    end if;
    return false;
  end;

  --iterates through all the output buffers that were not purged
  --for each buffer tries to send the content of the buffer
  --if all content was sent, buffer is recycled (removed)
  function flush_buffers(a_timeout_seconds naturaln := 0) return boolean is
    l_output_id           t_output_id;
    l_output_id_to_delete t_output_id;
    l_pipe_removal_status integer;
    l_timed_out           boolean := false;
  begin
    l_output_id := g_outputs_buffer.first;
    while l_output_id is not null loop
      l_output_id_to_delete := null;
      if send_from_buffer(l_output_id, a_timeout_seconds) = true then
        l_output_id_to_delete := l_output_id;
      else
        l_timed_out := true;
      end if;
      l_output_id := g_outputs_buffer.next(l_output_id);

      if l_output_id_to_delete is not null then
        g_outputs_buffer.delete(l_output_id_to_delete);
      end if;

    end loop;
    return not l_timed_out;
  end;

  --check if all the buffers are waiting to be flushed
  function all_buffers_to_flush return boolean is
    l_output_id t_output_id;
  begin
    l_output_id := g_outputs_buffer.first;
    while l_output_id is not null loop
      if not g_outputs_buffer(l_output_id).to_flush then
        return false;
      end if;
      l_output_id := g_outputs_buffer.next(l_output_id);
    end loop;
    return true;
  end;

  --remove all the pipes anf purges all the buffers
  procedure purge is
    l_pipe_removal_status integer;
    l_output_id           t_output_id;
  begin
    l_output_id := g_outputs_buffer.first;
    while l_output_id is not null loop
      l_output_id := g_outputs_buffer.next(l_output_id);
    end loop;
    g_outputs_buffer.delete;
  end;

  --writes the message to the end of the buffer
  procedure buffer(a_output_id t_output_id, a_text t_pipe_item) is
  begin
    if not g_outputs_buffer.exists(a_output_id) then
      g_outputs_buffer(a_output_id).data := tt_pipe_buffer();
      g_outputs_buffer(a_output_id).to_flush := false;
    end if;
    g_outputs_buffer(a_output_id).data.extend;
    g_outputs_buffer(a_output_id).data(g_outputs_buffer(a_output_id).data.last) :=  a_text;
  end;


  ---public

  --adds message to pipe buffer and tries to sent all messages from the buffer
  --exists immediately when sending timesout (pipe full)
  --the messages that were sent are removed from buffer
  procedure send(a_output_id t_output_id, a_text t_pipe_item) is
    l_is_successful boolean;
  begin
      buffer(a_output_id, a_text);
      l_is_successful := send_from_buffer(a_output_id);
  end;

  --marks a buffer as ready to be flushed
  --tries to flush all the data from all the outputs buffers to the pipes immediately
  --in case, all buffers outputs are to be flused, it will try with a timeout.
  procedure flush(a_output_id t_output_id, a_timeout_seconds naturaln := gc_flush_timeout_seconds) is
  begin
    if g_outputs_buffer.exists(a_output_id) then
      g_outputs_buffer(a_output_id).to_flush := true;
    end if;

    if (flush_buffers() = false) and all_buffers_to_flush then
      --try as many times as there are seconds for timeout
      --each time try with one second delay
      for i in 1 .. a_timeout_seconds loop
        exit when flush_buffers(a_timeout_seconds => 1) = true;
      end loop;
      purge();
    end if;

  end;

end;
/
