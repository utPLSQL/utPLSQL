create global temporary table ut_cursor_data_diff(
  row_no           integer
  constraint ut_cursor_data_diff_pk primary key(row_no)
) on commit preserve rows;
