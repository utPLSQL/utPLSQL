CREATE OR REPLACE PACKAGE utoutput
&start81 AUTHID CURRENT_USER &end81
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
/*Modification History:
chrisrimmer      03-Apr-2002  Created
*/
   
   EMPTY_OUTPUT_BUFFER EXCEPTION;
   
   FUNCTION saving RETURN BOOLEAN;
   
   PROCEDURE save;

   PROCEDURE nosave;

   PROCEDURE replace;

   FUNCTION extract (
     buffer_out OUT DBMS_OUTPUT.CHARARR,
     max_lines_in   IN INTEGER := NULL, 
	 save_in IN BOOLEAN := saving
   ) RETURN INTEGER;

   PROCEDURE extract (
     buffer_out OUT DBMS_OUTPUT.CHARARR,
     max_lines_in   IN INTEGER := NULL, 
	 save_in IN BOOLEAN := saving
   );

   FUNCTION extract(
      max_lines_in       IN INTEGER := NULL,
	  save_in     IN BOOLEAN := saving
   ) RETURN INTEGER;
     
   PROCEDURE extract(
      max_lines_in IN INTEGER := NULL,
	  save_in IN BOOLEAN := saving
   );
   
   FUNCTION nextLine(raise_exc_in BOOLEAN := TRUE, save_in BOOLEAN := saving) RETURN VARCHAR2;
      
   FUNCTION count RETURN INTEGER;

END utoutput;
/   
