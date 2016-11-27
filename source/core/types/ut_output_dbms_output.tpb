create or replace type body ut_output_dbms_output as

  constructor function ut_output_dbms_output(self in out nocopy ut_output_dbms_output) return self as result is
  begin
    self.output_type := $$plsql_unit;
    self.output_id := self.generate_output_id();
    return;
  end;

  overriding member procedure open(self in out nocopy ut_output_dbms_output) is
  begin
    null;
  end;

  overriding member procedure send_line(self in out nocopy ut_output_dbms_output, a_text varchar2) is
  begin
    dbms_output.put_line(a_text);
  end;

  overriding member procedure send_clob(self in out nocopy ut_output_dbms_output, a_text clob) is
    l_buffer ut_varchar2_list;
  begin
    l_buffer := ut_utils.clob_to_table(a_text);
    for i in 1 .. l_buffer.count loop
      dbms_output.put_line(l_buffer(i));
    end loop;
  end;

  overriding member procedure close(self in out nocopy ut_output_dbms_output) is
  begin
    null;
  end;

  overriding final member function get_lines(a_output_id varchar2) return ut_varchar2_list pipelined is
    l_buffer          varchar2(32767);
    l_status          integer;
    c_max_line_length constant integer := 4000;
    l_results_tab     ut_varchar2_list;
  begin
    loop
      dbms_output.get_line (l_buffer, l_status);
      exit when l_status != 0;
      l_results_tab := ut_utils.clob_to_table(l_buffer, c_max_line_length);
      --pipe results one by one
      for i in 1 .. l_results_tab.count loop
        pipe row( l_results_tab(i) );
      end loop;
    end loop;
    return;
  end;

  overriding final member function get_clob_lines(a_output_id varchar2) return ut_clob_list pipelined is
    l_buffer varchar2(32767);
    l_status integer;
  begin
    loop
      dbms_output.get_line (l_buffer, l_status);
      exit when l_status != 0;
      pipe row(l_buffer);
    end loop;
    return;
  end;

end;
/
