create or replace package body test_annot_throws_exception
is
  g_tests_results clob;

  procedure recollect_tests_results is
    pragma autonomous_transaction;

    l_package_spec  varchar2(32737);
    l_package_body  varchar2(32737);
    l_exception_spec varchar2(32737);
    l_test_results  ut3_develop.ut_varchar2_list;
  begin
    l_exception_spec := q'[
        create or replace package exc_pkg is
          c_e_single_exc constant number := -20200;
          c_e_dummy      constant varchar2(10) := 'dummy';
          c_e_varch_exc  constant varchar2(10) := '-20201';
          c_e_list_1              number := -20202;
          c_e_list_2     constant number := -20203;
          c_e_diff_exc   constant number := -20204;
          c_e_mix_list   constant number := -20205;
          c_e_mix_missin constant number := -20206;
          c_e_positive   constant number :=  20207;

          e_some_exception exception;
          pragma exception_init(e_some_exception, -20207);
          
       end;]';
    
    l_package_spec := '
      create package annotated_package_with_throws is
        --%suite(Dummy package to test annotation throws)

        --%test(Throws same annotated exception)
        --%throws(-20145)
        procedure raised_same_exception;

        --%test(Throws one of the listed exceptions)
        --%throws(-20145,-20146, -20189 ,-20563)
        procedure raised_one_listed_exception;

        --%test(Leading zero is ignored in exception list)
        --%throws(-01476)
        procedure leading_0_exception_no;

        --%test(Throws diff exception)
        --%throws(-20144)
        procedure raised_diff_exception;

        --%test(Throws empty)
        --%throws()
        procedure empty_throws;

        --%test(Ignores annotation and fails when exception was thrown)
        --%throws(hello,784#,0-=234,,u1234)
        procedure bad_paramters_with_except;

        --%test(Ignores annotation and succeeds when no exception thrown)
        --%throws(hello,784#,0-=234,,u1234)
        procedure bad_paramters_without_except;

        --%test(Ignores annotation for positive exception number value)
        --%throws(20001)
        procedure positive_exception_number;

        --%test(Ignores annotation for positive exception number variable)
        --%throws(exc_pkg.c_e_positive)
        procedure positive_exception_number_var;

        --%test(Detects a valid exception number within many invalid ones)
        --%throws(7894562, operaqk, -=1, -1, pow74d, posdfk3)
        procedure one_valid_exception_number;

        --%test(Gives failure when a exception is expected and nothing is thrown)
        --%throws(-20459, -20136, -20145)
        procedure nothing_thrown;

        --%test(Single exception defined as a constant number in package)
        --%throws(exc_pkg.c_e_single_exc)
        procedure single_exc_const_pkg;

        --%test(Gives success when one of annotated exception using constant is thrown)
        --%throws(exc_pkg.c_e_list_1,exc_pkg.c_e_list_2)
        procedure list_of_exc_constant;

        --%test(Gives failure when the raised exception is different that the annotated one using variable)
        --%throws(exc_pkg.c_e_diff_exc)
        procedure fail_not_match_exc;

        --%test(Success when one of exception from mixed list of number and constant is thrown)
        --%throws(exc_pkg.c_e_mix_list,-20105)
        procedure mixed_exc_list;

        --%test(Success when match exception even if other variable on list dont exists)
        --%throws(exc_pkg.c_e_mix_missin,utter_rubbish)
        procedure mixed_list_notexi;

        --%test(Success resolve and match named exception defined in pragma exception init)
        --%throws(exc_pkg.e_some_exception)
        procedure named_exc_pragma;

        --%test(Success resolve and match oracle named exception)
        --%throws(NO_DATA_FOUND)
        procedure named_exc_ora;

        --%test(Success resolve and match oracle named exception dup val index)
        --%throws(DUP_VAL_ON_INDEX)
        procedure named_exc_ora_dup_ind;

        --%test(Success map no data 100 to -1403)
        --%throws(-1403)
        procedure nodata_exc_ora;

        --%test(Success for exception defined as varchar)
        --%throws(exc_pkg.c_e_varch_exc)
        procedure defined_varchar_exc;

        --%test(Non existing constant exception)
        --%throws(dummy.c_dummy);
        procedure non_existing_const;

        --%test(Bad exception constant)
        --%throws(exc_pkg.c_e_dummy);
        procedure bad_exc_const;
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

        procedure leading_0_exception_no is
          x integer;
        begin
          x := 1 / 0;
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

        procedure positive_exception_number is
        begin
          null;
        end;

        procedure positive_exception_number_var is
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

        procedure single_exc_const_pkg is
        begin
          raise_application_error(exc_pkg.c_e_single_exc,''Test'');
        end;

        procedure list_of_exc_constant is
        begin
          raise_application_error(exc_pkg.c_e_list_1,''Test'');
        end;

        procedure fail_not_match_exc is
        begin
          raise NO_DATA_FOUND;
        end;

        procedure mixed_exc_list is
        begin
          raise_application_error(exc_pkg.c_e_mix_list,''Test'');
        end;

        procedure mixed_list_notexi is
        begin
          raise_application_error(exc_pkg.c_e_mix_missin,''Test'');
        end;

        procedure named_exc_pragma is
        begin
          raise exc_pkg.e_some_exception;
        end;

        procedure named_exc_ora is
        begin
          raise NO_DATA_FOUND;
        end;

        procedure named_exc_ora_dup_ind is
        begin
          raise DUP_VAL_ON_INDEX;
        end;

        procedure nodata_exc_ora is
        begin
          raise NO_DATA_FOUND;
        end;

        procedure defined_varchar_exc is
        begin
          raise_application_error(exc_pkg.c_e_varch_exc,''Test'');
        end;

        procedure non_existing_const is
        begin
          raise_application_error(-20143, ''Test error'');
        end;

        procedure bad_exc_const is
        begin
          raise_application_error(-20143, ''Test error'');
        end;
           
      end;
    ';

    execute immediate l_exception_spec;
    execute immediate l_package_spec;
    execute immediate l_package_body;

    
    select * bulk collect into l_test_results from table(ut3_develop.ut.run(('annotated_package_with_throws')));

    g_tests_results := ut3_develop.ut_utils.table_to_clob(l_test_results);
  end;

  procedure throws_same_annotated_except is
  begin
    ut.expect(g_tests_results).to_match('^\s*Throws same annotated exception \[[,\.0-9]+ sec\]\s*$','m');
    ut.expect(g_tests_results).not_to_match('raised_same_exception');
  end;

  procedure throws_one_of_annotated_excpt is
  begin
    ut.expect(g_tests_results).to_match('^\s*Throws one of the listed exceptions \[[,\.0-9]+ sec\]\s*$','m');
    ut.expect(g_tests_results).not_to_match('raised_one_listed_exception');
  end;

  procedure throws_with_leading_zero is
  begin
    ut.expect(g_tests_results).to_match('^\s*Leading zero is ignored in exception list \[[,\.0-9]+ sec\]\s*$','m');
    ut.expect(g_tests_results).not_to_match('leading_0_exception_no');
  end;

  procedure throws_diff_annotated_except is
  begin
    ut.expect(g_tests_results).to_match('^\s*Throws diff exception \[[,\.0-9]+ sec\] \(FAILED - [0-9]+\)\s*$','m');
    ut.expect(g_tests_results).to_match('raised_diff_exception\s+Actual: -20143 was expected to equal: -20144\s+ORA-20143: Test error\s+ORA-06512: at "UT3_TESTER.ANNOTATED_PACKAGE_WITH_THROWS"');
  end;

  procedure throws_empty is
  begin
    ut.expect(g_tests_results).to_match('^\s*Throws empty \[[,\.0-9]+ sec\] \(FAILED - [0-9]+\)\s*$','m');
    ut.expect(g_tests_results).to_match('empty_throws\s*ORA-20143: Test error\s*ORA-06512: at "UT3_TESTER.ANNOTATED_PACKAGE_WITH_THROWS"');
  end;

  procedure bad_paramters_with_except is
  begin
    ut.expect(g_tests_results).to_match('^\s*Ignores annotation and fails when exception was thrown \[[,\.0-9]+ sec\] \(FAILED - [0-9]+\)\s*$','m');
    ut.expect(g_tests_results).to_match('bad_paramters_with_except\s*ORA-20143: Test error\s*ORA-06512: at "UT3_TESTER.ANNOTATED_PACKAGE_WITH_THROWS"');
  end;

  procedure bad_paramters_without_except is
  begin
    ut.expect(g_tests_results).to_match('^\s*Ignores annotation and succeeds when no exception thrown \[[,\.0-9]+ sec\]\s*$','m');
    ut.expect(g_tests_results).to_match('bad_paramters_without_except\s*Invalid parameter value ".*" for "--%throws" annotation. Parameter ignored.','m');
  end;

  procedure positive_exception_number is
  begin
    ut.expect(g_tests_results).to_match('^\s*Ignores annotation for positive exception number value \[[,\.0-9]+ sec\]\s*$','m');
    ut.expect(g_tests_results).to_match('positive_exception_number\s*Invalid parameter value "20001" for "--%throws" annotation. Exception value must be a negative integer. Parameter ignored.','m');
  end;

  procedure positive_exception_number_var is
  begin
    ut.expect(g_tests_results).to_match('^\s*Ignores annotation for positive exception number variable \[[,\.0-9]+ sec\]\s*$','m');
    ut.expect(g_tests_results).to_match('positive_exception_number_var\s*Invalid parameter value ".*" for "--%throws" annotation. Exception value must be a negative integer. Parameter ignored.','m');
  end;

  procedure one_valid_exception_number is
  begin
    ut.expect(g_tests_results).to_match('^\s*Detects a valid exception number within many invalid ones \[[\.0-9]+ sec\]\s*$','m');
    ut.expect(g_tests_results).to_match('one_valid_exception_number\s*Invalid parameter value ".*" for "--%throws" annotation. Parameter ignored.','m');
  end;

  procedure nothing_thrown is
  begin
    ut.expect(g_tests_results).to_match('^\s*Gives failure when a exception is expected and nothing is thrown \[[,\.0-9]+ sec\] \(FAILED - [0-9]+\)\s*$','m');
    ut.expect(g_tests_results).to_match('nothing_thrown\s*Expected one of exceptions \(-20459, -20136, -20145\) but nothing was raised.');
  end;

  procedure single_exc_const_pkg is
  begin
    ut.expect(g_tests_results).to_match('^\s*Single exception defined as a constant number in package \[[,\.0-9]+ sec\]\s*$','m');
    ut.expect(g_tests_results).not_to_match('single_exc_const_pkg');
  end;
  
  procedure list_of_exc_constant is
  begin
    ut.expect(g_tests_results).to_match('^\s*Gives success when one of annotated exception using constant is thrown \[[,\.0-9]+ sec\]\s*$','m');
    ut.expect(g_tests_results).not_to_match('list_of_exc_constant');
  end;  

  procedure fail_not_match_exc is
  begin
    ut.expect(g_tests_results).to_match('^\s*Gives failure when the raised exception is different that the annotated one using variable \[[,\.0-9]+ sec\] \(FAILED - [0-9]+\)\s*$','m');
    ut.expect(g_tests_results).to_match('fail_not_match_exc\s+Actual: -1403 was expected to equal: -20204\s+ORA-01403: no data found\s+ORA-06512: at "UT3_TESTER.ANNOTATED_PACKAGE_WITH_THROWS"');
  end;  

  procedure mixed_exc_list is
  begin
    ut.expect(g_tests_results).to_match('^\s*Success when one of exception from mixed list of number and constant is thrown \[[,\.0-9]+ sec\]\s*$','m');
    ut.expect(g_tests_results).not_to_match('mixed_exc_list');
  end;
      
  procedure mixed_list_notexi is
  begin
    ut.expect(g_tests_results).to_match('^\s*Success when match exception even if other variable on list dont exists \[[,\.0-9]+ sec\]\s*$','m');
    ut.expect(g_tests_results).to_match('mixed_list_notexi\s*Invalid parameter value "utter_rubbish" for "--%throws" annotation. Parameter ignored.','m');
  end;

  procedure named_exc_pragma is
  begin
    ut.expect(g_tests_results).to_match('^\s*Success resolve and match named exception defined in pragma exception init \[[,\.0-9]+ sec\]\s*$','m');
    ut.expect(g_tests_results).not_to_match('named_exc_pragma');
  end;
  
  procedure named_exc_ora is
  begin
    ut.expect(g_tests_results).to_match('^\s*Success resolve and match oracle named exception \[[,\.0-9]+ sec\]\s*$','m');
    ut.expect(g_tests_results).not_to_match('named_exc_ora');
  end;  

  procedure named_exc_ora_dup_ind is
  begin
    ut.expect(g_tests_results).to_match('^\s*Success resolve and match oracle named exception dup val index \[[,\.0-9]+ sec\]\s*$','m');
    ut.expect(g_tests_results).not_to_match('named_exc_ora_dup_ind');
  end;   
  
  procedure nodata_exc_ora is
  begin
    ut.expect(g_tests_results).to_match('^\s*Success map no data 100 to -1403 \[[,\.0-9]+ sec\]\s*$','m');
    ut.expect(g_tests_results).not_to_match('nodata_exc_ora');
  end; 
  
  procedure defined_varchar_exc is 
  begin
    ut.expect(g_tests_results).to_match('^\s*Success for exception defined as varchar \[[,\.0-9]+ sec\]\s*$','m');
    ut.expect(g_tests_results).not_to_match('defined_varchar_exc');
  end; 
  
  procedure non_existing_const is  
  begin
    ut.expect(g_tests_results).to_match('^\s*Non existing constant exception \[[,\.0-9]+ sec\] \(FAILED - [0-9]+\)\s*$','m');
    ut.expect(g_tests_results).to_match('non_existing_const\s*ORA-20143: Test error\s*ORA-06512: at "UT3_TESTER.ANNOTATED_PACKAGE_WITH_THROWS"');
  end;
 
  procedure bad_exc_const is
  begin
    ut.expect(g_tests_results).to_match('^\s*Bad exception constant \[[,\.0-9]+ sec\] \(FAILED - [0-9]+\)\s*$','m');
    ut.expect(g_tests_results).to_match('bad_exc_const\s*ORA-20143: Test error\s*ORA-06512: at "UT3_TESTER.ANNOTATED_PACKAGE_WITH_THROWS"');
  end; 
  
  procedure drop_test_package is
    pragma autonomous_transaction;
  begin
    execute immediate 'drop package annotated_package_with_throws';
    execute immediate 'drop package exc_pkg';
  end;

end;
/
