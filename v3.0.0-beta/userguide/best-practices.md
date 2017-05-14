#Best Practices

The following are best practices we as utPLSQL have learned about PL/SQL and Unit Testing. 


## Test Interaction

 - Tests should not depend on a specific order to run. 
 - Tests should not depend on other tests to execute.
 - A developer should be able to run one or more tests of their choosing with out any prerequisites.

## Tests are not for production

 Tests generate will generate fake data, so it should go without saying.   You should not deploy your tests to a production database.

## Tests and their relationship to code under test.
 -  Code that you want to test, and the tests should be in separate packages.
 -  Test code commonly will be the same schema as code 
 

## Version Control

Use a version control system for your code.   Don't just trust the database for code storage.    This includes both the code you have under test, and the unit tests you develop as well.

 