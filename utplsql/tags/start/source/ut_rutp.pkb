/* Formatted on 2001/07/13 12:29 (RevealNet Formatter v4.4.1) */
CREATE OR REPLACE PACKAGE BODY utrutp
IS
   PROCEDURE initiate (
      run_id_in     IN   utr_utp.run_id%TYPE,
      utp_id_in     IN   utr_utp.utp_id%TYPE,
      start_on_in   IN   DATE := SYSDATE
   )
   IS
      &start81 
      PRAGMA autonomous_transaction;
   &end81

   BEGIN
      utplsql2.set_current_utp (utp_id_in);

      INSERT INTO utr_utp
                  (run_id, utp_id, start_on)
           VALUES (run_id_in, utp_id_in, start_on_in);

      &start81 
      COMMIT;
   &end81
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX
      THEN
         -- Run has already been initiated. Ignore...
         NULL;
         &start81 
         ROLLBACK;
      &end81
      WHEN OTHERS
      THEN
         &start81 
         ROLLBACK;
         &end81
         utrerror.utp_report (
            run_id_in,
            utp_id_in,
            SQLCODE,
            SQLERRM,
               'Unable to initiate UTP for run '
            || run_id_in
            || ' UTP ID '
            || utp_id_in
         );
   END initiate;

   PROCEDURE terminate (
      run_id_in   IN   utr_utp.run_id%TYPE,
      utp_id_in   IN   utr_utp.utp_id%TYPE,
      end_on_in   IN   DATE := SYSDATE
   )
   IS
      &start81 
      PRAGMA autonomous_transaction;

      &end81

      CURSOR start_cur
      IS
         SELECT start_on, end_on
           FROM utr_utp
          WHERE run_id = run_id_in
            AND utp_id_in = utp_id;

      rec        start_cur%ROWTYPE;
      l_status   utr_utp.status%TYPE;
   BEGIN
      l_status := utresult2.run_status (run_id_in);
      OPEN start_cur;
      FETCH start_cur INTO rec;

      IF      start_cur%FOUND
          AND rec.end_on IS NULL
      THEN
         UPDATE utr_utp
            SET end_on = end_on_in,
                status = l_status
          WHERE run_id = run_id_in
            AND utp_id_in = utp_id;
      ELSIF      start_cur%FOUND
             AND rec.end_on IS NOT NULL
      THEN
         -- Run is already terminated. Ignore...
         NULL;
      ELSE
         INSERT INTO utr_utp
                     (run_id, utp_id, status, start_on, end_on)
              VALUES (run_id_in, utp_id_in, l_status, end_on_in, end_on_in);
      END IF;

      CLOSE start_cur;
      &start81 
      COMMIT;
   &end81
   EXCEPTION
      WHEN OTHERS
      THEN
         &start81 
         ROLLBACK;
         &end81
         utrerror.utp_report (
            run_id_in,
            utp_id_in,
            SQLCODE,
            SQLERRM,
               'Unable to insert or update the utr_utp table for run '
            || run_id_in
            || ' outcome ID '
            || utp_id_in
         );
   END terminate;
   
   PROCEDURE clear_results (run_id_in IN utr_utp.run_id%TYPE)
   IS
      &start81 
      PRAGMA AUTONOMOUS_TRANSACTION;
   &end81
   BEGIN
      DELETE FROM utr_utp
            WHERE run_id = run_id_in;

      &start81 
      COMMIT;
   &end81
   END;

   PROCEDURE clear_results (
      owner_in IN VARCHAR2
    , program_in IN VARCHAR2
    , start_from_in IN DATE
   )
   IS
      &start81 
      PRAGMA AUTONOMOUS_TRANSACTION;
   &end81
   BEGIN
      DELETE FROM utr_utp
            WHERE start_on >= start_from_in
              AND run_id IN (
                     SELECT r.run_id
                       FROM utr_utp r, ut_utp u
                      WHERE r.utp_id = u.ID
                        AND u.owner = owner_in
                        AND u.program = program_in);

      &start81 
      COMMIT;
   &end81
   END;

   PROCEDURE clear_all_but_last (owner_in IN VARCHAR2, program_in IN VARCHAR2)
   IS
      &start81 
      PRAGMA AUTONOMOUS_TRANSACTION;
   &end81
   BEGIN
      DELETE FROM utr_utp
            WHERE start_on <
                     (SELECT MAX (r.start_on)
                        FROM utr_utp r, ut_utp u
                       WHERE r.utp_id = u.ID
                         AND u.owner = owner_in
                         AND u.program = program_in)
              AND run_id IN (
                     SELECT r.run_id
                       FROM utr_utp r, ut_utp u
                      WHERE r.utp_id = u.ID
                        AND u.owner = owner_in
                        AND u.program = program_in);
   &start81
      COMMIT;
   &end81
   END;
   
   FUNCTION last_run_status (owner_in IN VARCHAR2, program_in IN VARCHAR2)
     RETURN utr_utp.status%TYPE
   IS
     retval   utr_utp.status%TYPE;
   BEGIN
     SELECT status
       INTO retval
       FROM utr_utp
      WHERE (utp_id, start_on) =
               (SELECT   r.utp_id, MAX (r.start_on)
                    FROM utr_utp r, ut_utp u
                   WHERE r.utp_id = u.ID
                     AND u.owner = owner_in
                     AND u.program = program_in
                GROUP BY r.utp_id)
        AND ROWNUM < 2;
   
     RETURN retval;
   EXCEPTION
     WHEN NO_DATA_FOUND
     THEN
        RETURN NULL;
   END;
   
END utrutp;
/
