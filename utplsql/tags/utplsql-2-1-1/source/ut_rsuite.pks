/* Formatted on 2001/07/13 12:29 (RevealNet Formatter v4.4.1) */
CREATE OR REPLACE PACKAGE utrsuite
IS
   PROCEDURE terminate (
      run_id_in     IN   utr_suite.run_id%TYPE,
      suite_id_in   IN   utr_suite.suite_id%TYPE,
      end_on_in     IN   DATE := SYSDATE
   );

   PROCEDURE initiate (
      run_id_in     IN   utr_suite.run_id%TYPE,
      suite_id_in   IN   utr_suite.suite_id%TYPE,
      start_on_in   IN   DATE := SYSDATE
   );
END utrsuite;
/
