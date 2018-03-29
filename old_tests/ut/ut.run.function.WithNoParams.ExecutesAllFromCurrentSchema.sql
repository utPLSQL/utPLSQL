declare
  l_output_data       ut_varchar2_list;
  l_packages_executed integer := 0;
begin
  --act
  select * bulk collect into l_output_data
    from table(ut.run());

  for i in 1 .. l_output_data.count loop
    if  l_output_data(i) like '%test\_package\_1%' escape '\'
    or l_output_data(i) like '%test_package_2%'
    or l_output_data(i) like '%test_package_3%' then
      l_packages_executed := l_packages_executed + 1;
    end if;
  end loop;

  if l_packages_executed = 3 then
    :test_result := ut_utils.gc_success;
  else
    for i in 1 .. l_output_data.count loop
      dbms_output.put_line(l_output_data(i));
    end loop;
    dbms_output.put_line('Failed: not all packages were found in the outputs. Expected 3, got '||l_packages_executed);
  end if;
end;
/
