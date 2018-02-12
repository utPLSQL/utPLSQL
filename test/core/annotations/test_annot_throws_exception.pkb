create or replace package body test_annot_throws_exception
is
  g_tests_results ut3.ut_varchar2_list;
  
  procedure recolect_tests_results is
    pragma autonomous_transaction;

    l_package_spec VARCHAR2(32737);
    l_package_body VARCHAR2(32737);
    l_drop_statment VARCHAR2(32737);
  begin
    l_package_spec := '
        create package annotated_package_with_throws is
            --%suite(Dummy package to test annotation throws)

            --%test(Throws same annoted exception)
            --%throws(-20145)
            procedure raised_same_exception;

            --%test(Throws one of the listed exceptions)
            --%throws(-20145,-20146, -20189 ,-20563)
            procedure raised_one_listed_exception;

            --%test(Throws diff exception)
            --%throws(-20144)
            procedure raised_diff_exception;

            --%test(Throws empty)
            --%throws()
            procedure empty_throws;

            --%test(Ignores when only bad parameters are passed1)
            --%throws(hello,784#,0-=234,,u1234)
            procedure bad_paramters_with_except;

            --%test(Ignores when only bad parameters are passed, the test does not raise a exception and it shows successful test)
            --%throws(hello,784#,0-=234,,u1234)
            procedure bad_paramters_without_except;

            --%test(Detects a valid exception number within many invalid ones)
            --%throws(7894562, operaqk, -=1, -1, pow74d, posdfk3)
            procedure one_valid_exception_number;

            --%test(Givess failure when a exception is expected and nothing is thrown)
            --%throws(-20459, -20136, -20145)
            procedure nothing_thrown;
        end;
    ';

    l_package_body := '
        create package body annotated_package_with_throws is
            procedure raised_same_exception is
            begin
                raise_application_error(-20145, ''Test error'');
            end;

            procedure raised_one_listed_exception is
            begin
                raise_application_error(-20189, ''Test error'');
            end;

            procedure raised_diff_exception is
            begin
                raise_application_error(-20143, ''Test error'');
            end;

            procedure empty_throws is
            begin
                raise_application_error(-20143, ''Test error'');
            end;

            procedure bad_paramters_with_except is
            begin
                raise_application_error(-20143, ''Test error'');
            end;

            procedure bad_paramters_without_except is
            begin
                null;
            end;

            procedure one_valid_exception_number is
            begin
              raise dup_val_on_index;
            end;

            procedure nothing_thrown is
            begin
                null;
            end;
        end;
    ';

    execute immediate l_package_spec;
    execute immediate l_package_body;
    
    select * bulk collect into g_tests_results from table(ut3.ut.run(('annotated_package_with_throws')));
    
    l_drop_statment := 'drop package annotated_package_with_throws';
    execute immediate l_drop_statment;
  end;
  
  function test_result(a_test_results in ut3.ut_varchar2_list, a_procedure_name in varchar2) return varchar2 
  is 
    l_test_result varchar2(200);
    l_index integer;
    l_regexp_failure varchar2(200) := '^[ ]*[0-9]+\) '||a_procedure_name||'$';
    l_regexp_errored varchar2(200) := '^[ ]*ORA-[0-9]*:';
  begin
    if a_test_results is not null then
      l_index :=  a_test_results.first;
      
      while(l_index is not null) loop
        if regexp_like(a_test_results(l_index), l_regexp_failure) then
          if regexp_like(a_test_results(l_index + 1), l_regexp_errored) then
            l_test_result := 'ERRORED';  
            exit;
          else
            l_test_result := 'FAILED';
            exit;
          end if;
        end if;
        
        l_index := a_test_results.next(l_index);
      end loop;
      -- if nothing was found it returns SUCCESSFUL
      if l_test_result is null then
        l_test_result := 'SUCCESSFUL';  
      end if;
    end if;
    
    return l_test_result;
  end;

  procedure throws_same_annotated_except is
    l_result VARCHAR2(32737);
  begin
    --Act
    l_result := test_result(g_tests_results, 'raised_same_exception');
    --Assert
    ut.expect(l_result).to_equal('SUCCESSFUL');
  end;

  procedure throws_one_of_annotated_excpt is
    l_result VARCHAR2(32737);
  begin
    --Act
    l_result := test_result(g_tests_results, 'raised_one_listed_exception');
    --Assert
    ut.expect(l_result).to_equal('SUCCESSFUL');
  end;

  procedure throws_diff_annotated_except is
    l_result VARCHAR2(32737);
  begin
    --Act
    l_result := test_result(g_tests_results, 'raised_diff_exception');
    --Assert
    ut.expect(l_result).to_equal('FAILED');
  end;

  procedure throws_empty is
    l_result VARCHAR2(32737);
  begin
    --Act
    l_result := test_result(g_tests_results, 'empty_throws');
    --Assert
    ut.expect(l_result).to_equal('ERRORED');
  end;

  procedure bad_paramters_with_except is
    l_result VARCHAR2(32737);
  begin
    --Act
    l_result := test_result(g_tests_results, 'bad_paramters_with_except');
    --Assert
    ut.expect(l_result).to_equal('ERRORED');
  end;

  procedure bad_paramters_without_except is
    l_result VARCHAR2(32737);
  begin
    --Act
    l_result := test_result(g_tests_results, 'bad_paramters_without_except');
    --Assert
    ut.expect(l_result).to_equal('SUCCESSFUL');
  end;

  procedure one_valid_exception_number is
    l_result VARCHAR2(32737);
  begin
    --Act
    l_result := test_result(g_tests_results, 'one_valid_exception_number');
    --Assert
    ut.expect(l_result).to_equal('SUCCESSFUL');
  end;

  procedure nothing_thrown is
    l_result VARCHAR2(32737);
  begin
    --Act
    l_result := test_result(g_tests_results, 'nothing_thrown');
    --Assert
    ut.expect(l_result).to_equal('FAILED');
  end;
end;
/
