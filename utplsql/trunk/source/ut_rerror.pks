/* Formatted on 2001/07/13 12:29 (RevealNet Formatter v4.4.1) */
CREATE OR REPLACE PACKAGE utrerror &start81 AUTHID CURRENT_USER &end81
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

   c_error_indicator    CONSTANT VARCHAR2 (7) := 'UT-300%';
   general_error        CONSTANT INTEGER      := 300000;
   no_utp_for_program   CONSTANT INTEGER      := 300001;
   cannot_run_program   CONSTANT INTEGER      := 300002;
   undefined_outcome    CONSTANT INTEGER      := 300003;
   undefined_suite      CONSTANT INTEGER      := 300004;
   assertion_failure    CONSTANT INTEGER      := 300005;
   exc_undefined_suite           EXCEPTION;

   FUNCTION uterrcode (errmsg_in IN VARCHAR2 := NULL)
      RETURN INTEGER;

   PROCEDURE assert (
      condition_in   IN   BOOLEAN,
      message_in     IN   VARCHAR2,
      raiseexc       IN   BOOLEAN := TRUE,
      raiseerr       IN   INTEGER := NULL
   );

   PROCEDURE report (
      errcode_in       IN   INTEGER,
      errtext_in       IN   VARCHAR2 := NULL,
      description_in   IN   VARCHAR2 := NULL,
      errlevel_in      IN   VARCHAR2 := NULL,
      recorderr        IN   BOOLEAN := TRUE,
      raiseexc         IN   BOOLEAN := TRUE
   );

   -- Generic reporting for definition actions. 
   -- Passes SQLCODE and SQLERRM, does NOT record the error
   PROCEDURE report_define_error (
      define_in    IN   VARCHAR2,
      message_in   IN   VARCHAR2 := NULL
   );

   PROCEDURE suite_report (
      run_in           IN   INTEGER,
      suite_in         IN   ut_suite.id%TYPE,
      errcode_in       IN   INTEGER,
      errtext_in       IN   VARCHAR2 := NULL,
      description_in   IN   VARCHAR2 := NULL,
      raiseexc         IN   BOOLEAN := TRUE
   );

   PROCEDURE utp_report (
      run_in           IN   INTEGER,
      utp_in           IN   ut_utp.id%TYPE,
      errcode_in       IN   INTEGER,
      errtext_in       IN   VARCHAR2 := NULL,
      description_in   IN   VARCHAR2 := NULL,
      raiseexc         IN   BOOLEAN := TRUE
   );

   PROCEDURE ut_report (
      run_in           IN   INTEGER,
      unittest_in      IN   ut_unittest.id%TYPE,
      errcode_in       IN   INTEGER,
      errtext_in       IN   VARCHAR2 := NULL,
      description_in   IN   VARCHAR2 := NULL,
      raiseexc         IN   BOOLEAN := TRUE
   );

   PROCEDURE tc_report (
      run_in           IN   INTEGER,
      testcase_in      IN   ut_testcase.id%TYPE,
      errcode_in       IN   INTEGER,
      errtext_in       IN   VARCHAR2 := NULL,
      description_in   IN   VARCHAR2 := NULL,
      raiseexc         IN   BOOLEAN := TRUE
   );

   PROCEDURE oc_report (
      run_in           IN   INTEGER,
      outcome_in       IN   ut_outcome.id%TYPE,
      errcode_in       IN   INTEGER,
      errtext_in       IN   VARCHAR2 := NULL,
      description_in   IN   VARCHAR2 := NULL,
      raiseexc         IN   BOOLEAN := TRUE
   );
END utrerror;
/
