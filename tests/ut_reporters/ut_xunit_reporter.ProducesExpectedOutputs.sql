declare
  l_output_data       ut_varchar2_list;
  l_output            varchar2(32767);
  l_expected          varchar2(32767);
begin
  l_expected := q'[<testsuites tests="5" skipped="1" error="1" failure="1" name="%" time="%" >
<testsuite tests="5" id="1" package="org"  skipped="1" error="1" failure="1" name="org" time="%" >
<testsuite tests="5" id="2" package="org.utplsql"  skipped="1" error="1" failure="1" name="utplsql" time="%" >
<testsuite tests="5" id="3" package="org.utplsql.utplsql"  skipped="1" error="1" failure="1" name="utplsql" time="%" >
<testsuite tests="5" id="4" package="org.utplsql.utplsql.test"  skipped="1" error="1" failure="1" name="test" time="%" >
<testsuite tests="5" id="5" package="org.utplsql.utplsql.test.test_reporters"  skipped="1" error="1" failure="1" name="%" time="%" >
<system-out>%<!beforeall!>%<!afterall!>%</system-out>
<testcase classname="org.utplsql.utplsql.test.test_reporters"  assertions="1" skipped="0" error="0" failure="0" name="%" time="%" >
<system-out>%<!beforeeach!>%<!beforetest!>%<!passing test!>%<!aftertest!>%<!aftereach!>%</system-out>
</testcase>
<testcase classname="org.utplsql.utplsql.test.test_reporters"  assertions="1" skipped="0" error="0" failure="1" name="%" time="%"  status="Failure">
<failure>%"Fails as values are different"
Actual: 1 (number) was expected to equal: 2 (number)%</failure>
<system-out>%</system-out>
</testcase>
<testcase classname="org.utplsql.utplsql.test.test_reporters"  assertions="0" skipped="0" error="1" failure="0" name="%" time="%"  status="Error">
<error>%ORA-06502:%</error>
<system-out>%</system-out>
</testcase>
<testcase classname="org.utplsql.utplsql.test.test_reporters"  assertions="0" skipped="1" error="0" failure="0" name="%" time="0"  status="Disabled">
<skipped/>
</testcase>
<testsuite tests="1" id="6" package="org.utplsql.utplsql.test.test_reporters.test_reporters_1"  skipped="0" error="0" failure="0" name="%" time="%" >
<testcase classname="org.utplsql.utplsql.test.test_reporters.test_reporters_1"  assertions="1" skipped="0" error="0" failure="0" name="%" time="%" >
</testcase>
</testsuite>
</testsuite>
</testsuite>
</testsuite>
</testsuite>
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
