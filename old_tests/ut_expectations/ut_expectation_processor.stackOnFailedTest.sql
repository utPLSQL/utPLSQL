set termout off
create or replace package tst_stack_on_failed_test as
  --%suite

  --%test
  procedure test;
end;
/

create or replace package body tst_stack_on_failed_test as
  procedure test is begin ut.expect(1).to_equal(2); end;
end;
/

set termout on

declare
  l_test_report ut_varchar2_list;
  l_output_data       ut_varchar2_list;
  l_output            varchar2(32767);
  l_expected          varchar2(32767);
begin
  l_expected := q'[%Failures:%at "UT3.TST_STACK_ON_FAIL%", line 2%]';

  --act
  select *
  bulk collect into l_output_data
  from table(ut.run('tst_stack_on_failed_test',ut_documentation_reporter()));

  l_output := ut_utils.table_to_clob(l_output_data);

  --assert
  if l_output like l_expected then
    :test_result := ut_utils.gc_success;
  else
    dbms_output.put_line('Actual:"'||l_output||'"');
  end if;
end;
/

drop package tst_stack_on_failed_test;
