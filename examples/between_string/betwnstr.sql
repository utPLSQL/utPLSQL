create or replace function betwnstr( a_string varchar2, a_start_pos integer, a_end_pos integer ) return varchar2 is
  l_start_pos pls_integer := a_start_pos;
begin
  if l_start_pos = 0 then
    l_start_pos := 1;
  end if;
  return substr( a_string, l_start_pos, a_end_pos - l_start_pos + 1);
end;
/
