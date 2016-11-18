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
  begin
    for i in (select column_value as text from table(ut_utils.clob_to_table(a_text)) ) loop
      dbms_output.put_line(i.text);
    end loop;
  end;

  overriding member procedure close(self in out nocopy ut_output_dbms_output) is
  begin
    null;
  end;

end;
/
