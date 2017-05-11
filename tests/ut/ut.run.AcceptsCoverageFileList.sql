declare
  l_output_data       dbms_output.chararr;
  l_num_lines         integer := 100000;
  l_packages_reported integer := 0;
begin
  --act
  ut.run(
    ut_sonar_test_reporter(), a_source_files => ut_varchar2_list(),
    a_test_files => ut_varchar2_list('tests/test_package_1.pkb','tests/test_package_2.pkb','tests/test_package_3.pkb')
  );
  dbms_output.get_lines( l_output_data, l_num_lines);

  for i in 1 .. l_num_lines loop
    if  l_output_data(i) like '%tests/test_package_1.pkb%' escape '\'
    or l_output_data(i) like '%tests/test_package_2.pkb%'
    or l_output_data(i) like '%tests/test_package_3.pkb%' then
      l_packages_reported := l_packages_reported + 1;
    end if;
  end loop;

  if l_packages_reported = 3 then
    :test_result := ut_utils.tr_success;
  else
    for i in 1 .. l_output_data.count loop
      dbms_output.put_line(l_output_data(i));
    end loop;
    dbms_output.put_line('Failed: not all package paths were found in the outputs. Expected 3, got '||l_packages_reported);
  end if;
end;
/
