/* Formatted on 2001/07/13 12:30 (RevealNet Formatter v4.4.1) */
CREATE OR REPLACE PACKAGE BODY utrerror
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

   FUNCTION uterrcode (errmsg_in IN VARCHAR2 := NULL)
      RETURN INTEGER
   IS
   BEGIN
      -- FORMAT ORA-XXXXXX: UT-300XXX:
      IF NVL (errmsg_in, SQLERRM) LIKE 'ORA-_____: ' || c_error_indicator
      THEN
         RETURN SUBSTR (NVL (errmsg_in, SQLERRM), 15, 6);
      ELSE
         RETURN NULL;
      END IF;
   END;

   PROCEDURE raise_error (
      errcode_in   IN   utr_error.errcode%TYPE,
      errtext_in   IN   utr_error.errtext%TYPE
   )
   IS
   BEGIN
      -- Raise "error reported"
      IF errcode_in BETWEEN 300000 AND 399999
      THEN
         raise_application_error (
            -20000,
            SUBSTR (   'UT-'
                    || errcode_in
                    || ': '
                    || errtext_in, 1, 255)
         );
      ELSE
         raise_application_error (
            -20000,
            SUBSTR (   errcode_in
                    || ': '
                    || errtext_in
                    || '"', 1, 255)
         );
      END IF;
   END;

   PROCEDURE ins (
      run_id_in        IN   utr_error.run_id%TYPE := NULL,
      suite_id_in      IN   utr_error.suite_id%TYPE := NULL,
      utp_id_in        IN   utr_error.utp_id%TYPE := NULL,
      unittest_id_in   IN   utr_error.unittest_id%TYPE := NULL,
      testcase_id_in   IN   utr_error.testcase_id%TYPE := NULL,
      outcome_id_in    IN   utr_error.outcome_id%TYPE := NULL,
      errlevel_in      IN   utr_error.errlevel%TYPE := NULL,
      errcode_in       IN   utr_error.errcode%TYPE := NULL,
      errtext_in       IN   utr_error.errtext%TYPE := NULL,
      description_in   IN   utr_error.description%TYPE := NULL,
      recorderr        IN   BOOLEAN := TRUE,
      raiseexc         IN   BOOLEAN := TRUE
   )
   IS
      l_message   VARCHAR2 (2000);
      &start_ge_8_1 
      PRAGMA autonomous_transaction;
   &start_ge_8_1
   BEGIN
      -- If error already recorded, simply re-raise.

      IF errtext_in LIKE c_error_indicator
      THEN
         -- Already recorded. SKip this step.
         NULL;
      ELSE
         IF recorderr
         THEN
            INSERT INTO utr_error
                        (run_id, suite_id, utp_id, unittest_id,
                         testcase_id, outcome_id, errlevel, occurred_on,
                         errcode, errtext, description)
                 VALUES (run_id_in, suite_id_in, utp_id_in, unittest_id_in,
                         testcase_id_in, outcome_id_in, errlevel_in, SYSDATE,
                         errcode_in, errtext_in, description_in);
         ELSE
            l_message :=    'Error UT-'
                         || NVL (errcode_in, general_error)
                         || ': '
                         || errtext_in;

            IF errlevel_in IS NOT NULL
            THEN
               l_message :=    l_message
                            || ' '
                            || errlevel_in;
            END IF;

            IF description_in IS NOT NULL
            THEN
               l_message :=    l_message
                            || ' '
                            || description_in;
            END IF;

            -- Simply display the error information.
            utreport.pl (l_message);
         END IF;
      END IF;

      &start_ge_8_1 
      COMMIT;

      &start_ge_8_1

      IF raiseexc
      THEN
         raise_error (errcode_in, errtext_in);
      END IF;
   &start_ge_8_1 
   EXCEPTION
      WHEN OTHERS
      THEN
         ROLLBACK;
         RAISE;
   &start_ge_8_1
   END;

   PROCEDURE report (
      errcode_in       IN   INTEGER,
      errtext_in       IN   VARCHAR2 := NULL,
      description_in   IN   VARCHAR2 := NULL,
      errlevel_in      IN   VARCHAR2 := NULL,
      recorderr        IN   BOOLEAN := TRUE,
      raiseexc         IN   BOOLEAN := TRUE
   )
   IS
   BEGIN
      ins (
         run_id_in=> NULL,
         suite_id_in=> NULL,
         utp_id_in=> NULL,
         unittest_id_in=> NULL,
         testcase_id_in=> NULL,
         outcome_id_in=> NULL,
         errlevel_in=> errlevel_in,
         errcode_in=> errcode_in,
         errtext_in=> errtext_in,
         description_in=> description_in,
         recorderr=> recorderr,
         raiseexc=> raiseexc
      );
   END;

   PROCEDURE report_define_error (
      define_in    IN   VARCHAR2,
      message_in   IN   VARCHAR2 := NULL
   )
   IS
   BEGIN
      report (
         errcode_in=> SQLCODE,
         errtext_in=> SQLERRM,
         description_in=> message_in,
         errlevel_in=> define_in,
         recorderr=> FALSE,
         raiseexc=> TRUE
      );
   END;

   PROCEDURE assert (
      condition_in   IN   BOOLEAN,
      message_in     IN   VARCHAR2,
      raiseexc       IN   BOOLEAN := TRUE,
      raiseerr       IN   INTEGER := NULL
   )
   IS
   BEGIN
      IF    condition_in IS NULL
         OR NOT condition_in
      THEN
         report (
            errcode_in=> NVL (raiseerr, assertion_failure),
            errtext_in=> message_in,
            description_in=> NULL,
            errlevel_in=> NULL,
            recorderr=> FALSE,
            raiseexc=> raiseexc
         );
      END IF;
   END;

   PROCEDURE suite_report (
      run_in           IN   INTEGER,
      suite_in         IN   ut_suite.id%TYPE,
      errcode_in       IN   INTEGER,
      errtext_in       IN   VARCHAR2 := NULL,
      description_in   IN   VARCHAR2 := NULL,
      raiseexc         IN   BOOLEAN := TRUE
   )
   IS
   BEGIN
      ins (
         run_id_in=> run_in,
         suite_id_in=> suite_in,
         utp_id_in=> NULL,
         unittest_id_in=> NULL,
         testcase_id_in=> NULL,
         outcome_id_in=> NULL,
         errlevel_in=> ututp.c_abbrev,
         errcode_in=> errcode_in,
         errtext_in=> errtext_in,
         description_in=> description_in,
         raiseexc=> raiseexc
      );
   END;

   PROCEDURE utp_report (
      run_in           IN   INTEGER,
      utp_in           IN   ut_utp.id%TYPE,
      errcode_in       IN   INTEGER,
      errtext_in       IN   VARCHAR2 := NULL,
      description_in   IN   VARCHAR2 := NULL,
      raiseexc         IN   BOOLEAN := TRUE
   )
   IS
   BEGIN
      ins (
         run_id_in=> run_in,
         utp_id_in=> utp_in,
         unittest_id_in=> NULL,
         testcase_id_in=> NULL,
         outcome_id_in=> NULL,
         errlevel_in=> ututp.c_abbrev,
         errcode_in=> errcode_in,
         errtext_in=> errtext_in,
         description_in=> description_in,
         raiseexc=> raiseexc
      );
   END;

   PROCEDURE ut_report (
      run_in           IN   INTEGER,
      unittest_in      IN   ut_unittest.id%TYPE,
      errcode_in       IN   INTEGER,
      errtext_in       IN   VARCHAR2 := NULL,
      description_in   IN   VARCHAR2 := NULL,
      raiseexc         IN   BOOLEAN := TRUE
   )
   IS
   BEGIN
      ins (
         run_id_in=> run_in,
         utp_id_in=> NULL,
         unittest_id_in=> unittest_in,
         testcase_id_in=> NULL,
         outcome_id_in=> NULL,
         errlevel_in=> utunittest.c_abbrev,
         errcode_in=> errcode_in,
         errtext_in=> errtext_in,
         description_in=> description_in,
         raiseexc=> raiseexc
      );
   END;

   PROCEDURE tc_report (
      run_in           IN   INTEGER,
      testcase_in      IN   ut_testcase.id%TYPE,
      errcode_in       IN   INTEGER,
      errtext_in       IN   VARCHAR2 := NULL,
      description_in   IN   VARCHAR2 := NULL,
      raiseexc         IN   BOOLEAN := TRUE
   )
   IS
   BEGIN
      ins (
         run_id_in=> run_in,
         utp_id_in=> NULL,
         unittest_id_in=> NULL,
         testcase_id_in=> testcase_in,
         outcome_id_in=> NULL,
         errlevel_in=> uttestcase.c_abbrev,
         errcode_in=> errcode_in,
         errtext_in=> errtext_in,
         description_in=> description_in,
         raiseexc=> raiseexc
      );
   END;

   PROCEDURE oc_report (
      run_in           IN   INTEGER,
      outcome_in       IN   ut_outcome.id%TYPE,
      errcode_in       IN   INTEGER,
      errtext_in       IN   VARCHAR2 := NULL,
      description_in   IN   VARCHAR2 := NULL,
      raiseexc         IN   BOOLEAN := TRUE
   )
   IS
   BEGIN
      ins (
         run_id_in=> run_in,
         utp_id_in=> NULL,
         unittest_id_in=> NULL,
         testcase_id_in=> NULL,
         outcome_id_in=> outcome_in,
         errlevel_in=> utoutcome.c_abbrev,
         errcode_in=> errcode_in,
         errtext_in=> errtext_in,
         description_in=> description_in,
         raiseexc=> raiseexc
      );
   END;
END utrerror;
/
