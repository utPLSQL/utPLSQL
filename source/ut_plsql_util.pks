CREATE OR REPLACE PACKAGE utplsql_util
AS 

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

   TYPE SQLDATA IS RECORD (
      col_name   VARCHAR2 (50),
      col_type   PLS_INTEGER,
      col_len    PLS_INTEGER
   );

   TYPE sqldata_tab IS TABLE OF SQLDATA
      INDEX BY BINARY_INTEGER;

   TYPE params_rec IS RECORD (
      par_name       VARCHAR2 (50),
      par_type       VARCHAR2 (10),
      par_sql_type   VARCHAR2 (50),
      par_inout      PLS_INTEGER,
      par_pos        PLS_INTEGER,
      par_val        VARCHAR2 (32000)
   );

   TYPE utplsql_array IS RECORD (
      array_pos   PLS_INTEGER,
      array_val   VARCHAR2 (32000)
   );

   TYPE utplsql_params IS TABLE OF params_rec
      INDEX BY BINARY_INTEGER;

   TYPE array_table IS TABLE OF utplsql_array
      INDEX BY BINARY_INTEGER;

   TYPE ut_refc IS REF CURSOR;

   TYPE v30_table IS TABLE OF VARCHAR2 (30)
      INDEX BY BINARY_INTEGER;

   TYPE varchar_array IS TABLE OF VARCHAR2 (4000)
      INDEX BY BINARY_INTEGER;

   array_holder   array_table;

   PROCEDURE reg_in_param (
      par_pos            PLS_INTEGER,
      par_val            VARCHAR2,
      params    IN OUT   utplsql_params
   );

   PROCEDURE reg_in_array (
      par_pos      IN       PLS_INTEGER,
      array_name   IN       VARCHAR2,
      array_vals   IN       varchar_array,
      params       IN OUT   utplsql_params
   );

   PROCEDURE reg_in_param (
      par_pos            PLS_INTEGER,
      par_val            NUMBER,
      params    IN OUT   utplsql_params
   );

   PROCEDURE reg_in_param (
      par_pos            PLS_INTEGER,
      par_val            DATE,
      params    IN OUT   utplsql_params
   );

   PROCEDURE reg_inout_param (
      par_pos            PLS_INTEGER,
      par_val            VARCHAR2,
      params    IN OUT   utplsql_params
   );

   PROCEDURE reg_inout_param (
      par_pos            PLS_INTEGER,
      par_val            NUMBER,
      params    IN OUT   utplsql_params
   );

   PROCEDURE reg_inout_param (
      par_pos            PLS_INTEGER,
      par_val            DATE,
      params    IN OUT   utplsql_params
   );

   PROCEDURE reg_out_param (
      par_pos             PLS_INTEGER,
      par_type            VARCHAR2,
      params     IN OUT   utplsql_params
   );

   PROCEDURE get_table_for_str (
      p_arr         OUT   v30_table,
      p_string            VARCHAR2,
      delim               VARCHAR2 := ',',
      enclose_str         VARCHAR2 DEFAULT NULL
   );

   PROCEDURE get_metadata_for_cursor (
      proc_name         VARCHAR2,
      metadata    OUT   sqldata_tab
   );

   PROCEDURE get_metadata_for_query (
      query_txt         VARCHAR2,
      metadata    OUT   sqldata_tab
   );

   PROCEDURE get_metadata_for_table (
      table_name         VARCHAR2,
      metadata     OUT   sqldata_tab
   );

   PROCEDURE get_metadata_for_proc (
      proc_name         VARCHAR2,
      POSITION          INTEGER,
      data_type   OUT   VARCHAR2,
      metadata    OUT   sqldata_tab
   );

   PROCEDURE test_get_metadata_for_cursor (proc_name VARCHAR2);

   PROCEDURE print_metadata (metadata sqldata_tab);

   FUNCTION get_colnamesstr (metadata sqldata_tab)
      RETURN VARCHAR2;

   FUNCTION get_coltypesstr (metadata sqldata_tab)
      RETURN VARCHAR2;

   FUNCTION get_coltype_syntax (col_type PLS_INTEGER, col_len PLS_INTEGER)
      RETURN VARCHAR2;

   PROCEDURE PRINT (str VARCHAR2);

   FUNCTION get_proc_name (p_proc_nm VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION get_version
      RETURN VARCHAR2;

   FUNCTION get_val_for_table (
      table_name         VARCHAR2,
      col_name           VARCHAR2,
      col_val      OUT   VARCHAR2,
      col_type     OUT   NUMBER
   )
      RETURN NUMBER;

   FUNCTION get_table_name
      RETURN VARCHAR2;

   PROCEDURE execute_ddl (stmt VARCHAR2);

   FUNCTION get_create_ddl (
      metadata     utplsql_util.sqldata_tab,
      table_name   VARCHAR2,
      owner_name   VARCHAR2 DEFAULT NULL
   )
      RETURN VARCHAR2;

   PROCEDURE prepare_cursor_1 (
      stmt             IN OUT   VARCHAR2,
      table_name                VARCHAR2,
      call_proc_name            VARCHAR2,
      metadata                  utplsql_util.sqldata_tab
   );

   FUNCTION prepare_and_fetch_rc (proc_name VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION prepare_and_fetch_rc (
      proc_name            VARCHAR2,
      params               utplsql_params,
      refc_pos_in_proc     PLS_INTEGER,
      refc_metadata_from   PLS_INTEGER DEFAULT 1,
      refc_metadata_str    VARCHAR2 DEFAULT NULL
   )
      RETURN VARCHAR2;
END;
/
