/* Formatted on 2001/07/13 12:29 (RevealNet Formatter v4.4.1) */
CREATE OR REPLACE PACKAGE BODY utrsuite
IS
   PROCEDURE initiate (
      run_id_in     IN   utr_suite.run_id%TYPE,
      suite_id_in   IN   utr_suite.suite_id%TYPE,
      start_on_in   IN   DATE := SYSDATE
   )
   IS
      &start81 
      PRAGMA autonomous_transaction;
   &end81

   BEGIN
      utplsql2.set_current_suite (suite_id_in);

      INSERT INTO utr_suite
                  (run_id, suite_id, start_on)
           VALUES (run_id_in, suite_id_in, start_on_in);

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
         utrerror.suite_report (
            run_id_in,
            suite_id_in,
            SQLCODE,
            SQLERRM,
               'Unable to initiate suite for run '
            || run_id_in
            || ' SUITE ID '
            || suite_id_in
         );
   END initiate;

   PROCEDURE terminate (
      run_id_in     IN   utr_suite.run_id%TYPE,
      suite_id_in   IN   utr_suite.suite_id%TYPE,
      end_on_in     IN   DATE := SYSDATE
   )
   IS
      &start81 
      PRAGMA autonomous_transaction;

      &end81

      CURSOR start_cur
      IS
         SELECT start_on, end_on
           FROM utr_suite
          WHERE run_id = run_id_in
            AND suite_id_in = suite_id;

      rec        start_cur%ROWTYPE;
      l_status   utr_suite.status%TYPE;
   BEGIN
      l_status := utresult2.run_status (run_id_in);
      OPEN start_cur;
      FETCH start_cur INTO rec;

      IF      start_cur%FOUND
          AND rec.end_on IS NULL
      THEN
         UPDATE utr_suite
            SET end_on = end_on_in,
                status = l_status
          WHERE run_id = run_id_in
            AND suite_id_in = suite_id;
      ELSIF      start_cur%FOUND
             AND rec.end_on IS NOT NULL
      THEN
         -- Run is already terminated. Ignore...
         NULL;
      ELSE
         INSERT INTO utr_suite
                     (run_id, suite_id, status, end_on)
              VALUES (run_id_in, suite_id_in, l_status, end_on_in);
      END IF;

      &start81 
      COMMIT;
   &end81
   EXCEPTION
      WHEN OTHERS
      THEN
         &start81 
         ROLLBACK;
         &end81
         utrerror.suite_report (
            run_id_in,
            suite_id_in,
            SQLCODE,
            SQLERRM,
               'Unable to insert or update the utr_suite table for run '
            || run_id_in
            || ' SUITE ID '
            || suite_id_in
         );
   END terminate;
END utrsuite;
/
