CREATE OR REPLACE PACKAGE BODY utresult2
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
Revision 1.2  2003/07/01 19:36:47  chrisrimmer
Added Standard Headers

************************************************************************/

   PROCEDURE report (
      outcome_in       IN   ut_outcome.ID%TYPE
     ,description_in   IN   VARCHAR2
   )
   IS
   BEGIN
      NULL;
   END;

   PROCEDURE report (
      outcome_in       IN   ut_outcome.ID%TYPE
     ,test_failed_in   IN   BOOLEAN
     ,description_in   IN   VARCHAR2
     ,register_in      IN   BOOLEAN := TRUE
     , -- v1 compatibility
      showresults_in   IN   BOOLEAN := FALSE -- v1 compatibility
   )
   IS
      l_id            utr_outcome.outcome_id%TYPE    := outcome_in;
      l_description   utr_outcome.description%TYPE   := substr(description_in,1,2000);
   BEGIN
      IF utplsql2.tracing
      THEN
         utreport.pl ('Record outcome result:');
         utreport.pl (utplsql2.runnum);
         utreport.pl (utplsql2.tc_runnum);
         utreport.pl (outcome_in);
         utreport.pl (test_failed_in);
         utreport.pl (description_in);
      END IF;

      IF register_in
      THEN
         IF l_id IS NULL
         THEN
            -- v1 compatibility. Create an outcome ID and
            -- construct the message to match screen output.
            l_id := utroutcome.next_v1_id (utplsql2.runnum);
            l_description := substr(utplsql.currcase.NAME || ': ' || l_description,1,2000);
         END IF;

         utroutcome.RECORD (utplsql2.runnum
                           ,utplsql2.tc_runnum
                           , -- 2.0.9.1
                            l_id
                           ,test_failed_in
                           ,description_in
                           );
      END IF;

      -- v1 compatibility and output to screen
      IF test_failed_in
      THEN
         IF register_in
         THEN
            utresult.report (description_in);
         ELSE
            utreport.pl (description_in);
         END IF;

         IF showresults_in AND register_in
         THEN
            utresult.showlast;
         END IF;
      END IF;
   END;

   -- NOTE: the logic in the following function is REPEATED three times.
   -- Need to move to cursor variables or dynamic SQL.

   FUNCTION run_succeeded (runnum_in IN utr_outcome.run_id%TYPE)
      RETURN BOOLEAN
   /* A run succeeds if
      a. there are no FAILUREs
      b. there are no errors
   */
   IS
      l_val           CHAR (1);
      success_found   BOOLEAN;
      failure_found   BOOLEAN;

      CURSOR err_cur
      IS
         SELECT 'x'
           FROM utr_error
          WHERE run_id = runnum_in;

      CURSOR stat_cur (status_in IN VARCHAR2)
      IS
         SELECT 'x'
           FROM utr_outcome
          WHERE run_id = runnum_in AND status LIKE status_in;
   BEGIN
      -- start: same for all *_succeeded programs
      OPEN err_cur;
      FETCH err_cur INTO l_val;
      failure_found := err_cur%FOUND;

      IF NOT failure_found
      THEN
         OPEN stat_cur (c_success);
         FETCH stat_cur INTO l_val;
         success_found := stat_cur%FOUND;
         CLOSE stat_cur;
         OPEN stat_cur (c_failure);
         FETCH stat_cur INTO l_val;
         failure_found := stat_cur%FOUND;
         CLOSE stat_cur;
      END IF;

      IF NOT failure_found AND NOT success_found
      THEN
         RETURN NULL; -- Nothing was run.
      ELSE
         RETURN NOT failure_found;
      END IF;
   -- end: same for all *_succeeded programs      
   END run_succeeded;

   FUNCTION run_status (runnum_in IN utr_outcome.run_id%TYPE)
      RETURN VARCHAR2
   IS
   BEGIN
      IF run_succeeded (runnum_in)
      THEN
         RETURN c_success;
      ELSE
         RETURN c_failure;
      END IF;
   END;

   FUNCTION utp_succeeded (
      runnum_in   IN   utr_outcome.run_id%TYPE
     ,utp_in      IN   utr_utp.utp_id%TYPE
   )
      RETURN BOOLEAN
   IS
      l_val           CHAR (1);
      success_found   BOOLEAN;
      failure_found   BOOLEAN;

      CURSOR err_cur
      IS
         SELECT 'x'
           FROM utr_error
          WHERE run_id = runnum_in
            AND utp_id = utp_in
            AND errlevel = ututp.c_abbrev;

      CURSOR stat_cur (status_in IN VARCHAR2)
      IS
         SELECT 'x'
           FROM utr_outcome
          WHERE run_id = runnum_in
            AND utoutcome.utp (outcome_id) = utp_in
            AND status LIKE status_in;
   BEGIN
      OPEN err_cur;
      FETCH err_cur INTO l_val;
      failure_found := err_cur%FOUND;

      IF NOT failure_found
      THEN
         OPEN stat_cur (c_success);
         FETCH stat_cur INTO l_val;
         success_found := stat_cur%FOUND;
         CLOSE stat_cur;
         OPEN stat_cur (c_failure);
         FETCH stat_cur INTO l_val;
         failure_found := stat_cur%FOUND;
         CLOSE stat_cur;
      END IF;

      IF NOT failure_found AND NOT success_found
      THEN
         RETURN NULL; -- Nothing was run.
      ELSE
         RETURN NOT failure_found;
      END IF;
   END utp_succeeded;

   FUNCTION utp_status (
      runnum_in   IN   utr_outcome.run_id%TYPE
     ,utp_in      IN   utr_utp.utp_id%TYPE
   )
      RETURN VARCHAR2
   IS
   BEGIN
      IF utp_succeeded (runnum_in, utp_in)
      THEN
         RETURN c_success;
      ELSE
         RETURN c_failure;
      END IF;
   END;

   FUNCTION unittest_succeeded (
      runnum_in     IN   utr_outcome.run_id%TYPE
     ,unittest_in   IN   utr_unittest.unittest_id%TYPE
   )
      RETURN BOOLEAN
   IS
      l_val           CHAR (1);
      success_found   BOOLEAN;
      failure_found   BOOLEAN;

      CURSOR err_cur
      IS
         SELECT 'x'
           FROM utr_error
          WHERE run_id = runnum_in
            AND unittest_id = unittest_in
            AND errlevel = utunittest.c_abbrev;

      CURSOR stat_cur (status_in IN VARCHAR2)
      IS
         SELECT 'x'
           FROM utr_outcome
          WHERE run_id = runnum_in
            AND utoutcome.unittest (outcome_id) = unittest_in
            AND status LIKE status_in;
   BEGIN
      OPEN err_cur;
      FETCH err_cur INTO l_val;
      failure_found := err_cur%FOUND;

      IF NOT failure_found
      THEN
         OPEN stat_cur (c_success);
         FETCH stat_cur INTO l_val;
         success_found := stat_cur%FOUND;
         CLOSE stat_cur;
         OPEN stat_cur (c_failure);
         FETCH stat_cur INTO l_val;
         failure_found := stat_cur%FOUND;
         CLOSE stat_cur;
      END IF;

      IF NOT failure_found AND NOT success_found
      THEN
         RETURN NULL; -- Nothing was run.
      ELSE
         RETURN NOT failure_found;
      END IF;
   END unittest_succeeded;

   FUNCTION unittest_status (
      runnum_in     IN   utr_outcome.run_id%TYPE
     ,unittest_in   IN   utr_unittest.unittest_id%TYPE
   )
      RETURN VARCHAR2
   IS
   BEGIN
      IF unittest_succeeded (runnum_in, unittest_in)
      THEN
         RETURN c_success;
      ELSE
         RETURN c_failure;
      END IF;
   END;

   FUNCTION results_headers (schema_in IN VARCHAR2, program_in IN VARCHAR2)
      RETURN utconfig.refcur_t
   IS
      retval   utconfig.refcur_t;
   BEGIN
      OPEN retval FOR
         SELECT   run_id, start_on, end_on, status
             FROM ut_utp utp, utr_utp utpr
            WHERE utp.ID = utpr.utp_id
              AND utp.program = UPPER (program_in)
              AND utp.owner = UPPER (schema_in)
         ORDER BY end_on;
      RETURN retval;
   END results_headers;

   FUNCTION results_details (
      run_id_in               IN   utr_utp.run_id%TYPE
     ,show_failures_only_in   IN   ut_config.show_failures_only%TYPE
   )
      RETURN utconfig.refcur_t
   IS
      retval   utconfig.refcur_t;
   BEGIN
      OPEN retval FOR
         SELECT   start_on, end_on, status, description
             FROM utr_outcome
            WHERE run_id = run_id_in
              AND (   show_failures_only_in = 'N'
                   OR (show_failures_only_in = 'Y' AND status = 'FAILURE'
                      )
                  )
         ORDER BY start_on;
      RETURN retval;
   END results_details;
END utresult2;
/
