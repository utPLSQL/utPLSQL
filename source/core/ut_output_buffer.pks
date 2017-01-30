create or replace package ut_output_buffer authid definer is

  gc_max_wait_sec             constant naturaln := 60 * 60 * 4; -- 4 hours
  gc_buffer_retention_sec     constant naturaln := 60 * 60 * 24; -- 24 hours
  gc_sleep_time               constant number(1,1) := 0.1; --sleep for 100 ms between checks

  procedure send_line(a_reporter ut_reporter_base, a_text varchar2);

  procedure close(a_reporter ut_reporter_base);

  procedure close(a_reporters ut_reporters);

  function get_lines(a_reporter_id varchar2, a_timeout_sec naturaln := gc_max_wait_sec) return ut_varchar2_list pipelined;

  function get_lines_cursor(a_reporter_id varchar2, a_timeout_sec naturaln := gc_max_wait_sec) return sys_refcursor;

  procedure lines_to_dbms_output(a_reporter_id varchar2, a_timeout_sec naturaln := gc_max_wait_sec);

  procedure cleanup_buffer(a_retention_time_sec naturaln := gc_buffer_retention_sec);

end;
/
