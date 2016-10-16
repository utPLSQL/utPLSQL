create or replace type ut_assertion as object
(
  actual_data         ut_data_value,
  message             varchar2(4000 char),
  final member procedure add_assert_result( self in ut_assertion, a_assert_result boolean, a_assert_name varchar2,
    a_assert_info varchar2, a_expected_value_string in varchar2 := null, a_expected_data_type varchar2 := null),
  member procedure to_equal(self in ut_assertion, a_expected anydata, a_nulls_are_equal boolean := null),
  member procedure to_equal(self in ut_assertion, a_expected blob, a_nulls_are_equal boolean := null),
  member procedure to_equal(self in ut_assertion, a_expected boolean, a_nulls_are_equal boolean := null),
  member procedure to_equal(self in ut_assertion, a_expected clob, a_nulls_are_equal boolean := null),
  member procedure to_equal(self in ut_assertion, a_expected date, a_nulls_are_equal boolean := null),
  member procedure to_equal(self in ut_assertion, a_expected number, a_nulls_are_equal boolean := null),
  member procedure to_equal(self in ut_assertion, a_expected sys_refcursor, a_nulls_are_equal boolean := null),
  member procedure to_equal(self in ut_assertion, a_expected timestamp_unconstrained, a_nulls_are_equal boolean := null),
  member procedure to_equal(self in ut_assertion, a_expected timestamp_ltz_unconstrained, a_nulls_are_equal boolean := null),
  member procedure to_equal(self in ut_assertion, a_expected timestamp_tz_unconstrained, a_nulls_are_equal boolean := null),
  member procedure to_equal(self in ut_assertion, a_expected varchar2, a_nulls_are_equal boolean := null),
  final member procedure to_(self in ut_assertion, a_expectation ut_expectation),
  final member procedure not_to(self in ut_assertion, a_expectation ut_expectation),
  final member procedure to_be_null(self in ut_assertion),
  final member procedure to_be_not_null(self in ut_assertion)
)
not final not instantiable
/
