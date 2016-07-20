create or replace package ut_metadata as
  /*
    package: ut_metadata
  
    Common place for all code that reads from the system tables.
  
  */
	
	/*
	  function form_name
			
		forms correct object/subprogram name to call as owner.object[.subprogram]
		
  */
	
	function form_name(a_owner_name varchar2, a_object varchar2, a_subprogram varchar2 default null) return varchar2;

  /*
    function: package_valid
  
    check if package exists and is VALID.
  
  */
  function package_valid(a_owner_name varchar2, a_package_name in varchar2) return boolean;

  /*
    function: procedure_exists
  
    check if package exists and is VALID and contains the given procedure.
  
  */
  function procedure_exists(a_owner_name varchar2, a_package_name in varchar2, a_procedure_name in varchar2)
    return boolean;

  /*
	  function: do_resolve
		
		resolves full subprogram name using dbms_utility.name_resolve
	*/
  function do_resolve(the_owner in varchar2, the_object in varchar2, a_procedurename in varchar2) return boolean;

end ut_metadata;
/
