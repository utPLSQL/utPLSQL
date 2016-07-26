create or replace type ut_assert_result force under ut_object
(
  result  integer(1),
  message varchar2(4000 char),

  constructor function ut_assert_result(a_result varchar2, a_message varchar2, a_name varchar2 default null)
    return self as result,

  member function result_to_char(self in ut_assert_result) return varchar2
)
not final
/
