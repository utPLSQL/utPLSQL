CREATE OR REPLACE PACKAGE BODY utroutcome
IS

/************************************************************************
GNU General Public License for utPLSQL

Copyright (C) 2000-2003 
Steven Feuerstein and the utPLSQL Project
(steven@stevenfeuerstein.com)

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program (see license.txt); if not, write to the Free Software
Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
************************************************************************
$Log$
************************************************************************/

   PROCEDURE initiate (
      run_id_in IN utr_outcome.run_id%TYPE
    , outcome_id_in IN utr_outcome.outcome_id%TYPE
    , start_on_in IN DATE := SYSDATE
   )
   IS
      &start81 
      PRAGMA AUTONOMOUS_TRANSACTION;
   &end81
   BEGIN
      utplsql2.set_current_outcome (outcome_id_in);

      INSERT INTO utr_outcome
                  (run_id, outcome_id, start_on
                  )
           VALUES (run_id_in, outcome_id_in, start_on_in
                  );

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
         utrerror.oc_report (run_id_in
                           , outcome_id_in
                           , SQLCODE
                           , SQLERRM
                           ,    'Unable to initiate outcome for run '
                             || run_id_in
                             || ' outcome ID '
                             || outcome_id_in
                            );
   END initiate;

   PROCEDURE RECORD (
      run_id_in IN utr_outcome.run_id%TYPE
    , tc_run_id_in IN PLS_INTEGER
    , outcome_id_in IN utr_outcome.outcome_id%TYPE
    , test_failed_in IN BOOLEAN
    , description_in IN VARCHAR2 := NULL
    , end_on_in IN DATE := SYSDATE
   )
   IS
      &start81 
      PRAGMA AUTONOMOUS_TRANSACTION;

      &end81

      CURSOR start_cur (id_in IN utr_outcome.outcome_id%TYPE)
      IS
         SELECT start_on, end_on
           FROM utr_outcome
          WHERE run_id = run_id_in AND outcome_id = id_in;

      rec        start_cur%ROWTYPE;
      l_status   utr_outcome.status%TYPE;
   BEGIN
      -- FALSE means that the test succeeded.
      IF test_failed_in
      THEN
         l_status := utresult2.c_failure;
      ELSE
         l_status := utresult2.c_success;
      END IF;

      OPEN start_cur (outcome_id_in);
      FETCH start_cur INTO rec;

      IF start_cur%FOUND AND rec.end_on IS NULL
      THEN
         UPDATE utr_outcome
            SET end_on = end_on_in
              , status = l_status
              , description = description_in
          WHERE run_id = run_id_in AND outcome_id = outcome_id_in;
      ELSIF start_cur%FOUND AND rec.end_on IS NOT NULL
      THEN
         -- Run is already terminated. Ignore...
         NULL;
      ELSE
         INSERT INTO utr_outcome
                     (run_id, tc_run_id, outcome_id, status
                    , end_on, description
                     )
              VALUES (run_id_in, tc_run_id_in, outcome_id_in, l_status
                    , end_on_in, description_in
                     );

         utplsql2.move_ahead_tc_runnum; -- 2.0.9.1
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
         utrerror.oc_report (run_id_in
                           , outcome_id_in
                           , SQLCODE
                           , SQLERRM
                           ,    'Unable to insert or update the utr_outcome table for run '
                             || run_id_in
                             || ' outcome ID '
                             || outcome_id_in
                            );
   END RECORD;

   FUNCTION next_v1_id (run_id_in IN utr_outcome.run_id%TYPE)
      RETURN utr_outcome.outcome_id%TYPE
   IS
      retval   utr_outcome.outcome_id%TYPE;
   BEGIN
      SELECT MIN (outcome_id)
        INTO retval
        FROM utr_outcome
       WHERE run_id = run_id_in;

      retval := LEAST (NVL (retval, 0), 0) - 1;
      RETURN retval;
   END;

   PROCEDURE clear_results (run_id_in IN utr_outcome.run_id%TYPE)
   IS
      &start81 
      PRAGMA AUTONOMOUS_TRANSACTION;
   &end81
   BEGIN
      DELETE FROM utr_outcome
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
      DELETE FROM utr_outcome
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
      DELETE FROM utr_outcome
            WHERE start_on <
                     (SELECT MAX (o.start_on)
                        FROM utr_outcome o, utr_utp r, ut_utp u
                       WHERE r.utp_id = u.ID
                         AND u.owner = owner_in
                         AND u.program = program_in
                         AND o.run_id = r.run_id)
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
END utroutcome;
/

