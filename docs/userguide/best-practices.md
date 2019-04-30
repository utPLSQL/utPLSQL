![version](https://img.shields.io/badge/version-v3.1.7.2905--develop-blue.svg)

# Best Practices

The following are best practices we at utPLSQL have learned about PL/SQL and Unit Testing. 

## Test Isolation and Dependency

 - Tests should not depend on a specific order to run 
 - Tests should not depend on other tests to execute
 - Tests should not depend on specific database state, they should setup the expected state before being run
 - Tests should keep the environment unchanged post execution


## Writing tests

 - Tests should not mimic / duplicate the logic of tested code
 - Tests should contain zero logic (or as close to zero as possible)
 - The 3A rule:
   - Arrange (setup inputs/data/environment for the tested code)
   - Act (execute code under test)
   - Assert (validate the outcomes of the execution)
 - Each tested procedure/function/trigger (code block) should have more than one test
 - Each test should check only one behavior (one requirement) of the code block under test
 - Tests should be maintained as thoroughly as production code
 - Every test needs to be built so that it can fail, tests that do not fail when needed are useless  
  
## Gaining value from the tests
 
 - Tests are only valuable if they are executed frequently; ideally with every change to the project code
 - Tests need to run very fast; the slower the tests, the longer you wait. Build tests with performance in mind (do you really need to have 10k rows to run the tests?)
 - Tests that are executed infrequently can quickly become stale and end up adding overhead rather than value. Maintain tests as you would maintain code.
 - Tests that are failing need to be addressed immediately. How can you trust your tests when 139 of 1000 tests are failing for a month? Will you recognise each time that it is still the same 139 tests?  

## Tests are not for production

 Tests will generate and operate on fake data. They might insert, update and delete data. You don't want tests to run on a production database and affect real life data.

## Tests and their relationship to code under test
 -  Tests and the code under test should be in separate packages. This is a fundamental separation of responsibilities.
 -  It is common for test code to be in the same schema as the tested code. This removes the need to manage privileges for the tests. 

## Version Control

Use a version control system for your code. 
Don't just trust the database for code storage.
This includes both the code under test, and the unit tests you develop as well.
Treat the database as a target/destination for your code, not as a source of it.
