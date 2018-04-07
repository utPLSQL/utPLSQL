declare
  l_output_data       ut_varchar2_list;
  l_output            varchar2(32767);
  l_expected          varchar2(32767);
begin
  l_expected := q'[<testExecutions version="1">
<file path="tests/helpers/test_reporters_1.pkb">
<testCase name="diffrentowner_test" duration="%" >%</testCase>
</file>
<file path="tests/helpers/test_reporters.pkb">
<testCase name="passing_test" duration="%" >%</testCase>
<testCase name="failing_test" duration="%" >%<failure message="some expectations have failed">%</failure>%</testCase>
<testCase name="erroring_test" duration="%" >%<error message="encountered errors">%</error>%</testCase>
<testCase name="disabled_test" duration="0" >%<skipped message="skipped"/>%</testCase>
</file>
</testExecutions>]';

  --act
  select *
  bulk collect into l_output_data
  from table(ut.run('test_reporters',ut_sonar_test_reporter(),a_source_files=> null, a_test_files=>ut_varchar2_list('tests/helpers/test_reporters.pkb', 'tests/helpers/test_reporters_1.pkb')));

  l_output := ut_utils.table_to_clob(l_output_data);

  --assert
  if l_output like l_expected then
    :test_result := ut_utils.gc_success;
  else
    dbms_output.put_line('Actual:"'||l_output||'"');
  end if;
end;
/
