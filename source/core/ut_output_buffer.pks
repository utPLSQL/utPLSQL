create or replace package ut_output_buffer as

  procedure add_line_to_buffer(a_output_id varchar2, a_text varchar2);

  procedure add_to_buffer(a_output_id varchar2, a_text clob);

  procedure add_to_buffer(a_output_id varchar2, a_text varchar2);

  function get_buffer(a_output_id varchar2) return ut_varchar2_list;

  procedure flush_buffer(a_output_id varchar2);

  procedure purge;

end;
/
