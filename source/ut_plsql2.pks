/* Formatted on 2001/07/13 12:29 (RevealNet Formatter v4.4.1) */
CREATE OR REPLACE PACKAGE utplsql2 &start81 AUTHID CURRENT_USER &end81
IS
   
/*
GNU General Public License for utPLSQL

Copyright (C) 2000 Steven Feuerstein, steven@stevenfeuerstein.com

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

V2_naming_mode constant char(2) := 'V1';
V1_naming_mode constant char(2) := 'V2';

   -- Define and access "current test state" information

   TYPE current_test_rt IS RECORD (
      run_id                        utr_outcome.run_id%TYPE,
      tc_run_id PLS_INTEGER, -- 2.0.9.1
      suite_id                      ut_suite.id%TYPE,
      utp_id                        ut_utp.id%TYPE,
      unittest_id                   ut_unittest.id%TYPE,
      testcase_id                   ut_testcase.id%TYPE,
      outcome_id                    ut_outcome.id%TYPE);

   FUNCTION runnum
      RETURN utr_outcome.run_id%TYPE;
   --2.0.9.2
   PRAGMA RESTRICT_REFERENCES (runnum, WNDS);
   
   PROCEDURE set_runnum;

   FUNCTION tc_runnum 
      RETURN PLS_INTEGER;
   
   PROCEDURE move_ahead_tc_runnum;
    
   FUNCTION current_suite
      RETURN ut_suite.id%TYPE;

   PROCEDURE set_current_suite (suite_in IN ut_suite.id%TYPE);

   FUNCTION current_utp
      RETURN ut_utp.id%TYPE;

   PROCEDURE set_current_utp (utp_in IN ut_utp.id%TYPE);

   FUNCTION current_unittest
      RETURN ut_unittest.id%TYPE;

   PROCEDURE set_current_unittest (unittest_in IN ut_unittest.id%TYPE);

   FUNCTION current_testcase
      RETURN ut_testcase.id%TYPE;

   PROCEDURE set_current_testcase (testcase_in IN ut_testcase.id%TYPE);

   FUNCTION current_outcome
      RETURN ut_outcome.id%TYPE;

   PROCEDURE set_current_outcome (outcome_in IN ut_outcome.id%TYPE);

   PROCEDURE test (
      program_in        IN   VARCHAR2,
      owner_in          IN   VARCHAR2 := NULL,
      show_results_in   IN   BOOLEAN := TRUE,
      naming_mode_in IN VARCHAR2 := V2_naming_mode
   );

   PROCEDURE testsuite (
      suite_in          IN   VARCHAR2,
      show_results_in   IN   BOOLEAN := TRUE,
      naming_mode_in IN VARCHAR2 := V2_naming_mode
   );

   -- Utility programs

   PROCEDURE trc;

   PROCEDURE notrc;

   FUNCTION tracing
      RETURN BOOLEAN;
END utplsql2;
/
