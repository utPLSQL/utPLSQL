
-- ----------------------------------------------------------------------------------------------
--
-- Utility:         MyStats
--                  
-- Script:          mystats.sql
--                  
-- Version:         3.0
--                  
-- Author:          Adrian Billington
--                  www.oracle-developer.net
--                  (c) oracle-developer.net 
--                  
-- Description:     A free-standing SQL*Plus script to output the resource consumption of a unit or
--                  units of work as recorded in v$mystat, v$latch and v$sess_time_model. 
--                  Based on Jonathan Lewis's SNAP_MY_STATS package but as a standalone script (i.e.
--                  no database objects need to be created).
--                  
--                  Key Differences
--                  ---------------
--                  
--                     a) This is a SQL*Plus script that requires no objects to be created;
--                  
--                     b) This includes latch statistics and makes use of Tom
--                        Kyte's RUNSTATS method for distinguising between stats
--                        and latches;
--                  
--                     c) This includes advanced reporting options (see Usage and Examples
--                        sections below for details);
--                  
--                     d) This includes a session time model report;
--                  
--                     e) This requires at least version 10.1 to run because it
--                        makes use of collection methods such as MEMBER OF and
--                        reports on V$SESS_TIME_MODEL statistics.
--                  
-- Configuration:   Edit the c_ms_rmcmd variable in the Constants section at the start of this
--                  script to use the correct file deletion command for your SQL*Plus client
--                  platform. It is defaulted to a Windows "del" command, so you will need to
--                  change it if you are using a Linux/Unix SQL*Plus client.
--                  
--                  Reason: To make this run in standalone mode, a couple of temporary files
--                  are written to your current directory. These files are automatically
--                  removed on completion of this script.
--                  
-- Usage:           @mystats start [optional statistics type(s)]
--                  --<do some work>--
--                  @mystats stop [optional reporting parameter]
--                  
--                  Optional statistics types format:
--
--                  Short Format            Long Format Equivalent
--                  ----------------------- ----------------------
--                  s=[csv]                 stattypes=[csv]
--                  
--                  Statistics types values for the csv list are as follows:
--
--                  Statistics Type Short Format Long Format Equivalent
--                  --------------- ------------ ----------------------
--                  Statistic       s            statistic
--                  Latch           l            latch
--                  Time Model      t            time
--                  All (default)   a            all
--
--                  Optional reporting parameter formats:
--                  
--                  Short Format            Long Format Equivalent
--                  ----------------------- ----------------------
--                  t=<number>              threshold=<number>
--                  l=<string>              like=<string>
--                  n=<string list>         names=<string list>
--                  r=<regular expression>  regexp=<regular expression>
--                  
--                  Use double-quotes when the strings contain spaces, 
--                  e.g. "option=value with space"
--                  
-- Examples:        1. Output all statistics
--                  -------------------------------------------------------------
--                  @mystats start
--                  --<do some work>--
--                  @mystats stop
--                  
--                  2. Output statistics with delta values >= 1,000
--                  -------------------------------------------------------------   
--                  @mystats start
--                  --<do some work>--
--                  @mystats stop t=1000
--                  
--                  3. Output statistics for "redo size" and "user commits" only
--                  -------------------------------------------------------------
--                  @mystats start
--                  --<do some work>--
--                  @mystats stop "n=redo size, user commits"
--                  
--                  4. Output statistics for those containing the word 'memory' 
--                  -------------------------------------------------------------
--                  @mystats start
--                  --<do some work>--
--                  @mystats stop l=memory
--
--                  5. Output statistics for those with I/O, IO, i/o or io in the name
--                  ------------------------------------------------------------------
--                  @mystats start
--                  --<do some work>--
--                  @mystats stop r=I/?O\s
--
--                  6. Capture and output statistics and time model only
--                  -------------------------------------------------------------
--                  @mystats start s=s,t
--                  --<do some work>--
--                  @mystats stop
--
--                  7. Output statistics only for those containing 'parallel'
--                  -------------------------------------------------------------
--                  @mystats start s=s
--                  --<do some work>--
--                  @mystats stop l=parallel
--                  
-- Notes:           1. See http://www.jlcomp.demon.co.uk/snapshot.html for original
--                     version.
--                  
--                  2. As described in Configuration above, this script writes and removes
--                     a couple of temporary files during execution.
--
--                  3. A PL/SQL package version of MyStats (v3.0) is also available.
--
--                  4. Thanks to Martin Bach for the idea to provide a regexp reporting filter
--                     option and some example code.
--                  
-- Disclaimer:      http://www.oracle-developer.net/disclaimer.php
--
-- ----------------------------------------------------------------------------------------------

