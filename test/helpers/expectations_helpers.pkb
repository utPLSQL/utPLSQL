create or replace package body expectations_helpers
is
    function unary_expectation_block(a_matcher_name in varchar2,
                                        a_data_type in varchar2,
                                        a_data_value in varchar2)
        return varchar2
    is
        l_execute varchar2(32000);
    begin
        l_execute := '  declare
                            l_expected '||a_data_type||' := '||a_data_value||';
                        begin
                            --act - execute the expectation
                            ut3.ut.expect(l_expected).'||a_matcher_name||'();
                        end;';

        return l_execute;
    end;

    function binary_expectation_block(a_matcher_name in varchar2,
                                        a_data_type_1 in varchar2,
                                        a_data_value_1 in varchar2,
                                        a_data_type_2 in varchar2,
                                        a_data_value_2 in varchar2)
        return varchar2
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

        return l_execute;
    end;
end expectations_helpers;
/
