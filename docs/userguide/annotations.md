# Annotations

Annotations are used to configure tests and suites in a declarative way similar to modern OOP languages. This way, test configuration is stored along with the test logic inside the test package.
No configuration files or tables are needed. The annotation names are based on popular testing frameworks such as JUnit.
The framework runner searches for all the suitable annotated packages, automatically configures suites, forms the suite hierarchy, executes it and reports results in specified formats.

Annotations are interpreted only in the package specification and are case-insensitive. We strongly recommend using lower-case annotations as described in this documentation.

There are two distinct types of annotations, identified by their location in package:
- Procedure level annotations - placed directly before a procedure (`--%test`, `--%beforeall`, `--%beforeeach` etc.).
- Package level annotations   - placed at any place in package except directly before procedure (`--%suite`, `--%suitepath` etc.).

We strongly recommend putting package level annotations at the very top of package except for the `--%context` annotations (described below)  


## Supported annotations

| Annotation |Level| Description |
| --- | --- | --- |
| `--%suite(<description>)` | Package | Mandatory. Marks package as a test suite. Optional suite description can be provided (see `displayname`). |
| `--%suitepath(<path>)` | Package | Similar to java package. The annotation allows logical grouping of suites into hierarchies. |
| `--%displayname(<description>)` | Package/procedure | Human-readable and meaningful description of a suite/test. `%displayname(Name of the suite/test)`. The annotation is provided for flexibility and convenience only. It has exactly the same meaning as `<description>` in `test` and `suite` annotations. If description is provided using both `suite`/`test` and `displayname`, then the one defined as last takes precedence. |
| `--%test(<description>)` | Procedure | Denotes that the annotated procedure is a unit test procedure.  Optional test description can by provided (see `displayname`). |
| `--%throws(<exception_number>[,<exception_number>[,...]])`| Procedure | Denotes that the annotated procedure must throw one of the exception numbers provided. If no valid numbers were provided as annotation parameters the annotation is ignored. Applicable to test procedures only. |
| `--%beforeall` | Procedure | Denotes that the annotated procedure should be executed once before all elements of the suite. |
| `--%afterall` | Procedure | Denotes that the annotated procedure should be executed once after all elements of the suite. |
| `--%beforeeach` | Procedure | Denotes that the annotated procedure should be executed before each `%test` procedure in the suite. |
| `--%aftereach` | Procedure | Denotes that the annotated procedure should be executed after each `%test` procedure in the suite. |
| `--%beforetest(<procedure_name>)` | Procedure | Denotes that mentioned procedure should be executed before the annotated `%test` procedure. |
| `--%aftertest(<procedure_name>)` | Procedure | Denotes that mentioned procedure should be executed after the annotated `%test` procedure. |
| `--%rollback(<type>)` | Package/procedure | Defines transaction control. Supported values: `auto`(default) - a savepoint is created before invocation of each "before block" is and a rollback to specific savepoint is issued after each "after" block; `manual` - rollback is never issued automatically. Property can be overridden for child element (test in suite) |
| `--%disabled` | Package/procedure | Used to disable a suite or a test. Disabled suites/tests do not get executed, they are however marked and reported as disabled in a test run. |
| `--%context(<description>)` | Package | Denotes start of a nested context (sub-suite) in a suite package |
| `--%endcontext` | Package | Denotes end of a nested context (sub-suite) in a suite package |

### Suite

The `--%suite` annotation denotes PLSQL package as a unit test suite.
It accepts an optional description that will be visible when running the tests.
When description is not provided, package name is displayed on report.

Suite package without description.
```sql
create or replace package test_package as
  --%suite
end;
/
```
```sql
exec ut.run('test_package');
```
```
test_package
 
Finished in .002415 seconds
0 tests, 0 failed, 0 errored, 0 disabled, 0 warning(s)
```  

Suite package with description.
```sql
create or replace package test_package as
  --%suite(Tests for a package)
end;
/
```
```sql
exec ut.run('test_package');
```
```
Tests for a package
 
Finished in .001646 seconds
0 tests, 0 failed, 0 errored, 0 disabled, 0 warning(s)
```  

