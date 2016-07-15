create or replace package ut_assert authid current_user
as
 current_asserts_called ut_types.assert_list := ut_types.assert_list();
 
 function current_assert_test_result return ut_types.test_result;
 procedure clear_asserts;
 procedure report_error(message in varchar2);
 procedure copy_called_asserts(newtable in out ut_types.assert_list);
 /* Just need something to play with for now */
 procedure are_equal(expected in number,actual in number);
 procedure are_equal(msg in varchar2, expected in number,actual in number); 
  

end ut_assert;
