/* Formatted on 2001/07/13 12:29 (RevealNet Formatter v4.4.1) */
CREATE OR REPLACE PACKAGE utresult
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

   /* Test result record structure */
   TYPE result_rt IS RECORD (
      name                          VARCHAR2 (100),
      msg                           VARCHAR2 (32767),
      indx                          PLS_INTEGER,
      status                        BOOLEAN /* V2 */);

   TYPE result_tt IS TABLE OF result_rt
      INDEX BY BINARY_INTEGER;

   results   result_tt;

   PROCEDURE report (msg_in IN VARCHAR2);

   PROCEDURE show (
      run_id_in   IN   utr_outcome.run_id%TYPE := NULL,
      reset_in    IN   BOOLEAN := FALSE
   );

   PROCEDURE showone (
      run_id_in   IN   utr_outcome.run_id%TYPE := NULL,
      indx_in     IN   PLS_INTEGER
   );

   PROCEDURE showlast (run_id_in IN utr_outcome.run_id%TYPE := NULL);

   PROCEDURE showresults (
      success_in   IN   BOOLEAN,
      program_in   IN   VARCHAR2,
      run_id_in    IN   utr_outcome.run_id%TYPE := NULL
   );

   PROCEDURE init (from_suite_in IN BOOLEAN := FALSE);

   FUNCTION success (run_id_in IN utr_outcome.run_id%TYPE := NULL)
      RETURN BOOLEAN;

   FUNCTION failure (run_id_in IN utr_outcome.run_id%TYPE := NULL)
      RETURN BOOLEAN;

   PROCEDURE firstresult (run_id_in IN utr_outcome.run_id%TYPE := NULL);

   FUNCTION nextresult (run_id_in IN utr_outcome.run_id%TYPE := NULL)
      RETURN result_rt;

   PROCEDURE nextresult (
      name_out        OUT      VARCHAR2,
      msg_out         OUT      VARCHAR2,
      case_indx_out   OUT      PLS_INTEGER,
      run_id_in       IN       utr_outcome.run_id%TYPE := NULL
   );

   FUNCTION nthresult (
      indx_in     IN   PLS_INTEGER,
      run_id_in   IN   utr_outcome.run_id%TYPE := NULL
   )
      RETURN result_rt;

   PROCEDURE nthresult (
      indx_in         IN       PLS_INTEGER,
      name_out        OUT      VARCHAR2,
      msg_out         OUT      VARCHAR2,
      case_indx_out   OUT      PLS_INTEGER,
      run_id_in       IN       utr_outcome.run_id%TYPE := NULL
   );

   FUNCTION resultcount (run_id_in IN utr_outcome.run_id%TYPE := NULL)
      RETURN PLS_INTEGER;
      
      procedure include_successes;      
      procedure ignore_successes;
      
END utresult;
/
