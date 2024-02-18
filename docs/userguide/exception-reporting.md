![version](https://img.shields.io/badge/version-v3.1.14.4194--develop-blue.svg)

utPLSQL is responsible for handling exceptions wherever they occur in the test run. The framework is trapping most of the exceptions so that the test execution is not affected by individual tests or test packages throwing an exception.
The framework provides a full stacktrace for every exception that was thrown. The reported stacktrace does not include any utPLSQL library calls in it.
To achieve rerunability, the package state invalidation exceptions (ORA-04068, ORA-04061) are not handled and test execution will be interrupted if such exceptions are encountered. This is because of how Oracle behaves on those exceptions.

Test execution can fail for different reasons. The failures on different exceptions are handled as follows:

| Problem /  error                                               | Framework behavior                                                                                                                                                                                                                                  | 
|----------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| A test package **without body**                                | each `--%test` is reported as failed with exception, nothing is executed                                                                                                                                                                            |
| A test package with **invalid body**                           | each `--%test` is reported as failed with exception, nothing is executed                                                                                                                                                                            |
| A test package with **invalid spec**                           | package is not considered a valid unit test package and is excluded from execution. When trying to run a test package with invalid spec explicitly, exception is raised. Only valid specifications are parsed for annotations                       | 
| A test package that is raising an exception in `--%beforeall`  | each `--%test` is reported as failed with exception, `--%test`, `--%beforeeach`, `--%beforetest`, `--%aftertest` and `--%aftereach` are not executed. `--%afterall` is executed to allow cleanup of whatever was done in `--%beforeall`             |
| A test package that is raising an exception in `--%beforeeach` | each `--%test` is reported as failed with exception, `--%test`, `--%beforetest` and `--%aftertest` is not executed. The `--%aftereach` and `--%afterall` blocks are getting executed to allow cleanup of whatever was done in `--%before...` blocks |
| A test package that is raising an exception in `--%beforetest` | the `--%test` is reported as failed  with exception, `--%test` is not executed. The `--%aftertest`, `--%aftereach` and `--%afterall` blocks are getting executed to allow cleanup of whatever was done in `--%before...` blocks                     |
| A test package that is raising an exception in `--%test`       | the `--%test` is reported as failed with exception. The execution of other blocks continues normally                                                                                                                                                |
| A test package that is raising an exception in `--%aftertest`  | the `--%test` is reported as failed with exception. The execution of other blocks continues normally                                                                                                                                                |
| A test package that is raising an exception in `--%aftereach`  | each `--%test` is reported as failed with exception.                                                                                                                                                                                                |
| A test package that is raising an exception in `--%afterall`   | all blocks of  the package are executed, as the `--%afterall` is the last step of package execution. Exception in `--%afterall` is not affecting test results. A warning with exception stacktrace is displayed in the summary                      |


!!! warning
    If an exception is thrown in an `afterall` procedure then **no failure reported by utPLSQL**.<br>
    Framework will only report a warning on the suite that the `afterall` belongs to.

Example of reporting with exception thrown in `%beforetest`:
````
Remove rooms by name
  Removes a room without content in it (FAILED - 1)
  Does not remove room when it has content
  Raises exception when null room name given
 
Failures:
 
  1) remove_empty_room
        
        error: ORA-20001: Test exception
               ORA-06512: at "UT3.TEST_REMOVE_ROOMS_BY_NAME", line 39
               ORA-06512: at line 6
       
Finished in ,039346 seconds
3 tests, 0 failed, 1 errored, 0 ignored.
````

Example of reporting with exception thrown in `%test`:
```
Remove rooms by name
  Removes a room without content in it (FAILED - 1)
  Does not remove room when it has content
  Raises exception when null room name given
 
Failures:
 
  1) remove_empty_room
        
        error: ORA-20001: Test exception
               ORA-06512: at "UT3.TEST_REMOVE_ROOMS_BY_NAME", line 48
               ORA-06512: at line 6
       
Finished in ,035726 seconds
3 tests, 0 failed, 1 errored, 0 ignored.
```

Example of reporting with exception thrown in `%aftertest`:
```
Remove rooms by name
  Removes a room without content in it (FAILED - 1)
  Does not remove room when it has content
  Raises exception when null room name given
 
Failures:
 
  1) remove_empty_room
        
        error: ORA-20001: Test exception
               ORA-06512: at "UT3.TEST_REMOVE_ROOMS_BY_NAME", line 42
               ORA-06512: at line 6
       
Finished in ,045523 seconds
3 tests, 0 failed, 1 errored, 0 ignored.
```

Example of reporting with exception thrown in `%aftereach`:
```
Remove rooms by name
  Removes a room without content in it (FAILED - 1)
  Does not remove room when it has content (FAILED - 2)
  Raises exception when null room name given (FAILED - 3)
 
Failures:
 
  1) remove_empty_room
        
        error: ORA-20001: Test exception
               ORA-06512: at "UT3.TEST_REMOVE_ROOMS_BY_NAME", line 31
               ORA-06512: at line 6
       
  2) room_with_content
        
        error: ORA-20001: Test exception
               ORA-06512: at "UT3.TEST_REMOVE_ROOMS_BY_NAME", line 31
               ORA-06512: at line 6
       
  3) null_room_name
        
        error: ORA-20001: Test exception
               ORA-06512: at "UT3.TEST_REMOVE_ROOMS_BY_NAME", line 31
               ORA-06512: at line 6
       
Finished in ,034863 seconds
3 tests, 0 failed, 3 errored, 0 ignored.
```

Example of reporting with exception thrown in `%afterall`:
```
Remove rooms by name
  Removes a room without content in it
  Does not remove room when it has content
  Raises exception when null room name given
 
Warnings:
 
  1) test_remove_rooms_by_name - Afterall procedure failed: 
       ORA-20001: Test exception
       ORA-06512: at "UT3.TEST_REMOVE_ROOMS_BY_NAME", line 35
       ORA-06512: at line 6
 
Finished in ,044902 seconds
3 tests, 0 failed, 0 errored, 0 ignored. 1 warning(s)
```
