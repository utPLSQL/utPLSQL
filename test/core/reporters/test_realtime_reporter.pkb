create or replace package body test_realtime_reporter as

  procedure create_test_suites is
    pragma autonomous_transaction;
  begin
    execute immediate q'[create or replace package ut3_tester.check_realtime_reporting1 is
      --%suite(suite <A>)
      --%suitepath(realtime_reporting)

      --%context(test context)

      --%test(test 1 - OK) 
      procedure test_1_ok;
      
      --%test(test 2 - NOK)
      procedure test_2_nok;

      --%endcontext
    end;]';
    execute immediate q'[create or replace package body ut3_tester.check_realtime_reporting1 is
      procedure test_1_ok is
      begin
        ut3.ut.expect(1).to_equal(1);
      end;

      procedure test_2_nok is
      begin
        ut3.ut.expect(1).to_equal(2);
      end;
    end;]';
    
    execute immediate q'[create or replace package ut3_tester.check_realtime_reporting2 is
      --%suite
      --%suitepath(realtime_reporting)

      --%test 
      procedure test_3_ok;
      
      --%test
      procedure test_4_nok;

      --%test
      --%disabled
      procedure test_5;
    end;]';
    execute immediate q'[create or replace package body ut3_tester.check_realtime_reporting2 is
      procedure test_3_ok is
      begin
        ut3.ut.expect(2).to_equal(2);
      end;

      procedure test_4_nok is
      begin
        ut3.ut.expect(2).to_equal(3);
      end;
      
      procedure test_5 is
      begin
        null;
      end;
    end;]';
    commit;
  end;

  procedure report_produces_expected_out is
    l_results   ut3.ut_varchar2_list;
    l_actual    clob;
    l_expected  varchar2(32767) := q'[<?xml version="1.0"?>%]';
  begin
    select *
      bulk collect into l_results
      from table(ut3.ut.run('ut3_tester:realtime_reporting', ut3.ut_realtime_reporter()));
    l_actual := ut3.ut_utils.table_to_clob(l_results);
    ut.expect(l_actual).to_be_like(l_expected);  
  end;

  procedure remove_test_suites is
    pragma autonomous_transaction;
  begin
    execute immediate 'drop package ut3_tester.check_realtime_reporting1';
    execute immediate 'drop package ut3_tester.check_realtime_reporting2';
  end;

end;
/
