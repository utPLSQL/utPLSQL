CREATE OR REPLACE PACKAGE utreceq &start_ge_8_1 AUTHID CURRENT_USER &end_ge_8_1
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

   PROCEDURE add(

      pkg_name_in IN ut_package.name%TYPE ,

      record_in  IN ut_receq.name%TYPE ,

      rec_owner_in  IN ut_receq.created_by%TYPE := USER

   );



   PROCEDURE compile(

      pkg_name_in     IN ut_package.name%TYPE

   );



   PROCEDURE rem(

      name_in  IN ut_receq.name%TYPE,

      rec_owner_in   IN ut_receq.created_by%TYPE := USER,

      for_package_in IN BOOLEAN := FALSE

   );



END utreceq;

/

