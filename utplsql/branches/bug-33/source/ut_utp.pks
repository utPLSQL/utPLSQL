CREATE OR REPLACE PACKAGE ututp
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

   c_name     CONSTANT CHAR (18) := 'UNIT TEST PACKAGE';
   c_abbrev   CONSTANT CHAR (3)  := 'UTP';

   /* UTP##NNN */
   FUNCTION NAME (utp_in IN ut_utp%ROWTYPE)
      RETURN VARCHAR2;

   FUNCTION NAME (id_in IN ut_utp.ID%TYPE)
      RETURN VARCHAR2;

   /* schema.UTP##NNN */
   FUNCTION qualified_name (utp_in IN ut_utp%ROWTYPE)
      RETURN VARCHAR2;

   FUNCTION qualified_name (id_in IN ut_utp.ID%TYPE)
      RETURN VARCHAR2;

   FUNCTION setup_procedure (utp_in IN ut_utp%ROWTYPE)
      RETURN VARCHAR2;

   FUNCTION teardown_procedure (utp_in IN ut_utp%ROWTYPE)
      RETURN VARCHAR2;

   /* V1 compatibility */
   FUNCTION prefix (utp_in IN ut_utp%ROWTYPE)
      RETURN VARCHAR2;

   FUNCTION onerow (
      owner_in     IN   ut_utp.owner%TYPE
     ,program_in   IN   ut_utp.program%TYPE
   )
      RETURN ut_utp%ROWTYPE;

   FUNCTION onerow (utp_id_in IN ut_utp.ID%TYPE)
      RETURN ut_utp%ROWTYPE;

   PROCEDURE get_onerow (
      owner_in                IN       ut_utp.owner%TYPE
     ,program_in              IN       ut_utp.program%TYPE
     ,id_out                  OUT      ut_utp.ID%TYPE
     ,description_out         OUT      ut_utp.description%TYPE
     ,filename_out            OUT      ut_utp.filename%TYPE 
     ,program_directory_out   OUT      ut_utp.program_directory%TYPE 
     ,directory_out           OUT      ut_utp.DIRECTORY%TYPE 
     ,name_out                OUT      ut_utp.NAME%TYPE 
     ,utp_owner_out           OUT      ut_utp.utp_owner%TYPE 
     ,prefix_out              OUT      ut_utp.prefix%TYPE 
   );

   FUNCTION EXISTS (
      owner_in     IN   ut_utp.owner%TYPE
     ,program_in   IN   ut_utp.program%TYPE
   )
      RETURN BOOLEAN;

   FUNCTION ID (NAME_IN IN VARCHAR2)
      RETURN ut_utp.ID%TYPE;

   PROCEDURE ADD (
      -- 2.0.7 name_in          IN   ut_utp.name%TYPE,
      program_in             IN   ut_utp.program%TYPE := NULL
     ,owner_in               IN   ut_utp.owner%TYPE := NULL
     ,description_in         IN   ut_utp.description%TYPE := NULL
     ,filename_in            IN   ut_utp.filename%TYPE := NULL
     ,frequency_in           IN   ut_utp.frequency%TYPE := NULL
     ,program_map_in         IN   ut_utp.program_map%TYPE := NULL
     ,declarations_in        IN   ut_utp.declarations%TYPE := NULL
     ,setup_in               IN   ut_utp.setup%TYPE := NULL
     ,teardown_in            IN   ut_utp.teardown%TYPE := NULL
     ,exceptions_in          IN   ut_utp.EXCEPTIONS%TYPE := NULL
     ,program_directory_in   IN   ut_utp.program_directory%TYPE := NULL
     ,directory_in           IN   ut_utp.DIRECTORY%TYPE := NULL
     ,NAME_IN                IN   ut_utp.NAME%TYPE := NULL
     ,utp_owner_in           IN   ut_utp.utp_owner%TYPE := NULL
     ,prefix_in              IN   ut_utp.prefix%TYPE := NULL
   -- V1 prefix_in        IN   ut_utp.prefix%TYPE := utconfig.c_prefix
   );

   PROCEDURE ADD (
      program_in             IN       ut_utp.program%TYPE := NULL
     ,owner_in               IN       ut_utp.owner%TYPE := NULL
     ,description_in         IN       ut_utp.description%TYPE := NULL
     ,filename_in            IN       ut_utp.filename%TYPE := NULL
     ,frequency_in           IN       ut_utp.frequency%TYPE := NULL
     ,program_map_in         IN       ut_utp.program_map%TYPE := NULL
     ,declarations_in        IN       ut_utp.declarations%TYPE := NULL
     ,setup_in               IN       ut_utp.setup%TYPE := NULL
     ,teardown_in            IN       ut_utp.teardown%TYPE := NULL
     ,exceptions_in          IN       ut_utp.EXCEPTIONS%TYPE := NULL
     ,program_directory_in   IN       ut_utp.program_directory%TYPE := NULL
     ,directory_in           IN       ut_utp.DIRECTORY%TYPE := NULL
     ,NAME_IN                IN       ut_utp.NAME%TYPE := NULL
     ,utp_owner_in           IN       ut_utp.utp_owner%TYPE := NULL
     ,prefix_in              IN       ut_utp.prefix%TYPE := NULL
     ,id_out                 OUT      ut_utp.ID%TYPE
   );

   PROCEDURE REM (NAME_IN IN VARCHAR2);

   PROCEDURE REM (id_in IN ut_utp.ID%TYPE);
   
   FUNCTION utps (
      program_like_in   IN   VARCHAR2 := '%'
   )
      RETURN utconfig.refcur_t;
   
END ututp;
/
