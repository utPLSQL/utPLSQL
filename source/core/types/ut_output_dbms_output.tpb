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

  overriding member procedure send(self in out nocopy ut_output_dbms_output, a_text clob) is
    l_text_part varchar2(32767 byte);
    --we're assuming max of 2 bytes per char
    c_size_limit_chars constant integer := (32767/2);
    i integer := 0;
  begin
    while i < length(a_text) loop
      l_text_part := substr( a_text, i + 1, c_size_limit_chars );
      dbms_output.put_line(l_text_part);
      i := i + c_size_limit_chars;
    end loop;
  end;

  overriding member procedure close(self in out nocopy ut_output_dbms_output) is
  begin
    null;
  end;

end;
/
