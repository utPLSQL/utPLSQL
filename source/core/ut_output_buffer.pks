create or replace package ut_output_buffer authid definer is

  gc_max_wait_sec naturaln := 60 * 60 * 4; -- 4 hours

  procedure send_line(a_reporter_id varchar2, a_text varchar2);

  procedure close(a_reporter_id varchar2);

  function get_lines(a_reporter_id varchar2, a_timeout_sec naturaln := gc_max_wait_sec) return ut_varchar2_list pipelined;

  procedure purge(a_reporters ut_reporters);

end;
/
