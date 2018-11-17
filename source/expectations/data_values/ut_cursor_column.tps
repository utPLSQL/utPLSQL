create or replace type ut_cursor_column force authid current_user as object
(
   parent_name     varchar2(100),
   access_path     varchar2(500),
   nested_name     raw(30),
   hierarchy_level number,
   column_position number,
   xml_valid_name  varchar2(100),
   column_name     varchar2(100),
   column_type     varchar2(100),
   column_type_name varchar2(100),
   column_schema   varchar2(100),
   column_prec     integer,
   column_len      integer,
   column_scale    integer,
   is_sql_diffable number(1, 0),
   is_collection   number(1, 0),
   is_user_defined number(1, 0),

   member procedure init(self in out nocopy ut_cursor_column,
     a_col_name varchar2, a_col_schema_name varchar2,
     a_col_type_name varchar2, a_col_prec integer, a_col_scale integer,
     a_col_max_len integer, a_parent_name varchar2 := null, a_hierarchy_level number := 1,
     a_col_position number, a_col_type in varchar2),
     
   constructor function ut_cursor_column( self in out nocopy ut_cursor_column,
     a_col_name varchar2, a_col_schema_name varchar2,
     a_col_type_name varchar2, a_col_prec integer, a_col_scale integer,
     a_col_max_len integer, a_parent_name varchar2 := null, a_hierarchy_level number := 1,
     a_col_position number, a_col_type in varchar2) 
   return self as result
)
/
