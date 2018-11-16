create or replace type ut_column_info_rec under ut_column_info
(
   nested_details ut_column_info_tab,
   parent_name    varchar2(100),
   member function get_anytype_attributes_info(a_anytype anytype, a_col_name varchar2)
      return ut_column_info_tab,
   member function get_user_defined_type(a_owner varchar2, a_type_name varchar2)
      return anytype,
   overriding member procedure init(self              in out nocopy ut_column_info_rec,
                                    a_col_type        binary_integer,
                                    a_col_name        varchar2,
                                    a_col_schema_name varchar2,
                                    a_col_type_name   varchar2,
                                    a_col_prec        integer,
                                    a_col_scale       integer,
                                    a_col_max_len     integer,
                                    a_dbms_sql_desc   boolean := false,
                                    a_parent_name     varchar2 := null),
   constructor function ut_column_info_rec(self            in out nocopy ut_column_info_rec,
                                          a_col_type        binary_integer,
                                          a_col_name        varchar2,
                                          a_col_schema_name varchar2,
                                          a_col_type_name   varchar2,
                                          a_col_prec        integer,
                                          a_col_scale       integer,
                                          a_col_max_len     integer,
                                          a_dbms_sql_desc   boolean := false,
                                          a_parent_name     varchar2 := null)
      return self as result
)
/
