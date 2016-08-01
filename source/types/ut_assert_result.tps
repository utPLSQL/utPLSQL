create or replace type ut_assert_result force under ut_object
(
  message varchar2(4000 char),

  constructor function ut_assert_result(a_result varchar2, a_message varchar2, a_name varchar2 default null)
    return self as result
)
not final
/
