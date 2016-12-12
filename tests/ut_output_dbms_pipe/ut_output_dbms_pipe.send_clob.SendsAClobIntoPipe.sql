PROMPT ut_output_dbms_pipe.send_clob Sends a clob Into Pipe in a separate session and recieves it back cut into 4000 char pieces

def pipe_name = 'test_pipe_name'
def message_length = 98765

set define #
--try runnong on windows
$ start sqlplus %UT3_USER%/%UT3_USER_PASSWORD%@%ORACLE_SID% @ut_output_dbms_pipe/common/ut_output_dbms_pipe.send_clob.sql '##pipe_name' ##message_length
--try runnong on linus/unix
! sqlplus #ut3_runuser/#ut3_runpass@#_CONNECT_IDENTIFIER @ut_output_dbms_pipe/common/ut_output_dbms_pipe.send_clob.sql '##pipe_name' ##message_length &
set define &

declare
  l_output      ut_output_dbms_pipe := ut_output_dbms_pipe();
  l_text_length  integer;
  l_chunk_length integer;
  function pipe_exists(a_pipe_name varchar2) return boolean is
    l_pipes_count integer;
  begin
    select count(1) into l_pipes_count from v$db_pipes
     where name = a_pipe_name and type = 'PRIVATE';
    return (l_pipes_count  > 0 );
  end;
begin
  select sum(length(column_value)), max(length(column_value))
    into l_text_length, l_chunk_length
    from table( l_output.get_lines('&pipe_name') );
  --Assert - check that the length of text recieved is same as length of text sent
  if l_text_length = &&message_length and l_chunk_length = 4000 and not pipe_exists('&pipe_name') then
    :test_result := ut_utils.tr_success;
  elsif not pipe_exists('&pipe_name') then
    dbms_output.put_line('Pipe &pipe_name was not removed.');
  elsif not l_chunk_length = 4000 then
    dbms_output.put_line('Expected chunk length of 4000 but got'||l_chunk_length);
  else
    dbms_output.put_line('Expected '||&&message_length||' seconds and 0 rows, got '||l_text_length);
  end if;
end;
/

undef message_lenght
undef pipe_name
