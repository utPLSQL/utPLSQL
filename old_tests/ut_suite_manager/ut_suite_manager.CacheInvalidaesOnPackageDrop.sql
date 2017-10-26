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
  l_test_report ut_varchar2_list;
begin
  begin
    select * bulk collect into l_test_report from table(ut.run(user || '.tst_package_to_be_dropped'));
  exception
    when others then
      if sqlerrm like '%tst_package_to_be_dropped%not found%' then
        :test_result := ut_utils.tr_success;
      end if;
  end;
  if :test_result != ut_utils.tr_success or :test_result is null then
    dbms_output.put_line('Failed: Expected exception with text like ''%tst_package_to_be_dropped%not found%'' but got:''' ||
                         sqlerrm || '''');
  end if;
end;
/
