create or replace procedure remove_rooms_by_name( l_name rooms.name%type ) is
begin
  if l_name is null then
    raise program_error;
  end if;
  delete from rooms where name like l_name;
end;
/
