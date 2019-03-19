create or replace package body test_debug_reporter as

  g_actual clob;

  procedure run_reporter is
    l_results   ut3.ut_varchar2_list;
  begin
    select *
           bulk collect into l_results
      from table(
                  ut3.ut.run(
                    'test_reporters',
                    ut3.ut_debug_reporter()
                    )
                );
    g_actual := ut3.ut_utils.table_to_clob(l_results);
  end;

  procedure includes_event_info is
    l_expected  varchar2(32767);
  begin
    l_expected := '<DEBUG_LOG>\s+' ||
        '(<DEBUG>\s+' ||
          '<TIMESTAMP>[0-9\-]+T[0-9:\.]+<\/TIMESTAMP>\s+' ||
          '<TIME_FROM_START>[0-9 \+:\.]+<\/TIME_FROM_START>\s+' ||
          '<TIME_FROM_PREVIOUS>[0-9 \+:\.]+<\/TIME_FROM_PREVIOUS>\s+' ||
          '<EVENT_NAME>\w+<\/EVENT_NAME>\s+' ||
          '<CALL_STACK>(\s|\S)+?<\/CALL_STACK>(\s|\S)+?' ||
        '<\/DEBUG>\s+)+' ||
      '<\/DEBUG_LOG>';
    ut.expect( g_actual ).to_match( l_expected, 'm' );
  end;

  procedure includes_run_info is
    l_expected  varchar2(32767);
  begin
    l_expected := '<DEBUG>(\s|\S)+?<UT_RUN_INFO>(\s|\S)+?<\/UT_RUN_INFO>\s+<\/DEBUG>';
    ut.expect( g_actual ).to_match( l_expected, 'm' );
  end;


end;
/