set define on autoprint off 
set serveroutput on format wrapped

-- Constants...
-- -----------------------------------------------------------------------
define c_ms_version = 3.0
define c_ms_rmcmd   = "del"  --Windows
--define c_ms_rmcmd = "rm"   --Unix/Linux
define c_ms_init    = "_ms_init.sql"
define c_ms_clear   = "_ms_teardown.sql"


-- Initialise default substitution variables 1 and 2...
-- -----------------------------------------------------------------------
set termout off

col 1 new_value 1
col 2 new_value 2

select null as "1"
,      null as "2"
from   dual 
where  1=2;


-- Input parameters...
-- -----------------------------------------------------------------------
define p_ms_snap   = &1
define p_ms_option = "&2"


-- Initialisation section...
-- -----------------------------------------------------------------------
column snap     noprint new_value v_ms_snap
column if_start noprint new_value v_ms_if_start
column if_stop  noprint new_value v_ms_if_stop

select snap
,      decode(snap, 'start', '', '--') as if_start
,      decode(snap, 'stop', '', '--')  as if_stop
from  (
         select rtrim(lower('&p_ms_snap'),';') as snap
         from   dual
      );

spool "&c_ms_init" replace
prompt var bv_ms_&v_ms_snap     clob;
prompt var bv_ms_ela_&v_ms_snap number;
prompt var bv_ms_cpu_&v_ms_snap number;
spool off
@"&c_ms_init"
host &c_ms_rmcmd "&c_ms_init"


-- Parse the options...
-- -----------------------------------------------------------------------
column threshold    noprint new_value v_ms_threshold
column namelist     noprint new_value v_ms_name_list
column namelike     noprint new_value v_ms_name_like
column regexplike   noprint new_value v_ms_name_regexp
column stattypes    noprint new_value v_ms_stattypes
column ms_option    noprint new_value v_ms_option
column start_option noprint new_value v_ms_start_option
column stop_option  noprint new_value v_ms_stop_option

select case
         when o in ('threshold','t')
         then 1
         when o in ('names','n')
         then 2
         when o in ('like','l')
         then 3
         when o in ('regex','r')
         then 4
         when o in ('stattype','s')
         then 5
         else 0
       end as ms_option
,      case
         when o in ('threshold','t')
         then to_number(v)
         else 0
       end as threshold
,      case
         when o in ('names','n')
         then '''' || regexp_replace(v, ' *, *', ''',''') || ''''
         else 'null'
       end as namelist
,      case
         when o in ('like','l')
         then '''%' || v || '%'''
         else 'null'
       end as namelike
,      case
         when o in ('regexp','r')
         then '''' || v || ''''
         else 'null'
       end as regexplike
&v_ms_if_start ,      case
&v_ms_if_start          when o in ('stattype','s')
&v_ms_if_start          then regexp_replace(v, ' *, *', ',')
&v_ms_if_start          when o is null
&v_ms_if_start          then 'all'
&v_ms_if_start        end as stattypes
&v_ms_if_start , p as start_option
,      p as stop_option
from  (
        select trim(regexp_substr(lower('&p_ms_option'), '[^=]+')) as o
        ,      trim(regexp_substr('&p_ms_option', '[^=]+', 1, 2))  as v
        ,      '&p_ms_option'                                      as p
        from   dual
      );


-- Stattypes include/exclude section...
-- -----------------------------------------------------------------------
column snap            noprint
column include_stats   noprint new_value v_ms_include_statistics
column include_latches noprint new_value v_ms_include_latches
column include_time    noprint new_value v_ms_include_time_model

select snap
&v_ms_if_start , case when regexp_like('&v_ms_stattypes', '(^|,)(s|statistic|a|all)(,|$)') then 'Y' else 'N' end as include_stats
&v_ms_if_start , case when regexp_like('&v_ms_stattypes', '(^|,)(l|latch|a|all)(,|$)') then 'Y' else 'N' end     as include_latches
&v_ms_if_start , case when regexp_like('&v_ms_stattypes', '(^|,)(t|time|a|all)(,|$)') then 'Y' else 'N' end      as include_time
from  (
         select rtrim(lower('&p_ms_snap'),';') as snap
         from   dual
      );


