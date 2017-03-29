The `ut_run.sql` script is designed to allow invocation of utPLSQL with multiple reporters.
It allows saving of outcomes into multiple output files.
It also facilitates displaying on screen unit test results while the execution is still ongoing.
Current limit of script parameters is 39

#Scrip invocation
  ut_run.sql user/password@database [-p=(ut_path|ut_paths)] [-c] [-f=format [-o=output] [-s] ...]

#Parameters
```
  user         - username to connect as
  password     - password of the user
  database     - database to connect to
  -p=ut_path(s)- A path or a comma separated list of paths to unit test to be executed.
                 The path can be in one of the following formats:
                   schema[.package[.procedure]]
                   schema:suite[.suite[.suite][...]][.procedure]
                 Both formats can be mixed in the comma separated list.
                 If only schema is provided, then all suites owner by that schema (user) are executed.
                 If -p is omitted, the current schema is used.
  -f=format    - A reporter to be used for reporting.
                 Available options:
                   -f=ut_documentation_reporter
                     A textual pretty-print of unit test results (usually use for console output)
                   -f=ut_teamcity_reporter
                     A teamcity Unit Test reporter, that can be used to visualize progress of test execution as the job progresses.
                   -f=ut_xunit_reporter
                     A XUnit xml format (as defined at: http://stackoverflow.com/a/9691131 and at https://gist.github.com/kuzuha/232902acab1344d6b578)
                     Usually used  by Continuous Integration servers like Jenkins/Hudson or Teamcity to display test results.
                 If no -f option is provided, the ut_documentation_reporter will be used.

  -o=output    - file name to save the output provided by the reporter.
                 If defined, the output is not displayed on screen by default. This can be changed with the -s parameter.
                 If not defined, then output will be displayed on screen, even if the parameter -s is not specified.
                 If more than one -o parameter is specified for one -f parameter, the last one is taken into consideration.
  -s           - Forces putting output to to screen for a given -f parameter.
  -c           - If specified, enables printing of test results in colors as defined by ANSICONSOLE standards
```

Parameters -f, -o, -s are correlated. That is parameters -o and -s are defining outputs for -f.

Examples of invocation using sqlplus from command line:

`sqlplus /nolog @ut_run hr/hr@xe -p=hr_test -f=ut_documentation_reporter -o=run.log -s -f=ut_teamcity_reporter -o=teamcity.xml`

All Unit tests from schema/package "hr_test" will be be invoked with two reporters:
  - ut_documentation_reporter - will output to screen and save it's output to file "run.log"
  - ut_teamcity_reporter - will save it's output to file "teamcity.xml"

`sqlplus /nolog @ut_run hr/hr@xe`

All Unit tests from schema "hr" will be be invoked with ut_documentation_reporter as a format and the results will be printed to screen
