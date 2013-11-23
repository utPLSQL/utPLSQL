/* Formatted on 2001/07/13 12:29 (RevealNet Formatter v4.4.1) */
CREATE OR REPLACE PACKAGE utoutcome
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
Revision 1.2  2003/07/01 19:36:46  chrisrimmer
Added Standard Headers

************************************************************************/

   c_name     CONSTANT CHAR (7) := 'OUTCOME';
   c_abbrev   CONSTANT CHAR (2) := 'OC';

   FUNCTION name (outcome_id_in IN ut_outcome.id%TYPE)
      RETURN ut_outcome.name%TYPE;

   FUNCTION id (name_in IN ut_outcome.name%TYPE)
      RETURN ut_outcome.id%TYPE;

   FUNCTION onerow (name_in IN ut_outcome.name%TYPE)
      RETURN ut_outcome%ROWTYPE;

   FUNCTION onerow (outcome_id_in IN ut_outcome.id%TYPE)
      RETURN ut_outcome%ROWTYPE;

   FUNCTION utp (outcome_id_in IN ut_outcome.id%TYPE)
      RETURN ut_utp.id%TYPE;

   PRAGMA restrict_references (utp, WNDS, WNPS);

   FUNCTION unittest (outcome_id_in IN ut_outcome.id%TYPE)
      RETURN ut_unittest.id%TYPE;

   PRAGMA restrict_references (unittest, WNDS, WNPS);
END utoutcome;
/
