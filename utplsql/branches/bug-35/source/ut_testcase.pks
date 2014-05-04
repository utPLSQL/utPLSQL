/* Formatted on 2001/07/13 12:29 (RevealNet Formatter v4.4.1) */
CREATE OR REPLACE PACKAGE uttestcase -- &start_ge_8_1 AUTHID CURRENT_USER &end_ge_8_1
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

   c_name     CONSTANT CHAR (9) := 'TEST CASE';
   c_abbrev   CONSTANT CHAR (3) := 'TC';

   FUNCTION name_from_id (id_in IN ut_testcase.id%TYPE)
      RETURN ut_testcase.name%TYPE;

   FUNCTION id_from_name (name_in IN ut_testcase.name%TYPE)
      RETURN ut_testcase.id%TYPE;

   PROCEDURE ADD (
      test_in       IN   INTEGER,
      testcase_in   IN   VARCHAR2,
      desc_in       IN   VARCHAR2 := NULL,
      seq_in        IN   PLS_INTEGER := NULL
   );

   PROCEDURE ADD (
      test_in       IN   VARCHAR2,
      testcase_in   IN   VARCHAR2,
      desc_in       IN   VARCHAR2 := NULL,
      seq_in        IN   PLS_INTEGER := NULL
   );

   PROCEDURE rem (test_in IN INTEGER, testcase_in IN VARCHAR2);

   PROCEDURE rem (test_in IN VARCHAR2, testcase_in IN VARCHAR2);

   PROCEDURE upd (
      test_in         IN   INTEGER,
      testcase_in     IN   VARCHAR2,
      start_in             DATE,
      end_in               DATE,
      successful_in        BOOLEAN
   );

   PROCEDURE upd (
      test_in         IN   VARCHAR2,
      testcase_in     IN   VARCHAR2,
      start_in             DATE,
      end_in               DATE,
      successful_in        BOOLEAN
   );
END uttestcase;
/
