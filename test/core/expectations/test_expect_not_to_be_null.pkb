create or replace package body test_expect_not_to_be_null
is
    procedure blob_not_null
    is
    begin
        expectations_helpers.execute_unary_expectation('not_to_be_null', 'blob', 'to_blob(''abc'')');
        expectations_helpers.test_success_expectacion;
    end;

    procedure blob_0_lengt
    is
    begin
        expectations_helpers.execute_unary_expectation('not_to_be_null', 'blob', 'empty_blob()');
        expectations_helpers.test_success_expectacion;
    end;

    procedure boolean_not_null
    is
    begin
        expectations_helpers.execute_unary_expectation('not_to_be_null', 'boolean', 'true');
        expectations_helpers.test_success_expectacion;
    end;

    procedure clob_not_null
    is
    begin
        expectations_helpers.execute_unary_expectation('not_to_be_null', 'clob', 'to_clob(''abc'')');
        expectations_helpers.test_success_expectacion;
    end;


    procedure clob_0_lengt
    is
    begin
        expectations_helpers.execute_unary_expectation('not_to_be_null', 'clob', 'empty_clob()');
        expectations_helpers.test_success_expectacion;
    end;

    procedure date_not_null
    is
    begin
        expectations_helpers.execute_unary_expectation('not_to_be_null', 'date', 'sysdate');
        expectations_helpers.test_success_expectacion;
    end;

    procedure number_not_null
    is
    begin
        expectations_helpers.execute_unary_expectation('not_to_be_null', 'number', '1234');
        expectations_helpers.test_success_expectacion;
    end;

    procedure timestamp_not_null
    is
    begin
        expectations_helpers.execute_unary_expectation('not_to_be_null', 'timestamp', 'systimestamp');
        expectations_helpers.test_success_expectacion;
    end;

    procedure timestamp_with_ltz_not_null
    is
    begin
        expectations_helpers.execute_unary_expectation('not_to_be_null', 'timestamp with local time zone', 'systimestamp');
        expectations_helpers.test_success_expectacion;
    end;

    procedure timestamp_with_tz_not_null
    is
    begin
        expectations_helpers.execute_unary_expectation('not_to_be_null', 'timestamp with time zone', 'systimestamp');
        expectations_helpers.test_success_expectacion;
    end;

    procedure varchar2_not_null
    is
    begin
        expectations_helpers.execute_unary_expectation('not_to_be_null', 'varchar2(4000)', '''abc''');
        expectations_helpers.test_success_expectacion;
    end;

    procedure null_blob
    is
    begin
        expectations_helpers.execute_unary_expectation('not_to_be_null', 'blob', 'null');
        expectations_helpers.test_failure_expectacion;
    end;


    procedure null_boolean
    is
    begin
        expectations_helpers.execute_unary_expectation('not_to_be_null', 'boolean', 'null');
        expectations_helpers.test_failure_expectacion;
    end;


    procedure null_clob
    is
    begin
        expectations_helpers.execute_unary_expectation('not_to_be_null', 'clob', 'null');
        expectations_helpers.test_failure_expectacion;
    end;


    procedure null_date
    is
    begin
        expectations_helpers.execute_unary_expectation('not_to_be_null', 'date', 'null');
        expectations_helpers.test_failure_expectacion;
    end;


    procedure null_number
    is
    begin
        expectations_helpers.execute_unary_expectation('not_to_be_null', 'number', 'null');
        expectations_helpers.test_failure_expectacion;
    end;


    procedure null_timestamp
    is
    begin
        expectations_helpers.execute_unary_expectation('not_to_be_null', 'timestamp', 'null');
        expectations_helpers.test_failure_expectacion;
    end;


    procedure null_timestamp_with_ltz
    is
    begin
        expectations_helpers.execute_unary_expectation('not_to_be_null', 'timestamp with local time zone', 'null');
        expectations_helpers.test_failure_expectacion;
    end;


    procedure null_timestamp_with_tz
    is
    begin
        expectations_helpers.execute_unary_expectation('not_to_be_null', 'timestamp with time zone', 'null');
        expectations_helpers.test_failure_expectacion;
    end;


    procedure null_varchar2
    is
    begin
        expectations_helpers.execute_unary_expectation('not_to_be_null', 'varchar2(4000)', 'null');
        expectations_helpers.test_failure_expectacion;
    end;

end test_expect_not_to_be_null;
/
