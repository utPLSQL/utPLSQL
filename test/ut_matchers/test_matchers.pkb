create or replace package body test_matchers is

  procedure restore_asserts(a_assert_results ut3.ut_expectation_results) is
  begin
    ut3.ut_expectation_processor.clear_expectations;

    if a_assert_results is not null then
      for i in 1 .. a_assert_results.count loop
        ut3.ut_expectation_processor.add_expectation_result(a_assert_results(i));
      end loop;
    end if;
  end;

  procedure transfer_results is
    l_assert_results ut3.ut_expectation_results;
    l_new_result ut3_latest_release.ut_expectation_result;
  begin
    l_assert_results := ut3.ut_expectation_processor.get_failed_expectations;
    for i in 1..l_assert_results.count loop
      l_new_result := ut3_latest_release.ut_expectation_result(l_assert_results(i).status,
                                                               l_assert_results(i).description,
                                                               l_assert_results(i).message);
      l_new_result.caller_info := l_assert_results(i).caller_info;
      ut3_latest_release.ut_expectation_processor.add_expectation_result(l_new_result);
    end loop;
  end;

  procedure exec_matcher(a_type varchar2, a_actual_value varchar2, a_expected_value varchar2, a_matcher varchar2, a_result integer, a_prefix varchar2 default null) is
    l_assert_results ut3.ut_expectation_results;
    l_result         integer;
    l_statement      varchar2(32767);
  begin
    l_assert_results := ut3.ut_expectation_processor.get_failed_expectations;
    l_statement := 'declare
  l_value1 '||a_type||' := '||a_actual_value||';
  l_value2 '||a_type||' := '||a_expected_value||';
begin ut3.ut.expect(l_value1).'||a_prefix||'to_'||a_matcher||'(l_value2); end;';
    execute immediate l_statement;
    l_result := ut3.ut_expectation_processor.get_status();
    restore_asserts(l_assert_results);
    ut.expect(l_result, 'exec_'||a_matcher||':'||chr(10)||l_statement).to_equal(a_result);
  end exec_matcher;

  procedure exec_be_between(a_type varchar2, a_actual_value varchar2, a_expected1_value varchar2, a_expected2_value varchar2,a_result integer) is
    l_assert_results ut3.ut_expectation_results;
    l_result         integer;
    l_statement      varchar2(32767);
  begin
    l_assert_results := ut3.ut_expectation_processor.get_failed_expectations;
    l_statement := 'declare
  l_actual_value '||a_type||' := '||a_actual_value||';
  l_value1 '||a_type||' := '||a_expected1_value||';
  l_value2 '||a_type||' := '||a_expected2_value||';
begin ut3.ut.expect(l_actual_value).to_be_between(l_value1, l_value2); end;';
    execute immediate l_statement;
    l_result := ut3.ut_expectation_processor.get_status();
    restore_asserts(l_assert_results);
    ut.expect(l_result, 'exec_be_between:'||chr(10)||l_statement).to_equal(a_result);
  end exec_be_between;

  procedure exec_be_less_than(a_type varchar2, a_actual_value varchar2, a_expected_value varchar2, a_result integer, a_prefix varchar2 default null)
    is
  begin
    exec_matcher(a_type, a_actual_value, a_expected_value, 'be_less_than',a_result, a_prefix);
  end;

  procedure exec_be_less_or_equal(a_type varchar2, a_actual_value varchar2, a_expected_value varchar2, a_result integer, a_prefix varchar2 default null)
    is
  begin
    exec_matcher(a_type, a_actual_value, a_expected_value, 'be_less_or_equal',a_result, a_prefix);
  end;

  procedure exec_be_greater_than(a_type varchar2, a_actual_value varchar2, a_expected_value varchar2, a_result integer, a_prefix varchar2 default null)
    is
  begin
    exec_matcher(a_type, a_actual_value, a_expected_value, 'be_greater_than',a_result, a_prefix);
  end;

  procedure exec_be_greater_or_equal(a_type varchar2, a_actual_value varchar2, a_expected_value varchar2, a_result integer, a_prefix varchar2 default null)
    is
  begin
    exec_matcher(a_type, a_actual_value, a_expected_value, 'be_greater_or_equal',a_result, a_prefix);
  end;

  procedure exec_be_between2(a_type varchar2, a_actual_value varchar2, a_expected1_value varchar2, a_expected2_value varchar2,a_result integer, a_not_prefix varchar2 default null) is
    l_assert_results ut3.ut_expectation_results;
    l_result         integer;
    l_statement      varchar2(32767);
  begin
    l_assert_results := ut3.ut_expectation_processor.get_failed_expectations;
    l_statement := 'declare
  l_actual_value '||a_type||' := '||a_actual_value||';
  l_value1 '||a_type||' := '||a_expected1_value||';
  l_value2 '||a_type||' := '||a_expected2_value||';
begin ut3.ut.expect(l_actual_value).'||a_not_prefix||'to_be_between(l_value1, l_value2); end;';
    execute immediate l_statement;
    l_result := ut3.ut_expectation_processor.get_status();
    restore_asserts(l_assert_results);
    ut.expect(l_result, 'exec_be_between2:'||chr(10)||l_statement).to_equal(a_result);
  end exec_be_between2;

  procedure exec_match(a_type varchar2, a_actual_value varchar2, a_pattern varchar2, a_modifiers varchar2, a_result integer, a_not_prefix varchar2 default null) is
    l_statement      varchar2(32767);
    l_assert_results ut3.ut_expectation_results;
    l_result         integer;
  begin
    l_assert_results := ut3.ut_expectation_processor.get_failed_expectations;
    l_statement := 'declare
  l_actual    '||a_type||' := '||a_actual_value||';
  l_pattern   varchar2(32767) := :a_pattern;
  l_modifiers varchar2(32767) := :a_modifiers;
  l_result    integer;
