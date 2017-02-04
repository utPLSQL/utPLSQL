create or replace type ut_coverage_html_reporter force under ut_coverage_reporter_base
(
  coverage_id integer,
  schema_names ut_varchar2_list,
  project_name varchar2(4000),
  constructor function ut_coverage_html_reporter(self in out nocopy ut_coverage_html_reporter, a_project_name varchar2 := null, a_schema_names ut_varchar2_list := null) return self as result,
  overriding member procedure before_calling_run(self in out nocopy ut_coverage_html_reporter, a_run ut_run),
  overriding member procedure after_calling_run(self in out nocopy ut_coverage_html_reporter, a_run in ut_run)
)
/
