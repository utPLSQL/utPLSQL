create or replace package body test_equal is

  procedure reset_nulls_equal is
  begin
    ut3_tester_helper.main_helper.reset_nulls_equal;
  end;

  procedure cleanup_expectations is
  begin
    ut3_tester_helper.main_helper.clear_expectations( );
  end;

  function to_equal_block(
    a_matcher_name  varchar2,
    a_actual_type   varchar2,
    a_expected_type varchar2,
    a_actual        varchar2,
    a_expected      varchar2,
    a_nulls_equal   boolean := null
  ) return varchar2 is
    l_nulls_equal   varchar2(10);
  begin
    l_nulls_equal := case when a_nulls_equal then 'true' when not a_nulls_equal then 'false' else 'null' end;
    return '
    declare
      l_actual   '||a_actual_type||' := '||a_actual||';
      l_expected '||a_expected_type||' := '||a_expected||';
    begin
      ut3.ut.expect( l_actual ).'||a_matcher_name||'(l_expected, a_nulls_are_equal=>'||l_nulls_equal||');
    end;';
  end;

  procedure test_to_equal_success(
    a_actual_type   varchar2,
    a_expected_type varchar2,
    a_actual        varchar2,
    a_expected      varchar2,
    a_nulls_equal   boolean := null
  ) is
  begin
    execute immediate
      to_equal_block( 'to_equal', a_actual_type, a_expected_type, a_actual, a_expected, a_nulls_equal );
    ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_n).to_equal(0);
    cleanup_expectations;
  end;

  procedure test_to_equal_success(
    a_actual_type   varchar2,
    a_actual        varchar2,
    a_expected      varchar2,
    a_nulls_equal   boolean := null
  ) is
  begin
    test_to_equal_success(a_actual_type, a_actual_type, a_actual, a_expected, a_nulls_equal);
  end;


  procedure test_to_equal_fail(
    a_actual_type   varchar2,
    a_expected_type varchar2,
    a_actual        varchar2,
    a_expected      varchar2,
    a_nulls_equal   boolean := null
  ) is
  begin
    execute immediate
      to_equal_block( 'to_equal', a_actual_type, a_expected_type, a_actual, a_expected, a_nulls_equal );
    ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_n).to_be_greater_than(0);
    cleanup_expectations;
  end;

  procedure test_not_to_equal_fail(
    a_actual_type   varchar2,
    a_expected_type varchar2,
    a_actual        varchar2,
    a_expected      varchar2,
    a_nulls_equal   boolean := null
  ) is
  begin
    execute immediate
      to_equal_block( 'not_to_equal', a_actual_type, a_expected_type, a_actual, a_expected, a_nulls_equal );
    ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_n).to_be_greater_than(0);
    cleanup_expectations;
  end;

  procedure test_to_equal_fail(
    a_actual_type   varchar2,
    a_actual        varchar2,
    a_expected      varchar2,
    a_nulls_equal   boolean := null
  ) is
  begin
    test_to_equal_fail(a_actual_type, a_actual_type, a_actual, a_expected, a_nulls_equal);
  end;

  procedure equal_fail_on_type_diff is
  begin
    test_to_equal_fail('boolean', 'integer', 'true', '1');
    test_to_equal_fail('integer', 'boolean', '1', 'true');
    test_to_equal_fail('blob', 'clob', 'to_blob(''ABC'')', '''ABC''');
    test_to_equal_fail('clob', 'blob', '''ABC''', 'to_blob(''ABC'')');
    test_to_equal_fail('clob', 'anydata', '''ABC''', 'null');
    test_to_equal_fail('anydata', 'sys_refcursor', 'null', 'null');
    test_to_equal_fail('sys_refcursor', 'anydata', 'null', 'null');
    test_to_equal_fail('clob', 'varchar2(4000)', '''Abc''', '''Abc''');
    test_to_equal_fail('date', 'timestamp', 'sysdate', 'sysdate');
    test_to_equal_fail('date', 'timestamp with local time zone', 'sysdate', 'sysdate');
    test_to_equal_fail('timestamp', 'date', 'sysdate', 'sysdate');
    test_to_equal_fail('timestamp with local time zone', 'timestamp', 'sysdate', 'sysdate');
    test_to_equal_fail('timestamp with local time zone', 'timestamp with time zone', 'sysdate', 'sysdate');
    test_to_equal_fail('number', 'varchar2(4000)', '1', '''1''');
    test_to_equal_fail('varchar2(4000)', 'number', '''1''', '1');
    test_to_equal_fail('varchar2(4000)', 'boolean', '''true''', 'true');
    test_to_equal_fail('interval day to second', 'interval year to month', '''2 01:00:00''', '''1-1''');
    test_to_equal_fail('interval year to month', 'interval day to second', '''1-1''', '''2 01:00:00''');
  end;

  procedure not_equal_fail_on_type_diff is
  begin
    test_not_to_equal_fail('boolean', 'integer', 'true', '1');
    test_not_to_equal_fail('integer', 'boolean', '1', 'true');
    test_not_to_equal_fail('blob', 'clob', 'to_blob(''ABC'')', '''ABC''');
    test_not_to_equal_fail('clob', 'blob', '''ABC''', 'to_blob(''ABC'')');
    test_not_to_equal_fail('clob', 'anydata', '''ABC''', 'null');
    test_not_to_equal_fail('anydata', 'sys_refcursor', 'null', 'null');
    test_not_to_equal_fail('sys_refcursor', 'anydata', 'null', 'null');
    test_not_to_equal_fail('clob', 'varchar2(4000)', '''Abc''', '''Abc''');
    test_not_to_equal_fail('date', 'timestamp', 'sysdate', 'sysdate');
    test_not_to_equal_fail('date', 'timestamp with local time zone', 'sysdate', 'sysdate');
    test_not_to_equal_fail('timestamp', 'date', 'sysdate', 'sysdate');
    test_not_to_equal_fail('timestamp with local time zone', 'timestamp', 'sysdate', 'sysdate');
    test_not_to_equal_fail('timestamp with local time zone', 'timestamp with time zone', 'sysdate', 'sysdate');
    test_not_to_equal_fail('number', 'varchar2(4000)', '1', '''1''');
    test_not_to_equal_fail('varchar2(4000)', 'number', '''1''', '1');
    test_not_to_equal_fail('varchar2(4000)', 'boolean', '''true''', 'true');
    test_not_to_equal_fail('interval day to second', 'interval year to month', '''2 01:00:00''', '''1-1''');
    test_not_to_equal_fail('interval year to month', 'interval day to second', '''1-1''', '''2 01:00:00''');
  end;

  procedure failure_on_data_diff is
  begin
    test_to_equal_fail('blob', 'to_blob(''abc'')', 'to_blob(''abd'')');
    test_to_equal_fail('boolean', 'false', 'true');
    test_to_equal_fail('boolean', 'true', 'false');
    test_to_equal_fail('clob', '''Abc''', '''abc''');
    test_to_equal_fail('date', 'sysdate', 'sysdate-1');
    test_to_equal_fail('number', '0.1', '0.3');
    test_to_equal_fail('timestamp', 'systimestamp', 'systimestamp');
    test_to_equal_fail('timestamp with local time zone', 'systimestamp', 'systimestamp');
    test_to_equal_fail('timestamp with time zone', 'systimestamp', 'systimestamp');
    test_to_equal_fail('varchar2(4000)', '''Abc''', '''abc''');
    test_to_equal_fail('interval day to second', '''2 01:00:00''', '''2 01:00:01''');
    test_to_equal_fail('interval year to month', '''1-1''', '''1-2''');
  end;

  procedure failure_on_actual_null is
  begin
    test_to_equal_fail('blob', 'NULL', 'to_blob(''abc'')');
    test_to_equal_fail('boolean', 'NULL', 'true');
    test_to_equal_fail('clob', 'NULL', '''abc''');
    test_to_equal_fail('date', 'NULL', 'sysdate');
    test_to_equal_fail('number', 'NULL', '1');
    test_to_equal_fail('timestamp', 'NULL', 'systimestamp');
    test_to_equal_fail('timestamp with local time zone', 'NULL', 'systimestamp');
    test_to_equal_fail('timestamp with time zone', 'NULL', 'systimestamp');
    test_to_equal_fail('varchar2(4000)', 'NULL', '''abc''');
    test_to_equal_fail('interval day to second', 'NULL', '''2 01:00:00''');
    test_to_equal_fail('interval year to month', 'NULL', '''1-1''');
  end;

  procedure failure_on_expected_null is
  begin
    test_to_equal_fail('blob', 'to_blob(''abc'')', 'NULL');
    test_to_equal_fail('boolean', 'true', 'NULL');
    test_to_equal_fail('clob', '''abc''', 'NULL');
    test_to_equal_fail('date', 'sysdate', 'NULL');
    test_to_equal_fail('number', '1234', 'NULL');
    test_to_equal_fail('timestamp', 'systimestamp', 'NULL');
    test_to_equal_fail('timestamp with local time zone', 'systimestamp', 'NULL');
    test_to_equal_fail('timestamp with time zone', 'systimestamp', 'NULL');
    test_to_equal_fail('varchar2(4000)', '''abc''', 'NULL');
    test_to_equal_fail('interval day to second', '''2 01:00:00''', 'NULL');
    test_to_equal_fail('interval year to month', '''1-1''', 'NULL');
  end;

  procedure failure_on_both_null_with_parm is
  begin
    test_to_equal_fail('blob', 'NULL', 'NULL', false);
    test_to_equal_fail('boolean', 'NULL', 'NULL', false);
    test_to_equal_fail('clob', 'NULL', 'NULL', false);
    test_to_equal_fail('date', 'NULL', 'NULL', false);
    test_to_equal_fail('number', 'NULL', 'NULL', false);
    test_to_equal_fail('timestamp', 'NULL', 'NULL', false);
    test_to_equal_fail('timestamp with local time zone', 'NULL', 'NULL', false);
    test_to_equal_fail('timestamp with time zone', 'NULL', 'NULL', false);
    test_to_equal_fail('varchar2(4000)', 'NULL', 'NULL', false);
    test_to_equal_fail('interval day to second', 'NULL', 'NULL', false);
    test_to_equal_fail('interval year to month', 'NULL', 'NULL', false);
  end;

  procedure failure_on_both_null_with_conf is
  begin
    ut3_tester_helper.main_helper.nulls_are_equal(false);
    test_to_equal_fail('blob', 'NULL', 'NULL');
    test_to_equal_fail('boolean', 'NULL', 'NULL');
    test_to_equal_fail('clob', 'NULL', 'NULL');
    test_to_equal_fail('date', 'NULL', 'NULL');
    test_to_equal_fail('number', 'NULL', 'NULL');
    test_to_equal_fail('timestamp', 'NULL', 'NULL');
    test_to_equal_fail('timestamp with local time zone', 'NULL', 'NULL');
    test_to_equal_fail('timestamp with time zone', 'NULL', 'NULL');
    test_to_equal_fail('varchar2(4000)', 'NULL', 'NULL');
    test_to_equal_fail('interval day to second', 'NULL', 'NULL');
    test_to_equal_fail('interval year to month', 'NULL', 'NULL');
  end;

  procedure success_on_equal_data is
  begin
    test_to_equal_success('blob', 'to_blob(''Abc'')', 'to_blob(''abc'')');
    test_to_equal_success('boolean', 'true', 'true');
    test_to_equal_success('clob', '''Abc''', '''Abc''');
    test_to_equal_success('date', 'sysdate', 'sysdate');
    test_to_equal_success('number', '12345', '12345');
    test_to_equal_success('timestamp(9)', 'to_Timestamp(''2016 123456789'',''yyyy ff'')', 'to_Timestamp(''2016 123456789'',''yyyy ff'')');
    test_to_equal_success('timestamp(9) with local time zone', 'to_Timestamp(''2016 123456789'',''yyyy ff'')', 'to_Timestamp(''2016 123456789'',''yyyy ff'')');
    test_to_equal_success('timestamp(9) with time zone', 'to_Timestamp(''2016 123456789'',''yyyy ff'')', 'to_Timestamp(''2016 123456789'',''yyyy ff'')');
    test_to_equal_success('varchar2(4000)', '''Abc''', '''Abc''');
    test_to_equal_success('interval day to second', '''2 01:00:00''', '''2 01:00:00''');
    test_to_equal_success('interval year to month', '''1-1''', '''1-1''');
  end;

  procedure success_on_both_null is
  begin
    test_to_equal_success('blob', 'NULL', 'NULL');
    test_to_equal_success('boolean', 'NULL', 'NULL');
    test_to_equal_success('clob', 'NULL', 'NULL');
    test_to_equal_success('date', 'NULL', 'NULL');
    test_to_equal_success('number', 'NULL', 'NULL');
    test_to_equal_success('timestamp', 'NULL', 'NULL');
    test_to_equal_success('timestamp with local time zone', 'NULL', 'NULL');
    test_to_equal_success('timestamp with time zone', 'NULL', 'NULL');
    test_to_equal_success('varchar2(4000)', 'NULL', 'NULL');
    test_to_equal_success('interval day to second', 'NULL', 'NULL');
    test_to_equal_success('interval year to month', 'NULL', 'NULL');
  end;

  procedure success_on_both_null_with_parm is
  begin
    ut3_tester_helper.main_helper.nulls_are_equal(false);
    test_to_equal_success('blob', 'NULL', 'NULL', true);
    test_to_equal_success('boolean', 'NULL', 'NULL', true);
    test_to_equal_success('clob', 'NULL', 'NULL', true);
    test_to_equal_success('date', 'NULL', 'NULL', true);
    test_to_equal_success('number', 'NULL', 'NULL', true);
    test_to_equal_success('timestamp', 'NULL', 'NULL', true);
    test_to_equal_success('timestamp with local time zone', 'NULL', 'NULL', true);
    test_to_equal_success('timestamp with time zone', 'NULL', 'NULL', true);
    test_to_equal_success('varchar2(4000)', 'NULL', 'NULL', true);
    test_to_equal_success('interval day to second', 'NULL', 'NULL', true);
    test_to_equal_success('interval year to month', 'NULL', 'NULL', true);
  end;

end;
/
