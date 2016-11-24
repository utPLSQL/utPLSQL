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

  overriding member procedure send_line(self in out nocopy ut_output_dbms_pipe, a_text varchar2) is
  begin
    self.send_clob(a_text);
  end;

  overriding member procedure send_clob(self in out nocopy ut_output_dbms_pipe, a_text clob) is
    c_size_limit_chars constant integer := ut_output_pipe_helper.gc_size_limit_chars;
    l_text_part        ut_output_pipe_helper.t_pipe_item;
    i                  integer := 0;
  begin
    --split test into pieces of a size valid for pipe and send to pipe
    while i < length(a_text) loop
      l_text_part := substr( a_text, i + 1, c_size_limit_chars );
      ut_output_pipe_helper.send_text( self.output_id, l_text_part);
      i := i + c_size_limit_chars;
    end loop;
    --SEND is closed by a EOM message
    ut_output_pipe_helper.send_eom(self.output_id);
  end;

  --we do not remove the pipe here, it is responsibility of the consumer,
  --when the pipe is fully consumed (recieved 'eot') then the consumer removed the pipe
  overriding member procedure close(self in out nocopy ut_output_dbms_pipe, a_timeout_sec integer) is
  begin
    ut_output_pipe_helper.send_eot(self.output_id);
    ut_output_pipe_helper.flush(self.output_id, a_timeout_sec);
  end;

  overriding member function get_lines(a_output_id varchar2, a_timeout_sec naturaln) return ut_varchar2_list pipelined is
    c_max_line_length constant integer := 4000;
    l_text            clob;
    l_result_flag     integer;
    l_results_tab     ut_varchar2_list;
  begin
    if a_output_id is null then
      return;
    end if;

    loop
      dbms_lob.createtemporary(l_text, true);
      --get message as a clob data and recieve information if the message is ended, timed out or it is the end of transmission
      l_result_flag := ut_output_pipe_helper.get_message(a_output_id, a_timeout_sec, l_text);
      -- convert message into collection of varchar2(4000) for SQL processing
      select column_value bulk collect into l_results_tab from table( ut_utils.clob_to_table(l_text, c_max_line_length));
      --pipe results one by one
      for i in 1 .. l_results_tab.count loop
        pipe row( l_results_tab(i) );
      end loop;
      dbms_lob.freetemporary(l_text);

      exit when l_result_flag in (ut_output_pipe_helper.gc_eot, ut_output_pipe_helper.gc_timeout);
    end loop;
    if l_result_flag = ut_output_pipe_helper.gc_eot then
      ut_output_pipe_helper.remove_pipe(a_output_id);
    end if;
    return;
  end;

  overriding final member function get_clob_lines(a_output_id varchar2, a_timeout_sec naturaln) return ut_clob_list pipelined is
    l_text            clob;
    l_result_flag     integer;
    l_results_tab     ut_varchar2_list;
  begin
    if a_output_id is null then
      return;
    end if;

    loop
      dbms_lob.createtemporary(l_text, true);
      l_result_flag := ut_output_pipe_helper.get_message(a_output_id, a_timeout_sec, l_text);
      exit when l_result_flag in (ut_output_pipe_helper.gc_eot, ut_output_pipe_helper.gc_timeout);
      pipe row( l_text );
      dbms_lob.freetemporary(l_text);
    end loop;
    dbms_lob.freetemporary(l_text);
    if l_result_flag = ut_output_pipe_helper.gc_eot then
      ut_output_pipe_helper.remove_pipe(a_output_id);
    end if;
    return;
  end;

end;
/
