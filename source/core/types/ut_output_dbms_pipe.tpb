create or replace type body ut_output_dbms_pipe as

  constructor function ut_output_dbms_pipe(self in out nocopy ut_output_dbms_pipe) return self as result is
  begin
    self.output_type := $$plsql_unit;
    self.output_id := self.generate_output_id;
    return;
  end;

  overriding member procedure open(self in out nocopy ut_output_dbms_pipe) is
    l_flag integer;
  begin
    --create an explicit private pipe. Explicitly created pipes need to be removed explicitly
    --otherwise they stay in memmory forever https://docs.oracle.com/cd/B19306_01/appdev.102/b14258/d_pipe.htm#CHDEICJI
    --to check if there are any non-purged pipes execute:  select * from v$db_pipes where pipe_size > 0 order by name desc;
    l_flag := dbms_pipe.create_pipe(self.output_id);
  end;

  overriding member procedure send(self in out nocopy ut_output_dbms_pipe, a_text clob) is
    c_size_limit_chars constant integer := ut_output_pipe_helper.gc_size_limit_chars;
    l_text_part        ut_output_pipe_helper.t_pipe_item;
    i                  integer := 0;
  begin
    --split test into pieces of a size valid for pipe and send to pipe
    while i < length(a_text) loop
      l_text_part := substr( a_text, i + 1, c_size_limit_chars );
      ut_output_pipe_helper.send( self.output_id, l_text_part);
      i := i + c_size_limit_chars;
    end loop;
    --SEND is closed by a EOM message
    ut_output_pipe_helper.send_eom(self.output_id);
  end;

  overriding member procedure close(self in out nocopy ut_output_dbms_pipe) is
  begin
    ut_output_pipe_helper.send_eot(self.output_id);
    ut_output_pipe_helper.flush(self.output_id);
  end;

  static function get_lines(a_output_id varchar2, a_timeout_sec integer := 60*60*4) return ut_output_clob_list pipelined is
    l_flag            integer;
    l_text_part       ut_output_pipe_helper.t_pipe_item;
    l_text            clob;
    l_timeout_occured boolean;
    l_need_to_send    boolean;
    l_item_type       integer;
  begin
    if a_output_id is not null then

      loop
        dbms_lob.createtemporary(l_text, true);
        l_need_to_send := false;

        --build a row. As a rule one call to 'send' is one row.
        -- TODO - add detection of newline so that for each new line recieved in text, the code generates a new output row
        loop
          dbms_pipe.reset_buffer;
          l_timeout_occured := (dbms_pipe.receive_message(a_output_id, a_timeout_sec) != 0);
          exit when l_timeout_occured;
          l_item_type := dbms_pipe.next_item_type();
          exit when l_item_type in (ut_output_pipe_helper.gc_eom, ut_output_pipe_helper.gc_eot);
          dbms_pipe.unpack_message(l_text_part);
          if l_text_part is not null then
            dbms_lob.writeappend(l_text, length(l_text_part), l_text_part);
          end if;
          l_need_to_send := true;
        end loop;

        if l_need_to_send then
          pipe row( l_text );
          dbms_lob.freetemporary(l_text);
        end if;

        exit when (l_timeout_occured or l_item_type = ut_output_pipe_helper.gc_eot);
      end loop;

      l_flag := dbms_pipe.remove_pipe(a_output_id);
    end if;
    return;
  end;

end;
/
