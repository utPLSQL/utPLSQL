create or replace package body ut_metadata 
as

  function package_valid(a_owner_name varchar2,a_package_name in varchar2) return boolean
  as
    v_cnt integer;
  begin
  --maybe use DBMS_UTILITY.NAME_RESOLVE first
  
    select 
        count(*) into v_cnt
    from
        all_objects
    where
        owner = a_owner_name
        and object_name = a_package_name
        and object_type in ('PACKAGE','PACKAGE BODY')
        and status = 'VALID';
    
    -- expect both package and body to be valid
    return v_cnt = 2;    
  end;
  
  function procedure_exists(a_owner_name varchar2,
                            a_package_name in varchar2,
                            a_procedure_name in varchar2) return boolean
  as
    v_cnt integer;
  Begin
   If A_Owner_Name Is Null Or A_Package_Name Is Null Or A_Procedure_Name Is Null Then
      Return False;
   end if;
    select 
        count(*) into v_cnt 
    from 
        all_procedures
    where 
        owner = a_owner_name
        and object_name = a_package_name
        and procedure_name = a_procedure_name;
    --expect one method only for the package with that name.
    return v_cnt = 1;
  end;                      
end;  