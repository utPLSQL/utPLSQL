declare
  l_output_data       ut_varchar2_list;
  l_output            varchar2(32767);
  l_expected          varchar2(32767);
begin
  l_expected := q'[<testsuites tests="5" disabled="1" errors="1" failures="1" name="" time=".026823" >
<testsuite tests="5" id="1" package="org"  disabled="1" errors="1" failures="1" name="org" time=".026549" >
<testsuite tests="5" id="2" package="org.utplsql"  disabled="1" errors="1" failures="1" name="utplsql" time=".026335" >
<testsuite tests="5" id="3" package="org.utplsql.utplsql"  disabled="1" errors="1" failures="1" name="utplsql" time=".026109" >
<testsuite tests="5" id="4" package="org.utplsql.utplsql.test"  disabled="1" errors="1" failures="1" name="test" time=".025908" >
<testsuite tests="5" id="5" package="org.utplsql.utplsql.test.test_reporters"  disabled="1" errors="1" failures="1" name="A suite for testing different outcomes from reporters" time=".025575" >
<testsuite tests="1" id="6" package="org.utplsql.utplsql.test.test_reporters.test_reporters_1"  disabled="0" errors="0" failures="0" name="A suite for testing html coverage options" time=".003939" >
<testcase classname="org.utplsql.utplsql.test.test_reporters.test_reporters_1" assertions="1" name="a test calling package outside schema" time=".003485" >
<system-out/>
<system-err/>
</testcase>
<system-out/>
<system-err/>
</testsuite>
<testcase classname="org.utplsql.utplsql.test.test_reporters" assertions="1" name="passing_test" time=".006677" >
<system-out>
<![CDATA[
<!beforeeach!>
<!beforetest!>
<!passing test!>
<!aftertest!>
<!aftereach!>
]]>
</system-out>
<system-err/>
</testcase>
<testcase classname="org.utplsql.utplsql.test.test_reporters" assertions="1" name="a test with failing assertion" time=".00566"  status="Failure">
<failure>
<![CDATA[
"Fails as values are different"
Actual: 1 (number) was expected to equal: 2 (number) 
at "UT3.TEST_REPORTERS", line 36 ut.expect(1,'Fails as values are different').to_equal(2);
]]>
</failure>
<system-out>
<![CDATA[
<!beforeeach!>
<!failing test!>
<!aftereach!>
]]>
</system-out>
<system-err/>
</testcase>
<testcase classname="org.utplsql.utplsql.test.test_reporters" assertions="0" name="a test raising unhandled exception" time=".003977"  status="Error">
<error>
<![CDATA[
ORA-06502: PL/SQL: numeric or value error: character to number conversion error
ORA-06512: at "UT3.TEST_REPORTERS", line 44
ORA-06512: at line 6
]]>
</error>
<system-out>
<![CDATA[
<!beforeeach!>
<!erroring test!>
<!aftereach!>
]]>
</system-out>
<system-err/>
</testcase>
<testcase classname="org.utplsql.utplsql.test.test_reporters" assertions="0" name="a disabled test" time="0"  status="Disabled">
<skipped/>
<system-out/>
<system-err/>
</testcase>
<system-out>
<![CDATA[
<!beforeall!>
<!afterall!>
]]>
</system-out>
<system-err/>
</testsuite>
</testsuite>
</testsuite>
</testsuite>
</testsuite>
</testsuites>]';

  --act
  select *
  bulk collect into l_output_data
  from table(ut.run('test_reporters',ut_junit_reporter()));

  l_output := ut_utils.table_to_clob(l_output_data);

  --assert
  if l_output like l_expected then
    :test_result := ut_utils.gc_success;
  else
    dbms_output.put_line('Actual:"'||l_output||'"');
  end if;
end;
/
