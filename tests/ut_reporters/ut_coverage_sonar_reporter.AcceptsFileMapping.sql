declare
  l_results ut_varchar2_list;
  l_clob    clob;
  l_expected varchar2(32767);
begin
  l_expected := '<coverage version="1">%</coverage>';
  select *
  bulk collect into l_results
  from table(
    ut.run(
      'test_reporters',
      ut_coverage_sonar_reporter(),
      a_project_file_mappings => ut_file_mapper.build_file_mappings( user, ut_varchar2_list(
        'tests/helpers/test_reporters.pkb' )
      )
    )
  );
  l_clob := ut_utils.table_to_clob(l_results);

  if l_clob like l_expected then
    :test_result := ut_utils.tr_success;
  else
    dbms_output.put_line(l_clob);
  end if;

end;
/
