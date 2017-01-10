create or replace type ut_coverage_reporter force under ut_reporter_base
(
  coverage_id integer,
  constructor function ut_coverage_reporter(self in out nocopy ut_coverage_reporter, a_output ut_output default ut_output_dbms_output()) return self as result,
  overriding member procedure before_calling_run(self in out nocopy ut_coverage_reporter, a_run ut_run),
  overriding member procedure after_calling_run(self in out nocopy ut_coverage_reporter, a_run in ut_run)
)
-- $if $$ut_trace $then
-- $end
/
