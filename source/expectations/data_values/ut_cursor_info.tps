create or replace type ut_cursor_info force authid current_user as object
(
   cursor_info ut_column_info_tab,
   constructor function ut_cursor_info(self in out nocopy ut_cursor_info,a_cursor in out nocopy sys_refcursor)
      return self as result
)
/
