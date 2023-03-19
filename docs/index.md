![version](https://img.shields.io/badge/version-v3.1.14.4094--develop-blue.svg)

## What is utPLSQL

utPLSQL is a Unit Testing framework for Oracle PL/SQL.
The framework follows industry standards and best patterns of modern Unit Testing frameworks like [JUnit](http://junit.org/junit4/) and [RSpec](http://rspec.info/)
 
## Demo project

Have a look at [utPLSQL demo project](https://github.com/utPLSQL/utPLSQL-demo-project/) to see:

- sample code and tests
- demo of deployment automation that leverages:
  - Flyway / Liquidbase for scripting and deployment of DB changes 
  - Docker container with Oracle XE Database
  - GitHub Actions and Azure Pipelines to orchestrate the deployment and testing process
  - utPLSQL framework for writhing, execution of tests as well as reporting test results and code coverage
  - [Sonar]((https://sonarcloud.io/project/overview?id=utPLSQL:utPLSQL-demo-project).) for code quality gate, test results and code coverage reporting  

## Three steps

With just three simple steps you can define and run your unit tests for PLSQL code.
 
1. Install the utPLSQL framework 
2. Create Unit Tests to for the code
3. Run the tests

Here is how you can simply create tested code, unit tests and execute the tests using SQL Developer

![3_steps](images/3_steps_to_run_utPLSQL.gif)

Check out the sections on [annotations](userguide/annotations.md) and [expectations](userguide/expectations.md) to see how to define your tests.  


## Command line

You can use the utPLSQL command line client [utPLSQL-cli](https://github.com/utPLSQL/utPLSQL-cli) to run tests without the need for Oracle Client or any IDE like SQLDeveloper/TOAD etc.

Amongst many benefits they provide ability to:

* see the progress of test execution for long-running tests - real-time reporting
* use many reporting formats simultaneously and save reports to files (publish)
* map your project source files and test files into database objects 

Download the [latest client](https://github.com/utPLSQL/utPLSQL-cli/releases/latest) and you are good to go.
See [project readme](https://github.com/utPLSQL/utPLSQL-cli/blob/develop/README.md) for details.  

## Coverage

It is best to use utPLSQL-cli or execute tests and gather code coverage from command line.
Check out the [coverage documentation](userguide/coverage.md) for options of coverage reporting



    