-- The utility...
-- -----------------------------------------------------------------------
set termout on
declare

   -- Run constants...
   -- -------------------------------------------------------------------------
   c_snap1 constant pls_integer := 1;
   c_snap2 constant pls_integer := 2;

   -- Snapshots...
   -- -------------------------------------------------------------------------
   type rt_snaps is record
   ( snap1 clob
   , snap2 clob );

   g_snaps rt_snaps;

   -- Elapsed time calculation...
   -- -------------------------------------------------------------------------
   type rt_time is record
   ( ela integer
   , cpu integer );

   type aat_time is table of rt_time
      index by pls_integer;

   g_times aat_time;

   -- Utility info...
   -- -------------------------------------------------------------------------
   procedure ms_options is
   begin
      dbms_output.put_line('- Statistics types : ' || nvl('&v_ms_start_option', 'all'));
      dbms_output.put_line('- Reporting filter : ' || nvl('&v_ms_stop_option', 'none'));
   end ms_options;

   procedure ms_info is
   begin
      dbms_output.put_line('- MyStats v&c_ms_version by Adrian Billington (http://www.oracle-developer.net)');
      dbms_output.put_line('- Original version based on the SNAP_MY_STATS utility by Jonathan Lewis');
      dbms_output.new_line();
   end ms_info;

   -- Snapshot procedure...
   -- -------------------------------------------------------------------------
   procedure ms_snap( p_stats in out clob ) is
   begin
      select dbms_xmlgen.getxml(
                q'[select 'STAT' as type
                          ,      a.name
                          ,      b.value
                          from   v$statname a
                          ,      v$mystat   b
                          where  a.statistic# = b.statistic#
                          and    '&v_ms_include_statistics' = 'Y'
                          union all
                          select 'LATCH'
                          ,      name
                          ,      gets 
                          from   v$latch
                          where  '&v_ms_include_latches' = 'Y'
                          union all
                          select 'TIME'
                          ,      stat_name
                          ,      value
                          from   v$sess_time_model
                          where  sid = sys_context('userenv','sid')
                          and    '&v_ms_include_time_model' = 'Y']'
                 ) into p_stats
      from   dual;
   end ms_snap;

   -- Time snapshot...
   -- -------------------------------------------------------------------------
   procedure ms_time( p_times in out nocopy aat_time,
                      p_snap  in pls_integer ) is
   begin
      p_times(p_snap).ela := dbms_utility.get_time;
      p_times(p_snap).cpu := dbms_utility.get_cpu_time;
   end ms_time;

   -- Reporting procedure...
   -- -------------------------------------------------------------------------
   procedure ms_report( p_times in aat_time,
                        p_snaps in rt_snaps ) is

      procedure div( p_divider in varchar2 default '-',
                     p_width   in pls_integer default 90 ) is
      begin
         dbms_output.put_line( rpad(p_divider, p_width, p_divider) );
      end div;

      procedure nl( p_newlines in pls_integer default 1 ) is
      begin
         for i in 1 .. p_newlines loop
            dbms_output.put_line(null);
         end loop;
      end nl;

      procedure sh ( p_title  in varchar2,
                     p_header in boolean default true ) is
      begin
         nl(2);
         div;
         dbms_output.put_line(p_title);
         div;
         if p_header then
            nl;
            dbms_output.put_line('Type    ' || rpad('Statistic Name',64) || lpad('Value',18));
            dbms_output.put_line(rpad('-',6,'-') || '  ' || rpad('-',64,'-') || '  ' || lpad('-',16,'-'));
         end if;
      end sh;

   begin

      -- Report header...
      -- ----------------
      nl;
      div('=');
      dbms_output.put_line('MyStats report : ' || to_char(sysdate,'dd-MON-YYYY hh24:mi:ss'));
      div('=');


      -- Summary timings...
      -- ------------------
      sh('1. Summary Timings');
      dbms_output.put_line(rpad('TIMER', 8) || rpad('snapshot interval (seconds)', 64) ||
                           lpad(to_char(round((p_times(c_snap2).ela-p_times(c_snap1).ela)/100,2), 'fm999,990.00'),18));
      dbms_output.put_line(rpad('TIMER', 8) || rpad('CPU time used (seconds)', 64) ||
                           lpad(to_char(round((p_times(c_snap2).cpu-p_times(c_snap1).cpu)/100,2), 'fm999,990.00'),18));


      -- Output the sorted stats...
      -- --------------------------
      sh('2. Statistics Report');

      for r in (  with ms_start as (
                        select extractValue(xs.object_value, '/ROW/TYPE')             as type
                        ,      extractValue(xs.object_value, '/ROW/NAME')             as name
                        ,      to_number(extractValue(xs.object_value, '/ROW/VALUE')) as value
                        from   table(xmlsequence(extract(xmltype(p_snaps.snap1), '/ROWSET/ROW'))) xs
                        )
                  ,    ms_stop as (
                        select extractValue(xs.object_value, '/ROW/TYPE')             as type
                        ,      extractValue(xs.object_value, '/ROW/NAME')             as name
                        ,      to_number(extractValue(xs.object_value, '/ROW/VALUE')) as value
                        from   table(xmlsequence(extract(xmltype(p_snaps.snap2), '/ROWSET/ROW'))) xs
                        )
                  ,    ms_diffs as (
                        select type
                        ,      name
                        ,      ms_stop.value - ms_start.value as diff
                        from   ms_start
                               inner join
                               ms_stop
                               using (type, name)
                        )
                  select type, name, diff
                  from   ms_diffs
                  where (&v_ms_option = 1 and abs(diff) >= &v_ms_threshold)
                  or    (&v_ms_option = 2 and name in (&v_ms_name_list))
                  or    (&v_ms_option = 3 and name like &v_ms_name_like)
                  or    (&v_ms_option = 4 and regexp_like(name, &v_ms_name_regexp, 'i'))
                  or     &v_ms_option = 0
                  order  by
                         abs(diff) )
      loop
         dbms_output.put_line(rpad(r.type,8) || rpad(r.name,64) || 
                              lpad(to_char(r.diff,'999,999,999,999'),18));
      end loop;

      -- Options...
      -- ----------
      sh('3. Options Used', false);
      ms_options;

      -- About...
      -- -------
      sh('4. About', false);
      ms_info;

      nl;
      div('=');
      dbms_output.put_line('End of report');
      div('=');

   end ms_report;

