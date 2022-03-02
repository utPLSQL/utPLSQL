create or replace package body test_to_be_within is

  procedure cleanup_expectations is
  begin
    ut3_tester_helper.main_helper.clear_expectations( );
  end;

  function be_within_expectation_block(
    a_matcher_name       varchar2,
    a_actual_data_type   varchar2,
    a_actual_data        varchar2,
    a_expected_data_type varchar2,
    a_expected_data      varchar2,
    a_distance           varchar2,
    a_distance_data_type varchar2,
    a_matcher_end        varchar2
  ) return varchar2
    is
    l_execute varchar2(32000);
  begin
    l_execute := '
      declare
        l_actual   '||a_actual_data_type||' := '||a_actual_data||';
        l_expected '||a_expected_data_type||' := '||a_expected_data||';
        l_distance '||a_distance_data_type||' := '||a_distance||';
      begin
        --act - execute the expectation
        ut3_develop.ut.expect( l_actual ).'||a_matcher_name||'(l_distance).of_(l_expected)'||a_matcher_end||';
      end;';
    return l_execute;
  end;

  procedure test_to_be_within_fail(
    a_matcher_name       varchar2,
    a_data_type          varchar2,
    a_actual             varchar2,
    a_expected           varchar2,
    a_distance           varchar2,
    a_distance_data_type varchar2,
    a_matcher_end        varchar2 := null
  ) is
  begin
    execute immediate be_within_expectation_block(
      a_matcher_name,a_data_type, a_actual, a_data_type, a_expected,
      a_distance,a_distance_data_type, a_matcher_end
      );
    ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).not_to_equal(0);
    cleanup_expectations;
  end;

  procedure test_to_be_within_success(
    a_matcher_name       varchar2,
    a_data_type          varchar2,
    a_actual             varchar2,
    a_expected           varchar2,
    a_distance           varchar2,
    a_distance_data_type varchar2,
    a_matcher_end        varchar2 := null
  ) is
  begin
    execute immediate be_within_expectation_block(
      a_matcher_name,a_data_type, a_actual, a_data_type, a_expected,
      a_distance,a_distance_data_type, a_matcher_end
      );
    ut.expect
      (ut3_tester_helper.main_helper.get_failed_expectations_num
      ,be_within_expectation_block(
          a_matcher_name,a_data_type, a_actual, a_data_type, a_expected,
          a_distance,a_distance_data_type, a_matcher_end
         )
      ).to_equal(0);
    cleanup_expectations;
  end;

  procedure success_tests is
  begin
    test_to_be_within_success('to_be_within','number', '2', '4','2','number');
    test_to_be_within_success('to_be_within','number', '4', '2','2','number');
    test_to_be_within_success('to_be_within','date', 'sysdate+1', 'sysdate','''1 0:00:11.333''','interval day to second');
    test_to_be_within_success('to_be_within','date', 'sysdate', 'sysdate+1','''1 0:00:11.333''','interval day to second');
    test_to_be_within_success('to_be_within','date', 'sysdate', 'sysdate+200','''1-0''','interval year to month');
    test_to_be_within_success('to_be_within','date', 'sysdate+200', 'sysdate','''1-0''','interval year to month');
    
    test_to_be_within_success('to_be_within','timestamp', q'[TIMESTAMP '2017-08-09 07:00:00']', q'[TIMESTAMP '2017-08-08 06:59:48.667']','''1 0:00:11.333''','interval day to second');
    test_to_be_within_success('to_be_within','timestamp', q'[TIMESTAMP '2017-08-08 06:59:48.667']', q'[TIMESTAMP '2017-08-09 07:00:00']','''1 0:00:11.333''','interval day to second');
    test_to_be_within_success('to_be_within','timestamp', q'[TIMESTAMP '2017-08-09 07:00:00']', q'[TIMESTAMP '2018-08-09 07:00:00']','''1-0''','interval year to month');
    test_to_be_within_success('to_be_within','timestamp', q'[TIMESTAMP '2018-08-09 07:00:00']', q'[TIMESTAMP '2017-08-09 07:00:00']','''1-0''','interval year to month');
    test_to_be_within_success('to_be_within','timestamp_tz_unconstrained', q'[TIMESTAMP '2017-08-09 07:00:00 -7:00']', q'[TIMESTAMP '2017-08-08 05:59:48.668 -8:00']','''1 0:00:11.333''','interval day to second');
    test_to_be_within_success('to_be_within','timestamp_tz_unconstrained', q'[TIMESTAMP '2017-08-08 05:59:48.668 -8:00']', q'[TIMESTAMP '2017-08-09 07:00:00 -7:00']','''1 0:00:11.333''','interval day to second');
    test_to_be_within_success('to_be_within','timestamp_tz_unconstrained', q'[TIMESTAMP '2017-08-09 07:00:00 -7:00']', q'[TIMESTAMP '2018-08-09 07:00:00 -7:00']','''1-0''','interval year to month');
    test_to_be_within_success('to_be_within','timestamp_tz_unconstrained', q'[TIMESTAMP '2018-08-09 07:00:00 -7:00']', q'[TIMESTAMP '2017-08-09 07:00:00 -7:00']','''1-0''','interval year to month');
    test_to_be_within_success('to_be_within','timestamp_ltz_unconstrained', q'[TIMESTAMP '2017-08-09 07:00:00 -7:00']', q'[TIMESTAMP '2017-08-08 05:59:48.668 -8:00']','''1 0:00:11.333''','interval day to second');
    test_to_be_within_success('to_be_within','timestamp_ltz_unconstrained', q'[TIMESTAMP '2017-08-08 05:59:48.668 -8:00']', q'[TIMESTAMP '2017-08-09 07:00:00 -7:00']','''1 0:00:11.333''','interval day to second');
    test_to_be_within_success('to_be_within','timestamp_ltz_unconstrained', q'[TIMESTAMP '2017-08-09 07:00:00 -7:00']', q'[TIMESTAMP '2018-08-09 07:00:00 -7:00']','''1-0''','interval year to month');
    test_to_be_within_success('to_be_within','timestamp_ltz_unconstrained', q'[TIMESTAMP '2018-08-09 07:00:00 -7:00']', q'[TIMESTAMP '2017-08-09 07:00:00 -7:00']','''1-0''','interval year to month');

    test_to_be_within_success('to_( ut3_develop.be_within','number', '2', '4','2','number', ')');
    test_to_be_within_success('to_( ut3_develop.be_within','number', '4', '2','2','number', ')');
    test_to_be_within_success('to_( ut3_develop.be_within','date', 'sysdate+1', 'sysdate','''1 0:00:11.333''','interval day to second', ')');
    test_to_be_within_success('to_( ut3_develop.be_within','date', 'sysdate', 'sysdate+1','''1 0:00:11.333''','interval day to second', ')');
    test_to_be_within_success('to_( ut3_develop.be_within','date', 'sysdate', 'sysdate+200','''1-0''','interval year to month', ')');
    test_to_be_within_success('to_( ut3_develop.be_within','date', 'sysdate+200', 'sysdate','''1-0''','interval year to month', ')');
    test_to_be_within_success('to_( ut3_develop.be_within','timestamp', q'[TIMESTAMP '2018-08-09 07:00:00']', q'[TIMESTAMP '2017-08-09 07:00:00']','''1-0''','interval year to month', ')');
    test_to_be_within_success('to_( ut3_develop.be_within','timestamp_tz_unconstrained', q'[TIMESTAMP '2017-08-09 07:00:00 -7:00']', q'[TIMESTAMP '2017-08-08 05:59:48.668 -8:00']','''1 0:00:11.333''','interval day to second', ')');
    test_to_be_within_success('to_( ut3_develop.be_within','timestamp_ltz_unconstrained', q'[TIMESTAMP '2017-08-09 07:00:00 -7:00']', q'[TIMESTAMP '2017-08-08 05:59:48.668 -8:00']','''1 0:00:11.333''','interval day to second', ')');
    test_to_be_within_fail('not_to_be_within','number', '2', '4','2','number');
    test_to_be_within_fail('not_to_be_within','number', '4', '2','2','number');
    test_to_be_within_fail('not_to_be_within','date', 'sysdate+1', 'sysdate','''1 0:00:11.333''','interval day to second');
    test_to_be_within_fail('not_to_be_within','date', 'sysdate', 'sysdate+1','''1 0:00:11.333''','interval day to second');
    test_to_be_within_fail('not_to_be_within','date', 'sysdate', 'sysdate+200','''1-0''','interval year to month');
    test_to_be_within_fail('not_to_be_within','date', 'sysdate+200', 'sysdate','''1-0''','interval year to month');
    test_to_be_within_fail('not_to( ut3_develop.be_within','number', '2', '4','2','number',')');
    test_to_be_within_fail('not_to( ut3_develop.be_within','number', '4', '2','2','number',')');
    test_to_be_within_fail('not_to( ut3_develop.be_within','date', 'sysdate+1', 'sysdate','''1 0:00:11.333''','interval day to second',')');
    test_to_be_within_fail('not_to( ut3_develop.be_within','date', 'sysdate', 'sysdate+1','''1 0:00:11.333''','interval day to second',')');
    test_to_be_within_fail('not_to( ut3_develop.be_within','date', 'sysdate', 'sysdate+200','''1-0''','interval year to month',')');
    test_to_be_within_fail('not_to( ut3_develop.be_within','date', 'sysdate+200', 'sysdate','''1-0''','interval year to month',')');
    test_to_be_within_fail('not_to( ut3_develop.be_within','timestamp', q'[TIMESTAMP '2018-08-09 07:00:00']', q'[TIMESTAMP '2017-08-09 07:00:00']','''1-0''','interval year to month', ')');
    test_to_be_within_fail('not_to( ut3_develop.be_within','timestamp_tz_unconstrained', q'[TIMESTAMP '2017-08-09 07:00:00 -7:00']', q'[TIMESTAMP '2017-08-08 05:59:48.668 -8:00']','''1 0:00:11.333''','interval day to second', ')');
    test_to_be_within_fail('not_to( ut3_develop.be_within','timestamp_ltz_unconstrained', q'[TIMESTAMP '2017-08-09 07:00:00 -7:00']', q'[TIMESTAMP '2017-08-08 05:59:48.668 -8:00']','''1 0:00:11.333''','interval day to second', ')');
    test_to_be_within_fail('not_to_be_within','timestamp', q'[TIMESTAMP '2018-08-09 07:00:00']', q'[TIMESTAMP '2017-08-09 07:00:00']','''1-0''','interval year to month');
    test_to_be_within_fail('not_to_be_within','timestamp_tz_unconstrained', q'[TIMESTAMP '2017-08-09 07:00:00 -7:00']', q'[TIMESTAMP '2017-08-08 05:59:48.668 -8:00']','''1 0:00:11.333''','interval day to second');
    test_to_be_within_fail('not_to_be_within','timestamp_ltz_unconstrained', q'[TIMESTAMP '2017-08-09 07:00:00 -7:00']', q'[TIMESTAMP '2017-08-08 05:59:48.668 -8:00']','''1 0:00:11.333''','interval day to second');
  end;
  
  procedure failed_tests is
  begin
    test_to_be_within_fail('to_be_within','number', '2', '4','1','number');
    test_to_be_within_fail('to_be_within','number', '4', '2','1','number');
    test_to_be_within_fail('to_be_within','date', 'sysdate', 'sysdate+1','''0 0:00:11.333''','interval day to second');
    test_to_be_within_fail('to_be_within','date', 'sysdate+1', 'sysdate','''0 0:00:11.333''','interval day to second');
    test_to_be_within_fail('to_be_within','date', 'sysdate', 'sysdate+750','''1-0''','interval year to month');
    test_to_be_within_fail('to_be_within','date', 'sysdate+750', 'sysdate','''1-0''','interval year to month');
    test_to_be_within_fail('to_( ut3_develop.be_within','number', '2', '4','1','number',')');
    test_to_be_within_fail('to_( ut3_develop.be_within','number', '4', '2','1','number',')');
    test_to_be_within_fail('to_( ut3_develop.be_within','date', 'sysdate', 'sysdate+1','''0 0:00:11.333''','interval day to second',')');
    test_to_be_within_fail('to_( ut3_develop.be_within','date', 'sysdate+1', 'sysdate','''0 0:00:11.333''','interval day to second',')');
    test_to_be_within_fail('to_( ut3_develop.be_within','date', 'sysdate', 'sysdate+750','''1-0''','interval year to month',')');
    test_to_be_within_fail('to_( ut3_develop.be_within','date', 'sysdate+750', 'sysdate','''1-0''','interval year to month',')');
    test_to_be_within_success('not_to_be_within','number', '2', '4','1','number');
    test_to_be_within_success('not_to_be_within','number', '4', '2','1','number');
    test_to_be_within_success('not_to_be_within','date', 'sysdate', 'sysdate+1','''0 0:00:11.333''','interval day to second');
    test_to_be_within_success('not_to_be_within','date', 'sysdate+1', 'sysdate','''0 0:00:11.333''','interval day to second');
    test_to_be_within_success('not_to_be_within','date', 'sysdate', 'sysdate+750','''1-0''','interval year to month');
    test_to_be_within_success('not_to_be_within','date', 'sysdate+750', 'sysdate','''1-0''','interval year to month');
    test_to_be_within_success('not_to( ut3_develop.be_within','number', '2', '4','1','number',')');
    test_to_be_within_success('not_to( ut3_develop.be_within','number', '4', '2','1','number',')');
    test_to_be_within_success('not_to( ut3_develop.be_within','date', 'sysdate', 'sysdate+1','''0 0:00:11.333''','interval day to second',')');
    test_to_be_within_success('not_to( ut3_develop.be_within','date', 'sysdate+1', 'sysdate','''0 0:00:11.333''','interval day to second',')');
    test_to_be_within_success('not_to( ut3_develop.be_within','date', 'sysdate', 'sysdate+750','''1-0''','interval year to month',')');
    test_to_be_within_success('not_to( ut3_develop.be_within','date', 'sysdate+750', 'sysdate','''1-0''','interval year to month',')');
  end;

  procedure fail_for_number_not_within is
    l_actual_message   varchar2(32767);
    l_expected_message varchar2(32767);
  begin
    --Arrange
    --Act
    ut3_develop.ut.expect(4).to_be_within(1).of_(7);
    --Assert
    l_expected_message := q'[Actual: 4 (number) was expected to be within 1 of 7 (number)]';
    l_actual_message := ut3_tester_helper.main_helper.get_failed_expectations(1);
    --Assert
    ut.expect(l_actual_message).to_be_like(l_expected_message);
  end;
    
  procedure fail_for_ds_int_not_within is   
    l_actual_message   varchar2(32767);
    l_expected_message varchar2(32767);
  begin
    --Arrange
    --Act
    ut3_develop.ut.expect(sysdate).to_be_within(interval '1' second).of_(sysdate+1);
    --Assert
    l_expected_message := q'[Actual: % (date) was expected to be within 1 second of % (date)]';
    l_actual_message := ut3_tester_helper.main_helper.get_failed_expectations(1);
    --Assert
    ut.expect(l_actual_message).to_be_like(l_expected_message);
  end;
  
  procedure fail_for_custom_ds_int is   
    l_actual_message   varchar2(32767);
    l_expected_message varchar2(32767);
  begin
    --Arrange
    --Act
    ut3_develop.ut.expect(sysdate).to_be_within(INTERVAL '2 3:04:11.333' DAY TO SECOND).of_(sysdate+100);
    --Assert
    l_expected_message := q'[Actual: % (date) was expected to be within 2 days 3 hours 4 minutes 11.333 seconds of % (date)]';
    l_actual_message := ut3_tester_helper.main_helper.get_failed_expectations(1);
    --Assert
    ut.expect(l_actual_message).to_be_like(l_expected_message);
  end;  
  
  procedure fail_for_ym_int_not_within is   
    l_actual_message   varchar2(32767);
    l_expected_message varchar2(32767);
  begin
    --Arrange
    --Act
    ut3_develop.ut.expect(sysdate).to_be_within(INTERVAL '1'  MONTH).of_(sysdate+ 46);
    --Assert
    l_expected_message := q'[Actual: % (date) was expected to be within 1 month of % (date)]';
    l_actual_message := ut3_tester_helper.main_helper.get_failed_expectations(1);
    --Assert
    ut.expect(l_actual_message).to_be_like(l_expected_message);
  end;  
  
  procedure fail_for_custom_ym_int is   
    l_actual_message   varchar2(32767);
    l_expected_message varchar2(32767);
  begin
    --Arrange
    --Act
    ut3_develop.ut.expect(sysdate).to_be_within(INTERVAL '1-3' YEAR TO MONTH).of_(sysdate+720);
    --Assert
    l_expected_message := q'[Actual: % (date) was expected to be within 1 year 3 months % (date)]';
    l_actual_message := ut3_tester_helper.main_helper.get_failed_expectations(1);
    --Assert
    ut.expect(l_actual_message).to_be_like(l_expected_message);
  end;      
  
  procedure fail_msg_when_not_within is
    l_actual_message   varchar2(32767);
    l_expected_message varchar2(32767);
  begin
    --Arrange
    --Act
    ut3_develop.ut.expect(1).to_be_within(3).of_(12);
    --Assert
    l_expected_message := q'[Actual: 1 (number) was expected to be within 3 of 12 (number)]';
    l_actual_message := ut3_tester_helper.main_helper.get_failed_expectations(1);
    --Assert
    ut.expect(l_actual_message).to_be_like(l_expected_message);
 end;
 
  procedure fail_msg_wrong_types is
    l_actual_message   varchar2(32767);
    l_expected_message varchar2(32767);
  begin
    --Act
    ut3_develop.ut.expect(sysdate).to_be_within(interval '1' second).of_(systimestamp);
    --Assert
    l_expected_message := q'[Matcher 'be within' cannot be used to compare Actual (date) with Expected (timestamp with time zone) using distance (interval day to second).]';
    l_actual_message := ut3_tester_helper.main_helper.get_failed_expectations(1);
    --Assert
    ut.expect(l_actual_message).to_be_like(l_expected_message);
  end;

  procedure null_expected is
    l_actual_message   varchar2(32767);
    l_expected_message varchar2(32767);
  begin
    --Act
    ut3_develop.ut.expect(sysdate).to_be_within(interval '1' second).of_(to_date(null));
    --Assert
    l_expected_message := q'[Actual: % (date) was expected to be within 1 second of NULL (date)]';
    l_actual_message := ut3_tester_helper.main_helper.get_failed_expectations(1);
    --Assert
    ut.expect(l_actual_message).to_be_like(l_expected_message);
  end;

  procedure null_actual_and_expected is
    l_actual_message   varchar2(32767);
    l_expected_message varchar2(32767);
  begin
    --Act
    ut3_develop.ut.expect(to_date(null)).to_be_within(interval '1' second).of_(to_date(null));
    --Assert
    l_expected_message := q'[Actual: NULL (date) was expected to be within 1 second of NULL (date)]';
    l_actual_message := ut3_tester_helper.main_helper.get_failed_expectations(1);
    --Assert
    ut.expect(l_actual_message).to_be_like(l_expected_message);
  end;

  procedure null_actual is
    l_actual_message   varchar2(32767);
    l_expected_message varchar2(32767);
  begin
    --Act
    ut3_develop.ut.expect(to_date(null)).to_be_within(interval '1' second).of_(sysdate);
    --Assert
    l_expected_message := q'[Actual: NULL (date) was expected to be within 1 second of % (date)]';
    l_actual_message := ut3_tester_helper.main_helper.get_failed_expectations(1);
    --Assert
    ut.expect(l_actual_message).to_be_like(l_expected_message);
  end;


  procedure null_distance is
    l_actual_message   varchar2(32767);
    l_expected_message varchar2(32767);
  begin
    --Act
    ut3_develop.ut.expect(sysdate).to_be_within(cast(null as interval day to second)).of_(sysdate);
    --Assert
    l_expected_message := q'[Actual: % (date) was expected to be within NULL of % (date)]';
    l_actual_message := ut3_tester_helper.main_helper.get_failed_expectations(1);
    --Assert
    ut.expect(l_actual_message).to_be_like(l_expected_message);
  end;


  procedure invalid_distance_for_number is
    l_actual_message   varchar2(32767);
    l_expected_message varchar2(32767);
  begin
    --Act
    ut3_develop.ut.expect(2).to_be_within(interval '1' second).of_(1);
    --Assert
    l_expected_message := q'[Matcher 'be within' cannot be used to compare Actual (number) with Expected (number) using distance (interval day to second).]';
    l_actual_message := ut3_tester_helper.main_helper.get_failed_expectations(1);
    --Assert
    ut.expect(l_actual_message).to_be_like(l_expected_message);
  end;


  procedure invalid_distance_for_timestamp is
    l_actual_message   varchar2(32767);
    l_expected_message varchar2(32767);
  begin
    --Act
    ut3_develop.ut.expect(sysdate).to_be_within(1).of_(sysdate);
    --Assert
    l_expected_message := q'[Matcher 'be within' cannot be used to compare Actual (date) with Expected (date) using distance (number).]';
    l_actual_message := ut3_tester_helper.main_helper.get_failed_expectations(1);
    --Assert
    ut.expect(l_actual_message).to_be_like(l_expected_message);
  end;

  procedure failure_on_tiny_time_diff is
    l_actual_message   varchar2(32767);
    l_expected_message varchar2(32767);
  begin
    --Act
    ut3_develop.ut.expect(timestamp'2022-01-29 23:23:23.000000009').to_be_within(interval '0.000000001' second).of_(timestamp'2022-01-29 23:23:23.000000001');
    --Assert
    l_expected_message := q'[Actual:  2022-01-29T23:23:23.000000009 (timestamp) was expected to be within .000000001 seconds of  2022-01-29T23:23:23.000000001 (timestamp)]';
    l_actual_message := ut3_tester_helper.main_helper.get_failed_expectations(1);
    --Assert
    ut.expect(l_actual_message).to_be_like(l_expected_message);
  end;


  procedure failure_on_large_years_compare is
    l_actual_message   varchar2(32767);
    l_expected_message varchar2(32767);
  begin
    --Act
    ut3_develop.ut.expect(to_date('-4000-01-01','syyyy-mm-dd')).to_be_within(interval '9990' year).of_(date '9999-12-31');
    --Assert
    l_expected_message := q'[Actual: -4000-01-01T00:00:00 (date) was expected to be within 9990 years of  9999-12-31T00:00:00 (date)]';
    l_actual_message := ut3_tester_helper.main_helper.get_failed_expectations(1);
    --Assert
    ut.expect(l_actual_message).to_be_like(l_expected_message);
  end;

end;
/
