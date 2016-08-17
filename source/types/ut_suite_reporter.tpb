create or replace type body ut_suite_reporter is

  -- Member procedures and functions
  member procedure begin_suite(self in out nocopy ut_suite_reporter, a_suite in ut_object) is
  begin
    null;
  end begin_suite;

  member procedure begin_test(self in out nocopy ut_suite_reporter, a_test in ut_object) is
  begin
    null;
  end begin_test;

  member procedure on_assert(self in out nocopy ut_suite_reporter, a_assert in ut_object) is
  begin
    null;
  end on_assert;

  member procedure end_test(self in out nocopy ut_suite_reporter, a_test in ut_object) is
  begin
    null;
  end end_test;

  member procedure end_suite(self in out nocopy ut_suite_reporter, a_suite in ut_object) is
  begin
    null;
  end end_suite;

end;
/
