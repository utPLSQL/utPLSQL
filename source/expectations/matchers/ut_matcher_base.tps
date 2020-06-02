create or replace type ut_matcher_base force authid current_user as object(
  self_type       varchar2(250)
)
not final not instantiable
/