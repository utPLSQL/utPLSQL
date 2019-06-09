create or replace trigger ut_trigger_annotation_parsing
  after create or alter or drop
on database
begin
  if (ora_dict_obj_owner = UPPER('&&UT3_OWNER')
    and ora_dict_obj_name = 'UT3_TRIGGER_ALIVE'
    and ora_dict_obj_type = 'SYNONYM')
  then
    execute immediate 'begin ut_trigger_check.is_alive(); end;';
  elsif   ( ora_dict_obj_type in ('PACKAGE','PROCEDURE','FUNCTION','TYPE')
        and ora_dict_obj_owner
          not in (
            'ANONYMOUS','APPQOSSYS','AUDSYS','DBSFWUSER','DBSNMP','DIP','GGSYS','GSMADMIN_INTERNAL',
            'GSMCATUSER','GSMUSER','ORACLE_OCM','OUTLN','REMOTE_SCHEDULER_AGENT','SYS','SYS$UMF',
            'SYSBACKUP','SYSDG','SYSKM','SYSRAC','SYSTEM','WMSYS','XDB','XS$NULL')
        and not (ora_dict_obj_type = 'TYPE' and ora_dict_obj_name like 'SYS\_PLSQL\_%' escape '\')
        )
  then
    execute immediate 'begin ut_annotation_manager.trigger_obj_annotation_rebuild; end;';
  end if;
exception
  when others then null;
end;
/
