create or replace package expectations_helpers
is
    procedure execute_unary_expectation(a_matcher_name in varchar2,
                                            a_data_type in varchar2,
                                            a_data_value in varchar2);

    procedure execute_binary_expectation(a_matcher_name in varchar2,
                                            a_data_type_1 in varchar2,
                                            a_data_value_1 in varchar2,
                                            a_data_type_2 in varchar2,
                                            a_data_value_2 in varchar2);

    procedure test_success_expectacion;

    procedure test_failure_expectacion;
end expectations_helpers;
/
