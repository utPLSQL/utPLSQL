--Arrange
declare
  l_varchar2_byte_limit integer := 32767;
  l_workaround_byte_limit integer := 24575;
  l_singlebyte_string_max_size varchar2(32767 char) := rpad('x',l_varchar2_byte_limit,'x');
  l_twobyte_character char(1 char) := 'ж';
  l_clob_multibyte clob := l_twobyte_character||l_singlebyte_string_max_size; --here we have 32769(2+32767) bytes and 32768 chars
  l_expected ut_varchar2_list := ut_varchar2_list();
  l_result   ut_varchar2_list;
begin
  l_expected.extend(2);
  l_expected(1) := l_twobyte_character||substr(l_singlebyte_string_max_size,1,l_workaround_byte_limit-1);
  l_expected(2) := substr(l_singlebyte_string_max_size,l_workaround_byte_limit-1+1);
--Act
  l_result :=  ut_utils.clob_to_table(l_clob_multibyte);
--Assert
  if l_result = l_expected then
    :test_result := ut_utils.tr_success;
  else
    dbms_output.put_line('expected: lengths '||length(l_expected(1))||' and '||length(l_expected(2))||', got lengths: '||length(l_result(1))||' and '||length(l_result(2)));
  end if;
end;
/