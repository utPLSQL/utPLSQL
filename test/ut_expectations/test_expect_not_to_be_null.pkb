create or replace package body test_expect_not_to_be_null
is

    procedure execute_expectation(a_data_type in varchar2,
                                    a_data_value in varchar2)
    is
        l_execute varchar2(32000);
    begin
         -- arrange
        l_execute := '  declare
                            l_expected '||a_data_type||' := '||a_data_value||';
                        begin
                            --act - execute the expectation
                            ut3.ut.expect(l_expected).not_to_be_null();
                        end;';

        execute immediate l_execute;
    end;

    procedure test_success_expectacion(a_data_type in varchar2,
                                    a_data_value in varchar2)
    is
    begin
        execute_expectation(a_data_type, a_data_value);

        --assert - check that expectation was executed successfully
        ut.expect(ut3.ut_expectation_processor.get_status()).to_equal(ut3.ut_utils.tr_success);

        -- cleanup
        ut3.ut_expectation_processor.clear_expectations();
    end;

    procedure test_failure_expectacion(a_data_type in varchar2,
                                    a_data_value in varchar2)
    is
    begin
        execute_expectation(a_data_type, a_data_value);

        --assert - check that expectation was a failure
        ut.expect(ut3.ut_expectation_processor.get_status()).to_equal(ut3.ut_utils.tr_failure);

        -- cleanup
        ut3.ut_expectation_processor.clear_expectations();
    end;

    procedure blob_not_null
    is
    begin
        test_success_expectacion('blob', 'to_blob(''abc'')');
    end;

    procedure blob_0_lengt
    is
    begin
        test_success_expectacion('blob', 'empty_blob()');
    end;

    procedure boolean_not_null
    is
    begin
        test_success_expectacion('boolean', 'true');
    end;

    procedure clob_not_null
    is
    begin
        test_success_expectacion('clob', 'to_clob(''abc'')');
    end;


    procedure clob_0_lengt
    is
    begin
        test_success_expectacion('clob', 'empty_clob()');
    end;

    procedure date_not_null
    is
    begin
        test_success_expectacion('date', 'sysdate');
    end;

    procedure number_not_null
    is
    begin
        test_success_expectacion('number', '1234');
    end;

    procedure timestamp_not_null
    is
    begin
        test_success_expectacion('timestamp', 'systimestamp');
    end;

    procedure timestamp_with_ltz_not_null
    is
    begin
        test_success_expectacion('timestamp with local time zone', 'systimestamp');
    end;

    procedure timestamp_with_tz_not_null
    is
    begin
        test_success_expectacion('timestamp with time zone', 'systimestamp');
    end;

    procedure varchar2_not_null
    is
    begin
        test_success_expectacion('varchar2(4000)', '''abc''');
    end;

    procedure null_blob
    is
    begin
        test_failure_expectacion('blob', 'null');
    end;


    procedure null_boolean
    is
    begin
        test_failure_expectacion('boolean', 'null');
    end;


    procedure null_clob
    is
    begin
        test_failure_expectacion('clob', 'null');
    end;


    procedure null_date
    is
    begin
        test_failure_expectacion('date', 'null');
    end;


    procedure null_number
    is
    begin
        test_failure_expectacion('number', 'null');
    end;


    procedure null_timestamp
    is
    begin
        test_failure_expectacion('timestamp', 'null');
    end;


    procedure null_timestamp_with_ltz
    is
    begin
        test_failure_expectacion('timestamp with local time zone', 'null');
    end;


    procedure null_timestamp_with_tz
    is
    begin
        test_failure_expectacion('timestamp with time zone', 'null');
    end;


    procedure null_varchar2
    is
    begin
        test_failure_expectacion('varchar2(4000)', 'null');
    end;

end test_expect_not_to_be_null;
