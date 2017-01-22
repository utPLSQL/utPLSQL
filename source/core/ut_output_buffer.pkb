create or replace package body ut_output_buffer as

  type tt_outputs is table of clob index by varchar2(128);

  g_outputs tt_outputs;

  procedure add_line_to_buffer(a_output_id varchar2, a_text varchar2) is
  begin
    if a_text is not null then
      add_to_buffer(a_output_id, a_text||chr(10));
    end if;
  end;

  procedure add_to_buffer(a_output_id varchar2, a_text clob) is
    l_clob clob;
  begin
    if a_text is not null and dbms_lob.getlength(a_text)>0 then
      if not g_outputs.exists(a_output_id) then
        dbms_lob.createtemporary(l_clob, true);
        g_outputs(a_output_id) := l_clob;
      end if;
      dbms_lob.append(g_outputs(a_output_id), a_text);
    end if;
  end;

  procedure add_to_buffer(a_output_id varchar2, a_text varchar2) is
    l_clob clob;
  begin
    if a_text is not null then
      if not g_outputs.exists(a_output_id) then
        dbms_lob.createtemporary(l_clob, true);
        g_outputs(a_output_id) := l_clob;
      end if;
      dbms_lob.writeappend(g_outputs(a_output_id), length(a_text), a_text);
    end if;
  end;

  function get_buffer(a_output_id varchar2) return ut_varchar2_list is
    l_output_lines ut_varchar2_list := ut_varchar2_list();
  begin
    if g_outputs.exists(a_output_id) then
      l_output_lines := ut_utils.clob_to_table(g_outputs(a_output_id));
      dbms_lob.freetemporary(g_outputs(a_output_id));
      g_outputs.delete(a_output_id);
    end if;
    return l_output_lines;
  end;

  procedure flush_buffer(a_output_id varchar2) is
    l_lines_list ut_varchar2_list;
  begin
    l_lines_list := get_buffer(a_output_id);
    for i in 1 .. l_lines_list.count loop
      dbms_output.put_line(l_lines_list(i));
    end loop;
  end;

  procedure purge is
  begin
    g_outputs.delete;
  end;

end;
/
