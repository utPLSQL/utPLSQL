set termout off
create or replace package ut_output_test_rollback as
  --%suite

  --%beforeall
  procedure ba;
  --%beforeeach
  procedure be;
  --%test
  procedure test;
  --%test
  --%rollback(manual)
  procedure t_manual;
  --%afterall
  procedure aa;
  --%aftereach
  procedure ae;
end;
/

create or replace package body ut_output_test_rollback as
 procedure ba is begin commit; end;
 procedure be is begin commit; end;
 procedure test is begin null; end;
 procedure t_manual is begin commit; end;
 procedure aa is begin commit; end;
 procedure ae is begin commit; end;
end;
/

set termout on

declare
  l_test_report ut_varchar2_list;
  l_output_data       ut_varchar2_list;
  l_output            varchar2(32767);
  l_expected          varchar2(32767);
begin
  l_expected := q'[%
  1) ut_output_test_rollback.test
      Unable to perform automatic rollback after test. An implicit or explicit commit/rollback occurred in procedures:
        ut3.ut_output_test_rollback.be
        ut3.ut_output_test_rollback.ae
      Use the "--%rollback(manual)" annotation or remove commit/rollback/ddl statements that are causing the issue.
%
  2) ut_output_test_rollback
      Unable to perform automatic rollback after test suite. An implicit or explicit commit/rollback occurred in procedures:
        ut3.ut_output_test_rollback.ba
        ut3.ut_output_test_rollback.aa
        ut3.ut_output_test_rollback.be
        ut3.ut_output_test_rollback.ae
        ut3.ut_output_test_rollback.t_manual
      Use the "--%rollback(manual)" annotation or remove commit/rollback/ddl statements that are causing the issue.
%
Finished in % seconds
2 tests, 0 failed, 0 errored, 0 disabled, 2 warning(s)%]';

  --act
  select *
  bulk collect into l_output_data
  from table(ut.run(ut_varchar2_list('ut_output_test_rollback'),ut_documentation_reporter()));

  l_output := ut_utils.table_to_clob(l_output_data);

  --assert
  if l_output like l_expected then
    :test_result := ut_utils.gc_success;
  else
    dbms_output.put_line('Actual:"'||l_output||'"');
    dbms_output.put_line('Expected:"'||l_expected||'"');
  end if;
end;
/

drop package ut_output_test_rollback;
