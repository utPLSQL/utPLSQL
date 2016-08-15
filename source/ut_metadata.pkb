create or replace package body ut_metadata as

  procedure do_resolve(a_owner in out varchar2, a_object in out varchar2, a_procedure_name in out varchar2) is
    l_name          varchar2(200);
    l_context       integer;
    l_dblink        varchar2(200);
    l_part1_type    number;
    l_object_number number;
  begin
    l_name := form_name(a_owner, a_object, a_procedure_name);
  
    l_context := 1; --plsql
  
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
    l_name := a_object;
    if trim(a_owner_name) is not null then
      l_name := trim(a_owner_name) || '.' || l_name;
    end if;
    if trim(a_subprogram) is not null then
      l_name := l_name || '.' || a_subprogram;
    end if;
    return l_name;
  end form_name;

  function package_valid(a_owner_name varchar2, a_package_name in varchar2) return boolean as
    l_cnt            number;
    l_name           varchar2(200);
    l_schema         varchar2(200);
    l_package_name   varchar2(200);
    l_procedure_name varchar2(200);
  begin
  
    l_schema        := a_owner_name;
    l_package_name  := a_package_name;
  
    do_resolve(l_schema, l_package_name, l_procedure_name);
  
    select count(decode(status, 'VALID', 1, null)) / count(*)
      into l_cnt
      from all_objects
     where owner = l_schema
       and object_name = l_package_name
       and object_type in ('PACKAGE', 'PACKAGE BODY');
  
    -- expect both package and body to be valid
    return l_cnt = 1;
  exception
    when others then
      return false;
  end;

  function procedure_exists(a_owner_name varchar2, a_package_name in varchar2, a_procedure_name in varchar2)
    return boolean as
    l_cnt            number;
    l_name           varchar2(200);
    l_schema         varchar2(200);
    l_package_name   varchar2(200);
    l_procedure_name varchar2(200);
  begin
  
    l_schema         := a_owner_name;
    l_package_name   := a_package_name;
    l_procedure_name := a_procedure_name;

    do_resolve(l_schema, l_package_name, l_procedure_name);
  
    select count(*)
      into l_cnt
      from all_procedures
     where owner = l_schema
       and object_name = l_package_name
       and procedure_name = l_procedure_name;
  
    --expect one method only for the package with that name.
    return l_cnt = 1;
  exception
    when others then
      return false;
  end;

  function resolvable(a_owner in varchar2, a_object in varchar2, a_procedurename in varchar2) return boolean is
    l_owner          varchar2(200);
    l_object_name    varchar2(200);
    l_procedure_name varchar2(200);
  begin
    l_owner          := a_owner;
    l_object_name    := a_object;
    l_procedure_name := a_procedurename;
    do_resolve(l_owner, l_object_name, l_procedure_name);
    return true;
  exception
    when others then
      return false;
  end resolvable;
end;
/
