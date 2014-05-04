CREATE OR REPLACE VIEW utv_last_run
AS
   SELECT a.id utp_id, program, run_id last_run_id
     FROM ut_utp a,
          (SELECT   utp_id, MAX (run_id) run_id
               FROM utv_result_full
           GROUP BY utp_id) b
    WHERE a.id = b.utp_id(+);

