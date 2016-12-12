alter session set plscope_settings= 'identifiers:all';
set linesize 300

set linesize 132
set pagesize 100 

set linesize 132
set pagesize 100 

--install or comple all code here
exec dbms_utility.compile_schema(USER,compile_all => TRUE,reuse_settings => FALSE);


var errcnt number

column errcnt_a noprint new_value errcnt_a
column errcnt_l noprint new_value errcnt_l
column errcnt_c noprint new_value errcnt_c

--find parameters that donot begin with A_
prompt parameters should start with A_
select name, type, object_name, object_type, usage, line, col, count(*) over() errcnt_a
  from user_identifiers
 where type like 'FORMAL%' and usage = 'DECLARATION'
   and name != 'SELF'
   and name  not like 'A#_%' escape '#'
 order by object_name, object_type, line, col
;

prompt variables should start with L_
--variables start with l_ or g_
select i.name, i.type, i.object_name, i.object_type, i.usage, i.line, i.col, count(*) over() errcnt_l
  from user_identifiers i
  join user_identifiers p
    on p.object_name = i.object_name and p.object_type = i.object_type
   and i.usage_context_id = p.usage_id
 where i.type like 'VARIABLE' and i.usage = 'DECLARATION'
   and i.object_type not in ('TYPE')
   and (i.name not like 'L#_%' escape '#' and p.type in ('PROCEDURE','FUNCTION','ITERATOR')
       or i.name not like 'G#_%' escape '#' and p.type not in ('PROCEDURE','FUNCTION','ITERATOR'))
   and p.type != 'RECORD'
 order by object_name, object_type, line, col;
;

--constants start with c_ or gc_
prompt constants should start with C_
select i.name, i.type, i.object_name, i.object_type, i.usage, i.line, i.col, count(*) over() errcnt_c
  from user_identifiers i
  join user_identifiers p
    on p.object_name = i.object_name and p.object_type = i.object_type
   and i.usage_context_id = p.usage_id
 where i.type like 'CONSTANT' and i.usage = 'DECLARATION'
   and (i.name not like 'C#_%' escape '#' and p.type in ('PROCEDURE','FUNCTION','ITERATOR')
       or i.name not like 'GC#_%' escape '#'  and p.type not in ('PROCEDURE','FUNCTION','ITERATOR'))
 order by object_name, object_type, line, col
;


exec  :errcnt := nvl('&errcnt_a',0) + nvl('&errcnt_l',0) + nvl('&errcnt_c',0); 

--quit :errcnt
exit success
