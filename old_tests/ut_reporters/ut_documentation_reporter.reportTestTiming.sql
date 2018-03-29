set termout off
create or replace package tst_doc_reporter_timing as
  --%suite

  --%test
  procedure test1;
  
  --%test
  procedure test2;
end;
/

create or replace package body tst_doc_reporter_timing as
  procedure test1 is begin ut.expect(1).to_equal(1); end;
  procedure test2 is begin ut.expect(1).to_equal(2); end;
end;
/

set termout on

declare
  l_test_report ut_varchar2_list;
  l_output_data       ut_varchar2_list;
  l_output            varchar2(32767);
  l_expected          varchar2(32767);
begin
  l_expected := q'[tst_doc_reporter_timing
%test1 [%sec]
%test2 [%sec] (FAILED - 1)
%Failures:%
Finished in % seconds
2 tests, 1 failed, 0 errored, 0 disabled, 0 warning(s)%]';

  --act
  select *
  bulk collect into l_output_data
  from table(ut.run('tst_doc_reporter_timing',ut_documentation_reporter()));

  l_output := ut_utils.table_to_clob(l_output_data);

  --assert
  if l_output like l_expected then
    :test_result := ut_utils.gc_success;
  else
    dbms_output.put_line('Actual:"'||l_output||'"');
  end if;
end;
/

drop package tst_doc_reporter_timing;
