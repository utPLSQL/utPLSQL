create or replace type body ut_output as

  final member function generate_output_id return varchar2 is
  begin
    return output_type||'-'||dbms_pipe.unique_session_name||'-'||ut_utils.to_string(cast(current_timestamp as timestamp));
  end;

end;
/
