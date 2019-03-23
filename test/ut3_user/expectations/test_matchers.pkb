create or replace package body test_matchers is

  procedure cleanup_expectations is
  begin
    ut3_tester_helper.main_helper.clear_expectations( );
  end;

  procedure exec_matcher(a_type varchar2, a_actual_value varchar2, a_expected_value varchar2, a_matcher varchar2, a_result integer, a_prefix varchar2 := null) is
    l_statement      varchar2(32767);
  begin
    l_statement := '
      declare
        l_actual   '||a_type||' := '||a_actual_value||';
        l_expected '||a_type||' := '||a_expected_value||';
      begin
        ut3.ut.expect( l_actual ).'||a_prefix||'to_'||a_matcher||'( l_expected );
      end;';
    execute immediate l_statement;
    if a_result = ut3_tester_helper.main_helper.gc_success then
      ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_n()).to_equal(0);
    else
      ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_n()).to_be_greater_than(0);
    end if;
    cleanup_expectations();
  end exec_matcher;

  procedure exec_be_between(a_type varchar2, a_actual_value varchar2, a_expected1_value varchar2, a_expected2_value varchar2,a_result integer) is
    l_statement      varchar2(32767);
  begin
    l_statement := '
      declare
        l_actual_value '||a_type||' := '||a_actual_value||';
        l_lower        '||a_type||' := '||a_expected1_value||';
        l_higher       '||a_type||' := '||a_expected2_value||';
      begin
        ut3.ut.expect(l_actual_value).to_be_between(l_lower, l_higher);
      end;';
    execute immediate l_statement;
    if a_result = ut3_tester_helper.main_helper.gc_success then
      ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_n()).to_equal(0);
    else
      ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_n()).to_be_greater_than(0);
    end if;
    cleanup_expectations();
  end exec_be_between;

  procedure exec_be_between2(a_type varchar2, a_actual_value varchar2, a_expected1_value varchar2, a_expected2_value varchar2,a_result integer, a_not_prefix varchar2 default null) is
    l_statement      varchar2(32767);
  begin
    l_statement := '
    declare
      l_actual_value '||a_type||' := '||a_actual_value||';
      l_value1 '||a_type||' := '||a_expected1_value||';
      l_value2 '||a_type||' := '||a_expected2_value||';
    begin
      ut3.ut.expect(l_actual_value).'||a_not_prefix||'to_be_between(l_value1, l_value2);
    end;';
    execute immediate l_statement;
    if a_result = ut3_tester_helper.main_helper.gc_success then
      ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_n()).to_equal(0);
    else
      ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_n()).to_be_greater_than(0);
    end if;
    cleanup_expectations();
  end exec_be_between2;

  procedure exec_be_like(a_type varchar2, a_value varchar2, a_pattern varchar2, a_escape varchar2, a_result integer, a_prefix varchar2 default null) is
  begin
    execute immediate
     'declare
        l_actual    ' || a_type || ' := '||a_value||';
        l_pattern   varchar2(32767) := :pattern;
        l_escape_char varchar2(32767) := :a_escape;
        l_result    integer;
      begin
        ut3.ut.expect( l_actual ).' || a_prefix ||q'[to_be_like(l_pattern, l_escape_char);
      end;]'
    using a_pattern, a_escape;
    if a_result = ut3_tester_helper.main_helper.gc_success then
      ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_n()).to_equal(0);
    else
      ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_n()).to_be_greater_than(0);
    end if;
    cleanup_expectations();
  end;
  
  procedure exec_match(a_type varchar2, a_actual_value varchar2, a_pattern varchar2, a_modifiers varchar2, a_result integer, a_not_prefix varchar2 default null) is
    l_statement      varchar2(32767);
  begin
    l_statement :=
     'declare
        l_actual    '||a_type||' := '||a_actual_value||';
        l_pattern   varchar2(32767) := :a_pattern;
        l_modifiers varchar2(32767) := :a_modifiers;
        l_result    integer;
      begin
        ut3.ut.expect( l_actual ).'||a_not_prefix||'to_match(l_pattern, l_modifiers);
      end;';
    execute immediate l_statement using a_pattern, a_modifiers;
    if a_result = ut3_tester_helper.main_helper.gc_success then
      ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_n()).to_equal(0);
    else
      ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_n()).to_be_greater_than(0);
    end if;
    cleanup_expectations();
  end;

  procedure test_be_between2 is
  begin

    --failure when value out of range
    exec_be_between2('date', 'sysdate', 'sysdate-2', 'sysdate-1', ut3_tester_helper.main_helper.gc_failure, '');
    exec_be_between2('number', '2.0', '1.99', '1.999', ut3_tester_helper.main_helper.gc_failure, '');
    exec_be_between2('varchar2(1)', '''c''', '''a''', '''b''', ut3_tester_helper.main_helper.gc_failure, '');
    exec_be_between2('timestamp', 'systimestamp+1', 'systimestamp-1', 'systimestamp', ut3_tester_helper.main_helper.gc_failure, '');
    exec_be_between2('timestamp with local time zone', 'systimestamp+1', 'systimestamp-1', 'systimestamp', ut3_tester_helper.main_helper.gc_failure, '');
    exec_be_between2('timestamp with time zone', 'systimestamp+1', 'systimestamp-1', 'systimestamp', ut3_tester_helper.main_helper.gc_failure, '');
    exec_be_between2('interval year to month', '''2-2''', '''2-0''', '''2-1''', ut3_tester_helper.main_helper.gc_failure, '');
    exec_be_between2('interval day to second', '''2 01:00:00''', '''2 00:59:58''', '''2 00:59:59''', ut3_tester_helper.main_helper.gc_failure, '');

    --success when value in range
    exec_be_between2('date', 'sysdate', 'sysdate-1', 'sysdate+1', ut3_tester_helper.main_helper.gc_success, '');
    exec_be_between2('number', '2.0', '1.99', '2.01', ut3_tester_helper.main_helper.gc_success, '');
    exec_be_between2('varchar2(1)', '''b''', '''a''', '''c''', ut3_tester_helper.main_helper.gc_success, '');
    exec_be_between2('timestamp', 'systimestamp', 'systimestamp-1', 'systimestamp+1', ut3_tester_helper.main_helper.gc_success, '');
    exec_be_between2('timestamp with local time zone', 'systimestamp', 'systimestamp-1', 'systimestamp+1', ut3_tester_helper.main_helper.gc_success, '');
    exec_be_between2('timestamp with time zone', 'systimestamp', 'systimestamp-1', 'systimestamp+1', ut3_tester_helper.main_helper.gc_success, '');
    exec_be_between2('interval year to month', '''2-1''', '''2-0''', '''2-2''', ut3_tester_helper.main_helper.gc_success, '');
    exec_be_between2('interval day to second', '''2 01:00:00''', '''2 00:59:58''', '''2 01:00:01''', ut3_tester_helper.main_helper.gc_success, '');

    --success when value not in range
    exec_be_between2('date', 'sysdate', 'sysdate-2', 'sysdate-1', ut3_tester_helper.main_helper.gc_success, 'not_');
    exec_be_between2('number', '2.0', '1.99', '1.999', ut3_tester_helper.main_helper.gc_success, 'not_');
    exec_be_between2('varchar2(1)', '''c''', '''a''', '''b''', ut3_tester_helper.main_helper.gc_success, 'not_');
    exec_be_between2('timestamp', 'systimestamp+1', 'systimestamp-1', 'systimestamp', ut3_tester_helper.main_helper.gc_success, 'not_');
    exec_be_between2('timestamp with local time zone', 'systimestamp+1', 'systimestamp-1', 'systimestamp', ut3_tester_helper.main_helper.gc_success, 'not_');
    exec_be_between2('timestamp with time zone', 'systimestamp+1', 'systimestamp-1', 'systimestamp', ut3_tester_helper.main_helper.gc_success, 'not_');
    exec_be_between2('interval year to month', '''2-2''', '''2-0''', '''2-1''', ut3_tester_helper.main_helper.gc_success, 'not_');
    exec_be_between2('interval day to second', '''2 01:00:00''', '''2 00:59:58''', '''2 00:59:59''', ut3_tester_helper.main_helper.gc_success, 'not_');

    --failure when value not out of range
    exec_be_between2('date', 'sysdate', 'sysdate-1', 'sysdate+1', ut3_tester_helper.main_helper.gc_failure, 'not_');
    exec_be_between2('number', '2.0', '1.99', '2.01', ut3_tester_helper.main_helper.gc_failure, 'not_');
    exec_be_between2('varchar2(1)', '''b''', '''a''', '''c''', ut3_tester_helper.main_helper.gc_failure, 'not_');
    exec_be_between2('timestamp', 'systimestamp', 'systimestamp-1', 'systimestamp+1', ut3_tester_helper.main_helper.gc_failure, 'not_');
    exec_be_between2('timestamp with local time zone', 'systimestamp', 'systimestamp-1', 'systimestamp+1', ut3_tester_helper.main_helper.gc_failure, 'not_');
    exec_be_between2('timestamp with time zone', 'systimestamp', 'systimestamp-1', 'systimestamp+1', ut3_tester_helper.main_helper.gc_failure, 'not_');
    exec_be_between2('interval year to month', '''2-1''', '''2-0''', '''2-2''', ut3_tester_helper.main_helper.gc_failure, 'not_');
    exec_be_between2('interval day to second', '''2 01:00:00''', '''2 00:59:58''', '''2 01:00:01''', ut3_tester_helper.main_helper.gc_failure, 'not_');

    --failure when value is null
    exec_be_between2('date', 'null', 'sysdate-1', 'sysdate+1', ut3_tester_helper.main_helper.gc_failure, '');
    exec_be_between2('number', 'null', '1.99', '2.01', ut3_tester_helper.main_helper.gc_failure, '');
    exec_be_between2('varchar2(1)', 'null', '''a''', '''c''', ut3_tester_helper.main_helper.gc_failure, '');
    exec_be_between2('timestamp', 'null', 'systimestamp-1', 'systimestamp+1', ut3_tester_helper.main_helper.gc_failure, '');
    exec_be_between2('timestamp with local time zone', 'null', 'systimestamp-1', 'systimestamp+1', ut3_tester_helper.main_helper.gc_failure, '');
    exec_be_between2('timestamp with time zone', 'null', 'systimestamp-1', 'systimestamp+1', ut3_tester_helper.main_helper.gc_failure, '');
    exec_be_between2('interval year to month', 'null', '''2-0''', '''2-2''', ut3_tester_helper.main_helper.gc_failure, '');
    exec_be_between2('interval day to second', 'null', '''2 00:59:58''', '''2 01:00:01''', ut3_tester_helper.main_helper.gc_failure, '');

    exec_be_between2('date', 'null', 'sysdate-2', 'sysdate-1', ut3_tester_helper.main_helper.gc_failure, 'not_');
    exec_be_between2('number', 'null', '1.99', '1.999', ut3_tester_helper.main_helper.gc_failure, 'not_');
    exec_be_between2('varchar2(1)', 'null', '''a''', '''b''', ut3_tester_helper.main_helper.gc_failure, 'not_');
    exec_be_between2('timestamp', 'null', 'systimestamp-1', 'systimestamp', ut3_tester_helper.main_helper.gc_failure, 'not_');
    exec_be_between2('timestamp with local time zone', 'null', 'systimestamp-1', 'systimestamp', ut3_tester_helper.main_helper.gc_failure, 'not_');
    exec_be_between2('timestamp with time zone', 'null', 'systimestamp-1', 'systimestamp', ut3_tester_helper.main_helper.gc_failure, 'not_');
    exec_be_between2('interval year to month', 'null', '''2-0''', '''2-1''', ut3_tester_helper.main_helper.gc_failure, 'not_');
    exec_be_between2('interval day to second', 'null', '''2 00:59:58''', '''2 00:59:59''', ut3_tester_helper.main_helper.gc_failure, 'not_');

    --failure when lower bound is null
    exec_be_between2('date', 'sysdate', 'null', 'sysdate+1', ut3_tester_helper.main_helper.gc_failure, '');
    exec_be_between2('number', '2.0', 'null', '2.01', ut3_tester_helper.main_helper.gc_failure, '');
    exec_be_between2('varchar2(1)', '''b''', 'null', '''c''', ut3_tester_helper.main_helper.gc_failure, '');
    exec_be_between2('timestamp', 'systimestamp', 'null', 'systimestamp+1', ut3_tester_helper.main_helper.gc_failure, '');
    exec_be_between2('timestamp with local time zone', 'systimestamp', 'null', 'systimestamp+1', ut3_tester_helper.main_helper.gc_failure, '');
    exec_be_between2('timestamp with time zone', 'systimestamp', 'null', 'systimestamp+1', ut3_tester_helper.main_helper.gc_failure, '');
    exec_be_between2('interval year to month', '''2-1''', 'null', '''2-2''', ut3_tester_helper.main_helper.gc_failure, '');
    exec_be_between2('interval day to second', '''2 01:00:00''', 'null', '''2 01:00:01''', ut3_tester_helper.main_helper.gc_failure, '');

    exec_be_between2('date', 'sysdate', 'null', 'sysdate-1', ut3_tester_helper.main_helper.gc_failure, 'not_');
    exec_be_between2('number', '2.0', 'null', '1.999', ut3_tester_helper.main_helper.gc_failure, 'not_');
    exec_be_between2('varchar2(1)', '''b''', 'null', '''b''', ut3_tester_helper.main_helper.gc_failure, 'not_');
    exec_be_between2('timestamp', 'systimestamp+1', 'null', 'systimestamp', ut3_tester_helper.main_helper.gc_failure, 'not_');
    exec_be_between2('timestamp with local time zone', 'systimestamp+1', 'null', 'systimestamp', ut3_tester_helper.main_helper.gc_failure, 'not_');
    exec_be_between2('timestamp with time zone', 'systimestamp+1', 'null', 'systimestamp', ut3_tester_helper.main_helper.gc_failure, 'not_');
    exec_be_between2('interval year to month', '''2-2''', 'null', '''2-1''', ut3_tester_helper.main_helper.gc_failure, 'not_');
    exec_be_between2('interval day to second', '''2 01:00:00''', 'null', '''2 00:59:59''', ut3_tester_helper.main_helper.gc_failure, 'not_');
    --Fails for unsupported data-type
    exec_be_between2('clob', '''b''', '''a''', '''c''', ut3_tester_helper.main_helper.gc_failure, '');
  end;

  procedure test_match is
  begin
    exec_match('varchar2(100)', '''Stephen''', '^Ste(v|ph)en$', '', ut3_tester_helper.main_helper.gc_success);
    exec_match('varchar2(100)', '''sTEPHEN''', '^Ste(v|ph)en$', 'i', ut3_tester_helper.main_helper.gc_success);
    exec_match('clob', 'to_clob(rpad('', '',32767)||''Stephen'')', 'Ste(v|ph)en$', '', ut3_tester_helper.main_helper.gc_success);
    exec_match('clob', 'to_clob(rpad('', '',32767)||''sTEPHEN'')', 'Ste(v|ph)en$', 'i', ut3_tester_helper.main_helper.gc_success);

    exec_match('varchar2(100)', '''Stephen''', '^Steven$', '', ut3_tester_helper.main_helper.gc_failure);
    exec_match('varchar2(100)', '''sTEPHEN''', '^Steven$', 'i', ut3_tester_helper.main_helper.gc_failure);
    exec_match('clob', 'to_clob(rpad('', '',32767)||''Stephen'')', '^Stephen', '', ut3_tester_helper.main_helper.gc_failure);
    exec_match('clob', 'to_clob(rpad('', '',32767)||''sTEPHEN'')', '^Stephen', 'i', ut3_tester_helper.main_helper.gc_failure);

    exec_match('varchar2(100)', '''Stephen''', '^Ste(v|ph)en$', '', ut3_tester_helper.main_helper.gc_failure, 'not_');
    exec_match('varchar2(100)', '''sTEPHEN''', '^Ste(v|ph)en$', 'i', ut3_tester_helper.main_helper.gc_failure, 'not_');
    exec_match('clob', 'to_clob(rpad('', '',32767)||''Stephen'')', 'Ste(v|ph)en$', '', ut3_tester_helper.main_helper.gc_failure, 'not_');
    exec_match('clob', 'to_clob(rpad('', '',32767)||''sTEPHEN'')', 'Ste(v|ph)en$', 'i', ut3_tester_helper.main_helper.gc_failure, 'not_');

    exec_match('varchar2(100)', '''Stephen''', '^Steven$', '', ut3_tester_helper.main_helper.gc_success, 'not_');
    exec_match('varchar2(100)', '''sTEPHEN''', '^Steven$', 'i', ut3_tester_helper.main_helper.gc_success, 'not_');
    exec_match('clob', 'to_clob(rpad('', '',32767)||''Stephen'')', '^Stephen', '', ut3_tester_helper.main_helper.gc_success, 'not_');
    exec_match('clob', 'to_clob(rpad('', '',32767)||''sTEPHEN'')', '^Stephen', 'i', ut3_tester_helper.main_helper.gc_success, 'not_');
    --Fails for unsupported data-type
    exec_match('number', '12345', '^123.*', 'i', ut3_tester_helper.main_helper.gc_failure);
  end;

  procedure test_be_like is
  begin
    exec_be_like('varchar2(100)', '''Stephen_King''', 'Ste__en%', '', ut3_tester_helper.main_helper.gc_success);
    exec_be_like('varchar2(100)', '''Stephen_King''', 'Ste__en\_K%', '\', ut3_tester_helper.main_helper.gc_success);
    exec_be_like('clob', 'to_clob(rpad(''a'',32767,''a'')||''Stephen_King'')', 'a%Ste__en%', '', ut3_tester_helper.main_helper.gc_success);
    exec_be_like('clob', 'to_clob(rpad(''a'',32767,''a'')||''Stephen_King'')', 'a%Ste__en\_K%', '\', ut3_tester_helper.main_helper.gc_success);

    exec_be_like('varchar2(100)', '''Stephen_King''', 'Ste_en%', '', ut3_tester_helper.main_helper.gc_failure);
    exec_be_like('varchar2(100)', '''Stephen_King''', 'Stephe\__%', '\', ut3_tester_helper.main_helper.gc_failure);
    exec_be_like('clob', 'to_clob(rpad(''a'',32767,''a'')||''Stephen_King'')', 'a%Ste_en%', '', ut3_tester_helper.main_helper.gc_failure);
    exec_be_like('clob', 'to_clob(rpad(''a'',32767,''a'')||''Stephen_King'')', 'a%Stephe\__%', '\', ut3_tester_helper.main_helper.gc_failure);

    exec_be_like('varchar2(100)', '''Stephen_King''', 'Ste__en%', '', ut3_tester_helper.main_helper.gc_failure, 'not_');
    exec_be_like('varchar2(100)', '''Stephen_King''', 'Ste__en\_K%', '\', ut3_tester_helper.main_helper.gc_failure, 'not_');
    exec_be_like('clob', 'to_clob(rpad(''a'',32767,''a'')||''Stephen_King'')', 'a%Ste__en%', '', ut3_tester_helper.main_helper.gc_failure, 'not_');
    exec_be_like('clob', 'to_clob(rpad(''a'',32767,''a'')||''Stephen_King'')', 'a%Ste__en\_K%', '\', ut3_tester_helper.main_helper.gc_failure, 'not_');

    exec_be_like('varchar2(100)', '''Stephen_King''', 'Ste_en%', '', ut3_tester_helper.main_helper.gc_success, 'not_');
    exec_be_like('varchar2(100)', '''Stephen_King''', 'Stephe\__%', '\', ut3_tester_helper.main_helper.gc_success, 'not_');
    exec_be_like('clob', 'to_clob(rpad(''a'',32767,''a'')||''Stephen_King'')', 'a%Ste_en%', '', ut3_tester_helper.main_helper.gc_success, 'not_');
    exec_be_like('clob', 'to_clob(rpad(''a'',32767,''a'')||''Stephen_King'')', 'a%Stephe\__%', '\', ut3_tester_helper.main_helper.gc_success, 'not_');

    --Fails for unsupported data-type
    exec_be_like('number', '12345', '123%', '', ut3_tester_helper.main_helper.gc_failure);
  end;

  procedure test_timestamp_between is
    l_value timestamp := to_timestamp('1997-01-31 09:26:50.13','YYYY-MM-DD HH24.MI.SS.FF');
    l_value_lower timestamp := to_timestamp('1997-01-31 09:26:50.11','YYYY-MM-DD HH24.MI.SS.FF');
    l_value_upper timestamp := to_timestamp('1997-01-31 09:26:50.14','YYYY-MM-DD HH24.MI.SS.FF');
  begin
    ut3.ut.expect(l_value).to_be_between(l_value_lower, l_value_upper);
    ut3.ut.expect(l_value).not_to_be_between(l_value_upper, l_value_lower);
  end;

  procedure test_timestamp_ltz_between is
    l_value timestamp with local time zone := to_timestamp_tz('1997-01-31 09:26:50.12 +02:00','YYYY-MM-DD HH24.MI.SS.FF TZR');
    l_value_lower timestamp with local time zone := to_timestamp_tz('1997-01-31 09:26:50.12 +03:00','YYYY-MM-DD HH24.MI.SS.FF TZR');
    l_value_upper timestamp with local time zone := to_timestamp_tz('1997-01-31 09:26:50.12 +01:00','YYYY-MM-DD HH24.MI.SS.FF TZR');
  begin
    ut3.ut.expect(l_value).to_be_between(l_value_lower, l_value_upper);
    ut3.ut.expect(l_value).not_to_be_between(l_value_upper, l_value_lower);
  end;

  procedure test_timestamp_tz_between is
    l_value timestamp with time zone := to_timestamp_tz('1997-01-31 09:26:50.12 +02:00','YYYY-MM-DD HH24.MI.SS.FF TZR');
    l_value_lower timestamp with time zone := to_timestamp_tz('1997-01-31 09:26:50.12 +03:00','YYYY-MM-DD HH24.MI.SS.FF TZR');
    l_value_upper timestamp with time zone := to_timestamp_tz('1997-01-31 09:26:50.12 +01:00','YYYY-MM-DD HH24.MI.SS.FF TZR');
  begin
    ut3.ut.expect(l_value).to_be_between(l_value_lower, l_value_upper);
    ut3.ut.expect(l_value).not_to_be_between(l_value_upper, l_value_lower);
  end;

end test_matchers;
/
