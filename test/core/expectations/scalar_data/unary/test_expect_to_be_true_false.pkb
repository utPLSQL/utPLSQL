create or replace package body test_expect_to_be_true_false
is

  procedure cleanup_expectations is
  begin
    expectations.cleanup_expectations( );
  end;

  procedure to_be_true_null_boolean is
  begin
    --Act
    ut3.ut.expect( 1=null ).to_be_true();
    --Assert
    ut.expect( expectations.failed_expectations_data( ) ).not_to_be_empty( );
  end;

  procedure to_be_true_success is
  begin
    --Act
    ut3.ut.expect( 1=1 ).to_be_true();
    --Assert
    ut.expect( expectations.failed_expectations_data( ) ).to_be_empty( );
  end;

  procedure to_be_true_failure is
  begin
    --Act
    ut3.ut.expect( 1=2 ).to_be_true();
    --Assert
    ut.expect( expectations.failed_expectations_data( ) ).not_to_be_empty( );
  end;

  procedure to_be_true_bad_type is
  begin
    --Act
    ut3.ut.expect( 1 ).to_be_true();
    --Assert
    ut.expect( expectations.failed_expectations_data( ) ).not_to_be_empty( );
  end;

  procedure not_to_be_true_null_boolean is
  begin
    --Act
    ut3.ut.expect( 1=null ).not_to_be_true();
    --Assert
    ut.expect( expectations.failed_expectations_data( ) ).not_to_be_empty( );
  end;

  procedure not_to_be_true_success is
  begin
    --Act
    ut3.ut.expect( 1=2 ).not_to_be_true();
    --Assert
    ut.expect( expectations.failed_expectations_data( ) ).to_be_empty( );
  end;

  procedure not_to_be_true_failure is
  begin
    --Act
    ut3.ut.expect( 1=1 ).not_to_be_true();
    --Assert
    ut.expect( expectations.failed_expectations_data( ) ).not_to_be_empty( );
  end;


  procedure not_to_be_true_bad_type is
  begin
    --Act
    ut3.ut.expect( 1 ).not_to_be_true();
    --Assert
    ut.expect( expectations.failed_expectations_data( ) ).not_to_be_empty( );
  end;

  procedure to_be_false_null_boolean is
  begin
    --Act
    ut3.ut.expect( 1=null ).to_be_false();
    --Assert
    ut.expect( expectations.failed_expectations_data( ) ).not_to_be_empty( );
  end;

  procedure to_be_false_success is
  begin
    --Act
    ut3.ut.expect( 1=2 ).to_be_false();
    --Assert
    ut.expect( expectations.failed_expectations_data( ) ).to_be_empty( );
  end;

  procedure to_be_false_failure is
  begin
    --Act
    ut3.ut.expect( 1=1 ).to_be_false();
    --Assert
    ut.expect( expectations.failed_expectations_data( ) ).not_to_be_empty( );
  end;

  procedure to_be_false_bad_type is
  begin
    --Act
    ut3.ut.expect( 1 ).to_be_false();
    --Assert
    ut.expect( expectations.failed_expectations_data( ) ).not_to_be_empty( );
  end;

  procedure not_to_be_false_null_boolean is
  begin
    --Act
    ut3.ut.expect( 1=null ).not_to_be_false();
    --Assert
    ut.expect( expectations.failed_expectations_data( ) ).not_to_be_empty( );
  end;

  procedure not_to_be_false_success is
  begin
    --Act
    ut3.ut.expect( 1=1 ).not_to_be_false();
    --Assert
    ut.expect( expectations.failed_expectations_data( ) ).to_be_empty( );
  end;

  procedure not_to_be_false_failure is
  begin
    --Act
    ut3.ut.expect( 1=2 ).not_to_be_false();
    --Assert
    ut.expect( expectations.failed_expectations_data( ) ).not_to_be_empty( );
  end;

  procedure not_to_be_false_bad_type is
  begin
    --Act
    ut3.ut.expect( 1 ).not_to_be_false();
    --Assert
    ut.expect( expectations.failed_expectations_data( ) ).not_to_be_empty( );
  end;

end;
/
