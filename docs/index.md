# Introduction to utPLSQL

utPLSQL is a Unit Testing framework for Oracle PL/SQL.
The framework follows industry standards and best patterns of modern Unit Testing frameworks like [JUnit](http://junit.org/junit4/) and [RSpec](http://rspec.info/)

#Three steps
With just three simple steps you can define and run your unit tests for PLSQL code.
 
1. Install the utPLSQL framework 
2. Create Unit Tests to cover the code
3. Run the tests

Here is how you can simply create tested code, unit tests and execute the tests using SQL Developer

![3_steps](images/3_steps_to_run_utPLSQL.gif)

Check out the sections on [annotations](userguide/annotations.md) and [expectations](userguide/expectations.md) to see how to define your tests  


# Command line 
The `ut_run.sql` script is a powerful thing - it can provide output from the tests on the fly.
You can also use it to have coloured output from the test, and if you try to test code that was dropper, all of unit tests related to that code will fail.

![colors_and_failures](images/running_from_command_line.gif)

Look into [ut_run.sql script options](userguide/ut_run-script.md) to see more.

# Coverage
If you want to have code coverage gathered on your code , it's best to use `ut_run.sql` to execute your tests with multiple reporters and have both test execution report as well as coverage report saved to a file.
Check out the [coverage documentation](userguide/coverage.md) for options of coverage reporting

![coverage](images/running_with_coverage_line.gif)

    



