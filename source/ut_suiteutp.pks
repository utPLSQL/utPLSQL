CREATE OR REPLACE PACKAGE utsuiteutp -- &start81 AUTHID CURRENT_USER &end81
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

   c_name     CONSTANT CHAR (18) := 'SUITE-UTP PACKAGE';
   c_abbrev   CONSTANT CHAR (9)  := 'SUITE-UTP';

   FUNCTION defined (
      suite_id_in   IN   ut_suite.ID%TYPE
     ,utp_id_in     IN   ut_utp.ID%TYPE
   )
      RETURN BOOLEAN;

   FUNCTION seq (
      suite_id_in   IN   ut_suite.ID%TYPE
     ,utp_id_in     IN   ut_utp.ID%TYPE
   )
      RETURN ut_suite_utp.seq%TYPE;

   PROCEDURE ADD (
      suite_id_in   IN   ut_suite.ID%TYPE
     ,utp_id_in     IN   ut_utp.ID%TYPE
     ,seq_in        IN   ut_suite_utp.seq%TYPE := NULL
     ,enabled_in    IN   ut_suite_utp.enabled%TYPE := NULL
   );

   FUNCTION enabled (
      suite_id_in   IN   ut_suite.ID%TYPE
     ,utp_id_in     IN   ut_utp.ID%TYPE
   )
      RETURN ut_suite_utp.enabled%TYPE;

   PROCEDURE REM (
      suite_id_in   IN   ut_suite.ID%TYPE
     ,utp_id_in     IN   ut_utp.ID%TYPE
   );
   
   FUNCTION utps (
      suite_in in ut_suite.name%TYPE
   )
      RETURN utconfig.refcur_t; 
	  
   FUNCTION utps (
      suite_in in ut_suite.id%TYPE
   )
      RETURN utconfig.refcur_t;	    
END utsuiteutp;
/
