# Annotations

Annotations provide a way to configure tests and suites in a declarative way similar to modern OOP languages. This way th behavior of tests stored along with the test logic, versioned using VCS with the code under test. No configuration files or tables are needed. The annotation list is based on popular testing frameworks such as jUnit 5 and RSpec.
The framework runner searches for all the suitable annotated packages, automatically configures suites, forms suites hierarchy, executes it and reports results in differet formats.

Annotations are case-insensitive. But it is recommended to use the lower-case standard as described in the documentation.

There are two places where annotations may appear: at the beginning of the package specification (`%suite`, `%suitepath` etc) and right before a procedure (`%test`, `%beforeall`, `%beforeeach` etc). Package level annotations are separated by at least one empty line from the following procedure annotations. Procedure annotetions are defined right before the procedure they reference, no empty lines allowed.

If a package conatins `%suite` annotation in its specification part it is treated as a test package and processed by the framework.

Some annotations accept parameters like `%suite`, `%test` `%displayname`, then the values are provided without any quatation marks, parameters are separated by commas.

# Example of annotated test package

```sql
create or replace package test_pkg is

  -- %suite(Name of suite)
  -- %suitepath(all.globaltests)

  -- %beforeall
  procedure globalsetup;

  -- %afterall
  procedure global_teardown;

  /* Such comments are allowed */

  -- %test
  -- %displayname(Name of test1)
  procedure test1;

  -- %test(Name of test2)
  -- %beforetest(setup_test1)
  -- %aftertest(teardown_test1)
  procedure test2;

  -- %test
  -- %displayname(Name of test3)
  -- %disabled
  procedure test3;
  
  -- %test(Name of test4)
  -- %rollback(manual)
  procedure test4;

  procedure setup_test1;

  procedure teardown_test1;

  -- %beforeeach
  procedure setup;

  -- %aftereach
  procedure teardown;

end test_pkg;
```

#Annotations description

| Annotation |Level| Description |
| --- | --- | --- |
| `%suite(<description>)` | Package | Marks package to be a suite of tests This way all testing packages might be found in a schema. Optional schema discription can by provided, similar to `%displayname` annotation. |
| `%suitepath(<path>)` | Package | Similar to java package. The annotation allows logical grouping of suites into hierarchies. |
| `%displayname(<description>)` | Package/procedure | Human-familiar description of the suite/test. Syntax is based on jUnit annotation: `%displayname(Name of the suite/test)` |
| `%test(<description>)` | Procedure | Denotes that a method is a test method.  Optional test description can by provided, similar to `%displayname` annotation. |
| `%beforeall` | Procedure | Denotes that the annotated procedure should be executed once before all elements of the current suite. |
| `%afterall` | Procedure | Denotes that the annotated procedure should be executed once after all elements of the current suite. |
| `%beforeeach` | Procedure | Denotes that the annotated procedure should be executed before each `%test` method in the current suite. |
| `%aftereach` | Procedure | Denotes that the annotated procedure should be executed after each `%test` method in the current suite. |
| `%beforetest(<procedure_name>)` | Procedure | Denotes that mentioned procedure should be executed before the annotated `%test` procedure. |
| `%aftertest(<procedure_name>)` | Procedure | Denotes that mentioned procedure should be executed after the annotated `%test` procedure. |
| `%rollback(<type>)` | Package/procedure | Configure transaction control behaviour (type). Supported values: `auto`(default) - rollback to savepoint (before the test/suite setup) is issued after each test/suite teardown; `manual` - rollback is never issued automatically. Property can be overridden for child element (test in suite) |
| `%disabled` | Package/procedure | Used to disable a suite or a test |

# Suitepath concept
It is very likely that the application for which you are going to introduce tests consists of many different packages or procedures/functions. Usually procedures can be logically grouped inside a package, there also might be several logical groups of procedure in a single package or even packages themselves might relate to a common module.

Lets say you have a complex insurance application the operates with policies, claims and payments. The payment module contains several packages for payment recognition, charging, planning etc. The payment recognition module among others contains a complex `recognize_payment` procedure that associates received money to the policies.

If you want to create tests for your application it is recommended to structure your tests similarly to the logical structure of you application. So you end up with something like:
* Integration tests
  *   Policy tests
  *   Claim tests
  *   Payment tests
    * Payments recognition 
    * Payments set off
    * Payouts 
    
The `%suitepath` annotation is used for such grouping. Even though test packages are defined in a flat structure the `%suitepath` is used by the framework to form a hierarchical structure of them. Your payments recognition test package might look like:

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

When you execute tests for your application, the framework constructs test suite for each test package. Then in combines suites into grouping suites by the `%suitepath` annotation value so that the fully qualified path to the `recognize_by_num` procedure is `USER:payments.test_payment_recognition.test_recognize_by_num`. If any of its expectations fails then the test is marked as failed, also the `test_payment_recognition` suite, the parent suite `payments` and the whole run is marked as failed.
The test report indicates which expectation has failed on the payments module. The payments recognition submodule is causing the failure as `recognize_by_num` has is not meeting the expectations of the test. Grouping tests into modules and submodules using the `%suitepath` annotation allows you to logically organize your projects flat structure of packages int functional groups. 

Additional advantage of such grouping is the fact that every element level of the grouping can be an actual unit test package containing module level common setup for all of the submodules. So in addition to the packages mentioned above you could have following package.
```sql
create or replace package payments as

  -- %suite(Payments)

  -- %beforeall
  procedure set_common_payments_data;

  -- %afterall
  procedure reset_common_paymnets_data;

end payments;
```
A `%suitepath` can be provided in tree ways:
* schema - execute all test in the schema
* [schema]:suite1[.suite2][.suite3]...[.procedure] - execute all tests in all suites from suite1[.suite2][.suite3]...[.procedure] path. If schema is not provided, then current schema is used. Example: `:all.rooms_tests`.
* [schema.]package[.procedure] - execute all tests in the test package provided. The whole hierarchy of suites in the schema is build before, all before/after hooks of partn suites for th provided suite package are executed as well. Example: `tests.test_contact.test_last_name_validator` or simply `test_contact.test_last_name_validator` if `tests` is the current schema.
