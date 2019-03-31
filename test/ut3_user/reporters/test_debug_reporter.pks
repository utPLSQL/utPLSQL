create or replace package test_debug_reporter as

  --%suite(ut_debug_reporter)
  --%suitepath(utplsql.test_user.reporters)

  --%beforeall
  procedure run_reporter;

  --%test(Includes event info for every event)
  procedure includes_event_info;

  --%test(Includes run info)
  procedure includes_run_info;

end;
/
