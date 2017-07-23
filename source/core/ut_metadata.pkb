create or replace package body ut_metadata as
  /*
  utPLSQL - Version X.X.X.X
  Copyright 2016 - 2017 utPLSQL Project

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

  function get_package_spec_source(a_owner varchar2, a_object_name varchar2) return clob is
    l_lines   sys.dbms_preprocessor.source_lines_t;
    l_source  clob;
  begin
    begin
      l_lines := sys.dbms_preprocessor.get_post_processed_source(object_type => 'PACKAGE',
                                                                 schema_name => a_owner,
                                                                 object_name => a_object_name);

      for i in 1..l_lines.count loop
        ut_utils.append_to_clob(l_source, l_lines(i));
      end loop;

    end;
    return l_source;
  end;

  function get_source_definition_line(a_owner varchar2, a_object_name varchar2, a_line_no integer) return varchar2 is
    l_line varchar2(4000);
    l_cursor sys_refcursor;
    l_view_name varchar2(128) := get_dba_view('dba_source');
  begin
    open l_cursor for 'select text from '||l_view_name||q'[ s
       where s.owner = :a_owner and s.name = :a_object_name and s.line = :a_line_no
          -- skip the declarations, consider only definitions
         and s.type not in ('PACKAGE','TYPE')]' using a_owner, a_object_name, a_line_no;
     fetch l_cursor into l_line;
     close l_cursor;
    return ltrim(rtrim( l_line, chr(10) ));
  exception
    when no_data_found then
      return null;
  end;

  function get_dba_view(a_view_name varchar2) return varchar2 is
    l_invalid_object_name exception;
    l_result              varchar2(128) := lower(a_view_name);
    pragma exception_init(l_invalid_object_name,-44002);
  begin
    l_result := dbms_assert.sql_object_name(l_result);
    return l_result;
  exception
    when l_invalid_object_name then
      return replace(l_result,'dba_','all_');
  end;
end;
/
