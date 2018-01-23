create or replace package expectations is

  function unary_expectation_block(
    a_matcher_name varchar2,
    a_data_type    varchar2,
    a_data_value   varchar2
  ) return varchar2;

  function unary_expectation_object_block(
    a_matcher_name varchar2,
    a_object_name  varchar2,
    a_object_value varchar2,
    a_object_type  varchar2
  ) return varchar2;

  function binary_expectation_block(
    a_matcher_name       varchar2,
    a_actual_data_type   varchar2,
    a_actual_data        varchar2,
    a_expected_data_type varchar2,
    a_expected_data      varchar2
  ) return varchar2;

  function failed_expectations_data return anydata;

  procedure cleanup_expectations;

end expectations;
/
