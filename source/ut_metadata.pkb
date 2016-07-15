create or replace package body ut_metadata 
as
  function package_valid(a_owner_name varchar2,a_package_name in varchar2) return boolean
  as
    v_cnt integer;
  begin
    select 
        count(*) into v_cnt
    from
        all_objects
    where
        upper(owner) = upper(a_owner_name)
        and upper(object_name) = upper(a_package_name)
        and object_type in ('package','package body')
        and status = 'valid';
    
	-- expect both package and body to be valid
    return v_cnt = 2;    
  end;
  
  function procedure_exists(a_owner_name varchar2,
                         a_package_name in varchar2,
                         a_procedure_name in varchar2) return boolean
  as
    v_cnt integer;
  begin
    select 
        count(*) into v_cnt 
    from 
        all_procedures
    where 
        upper(owner) = upper(a_owner_name)
        and upper(object_name) = upper(a_package_name)
        and upper(procedure_name) = upper(a_procedure_name);
    --expect one method only for the package with that name.
    return v_cnt = 1;
  end;                      
end;  