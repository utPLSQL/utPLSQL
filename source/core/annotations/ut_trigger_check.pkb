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

  g_is_trigger_live    boolean := false;

  function is_alive return boolean is
    pragma autonomous_transaction;
  begin
    if not g_is_trigger_live then
      execute immediate 'create or replace synonym '||ut_utils.ut_owner||'.'||gc_check_object_name||' for no_object';
    end if;
    return g_is_trigger_live;
  end;

  procedure is_alive is
  begin
    if ora_dict_obj_owner = ut_utils.ut_owner and ora_dict_obj_name = gc_check_object_name and ora_dict_obj_type = 'SYNONYM' then
      g_is_trigger_live := true;
    else
      g_is_trigger_live := false;
    end if;
  end;

end;
/
