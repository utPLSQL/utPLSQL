CREATE OR REPLACE PROCEDURE testit (prog_in IN VARCHAR2, recompile_in in boolean := true)
IS
BEGIN
   utconfig.setdir ('d:\openoracle\utplsql\examples');
   utconfig.showconfig;
   utplsql.test (prog_in, recompile_in => recompile_in);
END;
/

