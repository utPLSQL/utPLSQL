PROMPT ut_output_dbms_pipe.close Times out after a given time and removes the pipe

def message_lenght = 12345
def pipe_name = 'test_pipe_name'

@@ut_output_dbms_pipe/common/ut_output_dbms_pipe.send_clob_no_close.sql '&&pipe_name' &&message_lenght

declare
  l_output_dbms_pipe ut_output_dbms_pipe := ut_output_dbms_pipe();
  l_expected_time integer := 1;
  l_time          date := sysdate;
  l_result_time   integer;
  l_pipe_removed  boolean;
  function pipe_exists(a_pipe_name varchar2) return boolean is
    l_pipes_count integer;
  begin
    select count(1) into l_pipes_count from v$db_pipes
     where name = a_pipe_name and type = 'PRIVATE';
    return (l_pipes_count  > 0 );
  end;
begin
  l_output_dbms_pipe.output_id := '&pipe_name';
  l_output_dbms_pipe.close(1);
  l_result_time := (sysdate - l_time) * 24 * 60 * 60;
  l_pipe_removed := not pipe_exists('&pipe_name');
  if l_result_time = l_expected_time and l_pipe_removed then
    :test_result := ut_utils.tr_success;
  elsif not l_pipe_removed then
    dbms_output.put_line('Pipe "&pipe_name" was not removed.');
  else
    dbms_output.put_line('Expected '||l_expected_time||' seconds, got '||l_result_time||' seconds');
  end if;
end;
/

undef pipe_name