begin

   -- Runtime program...
   -- -------------------------------------------------------------------------
   if '&v_ms_snap' = 'start' then
      ms_snap(g_snaps.snap1);
      :bv_ms_start := g_snaps.snap1;
      ms_time(g_times, c_snap1);
      :bv_ms_ela_start := g_times(c_snap1).ela;
      :bv_ms_cpu_start := g_times(c_snap1).cpu;
   elsif '&v_ms_snap' = 'stop' then
      ms_time(g_times, c_snap2);
      g_snaps.snap1 := :bv_ms_start;
      g_times(c_snap1).ela := :bv_ms_ela_start;
      g_times(c_snap1).cpu := :bv_ms_cpu_start;
      ms_snap(g_snaps.snap2);
      ms_report(g_times, g_snaps);
   else
      raise_application_error( -20000, 
                              'Incorrect parameter at position 1 '||
                              '[used="&v_ms_snap"; valid="start" or "stop"]',
                              false );
   end if;

end;
/

-- Teardown section...
-- -----------------------------------------------------------------------
set termout off
spool "&c_ms_clear" replace
prompt &v_ms_if_stop undefine bv_ms_start
prompt &v_ms_if_stop undefine bv_ms_ela_start
prompt &v_ms_if_stop undefine bv_ms_cpu_start
prompt &v_ms_if_stop undefine v_ms_stattypes
prompt &v_ms_if_stop undefine v_ms_include_statistics
prompt &v_ms_if_stop undefine v_ms_include_latches
prompt &v_ms_if_stop undefine v_ms_include_time_model
prompt &v_ms_if_stop undefine v_ms_start_option
prompt &v_ms_if_stop undefine v_ms_stop_option
spool off
@"&c_ms_clear"
host &c_ms_rmcmd "&c_ms_clear"
undefine 1
undefine 2
undefine p_ms_snap
undefine p_ms_option
undefine v_ms_snap
undefine c_ms_rmcmd
undefine c_ms_init
undefine c_ms_clear
undefine v_ms_if_stop
undefine v_ms_if_start
undefine v_ms_threshold
undefine v_ms_name_list
undefine v_ms_name_like
undefine v_ms_name_regexp
undefine v_ms_option
undefine c_ms_version
set termout on
