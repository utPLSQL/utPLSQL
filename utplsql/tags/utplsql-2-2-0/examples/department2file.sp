CREATE OR REPLACE PROCEDURE DEPARTMENT2file (
   loc IN VARCHAR2,
   file IN VARCHAR2 := 'DEPARTMENT.dat',
   delim IN VARCHAR2 := '|'
   )
IS
   fid UTL_FILE.FILE_TYPE;
   line VARCHAR2(32767);
BEGIN
   fid := UTL_FILE.FOPEN (loc, file, 'W');

   FOR rec IN (SELECT * FROM DEPARTMENT)
   LOOP
      line :=
         TO_CHAR (rec.DEPARTMENT_ID) || delim ||
         rec.NAME || delim ||
         TO_CHAR (rec.LOC_ID);
      UTL_FILE.PUT_LINE (fid, line);
   END LOOP;
   UTL_FILE.FCLOSE (fid);
END;
/