When multiple `--%suite` annotations are specified in package, the first annotation will be used and a warning message will appear indicating duplicate annotation.
```sql
create or replace package test_package as
  --%suite(Tests for a package)
  --%suite(Bad annotation)
end;
/
```
```sql
exec ut.run('test_package');
```
```
Tests for a package
 
 
Warnings:
 
  1) test_package
      Duplicate annotation "--%suite". Annotation ignored.
      at "TESTS_OWNER.TEST_PACKAGE", line 3
 
Finished in .003318 seconds
0 tests, 0 failed, 0 errored, 0 disabled, 1 warning(s)
```  

When `--%suite` annotation is bound to procedure, it is ignored and results in package not getting recognized as test suite.
```sql
create or replace package test_package as
  --%suite(Tests for a package)
  procedure some_proc;
end;
/
```
```sql
exec ut.run('test_package');
```
```
ORA-20204: Suite package TESTS_OWNER.test_package not found
ORA-06512: at "UT3.UT_RUNNER", line 106
ORA-06512: at "UT3.UT", line 115
ORA-06512: at "UT3.UT", line 306
ORA-06512: at "UT3.UT", line 364
ORA-06512: at line 1
```  


### Test

The `--%suite` annotation denotes procedure withing test suite as a unit test.
It accepts an optional description that will be reported when the test is executed.
When description is not provided, procedure name is displayed on report.


Test procedure without description.
```sql
create or replace package test_package as
  --%suite(Tests for a package)
  
  --%test
  procedure some_test;
end;
/
create or replace package body test_package as
  procedure some_test is
  begin
    null;
  end;
end;
/
```
```sql
exec ut.run('test_package');
```
```
Tests for a package
  some_test [.003 sec]
 
Finished in .004109 seconds
1 tests, 0 failed, 0 errored, 0 disabled, 0 warning(s)
```  

Test procedure with description.
```sql
create or replace package test_package as
  --%suite(Tests for a package)
  
  --%test(Description of tesed behavior)
  procedure some_test;
end;
/
create or replace package body test_package as
  procedure some_test is
  begin
    null;
  end;
end;
/
```

```sql
exec ut.run('test_package');
```
```
Tests for a package
  Description of tesed behavior [.005 sec]
 
Finished in .006828 seconds
1 tests, 0 failed, 0 errored, 0 disabled, 0 warning(s)
```  

When multiple `--%test` annotations are specified for a procedure, the first annotation will be used and a warning message will appear indicating duplicate annotation.
```sql
create or replace package test_package as
  --%suite(Tests for a package)
  
  --%test(Description of tesed behavior)
  --%test(Duplicate description)
  procedure some_test;
end;
/
create or replace package body test_package as
  procedure some_test is
  begin
    null;
  end;
end;
/
```

```sql
exec ut.run('test_package');
```
```
Tests for a package
  Description of tesed behavior [.007 sec]
 
 
Warnings:
 
  1) test_package
      Duplicate annotation "--%test". Annotation ignored.
      at "TESTS_OWNER.TEST_PACKAGE.SOME_TEST", line 5
 
Finished in .008815 seconds
1 tests, 0 failed, 0 errored, 0 disabled, 1 warning(s)
```  

### Disabled
Marks a suite package or test procedure as disabled.

Disabling suite.
```sql
create or replace package test_package as
  --%suite(Tests for a package)
  --%disabled
  
  --%test(Description of tesed behavior)
  procedure some_test;

  --%test(Description of another behavior)
  procedure other_test;
end;
/
create or replace package body test_package as
  procedure some_test is
  begin
    null;
  end;
  procedure other_test is
  begin
    null;
  end;
end;
/
```

```sql
exec ut.run('test_package');
```
```
Tests for a package
  Description of tesed behavior [0 sec] (DISABLED)
  Description of another behavior [0 sec] (DISABLED)
 
Finished in .001441 seconds
2 tests, 0 failed, 0 errored, 2 disabled, 0 warning(s)
```  

Disabling individual test(s).
```sql
create or replace package test_package as
  --%suite(Tests for a package)
  
  --%test(Description of tesed behavior)
  procedure some_test;

  --%test(Description of another behavior)
  --%disabled
  procedure other_test;
end;
/
create or replace package body test_package as
  procedure some_test is
  begin
    null;
  end;
  procedure other_test is
  begin
    null;
  end;
end;
/
```

