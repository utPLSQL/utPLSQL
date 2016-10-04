create or replace type ut_assertion as object
(
  data_type           varchar2(250 char),
  is_null             number(1,0),
  actual_value_string varchar2(4000 char),
  message             varchar2(4000 char),
  final member procedure build_assert_result( self in ut_assertion, a_assert_result boolean, a_assert_name varchar2,
    a_expected_value_string in varchar2, a_expected_data_type varchar2 := null),
  member procedure to_be_equal(self in ut_assertion, a_expected varchar2),
  member procedure to_be_equal(self in ut_assertion, a_expected number),
--  member procedure to_be_equal(self in ut_assertion, a_expected raw),
  final member procedure to_be_null,
  final member procedure to_be_not_null
)
not final not instantiable
/
