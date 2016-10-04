create or replace type ut_assertion as object
(
  a_data_type           varchar2(250 char),
  a_message             varchar2(4000 char),
  a_actual_value_string varchar2(4000 char),
  final member procedure build_assert_result( a_assert_result boolean, a_assert_name varchar2,
    a_expected_value_string in varchar2, a_expected_data_type varchar2 := null)
)
not final not instantiable
/