```sql
exec ut.run('test_package');
```
```
Tests for a package
  Description of tesed behavior [.004 sec]
  Description of another behavior [0 sec] (DISABLED)
 
Finished in .005868 seconds
2 tests, 0 failed, 0 errored, 1 disabled, 0 warning(s)
```

### Beforeall

Marks a procedure to be executed before all test procedures in a suite.

Single beforeall procedure.
```sql
create or replace package test_package as
  --%suite(Tests for a package)

  --%test(Description of tesed behavior)
  procedure some_test;

  --%test(Description of another behavior)
  procedure other_test;

  --%beforeall
  procedure setup_stuff;
  
end;
/
create or replace package body test_package as
  procedure setup_stuff is
  begin
    dbms_output.put_line('--- SETUP_STUFF invoked ---');
  end;
  procedure some_test is
  begin
    null;
  end;
  procedure other_test is
  begin
    null;
  end;
end;
/
```

```sql
exec ut.run('test_package');
```
```
Tests for a package
  --- SETUP_STUFF invoked ---
  Description of tesed behavior [.004 sec]
  Description of another behavior [.003 sec]
 
Finished in .012292 seconds
2 tests, 0 failed, 0 errored, 0 disabled, 0 warning(s)
```


When you define multiple beforeall procedures, all of them will get executed before invoking any test in package.
Order of execution for beforeall procedures is defined by the position of the `--%beforeall` annotation in the package specification. 
 ```sql
 create or replace package test_package as
   --%suite(Tests for a package)
 
   --%beforeall
   procedure initial_setup;
   
   --%test(Description of tesed behavior)
   procedure some_test;
 
   --%test(Description of another behavior)
   procedure other_test;
 
   --%beforeall
   procedure another_setup;
   
 end;
 /
 create or replace package body test_package as
   procedure another_setup is
   begin
     dbms_output.put_line('--- ANOTHER_SETUP invoked ---');
   end;
   procedure initial_setup is
   begin
     dbms_output.put_line('--- INITIAL_SETUP invoked ---');
   end;
   procedure some_test is
   begin
     null;
   end;
   procedure other_test is
   begin
     null;
   end;
 end;
 /
```
 
 ```sql
 exec ut.run('test_package');
 ```
 ```
Tests for a package
  --- INITIAL_SETUP invoked ---
  --- ANOTHER_SETUP invoked ---
  Description of tesed behavior [.004 sec]
  Description of another behavior [.004 sec]
 
Finished in .016672 seconds
2 tests, 0 failed, 0 errored, 0 disabled, 0 warning(s)
 ```
  

### Afterall
Marks a procedure to be executed after all test procedures in a suite.

### Beforeeach

### Aftereach

### Beforetest

### Aftertest

### Suitepath

### Context

### Rollback




**Note**
>Package is considered a test-suite only when package specification contains the `--%suite` annotation at the package level.
>
>Some annotations like `--%suite`, `--%test` and `--%displayname` accept parameters. The parameters for annotations need to be placed in brackets.
Values for parameters should be provided without any quotation marks.
If the parameters are placed without brackets or with incomplete brackets, they will be ignored.
>
>Example: `--%suite(The name of suite without closing bracket`

# Suitepath concept

It is very likely that the application for which you are going to introduce tests consists of many different packages, procedures and functions.
Usually procedures can be logically grouped inside a package, there also might be several logical groups of procedures in a single package and packages might be grouped into modules and modules into subject areas.

As your project grows, the codebase will grow to. utPLSQL allows you to group packages into modules and modules into 

Let's say you have a complex insurance application that deals with policies, claims and payments. The payment module contains several packages for payment recognition, charging, planning etc. The payment recognition module among others contains a complex `recognize_payment` procedure that associates received money to the policies.

If you want to create tests for your application it is recommended to structure your tests similarly to the logical structure of your application. So you end up with something like:
* Integration tests
  *   Policy tests
  *   Claim tests
  *   Payment tests
    * Payments recognition
    * Payments set off

The `%suitepath` annotation is used for such grouping. Even though test packages are defined in a flat structure the `%suitepath` is used by the framework to form them into a hierarchical structure. Your payments recognition test package might look like:

