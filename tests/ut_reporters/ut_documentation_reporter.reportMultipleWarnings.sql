set termout off
create or replace package tst_documrep_mult_warn as
  --%suite

  --%test
  procedure test1;
end;
/

create or replace package body tst_documrep_mult_warn as
  procedure test1 is begin commit; end;
end;
/
create or replace package tst_documrep_mult_warn2 as
  --%suite

  --%test
  procedure test1;
end;
/

create or replace package body tst_documrep_mult_warn2 as
  procedure test1 is begin commit; end;
end;
/

set termout on

declare
  l_test_report ut_varchar2_list;
  l_output_data       ut_varchar2_list;
  l_output            varchar2(32767);
  l_expected          varchar2(32767);
begin
  l_expected := q'[%Warnings:
%1)%tst_documrep_mult_warn%
%2)%tst_documrep_mult_warn%]';

  --act
  select *
  bulk collect into l_output_data
  from table(ut.run(ut_varchar2_list('tst_documrep_mult_warn','tst_documrep_mult_warn2'),ut_documentation_reporter()));

  l_output := ut_utils.table_to_clob(l_output_data);

  --assert
  if l_output like l_expected then
    :test_result := ut_utils.tr_success;
  else
    dbms_output.put_line('Actual:"'||l_output||'"');
  end if;
end;
/

drop package tst_documrep_mult_warn;
drop package tst_documrep_mult_warn2;
