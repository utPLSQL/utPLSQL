create or replace package body ut_metadata as

  procedure do_resolve(the_owner in out varchar2, the_object in out varchar2, a_procedure_name in out varchar2) is
    name          varchar2(200);
    context       integer;
    dblink        varchar2(200);
    part1_type    number;
    object_number number;
  begin
    name := form_name(the_owner, the_object, a_procedure_name);
  
    context := 1; --plsql
  
    dbms_utility.name_resolve(name          => name
                             ,context       => context
                             ,schema        => the_owner
                             ,part1         => the_object
                             ,part2         => a_procedure_name
                             ,dblink        => dblink
                             ,part1_type    => part1_type
                             ,object_number => object_number);
  
  end do_resolve;

  function form_name(a_owner_name varchar2, a_object varchar2, a_subprogram varchar2 default null) return varchar2 is
    name varchar2(200);
  begin
    name := a_object;
    if trim(a_owner_name) is not null then
      name := trim(a_owner_name) || '.' || name;
    end if;
    if trim(a_subprogram) is not null then
      name := name || '.' || a_subprogram;
    end if;
    return name;
  end form_name;

  function package_valid(a_owner_name varchar2, a_package_name in varchar2) return boolean as
    v_cnt         number;
    name          varchar2(200);
    schema        varchar2(200);
    part1         varchar2(200);
    part2         varchar2(200);
    dblink        varchar2(200);
    part1_type    number;
    object_number number;
  begin
  
    schema := a_owner_name;
    part1  := a_package_name;
  
    do_resolve(schema, part1, part2);
  
    select count(*)
      into v_cnt
      from all_objects
     where owner = schema
       and object_name = part1
       and object_type in ('PACKAGE', 'PACKAGE BODY')
       and status = 'VALID';
  
    -- expect both package and body to be valid
    return v_cnt = 2;
  exception
    when others then
      return false;
  end;

  function procedure_exists(a_owner_name varchar2, a_package_name in varchar2, a_procedure_name in varchar2)
    return boolean as
    v_cnt         number;
    name          varchar2(200);
    schema        varchar2(200);
    part1         varchar2(200);
    part2         varchar2(200);
    dblink        varchar2(200);
    part1_type    number;
    object_number number;
  begin
  
    schema := a_owner_name;
    part1  := a_package_name;
    part2  := a_procedure_name;
  
    do_resolve(schema, part1, part2);
  
    select count(*)
      into v_cnt
      from all_procedures
     where owner = schema
       and object_name = part1
       and procedure_name = part2;
  
    --expect one method only for the package with that name.
    return v_cnt = 1;
  exception
    when others then
      return false;
  end;

  function resolvable(the_owner in varchar2, the_object in varchar2, a_procedurename in varchar2) return boolean is
    owner          varchar2(200);
    object_name    varchar2(200);
    procedure_name varchar2(200);
  begin
    owner          := the_owner;
    object_name    := the_object;
    procedure_name := a_procedurename;
    do_resolve(owner, object_name, procedure_name);
    return true;
  exception
    when others then
      return false;
  end resolvable;
end;
/
