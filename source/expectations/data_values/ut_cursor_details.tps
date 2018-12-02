create or replace type ut_cursor_details force authid current_user as object
(
   cursor_info ut_cursor_column_tab,
   is_column_order_enforced number(1,0),
   order member function compare(a_other ut_cursor_details) return integer,
   member procedure get_anytype_members_info(a_anytype anytype, a_attribute_typecode out pls_integer,
    a_schema_name out varchar2, a_type_name out varchar2, a_len out pls_integer,a_elements_count out pls_integer),
   member procedure getattreleminfo(a_anytype anytype,a_pos pls_integer, a_attribute_typecode out pls_integer,
    a_type_name out varchar2, a_len out pls_integer,a_attr_elt_type out anytype),
   member function get_anytype_of_coll_element(a_collection_owner in varchar2, a_collection_name in varchar2)
     return anytype,
   member procedure desc_compound_data(self in out nocopy ut_cursor_details,a_compound_data anytype, 
     a_parent_name in varchar2,a_level in integer,a_access_path in varchar2),
   member function get_anydata_from_compound_data(a_owner varchar2, a_type_name varchar2,a_type varchar2) return anydata,
   member function get_user_defined_type(a_owner varchar2, a_type_name varchar2) return anytype,
   member function get_user_defined_type(a_data anydata) return anytype,
   constructor function ut_cursor_details(self in out nocopy ut_cursor_details) return self as result,
   constructor function ut_cursor_details(self in out nocopy ut_cursor_details,a_cursor_number in number)
      return self as result,
   member procedure ordered_columns(self in out nocopy ut_cursor_details,a_ordered_columns boolean := false)
)
/
