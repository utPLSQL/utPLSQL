
CREATE OR REPLACE PACKAGE utrutp
IS
   PROCEDURE TERMINATE (
      run_id_in IN utr_utp.run_id%TYPE
    , utp_id_in IN utr_utp.utp_id%TYPE
    , end_on_in IN DATE := SYSDATE
   );

   PROCEDURE initiate (
      run_id_in IN utr_utp.run_id%TYPE
    , utp_id_in IN utr_utp.utp_id%TYPE
    , start_on_in IN DATE := SYSDATE
   );

   PROCEDURE clear_results (run_id_in IN utr_utp.run_id%TYPE);

   PROCEDURE clear_results (
      owner_in IN VARCHAR2
    , program_in IN VARCHAR2
    , start_from_in IN DATE
   );

   PROCEDURE clear_all_but_last (owner_in IN VARCHAR2, program_in IN VARCHAR2);
   
   function last_run_status (
      owner_in IN VARCHAR2
    , program_in IN VARCHAR2
   )
   return utr_utp.status%type;
END utrutp;
/

