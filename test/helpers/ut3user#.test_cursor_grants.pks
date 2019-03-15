create or replace package ut3$user#.test_cursor_grants is
  --%suite()

  procedure run;

  --%test(execute join by test)
  procedure test_join_by_cursor;
end;
/
