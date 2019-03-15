create or replace trigger ut_trigger_annotation_parsing
  after create or alter or drop
on database
begin
  if    ora_dict_obj_type = 'PACKAGE'
     or (ora_dict_obj_owner = UPPER('&&UT3_OWNER')
         and ora_dict_obj_name = 'UT3_TRIGGER_ALIVE'
         and ora_dict_obj_type = 'SYNONYM')
  then
    execute immediate 'begin ut_annotation_manager.trigger_obj_annotation_rebuild; end;';
  end if;
exception
  when others then null;
end;
/
