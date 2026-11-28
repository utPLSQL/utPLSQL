SET SCAN OFF
SET DEFINE OFF
SET SERVEROUTPUT ON

DECLARE
BEGIN
  DBMS_OUTPUT.PUT_LINE('=== PERF BENCHMARK: perf_suite_comprehensive (1,200 tests with hooks/failures) - feature/optimization ===');
  
  DBMS_OUTPUT.PUT_LINE('Step 1: Warm-up run');
  ut.run('perf_suite_comprehensive');
  DBMS_OUTPUT.PUT_LINE('  Warm-up complete');

  DBMS_OUTPUT.PUT_LINE('');
  DBMS_OUTPUT.PUT_LINE('Step 2: AWR snapshot + 3 measured runs + AWR snapshot');
  
  DBMS_WORKLOAD_REPOSITORY.create_snapshot;
  DBMS_OUTPUT.PUT_LINE('  AWR snapshot 1 taken');

  perf_harness.run_suite('perf_suite_comprehensive', 'meas_comp1200_r1');
  perf_harness.run_suite('perf_suite_comprehensive', 'meas_comp1200_r2');
  perf_harness.run_suite('perf_suite_comprehensive', 'meas_comp1200_r3');

  DBMS_WORKLOAD_REPOSITORY.create_snapshot;
  DBMS_OUTPUT.PUT_LINE('  AWR snapshot 2 taken');

  DBMS_OUTPUT.PUT_LINE('');
  DBMS_OUTPUT.PUT_LINE('Benchmark complete.');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('ERROR: ' || sqlerrm);
    RAISE;
END;
/