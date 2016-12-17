PROMPT calling ut_output_dbms_pipe.open creates a private pipe named as the output_id

declare
  l_output      ut_output_dbms_pipe := ut_output_dbms_pipe();

  function pipe_exists(a_pipe_name varchar2) return boolean is
    l_pipes_count integer;
  begin
    select count(1) into l_pipes_count from v$db_pipes
     where name = a_pipe_name and type = 'PRIVATE';
    return (l_pipes_count  > 0 );
  end;
begin
  --Arrange - check that pipe does not exist
  if not pipe_exists( l_output.output_id ) then
    --Act - open the pipe
    l_output.open();
    --Assert - check that pipe exists
    if pipe_exists( l_output.output_id ) then
      :test_result := ut_utils.tr_success;
    else
      dbms_output.put_line('Pipe '||l_output.output_id||' does not exist');
    end if;
  else
    dbms_output.put_line('Pipe '||l_output.output_id||' already exist exist');
  end if;
  ut_output_pipe_helper.remove_pipe( l_output.output_id );
end;
/
