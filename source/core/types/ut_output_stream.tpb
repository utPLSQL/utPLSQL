create or replace type body ut_output_stream as

  overriding final member procedure close(self in out nocopy ut_output_stream) is
  begin
    self.close(a_timeout_sec => 60);
  end;

  overriding final member function get_lines(a_output_id varchar2) return ut_varchar2_list
    pipelined is
    cursor l_cur is
      select column_value from table(self.get_lines(a_output_id, 60 * 60 * 4));
    l_col_value varchar2(32767);
  begin
    open l_cur;
  
    -- open-fetch-close routine is used to prevent optimization as we need row by row quering
    loop
      fetch l_cur
        into l_col_value;
      exit when l_cur%notfound;
      pipe row(l_col_value);
    end loop;
  
    close l_cur;
    return;
  end;

  overriding final member function get_clob_lines(a_output_id varchar2) return ut_clob_list
    pipelined is
    cursor l_cur is
      select column_value from table(self.get_clob_lines(a_output_id, 60 * 60 * 4));
    l_col_value clob;
  begin
    open l_cur;
  
    -- open-fetch-close routine is used to prevent optimization as we need row by row quering
    loop
      fetch l_cur
        into l_col_value;
      exit when l_cur%notfound;
      pipe row(l_col_value);
    end loop;
  
    close l_cur;
    return;
  end;

end;
/
