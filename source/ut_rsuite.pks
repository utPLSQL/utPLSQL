/* Formatted on 2001/07/13 12:29 (RevealNet Formatter v4.4.1) */
CREATE OR REPLACE PACKAGE utrsuite
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
************************************************************************/

   PROCEDURE terminate (
      run_id_in     IN   utr_suite.run_id%TYPE,
      suite_id_in   IN   utr_suite.suite_id%TYPE,
      end_on_in     IN   DATE := SYSDATE
   );

   PROCEDURE initiate (
      run_id_in     IN   utr_suite.run_id%TYPE,
      suite_id_in   IN   utr_suite.suite_id%TYPE,
      start_on_in   IN   DATE := SYSDATE
   );
END utrsuite;
/
