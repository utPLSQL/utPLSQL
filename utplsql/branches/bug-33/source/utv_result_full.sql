CREATE OR REPLACE VIEW utv_result_full
AS
   SELECT utp.id utp_id, program, ut.id unittest_id,
          tc.id testcase_id, utr.outcome_id, run_id,
          start_on, end_on, utr.status, utr.description
     FROM ut_utp utp,
          ut_unittest ut,
          ut_testcase tc,
          ut_outcome oc,
          utr_outcome utr
    WHERE utp.id = ut.utp_id
      AND ut.id = tc.unittest_id
      AND tc.id = oc.testcase_id
      AND oc.id = utr.outcome_id;
