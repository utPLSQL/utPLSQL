create or replace package body ut_metadata as
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

  type t_cache is table of all_source.text%type;
  g_source_cache t_cache;
  g_cached_object varchar2(500);
  ------------------------------
  --public definitions

  procedure do_resolve(a_owner in out nocopy varchar2, a_object in out nocopy varchar2) is
    l_procedure_name  varchar2(200);
  begin
    do_resolve(a_owner, a_object, l_procedure_name );
  end do_resolve;

  procedure do_resolve(a_owner in out nocopy varchar2, a_object in out nocopy varchar2, a_procedure_name in out nocopy varchar2) is
    l_name          varchar2(200);
    l_context       integer := 1; --plsql
    l_dblink        varchar2(200);
    l_part1_type    number;
    l_object_number number;
  begin
    l_name := form_name(a_owner, a_object, a_procedure_name);

    dbms_utility.name_resolve(name          => l_name
                             ,context       => l_context
                             ,schema        => a_owner
                             ,part1         => a_object
                             ,part2         => a_procedure_name
                             ,dblink        => l_dblink
                             ,part1_type    => l_part1_type
                             ,object_number => l_object_number);

  end do_resolve;

  function form_name(a_owner_name varchar2, a_object varchar2, a_subprogram varchar2 default null) return varchar2 is
    l_name varchar2(200);
  begin
    l_name := trim(a_object);
    if trim(a_owner_name) is not null then
      l_name := trim(a_owner_name) || '.' || l_name;
    end if;
    if trim(a_subprogram) is not null then
      l_name := l_name || '.' || trim(a_subprogram);
    end if;
    return l_name;
  end form_name;

  function package_valid(a_owner_name varchar2, a_package_name in varchar2) return boolean as
    l_cnt            number;
    l_schema         varchar2(200);
    l_package_name   varchar2(200);
    l_procedure_name varchar2(200);
    l_view_name      varchar2(200) := get_dba_view('dba_objects');
  begin

    l_schema       := a_owner_name;
    l_package_name := a_package_name;

    do_resolve(l_schema, l_package_name, l_procedure_name);

    execute immediate q'[select count(decode(status, 'VALID', 1, null)) / count(*)
      from ]'||l_view_name||q'[
     where owner = :l_schema
       and object_name = :l_package_name
       and object_type in ('PACKAGE')]'
    into l_cnt using l_schema, l_package_name;

    -- expect both package and body to be valid
    return l_cnt = 1;
  exception
    when others then
      return false;
  end;

  function procedure_exists(a_owner_name varchar2, a_package_name in varchar2, a_procedure_name in varchar2)
    return boolean as
    l_cnt            number;
    l_schema         varchar2(200);
    l_package_name   varchar2(200);
    l_procedure_name varchar2(200);
    l_view_name      varchar2(200) := get_dba_view('dba_procedures');
  begin

    l_schema         := a_owner_name;
    l_package_name   := a_package_name;
    l_procedure_name := a_procedure_name;

    do_resolve(l_schema, l_package_name, l_procedure_name);

    execute immediate
      'select count(*) from '||l_view_name
      ||' where owner = :l_schema and object_name = :l_package_name and procedure_name = :l_procedure_name'
    into l_cnt using l_schema, l_package_name, l_procedure_name;

    --expect one method only for the package with that name.
    return l_cnt = 1;
  exception
    when others then
      return false;
  end;

  function get_source_definition_line(a_owner varchar2, a_object_name varchar2, a_line_no integer) return varchar2 is
    l_cursor sys_refcursor;
    l_view_name varchar2(128) := get_dba_view('dba_source');
    l_line all_source.text%type;
    c_key  constant varchar2(500) := a_owner || '.' || a_object_name;
  begin
    if not nvl(c_key = g_cached_object, false) then
      g_cached_object := c_key;
      execute immediate
      'select trim(text) text
        from '||l_view_name||q'[ s
       where s.owner = :a_owner
         and s.name = :a_object_name
         /*skip the declarations, consider only definitions*/
         and s.type not in ('PACKAGE', 'TYPE')
       order by line]'
      bulk collect into g_source_cache
      using a_owner, a_object_name;
    end if;

    if g_source_cache.exists(a_line_no) then
      l_line := g_source_cache(a_line_no);
    end if;
    return l_line;
  end;

  procedure reset_source_definition_cache is
  begin
    g_source_cache := null;
    g_cached_object := null;
  end;

  function get_dba_view(a_dba_view_name varchar2) return varchar2 is
    l_invalid_object_name exception;
    l_result              varchar2(128) := lower(a_dba_view_name);
    pragma exception_init(l_invalid_object_name,-44002);
  begin
    l_result := dbms_assert.sql_object_name(l_result);
    return l_result;
  exception
    when l_invalid_object_name then
      return replace(l_result,'dba_','all_');
  end;

  function package_exists_in_cur_schema(a_object_name varchar2) return boolean is
    l_cnt            number;
    c_current_schema constant all_tables.owner%type := sys_context('USERENV','CURRENT_SCHEMA');
  begin
    select count(*)
      into l_cnt
      from all_objects t
     where t.object_name = a_object_name
       and t.object_type = 'PACKAGE'
       and t.owner = c_current_schema;
    return l_cnt > 0;
  end;


end;
/