```sql
create or replace package test_payment_recognition as

  --%suite(Payment recognition tests)
  --%suitepath(payments)

  --%test(Recognize payment by policy number)
  procedure test_recognize_by_num;

  --%test(Recognize payment by payment purpose)
  procedure test_recognize_by_purpose;

  --%test(Recognize payment by customer)
  procedure test_recognize_by_customer;

end test_payment_recognition;
```

And payments set off test package:
```sql
create or replace package test_payment_set_off as

  --%suite(Payment set off tests)
  --%suitepath(payments)

  --%test(Creates set off)
  procedure test_create_set_off;

  --%test(Cancels set off)
  procedure test_cancel_set_off;

end test_payment_set_off;
```

When you execute tests for your application, the framework constructs a test suite for each test package. Then it combines suites into grouping suites by the `%suitepath` annotation value so that the fully qualified path to the `recognize_by_num` procedure is `USER:payments.test_payment_recognition.test_recognize_by_num`. If any of its expectations fails then the test is marked as failed, also the `test_payment_recognition` suite, the parent suite `payments` and the whole run is marked as failed.
The test report indicates which expectation has failed on the payments module. The payments recognition submodule is causing the failure as `recognize_by_num` has not met the expectations of the test. Grouping tests into modules and submodules using the `%suitepath` annotation allows you to logically organize your project's flat structure of packages into functional groups.

An additional advantage of such grouping is the fact that every element level of the grouping can be an actual unit test package containing a common module level setup for all of the submodules. So in addition to the packages mentioned above you could have the following package.
```sql
create or replace package payments as

  --%suite(Payments)

  --%beforeall
  procedure set_common_payments_data;

  --%afterall
  procedure reset_common_paymnets_data;

end payments;
```
A `%suitepath` can be provided in three ways:
* schema - execute all tests in the schema
* [schema]:suite1[.suite2][.suite3]...[.procedure] - execute all tests in all suites from suite1[.suite2][.suite3]...[.procedure] path. If schema is not provided, then the current schema is used. Example: `:all.rooms_tests`
* [schema.]package[.procedure] - execute all tests in the specified test package. The whole hierarchy of suites in the schema is built before all before/after hooks or part suites for the provided suite package are executed as well. Example: `tests.test_contact.test_last_name_validator` or simply `test_contact.test_last_name_validator` if `tests` is the current schema.

# Using automatic rollback in tests

By default, changes performed by every setup, cleanup and test procedure are isolated by savepoints.
This solution is suitable for use-cases where the code that is being tested as well as the unit tests themselves do not use transaction control (commit/rollback) or DDL commands.

In general, your unit tests should not use transaction control as long as the code you are testing is not using it too.
Keeping the transactions uncommitted allows your changes to be isolated and the execution of tests does not impact others who might be using a shared development database.

If you are in a situation where the code you are testing uses transaction control (common case with ETL code), then your tests probably should not use the default automatic transaction control.
In that case use the annotation `--%rollback(manual)` on the suite level to disable automatic transaction control for the entire suite.
If you are using nested suites, you need to make sure that the entire suite all the way to the root is using manual transaction control.

It is possible with utPLSQL to change the transaction control on individual suites or tests that are part of complex suite.
It is strongly recommended not to have mixed transaction control in a suite.
Mixed transaction control settings will not work properly when your suites are using shared setup/cleanup with beforeall, afterall, beforeeach or aftereach annotations.
Your suite will most likely fail with error or warning on execution. Some of the automatic rollbacks will probably fail to execute depending on the configuration you have.

In some cases it is necessary to perform DDL as part of setup or cleanup for the tests.
It is recommended to move such DDL statements to a procedure with `pragma autonomous_transaction` to eliminate implicit commits in the main session that is executing all your tests.
Doing so allows your tests to use the framework's automatic transaction control and releases you from the burden of manual cleanup of data that was created or modified by test execution.

When you are testing code that performs explicit or implicit commits, you may set the test procedure to run as an autonomous transaction with `pragma autonomous_transaction`.
Keep in mind that when your test runs as autonomous transaction it will not see the data prepared in a setup procedure unless the setup procedure committed the changes.

**Note**
> The `--%suitepath` annotation, when used, must be provided with a value of path.
> The path in suitepath cannot contain spaces. Dot (.) identifies individual elements of the path.
>
> Example: `--%suitepath(org.utplsql.core.utils)`
>

