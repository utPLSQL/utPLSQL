The `ut_run.bat` and `ut_run` scripts are designed to allow invocation of utPLSQL with multiple reporters.
It allows saving of outcomes into multiple output files.
It also facilitates displaying on screen unit test results while the execution is still ongoing.
Current limit of script parameters is 39.

The easiest way to use it, is by adding the client_source/sqlplus folder on your PATH.

You need to run the `ut_run.bat` or `ut_run` script from your project's root directory for the Sonar and Coveralls reports to be valid.   

# Script Invocation
  ut_run user/password@database [-p=(ut_path|ut_paths)] [-c] [-f=format [-o=output] [-s] ...] [-source_path=path] [-test_path=path]

# Parameters
```
  user              - username to connect as
  password          - password of the user
  database          - database to connect to
  -p=ut_path(s)     - A path or a comma separated list of paths to unit test to be executed.     
                      The path can be in one of the following formats:
                        schema[.package[.procedure]]
                        schema:suite[.suite[.suite][...]][.procedure]
                      Both formats can be mixed in the comma separated list.
                      If only schema is provided, then all suites owner by that schema (user) are executed.
                      If -p is omitted, the current schema is used.
  -f=format         - A reporter to be used for reporting.
                    Available options:
                      -f=ut_documentation_reporter
                        A textual pretty-print of unit test results (usually   use for console output)
                      -f=ut_teamcity_reporter
                        A teamcity Unit Test reporter, that can be used to    visualize progress of test execution as the job    progresses.
                      -f=ut_xunit_reporter
                        A XUnit xml format (as defined at:    http://stackoverflow.com/a/9691131 and at    https://gist.github.com/kuzuha/232902acab1344d6b578)
                        Usually used  by Continuous Integration servers like   Jenkins/Hudson or Teamcity to display test results.
                      -f=ut_coverage_html_reporter
                        Generates a HTML coverage report providing summary    and detailed information on code coverage.
                        The html reporter is based on open-source    simplecov-html reporter for Ruby.
                        It includes source code of the code that was covered   (if possible).
                      -f=ut_coveralls_reporter
                        Generates a JSON coverage report providing detailed    information on code coverage with line numbers.
                        This coverage report is designed to be consumed by    cloud services like https://coveralls.io/.
                      -f=ut_coverage_sonar_reporter
                        Generates a JSON coverage report providing detailed    information on code coverage with line numbers.
                        This coverage report is designed to be consumed by    local services like https://about.sonarqube.com/.
                      -f=ut_sonar_test_reporter
                        Generates a JSON report providing detailed     information on test specifications.
                        This report is designed to be consumed by local     services like https://about.sonarqube.com/.
                    If no -f option is provided, the ut_documentation_reporter will be used.

  -o=output         - file name to save the output provided by the reporter.
                      If defined, the output is not displayed on screen by default.      This can be changed with the -s parameter.
                      If not defined, then output will be displayed on screen, even      if the parameter -s is not specified.
                      If more than one -o parameter is specified for one -f      parameter, the last one is taken into consideration.
  -s                - Forces putting output to to screen for a given -f parameter.
  -source_path=path - Source files path to be used by coverage reporters. The path need to be relative to the priject root directory.
  -test_path=path   - Test files path to be used by coverage reporters. The path need to be relative to the priject root directory.
  -c                - If specified, enables printing of test results in colors as defined by ANSICONSOLE standards
```

**To make coverage reporters work source_path and/or test_path cannot be empty, and ut_run need to be executed from your project's path.**

Parameters -f, -o, -s are correlated. That is parameters -o and -s are defining outputs for -f.

Examples of invocation using sqlplus from command line:

`ut_run @ut_run hr/hr@xe -p=hr_test -f=ut_documentation_reporter -o=run.log -s -f=ut_coverage_html_reporter -o=coverage.html -source_path=source`

All Unit tests from schema/package "hr_test" will be be invoked with two reporters:
  - ut_documentation_reporter - will output to screen and save output to file "run.log"
  - ut_coverage_html_reporter - will report on database objects that are mapping to file structure from "source" folder, and save output to file "coverage.html"

`ut_run hr/hr@xe`

All Unit tests from schema "hr" will be be invoked with ut_documentation_reporter as a format and the results will be printed to screen.
