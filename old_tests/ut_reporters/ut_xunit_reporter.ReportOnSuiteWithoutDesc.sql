set termout off
create or replace package tst_package_xunit_nodesc as
  --%suite

  --%test(Test name)
  procedure test1;
end;
/

create or replace package body tst_package_xunit_nodesc as
  procedure test1 is begin ut.expect(1).to_equal(1); end;
  procedure test2 is begin ut.expect(1).to_equal(1); end;
end;
/

set termout on

declare
  l_test_report ut_varchar2_list;
  l_output_data       ut_varchar2_list;
  l_output            varchar2(32767);
  l_expected          varchar2(32767);
begin
  l_expected := q'[<testsuites tests="1" skipped="0" error="0" failure="0" name="" time="%" >
<testsuite tests="1" id="1" package="tst_package_xunit_nodesc"  skipped="0" error="0" failure="0" name="tst_package_xunit_nodesc" time="%" >
<testcase classname="tst_package_xunit_nodesc"  assertions="1" skipped="0" error="0" failure="0" name="Test name" time="%" >
</testcase>
</testsuite>
</testsuites>]';

  --act
  select *
  bulk collect into l_output_data
  from table(ut.run('tst_package_xunit_nodesc',ut_xunit_reporter()));

  l_output := ut_utils.table_to_clob(l_output_data);

  --assert
  if l_output like l_expected then
    :test_result := ut_utils.gc_success;
  else
    dbms_output.put_line('Actual:"'||l_output||'"');
  end if;
end;
/

drop package tst_package_xunit_nodesc;
