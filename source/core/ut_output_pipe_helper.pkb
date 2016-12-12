create or replace package body ut_output_pipe_helper is

  -- private
  type t_pipe_buffer_rec is record(
    message_type integer,
    message      varchar2(4000)
  );
  type tt_pipe_buffer is table of t_pipe_buffer_rec;

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
        if a_buffer(i).message_type = gc_eom then
          dbms_pipe.pack_message_rowid( NULL );
        elsif a_buffer(i).message_type = gc_eot then
          dbms_pipe.pack_message_raw( NULL );
        elsif a_buffer(i).message_type = gc_text then
          dbms_pipe.pack_message( a_buffer(i).message );
        end if;
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
  --returns true if the flushing succeeded for all buffers
  function flush_buffers(a_timeout_seconds naturaln := 0) return boolean is
    l_output_id           t_output_id;
    l_output_id_to_delete t_output_id;
    l_pipe_removal_status integer;
    l_succeeded           boolean := false;
  begin
    l_output_id := g_outputs_buffer.first;
    while l_output_id is not null loop
      l_output_id_to_delete := null;

      l_succeeded := send_from_buffer(l_output_id, a_timeout_seconds);
      if l_succeeded then
        l_output_id_to_delete := l_output_id;
      end if;
      l_output_id := g_outputs_buffer.next(l_output_id);

      if l_output_id_to_delete is not null then
        g_outputs_buffer.delete(l_output_id_to_delete);
      end if;

    end loop;
    return l_succeeded;
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

  -- - remove pipes associated with buffers that are not yet deleted
  -- - delete all the buffers
  -- TODO - The purge procedure needs to be called by top level program (ut_runner)
  --  in the EXCEPTION WHEN OTHERS block before raising back,
  --  so that it tries to remove pipes on any exception before raising back to caller
  procedure purge is
    l_output_id           t_output_id;
  begin
    l_output_id := g_outputs_buffer.first;
    while l_output_id is not null loop
      remove_pipe(l_output_id);
      l_output_id := g_outputs_buffer.next(l_output_id);
    end loop;
    g_outputs_buffer.delete;
  end;

  --writes the message to the end of the buffer
  procedure buffer(a_output_id t_output_id, a_message_type integer, a_text t_pipe_item := null) is
  begin
    if not g_outputs_buffer.exists(a_output_id) then
      g_outputs_buffer(a_output_id).data := tt_pipe_buffer();
      g_outputs_buffer(a_output_id).to_flush := false;
    end if;
    g_outputs_buffer(a_output_id).data.extend;
    g_outputs_buffer(a_output_id).data(g_outputs_buffer(a_output_id).data.last).message_type :=  a_message_type;
    g_outputs_buffer(a_output_id).data(g_outputs_buffer(a_output_id).data.last).message :=  a_text;
  end;


  procedure buffer_and_send(a_output_id t_output_id, a_message_type integer, a_text t_pipe_item:= null) is
    l_is_successful boolean;
  begin
      buffer(a_output_id, a_message_type, a_text);
      l_is_successful := send_from_buffer(a_output_id);
  end;
  ---public

  --adds message to pipe buffer and tries to sent all messages from the buffer
  --exists immediately when sending timesout (pipe full)
  --the messages that were sent are removed from buffer
  procedure send_text(a_output_id t_output_id, a_text t_pipe_item) is
    l_is_successful boolean;
  begin
      buffer_and_send(a_output_id, gc_text, a_text);
  end;

  --sends a end of message into a a pipe
  procedure send_eom(a_output_id t_output_id) is
    l_is_successful boolean;
  begin
      buffer_and_send(a_output_id, gc_eom);
  end;

  --sends a end of message into a a pipe
  procedure send_eot(a_output_id t_output_id) is
    l_is_successful boolean;
  begin
      buffer_and_send(a_output_id, gc_eot);
  end;

  --marks a buffer as ready to be flushed
  --tries to flush all the data from all the outputs buffers to the pipes immediately
  --in case, all buffers outputs are to be flused, it will try with a timeout.
  procedure flush(a_output_id t_output_id, a_timeout_seconds naturaln) is
    l_buffers_flushed boolean := false;
  begin
    if g_outputs_buffer.exists(a_output_id) then
      g_outputs_buffer(a_output_id).to_flush := true;
    end if;

    l_buffers_flushed := flush_buffers();
    --if failed to flush data from buffer and all buffers are ready to be flushed
    if not l_buffers_flushed and all_buffers_to_flush() then
      --try as many times as there are seconds for timeout
      --each time try with one second delay
      for i in 1 .. a_timeout_seconds loop
        l_buffers_flushed := flush_buffers(a_timeout_seconds => 1);
        exit when l_buffers_flushed;
      end loop;

      --if timeout occured and buffers were not flushed then
      -- - remove pipes associated with non flushed buffers
      -- - delete the buffers
      if not l_buffers_flushed then
        purge();
      end if;
    end if;

  end;

  function get_message(a_output_id t_output_id, a_timeout_seconds integer, a_text in out nocopy clob) return integer is
    l_result_flag     integer :=0;
    l_status          integer;
    l_text_part       ut_output_pipe_helper.t_pipe_item;
    l_item_type       integer;
  begin
    loop
      dbms_pipe.reset_buffer;
      if 0 != dbms_pipe.receive_message(a_output_id, a_timeout_seconds) then
        l_result_flag := gc_timeout;
      else
        l_result_flag := dbms_pipe.next_item_type();
      end if;
      exit when l_result_flag in (gc_eom, gc_eot, gc_timeout);

      dbms_pipe.unpack_message(l_text_part);
      if l_text_part is not null then
        dbms_lob.writeappend(a_text, length(l_text_part), l_text_part);
      end if;
    end loop;
    if l_result_flag in (gc_eot, gc_timeout) then
      remove_pipe(a_output_id);
    end if;
    return l_result_flag;
  end;

  procedure remove_pipe(a_output_id t_output_id) is
    l_status          integer;
  begin
    l_status := dbms_pipe.remove_pipe(a_output_id);
  end remove_pipe;

end;
/
