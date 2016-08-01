create or replace type ut_assert_result as object
(
  result  integer(1),
  message varchar2(4000 char),

  member function result_to_char(self in ut_assert_result) return varchar2
)
not final
/
