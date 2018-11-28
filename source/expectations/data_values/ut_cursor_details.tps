create or replace type ut_cursor_details force authid current_user as object
(
   cursor_info ut_cursor_column_tab,
   order member function compare(a_other ut_cursor_details) return integer,
   member procedure get_anytype_members_info(a_anytype anytype, a_attribute_typecode out pls_integer,
    a_schema_name out varchar2, a_type_name out varchar2, a_len out pls_integer,a_elements_count out pls_integer),
   member procedure getattreleminfo(a_anytype anytype,a_pos pls_integer, a_attribute_typecode out pls_integer,
    a_type_name out varchar2, a_len out pls_integer),
   member function get_user_defined_type(a_owner varchar2, a_type_name varchar2) return anytype,
   constructor function ut_cursor_details(self in out nocopy ut_cursor_details,a_cursor in out nocopy sys_refcursor)
      return self as result
)
/
