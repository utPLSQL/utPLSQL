BEGIN
  null;
  $if dbms_db_version.version < 21 $then
    dbms_output.put_line('Installing json structures specs for native json.');
    execute immediate  q'[create or replace noneditionable TYPE JSON FORCE AUTHID CURRENT_USER AS OBJECT(
   dummyobjt NUMBER
) NOT FINAL NOT INSTANTIABLE;]';   
  $end

END;
/