## Invalid annotations

If procedure level annotation is not placed right before procedure, it is not considered an annotation for procedure.

Example of invalid procedure level annotations 
```sql
create or replace package test_pkg is

  --%suite(Name of suite)

  --%test
  -- this single-line comment makes the TEST annotation no longer associated with the procedure  
  procedure first_test;

  --%test
  --procedure some_test; /* This TEST annotation is not associated with any procedure*/

  --%test(Name of another test)
  procedure another_test;

  --%test
  /**
  * this multi-line comment makes the TEST annotation no longer associated with the procedure  
  */
  procedure yet_another_test;
end test_pkg;
```
Procedure level annotations must be defined right before the procedure they reference, no empty lines are allowed, no comment lines can exist between annotation and the procedure.


Package level annotations need to be separated by at least one empty line from a procedure procedure or procedure annotation.

Example of invalid package level annotation. 
```sql
create or replace package test_pkg is
  --%suite(Name of suite)
  --%test
  procedure first_test;
end test_pkg;
```
In the above example, the `--%suite` annotation is ignored, as it is in fact associated with `procedure first_test`. Association with procedure takes precedence over association with package.

## Order of execution

```sql
create or replace package test_employee_pkg is

  --%suite(Employee management)
  --%suitepath(com.my_company.hr)
  --%rollback(auto)

  --%beforeall
  procedure setup_employees;

  --%beforeall
  procedure setup_departments;

  --%afterall
  procedure cleanup_log_table;

  --%context(add_employee)

  --%beforeeach
  procedure setup_for_add_employees;

  --%test(Raises exception when employee already exists)
  --%throws(-20145)
  procedure add_existing_employee;

  --%test(Inserts employee to emp table)
  procedure add_employee;  

  --%endcontext


  --%context(remove_employee)
  
  --%beforeall
  procedure setup_for_remove_employee;
  
  --%test(Removed employee from emp table)
  procedure del_employee;
  
  --%endcontext

  --%test(Test without context)
  --%beforetest(setup_another_test)
  --%aftertest(cleanup_another_test)
  procedure some_test;

  --%test(Name of test)
  --%disabled
  procedure disabled_test;

  --%test(Name of test)
  --%rollback(manual)
  procedure no_transaction_control_test;

  procedure setup_another_test;

  procedure cleanup_another_test;

  --%beforeeach
  procedure set_session_context;

  --%aftereach
  procedure cleanup_session_context;

end test_employee_pkg;
```

