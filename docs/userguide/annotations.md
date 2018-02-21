# Annotations

Annotations are used to configure tests and suites in a declarative way similar to modern OOP languages. This way, test configuration is stored along with the test logic inside the test package.
No configuration files or tables are needed. The annotation names are based on popular testing frameworks such as jUnit.
The framework runner searches for all the suitable annotated packages, automatically configures suites, forms the suite hierarchy, executes it and reports results in specified formats.

Annotations are interpreted only in the package specification and are case-insensitive. It is recommended however, to use  lower-case annotations as described in this documentation.

There are two places where annotations may appear:

- at the beginning of the package specification (`%suite`, `%suitepath` etc.)
- right before a procedure (`%test`, `%beforeall`, `%beforeeach` etc.)

Package level annotations need to be separated by at least one empty line from the underlying procedure annotations.

Procedure annotations are defined right before the procedure they reference, no empty lines are allowed.

If a package specification contains the `%suite` annotation, it is treated as a test package and is processed by the framework.

Some annotations accept parameters like `%suite`, `%test` and `%displayname`. The parameters for annotations need to be placed in brackets. Values for parameters should be provided without any quotation marks.

# <a name="example"></a>Example of an annotated test package

```sql
create or replace package test_pkg is

  -- %suite(Name of suite)
  -- %suitepath(all.globaltests)

  -- %beforeall
  procedure global_setup;

  -- %afterall
  procedure global_cleanup;

  /* Such comments are allowed */

  -- %test
  -- %displayname(Name of a test)
  -- %throws(-20145,-20146,-20189,-20563)
  procedure some_test;

  -- %test(Name of another test)
  -- %beforetest(setup_another_test)
  -- %aftertest(cleanup_another_test)
  procedure another_test;

  -- %test
  -- %displayname(Name of test)
  -- %disabled
  procedure disabled_test;

  -- %test(Name of test)
  -- %rollback(manual)
  procedure no_transaction_control_test;

  procedure setup_another_test;

  procedure cleanup_another_test;

  -- %beforeeach
  procedure test_setup;

  -- %aftereach
  procedure test_cleanup;

end test_pkg;
```

# Supported annotations

| Annotation |Level| Description |
| --- | --- | --- |
| `%suite(<description>)` | Package | Mandatory. Marks package as a test suite. Optional suite description can be provided (see `displayname`). |
| `%suitepath(<path>)` | Package | Similar to java package. The annotation allows logical grouping of suites into hierarchies. |
| `%displayname(<description>)` | Package/procedure | Human-readable and meaningful description of a suite/test. `%displayname(Name of the suite/test)`. The annotation is provided for flexibility and convenience only. It has exactly the same meaning as `<description>` in `test` and `suite` annotations. If description is provided using both `suite`/`test` and `displayname`, then the one defined as last takes precedence. |
| `%test(<description>)` | Procedure | Denotes that the annotated procedure is a unit test procedure.  Optional test description can by provided (see `displayname`). |
| `%throws(<exception_number>)`| Test Procedure | Denotes that the annotated test procedure must throws one of the exception numbers written. If there are no valid number the annotation is ignored. Only applies to test procedures. |
| `%beforeall` | Procedure | Denotes that the annotated procedure should be executed once before all elements of the suite. |
| `%afterall` | Procedure | Denotes that the annotated procedure should be executed once after all elements of the suite. |
| `%beforeeach` | Procedure | Denotes that the annotated procedure should be executed before each `%test` procedure in the suite. |
| `%aftereach` | Procedure | Denotes that the annotated procedure should be executed after each `%test` procedure in the suite. |
| `%beforetest(<procedure_name>)` | Procedure | Denotes that mentioned procedure should be executed before the annotated `%test` procedure. |
| `%aftertest(<procedure_name>)` | Procedure | Denotes that mentioned procedure should be executed after the annotated `%test` procedure. |
| `%rollback(<type>)` | Package/procedure | Defines transaction control. Supported values: `auto`(default) - a savepoint is created before invocation of each "before block" is and a rollback to specific savepoint is issued after each "after" block; `manual` - rollback is never issued automatically. Property can be overridden for child element (test in suite) |
| `%disabled` | Package/procedure | Used to disable a suite or a test. Disabled suites/tests do not get executed, they are however marked and reported as disabled in a test run. |

# Suitepath concept

It is very likely that the application for which you are going to introduce tests consists of many different packages or procedures/functions. Usually procedures can be logically grouped inside a package, there also might be several logical groups of procedure in a single package or even packages themselves might relate to a common module.

Let's say you have a complex insurance application that deals with policies, claims and payments. The payment module contains several packages for payment recognition, charging, planning etc. The payment recognition module among others contains a complex `recognize_payment` procedure that associates received money to the policies.

If you want to create tests for your application it is recommended to structure your tests similarly to the logical structure of your application. So you end up with something like:
* Integration tests
  *   Policy tests
  *   Claim tests
  *   Payment tests
    * Payments recognition
    * Payments set off
    * Payouts

