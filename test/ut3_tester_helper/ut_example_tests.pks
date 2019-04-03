create or replace package ut_example_tests is
  g_number  number;
  
  procedure create_synonym;
  procedure drop_synonym;
  
  procedure set_g_number_0;
  procedure add_1_to_g_number;
  procedure failing_procedure;
  procedure ut_commit_test;
end;
/
