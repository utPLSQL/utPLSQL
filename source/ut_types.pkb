create or replace package body ut_types as

    
    function test_result_to_char(a_test_result test_result) return varchar2
    as
    begin
       case a_test_result
           when tr_success then return 'Success';
           when tr_failure then return 'Failure';
           when tr_error then return 'Error';
           else return 'Unknown('||a_test_result||')';
       end case; 
    end;

    function do_resolve (the_owner IN OUT dbms_quoted_id, the_object IN OUT dbms_quoted_id, a_procedurename IN OUT  dbms_quoted_id) return boolean
	is
  NAME  VARCHAR2(200);
  CONTEXT NUMBER;
  SCHEMA VARCHAR2(200);
  PART1 VARCHAR2(200);
  PART2 VARCHAR2(200);
  DBLINK VARCHAR2(200);
  PART1_TYPE NUMBER;
  OBJECT_NUMBER NUMBER;
begin
 
  name := the_object;
  if trim(the_owner)       is not null then name := trim(the_owner)||'.'||name; end if;
  if trim(a_procedurename) is not null then name := name||'.'||a_procedurename; end if;
  
  CONTEXT := 1; --plsql

  DBMS_UTILITY.NAME_RESOLVE(
    NAME => NAME,
    CONTEXT => CONTEXT,
    SCHEMA => SCHEMA,
    PART1 => PART1,
    PART2 => PART2,
    DBLINK => DBLINK,
    PART1_TYPE => PART1_TYPE,
    OBJECT_NUMBER => OBJECT_NUMBER
  );
   the_owner := SCHEMA;
   the_object := PART1;
   A_Procedurename := Part2;
   return true;
	
  exception
    when others then --replace with correct exception
		return false;
	end;
	
	

  function single_test_is_valid(a_single_test IN OUT NOCOPY single_test) return boolean
	is
  NAME  VARCHAR2(200);
  CONTEXT NUMBER;
  SCHEMA VARCHAR2(200);
  PART1 VARCHAR2(200);
  PART2 VARCHAR2(200);
  DBLINK VARCHAR2(200);
  PART1_TYPE NUMBER;
  OBJECT_NUMBER NUMBER;
Begin
  If A_Single_Test.Test_Procedure Is Null Then Return False; End If;
  
  if not do_resolve(a_single_test.owner_name,a_single_test.object_name, a_single_test.test_procedure) then return false; end if;
  
  if a_single_test.setup_procedure is not null then
   if not do_resolve(a_single_test.owner_name,a_single_test.object_name, a_single_test.setup_procedure) then return false; end if;
  end if;

  if a_single_test.teardown_procedure is not null then
   if not do_resolve(a_single_test.owner_name,a_single_test.object_name, a_single_test.teardown_procedure) then return false; end if;
  end if;
  
  Return True;
  
  End Single_Test_Is_Valid;
  
end ut_types;