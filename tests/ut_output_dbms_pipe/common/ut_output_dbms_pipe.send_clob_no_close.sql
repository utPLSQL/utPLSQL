declare
  l_expected_length  integer := &2;
  l_max_varchar2_len integer := 32767;
  l_loops            integer := floor(l_expected_length / l_max_varchar2_len);
  l_string           varchar2(32767);
  l_output_dbms_pipe ut_output_dbms_pipe := ut_output_dbms_pipe();
  l_lob clob;
begin
  dbms_lob.createtemporary(l_lob, true);
  for i in 1 .. l_loops loop
    l_string := lpad('a', l_max_varchar2_len, 'a');
    dbms_lob.writeappend( l_lob, length(l_string), l_string );
  end loop;
  if l_loops*l_max_varchar2_len < l_expected_length then
    l_string := lpad('a', mod(l_expected_length, l_max_varchar2_len), 'a');
    dbms_lob.writeappend( l_lob, length(l_string), l_string );
  end if;
  l_output_dbms_pipe.output_id := '&1';
  l_output_dbms_pipe.open;
  l_output_dbms_pipe.send_clob(l_lob);
end;
/
