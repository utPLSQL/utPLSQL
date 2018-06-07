create or replace package ut_curr_usr_compound_helper authid current_user is
   
  procedure get_columns_info(
    a_cursor in out nocopy sys_refcursor,
    a_columns_info out nocopy xmltype,
    a_join_by_info out nocopy xmltype,
    a_contains_collection out nocopy number
  );

  function get_columns_info(a_cursor in out nocopy sys_refcursor,
     a_desc_user_types boolean := false) return xmltype;

  function get_user_defined_type(a_owner varchar2, a_type_name varchar2) return xmltype;

end;
/
