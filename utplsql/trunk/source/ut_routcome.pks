CREATE OR REPLACE PACKAGE utroutcome
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

   PROCEDURE RECORD (
      run_id_in IN utr_outcome.run_id%TYPE
    , tc_run_id_in IN PLS_INTEGER
    , outcome_id_in IN utr_outcome.outcome_id%TYPE
    , test_failed_in IN BOOLEAN
    , description_in IN VARCHAR2 := NULL
    , end_on_in IN DATE := SYSDATE
   );

   PROCEDURE initiate (
      run_id_in IN utr_outcome.run_id%TYPE
    , outcome_id_in IN utr_outcome.outcome_id%TYPE
    , start_on_in IN DATE := SYSDATE
   );

   FUNCTION next_v1_id (run_id_in IN utr_outcome.run_id%TYPE)
      RETURN utr_outcome.outcome_id%TYPE;

   PROCEDURE clear_results (run_id_in IN utr_outcome.run_id%TYPE);

   PROCEDURE clear_results (
      owner_in IN VARCHAR2
    , program_in IN VARCHAR2
    , start_from_in IN DATE
   );

   PROCEDURE clear_all_but_last (owner_in IN VARCHAR2, program_in IN VARCHAR2);
END utroutcome;
/

