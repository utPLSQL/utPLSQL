declare
  l_exists integer;
begin
  select count(1) into l_exists from user_types where type_name = 'TEST_EVENT_OBJECT';
  if l_exists > 0 then
    execute immediate 'drop type test_event_object force';
  end if;
end;
/

create or replace type test_event_object as object (
  event_type  varchar2(1000),
  event_doc   xmltype
)
/