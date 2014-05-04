SET TERMOUT OFF

COLUMN col NOPRINT NEW_VALUE run_object 
SELECT substr('&1',1,instr('&1','.')-1) col FROM dual;

SET TERMOUT ON

PROMPT &prompt_text &run_object
@@&1
REM PROMPT &line1

SET TERMOUT OFF
