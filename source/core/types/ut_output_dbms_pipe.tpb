create or replace type body ut_output_dbms_pipe as

  constructor function ut_output_dbms_pipe(self in out nocopy ut_output_dbms_pipe) return self as result is
  begin
    self.output_type := $$plsql_unit;
    self.output_id := self.generate_output_id;
    return;
  end;

  overriding member procedure open(self in out nocopy ut_output_dbms_pipe) is
    l_buffer_size_bytes integer := 100 * 1024 * 1024;
    l_flag integer;
  begin
    --create an explixit private pipe
    --explicitly created pipes need to be removed explicitly
    --otherwise they stay in memmory forever
    --https://docs.oracle.com/cd/B19306_01/appdev.102/b14258/d_pipe.htm#CHDEICJI
    --to check ig there are any non-purged pipes execute:
    --select * from v$db_pipes where pipe_size > 0 order by name desc;
    l_flag := dbms_pipe.create_pipe(self.output_id, l_buffer_size_bytes);
  end;

  overriding member procedure send(self in out nocopy ut_output_dbms_pipe, a_text clob) is
    c_size_limit_chars constant integer := ut_output_pipe_helper.gc_size_limit_chars;
    l_text_part        ut_output_pipe_helper.t_pipe_item;
    i                  integer := 0;
  begin
    --split test into pieces of a size valid for pipe and send to pipe
    while i <= length(a_text) loop
      l_text_part := substr( a_text, i + 1, c_size_limit_chars );
      ut_output_pipe_helper.send( self.output_id, l_text_part);
      i := i + c_size_limit_chars;
    end loop;
    ut_output_pipe_helper.send( self.output_id, ut_utils.gc_output_eom );
  end;

  overriding member procedure close(self in out nocopy ut_output_dbms_pipe) is
  begin
    self.send(ut_utils.gc_output_eot);
  end;

  static function get_lines(a_output_id varchar2, a_timeout_sec integer := 60*60*4) return ut_output_clob_list pipelined is
    l_flag            integer;
    l_text_part       varchar2(4000 byte);
    l_text            clob;
    l_timeout_occured boolean;
  begin
    if a_output_id is null then
      return;
    end if;
    loop
      dbms_lob.createtemporary(l_text, true);
      loop
        l_timeout_occured := dbms_pipe.receive_message(a_output_id, a_timeout_sec) != 0;
        exit when l_timeout_occured;

        dbms_pipe.unpack_message(l_text_part);
        exit when (l_text_part = ut_utils.gc_output_eom or l_text_part = ut_utils.gc_output_eot);
        dbms_lob.writeappend(l_text,length(l_text_part),l_text_part);
      end loop;
      pipe row( l_text );
      exit when (l_text_part = ut_utils.gc_output_eot);
    end loop;
    l_flag := dbms_pipe.remove_pipe(a_output_id);
    return;
  end;

  member procedure to_screen(self in ut_output_dbms_pipe) is
  begin
    for i in (select column_value as text_line from table( ut_output_dbms_pipe.get_lines( self.output_id ) ) ) loop
      dbms_output.put_line(i.text_line);
    end loop;
  end;

  static procedure to_screen(a_output_id varchar2) is
  begin
    for i in (select column_value as text_line from table( ut_output_dbms_pipe.get_lines( a_output_id ) ) ) loop
      dbms_output.put_line(i.text_line);
    end loop;
  end;
end;
/
