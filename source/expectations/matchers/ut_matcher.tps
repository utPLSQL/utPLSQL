create or replace type ut_matcher authid current_user as object(
  name            varchar2(250),
  additional_info varchar2(4000),
  error_message   varchar2(4000),
  expected        ut_data_value,

  /*
    function: run_matcher

    A superclass function that executes the matcher.
    This is actually a fallback function, that should be called by subtype when there is a data type mismatch.
    The subtype should override this function and return:
    - true for success of a matcher,
    - false for faulure of a matcher,
    - null when result cannot be determined (type mismatch or exception)
  */
  member function run_matcher(self in out nocopy ut_matcher, a_actual ut_data_value) return boolean
) not final not instantiable
/
