/* Formatted on 2001/07/13 12:29 (RevealNet Formatter v4.4.1) */
CREATE OR REPLACE PACKAGE utplsql &start_ge_8_1 AUTHID CURRENT_USER &end_ge_8_1
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
Revision 1.4  2004/11/16 09:46:49  chrisrimmer
Changed to new version detection system.

Revision 1.2  2003/07/01 19:36:47  chrisrimmer
Added Standard Headers

************************************************************************/

   c_success    CONSTANT VARCHAR2 (7)     := 'SUCCESS';
   c_failure    CONSTANT VARCHAR2 (7)     := 'FAILURE';
   c_yes        CONSTANT CHAR (1)         := 'Y';
   c_no         CONSTANT CHAR (1)         := 'N';
   c_setup      CONSTANT CHAR (5)         := 'SETUP';
   c_teardown   CONSTANT CHAR (8)         := 'TEARDOWN';
   c_enabled   CONSTANT CHAR (7)         := 'ENABLED';
   c_disabled   CONSTANT CHAR (8)         := 'DISABLED';
   &start_lt_8_1
   dbmaxvc2              VARCHAR2 (2000);
   &end_lt_8_1
   &start_ge_8_1
   dbmaxvc2              VARCHAR2 (4000);

   &end_ge_8_1
   SUBTYPE dbmaxvc2_t IS dbmaxvc2%TYPE;

   maxvc2                VARCHAR2 (32767);

   SUBTYPE maxvc2_t IS maxvc2%TYPE;

   namevc2               VARCHAR2 (100);

   SUBTYPE name_t IS namevc2%TYPE;

   TYPE test_rt IS RECORD (
      pkg                           VARCHAR2 (100),
	  owner VARCHAR2(100), -- 2.0.9.1 support remote schema execution
      ispkg                         BOOLEAN,
      samepkg                       BOOLEAN,
      prefix                        VARCHAR2 (100),
      iterations                    PLS_INTEGER);

   TYPE testcase_rt IS RECORD (
      pkg                           VARCHAR2 (100),
      prefix                        VARCHAR2 (100),
      name                          VARCHAR2 (100),
      indx                          PLS_INTEGER,
      iterations                    PLS_INTEGER);

   TYPE test_tt IS TABLE OF testcase_rt
      INDEX BY BINARY_INTEGER;

   currcase              testcase_rt;

   /* Utility programs */
   FUNCTION vc2bool (vc IN VARCHAR2)
      RETURN BOOLEAN;

   FUNCTION bool2vc (bool IN BOOLEAN)
      RETURN VARCHAR2;

   FUNCTION ispackage (prog_in IN VARCHAR2, sch_in IN VARCHAR2)
      RETURN BOOLEAN;

   /* Single package test engine. */

   PROCEDURE test (
      package_in         IN   VARCHAR2,
      samepackage_in     IN   BOOLEAN := FALSE,
      prefix_in          IN   VARCHAR2 := NULL,
      recompile_in       IN   BOOLEAN := TRUE,
      dir_in             IN   VARCHAR2 := NULL,
      suite_in           IN   VARCHAR2 := NULL,
      owner_in           IN   VARCHAR2 := NULL,
      reset_results_in   IN   BOOLEAN := TRUE,
      from_suite_in      IN   BOOLEAN := FALSE,
      subprogram_in in varchar2 := '%',
      per_method_setup_in in boolean := FALSE, -- 2.0.8
	  override_package_in IN varchar2 := NULL -- 2.0.9.2
   -- If recompiling, then always looks for 
   -- <pkg>.pks and <pkg>.pkb files
   );

   PROCEDURE testsuite (
      suite_in           IN   VARCHAR2,
      recompile_in       IN   BOOLEAN := TRUE,
      reset_results_in   IN   BOOLEAN := TRUE,
      per_method_setup_in in boolean := FALSE, -- 2.0.8
      override_package_in IN BOOLEAN := FALSE
   -- If recompiling, then always looks for 
   -- <pkg>.pks and <pkg>.pkb files
   );

   /* Single package test engine. */
   -- 2.0.9.2: run a test package directly
   PROCEDURE run (
      testpackage_in     IN   VARCHAR2,
      prefix_in          IN   VARCHAR2 := NULL,
      suite_in           IN   VARCHAR2 := NULL,
      owner_in           IN   VARCHAR2 := NULL,
      reset_results_in   IN   BOOLEAN := TRUE,
      from_suite_in      IN   BOOLEAN := FALSE,
      subprogram_in in varchar2 := '%',
      per_method_setup_in in boolean := FALSE
   );

   PROCEDURE runsuite (
      suite_in           IN   VARCHAR2,
      reset_results_in   IN   BOOLEAN := TRUE,
      per_method_setup_in in boolean := FALSE
   );

   /* Programs used in ut_PKG.setup */

   /* 1.3.2: Hide setpkg. Modifies global package state
             and is no longer needed by customer.

   PROCEDURE setpkg (
      package_in IN VARCHAR2,
      samepackage_in IN BOOLEAN := FALSE,
      prefix_in IN VARCHAR2 := NULL
   );
   */

   FUNCTION currpkg
      RETURN VARCHAR2;

   PROCEDURE addtest (
      package_in      IN   VARCHAR2,
      name_in         IN   VARCHAR2,
      prefix_in       IN   VARCHAR2,
      iterations_in   IN   PLS_INTEGER,
      override_in     IN   BOOLEAN
   );

   PROCEDURE addtest (
      name_in         IN   VARCHAR2,
      prefix_in       IN   VARCHAR2 := NULL,
      iterations_in   IN   PLS_INTEGER := 1,
      override_in     IN   BOOLEAN := FALSE
   );

   -- Not currently used.
   PROCEDURE setcase (case_in IN VARCHAR2);

   -- Not currently used.
   PROCEDURE setdata (
      dir_in     IN   VARCHAR2,
      file_in    IN   VARCHAR2,
      delim_in   IN   VARCHAR2 := ','
   );

   -- Not currently used.
   PROCEDURE passdata (data_in IN VARCHAR2, delim_in IN VARCHAR2 := ',');

   -- Utility programs

   PROCEDURE trc;

   PROCEDURE notrc;

   FUNCTION tracing
      RETURN BOOLEAN;

   FUNCTION version
      RETURN VARCHAR2;

   FUNCTION seqval (tab_in IN VARCHAR2)
      RETURN PLS_INTEGER;

   -- Constructs name of package and program based on factors
   -- such as same package or test package, prefix, etc.
   FUNCTION pkgname (
      package_in       IN   VARCHAR2,
      samepackage_in   IN   BOOLEAN,
      prefix_in        IN   VARCHAR2,
      ispkg_in         IN   BOOLEAN,
	  owner_in IN VARCHAR2 := NULL
   )
      RETURN VARCHAR2;

   FUNCTION progname (
      program_in       IN   VARCHAR2,
      samepackage_in   IN   BOOLEAN,
      prefix_in        IN   VARCHAR2,
      ispkg_in         IN   BOOLEAN
   )
      RETURN VARCHAR2;

   FUNCTION pkgname (
      package_in       IN   VARCHAR2,
      samepackage_in   IN   BOOLEAN,
      prefix_in        IN   VARCHAR2,
	  owner_in IN VARCHAR2 := NULL
   )
      RETURN VARCHAR2;

   FUNCTION progname (
      program_in       IN   VARCHAR2,
      samepackage_in   IN   BOOLEAN,
      prefix_in        IN   VARCHAR2
   )
      RETURN VARCHAR2;

   FUNCTION ifelse (bool_in IN BOOLEAN, tval_in IN BOOLEAN, fval_in IN BOOLEAN)
      RETURN BOOLEAN;

   FUNCTION ifelse (bool_in IN BOOLEAN, tval_in IN DATE, fval_in IN DATE)
      RETURN DATE;

   FUNCTION ifelse (bool_in IN BOOLEAN, tval_in IN NUMBER, fval_in IN NUMBER)
      RETURN NUMBER;

   FUNCTION ifelse (
      bool_in   IN   BOOLEAN,
      tval_in   IN   VARCHAR2,
      fval_in   IN   VARCHAR2
   )
      RETURN VARCHAR2;
END;
/

