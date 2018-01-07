create or replace package body expectations_helpers
is
    procedure execute_unary_expectation(a_matcher_name in varchar2,
                                            a_data_type in varchar2,
                                            a_data_value in varchar2)
    is
        l_execute varchar2(32000);
    begin
        l_execute := '  declare
                            l_expected '||a_data_type||' := '||a_data_value||';
                        begin
                            --act - execute the expectation
                            ut3.ut.expect(l_expected).'||a_matcher_name||'();
                        end;';

        execute immediate l_execute;
    end;

    procedure execute_binary_expectation(a_matcher_name in varchar2,
                                            a_data_type_1 in varchar2,
                                            a_data_value_1 in varchar2,
                                            a_data_type_2 in varchar2,
                                            a_data_value_2 in varchar2)
    is
        l_execute varchar2(32000);
    begin
        l_execute := '  declare
                            l_expected_1 '||a_data_type_1||' := '||a_data_value_1||';
                            l_expected_2 '||a_data_type_2||' := '||a_data_value_2||';
                        begin
                            --act - execute the expectation
                            ut3.ut.expect(l_expected_1).'||a_matcher_name||'(l_expected_2);
                        end;';

        execute immediate l_execute;
    end;

    procedure test_success_expectacion
    is
    begin
        --assert - check that expectation was a success
        ut.expect(ut3.ut_expectation_processor.get_status()).to_equal(ut3.ut_utils.tr_success);

        -- cleanup
        ut3.ut_expectation_processor.clear_expectations();
    end;

    procedure test_failure_expectacion
    is
    begin
        --assert - check that expectation was a failure
        ut.expect(ut3.ut_expectation_processor.get_status()).to_equal(ut3.ut_utils.tr_failure);

        -- cleanup
        ut3.ut_expectation_processor.clear_expectations();
    end;
end expectations_helpers;
/
