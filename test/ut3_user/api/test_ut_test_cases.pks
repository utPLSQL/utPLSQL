create or replace package test_ut_test_cases is
  --%suite(test cases: --%testcase and --%testcasesource)
  --%suitepath(utplsql.test_user.api)

  --%beforeall(create_test_case_suites)
  --%afterall(drop_test_case_suites)

  procedure create_test_case_suites;
  procedure drop_test_case_suites;

  --%context(the examples of discussion #1326)

    --%test(Runs test cases given as JSON arrays and objects)
    procedure discount_json_arguments;

    --%test(Runs test cases returned as json_array_t)
    procedure discount_json_source;

    --%test(Runs test cases returned as cursor)
    procedure discount_cursor_source;

    --%test(Gives the same results when NLS settings and session time zone differ)
    procedure discount_independent_of_nls;

  --%endcontext

  --%context(--%testcase)

    --%test(Runs each test case as a separate test, from JSON arrays and objects)
    procedure testcase_runs_each_case;

    --%test(Runs all test cases of a procedure given by path)
    procedure testcase_by_path;

    --%test(Runs a single test case given by path)
    procedure testcase_single_case_by_path;

    --%test(Raises invalid path format when a test case number follows a package name)
    --%throws(ut3_develop.ut_utils.gc_invalid_path_format)
    procedure testcase_number_on_package;

    --%test(Reports each test case under its own name in all reporters)
    procedure testcase_reported_names;

    --%test(Passes JSON strings with quotes, non-ASCII characters and unicode escapes)
    procedure testcase_strings;

    --%test(Uses the default of parameters missing in a JSON object or array)
    procedure testcase_defaults;

    --%test(Converts JSON strings to numbers and numbers to strings)
    procedure testcase_json_conversions;

    --%test(Passes JSON booleans and reports other values for BOOLEAN parameters as errors)
    procedure testcase_json_booleans;

    --%test(Passes object types and collections from JSON, requiring a JSON object or array with all attributes)
    procedure testcase_json_objects;

    --%test(Reports a test case as errored when a parameter type can't be passed from JSON)
    procedure testcase_json_unsupported_type;

    --%test(Reports JSON test cases of overloaded procedures as errored)
    procedure testcase_json_overloaded;

    --%test(Skips a test case that is no JSON array or object with a warning)
    procedure testcase_not_json;

    --%test(Reports test cases whose arguments don't fit the parameters as errored and runs the others)
    procedure testcase_arguments_dont_fit;

    --%test(Converts JSON values to BINARY_DOUBLE, NVARCHAR2, intervals, RAW and CLOB)
    procedure testcase_json_more_types;

    --%test(Runs empty JSON arrays and objects for procedures without parameters)
    procedure testcase_without_parameters;

    --%test(Reports a JSON test case for a PL/SQL record parameter as errored, naming the type)
    procedure testcase_json_record_parameter;

    --%test(Reports JSON test cases for package collections, JSON object types and BLOB as errored, naming the type)
    procedure testcase_json_package_types;

  --%endcontext

  --%context(--%testcasesource returning JSON)

    --%test(Calls the function after beforeall and runs one test case per element)
    procedure source_json_after_beforeall;

    --%test(Calls a function of another package and a function with default arguments)
    procedure source_json_function_reference;

    --%test(Passes JSON built with the PL/SQL JSON API, with sysdate and constants)
    procedure source_json_built;

    --%test(Gives a warning for an empty array, null and json_arrayagg over no rows with nvl)
    procedure source_json_no_test_cases;

    --%test(Reports the test as errored when the function doesn't return a JSON array of arrays and objects)
    procedure source_json_invalid_result;

    --%test(Reports the test as errored when the function doesn't exist, fails or returns another type than json_array_t or sys_refcursor)
    procedure source_function_errors;

    --%test(Doesn't call the function of a disabled test)
    procedure source_disabled;

    --%test(Reports JSON values that don't fit the parameters as errors of their test case)
    procedure source_json_values_dont_fit;

    --%test(Passes long strings and clobs)
    procedure source_json_long_values;

    --%test(Names a test case of a test without description by its procedure)
    procedure source_no_description;

    --%test(Reports JSON test cases of an overloaded procedure as errored)
    procedure source_json_overloaded;

  --%endcontext

  --%context(--%testcasesource returning a cursor)

    --%test(Passes columns by name, with sysdate, constants and object types, and uses other columns in the description)
    procedure source_cursor_by_name;

    --%test(Passes columns by position when no column is named like a parameter)
    procedure source_cursor_by_position;

    --%test(Passes the rows fetched before the first test case even when they are deleted)
    procedure source_cursor_snapshot;

    --%test(Gives a warning when the cursor returns no rows)
    procedure source_cursor_no_rows;

    --%test(Reports the test as errored when a column has a type that can't be passed)
    procedure source_cursor_unsupported_column;

    --%test(Reports the test as errored when a column doesn't fit its parameter)
    procedure source_cursor_column_doesnt_fit;

    --%test(Runs many test cases)
    procedure source_cursor_many_rows;

    --%test(Passes columns of all supported types and shows them in the description)
    procedure source_cursor_types;

    --%test(Reports the test as errored when the cursor has more columns than can be passed)
    procedure source_cursor_too_many_columns;

    --%test(Reports the test as errored when no column is named like a parameter and the number of columns doesn't match)
    procedure source_cursor_position_count;

    --%test(Reports the test as errored when a column is no parameter and isn't used in the description)
    procedure source_cursor_misspelled_column;

    --%test(Reports the test as errored when a parameter without default has no column)
    procedure source_cursor_missing_column;

    --%test(Reports the test as errored when two columns are named like the same parameter)
    procedure source_cursor_duplicate_column;

    --%test(Matches column names to parameters not case-sensitive and uses defaults of parameters without column)
    procedure source_cursor_lower_case_column;

    --%test(Reports the test as errored when the test procedure is overloaded)
    procedure source_cursor_overloaded;

    $if dbms_db_version.version >= 23 $then
    --%test(Passes BOOLEAN columns)
    procedure source_cursor_booleans;
    $end

  --%endcontext

  --%context(dates and times)

    --%test(Converts date and time strings of JSON like the values of a cursor)
    procedure times_json_and_cursor_alike;

    --%test(Converts dates without time)
    procedure times_date_only;

    --%test(Reports date strings in another format as errors of their test case)
    procedure times_invalid_format;

  --%endcontext

end;
/
