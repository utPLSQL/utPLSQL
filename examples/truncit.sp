CREATE OR REPLACE PROCEDURE truncit (
   tab IN VARCHAR2,
   sch IN VARCHAR2 := NULL
)
IS
BEGIN
   EXECUTE IMMEDIATE 'truncate table ' || NVL (sch, USER) || '.' || tab;
END;
/