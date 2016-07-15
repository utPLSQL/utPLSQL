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
  
    function single_test_setup_stmt(a_single_test in single_test) return varchar2
    Is
    Begin
      If Trim(A_Single_Test.Setup_Procedure ) Is Null or Trim(A_Single_Test.object_name ) Is Null Then Return Null; End If;

      If Trim(A_Single_Test.Owner_Name)       Is Not Null Then 
        Return Trim(A_Single_Test.Owner_Name)||'.'||A_Single_Test.Object_Name||'.'||A_Single_Test.Setup_Procedure;
      Else
        Return                                      A_Single_Test.Object_Name||'.'||A_Single_Test.Setup_Procedure;
      End If;
      
    end;
    
    Function Single_Test_Teardown_Stmt(A_Single_Test In Single_Test) Return Varchar2
    Is
    Begin
      If Trim(A_Single_Test.teardown_procedure ) Is Null or Trim(A_Single_Test.object_name ) Is Null Then Return Null; End If;

      If Trim(A_Single_Test.Owner_Name)       Is Not Null Then 
        Return Trim(A_Single_Test.Owner_Name)||'.'||A_Single_Test.Object_Name||'.'||A_Single_Test.teardown_procedure;
      Else
        Return                                      A_Single_Test.Object_Name||'.'||A_Single_Test.teardown_procedure;
      End If;    
      End;
      
      
    function single_test_test_stmt(a_single_test in single_test) return varchar2
        Is
    Begin
      If Trim(A_Single_Test.test_procedure ) Is Null or Trim(A_Single_Test.object_name ) Is Null Then Return Null; End If;

      If Trim(A_Single_Test.Owner_Name)       Is Not Null Then 
        Return Trim(A_Single_Test.Owner_Name)||'.'||A_Single_Test.Object_Name||'.'||A_Single_Test.test_procedure;
      Else
        Return                                      A_Single_Test.Object_Name||'.'||A_Single_Test.test_procedure;
      End If;
    end;
    
    
  
  function test_suite_reporter_is_valid(a_test_suite_reporter IN OUT NOCOPY test_suite_reporter) return boolean
  is
  v_retval boolean := FALSE;
  begin
   if a_test_suite_reporter.package_name is null then return false; end if;
   
   if do_resolve(a_test_suite_reporter.owner_name,a_test_suite_reporter.package_name, a_test_suite_reporter.begin_suite_procedure) then v_retval := true; end if;
   if do_resolve(a_test_suite_reporter.owner_name,a_test_suite_reporter.package_name, a_test_suite_reporter.end_suite_procedure) then v_retval := true; end if;
   if do_resolve(a_test_suite_reporter.owner_name,a_test_suite_reporter.package_name, a_test_suite_reporter.begin_test_procedure) then v_retval := true; end if;
   if do_resolve(a_test_suite_reporter.owner_name,a_test_suite_reporter.package_name, a_test_suite_reporter.end_test_procedure) then v_retval := true; end if;
   
   return v_retval; --will be true if at least one of the procedures is valid
  end;
  
    function test_suite_reporter_bs_stmt(a_test_suite_reporter in test_suite_reporter) return varchar2
        Is
    Begin
      If Trim(a_test_suite_reporter.begin_suite_procedure ) Is Null or Trim(a_test_suite_reporter.package_name ) Is Null Then Return Null; End If;

      If Trim(A_Test_Suite_Reporter.Owner_Name)       Is Not Null Then 
        Return Trim(a_test_suite_reporter.Owner_Name)||'.'||a_test_suite_reporter.package_name||'.'||a_test_suite_reporter.begin_suite_procedure||'(:suite)';
      Else
        Return                                              a_test_suite_reporter.package_name||'.'||a_test_suite_reporter.begin_suite_procedure||'(:suite)';
      End If;    
    End;
    
    function test_suite_reporter_es_stmt(a_test_suite_reporter in test_suite_reporter) return varchar2
        Is
    Begin
      If Trim(a_test_suite_reporter.end_suite_procedure ) Is Null or Trim(a_test_suite_reporter.package_name ) Is Null Then Return Null; End If;

      If Trim(A_Test_Suite_Reporter.Owner_Name)       Is Not Null Then 
        Return Trim(a_test_suite_reporter.Owner_Name)||'.'||a_test_suite_reporter.package_name||'.'||a_test_suite_reporter.end_suite_procedure||'(:suite,:results)';
      Else
        Return                                              a_test_suite_reporter.package_name||'.'||a_test_suite_reporter.end_suite_procedure||'(:suite,:results)';
      End If;    
    End;
    Function Test_Suite_Reporter_Bt_Stmt(A_Test_Suite_Reporter In Test_Suite_Reporter) Return Varchar2
        Is
    Begin
      If Trim(a_test_suite_reporter.begin_test_procedure ) Is Null or Trim(a_test_suite_reporter.package_name ) Is Null Then Return Null; End If;

      If Trim(A_Test_Suite_Reporter.Owner_Name)       Is Not Null Then 
        Return Trim(a_test_suite_reporter.Owner_Name)||'.'||a_test_suite_reporter.package_name||'.'||a_test_suite_reporter.begin_test_procedure|| '(:test,:insuite)';
      Else
        Return                                              a_test_suite_reporter.package_name||'.'||a_test_suite_reporter.begin_test_procedure|| '(:test,:insuite)';
      End If;    
    End;
    function test_suite_reporter_et_stmt(a_test_suite_reporter in test_suite_reporter) return varchar2
        Is
    Begin
      If Trim(a_test_suite_reporter.end_test_procedure ) Is Null or Trim(a_test_suite_reporter.package_name ) Is Null Then Return Null; End If;

      If Trim(A_Test_Suite_Reporter.Owner_Name)       Is Not Null Then 
        Return Trim(a_test_suite_reporter.Owner_Name)||'.'||a_test_suite_reporter.package_name||'.'||a_test_suite_reporter.end_test_procedure|| '(:test,:result,:insuite)';
      Else
        Return                                              a_test_suite_reporter.package_name||'.'||a_test_suite_reporter.end_test_procedure|| '(:test,:result,:insuite)';
      End If;    
    End;
    
end ut_types;