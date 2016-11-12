create or replace package ut_teamcity_reporter_printer is

  procedure block_opened(a_name varchar2, a_flow_id varchar2 default null);
  procedure block_closed(a_name varchar2, a_flow_id varchar2 default null);

  procedure test_suite_started(a_suite_name varchar2, a_flow_id varchar2 default null);
  procedure test_suite_finished(a_suite_name varchar2, a_flow_id varchar2 default null);

  procedure test_started(a_test_name varchar2, a_capture_standard_output boolean default null, a_flow_id varchar2 default null);
  procedure test_finished(a_test_name varchar2, a_test_duration_milisec number default null, a_flow_id varchar2 default null);
  procedure test_ignored(a_test_name varchar2, a_flow_id varchar2 default null);
  procedure test_failed(a_test_name varchar2, a_msg in varchar2 default null, a_details varchar2 default null, a_flow_id varchar2 default null);
  procedure test_std_out(a_test_name varchar2, a_out in varchar2, a_flow_id in varchar2 default null);
  procedure test_std_err(a_test_name varchar2, a_out in varchar2, a_flow_id in varchar2 default null);

  procedure custom_message(a_text in varchar2, a_status in varchar2, a_error_deatils in varchar2 default null, a_flow_id in varchar2 default null);

end ut_teamcity_reporter_printer;
/
