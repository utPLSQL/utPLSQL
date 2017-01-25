create table ut_output_buffer_tmp(
  /*
  * This table is not a global temporary table as it needs to allow cross-session data exchange
  * It is used however as a temporary table with multiple writers.
  * This is why it has very high initrans and has nologging
  */
  reporter_id    raw(32) not null,
  message_id     number(38,0) not null,
  text           varchar2(4000),
  is_finished    number(1,0) default 0 not null,
  start_date     date not null,
  constraint ut_output_buffer_tmp_pk primary key(start_date, reporter_id, message_id),
  constraint ut_output_buffer_tmp_ck check(is_finished = 0 and text is not null or is_finished = 1 and text is null)
) nologging nomonitoring initrans 100
;

create index ut_output_buffer_tmp_i on ut_output_buffer_tmp(start_date) initrans 100 nologging;
