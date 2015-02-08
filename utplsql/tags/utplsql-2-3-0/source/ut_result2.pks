CREATE OR REPLACE PACKAGE utresult2
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

   c_success   CONSTANT CHAR (7) := 'SUCCESS';
   c_failure   CONSTANT CHAR (7) := 'FAILURE';

   /* Test result record structure */
   TYPE result_rt IS RECORD (
      NAME   VARCHAR2 (100)
     ,msg    VARCHAR2 (32767)
     ,indx   PLS_INTEGER
   );

   TYPE result_tt IS TABLE OF result_rt
      INDEX BY BINARY_INTEGER;

   CURSOR results_header_cur (schema_in IN VARCHAR2, program_in IN VARCHAR2)
   IS
      SELECT run_id, start_on, end_on, status
        FROM ut_utp utp, utr_utp utpr
       WHERE utp.ID = utpr.utp_id
         AND utp.program = program_in
         AND utp.owner = schema_in;

   PROCEDURE report (
      outcome_in       IN   ut_outcome.ID%TYPE
     ,description_in   IN   VARCHAR2
   );

   PROCEDURE report (
      outcome_in       IN   ut_outcome.ID%TYPE
     ,test_failed_in   IN   BOOLEAN
     ,description_in   IN   VARCHAR2
     ,register_in      IN   BOOLEAN := TRUE
     , -- v1 compatibility
      showresults_in   IN   BOOLEAN := FALSE -- v1 compatibility
   );

   FUNCTION run_succeeded (runnum_in IN utr_outcome.run_id%TYPE)
      RETURN BOOLEAN;

   FUNCTION run_status (runnum_in IN utr_outcome.run_id%TYPE)
      RETURN VARCHAR2;

   FUNCTION utp_succeeded (
      runnum_in   IN   utr_outcome.run_id%TYPE
     ,utp_in      IN   utr_utp.utp_id%TYPE
   )
      RETURN BOOLEAN;

   FUNCTION utp_status (
      runnum_in   IN   utr_outcome.run_id%TYPE
     ,utp_in      IN   utr_utp.utp_id%TYPE
   )
      RETURN VARCHAR2;

   FUNCTION unittest_succeeded (
      runnum_in     IN   utr_outcome.run_id%TYPE
     ,unittest_in   IN   utr_unittest.unittest_id%TYPE
   )
      RETURN BOOLEAN;

   FUNCTION unittest_status (
      runnum_in     IN   utr_outcome.run_id%TYPE
     ,unittest_in   IN   utr_unittest.unittest_id%TYPE
   )
      RETURN VARCHAR2;

   FUNCTION results_headers (schema_in IN VARCHAR2, program_in IN VARCHAR2)
      RETURN utconfig.refcur_t;

   FUNCTION results_details (
      run_id_in               IN   utr_utp.run_id%TYPE
     ,show_failures_only_in   IN   ut_config.show_failures_only%TYPE
   )
      RETURN utconfig.refcur_t;
   
  FUNCTION suite_succeded(
    suite_id  ut_suite.id%TYPE
  )
  RETURN BOOLEAN;
END utresult2;
/
