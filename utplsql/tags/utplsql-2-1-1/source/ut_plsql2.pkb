/* Formatted on 2001/10/15 08:45 (Formatter Plus v4.5.2) */
CREATE OR REPLACE PACKAGE BODY utplsql2
IS
   
/*
GNU General Public License for utPLSQL

Copyright (C) 2000
Steven Feuerstein, steven@stevenfeuerstein.com
Chris Rimmer, chris@sunset.force9.co.uk

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
*/
-------------------------------------------------------------------------------
--Modification History
-------------------------------------------------------------------------------
--WHO                 WHEN         WHAT
-------------------------------------------------------------------------------
--SEF                 15 Nov 2001  2.0.8.1: Add support for unit test level 
--                                          setup/teardown
--Chris Rimmer        08 Nov 2000  Changed to use new utConfig package
-------------------------------------------------------------------------------

   g_trc       BOOLEAN         := FALSE;
   g_version   VARCHAR2 (100)  := '1.5.6';
   g_current   current_test_rt;

   -- Global state information
   FUNCTION runnum
      RETURN utr_outcome.run_id%TYPE
   IS
   BEGIN
      RETURN g_current.run_id;
   END;


   -- 2.0.9.1: tc_run_id logic
   PROCEDURE set_runnum 
   IS
   BEGIN
      SELECT utplsql_runnum_seq.NEXTVAL
        INTO g_current.run_id
        FROM DUAL;
      g_current.tc_run_id := 1;  
   END;

   FUNCTION tc_runnum 
      RETURN PLS_INTEGER
   IS
   BEGIN
      RETURN g_current.tc_run_id;
   END;
   
   PROCEDURE move_ahead_tc_runnum 
   IS
   BEGIN
      g_current.tc_run_id := g_current.tc_run_id + 1;
   END;
   
   FUNCTION current_suite
      RETURN ut_suite.id%TYPE
   IS
   BEGIN
      RETURN g_current.suite_id;
   END;

   PROCEDURE set_current_suite (suite_in IN ut_suite.id%TYPE)
   IS
   BEGIN
      g_current.suite_id := suite_in;
   END;

   FUNCTION current_utp
      RETURN ut_utp.id%TYPE
   IS
   BEGIN
      RETURN g_current.utp_id;
   END;

   PROCEDURE set_current_utp (utp_in IN ut_utp.id%TYPE)
   IS
   BEGIN
      g_current.utp_id := utp_in;
   END;

   FUNCTION current_unittest
      RETURN ut_unittest.id%TYPE
   IS
   BEGIN
      RETURN g_current.unittest_id;
   END;

   PROCEDURE set_current_unittest (
      unittest_in   IN   ut_unittest.id%TYPE
   )
   IS
   BEGIN
      g_current.unittest_id := unittest_in;
   END;

   FUNCTION current_testcase
      RETURN ut_testcase.id%TYPE
   IS
   BEGIN
      RETURN g_current.testcase_id;
   END;

   PROCEDURE set_current_testcase (
      testcase_in   IN   ut_testcase.id%TYPE
   )
   IS
   BEGIN
      g_current.testcase_id := testcase_in;
   END;

   FUNCTION current_outcome
      RETURN ut_outcome.id%TYPE
   IS
   BEGIN
      RETURN g_current.outcome_id;
   END;

   PROCEDURE set_current_outcome (
      outcome_in   IN   ut_outcome.id%TYPE
   )
   IS
   BEGIN
      g_current.outcome_id := outcome_in;
   END;

   PROCEDURE runprog (
      procedure_in     IN   VARCHAR2,
      utp_id_in        IN   ut_utp.id%TYPE := NULL,
      unittest_id_in   IN   ut_unittest.id%TYPE := NULL,
      propagate_in     IN   BOOLEAN := FALSE,
      exceptions_in    IN   VARCHAR2 := NULL
   )
   IS
      v_name   VARCHAR2 (100)   := procedure_in;
      v_str    VARCHAR2 (32767);
      &start73 
      fdbk     PLS_INTEGER;
      cur      PLS_INTEGER      := DBMS_SQL.open_cursor;
   &end73
   BEGIN
      IF tracing
      THEN
         utplsql.pl (   'Runprog of '
                     || procedure_in);
      END IF;

      v_str :=    'BEGIN '
               || procedure_in
               || ';'
               || utplsql.ifelse (
                     exceptions_in IS NULL,
                     NULL,
                        RTRIM (
                              'EXCEPTION '
                           || exceptions_in,
                           ';'
                        )
                     || ';'
                  )
               || ' END;';
      &start81
      EXECUTE IMMEDIATE v_str;
      &end81
      &start73
      DBMS_SQL.parse (cur, v_str, DBMS_SQL.native);
      fdbk := DBMS_SQL.EXECUTE (cur);
      DBMS_SQL.close_cursor (cur);
   &end73
   EXCEPTION
      WHEN OTHERS
      THEN
         &start73
         DBMS_SQL.close_cursor (cur);

         &end73

         IF tracing
         THEN
            utplsql.pl (
                  'Procedure execution Error "'
               || SQLERRM
               || '" on: '
            );
            utplsql.pl (v_str);
         END IF;

         IF unittest_id_in IS NOT NULL
         THEN
            utrerror.ut_report (
               utplsql2.runnum,
               unittest_id_in,
               utrerror.cannot_run_program,
                  'Procedure named "'
               || procedure_in
               || '" could not be executed.',
               SQLERRM
            );
         ELSE
            utrerror.utp_report (
               utplsql2.runnum,
               utp_id_in,
               utrerror.cannot_run_program,
                  'Procedure named "'
               || procedure_in
               || '" could not be executed.',
               SQLERRM
            );
         END IF;
   /*
   utassert.this (
         'Unable to run '
      || procedure_in
      || ': '
      || SQLERRM,
      FALSE,
      null_ok_in=> NULL,
      raise_exc_in=> propagate_in,
      register_in=> TRUE
   );
   */
   END;

   PROCEDURE run_utp_setup (utp_in IN ut_utp%ROWTYPE, 
      package_level_in in boolean := TRUE)
   IS
      l_program   VARCHAR2 (100)
                          := ututp.setup_procedure (utp_in);
   -- V1 uttestprep.setup_program (utp_in)
   BEGIN
      IF l_program IS NOT NULL and
      (package_level_in OR utp_in.per_method_setup = utplsql.c_yes)
      THEN
         runprog (
            l_program,
            utp_in.id,
            exceptions_in=> utp_in.EXCEPTIONS
         );
      END IF;
   END;

   PROCEDURE run_utp_teardown (utp_in IN ut_utp%ROWTYPE, 
      package_level_in in boolean := TRUE)
   IS
      l_program   VARCHAR2 (100)
                       := ututp.teardown_procedure (utp_in);
   -- V1 uttestprep.teardown_program (utp_in);
   BEGIN
      IF l_program IS NOT NULL and
      (package_level_in OR utp_in.per_method_setup = utplsql.c_yes)
      THEN
         runprog (
            l_program,
            utp_in.id,
            exceptions_in=> utp_in.EXCEPTIONS
         );
      END IF;
   END;

   PROCEDURE run_unittest (
      utp_in   IN   ut_utp%ROWTYPE,
      ut_in    IN   ut_unittest%ROWTYPE
   )
   IS
   BEGIN
      utrunittest.initiate (utplsql2.runnum, ut_in.id);
      
      -- 2.0.8.1: Add support for unit test level setup/teardown
      
      run_utp_setup (utp_in, package_level_in => FALSE);
      
      runprog (
         utunittest.full_name (utp_in, ut_in),
         utp_in.id,
         ut_in.id,
         exceptions_in=> utp_in.EXCEPTIONS
      );
      
      run_utp_teardown (utp_in, package_level_in => FALSE);
      
      utrunittest.terminate (utplsql2.runnum, ut_in.id);
   END;

   PROCEDURE test (
      utp_rec           IN   ut_utp%ROWTYPE,
      show_results_in   IN   BOOLEAN := TRUE,
      program_in        IN   VARCHAR2 := NULL,
      naming_mode_in    IN   VARCHAR2 := v2_naming_mode
   )
   IS
      CURSOR unit_tests_cur (id_in IN ut_utp.id%TYPE)
      IS
         SELECT   *
             FROM ut_unittest
            WHERE utp_id = id_in
              AND status = utplsql.c_enabled
         ORDER BY seq;

      PROCEDURE cleanup (utp_in IN ut_utp%ROWTYPE)
      IS
      BEGIN
         IF utp_in.id IS NOT NULL
         THEN
            run_utp_teardown (utp_in);
            utrutp.terminate (utplsql2.runnum, utp_in.id);
         END IF;

         IF show_results_in
         THEN
            utresult.show (utplsql2.runnum);
         END IF;

         COMMIT;
      END;
   BEGIN
      IF utp_rec.id IS NULL
      THEN
         utrerror.utp_report (
            utplsql2.runnum,
            NULL,
            utrerror.no_utp_for_program,
               'Program named "'
            || program_in
            || '" does not have a UTP defined for it.'
         );
      ELSE
         utrutp.initiate (utplsql2.runnum, utp_rec.id);
         run_utp_setup (utp_rec);

         -- Get the information on this program from the ut_utp table.
         FOR ut_rec IN unit_tests_cur (utp_rec.id)
         LOOP
            IF tracing
            THEN
               utplsql.pl (
                     'Unit testing: '
                  || ut_rec.program_name
               );
            END IF;

            run_unittest (utp_rec, ut_rec);
            
         END LOOP;
      END IF;

      cleanup (utp_rec);
   EXCEPTION
      WHEN OTHERS
      THEN
         utrerror.utp_report (
            utplsql2.runnum,
            utp_rec.id,
            SQLCODE,
            SQLERRM,
            raiseexc=> FALSE
         );
         cleanup (utp_rec);
   END;

   PROCEDURE test (
      program_in        IN   VARCHAR2,
      owner_in          IN   VARCHAR2 := NULL,
      show_results_in   IN   BOOLEAN := TRUE,
      naming_mode_in    IN   VARCHAR2 := v2_naming_mode
   )
   IS
      utp_rec   ut_utp%ROWTYPE;
   BEGIN
      set_runnum;
      utp_rec := ututp.onerow (owner_in, program_in);
      test (
         utp_rec,
         show_results_in,
         program_in,
         naming_mode_in
      );
   END;

   PROCEDURE testsuite (
      suite_in          IN   VARCHAR2,
      show_results_in   IN   BOOLEAN := TRUE,
      naming_mode_in    IN   VARCHAR2 := v2_naming_mode
   )
   IS
      v_suite         ut_suite.id%TYPE;
      v_success       BOOLEAN            := TRUE;
      v_suite_start   DATE               := SYSDATE;
      v_pkg_start     DATE;
      suite_rec       ut_suite%ROWTYPE;

      CURSOR utps_cur (suite_in IN ut_suite.id%TYPE)
      IS
         SELECT ut_utp.*
           FROM ut_utp, ut_suite_utp
          WHERE suite_id = suite_in
            AND ut_utp.id = ut_suite_utp.utp_id;
   BEGIN
      set_runnum;
      suite_rec := utsuite.onerow (suite_in);

      IF suite_rec.id IS NULL
      THEN
         utrerror.suite_report (
            utplsql2.runnum,
            NULL,
            utrerror.undefined_suite,
               'Suite named "'
            || suite_in
            || '" is not defined.'
         );
      ELSE
         utrsuite.initiate (utplsql2.runnum, suite_rec.id);

         -- Get the information on this program from the ut_utp table.
         FOR utp_rec IN utps_cur (suite_rec.id)
         LOOP
            test (
               utp_rec,
               show_results_in=> show_results_in,
               naming_mode_in=> naming_mode_in
            );
         END LOOP;

         utrsuite.terminate (utplsql2.runnum, suite_rec.id);
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         utrerror.suite_report (
            utplsql2.runnum,
            suite_rec.id,
            SQLCODE,
            SQLERRM,
            raiseexc=> FALSE
         );
   END;

   PROCEDURE trc
   IS
   BEGIN
      g_trc := TRUE;
   END;

   PROCEDURE notrc
   IS
   BEGIN
      g_trc := FALSE;
   END;

   FUNCTION tracing
      RETURN BOOLEAN
   IS
   BEGIN
      RETURN g_trc;
   END;
END utplsql2;
/

