![version](https://img.shields.io/badge/version-v3.1.12.3719--develop-blue.svg)

# Introduction to utPLSQL

utPLSQL is a Unit Testing framework for Oracle PL/SQL.
The framework follows industry standards and best patterns of modern Unit Testing frameworks like [JUnit](http://junit.org/junit4/) and [RSpec](http://rspec.info/)

  - User Guide
       - [Installation](userguide/install.md)
       - [Getting Started](userguide/getting-started.md)
       - [Annotations](userguide/annotations.md)
       - [Expectations](userguide/expectations.md)
       - [Advanced data comparison](userguide/advanced_data_comparison.md)
       - [Running unit tests](userguide/running-unit-tests.md)
       - [Querying for test suites](userguide/querying_suites.md)
       - [Testing best practices](userguide/best-practices.md)
       - [Upgrade utPLSQL](userguide/upgrade.md)
  - Reporting
       - [Using reporters](userguide/reporters.md)
       - [Reporting errors](userguide/exception-reporting.md)
       - [Code coverage](userguide/coverage.md)
  - [Cheat-sheet](https://www.cheatography.com/jgebal/cheat-sheets/utplsql-v3-1-2/#downloads)
  - About
       - [Project Details](about/project-details.md)
       - [License](about/license.md)
       - [Support](about/support.md)
       - [Authors](about/authors.md)
  - [Version 2 to Version 3 Comparison](compare_version2_to_3.md)
       
# Demo project

Have a look at our [demo project](https://github.com/utPLSQL/utPLSQL-demo-project/).

It uses [Travis CI](https://travis-ci.org/utPLSQL/utPLSQL-demo-project) to build on every commit, runs all tests, publishes test results and code coverage to [SonarQube](https://sonarqube.com/dashboard?id=utPLSQL%3AutPLSQL-demo-project%3Adevelop).

# Three steps

With just three simple steps you can define and run your unit tests for PLSQL code.
 
1. Install the utPLSQL framework 
2. Create Unit Tests to for the code
3. Run the tests

Here is how you can simply create tested code, unit tests and execute the tests using SQL Developer

![3_steps](images/3_steps_to_run_utPLSQL.gif)

Check out the sections on [annotations](userguide/annotations.md) and [expectations](userguide/expectations.md) to see how to define your tests.  


# Command line

You can use the utPLSQL command line client [utPLSQL-cli](https://github.com/utPLSQL/utPLSQL-cli) to run tests without the need for Oracle Client or any IDE like SQLDeveloper/TOAD etc.

Amongst many benefits they provide ability to:
* see the progress of test execution for long-running tests - real-time reporting
* use many reporting formats simultaneously and save reports to files (publish)
* map your project source files and test files into database objects 

Download the [latest client](https://github.com/utPLSQL/utPLSQL-cli/releases/latest) and you are good to go.
See [project readme](https://github.com/utPLSQL/utPLSQL-cli/blob/develop/README.md) for details.  

# Coverage

If you want to have code coverage gathered on your code , it's best to use `ut_run` to execute your tests with multiple reporters and have both test execution report as well as coverage report saved to a file.

Check out the [coverage documentation](userguide/coverage.md) for options of coverage reporting



    



