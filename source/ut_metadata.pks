create or replace package ut_metadata 
as
/*
  package: ut_metadata
  
  Common place for all code that reads from the system tables.

*/

/*
  function: package_valid
  
  check if package exists and is VALID.

*/
function package_valid   (a_owner_name varchar2,a_package_name in varchar2) return boolean;
  
/*
  function: procedure_exists
  
  check if package exists and is VALID and contains the given procedure.

*/
function procedure_exists(a_owner_name varchar2,a_package_name in varchar2, a_procedure_name in varchar2) return boolean;

end ut_metadata;