begin ut3.ut.expect( l_actual ).'||a_not_prefix||'to_match(l_pattern, l_modifiers); end;';
    execute immediate l_statement using a_pattern, a_modifiers;
    l_result := ut3.ut_expectation_processor.get_status();
    restore_asserts(l_assert_results);
    ut.expect(l_result, 'exec_match:'||chr(10)||l_statement).to_equal(a_result);
  end;

  procedure test_be_less_than is
  begin

    exec_be_less_than('date', 'sysdate', 'sysdate-1', ut3.ut_utils.tr_failure, '');
    exec_be_less_than('number', '2.0', '1.99', ut3.ut_utils.tr_failure, '');
    exec_be_less_than('interval year to month', '''2-1''', '''2-0''', ut3.ut_utils.tr_failure, '');
    exec_be_less_than('interval day to second', '''2 01:00:00''', '''2 00:59:59''', ut3.ut_utils.tr_failure, '');
    exec_be_less_than('timestamp', 'to_timestamp(''1997 13'',''YYYY FF'')', 'to_timestamp(''1997 12'',''YYYY FF'')', ut3.ut_utils.tr_failure, '');
    exec_be_less_than('timestamp with time zone', 'to_timestamp_tz(''1997 12 +01:00'',''YYYY FF TZR'')', 'to_timestamp_tz(''1997 12 +02:00'',''YYYY FF TZR'')', ut3.ut_utils.tr_failure, '');
    exec_be_less_than('timestamp with local time zone', 'to_timestamp_tz(''1997 12 +01:00'',''YYYY FF TZR'')', 'to_timestamp_tz(''1997 12 +02:00'',''YYYY FF TZR'')', ut3.ut_utils.tr_failure, '');

    exec_be_less_than('date', 'sysdate-1', 'sysdate', ut3.ut_utils.tr_success, '');
    exec_be_less_than('number', '1.0', '1.01', ut3.ut_utils.tr_success, '');
    exec_be_less_than('interval year to month', '''2-1''', '''2-2''', ut3.ut_utils.tr_success, '');
    exec_be_less_than('interval day to second', '''2 00:59:58''', '''2 00:59:59''', ut3.ut_utils.tr_success, '');
    exec_be_less_than('timestamp', 'to_timestamp(''1997 12'',''YYYY FF'')', 'to_timestamp(''1997 13'',''YYYY FF'')', ut3.ut_utils.tr_success, '');
    exec_be_less_than('timestamp with time zone', 'to_timestamp_tz(''1997 12 +03:00'',''YYYY FF TZR'')', 'to_timestamp_tz(''1997 12 +02:00'',''YYYY FF TZR'')', ut3.ut_utils.tr_success, '');
    exec_be_less_than('timestamp with local time zone', 'to_timestamp_tz(''1997 12 +03:00'',''YYYY FF TZR'')', 'to_timestamp_tz(''1997 12 +02:00'',''YYYY FF TZR'')', ut3.ut_utils.tr_success, '');

    exec_be_less_than('date', 'sysdate', 'sysdate-1', ut3.ut_utils.tr_success, 'not_');
    exec_be_less_than('number', '2.0', '1.99', ut3.ut_utils.tr_success, 'not_');
    exec_be_less_than('interval year to month', '''2-1''', '''2-0''', ut3.ut_utils.tr_success, 'not_');
    exec_be_less_than('interval day to second', '''2 01:00:00''', '''2 00:59:59''', ut3.ut_utils.tr_success, 'not_');
    exec_be_less_than('timestamp', 'to_timestamp(''1997 13'',''YYYY FF'')', 'to_timestamp(''1997 12'',''YYYY FF'')', ut3.ut_utils.tr_success, 'not_');
    exec_be_less_than('timestamp with time zone', 'to_timestamp_tz(''1997 12 +01:00'',''YYYY FF TZR'')', 'to_timestamp_tz(''1997 12 +02:00'',''YYYY FF TZR'')', ut3.ut_utils.tr_success, 'not_');
    exec_be_less_than('timestamp with local time zone', 'to_timestamp_tz(''1997 12 +01:00'',''YYYY FF TZR'')', 'to_timestamp_tz(''1997 12 +02:00'',''YYYY FF TZR'')', ut3.ut_utils.tr_success, 'not_');

  end;

  procedure test_be_greater_or_equal is
  begin
    exec_be_greater_or_equal('date', 'sysdate', 'sysdate-1', ut3.ut_utils.tr_success);
    exec_be_greater_or_equal('number', '2.0', '1.99', ut3.ut_utils.tr_success);
    exec_be_greater_or_equal('interval year to month', '''2-1''', '''2-0''', ut3.ut_utils.tr_success);
    exec_be_greater_or_equal('interval day to second', '''2 01:00:00''', '''2 00:59:59''', ut3.ut_utils.tr_success);
    exec_be_greater_or_equal('timestamp', 'to_timestamp(''1997-01 09:26:50.13'',''YYYY-MM HH24.MI.SS.FF'')', 'to_timestamp(''1997-01 09:26:50.12'',''YYYY-MM HH24.MI.SS.FF'')', ut3.ut_utils.tr_success);
    exec_be_greater_or_equal('timestamp with time zone', 'to_timestamp_tz(''1997 +01:00'',''YYYY TZR'')', 'to_timestamp_tz(''1997 +02:00'',''YYYY TZR'')', ut3.ut_utils.tr_success);
    exec_be_greater_or_equal('timestamp with local time zone', 'to_timestamp_tz(''1997 +01:00'',''YYYY TZR'')', 'to_timestamp_tz(''1997 +02:00'',''YYYY TZR'')', ut3.ut_utils.tr_success);

    exec_be_greater_or_equal('date', 'sysdate', 'sysdate', ut3.ut_utils.tr_success);
    exec_be_greater_or_equal('number', '1.99', '1.99', ut3.ut_utils.tr_success);
    exec_be_greater_or_equal('interval year to month', '''2-0''', '''2-0''', ut3.ut_utils.tr_success);
    exec_be_greater_or_equal('INTERVAL DAY TO SECOND', '''2 00:59:01''', '''2 00:59:01''', ut3.ut_utils.tr_success);
    exec_be_greater_or_equal('timestamp', 'to_timestamp(''1997 09:26:50.12'',''YYYY HH24.MI.SS.FF'')', 'to_timestamp(''1997 09:26:50.12'',''YYYY HH24.MI.SS.FF'')', ut3.ut_utils.tr_success, '');
    exec_be_greater_or_equal('timestamp with time zone', 'to_timestamp_tz(''1997 +01:00'',''YYYY TZR'')', 'to_timestamp_tz(''1997 +01:00'',''YYYY TZR'')', ut3.ut_utils.tr_success, '');
    exec_be_greater_or_equal('timestamp with local time zone', 'to_timestamp_tz(''1997 +01:00'',''YYYY TZR'')', 'to_timestamp_tz(''1997 +01:00'',''YYYY TZR'')', ut3.ut_utils.tr_success, '');

    exec_be_greater_or_equal('date', 'sysdate-1', 'sysdate', ut3.ut_utils.tr_failure, '');
    exec_be_greater_or_equal('number', '1.0', '1.01', ut3.ut_utils.tr_failure, '');
    exec_be_greater_or_equal('interval year to month', '''2-1''', '''2-2''', ut3.ut_utils.tr_failure, '');
    exec_be_greater_or_equal('interval day to second', '''2 00:59:58''', '''2 00:59:59''', ut3.ut_utils.tr_failure, '');
    exec_be_greater_or_equal('timestamp', 'to_timestamp(''1997 09:26:50.12'',''YYYY HH24.MI.SS.FF'')', 'to_timestamp(''1997 09:26:50.13'',''YYYY HH24.MI.SS.FF'')', ut3.ut_utils.tr_failure, '');
    exec_be_greater_or_equal('timestamp with time zone', 'to_timestamp_tz(''1997 +03:00'',''YYYY TZR'')', 'to_timestamp_tz(''1997 +02:00'',''YYYY TZR'')', ut3.ut_utils.tr_failure, '');
    exec_be_greater_or_equal('timestamp with local time zone', 'to_timestamp_tz(''1997 +03:00'',''YYYY TZR'')', 'to_timestamp_tz(''1997 +02:00'',''YYYY TZR'')', ut3.ut_utils.tr_failure, '');

    exec_be_greater_or_equal('date', 'sysdate-2', 'sysdate-1', ut3.ut_utils.tr_success, 'not_');
    exec_be_greater_or_equal('number', '1.0', '1.99', ut3.ut_utils.tr_success, 'not_');
    exec_be_greater_or_equal('interval year to month', '''1-1''', '''2-0''', ut3.ut_utils.tr_success, 'not_');
    exec_be_greater_or_equal('interval day to second', '''1 01:00:00''', '''2 00:59:59''', ut3.ut_utils.tr_success, 'not_');
    exec_be_greater_or_equal('timestamp', 'to_timestamp(''1997-01 09:26:50.11'',''YYYY-MM HH24.MI.SS.FF'')', 'to_timestamp(''1997-01 09:26:50.12'',''YYYY-MM HH24.MI.SS.FF'')', ut3.ut_utils.tr_success, 'not_');
    exec_be_greater_or_equal('timestamp with time zone', 'to_timestamp_tz(''1997 +03:00'',''YYYY TZR'')', 'to_timestamp_tz(''1997 +02:00'',''YYYY TZR'')', ut3.ut_utils.tr_success, 'not_');
    exec_be_greater_or_equal('timestamp with local time zone', 'to_timestamp_tz(''1997 +03:00'',''YYYY TZR'')', 'to_timestamp_tz(''1997 +02:00'',''YYYY TZR'')', ut3.ut_utils.tr_success, 'not_');

  end;

  procedure test_be_greater_than is
  begin

    exec_be_greater_than('date', 'sysdate', 'sysdate-1', ut3.ut_utils.tr_success, '');
    exec_be_greater_than('number', '2.0', '1.99', ut3.ut_utils.tr_success, '');
    exec_be_greater_than('interval year to month', '''2-1''', '''2-0''', ut3.ut_utils.tr_success, '');
    exec_be_greater_than('interval day to second', '''2 01:00:00''', '''2 00:59:59''', ut3.ut_utils.tr_success, '');
    exec_be_greater_than('timestamp', 'to_timestamp(''1997 13'',''YYYY FF'')', 'to_timestamp(''1997 12'',''YYYY FF'')', ut3.ut_utils.tr_success, '');
    exec_be_greater_than('timestamp with time zone', 'to_timestamp_tz(''1997 +01:00'',''YYYY TZR'')', 'to_timestamp_tz(''1997 +02:00'',''YYYY TZR'')', ut3.ut_utils.tr_success, '');
    exec_be_greater_than('timestamp with local time zone', 'to_timestamp_tz(''1997 +01:00'',''YYYY TZR'')', 'to_timestamp_tz(''1997 +02:00'',''YYYY TZR'')', ut3.ut_utils.tr_success, '');

    exec_be_greater_than('date', 'sysdate', 'sysdate', ut3.ut_utils.tr_failure, '');
    exec_be_greater_than('number', '1.0', '1.0', ut3.ut_utils.tr_failure, '');
    exec_be_greater_than('interval year to month', '''2-1''', '''2-1''', ut3.ut_utils.tr_failure, '');
    exec_be_greater_than('interval day to second', '''2 00:59:58''', '''2 00:59:58''', ut3.ut_utils.tr_failure, '');
    exec_be_greater_than('timestamp', 'to_timestamp(''1997 12'',''YYYY FF'')', 'to_timestamp(''1997 12'',''YYYY FF'')', ut3.ut_utils.tr_failure, '');
    exec_be_greater_than('timestamp with time zone', 'to_timestamp_tz(''1997 +02:00'',''YYYY TZR'')', 'to_timestamp_tz(''1997+02:00'',''YYYY TZR'')', ut3.ut_utils.tr_failure, '');
    exec_be_greater_than('timestamp with local time zone', 'to_timestamp_tz(''1997 +03:00'',''YYYY TZR'')', 'to_timestamp_tz(''1997 +03:00'',''YYYY TZR'')', ut3.ut_utils.tr_failure, '');

    exec_be_greater_than('date', 'sysdate-1', 'sysdate-1', ut3.ut_utils.tr_success, 'not_');
    exec_be_greater_than('number', '1', '1.99', ut3.ut_utils.tr_success, 'not_');
    exec_be_greater_than('interval year to month', '''1-1''', '''2-0''', ut3.ut_utils.tr_success, 'not_');
    exec_be_greater_than('interval day to second', '''2 01:00:00''', '''2 01:00:00''', ut3.ut_utils.tr_success, 'not_');
    exec_be_greater_than('timestamp', 'to_timestamp(''1997 13'',''YYYY FF'')', 'to_timestamp(''1997 13'',''YYYY FF'')', ut3.ut_utils.tr_success, 'not_');
    exec_be_greater_than('timestamp with time zone', 'to_timestamp_tz(''1997 +01:00'',''YYYY TZR'')', 'to_timestamp_tz(''1997 +01:00'',''YYYY TZR'')', ut3.ut_utils.tr_success, 'not_');
    exec_be_greater_than('timestamp with local time zone', 'to_timestamp_tz(''1997 +01:00'',''YYYY TZR'')', 'to_timestamp_tz(''1997 +01:00'',''YYYY TZR'')', ut3.ut_utils.tr_success, 'not_');

  end;

  procedure test_be_less_or_equal is
  begin

    exec_be_less_or_equal('date', 'sysdate', 'sysdate-1', ut3.ut_utils.tr_failure, '');
    exec_be_less_or_equal('number', '2.0', '1.99', ut3.ut_utils.tr_failure, '');
    exec_be_less_or_equal('interval year to month', '''2-1''', '''2-0''', ut3.ut_utils.tr_failure, '');
    exec_be_less_or_equal('interval day to second', '''2 01:00:00''', '''2 00:59:59''', ut3.ut_utils.tr_failure, '');
    exec_be_less_or_equal('timestamp', 'to_timestamp(''1997 13'',''YYYY FF'')', 'to_timestamp(''1997 12'',''YYYY FF'')', ut3.ut_utils.tr_failure, '');
    exec_be_less_or_equal('timestamp with time zone', 'to_timestamp_tz(''1997 +01:00'',''YYYY TZR'')', 'to_timestamp_tz(''1997 +02:00'',''YYYY TZR'')', ut3.ut_utils.tr_failure, '');
    exec_be_less_or_equal('timestamp with local time zone', 'to_timestamp_tz(''1997 +01:00'',''YYYY TZR'')', 'to_timestamp_tz(''1997 +02:00'',''YYYY TZR'')', ut3.ut_utils.tr_failure, '');

    exec_be_less_or_equal('date', 'sysdate', 'sysdate', ut3.ut_utils.tr_success, '');
    exec_be_less_or_equal('number', '1.99', '1.99', ut3.ut_utils.tr_success, '');
    exec_be_less_or_equal('interval year to month', '''2-0''', '''2-0''', ut3.ut_utils.tr_success, '');
    exec_be_less_or_equal('interval day to second', '''2 00:59:01''', '''2 00:59:01''', ut3.ut_utils.tr_success, '');
    exec_be_less_or_equal('timestamp', 'to_timestamp(''1997 12'',''YYYY FF'')', 'to_timestamp(''1997 12'',''YYYY FF'')', ut3.ut_utils.tr_success, '');
    exec_be_less_or_equal('timestamp with time zone', 'to_timestamp_tz(''1997 +01:00'',''YYYY TZR'')', 'to_timestamp_tz(''1997 +01:00'',''YYYY TZR'')', ut3.ut_utils.tr_success, '');
    exec_be_less_or_equal('timestamp with local time zone', 'to_timestamp_tz(''1997 +01:00'',''YYYY TZR'')', 'to_timestamp_tz(''1997 +01:00'',''YYYY TZR'')', ut3.ut_utils.tr_success, '');

    exec_be_less_or_equal('date', 'sysdate-1', 'sysdate', ut3.ut_utils.tr_success, '');
    exec_be_less_or_equal('number', '1.0', '1.01', ut3.ut_utils.tr_success, '');
    exec_be_less_or_equal('interval year to month', '''2-1''', '''2-2''', ut3.ut_utils.tr_success, '');
    exec_be_less_or_equal('interval day to second', '''2 00:59:58''', '''2 00:59:59''', ut3.ut_utils.tr_success, '');
    exec_be_less_or_equal('timestamp', 'to_timestamp(''1997 12'',''YYYY FF'')', 'to_timestamp(''1997 13'',''YYYY FF'')', ut3.ut_utils.tr_success, '');
    exec_be_less_or_equal('timestamp with time zone', 'to_timestamp_tz(''1997 +03:00'',''YYYY TZR'')', 'to_timestamp_tz(''1997 +02:00'',''YYYY TZR'')', ut3.ut_utils.tr_success, '');
    exec_be_less_or_equal('timestamp with local time zone', 'to_timestamp_tz(''1997 +03:00'',''YYYY TZR'')', 'to_timestamp_tz(''1997 +02:00'',''YYYY TZR'')', ut3.ut_utils.tr_success, '');

    exec_be_less_or_equal('date', 'sysdate', 'sysdate-1', ut3.ut_utils.tr_success, 'not_');
    exec_be_less_or_equal('number', '2.0', '1.99', ut3.ut_utils.tr_success, 'not_');
    exec_be_less_or_equal('interval year to month', '''2-1''', '''2-0''', ut3.ut_utils.tr_success, 'not_');
    exec_be_less_or_equal('interval day to second', '''2 01:00:00''', '''2 00:59:59''', ut3.ut_utils.tr_success, 'not_');
    exec_be_less_or_equal('timestamp', 'to_timestamp(''1997 13'',''YYYY FF'')', 'to_timestamp(''1997 12'',''YYYY FF'')', ut3.ut_utils.tr_success, 'not_');
    exec_be_less_or_equal('timestamp with time zone', 'to_timestamp_tz(''1997 +01:00'',''YYYY TZR'')', 'to_timestamp_tz(''1997 +02:00'',''YYYY TZR'')', ut3.ut_utils.tr_success, 'not_');
    exec_be_less_or_equal('timestamp with local time zone', 'to_timestamp_tz(''1997 +01:00'',''YYYY TZR'')', 'to_timestamp_tz(''1997 +02:00'',''YYYY TZR'')', ut3.ut_utils.tr_success, 'not_');

  end;

  procedure test_be_between is
  begin

    exec_be_between('date', 'sysdate', 'sysdate-2', 'sysdate-1', ut3.ut_utils.tr_failure);
    exec_be_between('number', '2.0', '1.99', '1.999', ut3.ut_utils.tr_failure);
    exec_be_between('varchar2(1)', '''c''', '''a''', '''b''', ut3.ut_utils.tr_failure);
    exec_be_between('interval year to month', '''2-2''', '''2-0''', '''2-1''', ut3.ut_utils.tr_failure);
    exec_be_between('interval day to second', '''2 01:00:00''', '''2 00:59:58''', '''2 00:59:59''', ut3.ut_utils.tr_failure);
    exec_be_between('timestamp', 'to_timestamp(''1997-01-31 09:26:50.13'',''YYYY-MM-DD HH24.MI.SS.FF'')', 'to_timestamp(''1997-01-31 09:26:50.11'',''YYYY-MM-DD HH24.MI.SS.FF'')', 'to_timestamp(''1997-01-31 09:26:50.12'',''YYYY-MM-DD HH24.MI.SS.FF'')', ut3.ut_utils.tr_failure);
    exec_be_between('timestamp with local time zone', 'to_timestamp_tz(''1997-01-31 09:26:50.12 +01:00'',''YYYY-MM-DD HH24.MI.SS.FF TZR'')', 'to_timestamp_tz(''1997-01-31 09:26:50.12 +02:00'',''YYYY-MM-DD HH24.MI.SS.FF TZR'')', 'to_timestamp_tz(''1997-01-31 09:26:50.12 +03:00'',''YYYY-MM-DD HH24.MI.SS.FF TZR'')', ut3.ut_utils.tr_failure);
    exec_be_between('timestamp with time zone', 'to_timestamp_tz(''1997-01-31 09:26:50.12 +01:00'',''YYYY-MM-DD HH24.MI.SS.FF TZR'')', 'to_timestamp_tz(''1997-01-31 09:26:50.12 +02:00'',''YYYY-MM-DD HH24.MI.SS.FF TZR'')', 'to_timestamp_tz(''1997-01-31 09:26:50.12 +03:00'',''YYYY-MM-DD HH24.MI.SS.FF TZR'')', ut3.ut_utils.tr_failure);

    exec_be_between('date', 'sysdate', 'sysdate-1', 'sysdate+1', ut3.ut_utils.tr_success);
    exec_be_between('number', '2.0', '1.99', '2.01', ut3.ut_utils.tr_success);
    exec_be_between('varchar2(1)', '''b''', '''a''', '''c''', ut3.ut_utils.tr_success);
    exec_be_between('interval year to month', '''2-1''', '''2-0''', '''2-2''', ut3.ut_utils.tr_success);
    exec_be_between('interval day to second', '''2 01:00:00''', '''2 00:59:58''', '''2 01:00:01''', ut3.ut_utils.tr_success);
    exec_be_between('timestamp', 'to_timestamp(''1997-01-31 09:26:50.13'',''YYYY-MM-DD HH24.MI.SS.FF'')', 'to_timestamp(''1997-01-31 09:26:50.11'',''YYYY-MM-DD HH24.MI.SS.FF'')', 'to_timestamp(''1997-01-31 09:26:50.14'',''YYYY-MM-DD HH24.MI.SS.FF'')', ut3.ut_utils.tr_success);
    exec_be_between('timestamp with local time zone', 'to_timestamp_tz(''1997-01-31 09:26:50.12 +02:00'',''YYYY-MM-DD HH24.MI.SS.FF TZR'')', 'to_timestamp_tz(''1997-01-31 09:26:50.12 +03:00'',''YYYY-MM-DD HH24.MI.SS.FF TZR'')', 'to_timestamp_tz(''1997-01-31 09:26:50.12 +01:00'',''YYYY-MM-DD HH24.MI.SS.FF TZR'')', ut3.ut_utils.tr_success);
    exec_be_between('timestamp with time zone', 'to_timestamp_tz(''1997-01-31 09:26:50.12 +02:00'',''YYYY-MM-DD HH24.MI.SS.FF TZR'')', 'to_timestamp_tz(''1997-01-31 09:26:50.12 +03:00'',''YYYY-MM-DD HH24.MI.SS.FF TZR'')', 'to_timestamp_tz(''1997-01-31 09:26:50.12 +01:00'',''YYYY-MM-DD HH24.MI.SS.FF TZR'')', ut3.ut_utils.tr_success);
  end;

  procedure test_be_between2 is
  begin

    --failure when value out of range
    exec_be_between2('date', 'sysdate', 'sysdate-2', 'sysdate-1', ut3.ut_utils.tr_failure, '');
    exec_be_between2('number', '2.0', '1.99', '1.999', ut3.ut_utils.tr_failure, '');
    exec_be_between2('varchar2(1)', '''c''', '''a''', '''b''', ut3.ut_utils.tr_failure, '');
    exec_be_between2('timestamp', 'systimestamp+1', 'systimestamp-1', 'systimestamp', ut3.ut_utils.tr_failure, '');
    exec_be_between2('timestamp with local time zone', 'systimestamp+1', 'systimestamp-1', 'systimestamp', ut3.ut_utils.tr_failure, '');
    exec_be_between2('timestamp with time zone', 'systimestamp+1', 'systimestamp-1', 'systimestamp', ut3.ut_utils.tr_failure, '');
    exec_be_between2('interval year to month', '''2-2''', '''2-0''', '''2-1''', ut3.ut_utils.tr_failure, '');
    exec_be_between2('interval day to second', '''2 01:00:00''', '''2 00:59:58''', '''2 00:59:59''', ut3.ut_utils.tr_failure, '');

    --success when value in range
    exec_be_between2('date', 'sysdate', 'sysdate-1', 'sysdate+1', ut3.ut_utils.tr_success, '');
    exec_be_between2('number', '2.0', '1.99', '2.01', ut3.ut_utils.tr_success, '');
    exec_be_between2('varchar2(1)', '''b''', '''a''', '''c''', ut3.ut_utils.tr_success, '');
    exec_be_between2('timestamp', 'systimestamp', 'systimestamp-1', 'systimestamp+1', ut3.ut_utils.tr_success, '');
    exec_be_between2('timestamp with local time zone', 'systimestamp', 'systimestamp-1', 'systimestamp+1', ut3.ut_utils.tr_success, '');
    exec_be_between2('timestamp with time zone', 'systimestamp', 'systimestamp-1', 'systimestamp+1', ut3.ut_utils.tr_success, '');
    exec_be_between2('interval year to month', '''2-1''', '''2-0''', '''2-2''', ut3.ut_utils.tr_success, '');
    exec_be_between2('interval day to second', '''2 01:00:00''', '''2 00:59:58''', '''2 01:00:01''', ut3.ut_utils.tr_success, '');

    --success when value not in range
    exec_be_between2('date', 'sysdate', 'sysdate-2', 'sysdate-1', ut3.ut_utils.tr_success, 'not_');
    exec_be_between2('number', '2.0', '1.99', '1.999', ut3.ut_utils.tr_success, 'not_');
    exec_be_between2('varchar2(1)', '''c''', '''a''', '''b''', ut3.ut_utils.tr_success, 'not_');
    exec_be_between2('timestamp', 'systimestamp+1', 'systimestamp-1', 'systimestamp', ut3.ut_utils.tr_success, 'not_');
    exec_be_between2('timestamp with local time zone', 'systimestamp+1', 'systimestamp-1', 'systimestamp', ut3.ut_utils.tr_success, 'not_');
    exec_be_between2('timestamp with time zone', 'systimestamp+1', 'systimestamp-1', 'systimestamp', ut3.ut_utils.tr_success, 'not_');
    exec_be_between2('interval year to month', '''2-2''', '''2-0''', '''2-1''', ut3.ut_utils.tr_success, 'not_');
    exec_be_between2('interval day to second', '''2 01:00:00''', '''2 00:59:58''', '''2 00:59:59''', ut3.ut_utils.tr_success, 'not_');

    --failure when value not out of range
    exec_be_between2('date', 'sysdate', 'sysdate-1', 'sysdate+1', ut3.ut_utils.tr_failure, 'not_');
    exec_be_between2('number', '2.0', '1.99', '2.01', ut3.ut_utils.tr_failure, 'not_');
    exec_be_between2('varchar2(1)', '''b''', '''a''', '''c''', ut3.ut_utils.tr_failure, 'not_');
    exec_be_between2('timestamp', 'systimestamp', 'systimestamp-1', 'systimestamp+1', ut3.ut_utils.tr_failure, 'not_');
    exec_be_between2('timestamp with local time zone', 'systimestamp', 'systimestamp-1', 'systimestamp+1', ut3.ut_utils.tr_failure, 'not_');
    exec_be_between2('timestamp with time zone', 'systimestamp', 'systimestamp-1', 'systimestamp+1', ut3.ut_utils.tr_failure, 'not_');
    exec_be_between2('interval year to month', '''2-1''', '''2-0''', '''2-2''', ut3.ut_utils.tr_failure, 'not_');
    exec_be_between2('interval day to second', '''2 01:00:00''', '''2 00:59:58''', '''2 01:00:01''', ut3.ut_utils.tr_failure, 'not_');

    --failure when value is null
    exec_be_between2('date', 'null', 'sysdate-1', 'sysdate+1', ut3.ut_utils.tr_failure, '');
    exec_be_between2('number', 'null', '1.99', '2.01', ut3.ut_utils.tr_failure, '');
    exec_be_between2('varchar2(1)', 'null', '''a''', '''c''', ut3.ut_utils.tr_failure, '');
    exec_be_between2('timestamp', 'null', 'systimestamp-1', 'systimestamp+1', ut3.ut_utils.tr_failure, '');
    exec_be_between2('timestamp with local time zone', 'null', 'systimestamp-1', 'systimestamp+1', ut3.ut_utils.tr_failure, '');
    exec_be_between2('timestamp with time zone', 'null', 'systimestamp-1', 'systimestamp+1', ut3.ut_utils.tr_failure, '');
    exec_be_between2('interval year to month', 'null', '''2-0''', '''2-2''', ut3.ut_utils.tr_failure, '');
    exec_be_between2('interval day to second', 'null', '''2 00:59:58''', '''2 01:00:01''', ut3.ut_utils.tr_failure, '');
    exec_be_between2('date', 'null', 'sysdate-2', 'sysdate-1', ut3.ut_utils.tr_failure, 'not_');
    exec_be_between2('number', 'null', '1.99', '1.999', ut3.ut_utils.tr_failure, 'not_');
    exec_be_between2('varchar2(1)', 'null', '''a''', '''b''', ut3.ut_utils.tr_failure, 'not_');
    exec_be_between2('timestamp', 'null', 'systimestamp-1', 'systimestamp', ut3.ut_utils.tr_failure, 'not_');
    exec_be_between2('timestamp with local time zone', 'null', 'systimestamp-1', 'systimestamp', ut3.ut_utils.tr_failure, 'not_');
    exec_be_between2('timestamp with time zone', 'null', 'systimestamp-1', 'systimestamp', ut3.ut_utils.tr_failure, 'not_');
    exec_be_between2('interval year to month', 'null', '''2-0''', '''2-1''', ut3.ut_utils.tr_failure, 'not_');
    exec_be_between2('interval day to second', 'null', '''2 00:59:58''', '''2 00:59:59''', ut3.ut_utils.tr_failure, 'not_');

    --failure when lower bound is null
    exec_be_between2('date', 'sysdate', 'null', 'sysdate+1', ut3.ut_utils.tr_failure, '');
    exec_be_between2('number', '2.0', 'null', '2.01', ut3.ut_utils.tr_failure, '');
    exec_be_between2('varchar2(1)', '''b''', 'null', '''c''', ut3.ut_utils.tr_failure, '');
    exec_be_between2('timestamp', 'systimestamp', 'null', 'systimestamp+1', ut3.ut_utils.tr_failure, '');
    exec_be_between2('timestamp with local time zone', 'systimestamp', 'null', 'systimestamp+1', ut3.ut_utils.tr_failure, '');
    exec_be_between2('timestamp with time zone', 'systimestamp', 'null', 'systimestamp+1', ut3.ut_utils.tr_failure, '');
    exec_be_between2('interval year to month', '''2-1''', 'null', '''2-2''', ut3.ut_utils.tr_failure, '');
    exec_be_between2('interval day to second', '''2 01:00:00''', 'null', '''2 01:00:01''', ut3.ut_utils.tr_failure, '');
    exec_be_between2('date', 'sysdate', 'null', 'sysdate-1', ut3.ut_utils.tr_failure, 'not_');
    exec_be_between2('number', '2.0', 'null', '1.999', ut3.ut_utils.tr_failure, 'not_');
    exec_be_between2('varchar2(1)', '''b''', 'null', '''b''', ut3.ut_utils.tr_failure, 'not_');
    exec_be_between2('timestamp', 'systimestamp+1', 'null', 'systimestamp', ut3.ut_utils.tr_failure, 'not_');
    exec_be_between2('timestamp with local time zone', 'systimestamp+1', 'null', 'systimestamp', ut3.ut_utils.tr_failure, 'not_');
    exec_be_between2('timestamp with time zone', 'systimestamp+1', 'null', 'systimestamp', ut3.ut_utils.tr_failure, 'not_');
    exec_be_between2('interval year to month', '''2-2''', 'null', '''2-1''', ut3.ut_utils.tr_failure, 'not_');
    exec_be_between2('interval day to second', '''2 01:00:00''', 'null', '''2 00:59:59''', ut3.ut_utils.tr_failure, 'not_');
  end;

  procedure test_match is
  begin
    exec_match('varchar2(100)', '''Stephen''', '^Ste(v|ph)en$', '', ut3.ut_utils.tr_success, '');
    exec_match('varchar2(100)', '''sTEPHEN''', '^Ste(v|ph)en$', 'i', ut3.ut_utils.tr_success, '');
    exec_match('clob', 'rpad('', '',32767)||''Stephen''', 'Ste(v|ph)en$', '', ut3.ut_utils.tr_success, '');
    exec_match('clob', 'rpad('', '',32767)||''sTEPHEN''', 'Ste(v|ph)en$', 'i', ut3.ut_utils.tr_success, '');

    exec_match('varchar2(100)', '''Stephen''', '^Steven$', '', ut3.ut_utils.tr_failure, '');
    exec_match('varchar2(100)', '''sTEPHEN''', '^Steven$', 'i', ut3.ut_utils.tr_failure, '');
    exec_match('clob', 'to_clob(rpad('', '',32767)||''Stephen'')', '^Stephen', '', ut3.ut_utils.tr_failure, '');
    exec_match('clob', 'to_clob(rpad('', '',32767)||''sTEPHEN'')', '^Stephen', 'i', ut3.ut_utils.tr_failure, '');

    exec_match('varchar2(100)', '''Stephen''', '^Ste(v|ph)en$', '', ut3.ut_utils.tr_failure, 'not_');
    exec_match('varchar2(100)', '''sTEPHEN''', '^Ste(v|ph)en$', 'i', ut3.ut_utils.tr_failure, 'not_');
    exec_match('clob', 'rpad('', '',32767)||''Stephen''', 'Ste(v|ph)en$', '', ut3.ut_utils.tr_failure, 'not_');
    exec_match('clob', 'rpad('', '',32767)||''sTEPHEN''', 'Ste(v|ph)en$', 'i', ut3.ut_utils.tr_failure, 'not_');

    exec_match('varchar2(100)', '''Stephen''', '^Steven$', '', ut3.ut_utils.tr_success, 'not_');
    exec_match('varchar2(100)', '''sTEPHEN''', '^Steven$', 'i', ut3.ut_utils.tr_success, 'not_');
    exec_match('clob', 'to_clob(rpad('', '',32767)||''Stephen'')', '^Stephen', '', ut3.ut_utils.tr_success, 'not_');
    exec_match('clob', 'to_clob(rpad('', '',32767)||''sTEPHEN'')', '^Stephen', 'i', ut3.ut_utils.tr_success, 'not_');
  end;

  procedure test_be_empty_cursor is
    l_cursor sys_refcursor;
    l_result         integer;
    l_assert_results ut3.ut_expectation_results;
  begin
    open l_cursor for select * from dual where 1 = 2;
    ut3.ut.expect(l_cursor).to_be_empty;

    transfer_results;

    l_assert_results := ut3.ut_expectation_processor.get_failed_expectations;
    open l_cursor for select * from dual where 1 = 1;
    ut3.ut.expect(l_cursor).to_be_empty;

    l_result := ut3.ut_expectation_processor.get_status;
    restore_asserts(l_assert_results);

    ut.expect(l_result,'Expect cursor to be not empty').to_equal(ut3.ut_utils.tr_failure);
  end;

  procedure test_be_nonempty_cursor is
    l_cursor sys_refcursor;
    l_result         integer;
    l_assert_results ut3.ut_expectation_results;
  begin
    open l_cursor for select * from dual where 1 = 1;
    ut3.ut.expect(l_cursor).not_to_be_empty;

    transfer_results;

    l_assert_results := ut3.ut_expectation_processor.get_failed_expectations;
    open l_cursor for select * from dual where 1 = 2;
    ut3.ut.expect(l_cursor).not_to_be_empty;

    l_result := ut3.ut_expectation_processor.get_status;
    restore_asserts(l_assert_results);

    ut.expect(l_result,'Expect cursor to be empty').to_equal(ut3.ut_utils.tr_failure);
  end;

  procedure test_be_empty_collection is
    l_result         integer;
    l_assert_results ut3.ut_expectation_results;
  begin
    ut3.ut.expect(anydata.convertcollection(ora_mining_varchar2_nt())).to_be_empty;

    transfer_results;

    l_assert_results := ut3.ut_expectation_processor.get_failed_expectations;

    ut3.ut.expect(anydata.convertcollection(ora_mining_varchar2_nt('a'))).to_be_empty;
    l_result := ut3.ut_expectation_processor.get_status;
    restore_asserts(l_assert_results);

    ut.expect(l_result,'Expect collection to be not empty').to_equal(ut3.ut_utils.tr_failure);
  end;

  procedure test_be_nonempty_collection is
    l_result         integer;
    l_assert_results ut3.ut_expectation_results;
  begin
    ut3.ut.expect(anydata.convertcollection(ora_mining_varchar2_nt('a'))).not_to_be_empty;

    transfer_results;

    l_assert_results := ut3.ut_expectation_processor.get_failed_expectations;

    ut3.ut.expect(anydata.convertcollection(ora_mining_varchar2_nt())).not_to_be_empty;
    l_result := ut3.ut_expectation_processor.get_status;
    restore_asserts(l_assert_results);

    ut.expect(l_result,'Expect collection to be empty').to_equal(ut3.ut_utils.tr_failure);
  end;

  procedure test_be_empty_others is
    l_var1 ut3.ut_data_value_number;
    l_var2 ut3.ut_data_value_number;
    l_assert_results ut3.ut_expectation_results;
    l_new_result ut3_latest_release.ut_expectation_result;
  begin
    l_var1 := ut3.ut_data_value_number(1);
    ut3.ut.expect(anydata.ConvertObject(l_var1)).not_to_be_empty;
    ut3.ut.expect(anydata.ConvertObject(l_var2)).to_be_empty;

    transfer_results;
  end;

  procedure test_be_like is
    procedure exec_be_like(a_type varchar2, a_value varchar2, a_pattern varchar2, a_escape varchar2, a_result integer, a_prefix varchar2) is
      l_result integer;
      l_assert_results ut3.ut_expectation_results;
    begin
      l_assert_results := ut3.ut_expectation_processor.get_failed_expectations;
      execute immediate 'declare
      l_actual    ' || a_type || ' := '||a_value||';
      l_pattern   varchar2(32767) := :pattern;
      l_escape_char varchar2(32767) := :a_escape;
      l_result    integer;
    begin ut3.ut.expect( l_actual ).' || a_prefix ||
                        q'[to_be_like(l_pattern, l_escape_char);
      :l_result := ut3.ut_expectation_processor.get_status(); end;]'
        using a_pattern, a_escape, out l_result;
      restore_asserts(l_assert_results);
      ut.expect(l_result
               ,'expected: ''' || a_value || ''', to be like ''' || a_pattern || ''' escape ''' || a_escape || '''').to_equal(a_result);

    end;
  begin
    exec_be_like('varchar2(100)', '''Stephen_King''', 'Ste__en%', '', ut3.ut_utils.tr_success, '');
    exec_be_like('varchar2(100)', '''Stephen_King''', 'Ste__en\_K%', '\', ut3.ut_utils.tr_success, '');
    exec_be_like('clob', 'rpad(''a'',32767,''a'')||''Stephen_King''', 'a%Ste__en%', '', ut3.ut_utils.tr_success, '');
    exec_be_like('clob', 'rpad(''a'',32767,''a'')||''Stephen_King''', 'a%Ste__en\_K%', '\', ut3.ut_utils.tr_success, '');

    exec_be_like('varchar2(100)', '''Stephen_King''', 'Ste_en%', '', ut3.ut_utils.tr_failure, '');
    exec_be_like('varchar2(100)', '''Stephen_King''', 'Stephe\__%', '\', ut3.ut_utils.tr_failure, '');
    exec_be_like('clob', 'rpad(''a'',32767,''a'')||''Stephen_King''', 'a%Ste_en%', '', ut3.ut_utils.tr_failure, '');
    exec_be_like('clob', 'rpad(''a'',32767,''a'')||''Stephen_King''', 'a%Stephe\__%', '\', ut3.ut_utils.tr_failure, '');

    exec_be_like('varchar2(100)', '''Stephen_King''', 'Ste__en%', '', ut3.ut_utils.tr_failure, 'not_');
    exec_be_like('varchar2(100)', '''Stephen_King''', 'Ste__en\_K%', '\', ut3.ut_utils.tr_failure, 'not_');
    exec_be_like('clob', 'rpad(''a'',32767,''a'')||''Stephen_King''', 'a%Ste__en%', '', ut3.ut_utils.tr_failure, 'not_');
    exec_be_like('clob', 'rpad(''a'',32767,''a'')||''Stephen_King''', 'a%Ste__en\_K%', '\', ut3.ut_utils.tr_failure, 'not_');

    exec_be_like('varchar2(100)', '''Stephen_King''', 'Ste_en%', '', ut3.ut_utils.tr_success, 'not_');
    exec_be_like('varchar2(100)', '''Stephen_King''', 'Stephe\__%', '\', ut3.ut_utils.tr_success, 'not_');
    exec_be_like('clob', 'rpad(''a'',32767,''a'')||''Stephen_King''', 'a%Ste_en%', '', ut3.ut_utils.tr_success, 'not_');
    exec_be_like('clob', 'rpad(''a'',32767,''a'')||''Stephen_King''', 'a%Stephe\__%', '\', ut3.ut_utils.tr_success, 'not_');
  end;

  procedure test_timestamp_between is
    l_value timestamp := to_timestamp('1997-01-31 09:26:50.13','YYYY-MM-DD HH24.MI.SS.FF');
    l_value_lower timestamp := to_timestamp('1997-01-31 09:26:50.11','YYYY-MM-DD HH24.MI.SS.FF');
    l_value_upper timestamp := to_timestamp('1997-01-31 09:26:50.14','YYYY-MM-DD HH24.MI.SS.FF');
  begin
    ut3.ut.expect(l_value).to_be_between(l_value_lower, l_value_upper);
    ut3.ut.expect(l_value).not_to_be_between(l_value_upper, l_value_lower);

    transfer_results;
  end;

  procedure test_timestamp_ltz_between is
    l_value timestamp with local time zone := to_timestamp_tz('1997-01-31 09:26:50.12 +02:00','YYYY-MM-DD HH24.MI.SS.FF TZR');
    l_value_lower timestamp with local time zone := to_timestamp_tz('1997-01-31 09:26:50.12 +03:00','YYYY-MM-DD HH24.MI.SS.FF TZR');
    l_value_upper timestamp with local time zone := to_timestamp_tz('1997-01-31 09:26:50.12 +01:00','YYYY-MM-DD HH24.MI.SS.FF TZR');
  begin
    ut3.ut.expect(l_value).to_be_between(l_value_lower, l_value_upper);
    ut3.ut.expect(l_value).not_to_be_between(l_value_upper, l_value_lower);

    transfer_results;
  end;

  procedure test_timestamp_tz_between is
    l_value timestamp with time zone := to_timestamp_tz('1997-01-31 09:26:50.12 +02:00','YYYY-MM-DD HH24.MI.SS.FF TZR');
    l_value_lower timestamp with time zone := to_timestamp_tz('1997-01-31 09:26:50.12 +03:00','YYYY-MM-DD HH24.MI.SS.FF TZR');
    l_value_upper timestamp with time zone := to_timestamp_tz('1997-01-31 09:26:50.12 +01:00','YYYY-MM-DD HH24.MI.SS.FF TZR');
  begin
    ut3.ut.expect(l_value).to_be_between(l_value_lower, l_value_upper);
    ut3.ut.expect(l_value).not_to_be_between(l_value_upper, l_value_lower);

    transfer_results;
  end;

end test_matchers;
/
