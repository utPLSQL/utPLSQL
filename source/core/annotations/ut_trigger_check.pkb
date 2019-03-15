create or replace package body ut_trigger_check is
  /*
  utPLSQL - Version 3
  Copyright 2016 - 2018 utPLSQL Project

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

  g_is_trigger_live boolean := false;

  function is_alive return boolean is
    pragma autonomous_transaction;
    l_ut_owner        varchar2(250) := ut_utils.ut_owner;
    l_is_trigger_live boolean;
  begin
    execute immediate 'create or replace synonym '||l_ut_owner||'.ut3_trigger_alive for no_object';
    l_is_trigger_live := g_is_trigger_live;
    g_is_trigger_live := false;
    return l_is_trigger_live;
  end;

  procedure is_alive is
  begin
    if ora_dict_obj_owner = 'UT3' and ora_dict_obj_name = 'UT3_TRIGGER_TEST' and ora_dict_obj_type = 'SYNONYM' then
      g_is_trigger_live := true;
    end if;
  end;

end;
/
