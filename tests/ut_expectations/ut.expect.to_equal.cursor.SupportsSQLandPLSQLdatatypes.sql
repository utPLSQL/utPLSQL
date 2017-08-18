set termout off
create or replace package ut_equal_sys_refcursor_tests is
  --%suite(ut_equal on sys_refcursor data)
  --%suitepath(org.utplsql.test.expectations.equal.refcursor)

  --%beforeall
  procedure prepare_table;

  --%afterall
  procedure cleanup_table;

  --%test(compare cursor on table to cursor on plsql data)
  procedure compare;

end;
/

create or replace package body ut_equal_sys_refcursor_tests is

  gc_blob      blob := to_blob('123');
  gc_clob      clob := to_clob('abc');
  gc_date      date := sysdate;
  gc_ds_int    interval day(9) to second(9) := numtodsinterval(1.12345678912, 'day');
  gc_num       number := 123456789.1234567890123456789;
  gc_ts        timestamp(9) := to_timestamp_tz('2017-03-30 00:21:12.123456789 cet','yyyy-mm-dd hh24:mi:ss.ff9 tzr');
  gc_ts_tz     timestamp(9) with time zone := to_timestamp_tz('2017-03-30 00:21:12.123456789 cet','yyyy-mm-dd hh24:mi:ss.ff9 tzr');
  gc_ts_ltz    timestamp(9) with local time zone := to_timestamp_tz('2017-03-30 00:21:12.123456789 cet','yyyy-mm-dd hh24:mi:ss.ff9 tzr');
  gc_varchar   varchar2(4000) := 'a varchar2';
  gc_ym_int    interval year(9) to month := numtoyminterval(1.1, 'year');

  procedure prepare_table is
    pragma autonomous_transaction;
  begin
    execute immediate
    'create table test_table_for_cursors (
    some_blob          blob,
    some_clob          clob,
    some_date          date,
    some_ds_interval   interval day(9) to second(9),
    some_nummber       number,
    some_timestamp     timestamp(9),
    some_timestamp_tz  timestamp(9) with time zone,
    some_timestamp_ltz timestamp(9) with local time zone,
    some_varchar2      varchar2(4000),
    some_ym_interval   interval year(9) to month
    )';
    execute immediate q'[
     insert into test_table_for_cursors
     values( :gc_blob, :gc_clob, :gc_date, :gc_ds_int, :gc_num, :gc_ts, :gc_ts_tz, :gc_ts_ltz, :gc_varchar, :gc_ym_int
     )
    ]' using gc_blob, gc_clob, gc_date, gc_ds_int, gc_num, gc_ts, gc_ts_tz, gc_ts_ltz, gc_varchar, gc_ym_int;
    commit;
  end;


  --%afterall
  procedure cleanup_table is
    pragma autonomous_transaction;
  begin
    execute immediate 'drop table test_table_for_cursors';
  end;

  --%test(compare cursor on table to cursor on plsql data)
  procedure compare is
    l_expected  sys_refcursor;
    l_actual    sys_refcursor;
  begin
    open l_expected for
      select  gc_blob some_blob,
              gc_clob some_clob,
              gc_date some_date,
              gc_ds_int some_ds_interval,
              gc_num some_nummber,
              gc_ts some_timestamp,
              gc_ts_tz some_timestamp_tz,
              gc_ts_ltz some_timestamp_ltz ,
              gc_varchar some_varchar2,
              gc_ym_int some_ym_interval
        from dual;

    open l_actual for q'[select * from test_table_for_cursors]';

    ut.expect(l_expected).to_equal(l_actual);
  end;

end;
/
set termout on
declare
  l_result_reporter ut_output_reporter_base := ut_documentation_reporter();
  l_status_reporter ut_output_reporter_base := utplsql_test_reporter();
begin
  ut_runner.run(':org.utplsql.test', ut_reporters(l_result_reporter, l_status_reporter));
  select * into :test_result from table(l_status_reporter.get_lines());
  if :test_result != ut_utils.tr_success then
    l_result_reporter.lines_to_dbms_output();
  end if;
end;
/

set termout off
drop package ut_equal_sys_refcursor_tests;
set termout on
