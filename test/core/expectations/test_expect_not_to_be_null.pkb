create or replace package body test_expect_not_to_be_null
is
    procedure cleanup_expectations
    is
    begin
        ut3.ut_expectation_processor.clear_expectations();
    end;

    procedure blob_not_null
    is
    begin
        --Act
        execute immediate expectations_helpers.unary_expectation_block('not_to_be_null', 'blob', 'to_blob(''abc'')');
        --Assert
        ut.expect(anydata.convertCollection(ut3.ut_expectation_processor.get_failed_expectations())).to_be_empty();
    end;

    procedure blob_0_lengt
    is
    begin
        --Act
        execute immediate expectations_helpers.unary_expectation_block('not_to_be_null', 'blob', 'empty_blob()');
        --Assert
        ut.expect(anydata.convertCollection(ut3.ut_expectation_processor.get_failed_expectations())).to_be_empty();
    end;

    procedure boolean_not_null
    is
    begin
        --Act
        execute immediate expectations_helpers.unary_expectation_block('not_to_be_null', 'boolean', 'true');
        --Assert
        ut.expect(anydata.convertCollection(ut3.ut_expectation_processor.get_failed_expectations())).to_be_empty();
    end;

    procedure clob_not_null
    is
    begin
        --Act
        execute immediate expectations_helpers.unary_expectation_block('not_to_be_null', 'clob', 'to_clob(''abc'')');
        --Assert
        ut.expect(anydata.convertCollection(ut3.ut_expectation_processor.get_failed_expectations())).to_be_empty();
    end;


    procedure clob_0_lengt
    is
    begin
        --Act
        execute immediate expectations_helpers.unary_expectation_block('not_to_be_null', 'clob', 'empty_clob()');
        --Assert
        ut.expect(anydata.convertCollection(ut3.ut_expectation_processor.get_failed_expectations())).to_be_empty();
    end;

    procedure date_not_null
    is
    begin
        --Act
        execute immediate expectations_helpers.unary_expectation_block('not_to_be_null', 'date', 'sysdate');
        --Assert
        ut.expect(anydata.convertCollection(ut3.ut_expectation_processor.get_failed_expectations())).to_be_empty();
    end;

    procedure number_not_null
    is
    begin
        --Act
        execute immediate expectations_helpers.unary_expectation_block('not_to_be_null', 'number', '1234');
        --Assert
        ut.expect(anydata.convertCollection(ut3.ut_expectation_processor.get_failed_expectations())).to_be_empty();
    end;

    procedure timestamp_not_null
    is
    begin
        --Act
        execute immediate expectations_helpers.unary_expectation_block('not_to_be_null', 'timestamp', 'systimestamp');
        --Assert
        ut.expect(anydata.convertCollection(ut3.ut_expectation_processor.get_failed_expectations())).to_be_empty();
    end;

    procedure timestamp_with_ltz_not_null
    is
    begin
        --Act
        execute immediate expectations_helpers.unary_expectation_block('not_to_be_null', 'timestamp with local time zone', 'systimestamp');
        --Assert
        ut.expect(anydata.convertCollection(ut3.ut_expectation_processor.get_failed_expectations())).to_be_empty();
    end;

    procedure timestamp_with_tz_not_null
    is
    begin
        --Act
        execute immediate expectations_helpers.unary_expectation_block('not_to_be_null', 'timestamp with time zone', 'systimestamp');
        --Assert
        ut.expect(anydata.convertCollection(ut3.ut_expectation_processor.get_failed_expectations())).to_be_empty();
    end;

    procedure varchar2_not_null
    is
    begin
        --Act
        execute immediate expectations_helpers.unary_expectation_block('not_to_be_null', 'varchar2(4000)', '''abc''');
        --Assert
        ut.expect(anydata.convertCollection(ut3.ut_expectation_processor.get_failed_expectations())).to_be_empty();
    end;

    procedure null_blob
    is
    begin
        --Act
        execute immediate expectations_helpers.unary_expectation_block('not_to_be_null', 'blob', 'null');
        --Assert
        ut.expect(anydata.convertCollection(ut3.ut_expectation_processor.get_failed_expectations())).not_to_be_empty();
    end;


    procedure null_boolean
    is
    begin
        --Act
        execute immediate expectations_helpers.unary_expectation_block('not_to_be_null', 'boolean', 'null');
        --Assert
        ut.expect(anydata.convertCollection(ut3.ut_expectation_processor.get_failed_expectations())).not_to_be_empty();
    end;


    procedure null_clob
    is
    begin
        --Act
        execute immediate expectations_helpers.unary_expectation_block('not_to_be_null', 'clob', 'null');
        --Assert
        ut.expect(anydata.convertCollection(ut3.ut_expectation_processor.get_failed_expectations())).not_to_be_empty();
    end;


    procedure null_date
    is
    begin
        --Act
        execute immediate expectations_helpers.unary_expectation_block('not_to_be_null', 'date', 'null');
        --Assert
        ut.expect(anydata.convertCollection(ut3.ut_expectation_processor.get_failed_expectations())).not_to_be_empty();
    end;


    procedure null_number
    is
    begin
        --Act
        execute immediate expectations_helpers.unary_expectation_block('not_to_be_null', 'number', 'null');
        --Assert
        ut.expect(anydata.convertCollection(ut3.ut_expectation_processor.get_failed_expectations())).not_to_be_empty();
    end;


    procedure null_timestamp
    is
    begin
        --Act
        execute immediate expectations_helpers.unary_expectation_block('not_to_be_null', 'timestamp', 'null');
        --Assert
        ut.expect(anydata.convertCollection(ut3.ut_expectation_processor.get_failed_expectations())).not_to_be_empty();
    end;


    procedure null_timestamp_with_ltz
    is
    begin
        --Act
        execute immediate expectations_helpers.unary_expectation_block('not_to_be_null', 'timestamp with local time zone', 'null');
        --Assert
        ut.expect(anydata.convertCollection(ut3.ut_expectation_processor.get_failed_expectations())).not_to_be_empty();
    end;


    procedure null_timestamp_with_tz
    is
    begin
        --Act
        execute immediate expectations_helpers.unary_expectation_block('not_to_be_null', 'timestamp with time zone', 'null');
        --Assert
        ut.expect(anydata.convertCollection(ut3.ut_expectation_processor.get_failed_expectations())).not_to_be_empty();
    end;


    procedure null_varchar2
    is
    begin
        --Act
        execute immediate expectations_helpers.unary_expectation_block('not_to_be_null', 'varchar2(4000)', 'null');
        --Assert
        ut.expect(anydata.convertCollection(ut3.ut_expectation_processor.get_failed_expectations())).not_to_be_empty();
    end;

end test_expect_not_to_be_null;
/
