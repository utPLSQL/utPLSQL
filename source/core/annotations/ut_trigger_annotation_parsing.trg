create or replace trigger ut_trigger_annotation_parsing
  after create or alter or drop
on database
begin
  /*
  utPLSQL - Version 3
  Copyright 2016 - 2026 utPLSQL Project

  Licensed under the Apache License, Version 2.0 (the "License"):
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
  */
  if (ora_dict_obj_owner = UPPER('&&UT3_OWNER')
    and ora_dict_obj_name = 'UT3_TRIGGER_ALIVE'
    and ora_dict_obj_type = 'SYNONYM')
  then
    execute immediate 'begin ut_trigger_check.is_alive(); end;';
  elsif ora_dict_obj_type in ('PACKAGE','PROCEDURE','FUNCTION','TYPE')
    and not (ora_dict_obj_type = 'TYPE' and ora_dict_obj_name like 'SYS\_PLSQL\_%' escape '\')
  then
      execute immediate 'begin ut_annotation_manager.trigger_obj_annotation_rebuild; end;';
  end if;
exception
  when others then null;
end;
/
