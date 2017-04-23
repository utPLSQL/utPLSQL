create global temporary table ut_cursor_data(
  cursor_data_guid raw(16),
  row_no           integer,
  row_data         xmltype,
  constraint ut_cursor_data_pk primary key(cursor_data_guid, row_no)
) on commit preserve rows;
