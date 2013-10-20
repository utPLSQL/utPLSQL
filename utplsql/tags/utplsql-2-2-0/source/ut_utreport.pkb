CREATE OR REPLACE PACKAGE BODY UT_UTREPORT 
AS

  reporter_before VARCHAR2(1000);

  PROCEDURE ut_setup
  IS
  BEGIN
  
    reporter_before := utConfig.getreporter;
    
    EXECUTE IMMEDIATE 'CREATE OR REPLACE PACKAGE utTestReporter
AS
   char_log VARCHAR2(1000);

   PROCEDURE open;
   PROCEDURE pl (str IN VARCHAR2);
   PROCEDURE before_results(run_id IN utr_outcome.run_id%TYPE);
   PROCEDURE show_failure;
   PROCEDURE show_result;
   PROCEDURE after_results(run_id IN utr_outcome.run_id%TYPE);
   PROCEDURE before_errors(run_id IN utr_error.run_id%TYPE);
   PROCEDURE show_error;
   PROCEDURE after_errors(run_id IN utr_error.run_id%TYPE);
   PROCEDURE close;
END;';

    EXECUTE IMMEDIATE 'CREATE OR REPLACE PACKAGE BODY utTestReporter
AS
   PROCEDURE open IS BEGIN char_log := char_log || '' open''; END;
   PROCEDURE pl (str IN VARCHAR2) IS BEGIN char_log := char_log || '' pl(''|| str || '')''; END;
   PROCEDURE before_results(run_id IN utr_outcome.run_id%TYPE)
     IS BEGIN char_log := char_log || '' before_results''; END;
   PROCEDURE show_failure
     IS BEGIN char_log := char_log || '' show_failure''; END;
   PROCEDURE show_result
     IS BEGIN char_log := char_log || '' show_result''; END;   
   PROCEDURE after_results(run_id IN utr_outcome.run_id%TYPE)
     IS BEGIN char_log := char_log || '' after_results''; END;   
   PROCEDURE before_errors(run_id IN utr_error.run_id%TYPE)
     IS BEGIN char_log := char_log || '' before_errors''; END;   
   PROCEDURE show_error
     IS BEGIN char_log := char_log || '' show_error''; END;
   PROCEDURE after_errors(run_id IN utr_error.run_id%TYPE)
     IS BEGIN char_log := char_log || '' after_errors''; END;
   PROCEDURE close
     IS BEGIN char_log := char_log || '' close''; END;
END;';

  END;
  
  PROCEDURE ut_teardown
  IS
  BEGIN  
    BEGIN
      EXECUTE IMMEDIATE 'DROP PACKAGE utTestReporter';
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;     
    
    utConfig.setreporter(reporter_before);
     
  END;
  
  FUNCTION get_log RETURN VARCHAR2 IS  
    char_log VARCHAR2(1000);
  BEGIN  
    EXECUTE IMMEDIATE 'BEGIN :1 := utTestReporter.char_log; END;' USING OUT char_log;
    RETURN char_log;
  END;

  PROCEDURE clear_log IS
  BEGIN
    EXECUTE IMMEDIATE 'BEGIN utTestReporter.char_log := NULL; END;';
  END;    
    
  -----------------------------------------------------------
  --This checks that calls to utreport get passed through to 
  --our custom reporter package.
  -----------------------------------------------------------
  PROCEDURE ut_check_report_facade
  IS
  
    run_id utr_outcome.run_id%TYPE;
    rec_result utr_outcome%ROWTYPE;
    rec_error utr_error%ROWTYPE;
  
  BEGIN

    utreport.outcome.status := NULL;
    utreport.error.description := NULL;
  
    utConfig.setreporter('Test');    
  
    clear_log;          
    utReport.open;    
    utAssert.eq('open', get_log, ' open');    

    clear_log;    
    utReport.pl('Blah');    
    utAssert.eq('pl', get_log, ' pl(Blah)');    

    clear_log;
    utReport.before_results(run_id);    
    utAssert.eq('before_results', get_log, ' before_results');    

    clear_log;
    rec_result.STATUS := 'FAILURE';
    utReport.show_failure(rec_result);    
    utAssert.eq('show_failure', get_log, ' show_failure');
    utAssert.eq('show_failure: outcome set', utreport.outcome.status, 'FAILURE');    

    clear_log;
    rec_result.STATUS := 'RESULT';
    utReport.show_result(rec_result);    
    utAssert.eq('show_result', get_log, ' show_result');
    utAssert.eq('show_failure: outcome set', utreport.outcome.status, 'RESULT');    

    clear_log;
    utReport.after_results(run_id);    
    utAssert.eq('after_results', get_log, ' after_results');        

    clear_log;
    utReport.before_errors(run_id);    
    utAssert.eq('before_errors', get_log, ' before_errors');    

    clear_log;
    rec_error.DESCRIPTION := 'BOOM!';
    utReport.show_error(rec_error);    
    utAssert.eq('show_error', get_log, ' show_error');    
    utAssert.eq('show_error: error set', utreport.error.description, 'BOOM!');
    
    clear_log;
    utReport.after_errors(run_id);    
    utAssert.eq('after_errors', get_log, ' after_errors');    
    
    utConfig.setreporter(reporter_before);            

  EXCEPTION 
    WHEN OTHERS THEN
      utConfig.setreporter(reporter_before);
      RAISE;
                
  END;
  
END;
/
