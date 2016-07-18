create or replace package ut_assert authid current_user as
  current_asserts_called ut_assert_list := ut_assert_list();

  function current_assert_test_result return integer;
  procedure clear_asserts;
  procedure report_error(message in varchar2);
  procedure process_asserts(newtable out ut_assert_list, result out integer);
  /* Just need something to play with for now */
  procedure are_equal(expected in number, actual in number);
  procedure are_equal(msg in varchar2, expected in number, actual in number);

end ut_assert;
/
