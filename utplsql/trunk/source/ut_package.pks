/* Formatted on 2001/07/13 12:29 (RevealNet Formatter v4.4.1) */
CREATE OR REPLACE PACKAGE utpackage -- &start_ge_8_1 AUTHID CURRENT_USER &end_ge_8_1
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

   c_success   CONSTANT VARCHAR2 (7) := 'SUCCESS';
   c_failure   CONSTANT VARCHAR2 (7) := 'FAILURE';

   FUNCTION name_from_id (id_in IN ut_package.id%TYPE)
      RETURN ut_package.name%TYPE;

   FUNCTION id_from_name (name_in IN ut_package.name%TYPE,
       owner_in		  IN ut_package.owner%TYPE := NULL)
      RETURN ut_package.id%TYPE;

   PROCEDURE ADD (
      suite_in            IN   VARCHAR2,
      package_in          IN   VARCHAR2,
      samepackage_in      IN   BOOLEAN := FALSE,
      prefix_in           IN   VARCHAR2 := NULL,
      dir_in              IN   VARCHAR2 := NULL,
      seq_in              IN   PLS_INTEGER := NULL,
      owner_in            IN   VARCHAR2 := NULL,
      add_tests_in        IN   BOOLEAN := FALSE,
      test_overloads_in   IN   BOOLEAN := FALSE
   );

   PROCEDURE rem (
      suite_in     IN   VARCHAR2,
      package_in   IN   VARCHAR2,
      owner_in     IN   VARCHAR2 := NULL
   );

   PROCEDURE upd (
      suite_in        IN   VARCHAR2,
      package_in      IN   VARCHAR2,
      start_in             DATE,
      end_in               DATE,
      successful_in        BOOLEAN,
      owner_in        IN   VARCHAR2 := NULL
   );

   PROCEDURE ADD (
      suite_in            IN   INTEGER,
      package_in          IN   VARCHAR2,
      samepackage_in      IN   BOOLEAN := FALSE,
      prefix_in           IN   VARCHAR2 := NULL,
      dir_in              IN   VARCHAR2 := NULL,
      seq_in              IN   PLS_INTEGER := NULL,
      owner_in            IN   VARCHAR2 := NULL,
      add_tests_in        IN   BOOLEAN := FALSE,
      test_overloads_in   IN   BOOLEAN := FALSE
   );

   PROCEDURE rem (
      suite_in     IN   INTEGER,
      package_in   IN   VARCHAR2,
      owner_in     IN   VARCHAR2 := NULL
   );

   PROCEDURE upd (
      suite_id_in        IN   INTEGER,
      package_in      IN   VARCHAR2,
      start_in             DATE,
      end_in               DATE,
      successful_in        BOOLEAN,
      owner_in        IN   VARCHAR2 := NULL
   );
END utpackage;
/
