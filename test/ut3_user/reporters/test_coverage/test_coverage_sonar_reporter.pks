create or replace package test_coverage_sonar_reporter is

  --%suite(ut_coverge_sonar_reporter)
  --%suitepath(utplsql.test_user.reporters.test_coverage)

  --%test(reports on a project file mapped to database object)
  procedure report_on_file;

  --%test(Includes XML header with encoding when encoding provided)
  procedure check_encoding_included;

end;
/
