CREATE OR REPLACE PACKAGE utroutcome
IS
   PROCEDURE RECORD (
      run_id_in IN utr_outcome.run_id%TYPE
    , tc_run_id_in IN PLS_INTEGER
    , outcome_id_in IN utr_outcome.outcome_id%TYPE
    , test_failed_in IN BOOLEAN
    , description_in IN VARCHAR2 := NULL
    , end_on_in IN DATE := SYSDATE
   );

   PROCEDURE initiate (
      run_id_in IN utr_outcome.run_id%TYPE
    , outcome_id_in IN utr_outcome.outcome_id%TYPE
    , start_on_in IN DATE := SYSDATE
   );

   FUNCTION next_v1_id (run_id_in IN utr_outcome.run_id%TYPE)
      RETURN utr_outcome.outcome_id%TYPE;

   PROCEDURE clear_results (run_id_in IN utr_outcome.run_id%TYPE);

   PROCEDURE clear_results (
      owner_in IN VARCHAR2
    , program_in IN VARCHAR2
    , start_from_in IN DATE
   );

   PROCEDURE clear_all_but_last (owner_in IN VARCHAR2, program_in IN VARCHAR2);
END utroutcome;
/

