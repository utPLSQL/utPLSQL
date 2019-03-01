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

  procedure do_resolve(a_owner in out nocopy varchar2, a_object in out nocopy varchar2, a_procedure_name in out nocopy varchar2) is
    l_name          varchar2(200);
    l_context       integer := 1; --plsql
    l_dblink        varchar2(200);
    l_part1_type    number;
    l_object_number number;
  begin
    l_name := form_name(a_owner, a_object, a_procedure_name);
    do_resolve(l_name,l_context,a_owner,a_object, a_procedure_name);
  end do_resolve;

  procedure do_resolve(a_fully_qualified_name in varchar2,a_context in integer,a_owner out nocopy varchar2, a_object out nocopy varchar2, 
    a_procedure_name out nocopy varchar2) is
    l_dblink        varchar2(200);
    l_part1_type    number;
    l_object_number number;
  begin
    dbms_utility.name_resolve(name          => a_fully_qualified_name
                             ,context       => a_context
                             ,schema        => a_owner
                             ,part1         => a_object
                             ,part2         => a_procedure_name
                             ,dblink        => l_dblink
                             ,part1_type    => l_part1_type
                             ,object_number => l_object_number);
  end;
  
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
    l_view_name      varchar2(200) := get_objects_view_name;
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
    l_view_name varchar2(128) := get_source_view_name();
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
    l_result              varchar2(128) := lower(a_dba_view_name);
  begin
    if not is_object_visible(a_dba_view_name) then
      l_result := replace(l_result,'dba_','all_');
    end if;
     return l_result;
  end;

  function get_source_view_name return varchar2 is
  begin
    return get_dba_view('dba_source');
  end;


  function get_objects_view_name return varchar2 is
  begin
    return get_dba_view('dba_objects');
  end;

  function user_has_execute_any_proc return boolean is
    l_ut_owner     varchar2(250) := ut_utils.ut_owner;
  begin
    return is_object_visible(l_ut_owner||'.ut_utils');
  end;

  function is_object_visible(a_object_name varchar2) return boolean is
    l_invalid_object_name exception;
    pragma exception_init(l_invalid_object_name,-44002);
  begin
    return dbms_assert.sql_object_name(a_object_name) is not null;
  exception
    when l_invalid_object_name then
      return false;
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

  function is_collection (a_anytype_code in integer) return boolean is
  begin
    return coalesce(a_anytype_code in (dbms_types.typecode_varray,dbms_types.typecode_table,dbms_types.typecode_namedcollection),false);
  end;

  function is_collection (a_owner varchar2, a_type_name varchar2) return boolean is
  begin
    return is_collection(
      get_anytype_members_info(
        get_user_defined_type(a_owner, a_type_name)
        ).type_code
    );
  end;

  function get_attr_elem_info( a_anytype anytype, a_pos pls_integer := null )
    return t_anytype_elem_info_rec is
    l_result  t_anytype_elem_info_rec;
  begin
    if a_anytype is not null then
      l_result.type_code := a_anytype.getattreleminfo(
        pos           => a_pos,
        prec          => l_result.precision,
        scale         => l_result.scale,
        len           => l_result.length,
        csid          => l_result.char_set_id,
        csfrm         => l_result.char_set_frm,
        attr_elt_type => l_result.attr_elt_type,
        aname         => l_result.attribute_name
        );
      end if;
    return l_result;
  end;

  function get_anytype_members_info( a_anytype anytype )
    return t_anytype_members_rec is
    l_result  t_anytype_members_rec;
  begin
    if a_anytype is not null then
      l_result.type_code := a_anytype.getinfo(
        prec        => l_result.precision,
        scale       => l_result.scale,
        len         => l_result.length,
        csid        => l_result.char_set_id,
        csfrm       => l_result.char_set_frm,
        schema_name => l_result.schema_name,
        type_name   => l_result.type_name,
        version     => l_result.version,
        numelems    => l_result.elements_count
        );
      end if;
    return l_result;
  end;

  function get_user_defined_type(a_owner varchar2, a_type_name varchar2) return anytype is
    l_anytype anytype;
    not_found exception;
    pragma exception_init(not_found,-22303);
  begin
    if a_type_name is not null then
      begin
        if ut_metadata.is_object_visible('GETANYTYPEFROMPERSISTENT') then
          execute immediate 'begin :l_anytype := getanytypefrompersistent( :a_owner, :a_type_name ); end;'
            using out l_anytype, in nvl(a_owner,sys_context('userenv','current_schema')), in a_type_name;
          else
            execute immediate 'begin :l_anytype := anytype.getpersistent( :a_owner, :a_type_name ); end;'
              using out l_anytype, in nvl(a_owner,sys_context('userenv','current_schema')), in a_type_name;
          end if;
      exception
        when not_found then
          null;
      end;
      end if;
    return l_anytype;
  end;

  function get_collection_element(a_anydata in anydata) return varchar2 
  is
    l_anytype anytype;
    l_nested_type   t_anytype_members_rec;
    l_elements_rec  t_anytype_elem_info_rec;
    l_type_code integer;
  begin
    l_type_code := a_anydata.gettype(l_anytype);
    if is_collection(l_type_code) then
      l_elements_rec := get_attr_elem_info(l_anytype);
      if l_elements_rec.attr_elt_type is null then
        l_nested_type := get_anytype_members_info(l_anytype);
      else
        l_nested_type := get_anytype_members_info(l_elements_rec.attr_elt_type);
      end if;
    end if;
    return l_nested_type.schema_name || '.' ||l_nested_type.type_name;
  end; 
  
  function has_collection_members (a_anydata in anydata) return boolean is
    l_anytype anytype;
    l_nested_type   t_anytype_members_rec;
    l_elements_rec  t_anytype_elem_info_rec;
    l_type_code integer;
  begin
    l_type_code := a_anydata.gettype(l_anytype);
    l_elements_rec := get_attr_elem_info(l_anytype);
    if l_elements_rec.attr_elt_type is null then
      return false;
    else 
      return true;
    end if;
  end;

  function get_anydata_typename(a_data_value anydata) return varchar2
  is
  begin
    return case when a_data_value is not null then lower(a_data_value.gettypename()) else 'undefined' end;
  end;
  
  function is_anytype_null(a_value in anydata, a_compound_type in varchar2) return number is
    l_result integer := 0;
    l_anydata_sql varchar2(4000);
  begin
     if a_value is not null then
     l_anydata_sql := '
        declare
          l_data '||get_anydata_typename(a_value)||';
          l_value anydata := :a_value;
          l_status integer;
        begin
          l_status := l_value.get'||a_compound_type||'(l_data);
          :l_data_is_null := case when l_data is null then 1 else 0 end; 
        end;';
        execute immediate l_anydata_sql using in a_value, out l_result; 
    else
      l_result := 1;
    end if;
    return l_result;
  end; 

end;
/