When processing the test suite `test_employee_pkg` defined in [Example of annotated test package](#example), the order of execution will be as follows.
 
```
  create a savepoint 'before-suite'         
    execute setup_employees                 (--%beforeall)
    execute setup_departments               (--%beforeall)

    create a savepoint 'before-context'     
      create savepoint 'before-test'
          execute test_setup                (--%beforeeach)
          execute setup_for_add_employees   (--%beforeeach from context)
          execute add_existing_employee     (--%test)
          execute test_cleanup              (--%aftereach)
      rollback to savepoint 'before-test'
      create savepoint 'before-test'        (--%suite)
          execute test_setup                (--%beforeeach)
          execute setup_for_add_employees   (--%beforeeach from context)
          execute add_employee              (--%test)
          execute test_cleanup              (--%aftereach)
      rollback to savepoint 'before-test'      
    rollback to savepoint 'before-context'  

    create a savepoint 'before-context'
      execute setup_for_remove_employee     (--%beforeall from context)     
      create savepoint 'before-test'
          execute test_setup                (--%beforeeach)
          execute add_existing_employee     (--%test)
          execute test_cleanup              (--%aftereach)
      rollback to savepoint 'before-test'
    rollback to savepoint 'before-context'  

    create savepoint 'before-test'
      execute test_setup                    (--%beforeeach)
      execute some_test                     (--%test)
      execute test_cleanup                  (--%aftereach)
    rollback to savepoint 'before-test'     
                                            
    create savepoint 'before-test'          
      execute test_setup                    (--%beforeeach)
      execute setup_another_test            (--%beforetest)
      execute another_test                  (--%test)
      execute cleanup_another_test          (--%aftertest)
      execute test_cleanup                  (--%beforeeach)
    rollback to savepoint 'before-test'

    mark disabled_test as disabled          (--%test --%disabled)

    execute test_setup                      (--%beforeeach)
    execute no_transaction_control_test     (--%test)
    execute test_cleanup                    (--%aftertest)

    execute global_cleanup                  (--%afterall)
  rollback to savepoint 'before-suite'
```

**Note**
>utPLSQL does not guarantee ordering of tests in suite. On contrary utPLSQL might give random order of tests/contexts in suite.
>
>Order of execution within multiple occurrences of `before`/`after` procedures is determined by the order of annotations in specific block (context/suite) of package specification.


## Annotation cache

utPLSQL needs to scan the source of package specifications to identify and parse annotations.
To improve framework startup time, especially when dealing with database users owning large amounts of packages, the framework has a built-in persistent cache for annotations.

The annotation cache is checked for staleness and refreshed automatically on every run. The initial startup of utPLSQL for a schema will take longer than consecutive executions.

If you are in a situation where your database is controlled via CI/CD server and is refreshed/wiped before each run of your tests, consider building the annotation cache upfront and taking a snapshot of the database after the cache has been refreshed.

To build the annotation cache without actually invoking any tests, call `ut_runner.rebuild_annotation_cache(a_object_owner)` for every unit test owner for which you want to have the annotation cache prebuilt.
Example:
```sql
exec ut_runner.rebuild_annotation_cache('HR');
```

To purge the annotation cache call `ut_runner.purge_cache(a_object_owner)`.
Example:
```sql
exec ut_runner.purge_cache('HR', 'PACKAGE');
```

## Throws annotation

The `--%throws` annotation allows you to specify a list of exception numbers that can be expected from a test.

If `--%throws(-20001,-20002)` is specified and no exception is raised or the exception raised is not on the list of provided exception numbers, the test is marked as failed.

The framework ignores bad arguments. `--%throws(7894562, operaqk, -=1, -20496, pow74d, posdfk3)` will be interpreted as `--%throws(-20496)`.
The annotation is ignored, when no valid arguments are provided `--%throws()`,`--%throws`, `--%throws(abe, 723pf)`.

Example:
```sql
create or replace package example_pgk as

  --%suite(Example Throws Annotation)

  --%test(Throws one of the listed exceptions)
  --%throws(-20145,-20146, -20189 ,-20563)
  procedure raised_one_listed_exception;

  --%test(Throws different exception than expected)
  --%throws(-20144)
  procedure raised_different_exception;

  --%test(Throws different exception than listed)
  --%throws(-20144,-00001,-20145)
  procedure raised_unlisted_exception;

  --%test(Gives failure when an exception is expected and nothing is thrown)
  --%throws(-20459, -20136, -20145)
  procedure nothing_thrown;

end;  
/
create or replace package body example_pgk is
  procedure raised_one_listed_exception is
  begin
      raise_application_error(-20189, 'Test error');
  end;

  procedure raised_different_exception is
  begin
      raise_application_error(-20143, 'Test error');
  end;

  procedure raised_unlisted_exception is
  begin
      raise_application_error(-20143, 'Test error');
  end;

  procedure nothing_thrown is
  begin
      ut.expect(1).to_equal(1);
  end;
end;
/
        
exec ut.run('example_pgk');
```

Running the test will give report:
```
Example Throws Annotation
  Throws one of the listed exceptions [.018 sec]
  Throws different exception than expected [.008 sec] (FAILED - 1)
  Throws different exception than listed [.007 sec] (FAILED - 2)
  Gives failure when an exception is expected and nothing is thrown [.002 sec] (FAILED - 3)
 
Failures:
 
  1) raised_different_exception
      Actual: -20143 was expected to equal: -20144
      ORA-20143: Test error
      ORA-06512: at "UT3.EXAMPLE_PGK", line 9
      ORA-06512: at line 6
       
  2) raised_unlisted_exception
      Actual: -20143 was expected to be one of: (-20144, -1, -20145)
      ORA-20143: Test error
      ORA-06512: at "UT3.EXAMPLE_PGK", line 14
      ORA-06512: at line 6
       
  3) nothing_thrown
      Expected one of exceptions (-20459, -20136, -20145) but nothing was raised.
       
Finished in .038692 seconds
4 tests, 3 failed, 0 errored, 0 disabled, 0 warning(s)
```
