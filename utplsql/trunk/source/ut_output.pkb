CREATE OR REPLACE PACKAGE BODY utoutput
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

   g_temp_buffer               DBMS_OUTPUT.CHARARR;
   g_save_buffer               DBMS_OUTPUT.CHARARR;
   g_save                      BOOLEAN := FALSE;
   c_all_lines                 CONSTANT INTEGER := 1000000;       

   FUNCTION saving RETURN BOOLEAN
   IS
   BEGIN
     RETURN g_save;
   END;
   
   PROCEDURE save
   IS
   BEGIN
      g_save := TRUE;
   END;

   PROCEDURE nosave
   IS
   BEGIN
      g_save := FALSE;
   END;
   
   --Pull lines into given buffer and optionally
   --into the save buffer too.
   FUNCTION extract (
     buffer_out OUT DBMS_OUTPUT.CHARARR,
     max_lines_in IN INTEGER := NULL, 
      save_in IN BOOLEAN := saving
   ) RETURN INTEGER
   IS
     l_lines INTEGER := NVL(max_lines_in, c_all_lines);
      l_index BINARY_INTEGER;
   BEGIN
     buffer_out.DELETE;

     DBMS_OUTPUT.Get_Lines(buffer_out, l_lines);
      
      --Remove the extra empty lines 
      WHILE l_lines < buffer_out.COUNT LOOP
        buffer_out.DELETE(buffer_out.LAST);
      END LOOP;
      
      --Append to save buffer
      IF save_in THEN
        l_index := buffer_out.FIRST;
        WHILE l_index IS NOT NULL LOOP
          g_save_buffer(NVL(g_save_buffer.LAST,0) + 1) := buffer_out(l_index);
          l_index := buffer_out.NEXT(l_index);
        END LOOP;
      END IF;
      
      RETURN l_lines;
   END;

   --Get the output ignoring number of lines returned.
   PROCEDURE extract (
     buffer_out OUT DBMS_OUTPUT.CHARARR,
     max_lines_in IN INTEGER := NULL,
     save_in IN BOOLEAN := saving
   )
   IS
     l_lines INTEGER;
   BEGIN
     l_lines := extract(buffer_out, max_lines_in, save_in);
   END;

   --Get the output ignoring the data itself
   FUNCTION extract (
     max_lines_in IN INTEGER := NULL,
     save_in IN BOOLEAN := saving
   ) RETURN INTEGER
   IS
   BEGIN
     RETURN extract(g_temp_buffer, max_lines_in, save_in);
   END;
      
   --Get the output ignoring number of lines returned
   --and ignoring the data itself
   PROCEDURE extract (
     max_lines_in IN INTEGER := NULL,
     save_in IN BOOLEAN := saving
   )
   IS
   BEGIN
     extract(g_temp_buffer, max_lines_in, save_in);
   END;
      
   --Put a buffer back into DBMS_OUTPUT buffer.
   PROCEDURE replace(buffer_inout IN OUT DBMS_OUTPUT.CHARARR)
   IS
     l_index BINARY_INTEGER;
   BEGIN
     l_index := buffer_inout.FIRST;
      WHILE l_index IS NOT NULL LOOP
        DBMS_OUTPUT.Put_Line(buffer_inout(l_index));
        l_index := buffer_inout.NEXT(l_index);
      END LOOP;
      buffer_inout.DELETE;
   END;

   --Put the save buffer back into the DBMS_OUTPUT buffer
   PROCEDURE replace
   IS
   BEGIN
     replace(g_save_buffer);
   END;

   --Pull out the next line from the DBMS_OUTPUT buffer
   FUNCTION nextLine(raise_exc_in BOOLEAN := TRUE, save_in BOOLEAN := saving) RETURN VARCHAR2
   IS
     l_lines INTEGER;
   BEGIN

     l_lines := extract(buffer_out => g_temp_buffer, 
                        max_lines_in => 1, 
                        save_in => save_in);   

      IF l_lines <> 1 THEN
     
       IF raise_exc_in THEN
         RAISE EMPTY_OUTPUT_BUFFER;
       ELSE
          RETURN NULL;
       END IF;
      ELSE
        RETURN g_temp_buffer(g_temp_buffer.FIRST);
     END IF;
     
   END;
   
   --Simply count the number of lines in the DBMS_OUTPUT buffer
   --but don't remove anything
   FUNCTION count RETURN INTEGER
   IS
     l_lines INTEGER;
   BEGIN
     l_lines := extract(buffer_out => g_temp_buffer, 
                    max_lines_in => c_all_lines, 
                    save_in => FALSE);
     replace(g_temp_buffer);
     RETURN l_lines;
   END;

END utoutput;
/
