ALTER SESSION SET PLSCOPE_SETTINGS= 'IDENTIFIERS:ALL';

--install or comple all code here
exec dbms_utility.compile_schema(USER,compile_all => TRUE,reuse_settings => FALSE);


var errcnt number

column errcnt_a noprint new_value errcnt_a
column errcnt_l noprint new_value errcnt_l
column errcnt_c noprint new_value errcnt_c

--find parameters that donot begin with A_
prompt parameters should start with A_
select NAME,TYPE,OBJECT_NAME,OBJECT_TYPE,USAGE,LINE,COL , count(*) over() errcnt_a
from user_identifiers
where type like 'FORMAL%' and usage = 'DECLARATION'
and name != 'SELF'
and name  not like 'A#_%' escape '#'
order by object_name, object_type, line, col
;

prompt variables should start with L_
--variables start with l_ or g_
select NAME,TYPE,OBJECT_NAME,OBJECT_TYPE,USAGE,LINE,COL , count(*) over() errcnt_l
from user_identifiers
where type like 'VARIABLE' and usage = 'DECLARATION'
and object_type not in ('TYPE')
and (name  not like 'L#_%' escape '#'
and name  not like 'G#_%' escape '#' --TODO: only valid on package level
)
order by object_name, object_type, line, col
;

--constants start with c_ or gc_
prompt constants should start with C_
select NAME,TYPE,OBJECT_NAME,OBJECT_TYPE,USAGE,LINE,COL , count(*) over() errcnt_c
from user_identifiers
where type like 'CONSTANT' and usage = 'DECLARATION'
and (name  not like 'C#_%' escape '#'
and name  not like 'GC#_%' escape '#'
)
order by object_name, object_type, line, col
;


exec  :errcnt := nvl('&errcnt_a',0) + nvl('&errcnt_l',0) + nvl('&errcnt_c',0); 

quit :errcnt