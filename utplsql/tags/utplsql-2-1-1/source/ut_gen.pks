CREATE OR REPLACE PACKAGE utgen 
&start81 
AUTHID CURRENT_USER
&end81
IS 
   
/*
GNU General Public License for utPLSQL

Copyright (C) 2000 Steven Feuerstein, steven@stevenfeuerstein.com

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
/*
11/2001 SEF Add receq_package based on functionality provided by Dan Spencer.
09/2002 PBA Add testpkg_from_table functionality. Depends upon table ut_grid for
            input.
*/
   c_screen    CONSTANT PLS_INTEGER    := 1;
   c_string    CONSTANT PLS_INTEGER    := 2;
   c_file      CONSTANT PLS_INTEGER    := 3;
   c_array     CONSTANT PLS_INTEGER    := 4;
   c_delim     CONSTANT CHAR (1)       := ';';
   c_comment   CONSTANT CHAR (1)       := '#';
   c_asis      CONSTANT CHAR (1)       := '!';
   &start81 SUBTYPE codeline_t IS VARCHAR2(200); &end81

   &start73
   v_codeline           VARCHAR2 (200);

   SUBTYPE codeline_t IS v_codeline%TYPE;

   &end73

   -- Each line in the grid represents a test case 
   -- 

   TYPE grid_rt IS RECORD (
      progname         VARCHAR2 (100),
      overload         PLS_INTEGER,
      tcname           VARCHAR2 (100),
      MESSAGE          VARCHAR2 (2000),
      arglist          VARCHAR2 (2000),
      return_value     VARCHAR2 (2000),
      assertion_type   VARCHAR2 (100)
   );

   TYPE grid_tt IS TABLE OF grid_rt
      INDEX BY BINARY_INTEGER;

   PROCEDURE testpkg (
      package_in       IN   VARCHAR2,
      program_in       IN   VARCHAR2 := '%',
      samepackage_in   IN   BOOLEAN := FALSE ,
      prefix_in        IN   VARCHAR2 := NULL,
      schema_in        IN   VARCHAR2 := NULL,
      output_type_in   IN   PLS_INTEGER := c_screen,
      dir_in           IN   VARCHAR2 := NULL,
	  override_file_in IN   VARCHAR2 := NULL
   );

   PROCEDURE testpkg (
      package_in           IN   VARCHAR2,
      grid_in              IN   grid_tt,
      program_in           IN   VARCHAR2 := '%',
      samepackage_in       IN   BOOLEAN := FALSE ,
      prefix_in            IN   VARCHAR2 := NULL,
      schema_in            IN   VARCHAR2 := NULL,
      output_type_in       IN   PLS_INTEGER := c_screen,
      dir_in               IN   VARCHAR2 := NULL,
      delim_in             IN   VARCHAR2 := c_delim,
      date_format_in       IN   VARCHAR2 := 'MM/DD/YYYY',
      only_if_in_grid_in   IN   BOOLEAN := FALSE,
	  override_file_in IN   VARCHAR2 := NULL
   );

   PROCEDURE testpkg_from_file (
      package_in           IN   VARCHAR2,
      gridfile_loc_in      IN   VARCHAR2,
      gridfile_in          IN   VARCHAR2,
      program_in           IN   VARCHAR2 := '%',
      samepackage_in       IN   BOOLEAN := FALSE ,
      prefix_in            IN   VARCHAR2 := NULL,
      schema_in            IN   VARCHAR2 := NULL,
      output_type_in       IN   PLS_INTEGER := c_screen,
      dir_in               IN   VARCHAR2 := NULL,
      field_delim_in       IN   VARCHAR2 := '|',
      arg_delim_in         IN   VARCHAR2 := c_delim,
      date_format_in       IN   VARCHAR2 := 'MM/DD/YYYY',
      only_if_in_grid_in   IN   BOOLEAN := FALSE,
	  override_file_in IN   VARCHAR2 := NULL
   );

   PROCEDURE testpkg_from_string (
      package_in           IN   VARCHAR2,
      grid_in              IN   VARCHAR2,
      program_in           IN   VARCHAR2 := '%',
      samepackage_in       IN   BOOLEAN := FALSE ,
      prefix_in            IN   VARCHAR2 := NULL,
      schema_in            IN   VARCHAR2 := NULL,
      output_type_in       IN   PLS_INTEGER := c_screen,
      dir_in               IN   VARCHAR2 := NULL,
      line_delim_in        IN   VARCHAR := CHR (10),
      field_delim_in       IN   VARCHAR2 := '|',
      arg_delim_in         IN   VARCHAR2 := c_delim,
      date_format_in       IN   VARCHAR2 := 'MM/DD/YYYY',
      only_if_in_grid_in   IN   BOOLEAN := FALSE,
	  override_file_in IN   VARCHAR2 := NULL
   );

   PROCEDURE testpkg_from_string_od (
      package_in   IN   VARCHAR2,
      grid_in      IN   VARCHAR2,
      dir_in       IN   VARCHAR2 := NULL,
	  override_file_in IN   VARCHAR2 := NULL
   );

   -- Retrieve single string with generated package.
   FUNCTION pkgstring
      RETURN VARCHAR2;

   -- Retrieve individual lines of code in generated package

   FUNCTION nthrow (nth IN PLS_INTEGER, direction IN SIGNTYPE := 1)
      RETURN codeline_t;

   FUNCTION countrows
      RETURN PLS_INTEGER;

   FUNCTION firstrow
      RETURN PLS_INTEGER;

   FUNCTION firstbodyrow
      RETURN PLS_INTEGER;

   FUNCTION atfirstrow
      RETURN BOOLEAN;

   FUNCTION lastrow
      RETURN PLS_INTEGER;

   FUNCTION atlastrow
      RETURN BOOLEAN;

   PROCEDURE setrow (nth IN PLS_INTEGER);

   FUNCTION getrow
      RETURN codeline_t;

   PROCEDURE nextrow;

   PROCEDURE prevrow;

   PROCEDURE showrows (
      startrow   IN   PLS_INTEGER := NULL,
      endrow     IN   PLS_INTEGER := NULL
   );

   FUNCTION isfunction (
      schema_in     IN   VARCHAR2,
      package_in    IN   VARCHAR2,
      program_in    IN   VARCHAR2,
      overload_in   IN   PLS_INTEGER := NULL
   )
      RETURN BOOLEAN;

   -- 2.0.10.1  From Patrick Barel
   PROCEDURE add_to_grid (
      owner_in            IN   ut_grid.owner%TYPE
	 ,package_in          IN   ut_grid.PACKAGE%TYPE
     ,progname_in         IN   ut_grid.progname%TYPE
     ,overload_in         IN   ut_grid.overload%TYPE
     ,tcname_in           IN   ut_grid.tcname%TYPE
     ,message_in          IN   ut_grid.MESSAGE%TYPE
     ,arglist_in          IN   ut_grid.arglist%TYPE
     ,return_value_in     IN   ut_grid.return_value%TYPE
     ,assertion_type_in   IN   ut_grid.assertion_type%TYPE
   );
   
   PROCEDURE clear_grid (
      owner_in            IN   ut_grid.owner%TYPE
	 ,package_in          IN   ut_grid.PACKAGE%TYPE);
   
   /* START Patch72 607131 */
   PROCEDURE testpkg_from_table (
      package_in       IN   VARCHAR2,
      program_in       IN   VARCHAR2 := '%',
      samepackage_in   IN   BOOLEAN := FALSE ,
      prefix_in        IN   VARCHAR2 := NULL,
      schema_in        IN   VARCHAR2 := NULL,
      output_type_in   IN   PLS_INTEGER := c_screen,
      dir_in           IN   VARCHAR2 := NULL,
      date_format_in   IN   VARCHAR2 := 'MM/DD/YYYY',
	  override_file_in IN   VARCHAR2 := NULL
   );
/* END Patch72 607131 */

/*   -- 2.0.8 Implementation provided by Dan Spencer!
   PROCEDURE receq_package (
      table_in   IN   VARCHAR2,
      pkg_in     IN   VARCHAR2 := NULL,
      owner_in   IN   VARCHAR2 := NULL
   );
*/
END;
/
