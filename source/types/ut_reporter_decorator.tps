create or replace type ut_reporter_decorator under ut_suite_reporter 
(
  -- Author  : PAZZZ
  -- Created : 20.07.2016 23:31:07
  -- Purpose : 
  
  -- Attributes
  decorated_reporter ut_suite_reporter,
  
  -- Member functions and procedures
  constructor function ut_reporter_decorator(a_decorated_reporter ut_suite_reporter) return self as result,
	member procedure init(self in out nocopy ut_reporter_decorator, a_decorated_reporter ut_suite_reporter)
	
) not final not instantiable
/
