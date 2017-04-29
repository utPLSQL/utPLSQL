declare
  l_output_data       ut_varchar2_list;
  l_output            varchar2(32767);
  l_expected          varchar2(32767);
begin
  l_expected := q'[<testsuites tests="4" skipped="1" error="1" failure="1" name="%" time="%" >
<testsuite tests="4" id="1" package="test_reporters"  skipped="1" error="1" failure="1" name="%" time="%" >
<system-out>%<!beforeall!>%<!afterall!>%</system-out>
<testcase classname="test_reporters"  assertions="1" skipped="0" error="0" failure="0" name="%" time="%" >
<system-out>%<!beforeeach!>%<!beforetest!>%<!passing test!>%<!aftertest!>%<!aftereach!>%</system-out>
</testcase>
<testcase classname="test_reporters"  assertions="1" skipped="0" error="0" failure="1" name="%" time="%"  status="Failure">
<failure>%"Fails as values are different"
Actual: 1 (number) was expected to equal: 2 (number)%</failure>
<system-out>%</system-out>
</testcase>
<testcase classname="test_reporters"  assertions="0" skipped="0" error="1" failure="0" name="%" time="%"  status="Error">
<error>%ORA-06502:%</error>
<system-out>%</system-out>
</testcase>
<testcase classname="test_reporters"  assertions="0" skipped="1" error="0" failure="0" name="%" time="0"  status="Disabled">
<skipped/>
</testcase>
</testsuite>
</testsuites>]';

  --act
  select *
  bulk collect into l_output_data
  from table(ut.run('test_reporters',ut_xunit_reporter()));

  l_output := ut_utils.table_to_clob(l_output_data);

  --assert
  if l_output like l_expected then
    :test_result := ut_utils.tr_success;
  else
    dbms_output.put_line('Actual:"'||l_output||'"');
  end if;
end;
/
