create or replace type ut_dbms_output_suite_reporter force under ut_reporter
(

  constructor function ut_dbms_output_suite_reporter return self as result,

  static function c_dashed_line return varchar2,
  member procedure print(msg varchar2),

  overriding member procedure before_suite(self in out nocopy ut_dbms_output_suite_reporter, a_suite ut_object),
  overriding member procedure before_test(self in out nocopy ut_dbms_output_suite_reporter, a_test ut_object),
  overriding member procedure before_asserts_process(self in out nocopy ut_dbms_output_suite_reporter, a_test in ut_object),
  overriding member procedure on_assert_process(self in out nocopy ut_dbms_output_suite_reporter, a_assert ut_object),
  overriding member procedure after_test(self in out nocopy ut_dbms_output_suite_reporter, a_test ut_object),
  overriding member procedure after_suite(self in out nocopy ut_dbms_output_suite_reporter, a_suite ut_object)

)
not final
/
