create or replace package body ut_reporter_execution
as

procedure begin_suite (a_reporter in ut_types.test_suite_reporter, a_suite in ut_types.test_suite)
as
Begin
    If Ut_Metadata.Package_Valid(A_Reporter.Owner_Name,A_Reporter.Package_Name) And Ut_Metadata.Procedure_Exists(A_Reporter.Owner_Name,A_Reporter.Package_Name,A_Reporter.Begin_Suite_Procedure) Then
        execute immediate 'begin '  || nvl(Ut_Types.test_suite_reporter_bs_stmt(A_Reporter),'NULL') ||'; end;' using a_suite;
    end if;
end;

procedure end_suite (a_reporter in ut_types.test_suite_reporter, a_suite in ut_types.test_suite, a_results in ut_types.test_suite_results)
as
  stmt varchar2(100);
begin
    If Ut_Metadata.Package_Valid(A_Reporter.Owner_Name,A_Reporter.Package_Name) And Ut_Metadata.Procedure_Exists(A_Reporter.Owner_Name,A_Reporter.Package_Name,A_Reporter.End_Suite_Procedure) Then
        stmt := 'begin '  || nvl(Ut_Types.test_suite_reporter_es_stmt(A_Reporter),'NULL') || '; end;'; 
        execute immediate stmt using a_suite,a_results;
    end if;
end;
procedure begin_test(a_reporter in ut_types.test_suite_reporter, a_test in ut_types.single_test,a_in_suite in boolean)
as
  stmt varchar2(100);
begin
    If Ut_Metadata.Package_Valid(A_Reporter.Owner_Name,A_Reporter.Package_Name) And Ut_Metadata.Procedure_Exists(A_Reporter.Owner_Name,A_Reporter.Package_Name,A_Reporter.Begin_Test_Procedure) Then
        stmt := 'begin '  || nvl(Ut_Types.test_suite_reporter_bt_stmt(A_Reporter),'NULL') || '; end;'; 
        execute immediate stmt using a_test, a_in_suite;
    end if;
end;
procedure end_test(a_reporter in ut_types.test_suite_reporter, a_test in ut_types.single_test, a_result ut_types.test_execution_result,a_in_suite in boolean)
as
  stmt varchar2(100);
begin
    If Ut_Metadata.Package_Valid(A_Reporter.Owner_Name,A_Reporter.Package_Name) And Ut_Metadata.Procedure_Exists(A_Reporter.Owner_Name,A_Reporter.Package_Name,A_Reporter.End_Test_Procedure) Then
        stmt := 'begin '  || nvl(Ut_Types.test_suite_reporter_et_stmt(A_Reporter),'NULL')||'; end;'; 
        execute immediate stmt using a_test,a_result,a_in_suite;
    end if;    
end;

  
procedure begin_suite (a_reporters in ut_types.test_suite_reporters, a_suite in ut_types.test_suite)
as
begin
    if a_reporters is not null then
        for i in a_reporters.first .. a_reporters.last
        loop
            begin_suite(a_reporters(i),a_suite); 
        end loop;
    end if;
end;

procedure end_suite (a_reporters in ut_types.test_suite_reporters, a_suite in ut_types.test_suite, a_results in ut_types.test_suite_results)
as
begin
    if a_reporters is not null then
        for i in a_reporters.first .. a_reporters.last
        loop
            end_suite(a_reporters(i),a_suite,a_results); 
        end loop;
    end if;      
end;
procedure begin_test(a_reporters in ut_types.test_suite_reporters, a_test in ut_types.single_test,a_in_suite in boolean)
as
begin
    if a_reporters is not null then
        for i in a_reporters.first .. a_reporters.last
        loop
            begin_test(a_reporters(i),a_test,a_in_suite); 
        end loop;
    end if;
      
end;
procedure end_test(a_reporters in ut_types.test_suite_reporters, a_test in ut_types.single_test, a_result ut_types.test_execution_result,a_in_suite in boolean)  
as
begin  
    if a_reporters is not null then
        for i in a_reporters.first .. a_reporters.last
        loop
        end_test(a_reporters(i),a_test,a_result,a_in_suite); 
        end loop;
    end if;
end;

end;
