--Arrange
declare
  l_clob       clob := '&1';
  l_delimiter  varchar2(1) := '&2';
  l_expected   ut_output_varchar2_list := &3;
  l_result     ut_output_varchar2_list;
  l_limit      integer := &4;
  l_result_str varchar2(32767);
begin
--Act
  select column_value
    bulk collect into l_result
    from table(ut_utils.clob_to_table(l_clob, l_delimiter, l_limit));
  for i in 1 .. l_result.count loop
    if i = l_result.count then
       l_delimiter := null;
    end if;
    l_result_str := ''''||l_result(i)||l_delimiter||'''';
  end loop;
--Assert
  if l_result = l_expected then
    :test_result := ut_utils.tr_success;
  else
    dbms_output.put_line('expected: '||q'[&3]'||', got: ut_output_varchar2_list('||l_result_str||')' );
  end if;
end;
/
