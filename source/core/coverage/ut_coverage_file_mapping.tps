create or replace type ut_coverage_file_mapping as object(
  file_name    varchar2(4000),
  object_owner varchar2(4000),
  object_name  varchar2(4000),
  object_type  varchar2(4000)
)
/
