create or replace package body test_expect_not_to_be_null
is
  gc_object_name constant varchar2(30) := 't_not_to_be_null_test';
  gc_nested_table_name constant varchar2(30) := 'tt_not_to_be_null_test';
  gc_varray_name constant varchar2(30) := 'tv_not_to_be_null_test';

  procedure cleanup_expectations is
  begin
    ut3_tester_helper.main_helper.clear_expectations( );
  end;

  procedure create_types is
    pragma autonomous_transaction;
  begin
    execute immediate 'create type ' || gc_object_name || ' is object (dummy number)';
    execute immediate 'create type ' || gc_nested_table_name || ' is table of number';
    execute immediate 'create type ' || gc_varray_name || ' is varray(1) of number';
  end;

  procedure drop_types is
  pragma autonomous_transaction;
  begin
    execute immediate 'drop type ' || gc_object_name;
    execute immediate 'drop type ' || gc_nested_table_name;
    execute immediate 'drop type ' || gc_varray_name;
  end;

  procedure blob_not_null is
  begin
    --Act
    execute immediate ut3_tester_helper.expectations_helper.unary_expectation_block( 'not_to_be_null', 'blob', 'to_blob(''abc'')' );
    --Assert
    ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_equal(0);
  end;

  procedure blob_0_length is
  begin
    --Act
    execute immediate ut3_tester_helper.expectations_helper.unary_expectation_block( 'not_to_be_null', 'blob', 'empty_blob()' );
    --Assert
    ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_equal(0);
  end;

  procedure boolean_not_null is
  begin
    --Act
    execute immediate ut3_tester_helper.expectations_helper.unary_expectation_block( 'not_to_be_null', 'boolean', 'true' );
    --Assert
    ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_equal(0);
  end;

  procedure clob_not_null is
  begin
    --Act
    execute immediate ut3_tester_helper.expectations_helper.unary_expectation_block( 'not_to_be_null', 'clob', 'to_clob(''abc'')' );
    --Assert
    ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_equal(0);
  end;


  procedure clob_0_length is
  begin
    --Act
    execute immediate ut3_tester_helper.expectations_helper.unary_expectation_block( 'not_to_be_null', 'clob', 'empty_clob()' );
    --Assert
    ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_equal(0);
  end;

  procedure date_not_null is
  begin
    --Act
    execute immediate ut3_tester_helper.expectations_helper.unary_expectation_block( 'not_to_be_null', 'date', 'sysdate' );
    --Assert
    ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_equal(0);
  end;

  procedure number_not_null is
  begin
    --Act
    execute immediate ut3_tester_helper.expectations_helper.unary_expectation_block( 'not_to_be_null', 'number', '1234' );
    --Assert
    ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_equal(0);
  end;

  procedure timestamp_not_null is
  begin
    --Act
    execute immediate ut3_tester_helper.expectations_helper.unary_expectation_block( 'not_to_be_null', 'timestamp', 'systimestamp' );
    --Assert
    ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_equal(0);
  end;

  procedure timestamp_with_ltz_not_null is
  begin
    --Act
    execute immediate ut3_tester_helper.expectations_helper.unary_expectation_block(
      'not_to_be_null', 'timestamp with local time zone', 'systimestamp'
    );
    --Assert
    ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_equal(0);
  end;

  procedure timestamp_with_tz_not_null is
  begin
    --Act
    execute immediate ut3_tester_helper.expectations_helper.unary_expectation_block( 'not_to_be_null', 'timestamp with time zone',
                                                                    'systimestamp' );
    --Assert
    ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_equal(0);
  end;

  procedure varchar2_not_null is
  begin
    --Act
    execute immediate ut3_tester_helper.expectations_helper.unary_expectation_block( 'not_to_be_null', 'varchar2(4000)', '''abc''' );
    --Assert
    ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_equal(0);
  end;

  procedure initialized_object is
  begin
    --Act
    execute immediate ut3_tester_helper.expectations_helper.unary_expectation_object_block(
      'not_to_be_null', gc_object_name, gc_object_name || '(1)', 'object'
    );
    --Assert
    ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_equal(0);
  end;

  procedure initialized_nested_table is
  begin
    --Act
    execute immediate ut3_tester_helper.expectations_helper.unary_expectation_object_block(
      'not_to_be_null', gc_nested_table_name, gc_nested_table_name || '()', 'collection'
    );
    --Assert
    ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_equal(0);
  end;

  procedure initialized_varray is
  begin
    --Act
    execute immediate ut3_tester_helper.expectations_helper.unary_expectation_object_block(
      'not_to_be_null', gc_varray_name, gc_varray_name || '()', 'collection'
    );
    --Assert
    ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_equal(0);
  end;

  procedure null_blob is
  begin
    --Act
    execute immediate ut3_tester_helper.expectations_helper.unary_expectation_block( 'not_to_be_null', 'blob', 'null' );
    --Assert
    ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_be_greater_than(0);
  end;

  procedure null_boolean is
  begin
    --Act
    execute immediate ut3_tester_helper.expectations_helper.unary_expectation_block( 'not_to_be_null', 'boolean', 'null' );
    --Assert
    ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_be_greater_than(0);
  end;

  procedure null_clob is
  begin
    --Act
    execute immediate ut3_tester_helper.expectations_helper.unary_expectation_block( 'not_to_be_null', 'clob', 'null' );
    --Assert
    ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_be_greater_than(0);
  end;

  procedure null_date is
  begin
    --Act
    execute immediate ut3_tester_helper.expectations_helper.unary_expectation_block( 'not_to_be_null', 'date', 'null' );
    --Assert
    ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_be_greater_than(0);
  end;

  procedure null_number is
  begin
    --Act
    execute immediate ut3_tester_helper.expectations_helper.unary_expectation_block( 'not_to_be_null', 'number', 'null' );
    --Assert
    ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_be_greater_than(0);
  end;

  procedure null_timestamp is
  begin
    --Act
    execute immediate ut3_tester_helper.expectations_helper.unary_expectation_block( 'not_to_be_null', 'timestamp', 'null' );
    --Assert
    ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_be_greater_than(0);
  end;

  procedure null_timestamp_with_ltz is
  begin
    --Act
    execute immediate ut3_tester_helper.expectations_helper.unary_expectation_block(
      'not_to_be_null', 'timestamp with local time zone', 'null'
    );
    --Assert
    ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_be_greater_than(0);
  end;

  procedure null_timestamp_with_tz is
  begin
    --Act
    execute immediate ut3_tester_helper.expectations_helper.unary_expectation_block(
      'not_to_be_null', 'timestamp with time zone', 'null'
    );
    --Assert
    ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_be_greater_than(0);
  end;

  procedure null_varchar2 is
  begin
    --Act
    execute immediate ut3_tester_helper.expectations_helper.unary_expectation_block( 'not_to_be_null', 'varchar2(4000)', 'null' );
    --Assert
    ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_be_greater_than(0);
  end;

  procedure null_anydata is
  begin
    --Act
    execute immediate ut3_tester_helper.expectations_helper.unary_expectation_block( 'not_to_be_null', 'anydata', 'null' );
    --Assert
    ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_be_greater_than(0);
  end;

  procedure uninit_object_in_anydata is
  begin
    --Act
    execute immediate ut3_tester_helper.expectations_helper.unary_expectation_object_block(
      'not_to_be_null', gc_object_name, 'null', 'object'
    );
    --Assert
    ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_be_greater_than(0);
  end;

  procedure uninit_nested_table_in_anydata is
  begin
    --Act
    execute immediate ut3_tester_helper.expectations_helper.unary_expectation_object_block(
      'not_to_be_null', gc_nested_table_name, 'null', 'collection'
    );
    --Assert
    ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_be_greater_than(0);
  end;

  procedure uninit_varray_in_anydata is
  begin
    --Act
    execute immediate ut3_tester_helper.expectations_helper.unary_expectation_object_block(
        'not_to_be_null', gc_varray_name, 'null', 'collection'
    );
    --Assert
    ut.expect(ut3_tester_helper.main_helper.get_failed_expectations_num).to_be_greater_than(0);
  end;

end test_expect_not_to_be_null;
/
