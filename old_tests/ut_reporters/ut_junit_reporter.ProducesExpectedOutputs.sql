declare
  l_output_data       ut_varchar2_list;
  l_output            varchar2(32767);
  l_expected          varchar2(32767);
begin
  l_expected := q'[<testsuites tests="5" disabled="1" errors="1" failures="1" name="" time="%" >
<testsuite tests="5" id="1" package="org"  disabled="1" errors="1" failures="1" name="org" time="%" >
<testsuite tests="5" id="2" package="org.utplsql"  disabled="1" errors="1" failures="1" name="utplsql" time="%" >
<testsuite tests="5" id="3" package="org.utplsql.utplsql"  disabled="1" errors="1" failures="1" name="utplsql" time="%" >
<testsuite tests="5" id="4" package="org.utplsql.utplsql.test"  disabled="1" errors="1" failures="1" name="test" time="%" >
<testsuite tests="5" id="5" package="org.utplsql.utplsql.test.test_reporters"  disabled="1" errors="1" failures="1" name="A suite for testing different outcomes from reporters" time="%" >
%
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
