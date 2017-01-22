create or replace type body ut_output_buffered as

  constructor function ut_output_buffered(self in out nocopy ut_output_buffered) return self as result is
  begin
    self.self_type := $$plsql_unit;
    self.output_id := self.generate_output_id();
    return;
  end;

  overriding member procedure open(self in out nocopy ut_output_buffered) is
  begin
    null;
  end;

  overriding member procedure send_line(self in out nocopy ut_output_buffered, a_text varchar2) is
  begin
    ut_output_buffer.add_line_to_buffer(self.output_id, a_text);
  end;

  overriding member procedure send_clob(self in out nocopy ut_output_buffered, a_text clob) is
  begin
    ut_output_buffer.add_to_buffer(self.output_id, a_text);
  end;

  overriding member procedure close(self in out nocopy ut_output_buffered) is
  begin
    ut_output_buffer.flush_buffer(self.output_id);
  end;

  overriding final member function get_lines(a_output_id varchar2) return ut_varchar2_list pipelined is
    c_max_line_length constant integer := 4000;
    l_buffer_data     ut_varchar2_list;
    l_results_tab     ut_varchar2_list;
  begin
    l_buffer_data := ut_output_buffer.get_buffer(a_output_id);
    for i in 1 .. l_buffer_data.count loop
      l_results_tab := ut_utils.clob_to_table(l_buffer_data(i), c_max_line_length);
      --pipe results one by one
      for i in 1 .. l_results_tab.count loop
        if l_results_tab(i) is not null then
          pipe row( l_results_tab(i) );
        end if;
      end loop;
    end loop;
    return;
  end;

  overriding final member function get_clob_lines(a_output_id varchar2) return ut_clob_list pipelined is
    l_buffer_data     ut_varchar2_list;
  begin
    l_buffer_data := ut_output_buffer.get_buffer(a_output_id);
    for i in 1 .. l_buffer_data.count loop
      if l_buffer_data(i) is not null then
        pipe row(l_buffer_data(i));
      end if;
    end loop;
    return;
  end;

end;
/