The `%suitepath` annotation is used for such grouping. Even though test packages are defined in a flat structure the `%suitepath` is used by the framework to form them into a hierarchical structure. Your payments recognition test package might look like:

```sql
create or replace package test_payment_recognition as

  -- %suite(Payment recognition tests)
  -- %suitepath(payments)

  -- %test(Recognize payment by policy number)
  procedure test_recognize_by_num;

  -- %test
  -- %displayname(Recognize payment by payment purpose)
  procedure test_recognize_by_purpose;

  -- %test(Recognize payment by customer)
  procedure test_recognize_by_customer;

end test_payment_recognition;
```

And payments set off test package:
```sql
create or replace package test_payment_set_off as

  -- %suite(Payment set off tests)
  -- %suitepath(payments)

  -- %test(Set off creation test)
  procedure test_create_set_off;

  -- %test
  -- %displayname(Set off annulation test)
  procedure test_annulate_set_off;

end test_payment_set_off;
```

When you execute tests for your application, the framework constructs a test suite for each test package. Then it combines suites into grouping suites by the `%suitepath` annotation value so that the fully qualified path to the `recognize_by_num` procedure is `USER:payments.test_payment_recognition.test_recognize_by_num`. If any of its expectations fails then the test is marked as failed, also the `test_payment_recognition` suite, the parent suite `payments` and the whole run is marked as failed.
The test report indicates which expectation has failed on the payments module. The payments recognition submodule is causing the failure as `recognize_by_num` has not met the expectations of the test. Grouping tests into modules and submodules using the `%suitepath` annotation allows you to logically organize your project's flat structure of packages into functional groups.

An additional advantage of such grouping is the fact that every element level of the grouping can be an actual unit test package containing a common module level setup for all of the submodules. So in addition to the packages mentioned above you could have the following package.
```sql
create or replace package payments as

  -- %suite(Payments)

  -- %beforeall
  procedure set_common_payments_data;

  -- %afterall
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
In that case use the annotation `-- %rollback(manual)` on the suite level to disable automatic transaction control for the entire suite.
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

# Order of execution

When processing the test suite `test_pkg` defined in [Example of annotated test package](#example), the order of execution will be as follows.

```
  create a savepoint 'beforeall'
    execute global_setup

    create savepoint 'beforeeach'
      execute test_setup
      execute some_test
      execute test_cleanup
    rollback to savepoint 'beforeeach'

    create savepoint 'beforeeach'
      execute test_setup
      execute setup_another_test
      execute another_test
      execute cleanup_another_test
      execute test_cleanup
    rollback to savepoint 'beforeeach'

    mark disabled_test as disabled

    execute test_setup
    execute no_transaction_control_test
    execute test_cleanup    

    execute global_cleanup
  rollback to savepoint 'beforeall'

```

# Annotation cache

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

# Throws annotation

utPLSQL uses the `%throws` annotation to allow the user to delimit which exception numbers a test must throws.

If `%throws` is specified for one test and nothing is raise or a different exception than the annotated one is thrown, the test is marked as failed.

The framework discards the bad arguments, `--%throws(7894562, operaqk, -=1, -20496, pow74d, posdfk3)` it converts that to this `--%throws(-20496)`.
If the arguments is empty `--%throws()`,`--%throws`, or only no valid arguments are provided `--%throws(abe, 723pf)` the annotation is ignored.

Example how to use the annotation:

```
create or replace package example_pgk as

  -- %suite(Example Throws Annotation)

  -%test(Throws one of the listed exceptions)
  --%throws(-20145,-20146, -20189 ,-20563)
  procedure raised_one_listed_exception;

  --%test(Throws diff exception)
  --%throws(-20144)
  procedure raised_diff_exception;

  --%test(Givess failure when a exception is expected and nothing is thrown)
  --%throws(-20459, -20136, -20145)
  procedure nothing_thrown;

end;  
```

```
create package body annotated_package_with_throws is
  procedure raised_one_listed_exception is
  begin
      raise_application_error(-20189, 'Test error');
  end;

  procedure raised_diff_exception is
  begin
      raise_application_error(-20143, 'Test error');
  end;

  procedure nothing_thrown is
  begin
      null;
  end;
end;
```

The test results are:

```
Example Throws Annotation
  Throws one of the listed exceptions [.011 sec]
  Throws diff exception [.011 sec] (FAILED - 1)
  Givess failure when a exception is expected and nothing is thrown [.014 sec] (FAILED - 2)

Failures:

  1) raised_diff_exception
      UT3.annotated_package_with_throws.raised_diff_exception Actual: -20143 was expected to be one of (-20144)

  2) nothing_thrown
      UT3.annotated_package_with_throws.nothing_thrown Expected one of exceptions (-20459,-20136,-20145) but nothing was raised.

Finished in .040591 seconds
3 tests, 2 failed, 0 errored, 0 disabled, 0 warning(s)
```
