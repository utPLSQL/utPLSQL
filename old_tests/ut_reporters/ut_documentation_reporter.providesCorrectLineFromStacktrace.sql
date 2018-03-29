declare
  l_output_data       ut_varchar2_list;
  l_output            varchar2(32767);
  l_expected          varchar2(32767);
begin
  l_expected := q'[%
%Failures:%
%1)%failing_test%
%"Fails as values are different"%
%Actual: 1 (number) was expected to equal: 2 (number)%
%at "%.TEST_REPORTERS%", line%
%2)%erroring_test%
%ORA-06502%
%ORA-06512%
Finished %
5 tests, 1 failed, 1 errored%]';

  --act
  select *
  bulk collect into l_output_data
  from table(ut.run('test_reporters',ut_documentation_reporter()));

  l_output := ut_utils.table_to_clob(l_output_data);

  --assert
  if l_output like l_expected then
    :test_result := ut_utils.gc_success;
  else
    dbms_output.put_line('Actual:"'||l_output||'"');
  end if;
end;
/
