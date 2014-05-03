CREATE OR REPLACE PACKAGE BODY ut_te_employee
IS
   g_rowcount1 PLS_INTEGER;
   g_rowcount2 PLS_INTEGER;

   FUNCTION recseq (
      rec1 IN te_employee.i_employee_name_rt,
      rec2 IN te_employee.i_employee_name_rt
   )
      RETURN BOOLEAN
   IS
      unequal_records EXCEPTION;
      retval BOOLEAN;
   BEGIN
      retval :=
           rec1.last_name = rec2.last_name
        OR (
                  rec1.last_name IS NULL
              AND rec2.last_name IS NULL
           );

      IF NOT NVL (retval, FALSE)
      THEN
         RAISE unequal_records;
      END IF;

      retval :=
           rec1.first_name = rec2.first_name
        OR (
                  rec1.first_name IS NULL
              AND rec2.first_name IS NULL
           );

      IF NOT NVL (retval, FALSE)
      THEN
         RAISE unequal_records;
      END IF;

      retval :=
           rec1.middle_initial = rec2.middle_initial
        OR (
                  rec1.middle_initial IS NULL
              AND rec2.middle_initial IS NULL
           );

      IF NOT NVL (retval, FALSE)
      THEN
         RAISE unequal_records;
      END IF;

      RETURN TRUE;
   EXCEPTION
      WHEN unequal_records
      THEN
         RETURN FALSE;
   END;

   PROCEDURE ut_setup
   IS
   BEGIN
      ut_teardown;
      EXECUTE IMMEDIATE 'CREATE TABLE ut_employee AS
            SELECT * FROM employee';
      EXECUTE IMMEDIATE 'CREATE TABLE ut_DEL1 AS
            SELECT * FROM employee';
      EXECUTE IMMEDIATE 'CREATE TABLE ut_DELBY_EMP_DEPT_LOOKUP AS
            SELECT * FROM employee';
      EXECUTE IMMEDIATE 'CREATE TABLE ut_DELBY_EMP_JOB_LOOKUP AS
            SELECT * FROM employee';
      EXECUTE IMMEDIATE 'CREATE TABLE ut_DELBY_EMP_MGR_LOOKUP AS
            SELECT * FROM employee';
      EXECUTE IMMEDIATE 'CREATE TABLE ut_INS1 AS
            SELECT * FROM employee';
      EXECUTE IMMEDIATE 'CREATE TABLE ut_UPD1 AS
            SELECT * FROM employee';
      EXECUTE IMMEDIATE 'CREATE TABLE ut_UPD$HIRE_DATE1 AS   
            SELECT * FROM employee';
      EXECUTE IMMEDIATE 'CREATE TABLE ut_UPD$SALARY1 AS
            SELECT * FROM employee';
   END;

   PROCEDURE ut_teardown
   IS
   BEGIN
      BEGIN
         EXECUTE IMMEDIATE 'DROP TABLE ut_employee';
      EXCEPTION
         WHEN OTHERS
         THEN
            NULL;
      END;

      BEGIN
         EXECUTE IMMEDIATE 'DROP TABLE ut_DEL1';
      EXCEPTION
         WHEN OTHERS
         THEN
            NULL;
      END;

      BEGIN
         EXECUTE IMMEDIATE 'DROP TABLE ut_DELBY_EMP_DEPT_LOOKUP';
      EXCEPTION
         WHEN OTHERS
         THEN
            NULL;
      END;

      BEGIN
         EXECUTE IMMEDIATE 'DROP TABLE ut_DELBY_EMP_JOB_LOOKUP';
      EXCEPTION
         WHEN OTHERS
         THEN
            NULL;
      END;

      BEGIN
         EXECUTE IMMEDIATE 'DROP TABLE ut_DELBY_EMP_MGR_LOOKUP';
      EXCEPTION
         WHEN OTHERS
         THEN
            NULL;
      END;

      BEGIN
         EXECUTE IMMEDIATE 'DROP TABLE ut_INS1';
      EXCEPTION
         WHEN OTHERS
         THEN
            NULL;
      END;

      BEGIN
         EXECUTE IMMEDIATE 'DROP TABLE ut_UPD1';
      EXCEPTION
         WHEN OTHERS
         THEN
            NULL;
      END;

      BEGIN
         EXECUTE IMMEDIATE 'DROP TABLE ut_UPD$HIRE_DATE1';
      EXCEPTION
         WHEN OTHERS
         THEN
            NULL;
      END;

      BEGIN
         EXECUTE IMMEDIATE 'DROP TABLE ut_UPD$SALARY1';
      EXCEPTION
         WHEN OTHERS
         THEN
            NULL;
      END;

   END;

   PROCEDURE ut_del1
   IS
      fdbk PLS_INTEGER;
   BEGIN
      /* Delete that finds no rows. */

      EXECUTE IMMEDIATE '
      DELETE FROM ut_DEL1
       WHERE employee_id = -1
      ';
      te_employee.del (-1, rowcount_out => fdbk);
      -- Test results
      utassert.eqtable ('Delete rows', 'EMPLOYEE', 'ut_DEL1');
      /* Successful delete */

      EXECUTE IMMEDIATE '
      DELETE FROM ut_DEL1
       WHERE employee_id between 7800 and 7899
      ';

      FOR rec IN (SELECT *
                    FROM employee
                   WHERE employee_id BETWEEN 7800 AND 7899)
      LOOP
         te_employee.del (
            rec.employee_id,
            rowcount_out => fdbk
         );
      END LOOP;

      -- Test results
      utassert.eqtable ('Delete rows', 'EMPLOYEE', 'ut_DEL1');
      ROLLBACK;
   EXCEPTION
      WHEN OTHERS
      THEN
         utassert.this (
            'DEL1 exception ' || SQLERRM,
            SQLCODE = 0
         );
   END;

   PROCEDURE ut_delby_emp_dept_lookup
   IS
      fdbk PLS_INTEGER;
   BEGIN
      /* Delete that finds now rows. */

      EXECUTE IMMEDIATE '
      DELETE FROM ut_DELBY_EMP_DEPT_LOOKUP
       WHERE department_id = -1
      ';
      te_employee.delby_emp_dept_lookup (
         -1,
         rowcount_out => fdbk
      );
      -- Test results
      utassert.eqtable (
         'Delete no rows via DELBY_EMP_DEPT_LOOKUP',
         'EMPLOYEE',
         'ut_DELBY_EMP_DEPT_LOOKUP'
      );
      /* Successful delete */

      EXECUTE IMMEDIATE '
      DELETE FROM ut_DELBY_EMP_DEPT_LOOKUP
       WHERE department_id = 20
      ';
      te_employee.delby_emp_dept_lookup (
         20,
         rowcount_out => fdbk
      );
      -- Test results
      utassert.eqtable (
         'Successful DELBY_EMP_DEPT_LOOKUP',
         'EMPLOYEE',
         'ut_DELBY_EMP_DEPT_LOOKUP'
      );
      ROLLBACK;
   END;

   PROCEDURE ut_delby_emp_job_lookup
   IS
      fdbk PLS_INTEGER;
   BEGIN
      /* Delete that finds now rows. */

      EXECUTE IMMEDIATE '
      DELETE FROM ut_DELBY_EMP_JOB_LOOKUP
       WHERE job_id = -1
      ';
      te_employee.delby_emp_job_lookup (
         -1,
         rowcount_out => fdbk
      );
      -- Test results
      utassert.eqtable (
         'Delete no rows via DELBY_EMP_JOB_LOOKUP',
         'EMPLOYEE',
         'ut_DELBY_EMP_JOB_LOOKUP'
      );
      /* Successful delete */

      EXECUTE IMMEDIATE '
      DELETE FROM ut_DELBY_EMP_JOB_LOOKUP
       WHERE job_id = 668
      ';
      te_employee.delby_emp_job_lookup (
         668,
         rowcount_out => fdbk
      );
      -- Test results
      utassert.eqtable (
         'Successful DELBY_EMP_JOB_LOOKUP',
         'EMPLOYEE',
         'ut_DELBY_EMP_JOB_LOOKUP'
      );
      ROLLBACK;
   END;

   PROCEDURE ut_delby_emp_mgr_lookup
   IS
      fdbk PLS_INTEGER;
   BEGIN
      /* Delete that finds now rows. */

      EXECUTE IMMEDIATE '
      DELETE FROM ut_DELBY_EMP_MGR_LOOKUP
       WHERE manager_id = -1
      ';
      te_employee.delby_emp_mgr_lookup (
         -1,
         rowcount_out => fdbk
      );
      -- Test results
      utassert.eqtable (
         'Delete no rows via DELBY_EMP_MGR_LOOKUP',
         'EMPLOYEE',
         'ut_DELBY_EMP_MGR_LOOKUP'
      );
      /* Successful delete */

      EXECUTE IMMEDIATE '
      DELETE FROM ut_DELBY_EMP_MGR_LOOKUP
       WHERE manager_id = 7505
      ';
      te_employee.delby_emp_mgr_lookup (
         7505,
         rowcount_out => fdbk
      );
      -- Test results
      utassert.eqtable (
         'Successful DELBY_EMP_MGR_LOOKUP',
         'EMPLOYEE',
         'ut_DELBY_EMP_MGR_LOOKUP'
      );
      ROLLBACK;
   END;

   PROCEDURE ut_ins1
   IS
      v_employee_id employee.employee_id%TYPE;
      v_last_name employee.last_name%TYPE := 'GEORGE';
      v_first_name employee.first_name%TYPE := 'WASHINGTON';
      v_middle_initial employee.middle_initial%TYPE := 'M';
      v_job_id employee.job_id%TYPE := 688;
      v_manager_id employee.manager_id%TYPE := 7505;
      v_hire_date employee.hire_date%TYPE := SYSDATE;
      v_salary employee.salary%TYPE := 1000;
      v_commission employee.commission%TYPE := 3000;
      v_department_id employee.department_id%TYPE := 30;
      v_changed_by employee.changed_by%TYPE := USER;
      v_changed_on employee.changed_on%TYPE := SYSDATE;
      fdbk PLS_INTEGER;
   BEGIN
      EXECUTE IMMEDIATE '
      INSERT INTO ut_INS1 (
         EMPLOYEE_ID,
         LAST_NAME,
         FIRST_NAME,
         MIDDLE_INITIAL,
         JOB_ID,
         MANAGER_ID,
         HIRE_DATE,
         SALARY,
         COMMISSION,
         DEPARTMENT_ID,
         CHANGED_BY,
         CHANGED_ON,
         CREATED_BY,
         CREATED_ON
      )
      VALUES (
         employee_id_seq.NEXTVAL,
         :LAST_NAME,
         :FIRST_NAME,
         :MIDDLE_INITIAL,
         :JOB_ID,
         :MANAGER_ID,
         :HIRE_DATE,
         :SALARY,
         :COMMISSION,
         :DEPARTMENT_ID,
         :CHANGED_BY,
         :CHANGED_ON,
         USER,
         SYSDATE
      )
      '
         USING v_last_name, v_first_name, v_middle_initial, v_job_id, v_manager_id, v_hire_date, v_salary, v_commission, v_department_id, v_changed_by, v_changed_on;
      SELECT employee_id_seq.nextval
        INTO fdbk
        FROM dual;
      te_employee.ins (
         v_last_name,
         v_first_name,
         v_middle_initial,
         v_job_id,
         v_manager_id,
         v_hire_date,
         v_salary,
         v_commission,
         v_department_id,
         v_changed_by,
         v_changed_on,
         fdbk
      );

      -- Test results (everything but ID)
      utassert.eqquery (
         'Insert One Row - check data',
         'SELECT 
         LAST_NAME,
         FIRST_NAME,
         MIDDLE_INITIAL,
         JOB_ID,
         MANAGER_ID,
         HIRE_DATE,
         SALARY,
         COMMISSION,
         DEPARTMENT_ID,
         CHANGED_BY,
         CHANGED_ON from employee where changed_on = ''' ||
            SYSDATE ||
            '''',
         'SELECT 
         LAST_NAME,
         FIRST_NAME,
         MIDDLE_INITIAL,
         JOB_ID,
         MANAGER_ID,
         HIRE_DATE,
         SALARY,
         COMMISSION,
         DEPARTMENT_ID,
         CHANGED_BY,
         CHANGED_ON from ut_ins1 where changed_on = ''' ||
            SYSDATE ||
            ''''
      );
      utassert.eqtabcount (
         'Insert One Row - check count',
         'employee',
         'ut_ins1'
      );
      ROLLBACK;
   END;

   PROCEDURE ut_upd1
   IS
      v_employee_id employee.employee_id%TYPE;
      v_last_name employee.last_name%TYPE;
      v_first_name employee.first_name%TYPE;
      v_middle_initial employee.middle_initial%TYPE;
      v_job_id employee.job_id%TYPE;
      v_manager_id employee.manager_id%TYPE;
      v_hire_date employee.hire_date%TYPE;
      v_salary employee.salary%TYPE;
      v_commission employee.commission%TYPE;
      v_department_id employee.department_id%TYPE;
      v_changed_by employee.changed_by%TYPE;
      v_changed_on employee.changed_on%TYPE;
      fdbk PLS_INTEGER;
   BEGIN
      /* Update 3 columns by ID */

      EXECUTE IMMEDIATE '
      UPDATE ut_UPD1 SET
         FIRST_NAME = ''SILLY'',
         HIRE_DATE = trunc (SYSDATE+100),
         COMMISSION = 5000
       WHERE
          EMPLOYEE_ID = 7600
      ';
      te_employee.upd (
         7600,
         first_name_in => 'SILLY',
         commission_in => 5000,
         hire_date_in => TRUNC (SYSDATE + 100),
         rowcount_out => fdbk
      );
      -- Test results (audit fields are different so do a query)
      utassert.eqquery (
         'Update three columns',
         'select first_name, commission, hire_date from EMPLOYEE',
         'select first_name, commission, hire_date from ut_upd1'
      );
      ROLLBACK;
   END;

   PROCEDURE ut_upd$hire_date1
   IS
      fdbk PLS_INTEGER;
   BEGIN
      /* Successful update by ID */

      EXECUTE IMMEDIATE '
      UPDATE ut_UPD$HIRE_DATE1 SET
       hire_date = trunc (sysdate)
       WHERE employee_id = 7698
      ';
      te_employee.upd$hire_date (
         7698,
         TRUNC (SYSDATE),
         rowcount_out => fdbk
      );
      -- Test results
      utassert.eqquery (
         'Testing UPD$HIRE_DATE1',
         'select hire_date from EMPLOYEE',
         'select hire_date from ut_UPD$HIRE_DATE1'
      );
      ROLLBACK;
   END;

   PROCEDURE ut_upd$salary1
   IS
      fdbk PLS_INTEGER;
   BEGIN
      /* Successful update by ID */

      EXECUTE IMMEDIATE '
      UPDATE ut_UPD$SALARY1 SET
       salary = 5000
       WHERE employee_id = 7555
      ';
      te_employee.upd$salary (
         7555,
         5000,
         rowcount_out => fdbk
      );
      -- Test results
      utassert.eqquery (
         'Testing UPD$SALARY1',
         'select salary from EMPLOYEE',
         'select salary from ut_UPD$SALARY1'
      );
      ROLLBACK;
   END;

   PROCEDURE ut_emp_dept_lookuprowcount
   IS
   BEGIN
      -- Run baseline code.
      SELECT COUNT (*)
        INTO g_rowcount1
        FROM employee
       WHERE department_id = 30;
      -- Compare to program call:
      g_rowcount2 :=
                   te_employee.emp_dept_lookuprowcount (30);
      -- Test results
      utassert.eq (
         'Successful EMP_DEPT_LOOKUPROWCOUNT',
         g_rowcount2,
         g_rowcount1
      );
      ROLLBACK;
   EXCEPTION
      WHEN OTHERS
      THEN
         -- Force registration of test failURE ut_.
         utassert.this (
            'ut_EMP_DEPT_LOOKUPROWCOUNT exception ' ||
               SQLERRM,
            SQLCODE = 0
         );
   END;

   PROCEDURE ut_emp_job_lookuprowcount
   IS
   BEGIN
      -- Run baseline code.
      SELECT COUNT (*)
        INTO g_rowcount1
        FROM employee
       WHERE job_id = 669;
      -- Compare to program call:
      g_rowcount2 :=
                   te_employee.emp_job_lookuprowcount (669);
      -- Test results
      utassert.eq (
         'Successful EMP_JOB_LOOKUPROWCOUNT',
         g_rowcount2,
         g_rowcount1
      );
      ROLLBACK;
   EXCEPTION
      WHEN OTHERS
      THEN
         -- Force registration of test failURE ut_.
         utassert.this (
            'ut_EMP_JOB_LOOKUPROWCOUNT exception ' ||
               SQLERRM,
            SQLCODE = 0
         );
   END;

   PROCEDURE ut_emp_mgr_lookuprowcount
   IS
   BEGIN
      -- Run baseline code.
      SELECT COUNT (*)
        INTO g_rowcount1
        FROM employee
       WHERE manager_id = 7782;
      -- Compare to program call:
      g_rowcount2 :=
                  te_employee.emp_mgr_lookuprowcount (7782);
      -- Test results
      utassert.eq (
         'Successful EMP_MGR_LOOKUPROWCOUNT',
         g_rowcount2,
         g_rowcount1
      );
      ROLLBACK;
   EXCEPTION
      WHEN OTHERS
      THEN
         -- Force registration of test failURE ut_.
         utassert.this (
            'ut_EMP_MGR_LOOKUPROWCOUNT exception ' ||
               SQLERRM,
            SQLCODE = 0
         );
   END;

   PROCEDURE ut_hire_date$val
   IS
   BEGIN
      -- Test results
      utassert.eqquery (
         'Successful HIRE_DATE$VAL',
         'select te_employee.HIRE_DATE$VAL (employee_id) from employee',
         'select hire_Date from employee'
      );
      ROLLBACK;
   EXCEPTION
      WHEN OTHERS
      THEN
         -- Force registration of test failURE ut_.
         utassert.this (
            'ut_HIRE_DATE$VAL exception ' || SQLERRM,
            SQLCODE = 0
         );
   END;

   PROCEDURE ut_i_employee_name$row
   IS
      rec1 te_employee.allcols_rt;
      rec2 te_employee.allcols_rt;
   BEGIN
      -- Unsuccessful test
      BEGIN
         SELECT 
            EMPLOYEE_ID,
            LAST_NAME,
            FIRST_NAME,
            MIDDLE_INITIAL,
            JOB_ID,
            MANAGER_ID,
            HIRE_DATE,
            SALARY,
            COMMISSION,
            DEPARTMENT_ID,
            CHANGED_BY,
            CHANGED_ON
           INTO rec1
           FROM employee
          WHERE last_name = 'LANCE'
            AND first_name = 'GREG'
            AND middle_initial = 'J';
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            NULL;
      END;

      -- Run program
      begin
      rec2 :=
        te_employee.i_employee_name$row ('LANCE', 'GREG', 'J');
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            NULL;
      END;

      -- Test results
      utassert.this (
         'Unsuccessful I_EMPLOYEE_NAME$ROW',
         te_employee.recseq (rec1, rec2)
      );
      -- Successful test
         SELECT 
            EMPLOYEE_ID,
            LAST_NAME,
            FIRST_NAME,
            MIDDLE_INITIAL,
            JOB_ID,
            MANAGER_ID,
            HIRE_DATE,
            SALARY,
            COMMISSION,
            DEPARTMENT_ID,
            CHANGED_BY,
            CHANGED_ON
        INTO rec1
        FROM employee
       WHERE last_name = 'LANCE'
         AND first_name = 'GREGORY'
         AND middle_initial = 'J';
      -- Run program
      rec2 :=
        te_employee.i_employee_name$row (
           'LANCE',
           'GREGORY',
           'J'
        );
      -- Test results
      utassert.this (
         'Successful I_EMPLOYEE_NAME$ROW',
         te_employee.recseq (rec1, rec2)
      );
      ROLLBACK;
   EXCEPTION
      WHEN OTHERS
      THEN
         -- Force registration of test failURE ut_.
         utassert.this (
            'ut_I_EMPLOYEE_NAME$ROW exception ' || SQLERRM,
            SQLCODE = 0
         );
   END;

   PROCEDURE ut_i_employee_name$val
   IS
      rec1 te_employee.i_employee_name_rt;
      rec2 te_employee.i_employee_name_rt;
   BEGIN
      -- Unsuccessful test
      BEGIN
         SELECT last_name, first_name, middle_initial
           INTO rec1
           FROM employee
          WHERE employee_id = -1;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            NULL;
      END;

      -- Run program
      begin
      rec2 := te_employee.i_employee_name$val (-1);
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            NULL;
      END;
      -- Test results
      utassert.this (
         'Unsuccessful I_EMPLOYEE_NAME$VAL',
         recseq (rec1, rec2)
      );
      -- Successful test
      SELECT last_name, first_name, middle_initial
        INTO rec1
        FROM employee
       WHERE employee_id = 7839;
      -- Run program
      rec2 := te_employee.i_employee_name$val (7839);
      -- Test results
      utassert.this (
         'Successful I_EMPLOYEE_NAME$VAL',
         recseq (rec1, rec2)
      );
      ROLLBACK;
   EXCEPTION
      WHEN OTHERS
      THEN
         -- Force registration of test failURE ut_.
         utassert.this (
            'ut_I_EMPLOYEE_NAME$VAL exception ' || SQLERRM,
            SQLCODE = 0
         );
   END;

   PROCEDURE ut_onerow
   IS
      rec1 te_employee.allcols_rt;
      rec2 te_employee.allcols_rt;
   BEGIN
      -- Unsuccessful test
      BEGIN
         SELECT 
            EMPLOYEE_ID,
            LAST_NAME,
            FIRST_NAME,
            MIDDLE_INITIAL,
            JOB_ID,
            MANAGER_ID,
            HIRE_DATE,
            SALARY,
            COMMISSION,
            DEPARTMENT_ID,
            CHANGED_BY,
            CHANGED_ON
           INTO rec1
           FROM employee
          WHERE employee_id = -1;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            NULL;
      END;

      -- Run program
      begin
      rec2 := te_employee.onerow (-1);
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            NULL;
      END;
      -- Test results
      utassert.this (
         'Unsuccessful onerow',
         te_employee.recseq (rec1, rec2)
      );
      -- Successful test
         SELECT 
            EMPLOYEE_ID,
            LAST_NAME,
            FIRST_NAME,
            MIDDLE_INITIAL,
            JOB_ID,
            MANAGER_ID,
            HIRE_DATE,
            SALARY,
            COMMISSION,
            DEPARTMENT_ID,
            CHANGED_BY,
            CHANGED_ON
        INTO rec1
        FROM employee
       WHERE employee_id = 7839;
      -- Run program
      rec2 := te_employee.onerow (7839);
      -- Test results
      utassert.this (
         'Successful onerow',
         te_employee.recseq (rec1, rec2)
      );
   EXCEPTION
      WHEN OTHERS
      THEN
         -- Force registration of test failURE ut_.
         utassert.this (
            'ut_ONEROW exception ' || SQLERRM,
            SQLCODE = 0
         );
   END;

   PROCEDURE ut_pkyrowcount
   IS
   BEGIN
      -- Run baseline code.
      SELECT COUNT (*)
        INTO g_rowcount1
        FROM employee
       WHERE employee_id = 7782;
      -- Compare to program call:
      g_rowcount2 := te_employee.pkyrowcount (7782);
      -- Test results
      utassert.eq (
         'Successful PKYROWCOUNT',
         g_rowcount2,
         g_rowcount1
      );
      ROLLBACK;
   EXCEPTION
      WHEN OTHERS
      THEN
         -- Force registration of test failURE ut_.
         utassert.this (
            'ut_PKYROWCOUNT exception ' || SQLERRM,
            SQLCODE = 0
         );
   END;

   PROCEDURE ut_rowcount
   IS
   BEGIN
      -- Run baseline code.
      SELECT COUNT (*)
        INTO g_rowcount1
        FROM employee;
      -- Compare to program call:
      g_rowcount2 := te_employee.rowcount;
      -- Test results
      utassert.eq (
         'Successful ROWCOUNT',
         g_rowcount2,
         g_rowcount1
      );
      ROLLBACK;
   EXCEPTION
      WHEN OTHERS
      THEN
         -- Force registration of test failURE ut_.
         utassert.this (
            'ut_ROWCOUNT exception ' || SQLERRM,
            SQLCODE = 0
         );
   END;

   PROCEDURE ut_salary$val
   IS
   BEGIN
      -- Test results
      utassert.eqquery (
         'Successful SALARY$VAL',
         'select te_employee.SALARY$VAL (employee_id) from employee',
         'select salary from employee'
      );
      ROLLBACK;
   EXCEPTION
      WHEN OTHERS
      THEN
         -- Force registration of test failURE ut_.
         utassert.this (
            'ut_SALARY$VAL exception ' || SQLERRM,
            SQLCODE = 0
         );
   END;
END ut_te_employee;
/
