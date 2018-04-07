DECLARE
   l_results  ut_varchar2_list;
   l_clob     CLOB;
   l_expected VARCHAR2(32767);
BEGIN
   l_expected := '%<h3>UT3.TEST_REPORTERS_1</h3>%';
   SELECT * BULK COLLECT
   INTO   l_results
   FROM   TABLE(ut.run('test_reporters_1', ut_coverage_html_reporter()));
   l_clob := ut3.ut_utils.table_to_clob(l_results);

   IF l_clob LIKE l_expected THEN
      :test_result := ut3.ut_utils.gc_success;
   ELSE
      dbms_output.put_line('Failed to match to default schema');
   END IF;

END;
/