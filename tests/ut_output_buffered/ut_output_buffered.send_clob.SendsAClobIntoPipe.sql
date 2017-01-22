PROMPT ut_output_buffered.send_clob Sends a clob Into Pipe in a separate session and recieves it back cut into 4000 char pieces

declare
  l_message_lenght integer := 98765;
  l_output      ut_output_buffered := ut_output_buffered();
  l_text_lenght  integer;
  l_chunk_lenght integer;
begin
  --Arrange - send clob to dbms_output
  declare
    l_expected_length  integer := l_message_lenght;
    l_max_varchar2_len integer := 32767;
    l_loops            integer := floor(l_expected_length / l_max_varchar2_len);
    l_string           varchar2(32767);
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
    l_output.send_clob(l_lob);
  end;


  --Act - get clob as lines from dbms_output
  select sum(nvl(length(column_value),0)), max(length(column_value))
    into l_text_lenght, l_chunk_lenght
    from table( l_output.get_lines(l_output.output_id) );
  --Assert - check that the length of text recieved is same as lenght of text sent
  if l_text_lenght = l_message_lenght and l_chunk_lenght = 4000 then
    :test_result := ut_utils.tr_success;
  elsif not nvl(l_chunk_lenght,0) = 4000 then
    dbms_output.put_line('Expected chunk length of 4000 but got'||l_chunk_lenght);
  else
    dbms_output.put_line('Expected '||l_message_lenght||' characters, got '||l_text_lenght);
  end if;
end;
/



