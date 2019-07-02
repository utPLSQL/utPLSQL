create or replace package expectations as
  --%suite
  --%suitepath(utplsql.test_user)

  --%beforeall(ut3_tester_helper.main_helper.set_ut_run_context)

  --%afterall(ut3_tester_helper.main_helper.clear_ut_run_context)

  --%test(Expectations return data to screen when called standalone)
  --%aftertest(ut3_tester_helper.main_helper.set_ut_run_context)
  procedure inline_expectation_to_dbms_out;

end;
/