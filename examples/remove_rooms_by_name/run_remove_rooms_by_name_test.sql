@@rooms.sql
@@remove_rooms_by_name.sql
@@test_remove_rooms_by_name.pkg

set serveroutput on size unlimited format truncated

exec ut.run(user||'.test_remove_rooms_by_name');

drop package test_remove_rooms_by_name;
drop procedure remove_rooms_by_name;
drop table room_contents;
drop table rooms;

