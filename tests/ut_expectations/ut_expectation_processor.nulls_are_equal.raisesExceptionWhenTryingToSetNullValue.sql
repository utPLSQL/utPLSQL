declare
  e_numeric_or_value_error exception;
  pragma exception_init(e_numeric_or_value_error, -6502);
  l_value boolean := null;
begin
  ut_expectation_processor.nulls_Are_equal(l_value);
  :test_result := ut_utils.tr_failure;
  exception
    when e_numeric_or_value_error then
      :test_result := ut_utils.tr_success;
end;
/
