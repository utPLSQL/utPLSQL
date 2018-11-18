create or replace package ut_curr_usr_compound_helper authid current_user is
 
  function is_sql_compare_allowed(a_type_name varchar2) return boolean;
  
  function is_sql_compare_int(a_type_name varchar2) return integer;

  function is_collection (a_owner varchar2,a_type_name varchar2) return boolean;

  --TODO Depracate once switch fully to type
  procedure get_columns_info(
    a_cursor in out nocopy sys_refcursor,
    a_columns_info out nocopy xmltype,
    a_join_by_info out nocopy xmltype,
    a_contains_collection out nocopy number
  );

  function get_user_defined_type(a_owner varchar2, a_type_name varchar2) return xmltype;
  
  function extract_min_col_info(a_full_col_info xmltype) return xmltype;
  
  function get_column_type_desc(a_type_code in integer, a_dbms_sql_desc in boolean) return varchar2;

end;
/
