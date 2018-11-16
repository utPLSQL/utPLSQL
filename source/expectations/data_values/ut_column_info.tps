create or replace type ut_column_info force authid current_user as object
(
   xml_valid_name  varchar2(100),
   hashed_name     raw(30),
   column_name     varchar2(100),
   column_type     varchar2(100),
   column_schema   varchar2(100),
   column_prec     integer,
   column_len      integer,
   column_scale    integer,
   is_sql_diffable number(1, 0),
   is_collection   number(1, 0),
   is_user_defined number(1, 0),
   member function get_data_type(a_type_code in integer,a_user_defined in boolean) return varchar2,
   member procedure init(self            in out nocopy ut_column_info,
                         a_col_type        binary_integer,
                         a_col_name        varchar2,
                         a_col_schema_name varchar2,
                         a_col_type_name   varchar2,
                         a_col_prec        integer,
                         a_col_scale       integer,
                         a_col_max_len     integer,
                         a_dbms_sql_desc   boolean := false,
                         a_parent_name     varchar2 := null)
)
not final not instantiable
/
