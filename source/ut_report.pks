CREATE OR REPLACE PACKAGE utreport &start81 AUTHID CURRENT_USER &end81
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
$Log

************************************************************************/

   outcome utr_outcome%ROWTYPE;
   error utr_error%ROWTYPE;

   PROCEDURE use(reporter IN VARCHAR2);
   FUNCTION using RETURN VARCHAR2;

   PROCEDURE open;
   
   PROCEDURE pl (str IN VARCHAR2);
   PROCEDURE pl (bool IN BOOLEAN);

   PROCEDURE before_results(run_id IN utr_outcome.run_id%TYPE);
   PROCEDURE show_failure(rec_result utr_outcome%ROWTYPE);
   PROCEDURE show_result(rec_result utr_outcome%ROWTYPE);
   PROCEDURE after_results(run_id IN utr_outcome.run_id%TYPE);
   
   PROCEDURE before_errors(run_id IN utr_error.run_id%TYPE);
   PROCEDURE show_error(rec_error utr_error%ROWTYPE);
   PROCEDURE after_errors(run_id IN utr_error.run_id%TYPE);

   PROCEDURE close;

END;
/
