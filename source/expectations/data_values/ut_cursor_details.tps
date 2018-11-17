create or replace type ut_cursor_details force authid current_user as object
(
   cursor_info ut_cursor_column_tab,
   member function get_anytype_attribute_count(a_anytype anytype) return pls_integer,
   member function get_user_defined_type(a_owner varchar2, a_type_name varchar2) return anytype,
   constructor function ut_cursor_details(self in out nocopy ut_cursor_details,a_cursor in out nocopy sys_refcursor)
      return self as result
)
/
