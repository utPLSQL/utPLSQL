--Arrange
declare
  l_clob       clob := '&1';
  l_delimiter  varchar2(1) := '&2';
  l_expected   ut_output_varchar2_list := &3;
  l_result     ut_output_varchar2_list;
  l_limit      integer := &4;
  l_result_str varchar2(32767);
  l_errors     integer := 0;
  function compare_element(a_element_id integer, a_expected ut_output_varchar2_list, a_actual ut_output_varchar2_list) return integer is
  begin
    if a_expected.exists(a_element_id) and a_actual.exists(a_element_id) then
      if a_expected(a_element_id) = a_actual(a_element_id) or a_expected(a_element_id) is null and  a_actual(a_element_id) is null then
        return 0;
      else
        dbms_output.put('a_expected('||a_element_id||')='||a_expected(a_element_id)||' | a_actual('||a_element_id||')='||a_actual(a_element_id));
      end if;
    end if;
    if not a_expected.exists(a_element_id) then
      dbms_output.put('a_expected('||a_element_id||') does not exist ');
    end if;
    if not a_actual.exists(a_element_id) then
      dbms_output.put('a_actual('||a_element_id||') does not exist ');
    end if;
    dbms_output.put_line(null);
    return 1;
  end;
begin
--Act
  select column_value bulk collect into l_result from table( ut_utils.clob_to_table(l_clob, l_delimiter, l_limit) );
  for i in 1 .. l_result.count loop
    l_result_str := l_result_str||''''||l_result(i)||''''||l_delimiter;
  end loop;
  l_result_str := rtrim(l_result_str,l_delimiter);
--Assert
  for i in 1 .. greatest(l_expected.count, l_result.count) loop
    l_errors := l_errors + compare_element(i, l_expected, l_result);
  end loop;
  if l_errors = 0 then
    :test_result := ut_utils.tr_success;
  end if;
end;
/
