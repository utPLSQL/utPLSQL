create or replace package body test_expect_to_be_true_false
is

  procedure cleanup_expectations is
  begin
    ut3_tester_helper.main_helper.clear_expectations( );
  end;

  procedure to_be_true_null_boolean is
  begin
    --Act
    ut3_develop.ut.expect( 1=null ).to_be_true();
    --Assert
    ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_be_greater_than(0);
  end;

  procedure to_be_true_success is
  begin
    --Act
    ut3_develop.ut.expect( 1=1 ).to_be_true();
    --Assert
    ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_equal(0);
  end;

  procedure to_be_true_failure is
  begin
    --Act
    ut3_develop.ut.expect( 1=2 ).to_be_true();
    --Assert
    ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_be_greater_than(0);
  end;

  procedure to_be_true_bad_type is
  begin
    --Act
    ut3_develop.ut.expect( 1 ).to_be_true();
    --Assert
    ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_be_greater_than(0);
  end;

  procedure not_to_be_true_null_boolean is
  begin
    --Act
    ut3_develop.ut.expect( 1=null ).not_to_be_true();
    --Assert
    ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_be_greater_than(0);
  end;

  procedure not_to_be_true_success is
  begin
    --Act
    ut3_develop.ut.expect( 1=2 ).not_to_be_true();
    --Assert
    ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_equal(0);
  end;

  procedure not_to_be_true_failure is
  begin
    --Act
    ut3_develop.ut.expect( 1=1 ).not_to_be_true();
    --Assert
    ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_be_greater_than(0);
  end;


  procedure not_to_be_true_bad_type is
  begin
    --Act
    ut3_develop.ut.expect( 1 ).not_to_be_true();
    --Assert
    ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_be_greater_than(0);
  end;

  procedure to_be_false_null_boolean is
  begin
    --Act
    ut3_develop.ut.expect( 1=null ).to_be_false();
    --Assert
    ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_be_greater_than(0);
  end;

  procedure to_be_false_success is
  begin
    --Act
    ut3_develop.ut.expect( 1=2 ).to_be_false();
    --Assert
    ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_equal(0);
  end;

  procedure to_be_false_failure is
  begin
    --Act
    ut3_develop.ut.expect( 1=1 ).to_be_false();
    --Assert
    ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_be_greater_than(0);
  end;

  procedure to_be_false_bad_type is
  begin
    --Act
    ut3_develop.ut.expect( 1 ).to_be_false();
    --Assert
    ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_be_greater_than(0);
  end;

  procedure not_to_be_false_null_boolean is
  begin
    --Act
    ut3_develop.ut.expect( 1=null ).not_to_be_false();
    --Assert
    ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_be_greater_than(0);
  end;

  procedure not_to_be_false_success is
  begin
    --Act
    ut3_develop.ut.expect( 1=1 ).not_to_be_false();
    --Assert
    ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_equal(0);
  end;

  procedure not_to_be_false_failure is
  begin
    --Act
    ut3_develop.ut.expect( 1=2 ).not_to_be_false();
    --Assert
    ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_be_greater_than(0);
  end;

  procedure not_to_be_false_bad_type is
  begin
    --Act
    ut3_develop.ut.expect( 1 ).not_to_be_false();
    --Assert
    ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_be_greater_than(0);
  end;

end;
/
