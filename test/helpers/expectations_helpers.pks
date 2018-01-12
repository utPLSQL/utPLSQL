create or replace package expectations_helpers
is
    function unary_expectation_block(a_matcher_name in varchar2,
                                        a_data_type in varchar2,
                                        a_data_value in varchar2)
        return varchar2;

    function unary_expectation_object_block(a_matcher_name in varchar2,
                                            a_object_name in varchar2,
                                            a_object_value in varchar2,
                                            a_object_type in varchar2)
            return varchar2;

    function binary_expectation_block(a_matcher_name in varchar2,
                                        a_data_type_1 in varchar2,
                                        a_data_value_1 in varchar2,
                                        a_data_type_2 in varchar2,
                                        a_data_value_2 in varchar2)
        return varchar2;
end expectations_helpers;
/
