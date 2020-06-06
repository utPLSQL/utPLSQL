create or replace package body test_to_be_within is

  procedure cleanup_expectations is
  begin
    ut3_tester_helper.main_helper.clear_expectations( );
  end;

  function be_within_expectation_block(
    a_matcher_name       varchar2,
    a_data_type          varchar2,
    a_actual             varchar2,
    a_expected           varchar2,
    a_distance           varchar2,
    a_distance_data_type varchar2
  ) return varchar2 is
  begin
    return ut3_tester_helper.expectations_helper.be_within_expectation_block(
        a_matcher_name, a_data_type, a_actual, a_data_type, a_expected,a_distance,a_distance_data_type
    );
  end;

  procedure test_to_be_within_fail(
    a_matcher_name       varchar2,
    a_data_type          varchar2,
    a_actual             varchar2,
    a_expected           varchar2,
    a_distance           varchar2,
    a_distance_data_type varchar2
  ) is
  begin
    execute immediate be_within_expectation_block(a_matcher_name,a_data_type, a_actual, a_expected,a_distance,a_distance_data_type);
    ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).not_to_equal(0);
    cleanup_expectations;
  end;

  procedure test_to_be_within_success(
    a_matcher_name       varchar2,
    a_data_type          varchar2,
    a_actual             varchar2,
    a_expected           varchar2,
    a_distance           varchar2,
    a_distance_data_type varchar2
  ) is
  begin
    execute immediate be_within_expectation_block(a_matcher_name,a_data_type, a_actual, a_expected,a_distance,a_distance_data_type);
    ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_equal(0);
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
  end;
  
  procedure failed_tests is
  begin
    test_to_be_within_fail('to_be_within','number', '2', '4','1','number');
    test_to_be_within_fail('to_be_within','number', '4', '2','1','number');
    test_to_be_within_fail('to_be_within','date', 'sysdate', 'sysdate+1','''0 0:00:11.333''','interval day to second');
    test_to_be_within_fail('to_be_within','date', 'sysdate+1', 'sysdate','''0 0:00:11.333''','interval day to second');
    test_to_be_within_fail('to_be_within','date', 'sysdate', 'sysdate+750','''1-0''','interval year to month');
    test_to_be_within_fail('to_be_within','date', 'sysdate+750', 'sysdate','''1-0''','interval year to month');
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
    l_expected_message := q'[Actual: % (date) was expected to be within 2 day 3 hour 4 minute 11.333 second of % (date)]';
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
    ut3_develop.ut.expect(sysdate).to_be_within(INTERVAL '1'  MONTH).of_(sysdate+ 45);
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
    l_expected_message := q'[Actual: % (date) was expected to be within 1 year 3 month % (date)]';
    l_actual_message := ut3_tester_helper.main_helper.get_failed_expectations(1);
    --Assert
    ut.expect(l_actual_message).to_be_like(l_expected_message);
  end;      
  
end;
/