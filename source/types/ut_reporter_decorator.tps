create or replace type ut_reporter_decorator under ut_suite_reporter 
(
  decorated_reporter ut_suite_reporter,
  
  constructor function ut_reporter_decorator(a_decorated_reporter ut_suite_reporter) return self as result,
  member procedure init(self in out nocopy ut_reporter_decorator, a_decorated_reporter ut_suite_reporter)
	
) not final not instantiable
/
