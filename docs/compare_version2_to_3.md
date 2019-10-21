For version 3 has been a complete rewrite of the framework, the way it can be used is different to
the previous versions, but also more in line with other modern unit-testing frameworks like JUnit and RSpec.

There is a [migration tool](https://github.com/utPLSQL/utPLSQL-v2-v3-migration) that can help you to migrate your existing utPLSQL v2 tests to the v3 capabilities. 

# Feature comparison

| Feature                                | Version 2              | Version 3              |
| -------------------------------------- | ---------------------- | ---------------------- |
| Easy to install                        | Yes                    | Yes                    |
| Documentation                          | Yes                    | Yes                    |
| License                                | GPL v2                 | Apache 2.0             |
| **Tests Creation**                     |                        |                        |
| Declarative test configuration         | No                     | Yes - Annotations<sup>1</sup>|
| Tests as Packages                      | Yes                    | Yes                    |
| Multiple Tests in a single Package     | Yes                    | Yes                    |
| Optional Setup/Teardown                | No                     | Yes                    |
| Different Setup/Teardown <br/> For Each Test in a Single Package| No  | Yes - Annotations<sup>1</sup> |
| Suite Definition Storage               | Tables                 | Package - Annotations<sup>1</sup> |
| Multiple Suites                        | Yes                    | Yes                    |
| Suites can contain Suites              | No                     | Yes                    |
| Automatic Test detection               | No                     | Yes - Annotations<sup>1</sup>|
| Unconstrained naming of Test packages  | No - prefixes          | Yes - name not relevant|
| Require Prefix on Test procedures      | No - prefixes          | Yes - name not relevant|
| Auto Compilation of Tests              | Yes                    | No (Let us know if you use this) | 
| Assertion Library                      | 30 assertions<sup>2</sup> | 26 matchers (13 + 13 negated) |
| Extendable assertions                  | No                     | Yes - custom matchers  |
| PLSQL Record Assertions	             | generated code through **utRecEq** Package | [possible on Oracle 12c+](https://oracle-base.com/articles/12c/using-the-table-operator-with-locally-defined-types-in-plsql-12cr1) using [cursor matchers](userguide/expectations.md#comparing-cursors)| 
| Test Skeleton Generation               | Yes                    | No (Let us know if you use this) |
| **Test Execution<sup>3</sup>**         |                        |                        |
| Single Test Package Execution          |  Yes                   | Yes                    | 
| Single Test Procedure Execution        |  No                    | Yes                    | 
| Test Suite Execution                   |  Yes                   | Yes                    |
| Subset of Suite Execution              |  No                    | Yes                    |
| Multiple Suite Execution               |  No                    | Yes                    |
| Organizing Suites into hierarchies     |  No                    | Yes                    |
| **Code Coverage Reporting**            |  No                    | Yes                    |
| Html Coverage Report                   |  No                    | Yes                    |
| Sonar XML Coverage Report              |  No                    | Yes                    |
| Coveralls Json Coverage Report         |  No                    | Yes                    |
| Framework Transaction Control          |  No                    | Yes - Annotations<sup>1</sup> | 
| **Test Output**                        |                        |                        |
| Real-time test execution progress reporting | No                | Yes                    |
| Multiple Output Reporters can be used during test execution | No| Yes                    |
| DBMS_OUTPUT                            | Yes                    | Yes (clean formatting) |
| File                                   | Yes (to db server only)| Yes (on client side)   |
| Stored in Table                        | Yes                    | No (can be added as custom reporter) |
| XUnit format support                   | No                     | Yes                    |
| HTML Format                            | Yes                    | No                     |
| Custom Output reporter                 | Yes-needs configuration| Yes - no config needed |

<sup>1</sup> Annotations are specially formatted comments in your package specification.  This enables *declarative* test configuration that is coupled with the source code.   See Documentation for more details. 

<sup>2</sup> **utAssert2** package - Contains 59 Assertions - 2 Not implemented = 57, 28 are duplicated only change on outcome_in parameter 57-28 = 29, **utPipe** package - Contains 1 Assertion 29 + 1 = 30

<sup>3</sup> Test execution comparison is in a single call so the results are combined.   We know it was always possible to group in any way with multiple calls.  But that may not be desired under a CI system where you want a single JUnit XML Output.
