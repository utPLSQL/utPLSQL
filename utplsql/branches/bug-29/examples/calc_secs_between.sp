CREATE OR REPLACE PROCEDURE calc_secs_between (
   date1 IN DATE,
   date2 IN DATE,
   secs OUT NUMBER
)
IS
BEGIN
   secs := (date2 - date1) * 24 * 60 * 60;
END;
/
