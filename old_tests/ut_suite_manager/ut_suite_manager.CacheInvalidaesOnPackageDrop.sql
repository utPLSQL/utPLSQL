set termout off
create or replace package tst_package_to_be_dropped as
  --%suite

  --%test
  procedure test1;
end;
/

create or replace package body tst_package_to_be_dropped as
  procedure test1 is begin ut.expect(1).to_equal(1); end;
  procedure test2 is begin ut.expect(1).to_equal(1); end;
end;
/

set termout on

declare
  l_test_report ut_varchar2_list;
begin
  select * bulk collect into l_test_report from table(ut.run(USER||'.tst_package_to_be_dropped'));
end;
/

set termout off
drop package tst_package_to_be_dropped
/
set termout on

declare
  l_test_report   ut_varchar2_list;
  l_error_message varchar2(4000);
  l_expected      varchar2(4000);
begin
  l_expected := '%tst_package_to_be_dropped%does not exist%';
  begin
    select * bulk collect into l_test_report from table(ut.run(user || '.tst_package_to_be_dropped'));
  exception
    when others then
      l_error_message := sqlerrm;
      if l_error_message like l_expected then
        :test_result := ut_utils.gc_success;
      end if;
  end;
  if :test_result != ut_utils.gc_success or :test_result is null then
    dbms_output.put_line('Failed: Expected exception with text like '''||l_expected||''' but got:''' ||
                           l_error_message || '''');
  end if;
end;
/
