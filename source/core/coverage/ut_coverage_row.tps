create or replace type ut_coverage_row as object (
  full_name     varchar2(500),
  owner         varchar2(250),
  name          varchar2(250),
  type          varchar2(250),
  line_number   number(38,0),
  total_occur   number(38,0)
)
/
