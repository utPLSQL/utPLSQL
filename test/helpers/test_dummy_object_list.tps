create or replace type test_dummy_object_list as table of test_dummy_object
/

grant execute on test_dummy_object_list to ut3$user#;