CREATE OR REPLACE PACKAGE UTPIPE 
IS

/************************************************************************
GNU General Public License for utPLSQL

Copyright (C) 2000-2004
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

   -- DBMS_PIPE functionality based on code provided by John Beresniewicz,
   -- Savant Corp, in ORACLE BUILT-IN PACKAGES

   -- For pipe equality checking
   TYPE msg_rectype IS RECORD (
      item_type                     INTEGER,
      mvc2                          VARCHAR2 (4093),
      mdt                           DATE,
      mnum                          NUMBER,
      mrid                          ROWID,
      mraw                          RAW (4093));

   /*
 || msg_tbltype tables can hold an ordered list of
 || message items, thus any message can be captured
 */
   TYPE msg_tbltype IS TABLE OF msg_rectype
      INDEX BY BINARY_INTEGER; 

   PROCEDURE receive_and_unpack(pipe_in           IN       VARCHAR2,
      msg_tbl_out       OUT      msg_tbltype,
      pipe_status_out   IN OUT   PLS_INTEGER);
   
END UTPIPE;
/