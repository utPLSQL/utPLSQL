BEGIN
   -- Define a test suite for PL/Vision
   utsuite.add ('PLVision');
   
   -- Add two packages for testing
   utpackage.add (
      'PLVision', 'PLVstr', dir_in => 'e:\openoracle\utplsql\examples');
   utpackage.add (
      'PLVision', 'PLVdate', dir_in => 'e:\openoracle\utplsql\examples');
   
   -- Run the test suite
   utplsql.testsuite (
      'PLVision', recompile_in => TRUE);
END;
/
   
