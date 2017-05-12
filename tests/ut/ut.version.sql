declare
  l_expected varchar2(100) := 'utPLSQL - Version %.%.%';
begin
--Assert
  if ut.version() like l_expected  then
    :test_result := ut_utils.tr_success;
  else
    dbms_output.put_line('expected version like '''||l_expected ||''' got: '''||ut.version()||'''' );
  end if;
end;
/
