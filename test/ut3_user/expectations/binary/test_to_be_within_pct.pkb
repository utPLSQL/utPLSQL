create or replace package body test_to_be_within_pct is

  procedure cleanup_expectations is
  begin
    ut3_tester_helper.main_helper.clear_expectations( );
  end;

  function be_within_expectation_block(
    a_matcher         varchar2,
    a_actual_type     varchar2,
    a_actual          varchar2,
    a_expected_type   varchar2,
    a_expected        varchar2,
    a_distance        varchar2,
    a_distance_type   varchar2,
    a_matcher_end     varchar2
  ) return varchar2
    is
    l_execute varchar2(32000);
  begin
    l_execute := '
      declare
        l_actual   '||a_actual_type||' := '||a_actual||';
        l_expected '||a_expected_type||' := '||a_expected||';
        l_distance '||a_distance_type||' := '||a_distance||';
      begin
        --act - execute the expectation
        ut3_develop.ut.expect( l_actual ).'||a_matcher||'( l_distance ).of_( l_expected )'||a_matcher_end||';
      end;';
    return l_execute;
  end;

  procedure test_to_be_within_fail(
    a_matcher         varchar2,
    a_actual_type     varchar2,
    a_actual          varchar2,
    a_expected_type   varchar2,
    a_expected        varchar2,
    a_distance        varchar2,
    a_distance_type   varchar2,
    a_failure_message varchar2 := null,
    a_matcher_end     varchar2 := null
  ) is
    l_failure_text varchar2(4000);
  begin
    execute immediate be_within_expectation_block(
      a_matcher,a_actual_type, a_actual, a_expected_type, a_expected,
      a_distance,a_distance_type, a_matcher_end
      );
    ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_equal(1);
    if a_failure_message is not null then
      l_failure_text := ut3_tester_helper.main_helper.get_failed_expectations(1);
        ut.expect( l_failure_text ).to_be_like('%'||a_failure_message||'%' );
    end if;
    cleanup_expectations;
  end;

  procedure test_to_be_within_success(
    a_matcher       varchar2,
    a_actual_type   varchar2,
    a_actual        varchar2,
    a_expected_type varchar2,
    a_expected      varchar2,
    a_distance      varchar2,
    a_distance_type varchar2,
    a_matcher_end   varchar2 := null
  ) is
  begin
    execute immediate be_within_expectation_block(
      a_matcher,a_actual_type, a_actual, a_expected_type, a_expected,
      a_distance,a_distance_type, a_matcher_end
      );
    ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_equal(0);
    cleanup_expectations;
  end;


  procedure test_to_be_within_error(
    a_matcher       varchar2,
    a_actual_type   varchar2,
    a_actual        varchar2,
    a_expected_type varchar2,
    a_expected      varchar2,
    a_distance      varchar2,
    a_distance_type varchar2,
    a_error_message varchar2,
    a_matcher_end   varchar2 := null
  ) is
  begin
    execute immediate be_within_expectation_block(
      a_matcher,a_actual_type, a_actual, a_expected_type, a_expected,
      a_distance,a_distance_type, a_matcher_end
      );
    cleanup_expectations;
    ut.fail('Expected exception but nothing was raised');
  exception
    when others then
      ut.expect(sqlerrm).to_be_like('%'||a_error_message||'%');
    cleanup_expectations;
  end;


  procedure expect_success is
  begin
    ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_equal(0);
    cleanup_expectations;
  end;

  procedure expect_failure is
  begin
    ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_equal(1);
    cleanup_expectations;
  end;

  procedure success_tests is
  begin
    ut3_develop.ut.expect( 2.987654321 ).to_be_within_pct( 1 ).of_(3);
    expect_success;

    ut3_develop.ut.expect( 2.987654321 ).to_( ut3_develop.be_within_pct( 1 ).of_(3) );
    expect_success;

    ut3_develop.ut.expect( 2.987654321 ).not_to_be_within_pct( 0.1 ).of_(3);
    expect_success;

    ut3_develop.ut.expect( 2.987654321 ).not_to( ut3_develop.be_within_pct( 0.1 ).of_(3) );
    expect_success;
  end;

  procedure failed_tests is
  begin
    ut3_develop.ut.expect( 2.987654321 ).to_be_within_pct( 0.1 ).of_(3);
    expect_failure;

    ut3_develop.ut.expect( 2.987654321 ).to_( ut3_develop.be_within_pct( 0.1 ).of_(3) );
    expect_failure;

    ut3_develop.ut.expect( 2.987654321 ).not_to_be_within_pct( 1 ).of_(3);
    expect_failure;

    ut3_develop.ut.expect( 2.987654321 ).not_to( ut3_develop.be_within_pct( 1 ).of_(3) );
    expect_failure;
  end;

  procedure fail_for_number_not_within is
  begin
    test_to_be_within_fail(
      'to_be_within_pct','number', '4', 'number','7',
      '1','number',
      q'[Actual: 4 (number) was expected to be within 1 % of 7 (number)]'
      );
  end;

  procedure fail_at_invalid_argument_types is
  begin
    test_to_be_within_error(
      'to_be_within_pct','date', 'sysdate', 'date','sysdate',
      '''0 0:00:11.333''','interval day to second',
      'wrong number or types of arguments in call to ''TO_BE_WITHIN_PCT'''
      );
    test_to_be_within_error(
      'to_be_within_pct','number','1', 'date', 'sysdate',
      '1','number',
      ' wrong number or types of arguments in call to ''OF_'''
      );
    test_to_be_within_error(
      'to_be_within_pct','number','1','number','1',
      'sysdate', 'date',
      ' wrong number or types of arguments in call to ''TO_BE_WITHIN_PCT'''
      );
    test_to_be_within_fail(
      'to_be_within_pct','date', 'sysdate', 'number','1',
      '1','number',
      'Matcher ''be within pct'' cannot be used to compare Actual (date) with Expected (number) using distance (number).'
      );
  end;

end;
/
